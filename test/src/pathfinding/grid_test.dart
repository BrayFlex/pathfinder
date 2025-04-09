import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart';

// Helper to check if a list of nodes contains a node at specific coordinates
bool containsNodeAt(List<Node> nodes, int x, int y) {
  return nodes.any((node) => node.x == x && node.y == y);
}

void main() {
  group('Grid', () {
    const width = 5;
    const height = 4;

    group('Constructor', () {
      test('initializes with correct dimensions and default values', () {
        final grid = Grid(width, height);
        expect(grid.width, equals(width));
        expect(grid.height, equals(height));
        // Check a few nodes for default state
        final node00 = grid.getNodeAt(0, 0);
        expect(node00.x, equals(0));
        expect(node00.y, equals(0));
        expect(node00.isWalkable, isTrue);
        expect(node00.weight, equals(1.0));

        final nodeMid = grid.getNodeAt(2, 1);
        expect(nodeMid.isWalkable, isTrue);
        expect(nodeMid.weight, equals(1.0));

        final nodeLast = grid.getNodeAt(width - 1, height - 1);
        expect(nodeLast.isWalkable, isTrue);
        expect(nodeLast.weight, equals(1.0));
      });

      test('initializes with custom default weight', () {
         final grid = Grid(width, height, defaultWeight: 2.5);
         expect(grid.getNodeAt(1, 1).weight, equals(2.5));
         expect(grid.getNodeAt(3, 2).weight, equals(2.5));
      });

      test('initializes with matrix correctly', () {
        final matrix = [
          [0, 0, 1, 0, 0], // Row 0 (y=0)
          [0, 1, 0, 0, 0], // Row 1 (y=1)
          [0, 0, 0, 1, 1], // Row 2 (y=2)
          [0, 0, 0, 0, 0], // Row 3 (y=3)
        ];
        final grid = Grid(width, height, matrix: matrix);

        expect(grid.isWalkableAt(0, 0), isTrue);
        expect(grid.isWalkableAt(2, 0), isFalse); // Obstacle
        expect(grid.isWalkableAt(1, 1), isFalse); // Obstacle
        expect(grid.isWalkableAt(2, 1), isTrue);
        expect(grid.isWalkableAt(3, 2), isFalse); // Obstacle
        expect(grid.isWalkableAt(4, 2), isFalse); // Obstacle
        expect(grid.isWalkableAt(1, 3), isTrue);
        // Check default weight is still applied
        expect(grid.getNodeAt(0, 0).weight, equals(1.0));
      });

      test('throws ArgumentError for non-positive dimensions', () {
        expect(() => Grid(0, height), throwsArgumentError);
        expect(() => Grid(width, 0), throwsArgumentError);
        expect(() => Grid(-1, height), throwsArgumentError);
        expect(() => Grid(width, -1), throwsArgumentError);
      });

       test('throws ArgumentError for invalid default weight', () {
        expect(() => Grid(width, height, defaultWeight: 0.9), throwsArgumentError);
        expect(() => Grid(width, height, defaultWeight: 0.0), throwsArgumentError);
        expect(() => Grid(width, height, defaultWeight: -1.0), throwsArgumentError);
        // Weight 1.0 should be allowed
        expect(() => Grid(width, height, defaultWeight: 1.0), returnsNormally);
      });

      test('throws ArgumentError for matrix dimension mismatch', () {
        final wrongHeightMatrix = [[0,0],[0,0]]; // Height 2 != 4
        expect(() => Grid(2, height, matrix: wrongHeightMatrix), throwsArgumentError);

        final wrongWidthMatrix = [[0,0],[0,0],[0,0],[0,0]]; // Width 2 != 5
         expect(() => Grid(width, height, matrix: wrongWidthMatrix), throwsArgumentError);

         final inconsistentWidthMatrix = [[0,0,0,0,0],[0,0,0],[0,0,0,0,0],[0,0,0,0,0]];
         expect(() => Grid(width, height, matrix: inconsistentWidthMatrix), throwsArgumentError);
      });
    });

    group('getNodeAt', () {
       late Grid grid;
       setUp(() => grid = Grid(width, height));

       test('returns correct node for valid coordinates', () {
         final node = grid.getNodeAt(2, 1);
         expect(node.x, equals(2));
         expect(node.y, equals(1));
       });

       test('throws RangeError for out-of-bounds coordinates', () {
         expect(() => grid.getNodeAt(-1, 1), throwsRangeError);
         expect(() => grid.getNodeAt(width, 1), throwsRangeError);
         expect(() => grid.getNodeAt(1, -1), throwsRangeError);
         expect(() => grid.getNodeAt(1, height), throwsRangeError);
       });
    });

     group('isInside', () {
       late Grid grid;
       setUp(() => grid = Grid(width, height));

       test('returns true for coordinates inside grid', () {
         expect(grid.isInside(0, 0), isTrue);
         expect(grid.isInside(width - 1, height - 1), isTrue);
         expect(grid.isInside(2, 1), isTrue);
       });

       test('returns false for coordinates outside grid', () {
         expect(grid.isInside(-1, 1), isFalse);
         expect(grid.isInside(width, 1), isFalse);
         expect(grid.isInside(1, -1), isFalse);
         expect(grid.isInside(1, height), isFalse);
         expect(grid.isInside(width, height), isFalse);
       });
    });

     group('isWalkableAt', () {
       final matrix = [
          [0, 1], // Row 0
          [0, 0], // Row 1
       ];
       late Grid grid;
       setUp(() => grid = Grid(2, 2, matrix: matrix));

       test('returns true for walkable node inside grid', () {
         expect(grid.isWalkableAt(0, 0), isTrue);
         expect(grid.isWalkableAt(0, 1), isTrue);
         expect(grid.isWalkableAt(1, 1), isTrue);
       });

        test('returns false for unwalkable node inside grid', () {
         expect(grid.isWalkableAt(1, 0), isFalse);
       });

       test('returns false for coordinates outside grid', () {
         expect(grid.isWalkableAt(-1, 0), isFalse);
         expect(grid.isWalkableAt(0, -1), isFalse);
         expect(grid.isWalkableAt(2, 0), isFalse);
         expect(grid.isWalkableAt(0, 2), isFalse);
       });
    });

     group('setWalkableAt', () {
       late Grid grid;
       setUp(() => grid = Grid(width, height));

       test('sets walkable node to unwalkable', () {
         expect(grid.isWalkableAt(2, 1), isTrue); // Initially walkable
         grid.setWalkableAt(2, 1, false);
         expect(grid.isWalkableAt(2, 1), isFalse);
       });

       test('sets unwalkable node to walkable', () {
         grid.setWalkableAt(3, 2, false); // Make it unwalkable first
         expect(grid.isWalkableAt(3, 2), isFalse);
         grid.setWalkableAt(3, 2, true);
         expect(grid.isWalkableAt(3, 2), isTrue);
       });

       test('throws RangeError for out-of-bounds coordinates', () {
          expect(() => grid.setWalkableAt(-1, 1, false), throwsRangeError);
          expect(() => grid.setWalkableAt(width, 1, false), throwsRangeError);
          expect(() => grid.setWalkableAt(1, -1, false), throwsRangeError);
          expect(() => grid.setWalkableAt(1, height, false), throwsRangeError);
       });
    });

     group('setWeightAt', () {
       late Grid grid;
       setUp(() => grid = Grid(width, height));

       test('sets weight for a node', () {
         expect(grid.getNodeAt(2, 1).weight, equals(1.0)); // Default weight
         grid.setWeightAt(2, 1, 5.5);
         expect(grid.getNodeAt(2, 1).weight, equals(5.5));
       });

        test('allows setting weight to 1.0', () {
         grid.setWeightAt(2, 1, 5.5);
         expect(grid.getNodeAt(2, 1).weight, equals(5.5));
         grid.setWeightAt(2, 1, 1.0);
         expect(grid.getNodeAt(2, 1).weight, equals(1.0));
       });

       test('throws RangeError for out-of-bounds coordinates', () {
          expect(() => grid.setWeightAt(-1, 1, 2.0), throwsRangeError);
          expect(() => grid.setWeightAt(width, 1, 2.0), throwsRangeError);
          expect(() => grid.setWeightAt(1, -1, 2.0), throwsRangeError);
          expect(() => grid.setWeightAt(1, height, 2.0), throwsRangeError);
       });

        test('throws ArgumentError for weight less than 1.0', () {
          expect(() => grid.setWeightAt(1, 1, 0.99), throwsArgumentError);
          expect(() => grid.setWeightAt(1, 1, 0.0), throwsArgumentError);
          expect(() => grid.setWeightAt(1, 1, -1.0), throwsArgumentError);
       });
    });

    group('getNeighbors', () {
      // Grid setup for neighbor tests: 3x3
      // W = Walkable, O = Obstacle
      //   0 1 2 (x)
      // 0 W W W
      // 1 W O W
      // 2 W W W
      // (y)
      late Grid grid;
      late Node centerNode; // (1,1) - Obstacle
      late Node walkableNode; // (0,0)
      late Node edgeNode; // (0,1)
      late Node cornerNode; // (2,2)

      setUp(() {
         final matrix = [
           [0, 0, 0],
           [0, 1, 0], // Obstacle at (1,1)
           [0, 0, 0],
         ];
         grid = Grid(3, 3, matrix: matrix);
         centerNode = grid.getNodeAt(1, 1);
         walkableNode = grid.getNodeAt(0, 0);
         edgeNode = grid.getNodeAt(0, 1);
         cornerNode = grid.getNodeAt(2, 2);
      });

      test('cardinal neighbors only (allowDiagonal: false)', () {
        final neighbors = grid.getNeighbors(walkableNode); // Node (0,0)
        expect(neighbors.length, equals(2));
        expect(containsNodeAt(neighbors, 1, 0), isTrue);
        expect(containsNodeAt(neighbors, 0, 1), isTrue);

        final edgeNeighbors = grid.getNeighbors(edgeNode); // Node (0,1)
        expect(edgeNeighbors.length, equals(2)); // (0,0), (0,2) - blocked by (1,1)
        expect(containsNodeAt(edgeNeighbors, 0, 0), isTrue);
        expect(containsNodeAt(edgeNeighbors, 0, 2), isTrue);

         final cornerNeighbors = grid.getNeighbors(cornerNode); // Node (2,2)
         expect(cornerNeighbors.length, equals(2)); // (1,2), (2,1)
         expect(containsNodeAt(cornerNeighbors, 1, 2), isTrue);
         expect(containsNodeAt(cornerNeighbors, 2, 1), isTrue);
      });

       test('diagonal neighbors allowed (dontCrossCorners: false)', () {
         final neighbors = grid.getNeighbors(walkableNode, allowDiagonal: true); // Node (0,0)
         // Expect (1,0), (0,1), (1,1 is Obstacle)
         expect(neighbors.length, equals(2)); // (1,0), (0,1)
         expect(containsNodeAt(neighbors, 1, 0), isTrue);
         expect(containsNodeAt(neighbors, 0, 1), isTrue);

         final edgeNeighbors = grid.getNeighbors(edgeNode, allowDiagonal: true); // Node (0,1)
         // Expect (0,0), (0,2), (1,0), (1,2) - (1,1) is obstacle
         expect(edgeNeighbors.length, equals(4));
         expect(containsNodeAt(edgeNeighbors, 0, 0), isTrue);
         expect(containsNodeAt(edgeNeighbors, 0, 2), isTrue);
         expect(containsNodeAt(edgeNeighbors, 1, 0), isTrue); // Diagonal allowed
         expect(containsNodeAt(edgeNeighbors, 1, 2), isTrue); // Diagonal allowed

         final cornerNeighbors = grid.getNeighbors(cornerNode, allowDiagonal: true); // Node (2,2)
         // Expect (1,2), (2,1), (1,1 is Obstacle)
         expect(cornerNeighbors.length, equals(2));
         expect(containsNodeAt(cornerNeighbors, 1, 2), isTrue);
         expect(containsNodeAt(cornerNeighbors, 2, 1), isTrue);
       });

        test('diagonal neighbors allowed (dontCrossCorners: true)', () {
         final neighbors = grid.getNeighbors(walkableNode, allowDiagonal: true, dontCrossCorners: true); // Node (0,0)
         // Expect (1,0), (0,1). Diagonal (1,1) blocked because (1,1) is obstacle.
         expect(neighbors.length, equals(2));
         expect(containsNodeAt(neighbors, 1, 0), isTrue);
         expect(containsNodeAt(neighbors, 0, 1), isTrue);

         final edgeNeighbors = grid.getNeighbors(edgeNode, allowDiagonal: true, dontCrossCorners: true); // Node (0,1)
         // Expect (0,0), (0,2). Diagonal (1,0) allowed (needs 0,0 and 1,0). Diagonal (1,2) allowed (needs 0,2 and 1,2).
         // But (1,1) is obstacle, blocking crossing.
         // Let's re-evaluate:
         // N=(0,0) yes, S=(0,2) yes, E=(1,1) NO, W=N/A
         // NE: needs N and E. E is blocked. NO. (Target 1,0 is walkable)
         // SE: needs S and E. E is blocked. NO. (Target 1,2 is walkable)
         // SW: N/A
         // NW: N/A
         // So only cardinals (0,0) and (0,2) should be returned.
         expect(edgeNeighbors.length, equals(2));
         expect(containsNodeAt(edgeNeighbors, 0, 0), isTrue);
         expect(containsNodeAt(edgeNeighbors, 0, 2), isTrue);


         final cornerNeighbors = grid.getNeighbors(cornerNode, allowDiagonal: true, dontCrossCorners: true); // Node (2,2)
         // Expect (1,2), (2,1). Diagonal (1,1) blocked because (1,1) is obstacle.
         expect(cornerNeighbors.length, equals(2));
         expect(containsNodeAt(cornerNeighbors, 1, 2), isTrue);
         expect(containsNodeAt(cornerNeighbors, 2, 1), isTrue);

         // Test node (2,0)
         final node20 = grid.getNodeAt(2,0);
         final neighbors20 = grid.getNeighbors(node20, allowDiagonal: true, dontCrossCorners: true);
         // N=N/A, S=(2,1) yes, E=N/A, W=(1,0) yes
         // NE: N/A
         // SE: needs S and E. E=N/A. NO.
         // SW: needs S and W. S=(2,1) yes, W=(1,0) yes. Target (1,1) is OBSTACLE. NO.
         // NW: needs N and W. N=N/A. NO.
         // Expect only cardinals (1,0) and (2,1)
         expect(neighbors20.length, equals(2));
         expect(containsNodeAt(neighbors20, 1, 0), isTrue);
         expect(containsNodeAt(neighbors20, 2, 1), isTrue);
       });

       test('returns empty list for unwalkable node', () {
          final neighbors = grid.getNeighbors(centerNode, allowDiagonal: true); // Node (1,1) is obstacle
          expect(neighbors, isEmpty);
       });
    });

     group('clone', () {
       late Grid originalGrid;
       late Grid clonedGrid;

       setUp(() {
          final matrix = [ [0, 1], [0, 0] ];
          originalGrid = Grid(2, 2, matrix: matrix, defaultWeight: 1.5);
          originalGrid.setWeightAt(0, 1, 3.0);
          clonedGrid = originalGrid.clone();
       });

       test('cloned grid has same dimensions and properties', () {
         expect(clonedGrid.width, equals(originalGrid.width));
         expect(clonedGrid.height, equals(originalGrid.height));
         expect(clonedGrid.isWalkableAt(0, 0), isTrue);
         expect(clonedGrid.isWalkableAt(1, 0), isFalse); // Obstacle
         expect(clonedGrid.isWalkableAt(0, 1), isTrue);
         expect(clonedGrid.getNodeAt(0, 0).weight, equals(1.5)); // Default weight
         expect(clonedGrid.getNodeAt(0, 1).weight, equals(3.0)); // Set weight
       });

       test('nodes in cloned grid are different instances', () {
         final originalNode = originalGrid.getNodeAt(0, 0);
         final clonedNode = clonedGrid.getNodeAt(0, 0);
         expect(identical(originalNode, clonedNode), isFalse);
       });

       test('modifying cloned grid does not affect original', () {
         clonedGrid.setWalkableAt(0, 0, false);
         clonedGrid.setWeightAt(0, 1, 10.0);

         expect(originalGrid.isWalkableAt(0, 0), isTrue); // Original unchanged
         expect(originalGrid.getNodeAt(0, 1).weight, equals(3.0)); // Original unchanged
       });

        test('modifying original grid does not affect clone', () {
         originalGrid.setWalkableAt(0, 1, false);
         originalGrid.setWeightAt(0, 0, 5.0);

         expect(clonedGrid.isWalkableAt(0, 1), isTrue); // Clone unchanged
         expect(clonedGrid.getNodeAt(0, 0).weight, equals(1.5)); // Clone unchanged
       });
    });

  });
}
