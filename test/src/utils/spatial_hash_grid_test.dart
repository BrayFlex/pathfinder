import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';

// Simple MockAgent for testing purposes
class MockAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity = Vector2.zero(); // Not used by grid, but required
  @override
  double maxSpeed = 100;
  @override
  double maxForce = 10;
  @override
  double mass = 1;
  @override
  double radius; // Used for potential future tests, not directly by grid logic

  // Added for easier identification in tests
  final String id;

  MockAgent(this.id, this.position, {this.radius = 5.0});

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op for grid tests
  }

  // Override equality and hashCode for Set operations in queryRadius
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockAgent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'MockAgent($id, $position)';
}


void main() {
  group('SpatialHashGrid', () {
    late SpatialHashGrid grid;
    const double cellSize = 10.0;

    // Helper to create agents
    MockAgent agent(String id, double x, double y) => MockAgent(id, Vector2(x, y));

    setUp(() {
      grid = SpatialHashGrid(cellSize: cellSize);
    });

    test('constructor initializes correctly', () {
      expect(grid.cellSize, equals(cellSize));
      // Internal state check (optional, depends on visibility)
      // expect(grid._buckets, isEmpty);
      // expect(grid._agentBucketCache, isEmpty);
    });

    test('add correctly places agent', () {
      final a1 = agent('A', 5.0, 5.0);
      grid.add(a1);
      // Verify by querying
      final results = grid.queryRadius(Vector2(5.0, 5.0), 1.0);
      expect(results, contains(a1));
      expect(results.length, 1);
    });

     test('add multiple agents to same cell', () {
      final a1 = agent('A', 3.0, 4.0);
      final a2 = agent('B', 6.0, 7.0); // Same cell (0,0) for cellSize 10
      grid.add(a1);
      grid.add(a2);
      final results = grid.queryRadius(Vector2(5.0, 5.0), 5.0); // Query covers both
      expect(results, containsAll([a1, a2]));
      expect(results.length, 2);
    });

     test('add multiple agents to different cells', () {
      final a1 = agent('A', 5.0, 5.0);   // Cell (0,0)
      final a2 = agent('B', 15.0, 5.0); // Cell (1,0)
      grid.add(a1);
      grid.add(a2);

      // Query cell 0,0
      expect(grid.queryRadius(Vector2(5.0, 5.0), 1.0), contains(a1));
      expect(grid.queryRadius(Vector2(5.0, 5.0), 1.0).length, 1);

      // Query cell 1,0
      expect(grid.queryRadius(Vector2(15.0, 5.0), 1.0), contains(a2));
       expect(grid.queryRadius(Vector2(15.0, 5.0), 1.0).length, 1);

       // Query spanning both
       expect(grid.queryRadius(Vector2(10.0, 5.0), 6.0), containsAll([a1, a2]));
       expect(grid.queryRadius(Vector2(10.0, 5.0), 6.0).length, 2);
    });


    test('remove correctly removes agent', () {
      final a1 = agent('A', 5.0, 5.0);
      grid.add(a1);
      expect(grid.queryRadius(a1.position, 1.0), isNotEmpty);

      final removed = grid.remove(a1);
      expect(removed, isTrue);
      expect(grid.queryRadius(a1.position, 1.0), isEmpty);
    });

     test('remove returns false for non-existent agent', () {
       final a1 = agent('A', 5.0, 5.0);
       final a2 = agent('B', 15.0, 15.0);
       grid.add(a1);
       final removed = grid.remove(a2); // a2 was never added
       expect(removed, isFalse);
       expect(grid.queryRadius(a1.position, 1.0), contains(a1)); // a1 should still be there
     });

      test('remove leaves other agents intact', () {
       final a1 = agent('A', 5.0, 5.0);
       final a2 = agent('B', 6.0, 6.0); // Same cell
       grid.add(a1);
       grid.add(a2);

       final removed = grid.remove(a1);
       expect(removed, isTrue);
       expect(grid.queryRadius(Vector2(5.5, 5.5), 3.0), contains(a2));
       expect(grid.queryRadius(Vector2(5.5, 5.5), 3.0), isNot(contains(a1)));
       expect(grid.queryRadius(Vector2(5.5, 5.5), 3.0).length, 1);
     });


    test('update keeps agent in same cell if position unchanged', () {
      final a1 = agent('A', 5.0, 5.0);
      grid.add(a1);
      grid.update(a1); // Position didn't change
      expect(grid.queryRadius(a1.position, 1.0), contains(a1));
    });

     test('update keeps agent in same cell if position changes within cell', () {
      final a1 = agent('A', 5.0, 5.0);
      grid.add(a1);
      a1.position = Vector2(6.0, 6.0); // Still in cell (0,0)
      grid.update(a1);
      expect(grid.queryRadius(a1.position, 1.0), contains(a1));
      // Check old position query doesn't find it (unless radius overlaps)
      expect(grid.queryRadius(Vector2(5.0, 5.0), 0.5), isEmpty);
    });

    test('update moves agent to new cell', () {
      final a1 = agent('A', 5.0, 5.0); // Cell (0,0)
      grid.add(a1);
      final oldPosition = a1.position.clone();

      a1.position = Vector2(15.0, 5.0); // Move to cell (1,0)
      grid.update(a1);

      // Should not be found at old position (with small radius)
      expect(grid.queryRadius(oldPosition, 1.0), isEmpty);
      // Should be found at new position
      expect(grid.queryRadius(a1.position, 1.0), contains(a1));
    });

     test('update handles agent not previously added gracefully', () {
       final a1 = agent('A', 5.0, 5.0);
       // Don't add a1
       expect(() => grid.update(a1), returnsNormally); // Should add it
       expect(grid.queryRadius(a1.position, 1.0), contains(a1)); // Should now be found
     });


    test('queryRadius finds agents within radius', () {
      final a1 = agent('A', 5.0, 5.0);
      final a2 = agent('B', 12.0, 5.0); // 7 units away
      final a3 = agent('C', 5.0, 15.0); // 10 units away
      grid.add(a1);
      grid.add(a2);
      grid.add(a3);

      final center = Vector2(5.0, 5.0);
      expect(grid.queryRadius(center, 1.0), contains(a1));
      expect(grid.queryRadius(center, 1.0).length, 1);

      expect(grid.queryRadius(center, 8.0), containsAll([a1, a2]));
      expect(grid.queryRadius(center, 8.0).length, 2);

      expect(grid.queryRadius(center, 11.0), containsAll([a1, a2, a3]));
      expect(grid.queryRadius(center, 11.0).length, 3);
    });

     test('queryRadius returns empty list for empty grid', () {
       expect(grid.queryRadius(Vector2.zero(), 100.0), isEmpty);
     });

     test('queryRadius returns empty list when no agents are in radius', () {
       final a1 = agent('A', 100.0, 100.0);
       grid.add(a1);
       expect(grid.queryRadius(Vector2.zero(), 50.0), isEmpty);
     });

      test('queryRadius handles zero radius', () {
       final a1 = agent('A', 5.0, 5.0);
       final a2 = agent('B', 5.1, 5.0);
       grid.add(a1);
       grid.add(a2);
       expect(grid.queryRadius(Vector2(5.0, 5.0), 0.0), contains(a1));
       expect(grid.queryRadius(Vector2(5.0, 5.0), 0.0).length, 1);
     });

      test('queryRadius handles negative radius', () {
       final a1 = agent('A', 5.0, 5.0);
       grid.add(a1);
       expect(grid.queryRadius(Vector2(5.0, 5.0), -1.0), isEmpty);
     });

     test('queryRadius handles agents exactly on cell boundaries', () {
       final a1 = agent('A', 10.0, 10.0); // Boundary of (0,0), (1,0), (0,1), (1,1)
       grid.add(a1);
       // Query from different cells around the boundary
       expect(grid.queryRadius(Vector2(9.0, 9.0), 2.0), contains(a1)); // Cell (0,0) perspective
       expect(grid.queryRadius(Vector2(11.0, 9.0), 2.0), contains(a1)); // Cell (1,0) perspective
       expect(grid.queryRadius(Vector2(9.0, 11.0), 2.0), contains(a1)); // Cell (0,1) perspective
       expect(grid.queryRadius(Vector2(11.0, 11.0), 2.0), contains(a1)); // Cell (1,1) perspective
     });

      test('queryRadius handles query radius exactly touching agent', () {
       final a1 = agent('A', 10.0, 0.0);
       grid.add(a1);
       expect(grid.queryRadius(Vector2.zero(), 10.0), contains(a1));
     });


    test('clear removes all agents', () {
      final a1 = agent('A', 5.0, 5.0);
      final a2 = agent('B', 15.0, 5.0);
      grid.add(a1);
      grid.add(a2);
      expect(grid.queryRadius(Vector2(10.0, 5.0), 20.0), isNotEmpty);

      grid.clear();
      expect(grid.queryRadius(Vector2(10.0, 5.0), 20.0), isEmpty);
      // Optional: Check internal state if possible
      // expect(grid._buckets, isEmpty);
      // expect(grid._agentBucketCache, isEmpty);
    });
  });
}
