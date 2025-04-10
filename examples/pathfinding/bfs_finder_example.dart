import 'package:pathfinder/pathfinder.dart';

// --- BreadthFirst Pathing Algorithm (BFS) ---
// Explanation:
// Breadth-First Search (BFS) is an uninformed search algorithm that explores
// the grid level by level, starting from the source node. It uses a FIFO
// (First-In, First-Out) queue.
//
// 1. Setup: Define the grid, obstacles, start, and end points.
//
// 2. Finder Creation: Instantiate BreadthFirstFinder. Options like diagonal
//    movement are relevant, but heuristics and node weights are ignored.
//
// 3. Pathfinding: Call finder.findPath(). BFS explores all reachable nodes at
//    distance 1, then distance 2, and so on, until it finds the end node.
//
// 4. Result: BFS guarantees finding the path with the fewest number of steps
//    (nodes) on an unweighted grid (where each step has a cost of 1). It does
//    not consider varying movement costs (node weights). The path found might
//    look different from A* or Dijkstra if diagonal moves have a higher cost
//    (e.g., sqrt(2)) in those algorithms, as BFS treats all steps equally.

void main() {
  // --- 1. Setup ---
  print("--- Breadth-First Finder (BFS) Example ---");

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

  // --- 2. Create BreadthFirstFinder ---

  // Configure the finder
  final bool allowDiagonal = true; // BFS can use diagonal movement
  final bool dontCrossCorners = true;
  // Heuristics and weights are ignored by BFS

  print("\nCreating BreadthFirstFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  (Note: Heuristics and weights are ignored by BFS)");

  // Instantiate the BreadthFirstFinder
  final finder = BreadthFirstFinder(
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