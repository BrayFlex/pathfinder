import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/separation.dart';
import 'package:pathfinder/src/behaviors/cohesion.dart';
import 'package:pathfinder/src/behaviors/alignment.dart';
import 'package:pathfinder/src/behaviors/flocking.dart';
import 'dart:math'; // For PI

// --- Mocks & Helpers ---

// MockAgent for testing Flocking
class MockFlockingAgent implements Agent {
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

  MockFlockingAgent(this.id, {
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
      other is MockFlockingAgent && runtimeType == other.runtimeType && id == other.id;

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
  group('Flocking Behavior', () {
    late MockFlockingAgent agent;
    late SpatialHashGrid grid;
    late Flocking flockingBehavior;
    const maxSpeed = 10.0;
    // Define radii for sub-behaviors
    const separationDist = 15.0;
    const cohesionRadius = 40.0;
    const alignmentRadius = 30.0;
    // Define weights
    const separationWeight = 1.5;
    const cohesionWeight = 1.0;
    const alignmentWeight = 0.8;

    setUp(() {
      agent = MockFlockingAgent('A',
        position: Vector2.zero(),
        velocity: Vector2(maxSpeed, 0.0), // Moving right
        maxSpeed: maxSpeed,
      );
      // Grid large enough for tests
      grid = SpatialHashGrid(cellSize: cohesionRadius); // Use largest radius for grid cell size
      grid.add(agent);

      flockingBehavior = Flocking(
        spatialGrid: grid,
        separationDistance: separationDist,
        cohesionRadius: cohesionRadius,
        alignmentRadius: alignmentRadius,
        separationWeight: separationWeight,
        cohesionWeight: cohesionWeight,
        alignmentWeight: alignmentWeight,
      );
    });

    test('returns zero force when no neighbors are nearby', () {
      final steering = flockingBehavior.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('combines forces from sub-behaviors correctly', () {
      // Add neighbors that will trigger all three behaviors
      final neighbor1 = MockFlockingAgent('N1',
        position: Vector2(separationDist * 0.5, 0), // Close for separation, cohesion, alignment (x=7.5)
        velocity: Vector2(maxSpeed * 0.8, maxSpeed * 0.2), // Moving somewhat right-up
        maxSpeed: maxSpeed);
      final neighbor2 = MockFlockingAgent('N2',
        position: Vector2(cohesionRadius * 0.6, alignmentRadius * 0.6), // Inside cohesion/alignment, outside separation (x=24, y=18)
        velocity: Vector2(maxSpeed * 0.9, -maxSpeed * 0.1), // Moving mostly right-down
        maxSpeed: maxSpeed);
       final neighbor3 = MockFlockingAgent('N3',
        position: Vector2(cohesionRadius * 0.7, -alignmentRadius * 0.7), // Inside cohesion, outside alignment/separation (x=28, y=-21)
        velocity: Vector2(maxSpeed, 0), // Moving right (same as agent)
        maxSpeed: maxSpeed);

      grid.add(neighbor1);
      grid.add(neighbor2);
      grid.add(neighbor3);

      // Instantiate sub-behaviors manually for comparison
      final sep = Separation(spatialGrid: grid, desiredSeparation: separationDist);
      final coh = Cohesion(spatialGrid: grid, neighborhoodRadius: cohesionRadius);
      final align = Alignment(spatialGrid: grid, neighborhoodRadius: alignmentRadius);

      final expectedSepSteering = sep.calculateSteering(agent);
      final expectedCohSteering = coh.calculateSteering(agent);
      final expectedAlignSteering = align.calculateSteering(agent);

      final expectedTotal = (expectedSepSteering * separationWeight) +
                              (expectedCohSteering * cohesionWeight) +
                              (expectedAlignSteering * alignmentWeight);

      // Calculate actual steering from Flocking behavior
      final actualSteering = flockingBehavior.calculateSteering(agent);

      // Compare the actual combined force with the sum of manually calculated components
      // Increase tolerance slightly due to potential minor differences in sub-behavior states
      expect(actualSteering, vectorCloseTo(expectedTotal, 0.01));

      // Also check that the force is non-zero
      expect(actualSteering.length, greaterThan(0.001));
    });

     test('handles case where only separation applies', () {
       // Add a neighbor very close, but stationary and outside alignment/cohesion radius if different
       final closeNeighbor = MockFlockingAgent('C',
         position: Vector2(separationDist * 0.1, 0), // Very close
         velocity: Vector2.zero(), // Stationary
         maxSpeed: maxSpeed);
       grid.add(closeNeighbor);

       // Manually calculate expected separation force
       final sep_i = Separation(spatialGrid: grid, desiredSeparation: separationDist); // Instance for test
       final expectedSepSteering_s = sep_i.calculateSteering(agent); // _s for sep only
       // Cohesion and Alignment should yield zero force
       final expectedTotal_s = expectedSepSteering_s * separationWeight; // _s for sep only
       final actualSteering_s = flockingBehavior.calculateSteering(agent); // _s for sep only

       expect(actualSteering_s, vectorCloseTo(expectedTotal_s, 0.001)); // Tighter tolerance
       expect(actualSteering_s.length, greaterThan(0.001));
     });

      test('handles case where only cohesion applies', () {
        // Add neighbors outside separation distance but inside cohesion/alignment
        final neighbor1Pos_coh = Vector2(separationDist * 1.5, 10.0); // x=22.5
        final neighbor2Pos_coh = Vector2(separationDist * 1.5, -10.0); // x=22.5
        final neighbor1_coh = MockFlockingAgent('N1C', position: neighbor1Pos_coh.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed); // Stationary
        final neighbor2_coh = MockFlockingAgent('N2C', position: neighbor2Pos_coh.clone(), velocity: Vector2.zero(), maxSpeed: maxSpeed); // Stationary
        grid.add(neighbor1_coh);
        grid.add(neighbor2_coh);

        // Instantiate Cohesion manually to get expected force
        final coh_i = Cohesion(spatialGrid: grid, neighborhoodRadius: cohesionRadius); // Instance for test
        final expectedCohSteering_c = coh_i.calculateSteering(agent); // _c for coh only
        // Separation and Alignment should yield zero force
        final expectedTotal_c = expectedCohSteering_c * cohesionWeight; // _c for coh only
        final actualSteering_c = flockingBehavior.calculateSteering(agent); // _c for coh only

        expect(actualSteering_c, vectorCloseTo(expectedTotal_c, 0.001)); // Tighter tolerance
        // Steering might be zero if agent velocity already matches desired cohesion direction
        // Check if expected is non-zero before asserting length > 0
        // Also check if actual is non-zero, as floating point might make expected slightly non-zero
        if (expectedTotal_c.length2 > 1e-6 && actualSteering_c.length2 > 1e-6) {
           expect(actualSteering_c.length, greaterThan(0.001));
        } else {
           expect(actualSteering_c.length, closeTo(0.0, 0.001));
        }
      });

       test('handles case where only alignment applies', () {
         // Add neighbors outside separation/cohesion radius but inside alignment
         final neighbor1Pos = Vector2(alignmentRadius * 0.8, 0); // x=24
         final neighbor2Pos = Vector2(alignmentRadius * 0.8, 10); // x=24, y=10
         final velAlign = Vector2(0, maxSpeed); // Align upwards
         final neighbor1 = MockFlockingAgent('N1', position: neighbor1Pos.clone(), velocity: velAlign.clone(), maxSpeed: maxSpeed);
         final neighbor2 = MockFlockingAgent('N2', position: neighbor2Pos.clone(), velocity: velAlign.clone(), maxSpeed: maxSpeed);

         // Need to adjust radii for this test
         flockingBehavior = Flocking(
           spatialGrid: grid,
           separationDistance: 5.0, // Small separation
           cohesionRadius: 10.0, // Small cohesion
           alignmentRadius: alignmentRadius, // Keep alignment radius
           separationWeight: separationWeight,
           cohesionWeight: cohesionWeight,
           alignmentWeight: alignmentWeight,
         );
         grid.add(neighbor1);
         grid.add(neighbor2);


         final align_i = Alignment(spatialGrid: grid, neighborhoodRadius: alignmentRadius); // Instance for test
         final expectedAlignSteering_a = align_i.calculateSteering(agent); // _a for align only
         // Separation and Cohesion should be zero
         final expectedTotal_a = expectedAlignSteering_a * alignmentWeight; // _a for align only
         final actualSteering_a = flockingBehavior.calculateSteering(agent); // _a for align only

         expect(actualSteering_a, vectorCloseTo(expectedTotal_a, 0.001)); // Tighter tolerance
         if (expectedTotal_a.length2 > 1e-6 && actualSteering_a.length2 > 1e-6) {
            expect(actualSteering_a.length, greaterThan(0.001));
         } else {
            expect(actualSteering_a.length, closeTo(0.0, 0.001));
         }
       });

  });
}
