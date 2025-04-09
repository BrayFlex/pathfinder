import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/behaviors/pursuit.dart';

// --- Mocks & Helpers ---

// MockAgent for testing Pursuit behavior (can be pursuer or target)
class MockPursuitAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0; // Set high, Pursuit doesn't use it directly
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockPursuitAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op for behavior tests
  }
}

// Helper for vector comparison with tolerance
Matcher vectorCloseTo(Vector2 expected, double tolerance) {
  return predicate((v) {
    if (v is! Vector2) return false;
    if (expected.isNaN || v.isNaN) return false;
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

// Helper to calculate expected seek force (used internally by Pursuit)
Vector2 calculateSeekForce(Agent agent, Vector2 targetPosition) {
   final desiredVelocity = targetPosition - agent.position;
    const double closeEnoughSquared = 0.01 * 0.01;
    if (desiredVelocity.length2 < closeEnoughSquared) {
      return Vector2.zero();
    }
    desiredVelocity.normalize();
    desiredVelocity.scale(agent.maxSpeed);
    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
}


void main() {
  group('Pursuit Behavior', () {
    late MockPursuitAgent pursuer;
    late MockPursuitAgent targetAgent;
    late Pursuit pursuitBehavior;
    const pursuerMaxSpeed = 10.0;

    setUp(() {
      pursuer = MockPursuitAgent(
        position: Vector2.zero(),
        velocity: Vector2.zero(),
        maxSpeed: pursuerMaxSpeed,
      );
      targetAgent = MockPursuitAgent(
        position: Vector2(100.0, 0.0), // Target starts 100 units right
        velocity: Vector2(0.0, 5.0),   // Target moving up
        maxSpeed: 5.0,
      );
      pursuitBehavior = Pursuit(targetAgent: targetAgent);
    });

     test('constructor throws assertion error for negative maxPredictionTime', () {
       expect(() => Pursuit(targetAgent: targetAgent, maxPredictionTime: -1.0),
            throwsA(isA<AssertionError>()));
       // Null and zero should be allowed
       expect(() => Pursuit(targetAgent: targetAgent, maxPredictionTime: null), returnsNormally);
       expect(() => Pursuit(targetAgent: targetAgent, maxPredictionTime: 0.0), returnsNormally);
    });

    test('behaves like Seek when target is stationary', () {
      targetAgent.velocity.setZero(); // Make target stationary
      final steering = pursuitBehavior.calculateSteering(pursuer);
      final expectedSeek = calculateSeekForce(pursuer, targetAgent.position);

      expect(steering, vectorCloseTo(expectedSeek, 0.001));
    });

     test('behaves like Seek when pursuer is very close', () {
       pursuer.position = targetAgent.position + Vector2(0.01, 0); // Very close
       final steering = pursuitBehavior.calculateSteering(pursuer);
       final expectedSeek = calculateSeekForce(pursuer, targetAgent.position);

       expect(steering, vectorCloseTo(expectedSeek, 0.001));
     });

    test('predicts future position and seeks it (target moving away)', () {
      // Target at (100, 0), moving up (0, 5)
      // Pursuer at (0, 0), maxSpeed 10
      // Distance = 100
      // Prediction time T = distance / pursuerMaxSpeed = 100 / 10 = 10 seconds
      final predictionTime = 10.0;
      // Future position = targetPos + targetVel * T = (100, 0) + (0, 5) * 10 = (100, 50)
      final futurePosition = targetAgent.position + targetAgent.velocity * predictionTime;

      final steering = pursuitBehavior.calculateSteering(pursuer);
      final expectedSeek = calculateSeekForce(pursuer, futurePosition);

      expect(steering, vectorCloseTo(expectedSeek, 0.001));
      // Steering should point towards (100, 50) from (0,0)
      expect(steering.x, greaterThan(0));
      expect(steering.y, greaterThan(0));
    });

     test('predicts future position and seeks it (target moving towards)', () {
       // Target at (100, 0), moving left (-5, 0)
       // Pursuer at (0, 0), maxSpeed 10
       targetAgent.velocity.setValues(-5.0, 0.0);
       // Distance = 100
       // Prediction time T = 100 / 10 = 10 seconds
       final predictionTime = 10.0;
       // Future position = (100, 0) + (-5, 0) * 10 = (50, 0)
       final futurePosition = targetAgent.position + targetAgent.velocity * predictionTime;

       final steering = pursuitBehavior.calculateSteering(pursuer);
       final expectedSeek = calculateSeekForce(pursuer, futurePosition);

       expect(steering, vectorCloseTo(expectedSeek, 0.001));
       // Steering should point towards (50, 0) from (0,0) -> purely right
       expect(steering.x, closeTo(pursuerMaxSpeed, 0.001));
       expect(steering.y, closeTo(0.0, 0.001));
     });

     test('predicts future position and seeks it (pursuer moving)', () {
       // Target at (100, 0), moving up (0, 5)
       // Pursuer at (0, 0), moving right (5, 0), maxSpeed 10
       pursuer.velocity.setValues(5.0, 0.0);
       // Distance = 100
       // Prediction time T = 100 / 10 = 10 seconds
       final predictionTime = 10.0;
       // Future position = (100, 0) + (0, 5) * 10 = (100, 50)
       final futurePosition = targetAgent.position + targetAgent.velocity * predictionTime;

       final steering = pursuitBehavior.calculateSteering(pursuer);
       // Expected seek force towards (100, 50)
       final expectedSeek = calculateSeekForce(pursuer, futurePosition);

       expect(steering, vectorCloseTo(expectedSeek, 0.001));
       // Desired velocity is towards (100, 50), normalized * 10
       // Steering = Desired - (5, 0)
     });

    group('with maxPredictionTime', () {
       test('clamps prediction time when estimate exceeds max', () {
         // Target at (100, 0), moving up (0, 5)
         // Pursuer at (0, 0), maxSpeed 10
         // Distance = 100 -> Estimated T = 10 seconds
         final maxPrediction = 5.0; // Clamp prediction to 5 seconds
         pursuitBehavior = Pursuit(targetAgent: targetAgent, maxPredictionTime: maxPrediction);

         // Future position = targetPos + targetVel * maxT = (100, 0) + (0, 5) * 5 = (100, 25)
         final futurePosition = targetAgent.position + targetAgent.velocity * maxPrediction;

         final steering = pursuitBehavior.calculateSteering(pursuer);
         final expectedSeek = calculateSeekForce(pursuer, futurePosition);

         expect(steering, vectorCloseTo(expectedSeek, 0.001));
         // Steering should point towards (100, 25) - less steep than without clamping
       });

        test('does not clamp prediction time when estimate is below max', () {
         // Target at (50, 0), moving up (0, 5)
         // Pursuer at (0, 0), maxSpeed 10
         // Distance = 50 -> Estimated T = 5 seconds
         targetAgent.position.setValues(50.0, 0.0);
         final estimatedPredictionTime = 5.0;

         final maxPrediction = 8.0; // Max prediction > estimated T
         pursuitBehavior = Pursuit(targetAgent: targetAgent, maxPredictionTime: maxPrediction);

         // Future position = targetPos + targetVel * estimatedT = (50, 0) + (0, 5) * 5 = (50, 25)
         final futurePosition = targetAgent.position + targetAgent.velocity * estimatedPredictionTime;

         final steering = pursuitBehavior.calculateSteering(pursuer);
         final expectedSeek = calculateSeekForce(pursuer, futurePosition);

         expect(steering, vectorCloseTo(expectedSeek, 0.001));
       });

        test('handles zero maxPredictionTime (behaves like Seek)', () {
          pursuitBehavior = Pursuit(targetAgent: targetAgent, maxPredictionTime: 0.0);
          // Future position = targetPos + targetVel * 0 = targetPos
          final futurePosition = targetAgent.position;

          final steering = pursuitBehavior.calculateSteering(pursuer);
          final expectedSeek = calculateSeekForce(pursuer, futurePosition);

           expect(steering, vectorCloseTo(expectedSeek, 0.001));
        });
    });

    test('returns zero force when target is stationary and pursuer is at target', () {
      // Make target stationary
      targetAgent.velocity.setZero();
      // Place pursuer exactly at the target's position
      pursuer.position.setFrom(targetAgent.position);
      pursuer.velocity = Vector2(1.0, 0.0); // Give some velocity, shouldn't matter

      // calculateSteering should call _seek(agent, targetAgent.position)
      final steering = pursuitBehavior.calculateSteering(pursuer);

      // Inside _seek, desiredVelocity = targetPos - agent.pos = (0,0).
      // Should return zero vector due to the closeEnough check.
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });
  });
}
