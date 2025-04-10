import 'package:pathfinder/pathfinder.dart';

// --- IDA* Pathing Algorithm ---
// Explanation:
// Iterative Deepening A* (IDA*) combines A*'s shortest path guarantee (with an
// admissible heuristic) with the low memory usage of Depth-First Search (DFS).
// It performs successive DFS traversals, each limited by an increasing cost
// threshold (f-cost = g-cost + h-cost).
//
// 1. Setup: Define the grid, obstacles, start, and end points.
//
// 2. Finder Creation: Instantiate IDAStarFinder. An admissible heuristic is crucial.
//    Movement rules apply. An iterationLimit acts as a safety stop for each DFS.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm starts a DFS with a
//    threshold equal to the initial heuristic estimate. If the goal isn't found,
//    it increases the threshold to the minimum f-cost that exceeded the previous
//    threshold and starts a new DFS. This repeats until the goal is found or
//    limits are reached.
//
// 4. Result: IDA* returns the shortest path, like A*. Its main advantage is
//    memory efficiency (no large open list). However, it can revisit nodes
//    multiple times across iterations, potentially making it slower than A* in
//    some scenarios.

void main() {
  // --- 1. Setup ---
  print("--- IDA* Finder Example ---");

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

  // --- 2. Create IDAStarFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  final HeuristicFunction heuristic = Heuristics.diagonal; // Needs admissible heuristic
  final double weight = 1.0;
  final int iterationLimit = 2000000; // Safety limit for nodes per DFS iteration

  print("\nCreating IDAStarFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  Heuristic: Diagonal Distance");
  print("  Weight: $weight");
  print("  Iteration Limit (per DFS): $iterationLimit");

  // Instantiate the IDAStarFinder
  final finder = IDAStarFinder(
    allowDiagonal: allowDiagonal,
    dontCrossCorners: dontCrossCorners,
    heuristic: heuristic,
    weight: weight,
    iterationLimit: iterationLimit,
  );

  // --- 3. Find the Path ---

  print("\nFinding path...");
  // Use the finder to calculate the path
  // The result is a list of Node objects representing the path found
  final List<Node> path = finder.findPath(startX, startY, endX, endY, grid);

  // --- 4. Output / Verification ---

  if (path.isEmpty) {
    print("\nNo path found (or iteration limit reached)!");
  } else {
    print("\nPath found! Length: ${path.length} steps.");
    // Calculate path cost
    double pathCost = 0;
    for (int i = 1; i < path.length; i++) {
       pathCost += grid.getNodeAt(path[i].x, path[i].y).weight * finder.getMovementCost(path[i-1], path[i]);
    }
    print("Path Cost: ${pathCost.toStringAsFixed(2)}");

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