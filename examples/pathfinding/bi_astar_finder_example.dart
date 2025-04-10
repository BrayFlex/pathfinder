import 'package:pathfinder/pathfinder.dart';

// --- Bi-directional A* Pathing Algorithm ---
// Explanation:
// Bi-directional A* (BiA*) performs two A* searches simultaneously: one forward
// from the start node and one backward from the end node. The search stops when
// the two search frontiers meet, or when a termination condition based on the
// costs of the best nodes in both open lists is met.
//
// 1. Setup: Define the grid, obstacles, start, and end points.
//
// 2. Finder Creation: Instantiate BiAStarFinder. It uses the same heuristic
//    (estimating distance to the *other* search's origin) and movement rules
//    for both searches.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm maintains two open lists
//    (priority queues) and alternates expanding nodes from the start and end searches.
//    It checks if expanded nodes have been visited by the opposite search.
//
// 4. Result: When the searches meet, the algorithm reconstructs the path by
//    combining the path from the start to the meeting point and the path from
//    the end to the meeting point. BiA* often explores significantly fewer nodes
//    than unidirectional A*, especially in open areas, while still guaranteeing
//    the shortest path (given an admissible heuristic).

void main() {
  // --- 1. Setup ---
  print("--- Bi-directional A* Finder Example ---");

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

  // --- 2. Create BiAStarFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  final HeuristicFunction heuristic = Heuristics.diagonal; // Must be consistent for both directions
  final double weight = 1.0;

  print("\nCreating BiAStarFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  Heuristic: Diagonal Distance");
  print("  Weight: $weight");

  // Instantiate the BiAStarFinder
  final finder = BiAStarFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    heuristic: heuristic,
    weight: weight,
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