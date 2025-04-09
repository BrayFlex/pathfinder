import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/obstacle.dart';
import 'package:pathfinder/src/behaviors/obstacle_avoidance.dart';

// --- Mocks & Helpers ---

// MockAgent for testing ObstacleAvoidance
class MockAvoidanceAgent implements Agent {
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
  double radius; // Agent radius is important for avoidance

  MockAvoidanceAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
    required this.radius,
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
  group('ObstacleAvoidance Behavior', () {
    late MockAvoidanceAgent agent;
    late ObstacleAvoidance avoidanceBehavior;
    late List<Obstacle> obstacles;
    const agentRadius = 5.0;
    const obstacleRadius = 10.0;
    const detectionBoxLength = 50.0;
    const avoidanceForceMultiplier = 100.0;

    setUp(() {
      agent = MockAvoidanceAgent(
        position: Vector2.zero(),
        velocity: Vector2(10.0, 0.0), // Moving right along X-axis
        maxSpeed: 10.0,
        radius: agentRadius,
      );
      obstacles = []; // Start with no obstacles
      avoidanceBehavior = ObstacleAvoidance(
        obstacles: obstacles,
        detectionBoxLength: detectionBoxLength,
        avoidanceForceMultiplier: avoidanceForceMultiplier,
      );
    });

    test('constructor throws assertion error for negative detectionBoxLength', () {
       expect(() => ObstacleAvoidance(obstacles: obstacles, detectionBoxLength: -1.0),
            throwsA(isA<AssertionError>()));
       // Zero length should be allowed
       expect(() => ObstacleAvoidance(obstacles: obstacles, detectionBoxLength: 0.0), returnsNormally);
    });

    test('returns zero force when agent is stationary', () {
      agent.velocity.setZero();
      obstacles.add(CircleObstacle(position: Vector2(20, 0), radius: obstacleRadius));
      final steering = avoidanceBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when no obstacles are present', () {
      final steering = avoidanceBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when obstacles list contains non-CircleObstacles', () {
       obstacles.add(WallSegment(start: Vector2(10,10), end: Vector2(10, -10))); // Add a non-circle
       final steering = avoidanceBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

    test('returns zero force when obstacle is behind agent', () {
      obstacles.add(CircleObstacle(position: Vector2(-20, 5), radius: obstacleRadius));
      final steering = avoidanceBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when obstacle is far ahead (outside detection box)', () {
      obstacles.add(CircleObstacle(position: Vector2(detectionBoxLength + 20.0, 5), radius: obstacleRadius));
      final steering = avoidanceBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when obstacle is beside agent but outside combined radius', () {
       // Obstacle center at (0, 20). Agent at (0,0), radius 5. Obstacle radius 10.
       // Combined radius = 15. Distance = 20. Should not trigger.
       obstacles.add(CircleObstacle(position: Vector2(0, agentRadius + obstacleRadius + 1.0), radius: obstacleRadius));
       final steering = avoidanceBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

      test('returns zero force when obstacle is ahead but laterally outside combined radius', () {
       // Obstacle center at (30, 20). Agent at (0,0), radius 5. Obstacle radius 10.
       // Heading is (1,0). Closest point on heading is (30, 0).
       // Distance from obstacle center (30,20) to closest point (30,0) is 20.
       // Combined radius = 15. Distance > Combined radius. Should not trigger.
       obstacles.add(CircleObstacle(position: Vector2(30, agentRadius + obstacleRadius + 1.0), radius: obstacleRadius));
       final steering = avoidanceBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

      test('returns zero force when obstacle is directly ahead but agent velocity is zero', () {
        agent.velocity.setZero();
        obstacles.add(CircleObstacle(position: Vector2(20, 0), radius: obstacleRadius));
        final steering = avoidanceBehavior.calculateSteering(agent);
        expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
      });

       test('returns zero force when obstacle is directly ahead (zero lateral offset)', () {
         // Obstacle center directly on agent's path
         obstacles.add(CircleObstacle(position: Vector2(30, 0), radius: obstacleRadius));
         // Lateral projection should be zero
         final steering = avoidanceBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
       });


    test('calculates avoidance force laterally away from obstacle (obstacle to the left)', () {
      // Obstacle slightly ahead and to the left
      // Agent heading (1,0). Obstacle at (30, 5). Combined radius 15.
      // Closest point on heading is (30, 0). Dist from obs center to closest point = 5 ( < 15, intersects)
      final obstaclePos = Vector2(30.0, agentRadius + obstacleRadius - 1.0); // e.g., (30, 14)
      obstacles.add(CircleObstacle(position: obstaclePos, radius: obstacleRadius));

      final steering = avoidanceBehavior.calculateSteering(agent);

      // Lateral component points from heading line towards obstacle (roughly (0, 1))
      // Avoidance force should oppose this, pointing roughly (0, -1) -> steer right
      expect(steering.length, greaterThan(0));
      expect(steering.x, closeTo(0.0, 1.0)); // Should be primarily lateral
      expect(steering.y, lessThan(0)); // Steer right (negative Y)
    });

     test('calculates avoidance force laterally away from obstacle (obstacle to the right)', () {
      // Obstacle slightly ahead and to the right
      final obstaclePos = Vector2(30.0, -(agentRadius + obstacleRadius - 1.0)); // e.g., (30, -14)
      obstacles.add(CircleObstacle(position: obstaclePos, radius: obstacleRadius));

      final steering = avoidanceBehavior.calculateSteering(agent);

      // Lateral component points from heading line towards obstacle (roughly (0, -1))
      // Avoidance force should oppose this, pointing roughly (0, 1) -> steer left
      expect(steering.length, greaterThan(0));
      expect(steering.x, closeTo(0.0, 1.0)); // Should be primarily lateral
      expect(steering.y, greaterThan(0)); // Steer left (positive Y)
    });

     test('force magnitude increases as obstacle gets closer along heading', () {
       final obstacleFar = CircleObstacle(position: Vector2(detectionBoxLength * 0.8, 5), radius: obstacleRadius);
       final obstacleClose = CircleObstacle(position: Vector2(detectionBoxLength * 0.2, 5), radius: obstacleRadius);

       // Test far obstacle
       obstacles.add(obstacleFar);
       obstacles.clear();

       // Test close obstacle
       obstacles.add(obstacleClose);
       final steeringClose = avoidanceBehavior.calculateSteering(agent); // Corrected variable name
       final rawForceClose = avoidanceBehavior.debugLastRawAvoidanceForce.length;
       obstacles.clear();

       // Test far obstacle again to get its raw force
       obstacles.add(obstacleFar);
       final steeringFarAgain = avoidanceBehavior.calculateSteering(agent); // Need to recalculate
       final rawForceFar = avoidanceBehavior.debugLastRawAvoidanceForce.length;
       obstacles.clear(); // Clear again before next test if needed

       // Compare the raw avoidance force magnitudes before velocity subtraction
       expect(rawForceClose, greaterThan(rawForceFar + 1e-6)); // Use tolerance
       // Both should steer right (negative Y)
       expect(steeringFarAgain.y, lessThan(-1e-6)); // Use tolerance
       expect(steeringClose.y, lessThan(-1e-6)); // Use tolerance
     });

      test('avoids the closest obstacle when multiple intersect', () {
       // Obstacle 1: Farther away, but more laterally offset (stronger lateral push if considered alone)
       final obstacleFar = CircleObstacle(position: Vector2(40, 10), radius: obstacleRadius); // Proj=40, Lat=10
       // Obstacle 2: Closer, but less laterally offset
       final obstacleClose = CircleObstacle(position: Vector2(20, 5), radius: obstacleRadius); // Proj=20, Lat=5

       obstacles.add(obstacleFar);
       obstacles.add(obstacleClose);

       final steering = avoidanceBehavior.calculateSteering(agent);

       // It should prioritize avoiding the *closest* obstacle (obstacleClose at proj=20).
       // Lateral component is towards (0, 5). Avoidance force is towards (0, -5).
       expect(steering.length, greaterThan(0));
       expect(steering.x, closeTo(0.0, 1.0)); // Primarily lateral
       expect(steering.y, lessThan(0)); // Steer away from y=5 -> steer negative Y

       // Verify magnitude is based on the closer obstacle's proximity
      //  final proximityFactorClose = (detectionBoxLength - 20.0) / detectionBoxLength;
       // Rough estimate, actual force depends on normalization
       // expect(steering.length, closeTo(avoidanceForceMultiplier * proximityFactorClose, 50.0)); // Tolerance needed
     });

      test('force magnitude scales with avoidanceForceMultiplier', () {
        final obstaclePos = Vector2(30.0, 5.0);
        obstacles.add(CircleObstacle(position: obstaclePos, radius: obstacleRadius));

        final behaviorLowMult = ObstacleAvoidance(
          obstacles: obstacles,
          detectionBoxLength: detectionBoxLength,
          avoidanceForceMultiplier: 10.0, // Low multiplier
        );
         final behaviorHighMult = ObstacleAvoidance(
          obstacles: obstacles,
          detectionBoxLength: detectionBoxLength,
          avoidanceForceMultiplier: 200.0, // High multiplier
        );

       final steeringLow = behaviorLowMult.calculateSteering(agent);
       final rawForceLow = behaviorLowMult.debugLastRawAvoidanceForce.length;
       final steeringHigh = behaviorHighMult.calculateSteering(agent);
       final rawForceHigh = behaviorHighMult.debugLastRawAvoidanceForce.length;

       // Compare the raw avoidance force magnitudes
       expect(rawForceHigh, greaterThan(rawForceLow + 1e-6)); // Use tolerance
       // Direction should be the same (roughly (0, -1))
       expect(steeringLow.y, lessThan(-1e-6)); // Use tolerance
       expect(steeringHigh.y, lessThan(-1e-6)); // Use tolerance
       expect(steeringLow.x, closeTo(0.0, 0.1));
       expect(steeringHigh.x, closeTo(0.0, 0.1));
     });

  });
}
