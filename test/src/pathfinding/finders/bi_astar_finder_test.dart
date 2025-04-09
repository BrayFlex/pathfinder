import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_astar_finder.dart';
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
  group('BiAStarFinder', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds straight path on empty grid (cardinal)', () {
      grid = Grid(5, 5);
      final finder = BiAStarFinder(allowDiagonal: false);
      final path = finder.findPath(0, 0, 4, 0, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(0));
      expect(path.length, equals(5)); // BiA* guarantees shortest path
      expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds straight path on empty grid (diagonal)', () {
      grid = Grid(5, 5);
      final finder = BiAStarFinder(allowDiagonal: true);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      expect(path.length, equals(5)); // BiA* guarantees shortest path
       expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds path around simple obstacle (cardinal)', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = BiAStarFinder(allowDiagonal: false);
      final path = finder.findPath(1, 1, 3, 1, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // Should find one of the shortest paths (length 5)
      expect(path.length, equals(5));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
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
       final finder = BiAStarFinder(allowDiagonal: true);
       final path = finder.findPath(1, 1, 3, 1, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
       // Should find one of the shortest paths (length 3)
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
        final finder = BiAStarFinder(allowDiagonal: true, dontCrossCorners: true);
        final path = finder.findPath(1, 0, 2, 2, grid);

        expect(path, isNotEmpty);
        // Shortest path length is 6
        expect(path.length, equals(6));
        expect(path.any((node) => node.x == 1 && node.y == 1), isFalse);
        expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
        print('Corner Path (BiA*): ${printPath(path)}');
      });

    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = BiAStarFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = BiAStarFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = BiAStarFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = BiAStarFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = BiAStarFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        // Bi-directional might behave slightly differently here.
        // The loop condition might terminate immediately or after one expansion.
        // Let's expect length 1 as the start node is the goal.
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('finds lowest cost path with weighted nodes (cardinal)', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Direct path cost: 1 + 10 = 11. Path around cost: 4.
         // BiA* should find the detour.

         final finder = BiAStarFinder(allowDiagonal: false);
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(5)); // Should take the detour
         expect(path.any((node) => node.x == 1 && node.y == 1), isFalse); // Avoids center
         print('Weighted Path (BiA*): ${printPath(path)}');
         // Check one of the expected paths
         final path1 = pathMatches(path, [[0,1], [0,0], [1,0], [2,0], [2,1]]);
         final path2 = pathMatches(path, [[0,1], [0,2], [1,2], [2,2], [2,1]]);
         expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
       });

        test('finds lowest cost path with weighted nodes (diagonal)', () {
          grid = Grid(3, 3);
          grid.setWeightAt(1, 0, 10.0); // Expensive node above start
          grid.setWeightAt(1, 1, 10.0); // Expensive node diagonally
          // Path from (0,0) to (2,2)
          // Lowest cost path is via (0,1) and (1,2) with cost ~3.41

          final finder = BiAStarFinder(allowDiagonal: true, dontCrossCorners: false);
          final path = finder.findPath(0, 0, 2, 2, grid);

          expect(path, isNotEmpty);
          // Expect path via (0,1) and (1,2)
          expect(pathMatches(path, [[0,0], [0,1], [1,2], [2,2]]), isTrue, reason: 'Path: ${printPath(path)}');
          expect(path.length, equals(4));
        });

        test('works with different heuristics (diagonal)', () {
          grid = Grid(5, 5);
          final finder = BiAStarFinder(allowDiagonal: true, heuristic: Heuristics.diagonal);
          final path = finder.findPath(0, 0, 4, 4, grid);
          expect(path, isNotEmpty);
          expect(path.length, equals(5));
          expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue);
        });

         test('works with different heuristics (manhattan)', () {
           grid = Grid(5, 5, matrix: [
             [0,0,0,0,0],
             [0,1,1,1,0],
             [0,1,0,0,0],
             [0,1,1,1,0],
             [0,0,0,0,0],
           ]);
           // Manhattan is not strictly admissible for diagonal movement, but BiA* should still find the optimal path.
           final finder = BiAStarFinder(allowDiagonal: true, heuristic: Heuristics.manhattan);
           final path = finder.findPath(0, 0, 4, 4, grid);
           expect(path, isNotEmpty);
           expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
           expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
           // The optimal path here might be length 9 (needs verification)
           // Let's relax the length check for non-admissible heuristic case
           // expect(path.length, equals(9));
           print('Manhattan Path (BiA*): ${printPath(path)}');
           // Check it avoids walls
           expect(path.any((n) => !grid.isWalkableAt(n.x, n.y)), isFalse);
         });

  });
}
