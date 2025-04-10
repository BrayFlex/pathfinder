import 'package:pathfinder/pathfinder.dart';

// --- OrthogonalJPS Pathing Algorithm ---
// Explanation:
// Orthogonal Jump Point Search is a variant of JPS restricted to only cardinal
// (horizontal and vertical) movements. It applies the same principle of jumping
// between key points but defines jump points based on forced neighbors arising
// from obstacles adjacent to the orthogonal direction of travel.
//
// 1. Setup: Define the grid (assuming uniform cost), obstacles, start, and end.
//
// 2. Finder Creation: Instantiate OrthogonalJumpPointFinder. The Manhattan
//    heuristic is appropriate. Diagonal movement is disabled by the finder itself.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm performs an A*-like search,
//    jumping cardinally and identifying orthogonal jump points (goal, nodes with
//    forced neighbors specific to cardinal movement).
//
// 4. Result: The finder returns a path containing the start, end, and orthogonal
//    jump points. This path represents the shortest path restricted to cardinal
//    movements only. Like standard JPS, it explores fewer nodes than A* or Dijkstra
//    on uniform grids.

void main() {
  // --- 1. Setup ---
  print("--- Orthogonal JPS Finder Example ---");

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
  // Assumes uniform cost
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

  // --- 2. Create OrthogonalJumpPointFinder ---

  // Configure the finder
  // Orthogonal JPS only uses cardinal moves. Manhattan heuristic is suitable.
  final HeuristicFunction heuristic = Heuristics.manhattan;
  final double weight = 1.0;

  print("\nCreating OrthogonalJumpPointFinder with:");
  print("  Heuristic: Manhattan Distance");
  print("  Weight: $weight");
  print("  (Note: Movement is restricted to orthogonal directions)");

  // Instantiate the OrthogonalJumpPointFinder
  final finder = OrthogonalJumpPointFinder(
    heuristic: heuristic,
    weight: weight,
    // allowDiagonal and dontCrossCorners are forced to false by the constructor
  );

  // --- 3. Find the Path ---

  print("\nFinding path...");
  // Use the finder to calculate the path
  // The result is a list of Node objects representing the path found
  // This path contains only the start, end, and orthogonal jump point nodes.
  final List<Node> path = finder.findPath(startX, startY, endX, endY, grid);

  // --- 4. Output / Verification ---

  if (path.isEmpty) {
    print("\nNo path found!");
  } else {
    print("\nPath found! Length: ${path.length} nodes (Jump Points + Start/End).");
    // Calculate path cost (using Manhattan distance between jump points)
    double pathCost = 0;
    for (int i = 1; i < path.length; i++) {
       // Use the finder instance to get movement cost (Manhattan distance for Orthogonal JPS)
       pathCost += finder.getMovementCost(path[i-1], path[i]);
    }
    print("Path Cost (Manhattan distance along jump points): ${pathCost.toStringAsFixed(2)}");

    print("Path Coordinates (x, y):");
    // Print the coordinates of each node in the path
    final pathCoords = path.map((node) => '(${node.x}, ${node.y})').join(' -> ');
    print(pathCoords);

    // Optional: Visualize the path on the grid
    // Note: Path only includes jump points.
    print("\nGrid with Path (*=jump points, S=start, E=end):");
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