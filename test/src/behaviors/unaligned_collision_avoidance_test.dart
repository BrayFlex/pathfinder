import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/unaligned_collision_avoidance.dart';

// --- Mocks & Helpers ---

// MockAgent for testing UnalignedCollisionAvoidance
class MockCollisionAgent implements Agent {
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
  double radius;
  final String id; // For easy identification

  MockCollisionAgent(this.id, {
    required this.position,
    required this.velocity,
    required this.maxSpeed,
    required this.radius,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op
  }

   // Override equality and hashCode for Set operations in grid query
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockCollisionAgent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MockAgent($id, $position, $velocity)';
}

// Helper for vector comparison with tolerance
Matcher vectorCloseTo(Vector2 expected, double tolerance) {
  return predicate((v) {
    if (v is! Vector2) return false;
    if (expected.isNaN || v.isNaN) return false; // Handle NaN comparison
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

void main() {
  group('UnalignedCollisionAvoidance Behavior', () {
    late MockCollisionAgent agent;
    late SpatialHashGrid grid;
    late UnalignedCollisionAvoidance avoidanceBehavior;
    const agentRadius = 5.0;
    const otherRadius = 5.0;
    const combinedRadius = agentRadius + otherRadius; // 10.0
    const combinedRadiusSq = combinedRadius * combinedRadius; // 100.0
    const maxSpeed = 10.0;
    const maxPredictionTime = 2.0;
    const avoidanceForceMultiplier = 100.0;

    setUp(() {
      agent = MockCollisionAgent('A',
        position: Vector2.zero(),
        velocity: Vector2(maxSpeed, 0.0), // Moving right
        maxSpeed: maxSpeed,
        radius: agentRadius,
      );
      // Grid covering a reasonable area around the agent
      grid = SpatialHashGrid(cellSize: combinedRadius * 4); // Increased cell size
      grid.add(agent); // Add self to grid

      avoidanceBehavior = UnalignedCollisionAvoidance(
        spatialGrid: grid,
        maxPredictionTime: maxPredictionTime,
        avoidanceForceMultiplier: avoidanceForceMultiplier,
      );
    });

     test('constructor throws assertion error for negative maxPredictionTime', () {
       expect(() => UnalignedCollisionAvoidance(spatialGrid: grid, maxPredictionTime: -1.0),
            throwsA(isA<AssertionError>()));
       // Zero should be allowed
       expect(() => UnalignedCollisionAvoidance(spatialGrid: grid, maxPredictionTime: 0.0), returnsNormally);
    });

    test('returns zero force when no other agents are nearby', () {
      final steering = avoidanceBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when nearby agent is moving parallel (no collision)', () {
      final other = MockCollisionAgent('B',
        position: Vector2(0.0, 50.0), // Above agent
        velocity: Vector2(maxSpeed, 0.0), // Moving parallel right
        maxSpeed: maxSpeed,
        radius: otherRadius,
      );
      grid.add(other);

      final steering = avoidanceBehavior.calculateSteering(agent);
      // Relative velocity is zero, timeToClosest is undefined/infinite or negative dot product
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when nearby agent is moving directly away', () {
      final other = MockCollisionAgent('B',
        position: Vector2(50.0, 0.0), // Ahead of agent
        velocity: Vector2(maxSpeed * 1.5, 0.0), // Moving right faster
        maxSpeed: maxSpeed * 1.5,
        radius: otherRadius,
      );
      grid.add(other);

      final steering = avoidanceBehavior.calculateSteering(agent);
      // Relative velocity points away, dot product with relative position is positive, timeToClosest is negative.
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when CPA is too far in the future', () {
       // Agents far apart, moving slowly towards each other
       agent.position = Vector2(-1000, 0);
       agent.velocity = Vector2(1, 0);
       final other = MockCollisionAgent('B',
         position: Vector2(1000, 0),
         velocity: Vector2(-1, 0),
         maxSpeed: 1.0,
         radius: otherRadius,
       );
       grid.clear(); grid.add(agent); grid.add(other); // Update grid
       // Relative position (2000, 0), Relative velocity (-2, 0)
       // timeToClosest = - (2000 * -2) / 4 = 4000 / 4 = 1000 seconds
       // This is > maxPredictionTime (2.0)

       final steering = avoidanceBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

      test('returns zero force when separation at CPA is greater than combined radii', () {
        // Head-on collision course, but will pass safely beside each other
        agent.position = Vector2(0, combinedRadius * 0.6); // y = 6
        agent.velocity = Vector2(50, 0); // Faster speed for quicker CPA
        final other = MockCollisionAgent('B',
          position: Vector2(50, -combinedRadius * 0.6), // y = -6
          velocity: Vector2(-50, 0), // Move left
          maxSpeed: 50.0,
          radius: otherRadius,
        );
        grid.clear(); grid.add(agent); grid.add(other); // Update grid
        // Relative position = (50, -12)
        // Relative velocity = (-100, 0), speedSq = 10000
        // timeToClosest = - ((50 * -100) + (-12 * 0)) / 10000 = 5000 / 10000 = 0.5 (within maxPredictionTime)
        // Separation at CPA = (50, -12) + (-100, 0) * 0.5 = (0, -12)
        // Separation distance sq = 144. Combined radius sq = 100.
        // Since 144 > 100, they pass safely.

        final steering = avoidanceBehavior.calculateSteering(agent);
        expect(steering, vectorCloseTo(Vector2.zero(), 0.001)); // No collision predicted
      });

    test('calculates avoidance force for imminent head-on collision', () {
      // Head-on collision course, will collide
      agent.position = Vector2(0, 0.1); // Slightly offset
      agent.velocity = Vector2(maxSpeed, 0); // Agent moving right
      final other = MockCollisionAgent('B',
        position: Vector2(maxSpeed * maxPredictionTime * 0.8, -0.1), // Closer, ensures CPA < maxPredictionTime
        velocity: Vector2(-maxSpeed, 0), // Other moving left
        maxSpeed: maxSpeed,
        radius: otherRadius,
      );
      grid.clear(); grid.add(agent); grid.add(other); // Update grid
      // RelPos = (16, -0.2), RelVel = (-20, 0), RelSpeedSq = 400
      // timeToClosest = - (16*-20 + -0.2*0) / 400 = 320 / 400 = 0.8s (clearly < 2.0)
      // Sep@CPA = (16, -0.2) + (-20, 0)*0.8 = (16-16, -0.2) = (0, -0.2) -> Collision!

      final steering = avoidanceBehavior.calculateSteering(agent);
      // Avoidance direction is opposite to separation at CPA (0, -0.2) -> (0, 0.2) -> normalized (0, 1)
      expect(steering.length, greaterThan(1e-6)); // Use epsilon
      // Should push the agent upwards (positive Y)
      expect(steering.y, greaterThan(1e-6));
    });

     test('prioritizes most imminent threat', () {
       // Threat 1: Farther away, but faster collision time (T ~ 0.91s)
       final threat1 = MockCollisionAgent('T1',
         position: Vector2(100, 0.1), // Slightly offset
         velocity: Vector2(-100, 0), // Very fast towards agent
         maxSpeed: 100.0, radius: otherRadius);
       // T = ~0.909s -> Collision! Sep@CPA = (0, 0.1)

       // Threat 2: Closer, but slower collision time (T = 1.5s)
       final threat2 = MockCollisionAgent('T2',
         position: Vector2(30, 5), // Slightly offset
         velocity: Vector2(-10, 0), // Slower towards agent
         maxSpeed: 10.0, radius: otherRadius);
       // T = 1.5s -> Collision (Sep@CPA = (0, 5))

       grid.add(threat1);
       grid.add(threat2);

       final steering = avoidanceBehavior.calculateSteering(agent);

       // Should react to Threat 1 (T=0.91s) as it's more imminent.
       // Avoidance for Threat 1 (CPA Sep approx (0, 0.1)): Should push downwards (negative Y)
       expect(steering.length, greaterThan(1e-6)); // Use epsilon
       // It should push the agent off the head-on course with Threat 1.
       expect(steering.y, lessThan(-1e-6)); // Should have negative Y component
     });

     test('returns zero force when relative velocity is near zero', () {
       // Place another agent very close, moving at almost the same velocity
       final other = MockCollisionAgent('B',
         position: Vector2(agentRadius + otherRadius - 1.0, 0.0), // Very close
         velocity: agent.velocity + Vector2(0.000001, 0.0), // Almost identical velocity
         maxSpeed: maxSpeed,
         radius: otherRadius,
       );
       grid.add(other);

       // Relative velocity is extremely small (0.000001, 0)
       final steering = avoidanceBehavior.calculateSteering(agent);

       // The relative velocity squared should be less than the threshold,
       // triggering the fallback which returns zero force.
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

  });
}
