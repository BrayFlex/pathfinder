import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/astar_finder.dart';
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
  group('AStarFinder', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds straight path on empty grid (cardinal)', () {
      grid = Grid(5, 5);
      final finder = AStarFinder(allowDiagonal: false);
      final path = finder.findPath(0, 0, 4, 0, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(0));
      expect(path.length, equals(5)); // 0,0 -> 1,0 -> 2,0 -> 3,0 -> 4,0
      expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds straight path on empty grid (diagonal)', () {
      grid = Grid(5, 5);
      final finder = AStarFinder(allowDiagonal: true);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      expect(path.length, equals(5)); // 0,0 -> 1,1 -> 2,2 -> 3,3 -> 4,4
       expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds path around simple obstacle (cardinal)', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = AStarFinder(allowDiagonal: false);
      final path = finder.findPath(1, 1, 3, 1, grid); // Path through the obstacle row

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // Expected path: (1,1) -> (1,0) -> (2,0) -> (3,0) -> (3,1) OR (1,1) -> (1,2) -> (2,2) -> (3,2) -> (3,1)
      // Length should be 5
      expect(path.length, equals(5));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse); // Must not go through obstacle
      // Check one possible valid path
      final path1 = pathMatches(path, [[1,1], [1,0], [2,0], [3,0], [3,1]]);
      final path2 = pathMatches(path, [[1,1], [1,2], [2,2], [3,2], [3,1]]);
      expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
    });

     test('finds path around simple obstacle (diagonal)', () {
       grid = Grid(5, 3, matrix: [
         [0, 0, 0, 0, 0],
         [0, 0, 1, 0, 0], // Obstacle at (2, 1)
         [0, 0, 0, 0, 0],
       ]);
       final finder = AStarFinder(allowDiagonal: true);
       final path = finder.findPath(1, 1, 3, 1, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
       // Expected path: (1,1) -> (2,0) -> (3,1) OR (1,1) -> (2,2) -> (3,1)
       // Length should be 3
       expect(path.length, equals(3));
       expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
       final path1 = pathMatches(path, [[1,1], [2,0], [3,1]]);
       final path2 = pathMatches(path, [[1,1], [2,2], [3,1]]);
       expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
     });

      test('finds path around simple obstacle (diagonal, dontCrossCorners)', () {
        grid = Grid(5, 3, matrix: [
          [0, 0, 0, 0, 0],
          [0, 1, 1, 0, 0], // Obstacles at (1, 1) and (2, 1)
          [0, 0, 0, 0, 0],
        ]);
        final finder = AStarFinder(allowDiagonal: true, dontCrossCorners: true);
        // Try to go from (1,0) to (2,2) - diagonal blocked by corners
        final path = finder.findPath(1, 0, 2, 2, grid);

        expect(path, isNotEmpty);
        // Expected path: (1,0) -> (0,0) -> (0,1) -> (0,2) -> (1,2) -> (2,2) OR similar detour
        // It cannot cut the corner at (1,1) or (2,1).
        // Let's check a simpler path: (1,0) -> (2,0) -> (3,0) -> (3,1) -> (3,2) -> (2,2) ? Length 6
        // Or (1,0) -> (0,0) -> (0,1) -> (0,2) -> (1,2) -> (2,2) ? Length 6
        expect(path.length, equals(6));
        expect(path.any((node) => node.x == 1 && node.y == 1), isFalse);
        expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
        print('Corner Path: ${printPath(path)}'); // For debugging
      });

    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = AStarFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = AStarFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = AStarFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = AStarFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = AStarFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('finds path with weighted nodes', () {
         grid = Grid(5, 1); // Simple 1D path
         grid.setWeightAt(1, 0, 5.0); // Make node (1,0) expensive
         grid.setWeightAt(2, 0, 5.0); // Make node (2,0) expensive
         grid.setWeightAt(3, 0, 5.0); // Make node (3,0) expensive
         // Path from (0,0) to (4,0)
         // Direct path cost: 1 + 5 + 5 + 5 = 16
         // A* should find this direct path as there's no alternative.

         final finder = AStarFinder(allowDiagonal: false);
         final path = finder.findPath(0, 0, 4, 0, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(5));
         expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
         // We can't easily verify the cost here, but the path should be correct.
       });

        test('finds cheaper path around weighted nodes', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Direct path cost: 1 + 10 = 11
         // Path around: (0,1)->(0,0)->(1,0)->(2,0)->(2,1) cost = 1+1+1+1 = 4
         // Or (0,1)->(0,2)->(1,2)->(2,2)->(2,1) cost = 4

         final finder = AStarFinder(allowDiagonal: false);
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(5)); // Should take the detour
         expect(path.any((node) => node.x == 1 && node.y == 1), isFalse); // Avoids center
         print('Weighted Path: ${printPath(path)}');
       });

        test('works with different heuristics (diagonal)', () {
          grid = Grid(5, 5);
          final finder = AStarFinder(allowDiagonal: true, heuristic: Heuristics.diagonal);
          final path = finder.findPath(0, 0, 4, 4, grid);
          expect(path, isNotEmpty);
          expect(path.length, equals(5));
          expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue);
        });

         test('works with different heuristics (manhattan)', () {
           // Manhattan might not yield the geometrically shortest path with diagonal moves allowed,
           // but it should still find *a* path.
           grid = Grid(5, 5, matrix: [
             [0,0,0,0,0],
             [0,1,1,1,0],
             [0,1,0,0,0],
             [0,1,1,1,0],
             [0,0,0,0,0],
           ]);
           final finder = AStarFinder(allowDiagonal: true, heuristic: Heuristics.manhattan);
           final path = finder.findPath(0, 0, 4, 4, grid);
           expect(path, isNotEmpty);
           expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
           expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
           print('Manhattan Path: ${printPath(path)}');
         });

         test('works with different heuristics (euclidean)', () {
           grid = Grid(5, 5);
           final finder = AStarFinder(allowDiagonal: true, heuristic: Heuristics.euclidean);
           final path = finder.findPath(0, 0, 4, 4, grid);
           expect(path, isNotEmpty);
           expect(path.length, equals(5)); // Should find direct diagonal path
           expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue);
         });

  });
}
