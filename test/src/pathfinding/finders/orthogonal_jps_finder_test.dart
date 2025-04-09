import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/finders/orthogonal_jps_finder.dart';
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
  group('OrthogonalJumpPointFinder', () {
    late Grid grid;

    // --- Test Scenarios ---

    test('finds straight path on empty grid (horizontal)', () {
      grid = Grid(10, 5);
      final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
      final path = finder.findPath(0, 2, 9, 2, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(2));
      expect(path.last.x, equals(9)); expect(path.last.y, equals(2));
      // Orthogonal JPS should jump directly to the end horizontally
      expect(path.length, equals(2));
      expect(pathMatches(path, [[0,2], [9,2]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

     test('finds straight path on empty grid (vertical)', () {
      grid = Grid(5, 10);
      final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
      final path = finder.findPath(2, 0, 2, 9, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(2)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(2)); expect(path.last.y, equals(9));
      // Orthogonal JPS should jump directly to the end vertically
      expect(path.length, equals(2));
      expect(pathMatches(path, [[2,0], [2,9]]), isTrue, reason: 'Path: ${printPath(path)}');
    });

    test('finds L-shaped path on empty grid', () {
      grid = Grid(5, 5);
      final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
      final path = finder.findPath(0, 0, 4, 4, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
      expect(path.last.x, equals(4)); expect(path.last.y, equals(4));
      // Should find a path with one corner jump point, e.g., (0,0)->(4,0)->(4,4) or (0,0)->(0,4)->(4,4)
      // The path length will be 3 (start, corner, end)
      expect(path.length, equals(3));
      final path1 = pathMatches(path, [[0,0], [4,0], [4,4]]);
      final path2 = pathMatches(path, [[0,0], [0,4], [4,4]]);
       expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
     }); // Removed skip

     test('finds path around simple obstacle', () {
      grid = Grid(5, 3, matrix: [
        [0, 0, 0, 0, 0],
        [0, 0, 1, 0, 0], // Obstacle at (2, 1)
        [0, 0, 0, 0, 0],
      ]);
      final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
      final path = finder.findPath(1, 1, 3, 1, grid);

      expect(path, isNotEmpty);
      expect(path.first.x, equals(1)); expect(path.first.y, equals(1));
      expect(path.last.x, equals(3)); expect(path.last.y, equals(1));
      // Orthogonal JPS should find a path like (1,1)->(1,0)->(3,0)->(3,1) or (1,1)->(1,2)->(3,2)->(3,1)
      // Jump points likely at corners of the detour.
      expect(path.length, equals(4)); // (1,1)->(1,0 or 1,2)->(3,0 or 3,2)->(3,1)
      expect(path.any((node) => node.x == 2 && node.y == 1), isFalse);
      final path1 = pathMatches(path, [[1,1], [1,0], [3,0], [3,1]]);
       final path2 = pathMatches(path, [[1,1], [1,2], [3,2], [3,1]]);
       expect(path1 || path2, isTrue, reason: 'Path: ${printPath(path)}');
     }); // Removed skip

     test('finds path requiring forced neighbor jump', () {
       grid = Grid(5, 5, matrix: [
         [0, 0, 0, 0, 0],
         [0, 0, 1, 0, 0], // Obstacle at (2, 1)
         [0, 0, 0, 0, 0],
         [0, 1, 0, 0, 0], // Obstacle at (1, 3)
         [0, 0, 0, 0, 0],
       ]);
       final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
       // Path from (0,2) to (3,2)
       // Moving right from (0,2). At (1,2), obstacle at (1,3) forces check at (2,3).
       // If (2,3) is walkable, (1,2) is NOT a jump point yet.
       // At (2,2), obstacle at (2,1) forces check at (3,1). If walkable, (2,2) is jump point.
       // Let's trace: (0,2) -> jump right -> hits wall? No. Forced neighbor?
       // At (1,2): Wall below at (1,3)? No. Wall above at (1,1)? No.
       // At (2,2): Wall below at (2,3)? No. Wall above at (2,1)? YES. Check (3,1). Walkable. (2,2) is jump point.
       // Path: (0,2) -> (2,2) -> (3,2) ?
       final path = finder.findPath(0, 2, 3, 2, grid);

       expect(path, isNotEmpty);
       expect(path.first.x, equals(0)); expect(path.first.y, equals(2));
       expect(path.last.x, equals(3)); expect(path.last.y, equals(2));
       expect(pathMatches(path, [[0,2], [2,2], [3,2]]), isTrue, reason: 'Path: ${printPath(path)}');
       expect(path.length, equals(3));
     });


    test('returns empty list when no path exists (blocked)', () {
      grid = Grid(3, 3, matrix: [
        [0, 1, 0],
        [0, 1, 0],
        [0, 1, 0], // Wall blocking path
      ]);
      final finder = OrthogonalJumpPointFinder();
      final path = finder.findPath(0, 1, 2, 1, grid);
      expect(path, isEmpty);
    });

     test('returns empty list when start node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[1, 0, 0], [0, 0, 0], [0, 0, 0]]);
       final finder = OrthogonalJumpPointFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

      test('returns empty list when end node is unwalkable', () {
       grid = Grid(3, 3, matrix: [[0, 0, 0], [0, 0, 0], [0, 0, 1]]);
       final finder = OrthogonalJumpPointFinder();
       final path = finder.findPath(0, 0, 2, 2, grid);
       expect(path, isEmpty);
     });

     test('returns empty list when goal is surrounded', () {
       grid = Grid(3, 3, matrix: [
         [0, 1, 0],
         [1, 0, 1], // Goal at (1,1) surrounded by walls
         [0, 1, 0],
       ]);
       final finder = OrthogonalJumpPointFinder();
       final path = finder.findPath(0, 0, 1, 1, grid); // Start at (0,0)
       expect(path, isEmpty);
     });

      test('handles start == end', () {
        grid = Grid(3, 3);
        final finder = OrthogonalJumpPointFinder();
        final path = finder.findPath(1, 1, 1, 1, grid);
        expect(path, isNotEmpty);
        expect(path.length, equals(1));
        expect(pathMatches(path, [[1,1]]), isTrue);
      });

       test('ignores node weights (finds shortest step path)', () {
         grid = Grid(3, 3);
         grid.setWeightAt(1, 1, 10.0); // Expensive center node
         // Path from (0,1) to (2,1)
         // Orthogonal JPS ignores weights and finds the direct path (0,1)->(2,1)

         final finder = OrthogonalJumpPointFinder();
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
          final finder = OrthogonalJumpPointFinder(heuristic: Heuristics.manhattan);
          final path = finder.findPath(0, 0, 9, 9, grid);

          expect(path, isNotEmpty);
          expect(path.first.x, equals(0)); expect(path.first.y, equals(0));
          expect(path.last.x, equals(9)); expect(path.last.y, equals(9));
          // Check path doesn't go through walls (value 1)
          for (final node in path) {
            expect(grid.isWalkableAt(node.x, node.y), isTrue);
          }
          print('Maze Path (Orthogonal JPS): ${printPath(path)}');
          // Path should only contain jump points and start/end
          expect(path.length, lessThan(20)); // Should be efficient
        });

  });
}
