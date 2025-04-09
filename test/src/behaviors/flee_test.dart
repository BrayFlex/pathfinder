import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/behaviors/flee.dart';

// --- Mocks & Helpers ---

// Simple MockAgent for testing Flee behavior
class MockFleeAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0; // Set high, Flee doesn't use it directly
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockFleeAgent({
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

void main() {
  group('Flee Behavior', () {
    late MockFleeAgent agent;
    late Flee fleeBehavior;
    final targetPosition = Vector2(100.0, 50.0);
    const maxSpeed = 10.0;

    setUp(() {
      agent = MockFleeAgent(
        position: Vector2(90.0, 45.0), // Start near the target
        velocity: Vector2.zero(),    // Start stationary
        maxSpeed: maxSpeed,
      );
      // Flee without radius initially
      fleeBehavior = Flee(target: targetPosition.clone());
    });

    test('constructor throws assertion error for non-positive fleeRadius', () {
       expect(() => Flee(target: targetPosition, fleeRadius: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => Flee(target: targetPosition, fleeRadius: -10.0),
            throwsA(isA<AssertionError>()));
        // Null radius should be allowed
       expect(() => Flee(target: targetPosition, fleeRadius: null), returnsNormally);
    });

    test('calculates force away from target when stationary', () {
      final steering = fleeBehavior.calculateSteering(agent);

      // Expected: Desired velocity is (position - target) normalized * maxSpeed
      final desired = (agent.position - targetPosition).normalized() * maxSpeed;
      // Steering = Desired - CurrentVelocity
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      // Force should point away from the target (target is 100,50, agent is 90,45 -> away is roughly -x, -y)
      expect(steering.x, lessThan(0));
      expect(steering.y, lessThan(0));
      // Magnitude should be maxSpeed since current velocity is zero
      expect(steering.length, closeTo(maxSpeed, 0.001));
    });

    test('calculates force away from target when moving towards', () {
      agent.velocity = Vector2(5.0, 2.0); // Moving somewhat towards target (100, 50)

      final steering = fleeBehavior.calculateSteering(agent);

      final desired = (agent.position - targetPosition).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      // Steering force should be strong, countering the current velocity
      expect(steering.x, lessThan(desired.x)); // Subtracts positive x velocity
      expect(steering.y, lessThan(desired.y)); // Subtracts positive y velocity
    });

     test('calculates force away from target when moving away', () {
      // Moving somewhat away from the target (100, 50)
      agent.velocity = Vector2(-5.0, -2.0);

      final steering = fleeBehavior.calculateSteering(agent);

      final desired = (agent.position - targetPosition).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
       // Steering force might be smaller as velocity partially aligns with desired flee direction
    });

    test('returns zero vector when agent is exactly at target', () {
      agent.position = targetPosition.clone();
      agent.velocity = Vector2(1.0, 1.0);

      final steering = fleeBehavior.calculateSteering(agent);

      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('updates force calculation when target position changes', () {
      // Initial calculation away from (100, 50) -> force is roughly (-x, -y)
      final steering1 = fleeBehavior.calculateSteering(agent);
      expect(steering1.x, lessThan(0));
      expect(steering1.y, lessThan(0));

      // Change target to be where the agent started (90, 45)
      fleeBehavior.target = Vector2(90.0, 45.0);
      final steering2 = fleeBehavior.calculateSteering(agent);

      // Agent is now exactly at target, should return zero
      expect(steering2, vectorCloseTo(Vector2.zero(), 0.001));

      // Change target again, far away
       fleeBehavior.target = Vector2(-100, -100);
       final steering3 = fleeBehavior.calculateSteering(agent);
       // Desired away from (-100,-100) towards (90,45) -> roughly (+x, +y)
       final desired = (agent.position - fleeBehavior.target).normalized() * maxSpeed;
       final expectedSteering = desired - agent.velocity; // Velocity is still zero
       expect(steering3, vectorCloseTo(expectedSteering, 0.001));
       expect(steering3.x, greaterThan(0));
       expect(steering3.y, greaterThan(0));
    });

    group('with fleeRadius', () {
      const radius = 20.0;
      const radiusSq = radius * radius;

      setUp(() {
         // Flee with radius
         fleeBehavior = Flee(target: targetPosition.clone(), fleeRadius: radius);
         // Agent starts near target (90, 45) -> distance sqrt(10^2 + 5^2) = sqrt(125) approx 11.18
         agent.position = Vector2(90.0, 45.0);
         agent.velocity = Vector2.zero();
      });

      test('calculates flee force when agent is inside radius', () {
         final distanceSq = agent.position.distanceToSquared(targetPosition);
         expect(distanceSq, lessThan(radiusSq)); // Verify agent is inside

         final steering = fleeBehavior.calculateSteering(agent);
         expect(steering.length, closeTo(maxSpeed, 0.001)); // Should flee
         expect(steering.x, lessThan(0));
         expect(steering.y, lessThan(0));
      });

      test('returns zero force when agent is outside radius', () {
         agent.position = Vector2(0.0, 0.0); // Far from target (100, 50)
         final distanceSq = agent.position.distanceToSquared(targetPosition);
         expect(distanceSq, greaterThan(radiusSq)); // Verify agent is outside

         final steering = fleeBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
      });

       test('calculates flee force when agent is exactly on radius boundary', () {
         // Position agent exactly 'radius' distance away horizontally
         agent.position = targetPosition + Vector2(-radius, 0.0);
         final distanceSq = agent.position.distanceToSquared(targetPosition);
         expect(distanceSq, closeTo(radiusSq, 0.001)); // Verify agent is on boundary

         // Since check is distanceSquared > fleeRadiusSq, it should NOT flee if exactly on boundary
         final steering = fleeBehavior.calculateSteering(agent);
         // Let's re-read the code: `distanceSquared > fleeRadius! * fleeRadius!`
         // If distanceSq == radiusSq, the condition is false, so it *should* flee.
         expect(steering.length, closeTo(maxSpeed, 0.001));
         expect(steering.x, closeTo(-maxSpeed, 0.001)); // Fleeing directly left
         expect(steering.y, closeTo(0.0, 0.001));
       });

        test('returns zero force when agent moves from inside to outside radius', () {
          // Start inside
          agent.position = targetPosition + Vector2(radius * 0.5, 0);
          expect(fleeBehavior.calculateSteering(agent).length, greaterThan(0));

          // Move outside
          agent.position = targetPosition + Vector2(radius * 1.1, 0);
           expect(fleeBehavior.calculateSteering(agent), vectorCloseTo(Vector2.zero(), 0.001));
        });

         test('calculates flee force when agent moves from outside to inside radius', () {
          // Start outside
          agent.position = targetPosition + Vector2(radius * 1.1, 0);
          expect(fleeBehavior.calculateSteering(agent), vectorCloseTo(Vector2.zero(), 0.001));

          // Move inside
          agent.position = targetPosition + Vector2(radius * 0.9, 0); // e.g., at (118, 50) if target is (100,50), radius 20
          agent.velocity.setZero(); // Ensure velocity is zero for clear expectation
          final steering = fleeBehavior.calculateSteering(agent);
          // Desired velocity is away from target: (pos - target).normalized * maxSpeed
          // (118, 50) - (100, 50) = (18, 0). Normalized (1, 0). Desired = (10, 0).
          // Steering = Desired - Current = (10, 0) - (0, 0) = (10, 0).
          // Let's re-read the code: desiredVelocity = offset.normalized() * agent.maxSpeed; offset = agent.position - target;
          // offset = (90, 45) - (100, 50) = (-10, -5). Normalized approx (-0.89, -0.45). Desired approx (-8.9, -4.5).
          // Let's re-run the specific test case mentally:
          // Target (100, 50). Radius 20. Agent moves to (118, 50).
          // Offset = (118, 50) - (100, 50) = (18, 0). Normalized = (1, 0).
          // Desired = (1, 0) * 10 = (10, 0).
          // Steering = (10, 0) - (0, 0) = (10, 0).
          // The previous test comment "Fleeing left" was incorrect for this setup.
          expect(steering.length, closeTo(maxSpeed, 0.001));
          expect(steering.x, closeTo(maxSpeed, 0.001)); // Fleeing right (away from 100,50)
          expect(steering.y, closeTo(0.0, 0.001));
        });
    });
  });
}
