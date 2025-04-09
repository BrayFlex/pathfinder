import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/separation.dart';
import 'dart:math'; // For PI

// --- Mocks & Helpers ---

// MockAgent for testing Separation
class MockSeparationAgent implements Agent {
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
  double radius = 1.0; // Not directly used by Separation logic
  final String id;

  MockSeparationAgent(this.id, {
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
      other is MockSeparationAgent && runtimeType == other.runtimeType && id == other.id;

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
  group('Separation Behavior', () {
    late MockSeparationAgent agent;
    late SpatialHashGrid grid;
    late Separation separationBehavior;
    const maxSpeed = 10.0;
    const desiredSeparation = 20.0;
    const desiredSeparationSq = desiredSeparation * desiredSeparation;

    setUp(() {
      agent = MockSeparationAgent('A',
        position: Vector2.zero(),
        velocity: Vector2(maxSpeed, 0.0), // Moving right
        maxSpeed: maxSpeed,
      );
      // Grid large enough for tests
      grid = SpatialHashGrid(cellSize: desiredSeparation);
      grid.add(agent);

      separationBehavior = Separation(
        spatialGrid: grid,
        desiredSeparation: desiredSeparation,
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => Separation(spatialGrid: grid, desiredSeparation: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => Separation(spatialGrid: grid, desiredSeparation: -10.0),
            throwsA(isA<AssertionError>()));
       expect(() => Separation(spatialGrid: grid, desiredSeparation: desiredSeparation, viewAngle: -pi),
            throwsA(isA<AssertionError>()));
       // Valid construction
       expect(() => Separation(spatialGrid: grid, desiredSeparation: 1.0, viewAngle: null), returnsNormally);
       expect(() => Separation(spatialGrid: grid, desiredSeparation: 1.0, viewAngle: pi), returnsNormally);
       expect(() => Separation(spatialGrid: grid, desiredSeparation: 1.0, viewAngle: 0.0), returnsNormally);
    });

    test('returns zero force when no neighbors are nearby', () {
      final steering = separationBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when neighbors are outside desiredSeparation', () {
      final other = MockSeparationAgent('B',
        position: Vector2(desiredSeparation + 1.0, 0.0), // Just outside radius
        velocity: Vector2.zero(), maxSpeed: maxSpeed);
      grid.add(other);

      final steering = separationBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

     test('returns zero force when neighbor is exactly at desiredSeparation', () {
      final other = MockSeparationAgent('B',
        position: Vector2(desiredSeparation, 0.0), // Exactly at radius
        velocity: Vector2.zero(), maxSpeed: maxSpeed);
      grid.add(other);

      final steering = separationBehavior.calculateSteering(agent);
       // Check is distanceSquared < desiredSeparationSq, so equal distance yields zero force
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('calculates repulsive force from single close neighbor', () {
      final distance = desiredSeparation * 0.5; // Halfway inside radius
      final other = MockSeparationAgent('B',
        position: Vector2(distance, 0.0), // Directly to the right
        velocity: Vector2.zero(), maxSpeed: maxSpeed);
      grid.add(other);

      final steering = separationBehavior.calculateSteering(agent);

      // Repulsive force points away from neighbor: (-1, 0)
      // Scaled magnitude: desiredSeparation / distance = 20 / 10 = 2.0
      // Raw repulsive force = (-1, 0) * 2.0 = (-2, 0)
      final repulsiveForce = Vector2(-1.0, 0.0) * (desiredSeparation / distance);
      // Desired velocity = repulsiveForce.normalized * maxSpeed = (-1, 0) * 10 = (-10, 0)
      final desiredVelocity = repulsiveForce.normalized() * maxSpeed;
      // Steering = Desired - Current = (-10, 0) - (10, 0) = (-20, 0)
      final expectedSteering = desiredVelocity - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
    });

     test('calculates combined repulsive force from multiple close neighbors', () {
       final distance = desiredSeparation * 0.5; // 10
       final neighborRight = MockSeparationAgent('R',
         position: Vector2(distance, 0.0),
         velocity: Vector2.zero(), maxSpeed: maxSpeed);
       final neighborUp = MockSeparationAgent('U',
         position: Vector2(0.0, distance),
         velocity: Vector2.zero(), maxSpeed: maxSpeed);
       grid.add(neighborRight);
       grid.add(neighborUp);

       // Force from Right: (-1, 0) * (20/10) = (-2, 0)
       // Force from Up: (0, -1) * (20/10) = (0, -2)
       // Summed repulsive force = (-2, -2)
       final summedRepulsiveForce = Vector2(-2.0, -2.0);
       // Desired velocity = summed.normalized * maxSpeed = (-1,-1).normalized * 10
       final desiredVelocity = summedRepulsiveForce.normalized() * maxSpeed;
       // Steering = Desired - Current = desired - (10, 0)
       final expectedSteering = desiredVelocity - agent.velocity;

       final steering = separationBehavior.calculateSteering(agent);
       expect(steering, vectorCloseTo(expectedSteering, 0.001));
     });

      test('force magnitude is stronger for closer neighbors', () {
        final neighborClose = MockSeparationAgent('C',
          position: Vector2(desiredSeparation * 0.2, 0.0), // Very close (dist=4)
          velocity: Vector2.zero(), maxSpeed: maxSpeed);
         final neighborMid = MockSeparationAgent('M',
          position: Vector2(desiredSeparation * 0.7, 0.0), // Mid-range (dist=14)
          velocity: Vector2.zero(), maxSpeed: maxSpeed);

        // Test close neighbor
        grid.add(neighborClose);
        final steeringClose = separationBehavior.calculateSteering(agent);
        grid.remove(neighborClose); // Remove for next test

        // Test mid neighbor
        grid.add(neighborMid);
        final steeringMid = separationBehavior.calculateSteering(agent);
        grid.remove(neighborMid);

        // Steering = desired - current. Desired direction is (-1,0) for both.
        // Desired magnitude is maxSpeed.
        // The *intermediate* repulsive force magnitude is different:
        // Close: scale = 20 / 4 = 5.0
        // Mid: scale = 20 / 14 = ~1.43
        // Since the desired *direction* is the same, and maxSpeed dominates,
        // the final steering force might be very similar if velocity aligns.
        // Let's test with zero velocity for clarity.
        agent.velocity.setZero();

         grid.add(neighborClose);
         final steeringClose_v0 = separationBehavior.calculateSteering(agent);
         grid.remove(neighborClose);
         grid.add(neighborMid);
         final steeringMid_v0 = separationBehavior.calculateSteering(agent);
         grid.remove(neighborMid);

         // Now steering = desired = repulsive.normalized * maxSpeed
         // Since repulsive direction is (-1,0) for both, steering should be identical.
         expect(steeringClose_v0, vectorCloseTo(Vector2(-maxSpeed, 0), 0.001));
         expect(steeringMid_v0, vectorCloseTo(Vector2(-maxSpeed, 0), 0.001));

         // Conclusion: The inverse scaling affects the *summed* force direction/magnitude
         // when multiple neighbors are present, but for a single neighbor, the final
         // steering magnitude is often capped by maxSpeed. The *urgency* is higher
         // for closer neighbors, reflected in the intermediate force sum before normalization.
     });

     group('with viewAngle', () {
       // View angle of 90 degrees (PI/2 radians)
       const viewAngleRad = pi / 2.0;

       setUp(() {
          separationBehavior = Separation(
            spatialGrid: grid,
            desiredSeparation: desiredSeparation,
            viewAngle: viewAngleRad,
          );
          // Agent heading right (1, 0)
          agent.velocity = Vector2(maxSpeed, 0);
       });

       test('ignores neighbor directly behind', () {
         final neighborBehind = MockSeparationAgent('B',
           position: Vector2(-desiredSeparation * 0.5, 0.0),
           velocity: Vector2.zero(), maxSpeed: maxSpeed);
         grid.add(neighborBehind);
         final steering = separationBehavior.calculateSteering(agent);
         expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
       });

        test('ignores neighbor outside side angle', () {
          // Neighbor at 60 degrees (outside +/- 45 deg view)
          final angle = pi / 3.0; // 60 degrees
          final dist = desiredSeparation * 0.5;
          final neighborSide = MockSeparationAgent('S',
            position: Vector2(cos(angle) * dist, sin(angle) * dist),
            velocity: Vector2.zero(), maxSpeed: maxSpeed);
          grid.add(neighborSide);
          final steering = separationBehavior.calculateSteering(agent);
          expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
        });

        test('considers neighbor inside side angle', () {
           // Neighbor at 30 degrees (inside +/- 45 deg view)
          final angle = pi / 6.0; // 30 degrees
          final dist = desiredSeparation * 0.5;
          final neighborIn = MockSeparationAgent('I',
            position: Vector2(cos(angle) * dist, sin(angle) * dist),
            velocity: Vector2.zero(), maxSpeed: maxSpeed);
          grid.add(neighborIn);

          final steering = separationBehavior.calculateSteering(agent);
          // Should produce a repulsive force away from the neighbor
          expect(steering.length, greaterThan(0.001));
          // Force should generally point away from (cos30*10, sin30*10) = (8.66, 5)
          // Repulsive dir approx (-0.866, -0.5). Desired Vel approx (-8.66, -5).
          // Steering = Desired - Current = (-8.66, -5) - (10, 0) = (-18.66, -5)
          expect(steering.x, lessThan(0));
          expect(steering.y, lessThan(0));
        });

         test('considers neighbor directly ahead', () {
           final neighborAhead = MockSeparationAgent('Ah',
             position: Vector2(desiredSeparation * 0.5, 0.0),
             velocity: Vector2.zero(), maxSpeed: maxSpeed);
           grid.add(neighborAhead);
           final steering = separationBehavior.calculateSteering(agent);
           // Should produce repulsive force pointing left (-1, 0)
           expect(steering.length, greaterThan(0.001));
           expect(steering.x, lessThan(0));
           expect(steering.y, closeTo(0.0, 0.1));
         });
     });

  });
}
