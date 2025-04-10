import 'package:pathfinder/pathfinder.dart';

// --- BestFirst Pathing Algorithm ---
// Explanation:
// Best-First Search is an informed search algorithm that greedily explores the
// path that appears closest to the goal based solely on the heuristic estimate (h-cost).
// It ignores the actual cost incurred so far (g-cost) when choosing which node
// to explore next.
//
// 1. Setup: We define the grid, obstacles, start, and end points, just like A*.
//
// 2. Finder Creation: We instantiate BestFirstFinder. The heuristic function is
//    the primary driver of the search. Diagonal movement options are still relevant
//    for determining neighbors.
//
// 3. Pathfinding: We call finder.findPath(). The algorithm uses a priority queue
//    ordered only by the heuristic cost (h-cost) to the end node. It expands the
//    node that seems closest to the goal.
//
// 4. Result: The findPath method returns the first path found connecting start
//    and end. Because it prioritizes the heuristic, Best-First can be very fast
//    but is **not guaranteed** to find the shortest path. It might find a longer
//    path if the heuristic is misleading in certain areas of the grid. Compare the
//    output path length and shape to the A* example using the same grid.

void main() {
  // --- 1. Setup ---
  print("--- Best-First Finder Example ---");

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

  // --- 2. Create BestFirstFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  // Heuristic is crucial for Best-First's direction
  final HeuristicFunction heuristic = Heuristics.diagonal;
  // Weight is ignored by BestFirstFinder's core logic but inherited

  print("\nCreating BestFirstFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  Heuristic: Diagonal Distance");

  // Instantiate the BestFirstFinder
  final finder = BestFirstFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    heuristic: heuristic,
    // weight: weight, // Weight is ignored
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