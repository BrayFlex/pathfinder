import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/best_first_finder.dart';
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
  group('BestFirstFinder', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds straight path on empty grid (cardinal)', () {
      grid = Grid(5, 5);
      final finder = BestFirstFinder(allowDiagonal: false);
      final path = finder.findPath(0, 0, 4, 0, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(0));
      // Best-First should find the direct path here
      expect(path.length, equals(5));
      expect(pathMatches(path, [[0,0], [1,0], [2,0], [3,0], [4,0]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds straight path on empty grid (diagonal)', () {
      grid = Grid(5, 5);
      final finder = BestFirstFinder(allowDiagonal: true);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      // Best-First should find the direct diagonal path
      expect(path.length, equals(5));
       expect(pathMatches(path, [[0,0], [1,1], [2,2], [3,3], [4,4]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds path around simple obstacle (cardinal)', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = BestFirstFinder(allowDiagonal: false);
      final path = finder.findPath(1, 1, 3, 1, grid); // Path through the obstacle row

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // It should find *a* path, likely one of the shortest ones here.
      expect(path.length, equals(5));
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse); // Must not go through obstacle
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
       final finder = BestFirstFinder(allowDiagonal: true);
       final path = finder.findPath(1, 1, 3, 1, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
       // Should find one of the shortest paths here too.
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
      final finder = BestFirstFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = BestFirstFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = BestFirstFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = BestFirstFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = BestFirstFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('finds a path with weighted nodes (may not be shortest)', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Best-First prioritizes based on H only.
         // From (0,1), H for (1,1) is lower than H for (0,0) or (0,2) using Manhattan/Euclidean.
         // So it might try to go through the expensive node if heuristic leads it there.

         final finder = BestFirstFinder(allowDiagonal: false);
         final path = finder.findPath(0, 1, 2, 1, grid);

         expect(path, isNotEmpty);
         // It *might* find the direct path (length 3) or a detour (length 5).
         // We can't guarantee which one without knowing the exact heuristic and tie-breaking.
         expect(path.last.x, equals(2)); expect(path.last.y, equals(1));
         print('Weighted Path (BestFirst): ${printPath(path)}');
       });

        test('works with different heuristics (diagonal)', () {
          grid = Grid(5, 5);
          final finder = BestFirstFinder(allowDiagonal: true, heuristic: Heuristics.diagonal);
          final path = finder.findPath(0, 0, 4, 4, grid);
          expect(path, isNotEmpty);
          expect(path.length, equals(5)); // Should find direct path here
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
           final finder = BestFirstFinder(allowDiagonal: true, heuristic: Heuristics.manhattan);
           final path = finder.findPath(0, 0, 4, 4, grid);
           expect(path, isNotEmpty);
           expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
           expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
           print('Manhattan Path (BestFirst): ${printPath(path)}');
         });

  });
}
