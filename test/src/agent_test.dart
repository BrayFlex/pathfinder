import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart'; // Use vector_math_64
import 'package:pathfinder/src/agent.dart';

// Concrete implementation for testing
class MockAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce; // Although Agent defines maxForce, applySteering receives already truncated force
  @override
  double mass;
  @override
  double radius;

  MockAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
    required this.maxForce, // Keep for setup consistency, though not directly used in applySteering logic here
    required this.mass,
    this.radius = 1.0, // Default radius
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    if (deltaTime <= 0) return; // No change if time doesn't pass

    // Note: SteeringManager usually truncates force by maxForce *before* calling applySteering.
    // The agent's responsibility is primarily applying physics and maxSpeed clamping.
    Vector2 acceleration = steeringForce / mass;
    velocity = (velocity + acceleration * deltaTime);

    // Clamp velocity by maxSpeed
    if (velocity.length2 > maxSpeed * maxSpeed && maxSpeed > 0) {
       velocity.length = maxSpeed;
    } else if (maxSpeed == 0) {
      velocity.setZero(); // If maxSpeed is zero, velocity must be zero
    }

    position += velocity * deltaTime;
  }
}


void main() {
  group('Agent (via MockAgent)', () { // Updated group name
    late MockAgent agent; // Use MockAgent
    final initialPosition = Vector2(10.0, 20.0);
    final initialVelocity = Vector2(1.0, -1.0);
    const maxSpeed = 5.0;
    const maxForce = 0.5;
    const mass = 1.0;
    const radius = 5.0; // Example radius

    setUp(() {
      // Instantiate MockAgent
      agent = MockAgent(
        position: initialPosition.clone(),
        velocity: initialVelocity.clone(),
        maxSpeed: maxSpeed,
        maxForce: maxForce, // Passed for consistency, but truncation happens before applySteering
        mass: mass,
        radius: radius,
      );
    });

    test('constructor initializes properties correctly (via MockAgent)', () {
      expect(agent.position, equals(initialPosition));
      expect(agent.velocity, equals(initialVelocity));
      expect(agent.maxSpeed, equals(maxSpeed));
      expect(agent.maxForce, equals(maxForce)); // Test the value passed to constructor
      expect(agent.mass, equals(mass));
      expect(agent.radius, equals(radius)); // Check radius
    });

    test('applySteering applies velocity to position correctly (zero force)', () {
      const dt = 1.0; // Time delta
      agent.applySteering(Vector2.zero(), dt); // Use applySteering

      // Calculate expected velocity after potential clamping (though unlikely here)
      final expectedVelocity = initialVelocity.clone();
      if (expectedVelocity.length2 > maxSpeed * maxSpeed && maxSpeed > 0) {
        expectedVelocity.length = maxSpeed;
      }
      final expectedPosition = initialPosition + expectedVelocity * dt;

      expect(agent.position.x, closeTo(expectedPosition.x, 0.001));
      expect(agent.position.y, closeTo(expectedPosition.y, 0.001));
      // Velocity should remain unchanged without steering force
      expect(agent.velocity.x, closeTo(initialVelocity.x, 0.001));
      expect(agent.velocity.y, closeTo(initialVelocity.y, 0.001));
    });

    test('applySteering applies steering force to velocity correctly', () {
      const dt = 1.0;
      final steeringForce = Vector2(0.5, 0.0); // Assume this force is already truncated if needed
      // Expected acceleration = steeringForce / mass
      final expectedAcceleration = steeringForce / mass;
      // Expected change in velocity = acceleration * dt
      final expectedDeltaV = expectedAcceleration * dt;
      var expectedVelocity = initialVelocity + expectedDeltaV; // Calculate potential new velocity

      // Apply maxSpeed clamping if necessary
      if (expectedVelocity.length2 > maxSpeed * maxSpeed && maxSpeed > 0) {
        expectedVelocity.length = maxSpeed;
      }

      agent.applySteering(steeringForce, dt); // Call applySteering

      // Position update uses the *final* (potentially clamped) velocity
      final expectedPosition = initialPosition + agent.velocity * dt; // Use agent's actual final velocity

      expect(agent.velocity.x, closeTo(expectedVelocity.x, 0.001));
      expect(agent.velocity.y, closeTo(expectedVelocity.y, 0.001));
      expect(agent.position.x, closeTo(expectedPosition.x, 0.001));
      expect(agent.position.y, closeTo(expectedPosition.y, 0.001));
    });

     // Removed 'update truncates steering force' test as truncation happens before applySteering

     test('applySteering truncates velocity exceeding maxSpeed', () {
      const dt = 1.0;
      // Force that will push velocity over maxSpeed
      // Assume force is already truncated by maxForce if necessary by SteeringManager
      final strongForce = Vector2(maxForce, 0.0); // Use maxForce or less
      // Start close to maxSpeed but ensure applying force will exceed it
      agent.velocity = Vector2(maxSpeed * 0.9, 0.0);
      final initialPosForThisTest = agent.position.clone(); // Capture position before update

      agent.applySteering(strongForce, dt); // Use applySteering

      // Velocity should be capped at maxSpeed
      expect(agent.velocity.length, closeTo(maxSpeed, 0.001));
      // Check direction is maintained (approximately, should still be positive x)
      expect(agent.velocity.x, greaterThan(0));
      expect(agent.velocity.y, closeTo(0.0, 0.001));

      // Position update uses the *clamped* velocity
      final expectedFinalPosition = initialPosForThisTest + agent.velocity * dt;

      expect(agent.position.x, closeTo(expectedFinalPosition.x, 0.001));
      expect(agent.position.y, closeTo(expectedFinalPosition.y, 0.001));
    });

    test('applySteering handles zero dt correctly', () {
      final initialPos = agent.position.clone();
      final initialVel = agent.velocity.clone();
      agent.applySteering(Vector2(1.0, 1.0), 0.0); // Zero time delta

      expect(agent.position, equals(initialPos)); // Position shouldn't change
      expect(agent.velocity, equals(initialVel)); // Velocity shouldn't change
    });

     // Removed 'update handles zero maxForce' test as logic is in SteeringManager

     test('applySteering handles zero maxSpeed correctly', () {
      // Re-initialize agent with maxSpeed = 0
      agent = MockAgent(
        position: initialPosition.clone(),
        velocity: initialVelocity.clone(), // Start with some velocity
        maxSpeed: 0.0, // Zero max speed
        maxForce: maxForce,
        mass: mass,
        radius: radius,
      );
      const dt = 1.0;
      final steeringForce = Vector2(0.1, 0.0); // Apply some force

      agent.applySteering(steeringForce, dt); // Use applySteering

      // Velocity should be clamped to zero by applySteering logic
      expect(agent.velocity.x, closeTo(0.0, 0.001));
      expect(agent.velocity.y, closeTo(0.0, 0.001));

      // Position should not change as velocity becomes zero and dt > 0
      expect(agent.position.x, closeTo(initialPosition.x, 0.001));
      expect(agent.position.y, closeTo(initialPosition.y, 0.001));
    });

    test('applySteering does nothing if deltaTime is zero or negative', () {
      final initialPos = agent.position.clone();
      final initialVel = agent.velocity.clone();
      final steering = Vector2(10.0, 10.0);

      agent.applySteering(steering, 0.0); // Zero deltaTime
      expect(agent.position, equals(initialPos), reason: 'Position changed with dt=0');
      expect(agent.velocity, equals(initialVel), reason: 'Velocity changed with dt=0');

      agent.applySteering(steering, -1.0); // Negative deltaTime
      expect(agent.position, equals(initialPos), reason: 'Position changed with dt<0');
      expect(agent.velocity, equals(initialVel), reason: 'Velocity changed with dt<0');
    });

  });
}
