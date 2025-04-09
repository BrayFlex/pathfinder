import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/steering_behavior.dart';
import 'package:pathfinder/src/steering_manager.dart';

// --- Mocks ---

// Simple MockAgent for testing SteeringManager
class MockManagerAgent implements Agent {
  @override
  Vector2 position = Vector2.zero();
  @override
  Vector2 velocity = Vector2.zero();
  @override
  double maxSpeed;
  @override
  double maxForce;
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  // To verify applySteering was called correctly
  Vector2? lastAppliedForce;
  double? lastDeltaTime;

  MockManagerAgent({this.maxSpeed = 100.0, this.maxForce = 10.0});

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    lastAppliedForce = steeringForce.clone(); // Clone to capture the value
    lastDeltaTime = deltaTime;
    // Simulate basic physics for potential future tests if needed
    // Vector2 acceleration = steeringForce / mass;
    // velocity = (velocity + acceleration * deltaTime).clampMagnitude(maxSpeed);
    // position += velocity * deltaTime;
  }
}

// Mock SteeringBehavior that returns a fixed force
class MockBehavior implements SteeringBehavior {
  final Vector2 forceToReturn;
  int calculateCallCount = 0; // To track calls

  MockBehavior(this.forceToReturn);

  @override
  Vector2 calculateSteering(Agent agent) {
    calculateCallCount++;
    return forceToReturn.clone(); // Return a clone
  }
}

// Helper for vector comparison with tolerance
Matcher vectorCloseTo(Vector2 expected, double tolerance) {
  return predicate((v) {
    if (v is! Vector2) return false;
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}


void main() {
  group('SteeringManager', () {
    late MockManagerAgent agent;
    late SteeringManager manager;

    setUp(() {
      agent = MockManagerAgent(maxForce: 10.0); // Example maxForce
      manager = SteeringManager(agent);
    });

    test('constructor initializes with agent', () {
      expect(manager.agent, equals(agent));
      // expect(manager._behaviors, isEmpty); // Internal check
    });

    group('add/remove/clear behaviors', () {
      final behavior1 = MockBehavior(Vector2(1, 0));
      final behavior2 = MockBehavior(Vector2(0, 1));

      test('add behavior increases behavior count', () {
        manager.add(behavior1);
        // Cannot directly check _behaviors.length, test via calculate
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2(1,0), 0.001));
      });

       test('add behavior with weight', () {
        manager.add(behavior1, weight: 2.0);
        final force = manager.calculateSteering();
         // Force = behaviorForce * weight = (1,0) * 2.0 = (2,0)
        expect(force, vectorCloseTo(Vector2(2,0), 0.001));
      });

      test('remove behavior decreases behavior count', () {
        manager.add(behavior1);
        manager.add(behavior2);
        manager.remove(behavior1);
        // Only behavior2 should remain
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2(0,1), 0.001));
      });

       test('remove non-existent behavior does nothing', () {
         manager.add(behavior1);
         manager.remove(behavior2); // behavior2 was never added
         final force = manager.calculateSteering();
         expect(force, vectorCloseTo(Vector2(1,0), 0.001)); // behavior1 still there
       });

      test('clear removes all behaviors', () {
        manager.add(behavior1);
        manager.add(behavior2);
        manager.clear();
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2.zero(), 0.001));
      });
    });

    group('calculateSteering', () {
      final behaviorX = MockBehavior(Vector2(5, 0)); // Force along X
      final behaviorY = MockBehavior(Vector2(0, 8)); // Force along Y
      final behaviorDiag = MockBehavior(Vector2(3, 4)); // Force diagonal (length 5)

      test('returns zero vector when no behaviors', () {
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2.zero(), 0.001));
      });

      test('returns force from single behavior (weight 1.0)', () {
        manager.add(behaviorX);
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2(5, 0), 0.001));
      });

      test('returns weighted force from single behavior', () {
        manager.add(behaviorX, weight: 1.5);
        final force = manager.calculateSteering();
        // Expected = (5, 0) * 1.5 = (7.5, 0)
        expect(force, vectorCloseTo(Vector2(7.5, 0), 0.001));
      });

      test('sums forces from multiple behaviors (weight 1.0)', () {
        manager.add(behaviorX);
        manager.add(behaviorY);
        final force = manager.calculateSteering();
        // Expected = (5, 0) + (0, 8) = (5, 8)
        expect(force, vectorCloseTo(Vector2(5, 8), 0.001));
      });

      test('sums weighted forces from multiple behaviors', () {
        manager.add(behaviorX, weight: 1.0); // (5, 0) * 1.0 = (5, 0)
        manager.add(behaviorY, weight: 0.5); // (0, 8) * 0.5 = (0, 4)
        final force = manager.calculateSteering();
        // Expected = (5, 0) + (0, 4) = (5, 4)
        expect(force, vectorCloseTo(Vector2(5, 4), 0.001));
      });

       test('ignores behaviors with zero weight', () {
        manager.add(behaviorX, weight: 1.0);
        manager.add(behaviorY, weight: 0.0); // This one should be ignored
        final force = manager.calculateSteering();
        expect(force, vectorCloseTo(Vector2(5, 0), 0.001));
      });

      test('truncates total force exceeding agent.maxForce', () {
        agent.maxForce = 10.0;
        // Behavior forces: (5,0) and (0,8). Sum = (5,8). Length = sqrt(25+64) = sqrt(89) approx 9.43 (below maxForce)
        manager.add(behaviorX);
        manager.add(behaviorY);
        final force1 = manager.calculateSteering();
        expect(force1.length, closeTo(9.4339, 0.001)); // Not truncated yet

        // Add another behavior to exceed maxForce
        // (5,0) + (0,8) + (3,4) = (8, 12). Length = sqrt(64+144) = sqrt(208) approx 14.42
        manager.add(behaviorDiag);
        final force2 = manager.calculateSteering();
        expect(force2.length, closeTo(agent.maxForce, 0.001)); // Should be truncated to 10.0
        // Check direction is preserved (proportional to (8, 12))
        expect(force2.x / force2.y, closeTo(8.0 / 12.0, 0.001));
      });

       test('handles zero maxForce correctly (truncates to zero)', () {
        agent.maxForce = 0.0;
        manager.add(behaviorX); // Add some force (e.g., (5,0))
        final force = manager.calculateSteering();
        // Since maxForce is 0, the truncate step should result in a zero vector.
        expect(force, vectorCloseTo(Vector2.zero(), 0.001));
      });
    });

    group('update', () {
       final behaviorX = MockBehavior(Vector2(5, 0));
       const dt = 0.1; // Example delta time

       test('calls calculateSteering implicitly', () {
         // We can verify this by checking if the mock behavior's calculate was called
         manager.add(behaviorX);
         manager.update(dt);
         expect(behaviorX.calculateCallCount, greaterThan(0));
       });

       test('calls agent.applySteering with calculated force and dt', () {
         manager.add(behaviorX, weight: 1.5); // Calculated force should be (7.5, 0)
         manager.update(dt);

         expect(agent.lastAppliedForce, isNotNull);
         expect(agent.lastAppliedForce, vectorCloseTo(Vector2(7.5, 0), 0.001));
         expect(agent.lastDeltaTime, equals(dt));
       });

        test('calls agent.applySteering with truncated force', () {
         agent.maxForce = 5.0;
         manager.add(behaviorX, weight: 1.5); // Raw weighted force = (7.5, 0)
         manager.update(dt);

         // applySteering should receive the truncated force (length 5.0 in direction (1,0))
         expect(agent.lastAppliedForce, isNotNull);
         expect(agent.lastAppliedForce, vectorCloseTo(Vector2(5.0, 0), 0.001));
         expect(agent.lastDeltaTime, equals(dt));
       });

        test('calls agent.applySteering with zero force if no behaviors', () {
         manager.update(dt);
         expect(agent.lastAppliedForce, isNotNull);
         expect(agent.lastAppliedForce, vectorCloseTo(Vector2.zero(), 0.001));
         expect(agent.lastDeltaTime, equals(dt));
       });
    });
  });
}
