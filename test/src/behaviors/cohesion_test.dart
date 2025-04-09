import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/cohesion.dart';
import 'dart:math'; // For PI

// --- Mocks & Helpers ---

// MockAgent for testing Cohesion
class MockCohesionAgent implements Agent {
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
  final String id;

  MockCohesionAgent(this.id, {
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op
  }

   // Override equality and hashCode for Set operations in grid query
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockCohesionAgent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

   @override
  String toString() => 'MockAgent($id, $position, $velocity)';
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

// Helper to calculate expected seek force
Vector2 calculateSeekForce(Agent agent, Vector2 targetPosition) {
   final desiredVelocity = targetPosition - agent.position;
    if (desiredVelocity.length2 < 0.01 * 0.01) return Vector2.zero();
    desiredVelocity.normalize();
    desiredVelocity.scale(agent.maxSpeed);
    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
}


void main() {
  group('Cohesion Behavior', () {
    late MockCohesionAgent agent;
    late SpatialHashGrid grid;
    late Cohesion cohesionBehavior;
    const maxSpeed = 10.0;
    const neighborhoodRadius = 50.0;
    const neighborhoodRadiusSq = neighborhoodRadius * neighborhoodRadius;

    setUp(() {
      agent = MockCohesionAgent('A',
        position: Vector2.zero(),
        velocity: Vector2(maxSpeed, 0.0), // Moving right
        maxSpeed: maxSpeed,
      );
      // Grid large enough for tests
      grid = SpatialHashGrid(cellSize: neighborhoodRadius);
      grid.add(agent);

      cohesionBehavior = Cohesion(
        spatialGrid: grid,
        neighborhoodRadius: neighborhoodRadius,
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: -10.0),
            throwsA(isA<AssertionError>()));
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: neighborhoodRadius, viewAngle: -pi),
            throwsA(isA<AssertionError>()));
       // Valid construction
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: null), returnsNormally);
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: pi), returnsNormally);
       expect(() => Cohesion(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: 0.0), returnsNormally);
    });

    test('returns zero force when no neighbors are nearby', () {
      final steering = cohesionBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when neighbors are outside neighborhoodRadius', () {
      final other = MockCohesionAgent('B',
        position: Vector2(neighborhoodRadius + 1.0, 0.0), // Just outside radius
        velocity: Vector2.zero(), maxSpeed: maxSpeed);
      grid.add(other);

      final steering = cohesionBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('calculates steering towards single neighbor inside radius', () {
       final neighborPos = Vector2(neighborhoodRadius * 0.5, 0.0); // x=25
       final other = MockCohesionAgent('B',
         position: neighborPos.clone(),
         velocity: Vector2.zero(), maxSpeed: maxSpeed);
       grid.add(other);

       // Center of mass is just the neighbor's position (25, 0)
       final centerOfMass = neighborPos;
       final steering = cohesionBehavior.calculateSteering(agent);
       // Should seek the center of mass
       final expectedSeek = calculateSeekForce(agent, centerOfMass);

       expect(steering, vectorCloseTo(expectedSeek, 0.001));
     });

      test('calculates steering towards center of mass of multiple neighbors', () {
        final neighbor1Pos = Vector2(30.0, 10.0);
        final neighbor2Pos = Vector2(10.0, -20.0);
        final neighbor1 = MockCohesionAgent('N1', position: neighbor1Pos.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed);
        final neighbor2 = MockCohesionAgent('N2', position: neighbor2Pos.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed);
        grid.add(neighbor1);
        grid.add(neighbor2);

        // Center of mass = ((30+10)/2, (10-20)/2) = (20, -5)
        final centerOfMass = Vector2(20.0, -5.0);
        final steering = cohesionBehavior.calculateSteering(agent);
        final expectedSeek = calculateSeekForce(agent, centerOfMass);

        expect(steering, vectorCloseTo(expectedSeek, 0.001));
      });

       test('returns zero force if agent is already at center of mass', () {
         final neighbor1Pos = Vector2(10.0, 10.0);
         final neighbor2Pos = Vector2(-10.0, -10.0);
         final neighbor1 = MockCohesionAgent('N1', position: neighbor1Pos.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed);
         final neighbor2 = MockCohesionAgent('N2', position: neighbor2Pos.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed);
         grid.add(neighbor1);
         grid.add(neighbor2);

         // Center of mass is (0, 0), which is the agent's position
         final steering = cohesionBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
       });

      group('with viewAngle', () {
       // View angle of 90 degrees (PI/2 radians)
       const viewAngleRad = pi / 2.0;

       setUp(() {
          cohesionBehavior = Cohesion(
            spatialGrid: grid,
            neighborhoodRadius: neighborhoodRadius,
            viewAngle: viewAngleRad,
          );
          // Agent heading right (1, 0)
          agent.velocity = Vector2(maxSpeed, 0);
       });

       test('ignores neighbor directly behind', () {
         final neighborBehind = MockCohesionAgent('B',
           position: Vector2(-neighborhoodRadius * 0.5, 0.0),
           velocity: Vector2.zero(), maxSpeed: maxSpeed);
         grid.add(neighborBehind);
         final steering = cohesionBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001)); // No neighbors considered
       });

        test('ignores neighbor outside side angle', () {
          // Neighbor at 60 degrees (outside +/- 45 deg view)
          final angle = pi / 3.0; // 60 degrees
          final dist = neighborhoodRadius * 0.5;
          final neighborSide = MockCohesionAgent('S',
            position: Vector2(cos(angle) * dist, sin(angle) * dist),
            velocity: Vector2.zero(), maxSpeed: maxSpeed);
          grid.add(neighborSide);
          final steering = cohesionBehavior.calculateSteering(agent);
          expect(steering, vectorCloseTo(Vector2.zero(), 0.001)); // No neighbors considered
        });

        test('considers neighbor inside side angle', () {
           // Neighbor at 30 degrees (inside +/- 45 deg view)
          final angle = pi / 6.0; // 30 degrees
          final dist = neighborhoodRadius * 0.5; // 25
          final neighborPos = Vector2(cos(angle) * dist, sin(angle) * dist); // Approx (21.65, 12.5)
          final neighborIn = MockCohesionAgent('I',
            position: neighborPos.clone(),
            velocity: Vector2.zero(), maxSpeed: maxSpeed);
          grid.add(neighborIn);

          // Center of mass is just the neighbor's position
          final centerOfMass = neighborPos;
          final steering = cohesionBehavior.calculateSteering(agent);
          final expectedSeek = calculateSeekForce(agent, centerOfMass);

          expect(steering, vectorCloseTo(expectedSeek, 0.001));
          expect(steering.length, greaterThan(0.001));
        });

         test('considers only neighbors within view angle for center of mass', () {
           final neighborAhead = MockCohesionAgent('Ah',
             position: Vector2(neighborhoodRadius * 0.5, 0.0), // (25, 0)
             velocity: Vector2.zero(), maxSpeed: maxSpeed);
           final neighborBehind = MockCohesionAgent('B',
             position: Vector2(-neighborhoodRadius * 0.5, 0.0), // (-25, 0) - Outside view
             velocity: Vector2.zero(), maxSpeed: maxSpeed);
           grid.add(neighborAhead);
           grid.add(neighborBehind);

           // Center of mass should only consider neighborAhead -> (25, 0)
           final centerOfMass = neighborAhead.position;
           final steering = cohesionBehavior.calculateSteering(agent);
           final expectedSeek = calculateSeekForce(agent, centerOfMass);

           expect(steering, vectorCloseTo(expectedSeek, 0.001));
         });
     });

  });
}
