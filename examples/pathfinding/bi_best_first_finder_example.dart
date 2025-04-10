import 'package:pathfinder/pathfinder.dart';

// --- Bi-directional BestFirst Pathing Algorithm ---
// Explanation:
// Bi-directional Best-First Search performs two Best-First searches simultaneously,
// one from the start and one from the end. Both searches greedily expand the node
// that has the lowest heuristic cost (h-cost) to the *other* search's origin.
// The search stops as soon as a node visited by one search is encountered by the other.
//
// 1. Setup: Define the grid, obstacles, start, and end points.
//
// 2. Finder Creation: Instantiate BiBestFirstFinder. The heuristic is the key
//    component driving both searches. Movement rules apply.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm maintains two priority
//    queues ordered by h-cost and alternates expanding nodes from each search.
//    It stops immediately when the frontiers meet.
//
// 4. Result: The algorithm returns the path formed by joining the paths from start
//    and end to the meeting point. Like unidirectional Best-First, this is often
//    very fast but **does not guarantee** finding the shortest path, as it ignores
//    the actual path cost (g-cost). The path found might differ from BiA*.

void main() {
  // --- 1. Setup ---
  print("--- Bi-directional Best-First Finder Example ---");

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

  // --- 2. Create BiBestFirstFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  final HeuristicFunction heuristic = Heuristics.diagonal;
  // Weight is ignored

  print("\nCreating BiBestFirstFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  Heuristic: Diagonal Distance");
  print("  (Note: Weights are ignored)");

  // Instantiate the BiBestFirstFinder
  final finder = BiBestFirstFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    heuristic: heuristic,
    // weight: weight, // Ignored
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