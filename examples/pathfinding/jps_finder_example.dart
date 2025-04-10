import 'package:pathfinder/pathfinder.dart';

// --- Jump Point Search (JPS) Pathing Algorithm ---
// Explanation:
// Jump Point Search (JPS) is an optimization of A* for uniform-cost grids.
// It drastically reduces the number of nodes explored by identifying and jumping
// between "jump points" – locations where the optimal path might change direction
// due to obstacles or "forced neighbors".
//
// 1. Setup: Define the grid (assuming uniform cost), obstacles, start, and end.
//
// 2. Finder Creation: Instantiate JumpPointFinder. An appropriate heuristic
//    (like Octile or Diagonal distance) is needed. JPS handles movement rules internally.
//
// 3. Pathfinding: Call finder.findPath(). JPS performs an A*-like search but
//    instead of expanding all neighbors, it "jumps" straight or diagonally,
//    only adding actual jump points (goal, nodes with forced neighbors, etc.)
//    to the open list.
//
// 4. Result: JPS returns a path containing the start node, end node, and the
//    intermediate jump points identified. This path represents the shortest path
//    but doesn't include every single grid cell along the straight/diagonal lines
//    between jump points. It's significantly faster than A* on uniform grids,
//    especially in open areas, due to exploring far fewer nodes.

void main() {
  // --- 1. Setup ---
  print("--- Jump Point Search (JPS) Finder Example ---");

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
  // JPS assumes uniform cost, so node weights are typically ignored by its core logic.
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

  // --- 2. Create JumpPointFinder ---

  // Configure the finder
  // JPS inherently requires diagonal checking capabilities.
  // Heuristic should match diagonal movement (Octile/Diagonal).
  final HeuristicFunction heuristic = Heuristics.octile;
  final double weight = 1.0;

  print("\nCreating JumpPointFinder with:");
  print("  Heuristic: Octile Distance");
  print("  Weight: $weight");
  print("  (Note: Assumes uniform grid cost, uses diagonal movement rules internally)");

  // Instantiate the JumpPointFinder
  final finder = JumpPointFinder(
    heuristic: heuristic,
    weight: weight,
    // allowDiagonal and dontCrossCorners are handled internally by JPS logic
  );

  // --- 3. Find the Path ---

  print("\nFinding path...");
  // Use the finder to calculate the path
  // The result is a list of Node objects representing the path found
  // This path typically contains only the start, end, and jump point nodes.
  final List<Node> path = finder.findPath(startX, startY, endX, endY, grid);

  // --- 4. Output / Verification ---

  if (path.isEmpty) {
    print("\nNo path found!");
  } else {
    print("\nPath found! Length: ${path.length} nodes (Jump Points + Start/End).");
    // Calculate path cost (assuming uniform cost for JPS)
    double pathCost = 0;
    for (int i = 1; i < path.length; i++) {
       // Use the finder instance to get movement cost (Octile distance for JPS)
       pathCost += finder.getMovementCost(path[i-1], path[i]);
    }
    print("Path Cost (approx based on jump points): ${pathCost.toStringAsFixed(2)}");

    print("Path Coordinates (x, y):");
    // Print the coordinates of each node in the path
    final pathCoords = path.map((node) => '(${node.x}, ${node.y})').join(' -> ');
    print(pathCoords);

    // Optional: Visualize the path on the grid
    // Note: JPS path only includes jump points, not every step.
    // Visualization might look sparse compared to A*.
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