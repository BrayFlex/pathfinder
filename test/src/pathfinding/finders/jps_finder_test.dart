import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/jps_finder.dart';
import 'package:pathfinder/src/pathfinding/heuristics.dart';

// Helper to check if a path matches a list of expected coordinates
bool pathMatches(List<Node> path, List<List<int>> expectedCoords) {
  if (path.length != expectedCoords.length) return false;
  for (int i = 0; i < path.length; ++i) {
    if (path[i].x != expectedCoords[i][0] || path[i].y != expectedCoords[i][1]) {
      return false;
    }
  }
  return true;
}

// Helper to print path for debugging
String printPath(List<Node> path) {
  return path.map((n) => '(${n.x},${n.y})').join(' -> ');
}


void main() {
  group('JumpPointFinder (JPS)', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds straight path on empty grid (horizontal)', () {
      grid = Grid(10, 5);
      // JPS requires a heuristic, Octile is common
      final finder = JumpPointFinder(heuristic: Heuristics.octile);
      final path = finder.findPath(0, 2, 9, 2, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(2));
      expect(path.last.x, equals(9)); expect(path.last.y, equals(2));
      // JPS should jump directly to the end
      expect(path.length, equals(2));
      expect(pathMatches(path, [[0,2], [9,2]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

     test('finds straight path on empty grid (vertical)', () {
      grid = Grid(5, 10);
      final finder = JumpPointFinder(heuristic: Heuristics.octile);
      final path = finder.findPath(2, 0, 2, 9, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(2)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(2)); expect(path.last.y, equals(9));
      // JPS should jump directly to the end
      expect(path.length, equals(2));
      expect(pathMatches(path, [[2,0], [2,9]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds straight path on empty grid (diagonal)', () {
      grid = Grid(10, 10);
      final finder = JumpPointFinder(heuristic: Heuristics.octile);
      final path = finder.findPath(0, 0, 9, 9, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(9)); expect(path.last.y, equals(9));
       // JPS should jump directly to the end diagonally
      expect(path.length, equals(2));
       expect(pathMatches(path, [[0,0], [9,9]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds path around simple obstacle', () {
      grid = Grid(5, 5, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
        [0, 0, 0, 0, 0],
      ]);
      final finder = JumpPointFinder(heuristic: Heuristics.octile);
      final path = finder.findPath(1, 1, 3, 1, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // JPS should find a path with few jump points, e.g., (1,1) -> (2,0) -> (3,1) or (1,1) -> (2,2) -> (3,1)
      expect(path.length, equals(3));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
      final path1 = pathMatches(path, [[1,1], [2,0], [3,1]]);
      final path2 = pathMatches(path, [[1,1], [2,2], [3,1]]);
      expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
    });

     test('finds path requiring forced neighbor jump', () {
       grid = Grid(5, 5, matrix: [
         [0, 0, 0, 0, 0],
         [0, 0, 1, 0, 0], // Obstacle at (2, 1)
         [0, 0, 0, 0, 0],
         [0, 1, 0, 0, 0], // Obstacle at (1, 3)
         [0, 0, 0, 0, 0],
       ]);
       final finder = JumpPointFinder(heuristic: Heuristics.octile);
       // Path from (0,0) to (3,3)
       // Should jump diagonally to (1,1), then detect forced neighbor at (1,2) due to obstacle (1,3)
       // Might jump to (1,2) or find another path.
       final path = finder.findPath(0, 0, 3, 3, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(3));
       // Expected path might be (0,0) -> (1,2) [jump point due to forced neighbor] -> (2,2) -> (3,3) ?
       // Or (0,0) -> (2,0) -> (2,2) -> (3,3) ?
       print('Forced Neighbor Path (JPS): ${printPath(path)}'); // Print for analysis
       // Check it avoids obstacles
       expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
       expect(path.any((node) => node.x == 1 && node.y == 3), isFalse);
       // Check path length is reasonable (should be shorter than A* node count)
       expect(path.length, lessThan(7)); // A* cardinal path length is 7
     });


    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = JumpPointFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = JumpPointFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = JumpPointFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = JumpPointFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = JumpPointFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('ignores node weights (finds shortest step/geometric path)', () {
         // JPS assumes uniform cost, weights should ideally not affect the path shape,
         // although the internal g-cost calculation might use them if not overridden.
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // JPS should still find the direct path (0,1)->(2,1) as it's geometrically shortest
         // and doesn't consider the weight for pruning/jumping.

         final finder = JumpPointFinder(heuristic: Heuristics.manhattan); // Use Manhattan for clarity
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(2)); // Jumps directly
         expect(pathMatches(path, [[0,1], [2,1]]), isTrue, reason: 'Path: ${printPath(path)}');
       });

        test('finds path in complex maze', () {
          grid = Grid(10, 10, matrix: [
            [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
            [0, 1, 1, 0, 1, 0, 1, 0, 1, 0],
            [0, 0, 1, 0, 1, 0, 0, 0, 1, 0],
            [1, 0, 1, 0, 1, 1, 1, 0, 1, 0],
            [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
            [0, 1, 1, 1, 1, 0, 1, 1, 1, 0],
            [0, 0, 0, 0, 1, 0, 0, 0, 1, 0],
            [0, 1, 1, 0, 1, 1, 0, 0, 1, 0],
            [0, 1, 0, 0, 0, 0, 0, 1, 1, 0],
            [0, 0, 0, 1, 1, 1, 0, 0, 0, 0],
          ]);
          final finder = JumpPointFinder(heuristic: Heuristics.octile);
          final path = finder.findPath(0, 0, 9, 9, grid);

          expect(path, isNotEmpty);
          expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
          expect(path.last.x, equals(9)); expect(path.last.y, equals(9));
          // Check path doesn't go through walls (value 1)
          for (final node in path) {
            expect(grid.isWalkableAt(node.x, node.y), isTrue);
          }
          print('Maze Path (JPS): ${printPath(path)}');
          // JPS path should have significantly fewer nodes than A* or BFS path
          expect(path.length, lessThan(20)); // A reasonable upper bound for this maze
        });

  });
}
