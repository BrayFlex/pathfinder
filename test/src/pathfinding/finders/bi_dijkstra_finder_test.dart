import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_dijkstra_finder.dart';

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
  group('BiDijkstraFinder', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds shortest cost path on empty grid (cardinal)', () {
      grid = Grid(5, 5); // All weights are 1.0
      final finder = BiDijkstraFinder(allowDiagonal: false);
      final path = finder.findPath(0, 0, 4, 0, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(0));
      expect(path.length, equals(5)); // Shortest cost path
      expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds shortest cost path on empty grid (diagonal)', () {
      grid = Grid(5, 5); // All weights are 1.0
      final finder = BiDijkstraFinder(allowDiagonal: true);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      // Diagonal path cost ~5.66, Cardinal path cost 8. Dijkstra finds diagonal.
      expect(path.length, equals(5));
       expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds shortest cost path around simple obstacle (cardinal)', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = BiDijkstraFinder(allowDiagonal: false);
      final path = finder.findPath(1, 1, 3, 1, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // Both detours have cost 4 (length 5). BiDijkstra might find either.
      expect(path.length, equals(5));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
      final path1 = pathMatches(path, [[1,1], [1,0], [2,0], [3,0], [3,1]]);
      final path2 = pathMatches(path, [[1,1], [1,2], [2,2], [3,2], [3,1]]);
      expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
    });

     test('finds shortest cost path around simple obstacle (diagonal)', () {
       grid = Grid(5, 3, matrix: [
         [0, 0, 0, 0, 0],
         [0, 0, 1, 0, 0], // Obstacle at (2, 1)
         [0, 0, 0, 0, 0],
       ]);
       final finder = BiDijkstraFinder(allowDiagonal: true);
       final path = finder.findPath(1, 1, 3, 1, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
       // Both diagonal detours have cost 1 + sqrt(2) ~ 2.414.
       expect(path.length, equals(3));
       expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
       final path1 = pathMatches(path, [[1,1], [2,0], [3,1]]);
       final path2 = pathMatches(path, [[1,1], [2,2], [3,1]]);
       expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
     });

    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = BiDijkstraFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = BiDijkstraFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = BiDijkstraFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = BiDijkstraFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = BiDijkstraFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('finds lowest cost path with weighted nodes (cardinal)', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Direct path cost: 11. Path around cost: 4.
         // BiDijkstra should find the detour.

         final finder = BiDijkstraFinder(allowDiagonal: false);
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(5)); // Should take the detour
         expect(path.any((node) => node.x == 1 && node.y == 1), isFalse); // Avoids center
         print('Weighted Path (BiDijkstra): ${printPath(path)}');
       });

        test('finds lowest cost path with weighted nodes (diagonal)', () {
          grid = Grid(3, 3);
          grid.setWeightAt(1, 0, 10.0); // Expensive node above start
          grid.setWeightAt(1, 1, 10.0); // Expensive node diagonally
          // Path from (0,0) to (2,2)
          // Lowest cost path is via (0,1) and (1,2) with cost ~3.41

          final finder = BiDijkstraFinder(allowDiagonal: true, dontCrossCorners: false);
          final path = finder.findPath(0, 0, 2, 2, grid);

          expect(path, isNotEmpty);
          // Expect path via (0,1) and (1,2)
          expect(pathMatches(path, [[0,0], [0,1], [1,2], [2,2]]), isTrue, reason: 'Path: ${printPath(path)}');
          expect(path.length, equals(4));
        });

  });
}
