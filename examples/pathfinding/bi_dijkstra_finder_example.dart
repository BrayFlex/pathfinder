import 'package:pathfinder/pathfinder.dart';

// --- Bi-directional Dijkstra Pathing Algorithm ---
// Explanation:
// Bi-directional Dijkstra performs two Dijkstra searches simultaneously: one
// forward from the start and one backward from the end. Both searches prioritize
// nodes based solely on the accumulated cost (g-cost) from their respective origins.
// It ignores heuristics.
//
// 1. Setup: Define the grid, obstacles, start, and end points. Node weights
//    (representing terrain cost) can be set on the grid and will be considered.
//
// 2. Finder Creation: Instantiate BiDijkstraFinder. Movement rules apply.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm maintains two priority
//    queues ordered by g-cost and alternates expanding nodes from each search.
//    It stops when the frontiers meet or a termination condition based on the
//    sum of minimum costs in both queues is met.
//
// 4. Result: Bi-Dijkstra guarantees finding the path with the lowest total cost
//    (sum of movement costs and node weights). Like BiA*, it often explores fewer
//    nodes than its unidirectional counterpart. The path found will correctly
//    account for any varying node weights on the grid.

void main() {
  // --- 1. Setup ---
  print("--- Bi-directional Dijkstra Finder Example ---");

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
  // Optionally add weights to some nodes to see Dijkstra's behavior
  final grid = Grid(gridWidth, gridHeight, matrix: matrix);
  // Example: Make a cell more costly to traverse
  // grid.setWeightAt(5, 4, 5.0); // Node (5,4) now has weight 5

  print("Created ${gridWidth}x$gridHeight grid.");
  print("Grid Matrix (1=obstacle):");
  matrix.forEach((row) => print(row));
  // if (grid.getNodeAt(5, 4).weight > 1.0) print("Note: Node (5,4) has extra weight.");


  // Define start and end coordinates
  final int startX = 1;
  final int startY = 5;
  final int endX = 8;
  final int endY = 2;
  print("\nStart Node: ($startX, $startY)");
  print("End Node: ($endX, $endY)");

  // --- 2. Create BiDijkstraFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  // Heuristics and weights are ignored by Dijkstra

  print("\nCreating BiDijkstraFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  (Note: Heuristics are ignored, Node weights are considered)");

  // Instantiate the BiDijkstraFinder
  final finder = BiDijkstraFinder(
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
    // Calculate path cost (sum of weights of nodes except start)
    double pathCost = 0;
    for (int i = 1; i < path.length; i++) {
       // Call getMovementCost on the finder instance
       pathCost += grid.getNodeAt(path[i].x, path[i].y).weight * finder.getMovementCost(path[i-1], path[i]);
    }
    print("Path Cost: ${pathCost.toStringAsFixed(2)}"); // Show calculated cost

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