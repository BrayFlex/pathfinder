import 'package:pathfinder/pathfinder.dart';

// --- Bi-directional BFS Pathing Algorithm ---
// Explanation:
// Bi-directional Breadth-First Search (Bi-BFS) performs two BFS searches
// simultaneously, one from the start and one from the end, using FIFO queues.
// It explores level by level from both ends.
//
// 1. Setup: Define the grid, obstacles, start, and end points.
//
// 2. Finder Creation: Instantiate BiBreadthFirstFinder. Movement rules apply,
//    but heuristics and weights are ignored.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm alternates expanding
//    one level from the start queue and one level from the end queue. It stops
//    as soon as a node expanded by one search is found to have already been
//    visited by the other search.
//
// 4. Result: Because BFS explores layer by layer, the first meeting point
//    guarantees the shortest path in terms of the number of steps (nodes).
//    Bi-BFS is often significantly faster than unidirectional BFS on large grids
//    as the search radius from each end is smaller. Like BFS, it ignores costs.

void main() {
  // --- 1. Setup ---
  print("--- Bi-directional BFS Finder Example ---");

  // Define grid dimensions
  final int gridWidth = 10;
  final int gridHeight = 10;

  // Define a matrix representing the grid layout
  // 0 = walkable, 1 = obstacle
  // Use the same grid as A* example for comparison
  final List<List<int>> matrix = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 1, 1, 1, 1, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  // Create the Grid object
  final grid = Grid(gridWidth, gridHeight, matrix: matrix);
  print("Created ${gridWidth}x$gridHeight grid.");
  print("Grid Matrix (1=obstacle):");
  matrix.forEach((row) => print(row));


  // Define start and end coordinates
  final int startX = 1;
  final int startY = 5;
  final int endX = 8;
  final int endY = 2;
  print("\nStart Node: ($startX, $startY)");
  print("End Node: ($endX, $endY)");

  // --- 2. Create BiBreadthFirstFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  // Heuristics and weights are ignored by BFS

  print("\nCreating BiBreadthFirstFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  (Note: Heuristics and weights are ignored)");

  // Instantiate the BiBreadthFirstFinder
  final finder = BiBreadthFirstFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    // heuristic and weight parameters are inherited but ignored
  );

  // --- 3. Find the Path ---

  print("\nFinding path...");
  // Use the finder to calculate the path
  // The result is a list of Node objects representing the path found
  final List<Node> path = finder.findPath(startX, startY, endX, endY, grid);

  // --- 4. Output / Verification ---

  if (path.isEmpty) {
    print("\nNo path found!");
  } else {
    print("\nPath found! Length: ${path.length} steps.");
    print("Path Coordinates (x, y):");
    // Print the coordinates of each node in the path
    final pathCoords = path.map((node) => '(${node.x}, ${node.y})').join(' -> ');
    print(pathCoords);

    // Optional: Visualize the path on the grid
    print("\nGrid with Path (*=path, S=start, E=end):");
    final List<List<String>> displayGrid = List.generate(gridHeight,
        (y) => List.generate(gridWidth, (x) => matrix[y][x] == 1 ? '▓' : '.'));

    for (final node in path) {
      if (node.x == startX && node.y == startY) {
        displayGrid[node.y][node.x] = 'S';
      } else if (node.x == endX && node.y == endY) {
        displayGrid[node.y][node.x] = 'E';
      } else {
        displayGrid[node.y][node.x] = '*';
      }
    }
    displayGrid.forEach((row) => print(row.join(' ')));
  }
  print("----------------------------------");
}