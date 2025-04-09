import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/alignment.dart';
import 'dart:math'; // For PI

// --- Mocks & Helpers ---

// MockAgent for testing Alignment
class MockAlignmentAgent implements Agent {
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

  MockAlignmentAgent(this.id, {
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
      other is MockAlignmentAgent && runtimeType == other.runtimeType && id == other.id;

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

void main() {
  group('Alignment Behavior', () {
    late MockAlignmentAgent agent;
    late SpatialHashGrid grid;
    late Alignment alignmentBehavior;
    const maxSpeed = 10.0;
    const neighborhoodRadius = 50.0;

    setUp(() {
      agent = MockAlignmentAgent('A',
        position: Vector2.zero(),
        velocity: Vector2(0.0, maxSpeed), // Moving up initially
        maxSpeed: maxSpeed,
      );
      // Grid large enough for tests
      grid = SpatialHashGrid(cellSize: neighborhoodRadius);
      grid.add(agent);

      alignmentBehavior = Alignment(
        spatialGrid: grid,
        neighborhoodRadius: neighborhoodRadius,
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: -10.0),
            throwsA(isA<AssertionError>()));
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: neighborhoodRadius, viewAngle: -pi),
            throwsA(isA<AssertionError>()));
       // Valid construction
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: null), returnsNormally);
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: pi), returnsNormally);
       expect(() => Alignment(spatialGrid: grid, neighborhoodRadius: 1.0, viewAngle: 0.0), returnsNormally);
    });

    test('returns zero force when no neighbors are nearby', () {
      final steering = alignmentBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when neighbors are outside neighborhoodRadius', () {
      final other = MockAlignmentAgent('B',
        position: Vector2(neighborhoodRadius + 1.0, 0.0), // Just outside radius
        velocity: Vector2(maxSpeed, 0), maxSpeed: maxSpeed); // Moving
      grid.add(other);

      final steering = alignmentBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when neighbors are stationary', () {
       final other = MockAlignmentAgent('B',
         position: Vector2(neighborhoodRadius * 0.5, 0.0), // Inside radius
         velocity: Vector2.zero(), // Stationary
         maxSpeed: maxSpeed);
       grid.add(other);

       final steering = alignmentBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
     });

    test('calculates steering towards single moving neighbor\'s velocity', () {
      final neighborVel = Vector2(maxSpeed, maxSpeed).normalized() * maxSpeed; // Moving diagonally up-right
      final other = MockAlignmentAgent('B',
        position: Vector2(neighborhoodRadius * 0.5, 0.0), // Inside radius
        velocity: neighborVel.clone(),
        maxSpeed: maxSpeed);
      grid.add(other);

      // Average velocity is just the neighbor's velocity
      final averageVelocity = neighborVel;
      // Desired velocity = average.normalized * agent.maxSpeed
      final desiredVelocity = averageVelocity.normalized() * agent.maxSpeed;
      // Steering = Desired - Current = desired - (0, 10)
      final expectedSteering = desiredVelocity - agent.velocity;

      final steering = alignmentBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(expectedSteering, 0.001));
    });

     test('calculates steering towards average velocity of multiple neighbors', () {
       final velRight = Vector2(maxSpeed, 0);
       final velUp = Vector2(0, maxSpeed);
       final neighbor1 = MockAlignmentAgent('N1',
         position: Vector2(10, 0), velocity: velRight.clone(), maxSpeed: maxSpeed);
       final neighbor2 = MockAlignmentAgent('N2',
         position: Vector2(0, 10), velocity: velUp.clone(), maxSpeed: maxSpeed);
       grid.add(neighbor1);
       grid.add(neighbor2);

       // Average velocity = ((10,0) + (0,10)) / 2 = (5, 5)
       final averageVelocity = Vector2(5.0, 5.0);
       // Desired velocity = (5,5).normalized * agent.maxSpeed
       final desiredVelocity = averageVelocity.normalized() * agent.maxSpeed;
       // Steering = Desired - Current = desired - (0, 10)
       final expectedSteering = desiredVelocity - agent.velocity;

       final steering = alignmentBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(expectedSteering, 0.001));
     });

      test('returns zero force if average velocity is zero (e.g., opposite directions)', () {
        final velRight = Vector2(maxSpeed, 0);
        final velLeft = Vector2(-maxSpeed, 0);
        final neighbor1 = MockAlignmentAgent('N1',
          position: Vector2(10, 0), velocity: velRight.clone(), maxSpeed: maxSpeed);
        final neighbor2 = MockAlignmentAgent('N2',
          position: Vector2(-10, 0), velocity: velLeft.clone(), maxSpeed: maxSpeed);
        grid.add(neighbor1);
        grid.add(neighbor2);

        // Average velocity = ((10,0) + (-10,0)) / 2 = (0, 0)
        final steering = alignmentBehavior.calculateSteering(agent);
        expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
      });

     group('with viewAngle', () {
       // View angle of 90 degrees (PI/2 radians)
       const viewAngleRad = pi / 2.0;

       setUp(() {
          alignmentBehavior = Alignment(
            spatialGrid: grid,
            neighborhoodRadius: neighborhoodRadius,
            viewAngle: viewAngleRad,
          );
          // Agent heading up (0, 1)
          agent.velocity = Vector2(0, maxSpeed);
       });

       test('ignores neighbor directly behind', () {
         final neighborBehind = MockAlignmentAgent('B',
           position: Vector2(0, -neighborhoodRadius * 0.5), // Behind agent
           velocity: Vector2(maxSpeed, 0), // Moving right
           maxSpeed: maxSpeed);
         grid.add(neighborBehind);
         final steering = alignmentBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001)); // No neighbors considered
       });

        test('ignores neighbor outside side angle', () {
          // Neighbor at 60 degrees left (outside +/- 45 deg view relative to agent's UP heading)
          final angle = pi * 2 / 3.0; // 120 degrees from positive X-axis -> (-0.5, 0.866) direction
          final dist = neighborhoodRadius * 0.5;
          final neighborSide = MockAlignmentAgent('S',
            position: Vector2(cos(angle) * dist, sin(angle) * dist),
            velocity: Vector2(0, maxSpeed), // Moving up
            maxSpeed: maxSpeed);
          grid.add(neighborSide);
          final steering = alignmentBehavior.calculateSteering(agent);
          expect(steering, vectorCloseTo(Vector2.zero(), 0.001)); // No neighbors considered
        });

        test('considers neighbor inside side angle', () {
           // Neighbor at 30 degrees right (inside +/- 45 deg view relative to agent's UP heading)
           // Angle = 60 deg from positive X -> direction (0.5, 0.866)
          final angle = pi / 3.0;
          final dist = neighborhoodRadius * 0.5;
          final neighborPos = Vector2(cos(angle) * dist, sin(angle) * dist);
          final neighborVel = Vector2(maxSpeed, 0); // Neighbor moving right
          final neighborIn = MockAlignmentAgent('I',
            position: neighborPos.clone(),
            velocity: neighborVel.clone(),
            maxSpeed: maxSpeed);
          grid.add(neighborIn);

          // Average velocity is just neighbor's velocity (10, 0)
          final averageVelocity = neighborVel;
          // Desired velocity = (10,0).normalized * agent.maxSpeed = (1,0) * 10 = (10,0)
          final desiredVelocity = averageVelocity.normalized() * agent.maxSpeed;
          // Steering = Desired - Current = (10, 0) - (0, 10) = (10, -10)
          final expectedSteering = desiredVelocity - agent.velocity;

          final steering = alignmentBehavior.calculateSteering(agent);
          expect(steering, vectorCloseTo(expectedSteering, 0.001));
        });

         test('considers only neighbors within view angle for average velocity', () {
           final neighborAhead = MockAlignmentAgent('Ah',
             position: Vector2(0, neighborhoodRadius * 0.5), // Directly ahead (y=25)
             velocity: Vector2(0, maxSpeed), // Moving up
             maxSpeed: maxSpeed);
           final neighborBehind = MockAlignmentAgent('B',
             position: Vector2(0, -neighborhoodRadius * 0.5), // Directly behind (y=-25) - Outside view
             velocity: Vector2(0, -maxSpeed), // Moving down
             maxSpeed: maxSpeed);
           grid.add(neighborAhead);
           grid.add(neighborBehind);

           // Average velocity should only consider neighborAhead -> (0, 10)
           final averageVelocity = neighborAhead.velocity;
           // Desired velocity = (0, 10).normalized * agent.maxSpeed = (0, 1) * 10 = (0, 10)
           final desiredVelocity = averageVelocity.normalized() * agent.maxSpeed;
           // Steering = Desired - Current = (0, 10) - (0, 10) = (0, 0)
           final expectedSteering = desiredVelocity - agent.velocity;

           final steering = alignmentBehavior.calculateSteering(agent);
           expect(steering, vectorCloseTo(expectedSteering, 0.001));
           expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
         });
     });

  });
}
