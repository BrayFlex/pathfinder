import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';
import 'package:pathfinder/src/pathfinding/pathfinding_utils.dart';
import 'package:pathfinder/src/pathfinding/heuristics.dart'; // Added import

// Helper to create a simple path from coordinates
List<Node> createPath(List<List<int>> coords) {
  return coords.map((c) => Node(c[0], c[1])).toList();
}

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
  group('PathfindingUtils', () {

    group('compressPath', () {
      test('returns copy for path < 3 nodes', () {
        final path0 = createPath([]);
        final path1 = createPath([[0,0]]);
        final path2 = createPath([[0,0], [1,1]]);
        expect(PathfindingUtils.compressPath(path0), equals(path0));
        expect(PathfindingUtils.compressPath(path1), equals(path1));
        expect(PathfindingUtils.compressPath(path2), equals(path2));
        // Ensure it's a copy, not the same instance (for paths > 0)
        expect(identical(PathfindingUtils.compressPath(path1), path1), isFalse);
        expect(identical(PathfindingUtils.compressPath(path2), path2), isFalse);
      });

      test('compresses straight horizontal path', () {
        final path = createPath([[0,0], [1,0], [2,0], [3,0], [4,0]]);
        final compressed = PathfindingUtils.compressPath(path);
        expect(pathMatches(compressed, [[0,0], [4,0]]), isTrue, reason: printPath(compressed));
      });

      test('compresses straight vertical path', () {
        final path = createPath([[1,0], [1,1], [1,2], [1,3]]);
        final compressed = PathfindingUtils.compressPath(path);
        expect(pathMatches(compressed, [[1,0], [1,3]]), isTrue, reason: printPath(compressed));
      });

      test('compresses straight diagonal path', () {
        final path = createPath([[0,0], [1,1], [2,2], [3,3]]);
        final compressed = PathfindingUtils.compressPath(path);
        expect(pathMatches(compressed, [[0,0], [3,3]]), isTrue, reason: printPath(compressed));
      });

      test('compresses path with single turn', () {
        final path = createPath([[0,0], [1,0], [2,0], [2,1], [2,2]]);
        final compressed = PathfindingUtils.compressPath(path);
        expect(pathMatches(compressed, [[0,0], [2,0], [2,2]]), isTrue, reason: printPath(compressed));
      });

       test('compresses path with multiple turns', () {
        final path = createPath([[0,0], [1,0], [2,0], [2,1], [2,2], [3,2], [4,2]]);
        final compressed = PathfindingUtils.compressPath(path);
        expect(pathMatches(compressed, [[0,0], [2,0], [2,2], [4,2]]), isTrue, reason: printPath(compressed));
      });

       test('compresses path with diagonal turns', () {
         final path = createPath([[0,0], [1,1], [2,2], [3,1], [4,0]]);
         final compressed = PathfindingUtils.compressPath(path);
         expect(pathMatches(compressed, [[0,0], [2,2], [4,0]]), isTrue, reason: printPath(compressed));
       });

        test('handles path doubling back', () {
         final path = createPath([[0,0], [1,0], [2,0], [1,0], [0,0]]);
         final compressed = PathfindingUtils.compressPath(path);
         // Corrected expectation: Keep start (0,0), turn point (2,0), end (0,0).
         // Node (1,0) is removed as it's collinear on the return segment.
         expect(pathMatches(compressed, [[0,0], [2,0], [0,0]]), isTrue, reason: printPath(compressed));
       });
    });

    group('expandPath', () {
       late Grid grid;
       setUp(() => grid = Grid(10, 10)); // Simple empty grid

       test('returns copy for path < 2 nodes', () {
         final path0 = createPath([]);
         final path1 = createPath([[1,1]]);
         expect(PathfindingUtils.expandPath(path0, grid), equals(path0));
         expect(PathfindingUtils.expandPath(path1, grid), equals(path1));
         // Pass grid to expandPath in identical check
         expect(identical(PathfindingUtils.expandPath(path1, grid), path1), isFalse);
       });

       test('expands horizontal path', () {
         final path = createPath([[1,2], [4,2]]);
         final expanded = PathfindingUtils.expandPath(path, grid);
         expect(pathMatches(expanded, [[1,2], [2,2], [3,2], [4,2]]), isTrue, reason: printPath(expanded));
       });

       test('expands vertical path', () {
         final path = createPath([[3,1], [3,4]]);
         final expanded = PathfindingUtils.expandPath(path, grid);
         expect(pathMatches(expanded, [[3,1], [3,2], [3,3], [3,4]]), isTrue, reason: printPath(expanded));
       });

       test('expands diagonal path', () {
         final path = createPath([[1,1], [4,4]]);
         final expanded = PathfindingUtils.expandPath(path, grid);
         expect(pathMatches(expanded, [[1,1], [2,2], [3,3], [4,4]]), isTrue, reason: printPath(expanded));
       });

       test('expands multi-segment path', () {
         final path = createPath([[0,0], [3,0], [3,2]]);
         final expanded = PathfindingUtils.expandPath(path, grid);
         expect(pathMatches(expanded, [[0,0], [1,0], [2,0], [3,0], [3,1], [3,2]]), isTrue, reason: printPath(expanded));
       });

        test('handles adjacent nodes in compressed path', () {
         final path = createPath([[1,1], [1,2], [2,2]]);
         final expanded = PathfindingUtils.expandPath(path, grid);
         expect(pathMatches(expanded, [[1,1], [1,2], [2,2]]), isTrue, reason: printPath(expanded));
       });
    });

     group('smoothenPath', () {
       late Grid grid;

       test('returns copy for path < 3 nodes', () {
         grid = Grid(5, 5);
         final path0 = createPath([]);
         final path1 = createPath([[1,1]]);
         final path2 = createPath([[1,1], [2,2]]);
         expect(PathfindingUtils.smoothenPath(grid, path0), equals(path0));
         expect(PathfindingUtils.smoothenPath(grid, path1), equals(path1));
         expect(PathfindingUtils.smoothenPath(grid, path2), equals(path2));
         expect(identical(PathfindingUtils.smoothenPath(grid, path1), path1), isFalse);
         expect(identical(PathfindingUtils.smoothenPath(grid, path2), path2), isFalse);
       });

       test('smoothes straight path to start and end', () {
         grid = Grid(5, 5);
         final path = createPath([[0,0], [1,0], [2,0], [3,0], [4,0]]);
         final smoothed = PathfindingUtils.smoothenPath(grid, path);
         expect(pathMatches(smoothed, [[0,0], [4,0]]), isTrue, reason: printPath(smoothed));
       });

        test('smoothes diagonal path to start and end', () {
         grid = Grid(5, 5);
         final path = createPath([[0,0], [1,1], [2,2], [3,3], [4,4]]);
         final smoothed = PathfindingUtils.smoothenPath(grid, path);
         expect(pathMatches(smoothed, [[0,0], [4,4]]), isTrue, reason: printPath(smoothed));
       });

       test('smoothes path with simple redundant corner', () {
         grid = Grid(5, 5);
         // Path: (0,0) -> (1,0) -> (2,0) -> (2,1) -> (2,2)
         // Expected: (0,0) -> (2,2) because LOS exists
         final path = createPath([[0,0], [1,0], [2,0], [2,1], [2,2]]);
         final smoothed = PathfindingUtils.smoothenPath(grid, path);
         expect(pathMatches(smoothed, [[0,0], [2,2]]), isTrue, reason: printPath(smoothed));
       });

        test('does not smooth path around obstacle corner', () {
          grid = Grid(5, 5, matrix: [
            [0,0,0,0,0],
            [0,0,1,0,0], // Obstacle at (2,1)
            [0,0,0,0,0],
            [0,0,0,0,0],
            [0,0,0,0,0],
          ]);
          // Path: (1,1) -> (1,0) -> (2,0) -> (3,0) -> (3,1)
          // Expected: (1,1) -> (2,0) -> (3,1)
          final path = createPath([[1,1], [1,0], [2,0], [3,0], [3,1]]);
          final smoothed = PathfindingUtils.smoothenPath(grid, path);
          expect(pathMatches(smoothed, [[1,1], [2,0], [3,1]]), isTrue, reason: printPath(smoothed));
        });

         test('smoothes complex path', () {
           grid = Grid(7, 5);
           // Path: (0,0)->(1,0)->(2,0)->(3,0)->(3,1)->(3,2)->(4,2)->(5,2)->(5,3)->(5,4)->(6,4)
           final path = createPath([
             [0,0],[1,0],[2,0],[3,0], // Straight H
             [3,1],[3,2],             // Straight V
             [4,2],[5,2],             // Straight H
             [5,3],[5,4],             // Straight V
             [6,4]                    // Final H
           ]);
           // Expected: (0,0) -> (6,4) because grid is empty
           final smoothed = PathfindingUtils.smoothenPath(grid, path);
           expect(pathMatches(smoothed, [[0,0], [6,4]]), isTrue, reason: printPath(smoothed));
         });

    });

  });

  group('Heuristics', () {
    test('manhattan calculates correctly', () {
      expect(Heuristics.manhattan(3, 4), equals(7));
      expect(Heuristics.manhattan(0, 0), equals(0));
      expect(Heuristics.manhattan(5, 0), equals(5));
      expect(Heuristics.manhattan(0, 2), equals(2));
    });

    test('euclidean calculates correctly', () {
      expect(Heuristics.euclidean(3, 4), closeTo(5.0, 0.001)); // 3-4-5 triangle
      expect(Heuristics.euclidean(0, 0), equals(0.0));
      expect(Heuristics.euclidean(5, 0), equals(5.0));
      expect(Heuristics.euclidean(0, 2), equals(2.0));
      expect(Heuristics.euclidean(1, 1), closeTo(1.414, 0.001)); // sqrt(2)
    });

     test('octile calculates correctly', () {
       final d = 1.0; // Cost of cardinal move
       final d2 = 1.414; // Approx cost of diagonal move (sqrt(2))
       expect(Heuristics.octile(3, 4), closeTo(d * (4-3) + d2 * 3, 0.001)); // 1*1 + sqrt(2)*3 = 1 + 4.242 = 5.242
       expect(Heuristics.octile(4, 3), closeTo(d * (4-3) + d2 * 3, 0.001)); // Same as above
       expect(Heuristics.octile(0, 0), equals(0.0));
       expect(Heuristics.octile(5, 0), equals(5.0)); // Purely horizontal
       expect(Heuristics.octile(0, 2), equals(2.0)); // Purely vertical
       expect(Heuristics.octile(3, 3), closeTo(d2 * 3, 0.001)); // Purely diagonal = sqrt(2)*3 = 4.242
     });
  });
}
