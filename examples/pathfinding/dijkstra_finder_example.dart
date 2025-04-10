import 'package:pathfinder/pathfinder.dart';

// --- Dijkstra Pathing Algorithm ---
// Explanation:
// Dijkstra's algorithm finds the shortest path between a start node and all
// other reachable nodes in a weighted graph. It explores outwards from the start,
// always expanding the unvisited node with the lowest accumulated cost (g-cost).
// It does not use heuristics.
//
// 1. Setup: Define the grid, obstacles, start, and end points. Node weights
//    (terrain costs) can be set and will be considered.
//
// 2. Finder Creation: Instantiate DijkstraFinder. Movement rules apply.
//
// 3. Pathfinding: Call finder.findPath(). The algorithm uses a priority queue
//    ordered by g-cost to explore the grid until the end node is reached or the
//    queue is empty.
//
// 4. Result: Dijkstra guarantees finding the path with the lowest total cost
//    (sum of movement costs and node weights). Compared to A*, it might explore
//    more nodes as it doesn't have the heuristic to guide it towards the target,
//    but it ensures optimality based purely on cost.

void main() {
  // --- 1. Setup ---
  print("--- Dijkstra Finder Example ---");

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
  // Optionally add weights to some nodes
  final grid = Grid(gridWidth, gridHeight, matrix: matrix);
  // Example: Make a cell more costly
  // grid.setWeightAt(5, 4, 5.0);

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

  // --- 2. Create DijkstraFinder ---

  // Configure the finder
  final bool allowDiagonal = true;
  final bool dontCrossCorners = true;
  // Heuristics and weights are ignored by Dijkstra

  print("\nCreating DijkstraFinder with:");
  print("  Allow Diagonal: $allowDiagonal");
  print("  Don't Cross Corners: $dontCrossCorners");
  print("  (Note: Heuristics are ignored, Node weights are considered)");

  // Instantiate the DijkstraFinder
  final finder = DijkstraFinder(
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
    // Calculate path cost
    double pathCost = 0;
    for (int i = 1; i < path.length; i++) {
       // Use the finder instance to get movement cost
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