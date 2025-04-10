import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math'; // For max()
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/obstacle.dart'; // Needs RectangleBoundary
import 'package:pathfinder/src/behaviors/containment.dart';

// --- Mocks & Helpers ---

// MockAgent for testing Containment
class MockContainmentAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0;
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockContainmentAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op
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

void main() {
  group('Containment Behavior', () {
    late MockContainmentAgent agent;
    late RectangleBoundary boundary;
    late Containment containmentBehavior;
    const maxSpeed = 10.0;
    const predictionDistance = 20.0;
    const forceMultiplier = 100.0;

    // Boundary from (0,0) to (100, 50)
    final minCorner = Vector2.zero();
    final maxCorner = Vector2(100.0, 50.0);

    setUp(() {
      agent = MockContainmentAgent(
        position: Vector2(50.0, 25.0), // Start in the center
        velocity: Vector2(maxSpeed, 0.0), // Moving right
        maxSpeed: maxSpeed,
      );
      boundary = RectangleBoundary(minCorner: minCorner, maxCorner: maxCorner);
      containmentBehavior = Containment(
        boundary: boundary,
        predictionDistance: predictionDistance,
        forceMultiplier: forceMultiplier,
      );
    });

     test('constructor throws assertion error for negative predictionDistance', () {
       expect(() => Containment(boundary: boundary, predictionDistance: -1.0),
            throwsA(isA<AssertionError>()));
       // Zero distance should be allowed
       expect(() => Containment(boundary: boundary, predictionDistance: 0.0), returnsNormally);
    });

    test('returns zero force when agent velocity is zero', () {
      agent.velocity.setZero();
      final steering = containmentBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when predicted position is inside boundary', () {
      // Agent at (50, 25), Vel (10, 0), PredDist 20 -> FuturePos (70, 25) - Inside
      final steering = containmentBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));

      // Agent near edge but prediction still inside
      agent.position = Vector2(maxCorner.x - predictionDistance * 0.5, 25.0); // At x=90
      // FuturePos (110, 25) -> WRONG, future pos is pos + norm(vel)*predDist = (90,25) + (1,0)*20 = (110, 25) -> OUTSIDE
      // Let's re-evaluate: Agent at x=90, FuturePos = 90 + 20 = 110. MaxX = 100. OUTSIDE.
      // Let's test agent near edge where prediction IS inside:
      agent.position = Vector2(maxCorner.x - predictionDistance * 1.1, 25.0); // At x = 100 - 22 = 78
      // FuturePos = 78 + 20 = 98. Inside.
      final steeringInside = containmentBehavior.calculateSteering(agent);
      expect(steeringInside, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('calculates force inwards when predicted position crosses right boundary', () {
      agent.position = Vector2(maxCorner.x - predictionDistance * 0.5, 25.0); // At x=90
      // FuturePos (110, 25) - Crosses right edge (x=100)

      final steering = containmentBehavior.calculateSteering(agent);
      // Corrective force should point left (-1, 0) and be scaled.
      // Penetration = 110 - 100 = 10. Factor = 10 / 20 = 0.5.
      // Scaled Force = normalize(-1, 0) * 100 * 0.5 = (-1, 0) * 50 = (-50, 0)
      final penetration = (agent.position.x + agent.velocity.normalized().x * predictionDistance) - maxCorner.x;
      final penetrationFactor = (penetration / predictionDistance).clamp(0.1, 1.5);
      final expectedForce = Vector2(-1.0, 0.0) * forceMultiplier * penetrationFactor;
      expect(steering, vectorCloseTo(expectedForce, 0.001));
    });

     test('calculates force inwards when predicted position crosses left boundary', () {
      agent.position = Vector2(minCorner.x + predictionDistance * 0.5, 25.0); // At x=10
      agent.velocity = Vector2(-maxSpeed, 0.0); // Moving left
      // FuturePos (-10, 25) - Crosses left edge (x=0)

      final steering = containmentBehavior.calculateSteering(agent);
      // FuturePos (-10, 25). Crosses left edge (x=0).
      // Corrective force should point right (1, 0) and be scaled.
      // Penetration = 0 - (-10) = 10. Factor = 10 / 20 = 0.5.
      // Scaled Force = normalize(1, 0) * 100 * 0.5 = (1, 0) * 50 = (50, 0)
      final futurePosition = agent.position + agent.velocity.normalized() * predictionDistance;
      final penetration = minCorner.x - futurePosition.x;
      final penetrationFactor = (penetration / predictionDistance).clamp(0.1, 1.5);
      final expectedForce = Vector2(1.0, 0.0) * forceMultiplier * penetrationFactor;
      expect(steering, vectorCloseTo(expectedForce, 0.001));
    });

      test('calculates force inwards when predicted position crosses top boundary', () {
      agent.position = Vector2(50.0, maxCorner.y - predictionDistance * 0.5); // At y=40
      agent.velocity = Vector2(0.0, maxSpeed); // Moving up
      // FuturePos (50, 60) - Crosses top edge (y=50)

      final steering = containmentBehavior.calculateSteering(agent);
      // FuturePos (50, 60). Crosses top edge (y=50).
      // Corrective force should point down (0, -1) and be scaled.
      // Penetration = 60 - 50 = 10. Factor = 10 / 20 = 0.5.
      // Scaled Force = normalize(0, -1) * 100 * 0.5 = (0, -1) * 50 = (0, -50)
      final futurePosition = agent.position + agent.velocity.normalized() * predictionDistance;
      final penetration = futurePosition.y - maxCorner.y;
      final penetrationFactor = (penetration / predictionDistance).clamp(0.1, 1.5);
      final expectedForce = Vector2(0.0, -1.0) * forceMultiplier * penetrationFactor;
      expect(steering, vectorCloseTo(expectedForce, 0.001));
    });

     test('calculates force inwards when predicted position crosses bottom boundary', () {
      agent.position = Vector2(50.0, minCorner.y + predictionDistance * 0.5); // At y=10
      agent.velocity = Vector2(0.0, -maxSpeed); // Moving down
      // FuturePos (50, -10) - Crosses bottom edge (y=0)

      final steering = containmentBehavior.calculateSteering(agent);
      // FuturePos (50, -10). Crosses bottom edge (y=0).
      // Corrective force should point up (0, 1) and be scaled.
      // Penetration = 0 - (-10) = 10. Factor = 10 / 20 = 0.5.
      // Scaled Force = normalize(0, 1) * 100 * 0.5 = (0, 1) * 50 = (0, 50)
      final futurePosition = agent.position + agent.velocity.normalized() * predictionDistance;
      final penetration = minCorner.y - futurePosition.y;
      final penetrationFactor = (penetration / predictionDistance).clamp(0.1, 1.5);
      final expectedForce = Vector2(0.0, 1.0) * forceMultiplier * penetrationFactor;
      expect(steering, vectorCloseTo(expectedForce, 0.001));
    });

     test('calculates force inwards when predicted position crosses corner', () {
      agent.position = Vector2(maxCorner.x - predictionDistance * 0.5,
                               maxCorner.y - predictionDistance * 0.5); // Near top-right corner (90, 40)
      agent.velocity = Vector2(maxSpeed, maxSpeed).normalized() * maxSpeed; // Moving towards top-right
      // FuturePos roughly (90,40) + (0.707, 0.707)*20 = (90,40) + (14.1, 14.1) = (104.1, 54.1)
      // Crosses right (x=100) and top (y=50)
      final futurePosition = agent.position + agent.velocity.normalized() * predictionDistance; // Define futurePosition

      final steering = containmentBehavior.calculateSteering(agent);
      // FuturePos (104.1, 54.1). Crosses right (x=100) and top (y=50).
      // Corrective force = (-1, -1). Max penetration factor based on larger penetration.
      // PenetrationX = 4.1, FactorX = 4.1/20 = 0.205
      // PenetrationY = 4.1, FactorY = 4.1/20 = 0.205
      // MaxFactor = 0.205.
      // Scaled Force = normalize(-1, -1) * 100 * 0.205 = (-0.707, -0.707) * 20.5 = (-14.5, -14.5) approx
      final expectedForceDir = Vector2(-1.0, -1.0).normalized();
      final penetrationX = futurePosition.x - maxCorner.x;
      final penetrationY = futurePosition.y - maxCorner.y;
      final maxPenFactor = max(penetrationX, penetrationY) / predictionDistance;
      final expectedForceMag = forceMultiplier * maxPenFactor.clamp(0.1, 1.5);
      final expectedForce = expectedForceDir * expectedForceMag;

      expect(steering, vectorCloseTo(expectedForce, 0.1)); // Use tolerance
    });

     test('force magnitude scales with forceMultiplier', () {
       agent.position = Vector2(maxCorner.x - predictionDistance * 0.5, 25.0); // At x=90, heading right

       final behaviorLowMult = Containment(
         boundary: boundary,
         predictionDistance: predictionDistance,
         forceMultiplier: 10.0, // Low multiplier
       );
        final behaviorHighMult = Containment(
         boundary: boundary,
         predictionDistance: predictionDistance,
         forceMultiplier: 200.0, // High multiplier
       );

       final correctiveLow = behaviorLowMult.calculateSteering(agent);
       final correctiveHigh = behaviorHighMult.calculateSteering(agent);

       // Compare the magnitudes of the corrective forces directly
       // Use closeTo with a small tolerance instead of greaterThan for robustness
       expect(correctiveHigh.length, greaterThan(correctiveLow.length + 1e-6));
       // Direction should be the same (pointing left, -1, 0)
       expect(correctiveLow.x, lessThan(-1e-6)); // Use tolerance
       expect(correctiveHigh.x, lessThan(-1e-6)); // Use tolerance
       expect(correctiveLow.y, closeTo(0.0, 0.001));
       expect(correctiveHigh.y, closeTo(0.0, 0.001));
     });

      test('force magnitude scales with penetration depth', () {
        // Agent moving right, crossing right boundary

        // Prediction far outside
        agent.position = Vector2(maxCorner.x - predictionDistance * 0.1, 25.0); // x=98
        // FuturePos = 98 + 20 = 118. Penetration = 18. Factor = 18/20 = 0.9
        final correctiveFarOut = containmentBehavior.calculateSteering(agent);

        // Prediction just outside
        agent.position = Vector2(maxCorner.x - predictionDistance * 0.4, 25.0); // x=92
        // FuturePos = 92 + 20 = 112. Penetration = 12. Factor = 12/20 = 0.6
        final correctiveNearOut = containmentBehavior.calculateSteering(agent);

        // Expect corrective force magnitude to be greater when penetration is larger
        expect(correctiveFarOut.length, greaterThan(correctiveNearOut.length + 1e-6)); // Use tolerance

        // Direction should be the same (left)
        expect(correctiveFarOut.x, lessThan(-1e-6)); // Use tolerance
        expect(correctiveNearOut.x, lessThan(-1e-6)); // Use tolerance
        expect(correctiveFarOut.y, closeTo(0.0, 0.001));
         expect(correctiveNearOut.y, closeTo(0.0, 0.001));
       });

      test('returns zero force when agent is exactly at boundary center (fallback case)', () {
        // Position agent exactly at the boundary center
        agent.position.setFrom(boundary.position);
        // Give it some velocity so the main check doesn't return early
        agent.velocity = Vector2(1.0, 0.0);

        final steering = containmentBehavior.calculateSteering(agent);
        // The fallback logic should result in zero force when agent is at the center
        expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
      });

      test('calculates force towards closest point when far outside boundary', () {
        // Position agent far outside the top-right corner
        agent.position = Vector2(150.0, 100.0);
        // Velocity doesn't matter much here, but give it some
        agent.velocity = Vector2(maxSpeed, maxSpeed).normalized() * maxSpeed;

        // The algorithm should find the closest point on the boundary, which is the
        // top-right corner (100, 50).
        final closestPoint = maxCorner; // (100, 50)
        final offset = closestPoint - agent.position; // (-50, -50)

        // The force should point towards this closest point.
        // Penetration factor calculation might be less relevant here,
        // but the direction should be correct.
        final steering = containmentBehavior.calculateSteering(agent);

        // Expect force to point towards (-1, -1) direction from (150, 100)
        expect(steering.x, lessThan(0));
        expect(steering.y, lessThan(0));
        // Check if the direction is roughly correct
        final expectedDir = offset.normalized();
       expect(steering.normalized(), vectorCloseTo(expectedDir, 0.1));
        // Magnitude should be significant due to being far outside
        expect(steering.length, greaterThan(forceMultiplier * 0.1)); // At least minimum clamped force
      });

     test('calculates force inwards based on crossed edges when agent starts outside boundary', () { // Renamed test
       // Position agent outside the top-left corner
       agent.position = Vector2(-50.0, 100.0);
       agent.velocity = Vector2(0.0, 0.0); // Stationary

       // Prediction is same as position. Outside boundary.
       // Crosses left edge (x=0) and top edge (y=50).
       // Corrective force direction should be (1, -1).
       final expectedDir = Vector2(1.0, -1.0).normalized(); // Correct expected direction

       final steering = containmentBehavior.calculateSteering(agent);
       final steeringDir = steering.normalized(); // Normalize the actual steering

       // Expect force to be non-zero and in the expected direction
       expect(steering.length, greaterThan(0.001));
       // Compare normalized components individually
       expect(steeringDir.x, closeTo(expectedDir.x, 0.001));
       expect(steeringDir.y, closeTo(expectedDir.y, 0.001));
     });

     test('returns zero force when agent is inside and moving towards center', () {
       // Agent well inside, moving towards center
       agent.position = Vector2(75.0, 30.0);
       agent.velocity = Vector2(-maxSpeed, -maxSpeed * 0.5); // Moving towards bottom-left

       // Prediction should still be well inside
       final futurePosition = agent.position + agent.velocity.normalized() * predictionDistance;
       expect(futurePosition.x, greaterThan(minCorner.x));
       expect(futurePosition.x, lessThan(maxCorner.x));
       expect(futurePosition.y, greaterThan(minCorner.y));
       expect(futurePosition.y, lessThan(maxCorner.y));

       final steering = containmentBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

  });
}
