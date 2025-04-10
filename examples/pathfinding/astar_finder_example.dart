import 'package:pathfinder/pathfinder.dart';

// --- A* Pathing Algorithm ---
// Explanation:
// A* (A-star) is an informed search algorithm used to find the shortest path
// between two points on a graph or grid. It balances the actual cost incurred
// so far (g-cost) with an estimated heuristic cost to the target (h-cost).
// It prioritizes exploring nodes with the lowest combined cost (f-cost = g + h).
//
// 1. Setup: We define a grid with walkable (0) and unwalkable (1) cells,
//    and specify the start and end coordinates.
//
// 2. Finder Creation: We instantiate AStarFinder, configuring options like
//    whether diagonal movement is allowed, corner-crossing rules, the heuristic
//    function (e.g., Manhattan, Diagonal, Euclidean - chosen based on movement rules),
//    and an optional weight for the heuristic.
//
// 3. Pathfinding: We call finder.findPath(), passing the start/end coordinates
//    and the grid. The algorithm explores the grid using a priority queue,
//    expanding nodes with the lowest f-cost until the end node is reached or
//    the queue is empty.
//
// 4. Result: The findPath method returns a list of Node objects representing the
//    shortest path found (or an empty list if no path exists). We print the
//    coordinates of the path nodes and optionally visualize it on the grid.
//    A* guarantees the shortest path if the heuristic is admissible (never
//    overestimates the true cost).

void main() {
  // --- 1. Setup ---
  print("--- A* Finder Example ---");

  // Define grid dimensions
  final int gridWidth = 10;
  final int gridHeight = 10;

  // Define a matrix representing the grid layout
  // 0 = walkable, 1 = obstacle
  final List<List<int>> matrix = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 1, 0, 0, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0], // Clear path below obstacle
    [0, 0, 1, 1, 1, 1, 1, 0, 0, 0], // Another obstacle wall
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 1, 0, 0, 0],
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
  ];

  // Create the Grid object using positional width/height and named matrix
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

  // --- 2. Create AStarFinder ---

  // Configure the finder
  final bool allowDiagonal = true; // Allow diagonal movement
  final bool dontCrossCorners = true; // Prevent cutting corners diagonally
  final HeuristicFunction heuristic = Heuristics.diagonal; // Suitable for diagonal movement
  final double weight = 1.0; // Standard A* weight

  print("\nCreating AStarFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  Heuristic: Diagonal Distance");
  print("  Weight: $weight");

  // Instantiate the AStarFinder
  final finder = AStarFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    heuristic: heuristic,
    weight: weight,
  );

  // --- 3. Find the Path ---

  print("\nFinding path...");
  // Use the finder to calculate the path
  // The result is a list of Node objects representing the path
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