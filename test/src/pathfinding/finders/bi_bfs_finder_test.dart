import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_bfs_finder.dart';

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
  group('BiBreadthFirstFinder (Bi-BFS)', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds shortest step path on empty grid (cardinal)', () {
      grid = Grid(5, 5);
      final finder = BiBreadthFirstFinder(allowDiagonal: false);
      final path = finder.findPath(0, 0, 4, 0, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(0));
      expect(path.length, equals(5)); // Shortest in steps
      // BiBFS might meet in the middle, path could be slightly different but length is key
      // expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds shortest step path on empty grid (diagonal)', () {
      grid = Grid(5, 5);
      final finder = BiBreadthFirstFinder(allowDiagonal: true);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      expect(path.length, equals(5)); // Diagonal path has fewest steps
       // BiBFS might meet in the middle, path could be slightly different but length is key
       // expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds shortest step path around simple obstacle (cardinal)', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = BiBreadthFirstFinder(allowDiagonal: false);
      final path = finder.findPath(1, 1, 3, 1, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // Both detours have 5 steps, Bi-BFS should find one.
      expect(path.length, equals(5));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
      print('Obstacle Path (BiBFS Cardinal): ${printPath(path)}');
    });

     test('finds shortest step path around simple obstacle (diagonal)', () {
       grid = Grid(5, 3, matrix: [
         [0, 0, 0, 0, 0],
         [0, 0, 1, 0, 0], // Obstacle at (2, 1)
         [0, 0, 0, 0, 0],
       ]);
       final finder = BiBreadthFirstFinder(allowDiagonal: true);
       final path = finder.findPath(1, 1, 3, 1, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
       // Both diagonal detours have 3 steps.
       expect(path.length, equals(3));
       expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
       print('Obstacle Path (BiBFS Diagonal): ${printPath(path)}');
     });

    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = BiBreadthFirstFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = BiBreadthFirstFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = BiBreadthFirstFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = BiBreadthFirstFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = BiBreadthFirstFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('ignores node weights (finds shortest step path)', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Bi-BFS ignores weights and finds the direct path (0,1)->(1,1)->(2,1) (3 steps).

         final finder = BiBreadthFirstFinder(allowDiagonal: false);
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         expect(path.length, equals(3)); // Should take the direct path
         expect(pathMatches(path, [[0,1], [1,1], [2,1]]), isTrue, reason: 'Path: ${printPath(path)}');
       });

        test('finds shortest step path with diagonal preference', () {
          grid = Grid(3, 3);
          final finder = BiBreadthFirstFinder(allowDiagonal: true);
          // Path from (0,0) to (1,2) -> 3 steps diagonally
          final path = finder.findPath(0, 0, 1, 2, grid);
          expect(path, isNotEmpty);
          expect(path.length, equals(3)); // Should find a 3-step path
          print('Bi-BFS Diagonal Path: ${printPath(path)}');
        });

  });
}
