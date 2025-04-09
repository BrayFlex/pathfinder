import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/behaviors/seek.dart';

// --- Mocks & Helpers ---

// Simple MockAgent for testing Seek behavior
class MockSeekAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0; // Set high, Seek doesn't use it directly
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockSeekAgent({
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
    // Handle potential NaN values from normalization edge cases if necessary
    if (expected.isNaN || v.isNaN) return false;
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

void main() {
  group('Seek Behavior', () {
    late MockSeekAgent agent;
    late Seek seekBehavior;
    final targetPosition = Vector2(100.0, 50.0);
    const maxSpeed = 10.0;

    setUp(() {
      agent = MockSeekAgent(
        position: Vector2.zero(), // Start at origin
        velocity: Vector2.zero(), // Start stationary
        maxSpeed: maxSpeed,
      );
      seekBehavior = Seek(target: targetPosition.clone());
    });

    test('calculates force towards target when stationary', () {
      final steering = seekBehavior.calculateSteering(agent);

      // Expected: Desired velocity is (target - position) normalized * maxSpeed
      final desired = (targetPosition - agent.position).normalized() * maxSpeed;
      // Steering = Desired - CurrentVelocity
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      // Force should point directly towards the target from origin
      expect(steering.x, greaterThan(0));
      expect(steering.y, greaterThan(0));
      // Magnitude should be maxSpeed since current velocity is zero
      expect(steering.length, closeTo(maxSpeed, 0.001));
    });

    test('calculates force towards target when moving away', () {
      agent.position = Vector2(10.0, 10.0);
      agent.velocity = Vector2(-5.0, -2.0); // Moving away from target (100, 50)

      final steering = seekBehavior.calculateSteering(agent);

      final desired = (targetPosition - agent.position).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      // Steering force should be strong and generally towards the target
      expect(steering.x, greaterThan(desired.x)); // Adds positive x to counter negative velocity
      expect(steering.y, greaterThan(desired.y)); // Adds positive y to counter negative velocity
    });

     test('calculates force towards target when moving towards', () {
      agent.position = Vector2(10.0, 10.0);
      // Moving somewhat towards the target (100, 50)
      agent.velocity = Vector2(5.0, 2.0);

      final steering = seekBehavior.calculateSteering(agent);

      final desired = (targetPosition - agent.position).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
       // Steering force should be smaller as velocity partially aligns with desired
       expect(steering.length, lessThan(maxSpeed * 2)); // Should be less than just desired + opposite velocity
    });

     test('calculates force towards target when moving perpendicular', () {
      agent.position = Vector2(100.0, 0.0); // Directly below target (100, 50)
      agent.velocity = Vector2(5.0, 0.0); // Moving right (perpendicular)

      final steering = seekBehavior.calculateSteering(agent);

      // Desired is purely vertical (0, 1) * maxSpeed = (0, 10)
      final desired = Vector2(0, 1.0) * maxSpeed;
      // Expected = (0, 10) - (5, 0) = (-5, 10)
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
    });

    test('returns zero vector when agent is very close to target', () {
      // Position agent extremely close to the target
      agent.position = targetPosition + Vector2(0.001, -0.001);
      agent.velocity = Vector2(1.0, 1.0); // Still moving

      final steering = seekBehavior.calculateSteering(agent);

      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero vector when agent is exactly at target', () {
      agent.position = targetPosition.clone();
      agent.velocity = Vector2(1.0, 1.0);

      final steering = seekBehavior.calculateSteering(agent);

      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('updates force calculation when target position changes', () {
      // Initial calculation towards (100, 50)
      final steering1 = seekBehavior.calculateSteering(agent);
      expect(steering1.x, greaterThan(0));
      expect(steering1.y, greaterThan(0));

      // Change target to be behind the agent
      seekBehavior.target = Vector2(-50.0, -20.0);
      final steering2 = seekBehavior.calculateSteering(agent);

      // Expected: Desired velocity towards new target (-50, -20) from origin
      final desired = (seekBehavior.target - agent.position).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity; // Velocity is still zero here

      expect(steering2, vectorCloseTo(expectedSteering, 0.001));
      expect(steering2.x, lessThan(0)); // Should now point negative x
      expect(steering2.y, lessThan(0)); // Should now point negative y
      expect(steering2.length, closeTo(maxSpeed, 0.001));
    });
  });
}
