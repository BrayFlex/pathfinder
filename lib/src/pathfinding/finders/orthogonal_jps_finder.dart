import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements a variation of the Jump Point Search (JPS)
/// algorithm restricted to **orthogonal (horizontal and vertical) movements only**.
///
/// This algorithm applies the core JPS principles of identifying jump points and
/// pruning symmetric paths, but it operates under the constraint that movement
/// is only allowed cardinally (up, down, left, right). Diagonal steps are never taken.
///
/// It identifies jump points based on "forced neighbors" that appear due to
/// obstacles adjacent to the direction of travel. For example, when moving
/// horizontally, a jump point occurs if there's an obstacle directly above or
/// below the current path, but the cell diagonally ahead (in the direction of
/// travel) is walkable.
///
/// Like standard JPS, this assumes a **uniform-cost grid** and guarantees finding
/// the shortest path in terms of steps/cost under orthogonal movement constraints.
/// It uses an A*-like search guided by a heuristic (Manhattan distance is most
/// appropriate here) and prioritizes jump points based on their `f`-cost.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [JumpPointFinder] for the standard JPS algorithm allowing diagonals.
/// @seealso [AStarFinder], [DijkstraFinder] for general grid pathfinding.
class OrthogonalJumpPointFinder extends PathFinder {
  /// Creates an Orthogonal Jump Point Search pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost (`h`-cost).
  ///   [Heuristics.manhattan] is the most suitable choice for purely orthogonal movement.
  /// - `weight`: Weight applied to the heuristic (`h`-cost).
  ///
  /// Note: `allowDiagonal` and `dontCrossCorners` are explicitly set to `false`
  /// in the base constructor call, enforcing orthogonal-only movement.
  OrthogonalJumpPointFinder({
    super.heuristic = Heuristics.manhattan, // Manhattan is appropriate
    super.weight = 1.0,
  }) : super(allowDiagonal: false, dontCrossCorners: false); // Enforce orthogonal

  /// Finds the shortest orthogonal path using the Orthogonal JPS algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface using Orthogonal JPS logic.
  /// Assumes a uniform-cost grid and restricts movement to cardinal directions.
  ///
  /// Returns a list of [Node]s representing the path (containing jump points
  /// and the start/end nodes), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization (Similar to A* and JPS)
    final searchId = ++grid.currentSearchId;
    final openList = HeapPriorityQueue<Node>((a, b) => a.f.compareTo(b.f));
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      return []; // Start or end out of bounds
    }

    startNode.reset(searchId);
    endNode.resetIfNeeded(searchId);

    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }

    startNode.g = 0;
    startNode.h = weight * heuristic((startX - endNode.x).abs(), (startY - endNode.y).abs());
    startNode.opened = true;
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      final node = openList.removeFirst();
      node.closed = true;

      if (node == endNode) {
        return PathFinder.backtrace(endNode);
      }

      // 3. Identify Orthogonal Successors (Jump Points)
      _identifySuccessors(node, grid, endNode, openList);
    }

    // 4. No Path Found
    return [];
  }

  /// Identifies orthogonal successors (jump points) for the given node.
  ///
  /// Determines valid cardinal directions based on the parent node (pruning)
  /// and then calls `_jump` to find jump points in those directions. Also checks
  /// for forced neighbors specific to orthogonal movement.
  ///
  /// [node] The current node being expanded.
  /// [grid] The grid being searched.
  /// [endNode] The target node.
  /// [openList] The priority queue of nodes to explore.
 void _identifySuccessors(Node node, Grid grid, Node endNode, HeapPriorityQueue<Node> openList) {
    final searchId = grid.currentSearchId;
    final x = node.x;
    final y = node.y;
    final parent = node.parent;
    final Set<(int, int)> directionsToJump = {}; // Use Set to avoid duplicate jumps

    // --- Always consider jumping towards goal coordinates ---
    // Consider jumping towards goal's X coordinate if different & walkable
    if (x != endNode.x) {
      final dx = (endNode.x - x).sign;
      if (grid.isWalkableAt(x + dx, y)) {
        directionsToJump.add((dx, 0));
      }
    }
    // Consider jumping towards goal's Y coordinate if different & walkable
    if (y != endNode.y) {
      final dy = (endNode.y - y).sign;
      if (grid.isWalkableAt(x, y + dy)) {
         directionsToJump.add((0, dy));
      }
    }

    // --- Add pruned directions based on parent (if applicable) ---
    if (parent != null) {
       final px = parent.x;
       final py = parent.y;
       final incomeDx = (x - px).sign; // Direction from parent
       final incomeDy = (y - py).sign;

       if (incomeDx != 0) { // Came horizontally
         // Straight (natural neighbor)
         if (grid.isWalkableAt(x + incomeDx, y)) directionsToJump.add((incomeDx, 0));
         // Forced Up
         if (grid.isWalkableAt(x, y + 1) && !grid.isWalkableAt(x - incomeDx, y + 1)) directionsToJump.add((0, 1));
         // Forced Down
         if (grid.isWalkableAt(x, y - 1) && !grid.isWalkableAt(x - incomeDx, y - 1)) directionsToJump.add((0, -1));
       } else { // Came vertically (incomeDy != 0)
         // Straight (natural neighbor)
         if (grid.isWalkableAt(x, y + incomeDy)) directionsToJump.add((0, incomeDy));
         // Forced Right
         if (grid.isWalkableAt(x + 1, y) && !grid.isWalkableAt(x + 1, y - incomeDy)) directionsToJump.add((1, 0));
         // Forced Left
         if (grid.isWalkableAt(x - 1, y) && !grid.isWalkableAt(x - 1, y - incomeDy)) directionsToJump.add((-1, 0));
       }
    } else {
       // Start node: Ensure all initial directions are considered (already done by goal check?)
       // Let's explicitly add neighbors for clarity/safety, Set handles duplicates.
       final cardinalNeighbors = grid.getNeighbors(node, allowDiagonal: false);
       for (final neighborNode in cardinalNeighbors) {
         directionsToJump.add((neighborNode.x - x, neighborNode.y - y));
       }
    }

    // --- Perform Jump for each unique valid direction ---
    for (final dir in directionsToJump) {
      final jumpPointCoords = _jump(x, y, dir.$1, dir.$2, grid, endNode);
      if (jumpPointCoords != null) {
        _addJumpPoint(jumpPointCoords, node, endNode, openList, grid, searchId);
      }
    }
  }

  /// Helper method to process a found jump point: calculate costs, update parent,
  /// and add/update it in the open list.
  ///
  /// [jumpPointCoords] The (x, y) coordinates of the found jump point.
  /// [parentNode] The node from which the jump originated.
  /// [endNode] The target node of the overall search.
  /// [openList] The priority queue for the search.
  /// [grid] The grid being searched.
  /// [searchId] The current search ID for node state management.
  void _addJumpPoint((int, int) jumpPointCoords, Node parentNode, Node endNode,
                     HeapPriorityQueue<Node> openList, Grid grid, int searchId) {
    final jx = jumpPointCoords.$1;
    final jy = jumpPointCoords.$2;
    final jumpNode = grid.getNodeAt(jx, jy);

    jumpNode.resetIfNeeded(searchId); // Ensure state is fresh

    // Skip if already expanded
    if (jumpNode.closed) return;

    // Calculate cost (g) to reach this jump point via parentNode
    // Use Manhattan distance as only orthogonal moves are considered
    final dist = Heuristics.manhattan((parentNode.x - jx).abs(), (parentNode.y - jy).abs());
    final tentativeG = parentNode.g + dist;

    // If this path is better OR the node hasn't been opened yet
    if (tentativeG < jumpNode.g || !jumpNode.opened) {
      jumpNode.g = tentativeG;
      jumpNode.h = weight * heuristic((jx - endNode.x).abs(), (jy - endNode.y).abs());
      jumpNode.parent = parentNode;

      if (!jumpNode.opened) {
        openList.add(jumpNode);
        jumpNode.opened = true;
      } else {
        // Already in open list, update priority (HeapPriorityQueue handles this)
      }
    }
  }


  /// Recursively searches ("jumps") orthogonally in a given cardinal direction
  /// (dx, dy) from (x, y) until an orthogonal jump point is found or the path is blocked.
  ///
  /// An orthogonal jump point occurs if the node is the goal or has a forced neighbor.
  ///
  /// [x], [y] Current coordinates during the jump.
  /// [dx], [dy] Direction of the jump (must be cardinal: dx= +/-1, dy=0 or dx=0, dy=+/-1).
  /// [grid] The grid being searched.
  /// [endNode] The target node.
  ///
  /// Returns the coordinates `(x, y)` of the jump point if found, otherwise `null`.
  (int, int)? _jump(int x, int y, int dx, int dy, Grid grid, Node endNode) {
    assert(dx == 0 || dy == 0, "Orthogonal jump requires cardinal direction.");
    assert(dx != 0 || dy != 0, "Orthogonal jump requires non-zero direction.");

    final nextX = x + dx;
    final nextY = y + dy;

    // --- Base Cases: Stop Jumping ---
    // 1. Hit grid boundary or unwalkable node
    if (!grid.isWalkableAt(nextX, nextY)) {
      // Check if the *current* node (x,y) has forced neighbors that make IT a jump point,
      // even though the next step is blocked. This handles jump points right before walls.
       if (dx != 0) { // Moving horizontally when blocked
         if ((grid.isWalkableAt(x, y + 1) && !grid.isWalkableAt(x - dx, y + 1)) || // Forced neighbor above?
             (grid.isWalkableAt(x, y - 1) && !grid.isWalkableAt(x - dx, y - 1))) { // Forced neighbor below?
           return (x, y); // Current node (x,y) is the jump point
         }
       } else { // Moving vertically when blocked (dy != 0)
         if ((grid.isWalkableAt(x + 1, y) && !grid.isWalkableAt(x + 1, y - dy)) || // Forced neighbor right?
             (grid.isWalkableAt(x - 1, y) && !grid.isWalkableAt(x - 1, y - dy))) { // Forced neighbor left?
            return (x, y); // Current node (x,y) is the jump point
         }
       }
      return null; // Wall hit, and current node wasn't forced
    }
    // 2. Reached the end node
    if (nextX == endNode.x && nextY == endNode.y) {
      return (nextX, nextY);
    }

    // 2b. Reached Goal Row/Column (potential corner)
    if (dx != 0 && nextX == endNode.x) { // Moving horizontally, reached goal column
      return (nextX, nextY);
    }
    if (dy != 0 && nextY == endNode.y) { // Moving vertically, reached goal row
      return (nextX, nextY);
    }

    // --- Check for Forced Neighbors (Orthogonal specific) ---
    if (dx != 0) { // Moving horizontally
      // Check vertical neighbors: if obstacle adjacent but diagonal ahead is clear
      if ((!grid.isWalkableAt(x, y + 1) && grid.isWalkableAt(nextX, y + 1)) ||
          (!grid.isWalkableAt(x, y - 1) && grid.isWalkableAt(nextX, y - 1))) {
        return (nextX, nextY); // Found jump point
      }
    } else { // Moving vertically (dy != 0)
      // Check horizontal neighbors: if obstacle adjacent but diagonal ahead is clear
      if ((!grid.isWalkableAt(x + 1, y) && grid.isWalkableAt(x + 1, nextY)) ||
          (!grid.isWalkableAt(x - 1, y) && grid.isWalkableAt(x - 1, nextY))) {
        return (nextX, nextY); // Found jump point
      }
    }

    // --- Recursive Step: Continue Jumping ---
    // Goal is straight ahead and no forced neighbors found, continue jump.
    return _jump(nextX, nextY, dx, dy, grid, endNode);
  }
}
