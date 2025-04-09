import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/behaviors/arrival.dart';

// --- Mocks & Helpers ---

// Simple MockAgent for testing Arrival behavior
class MockArrivalAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0; // Set high, Arrival doesn't use it directly
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockArrivalAgent({
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
  group('Arrival Behavior', () {
    late MockArrivalAgent agent;
    late Arrival arrivalBehavior;
    final targetPosition = Vector2(100.0, 0.0);
    const maxSpeed = 10.0;
    const slowingRadius = 20.0;
    const arrivalTolerance = 2.0; // Use a slightly larger tolerance for easier testing

    setUp(() {
      agent = MockArrivalAgent(
        position: Vector2.zero(), // Start at origin
        velocity: Vector2.zero(), // Start stationary
        maxSpeed: maxSpeed,
      );
      arrivalBehavior = Arrival(
        target: targetPosition.clone(),
        slowingRadius: slowingRadius,
        arrivalTolerance: arrivalTolerance,
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => Arrival(target: targetPosition, slowingRadius: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => Arrival(target: targetPosition, slowingRadius: -10.0),
            throwsA(isA<AssertionError>()));
       expect(() => Arrival(target: targetPosition, slowingRadius: slowingRadius, arrivalTolerance: -0.1),
            throwsA(isA<AssertionError>()));
       // Zero tolerance should be allowed
       expect(() => Arrival(target: targetPosition, slowingRadius: slowingRadius, arrivalTolerance: 0.0), returnsNormally);
    });

    test('behaves like Seek when far outside slowingRadius', () {
      agent.position = Vector2(0, 0); // Far from target (100, 0)
      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected: Desired velocity is towards target at maxSpeed
      final desired = (targetPosition - agent.position).normalized() * maxSpeed;
      // Steering = Desired - CurrentVelocity
      final expectedSteering = desired - agent.velocity; // Velocity is zero

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.length, closeTo(maxSpeed, 0.001));
      expect(steering.x, closeTo(maxSpeed, 0.001)); // Moving right
      expect(steering.y, closeTo(0.0, 0.001));
    });

     test('behaves like Seek when exactly at slowingRadius boundary', () {
      agent.position = targetPosition + Vector2(-slowingRadius, 0); // At (80, 0)
      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected: Still seeks at maxSpeed
      final desired = (targetPosition - agent.position).normalized() * maxSpeed;
      final expectedSteering = desired - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.length, closeTo(maxSpeed, 0.001));
      expect(steering.x, closeTo(maxSpeed, 0.001));
      expect(steering.y, closeTo(0.0, 0.001));
    });

    test('ramps down speed when inside slowingRadius', () {
      // Position agent halfway inside slowing radius
      final distance = slowingRadius * 0.5;
      agent.position = targetPosition + Vector2(-distance, 0); // At (90, 0)

      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected speed = maxSpeed * (distance / slowingRadius) = maxSpeed * 0.5
      final expectedSpeed = maxSpeed * 0.5;
      final desiredDirection = (targetPosition - agent.position).normalized();
      final desired = desiredDirection * expectedSpeed;
      final expectedSteering = desired - agent.velocity; // Velocity is zero

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.length, closeTo(expectedSpeed, 0.001));
      expect(steering.x, closeTo(expectedSpeed, 0.001)); // Moving right, but slower
      expect(steering.y, closeTo(0.0, 0.001));
    });

     test('ramps down speed correctly when moving towards target inside slowingRadius', () {
      final distance = slowingRadius * 0.5;
      agent.position = targetPosition + Vector2(-distance, 0); // At (90, 0)
      agent.velocity = Vector2(maxSpeed * 0.2, 0); // Moving slowly towards target

      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected speed = maxSpeed * 0.5
      final expectedSpeed = maxSpeed * 0.5;
      final desiredDirection = (targetPosition - agent.position).normalized();
      final desired = desiredDirection * expectedSpeed;
      // Steering = Desired - CurrentVelocity
      final expectedSteering = desired - agent.velocity; // (5,0) - (2,0) = (3,0)

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.length, closeTo(expectedSpeed - agent.velocity.x, 0.001));
    });

     test('ramps down speed correctly when moving away from target inside slowingRadius', () {
      final distance = slowingRadius * 0.5;
      agent.position = targetPosition + Vector2(-distance, 0); // At (90, 0)
      agent.velocity = Vector2(-maxSpeed * 0.2, 0); // Moving slowly away from target

      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected speed = maxSpeed * 0.5
      final expectedSpeed = maxSpeed * 0.5;
      final desiredDirection = (targetPosition - agent.position).normalized();
      final desired = desiredDirection * expectedSpeed;
      // Steering = Desired - CurrentVelocity
      final expectedSteering = desired - agent.velocity; // (5,0) - (-2,0) = (7,0)

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.length, closeTo(expectedSpeed + agent.velocity.x.abs(), 0.001));
    });


    test('applies braking force when inside arrivalTolerance', () {
      // Position agent just inside arrival tolerance
      final distance = arrivalTolerance * 0.5;
      agent.position = targetPosition + Vector2(-distance, 0); // At (99, 0)
      agent.velocity = Vector2(maxSpeed * 0.1, 0); // Still moving slightly

      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected steering is opposite to current velocity
      final expectedSteering = -agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
      expect(steering.x, closeTo(-maxSpeed * 0.1, 0.001));
      expect(steering.y, closeTo(0.0, 0.001));
    });

     test('applies braking force when exactly at target', () {
      agent.position = targetPosition.clone();
      agent.velocity = Vector2(1.0, -0.5); // Some residual velocity

      final steering = arrivalBehavior.calculateSteering(agent);

      // Expected steering is opposite to current velocity
      final expectedSteering = -agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
       expect(steering.x, closeTo(-1.0, 0.001));
       expect(steering.y, closeTo(0.5, 0.001));
    });

     test('calculates normally when just outside arrivalTolerance', () {
       // Position agent just outside arrival tolerance, but inside slowing radius
       final distance = arrivalTolerance * 1.1; // e.g., 2.2
       agent.position = targetPosition + Vector2(-distance, 0);
       agent.velocity = Vector2.zero();

       final steering = arrivalBehavior.calculateSteering(agent);

       // Expected speed should be ramped down
       final expectedSpeed = maxSpeed * (distance / slowingRadius);
       final desiredDirection = (targetPosition - agent.position).normalized();
       final desired = desiredDirection * expectedSpeed;
       final expectedSteering = desired - agent.velocity;

       expect(steering, vectorCloseTo(expectedSteering, 0.001));
       expect(steering.length, closeTo(expectedSpeed, 0.001));
       // Should not be the braking force (-agent.velocity)
       expect(steering, isNot(vectorCloseTo(-agent.velocity, 0.001)));
     });

     test('updates calculation when target position changes', () {
       // Initial calculation towards (100, 0) from (0,0) -> Seek at maxSpeed
       final steering1 = arrivalBehavior.calculateSteering(agent);
       expect(steering1.length, closeTo(maxSpeed, 0.001));

       // Move target close, inside slowing radius
       arrivalBehavior.target = Vector2(10, 0); // Distance 10, slowingRadius 20
       final steering2 = arrivalBehavior.calculateSteering(agent);
       final expectedSpeed2 = maxSpeed * (10.0 / slowingRadius);
       expect(steering2.length, closeTo(expectedSpeed2, 0.001));

       // Move target very close, inside arrival tolerance
       arrivalBehavior.target = Vector2(1, 0); // Distance 1, tolerance 2
       agent.velocity = Vector2(0.5, 0); // Give some velocity
       final steering3 = arrivalBehavior.calculateSteering(agent);
       expect(steering3, vectorCloseTo(-agent.velocity, 0.001)); // Braking force
     });

  });
}
