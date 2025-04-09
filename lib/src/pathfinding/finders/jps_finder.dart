import 'dart:math';

import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the Jump Point Search (JPS) algorithm.
///
/// JPS is an optimization of the A* search algorithm specifically designed for
/// uniform-cost grids (where the cost of moving between adjacent cells is constant,
/// typically 1 for cardinal moves and sqrt(2) for diagonal moves). It achieves
/// significant speedups over standard A* by exploiting grid symmetries and pruning
/// large portions of the search space.
///
/// Instead of exploring every neighbor of a node like A*, JPS identifies and
/// expands only certain "interesting" nodes called **jump points**. A jump point
/// is a node from which a path might potentially deviate optimally, typically
/// occurring near obstacles or when "forced neighbors" appear.
///
/// The algorithm works by:
/// 1. Starting at the initial node.
/// 2. Identifying potential "natural" and "forced" neighbors based on the direction
///    from the parent node.
/// 3. For each valid neighbor direction, performing a "jump" - moving straight
///    or diagonally in that direction until a jump point is found.
/// 4. A jump point is defined as:
///    - The target node itself.
///    - A node with "forced neighbors" (walkable neighbors that would not be
///      reached optimally if the agent continued straight/diagonally).
///    - For diagonal jumps, intermediate nodes reached via straight jumps that
///      are themselves jump points.
/// 5. Adding found jump points to the open list (priority queue based on f-cost).
/// 6. Repeating the process until the target node is expanded.
///
/// **Important Notes:**
/// - This JPS implementation assumes a **uniform-cost grid**. Node weights ([Node.weight])
///   are generally ignored by the core JPS logic (though used in `getMovementCost`
///   inherited from `PathFinder`, which might lead to suboptimal paths if weights vary).
///   For weighted grids, algorithms like Weighted JPS (WJPS) or A* are more appropriate.
/// - JPS inherently requires the ability to check diagonal movements to identify
///   forced neighbors correctly.
/// - The specific rules for identifying forced neighbors can be complex; this
///   implementation uses common JPS rules.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [AStarFinder] for the standard A* algorithm (works on weighted grids).
/// @seealso [OrthogonalJumpPointFinder] for a JPS variant restricted to cardinal moves.
class JumpPointFinder extends PathFinder {
  /// Creates a Jump Point Search (JPS) pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost (`h`-cost).
  ///   Octile or Diagonal distance ([Heuristics.octile], [Heuristics.diagonal])
  ///   are generally recommended for JPS as it considers diagonal movement.
  /// - `weight`: Weight applied to the heuristic (`h`-cost).
  ///
  /// Note: `allowDiagonal` and `dontCrossCorners` from the base class are
  /// effectively overridden as JPS requires diagonal checking capabilities.
  /// The internal logic handles movement constraints based on JPS rules.
  JumpPointFinder({
    super.heuristic = Heuristics.octile, // Octile/Diagonal often suitable for JPS
    super.weight = 1.0,
    // JPS specific options could be added here (e.g., different pruning rules)
  }) : super(allowDiagonal: true, dontCrossCorners: false); // JPS needs diagonal checks internally

  /// Finds the shortest path using the Jump Point Search (JPS) algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface using JPS logic.
  /// Assumes a uniform-cost grid.
  ///
  /// Returns a list of [Node]s representing the path (containing jump points
  /// and the start/end nodes), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId;
    final openList = HeapPriorityQueue<Node>((a, b) => a.f.compareTo(b.f)); // Open list (min-heap)
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      return []; // Start or end out of bounds
    }

    // Reset nodes for this search
    startNode.reset(searchId);
    endNode.resetIfNeeded(searchId);

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }

    // Initialize start node
    startNode.g = 0;
    startNode.h = weight * heuristic((startX - endNode.x).abs(), (startY - endNode.y).abs());
    // startNode.parent is null from reset
    startNode.opened = true;
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      // Get node with lowest f-cost (jump point or start node)
      final node = openList.removeFirst();
      node.closed = true; // Mark as expanded

      // --- Goal Check ---
      if (node == endNode) {
        return PathFinder.backtrace(endNode); // Path found
      }

      // --- Identify Successors (Jump Points) ---
      _identifySuccessors(node, grid, endNode, openList);
    }

    // 3. No Path Found
    return [];
  }

  /// Identifies and processes the successors (jump points) of a given node.
  ///
  /// This method determines the valid directions to explore from the current
  /// `node` based on its parent (pruning symmetric paths) and then calls the
  /// `_jump` function for each direction to find the next jump point. Found
  /// jump points are added to the `openList`.
  ///
  /// [node] The current node being expanded.
  /// [grid] The grid being searched.
  /// [endNode] The target node.
  /// [openList] The priority queue of nodes to explore.
  void _identifySuccessors(Node node, Grid grid, Node endNode, HeapPriorityQueue<Node> openList) {
    final searchId = grid.currentSearchId;
    final x = node.x;
    final y = node.y; // Keep first declaration
    final parent = node.parent;
    final neighborsToJump = <(int, int)>[]; // Stores (dx, dy) for potential jumps

    // --- Pruning Rules: Determine valid directions based on parent ---
    if (parent != null) {
      final px = parent.x;
      final py = parent.y;
      // Normalized direction vector from parent to current node
      final dx = (x - px).sign; // -1, 0, or 1
      final dy = (y - py).sign; // -1, 0, or 1

      if (dx != 0 && dy != 0) {
        // --- Diagonal Parent ---
        // Explore natural neighbors (straight and diagonal)
        if (grid.isWalkableAt(x, y + dy)) neighborsToJump.add((0, dy));
        if (grid.isWalkableAt(x + dx, y)) neighborsToJump.add((dx, 0));
        if (grid.isWalkableAt(x, y + dy) || grid.isWalkableAt(x + dx, y)) {
          if (grid.isWalkableAt(x + dx, y + dy)) neighborsToJump.add((dx, dy));
        }
        // Explore forced neighbors
        if (!grid.isWalkableAt(x - dx, y) && grid.isWalkableAt(x, y + dy)) {
          if (grid.isWalkableAt(x - dx, y + dy)) neighborsToJump.add((-dx, dy));
        }
        if (!grid.isWalkableAt(x, y - dy) && grid.isWalkableAt(x + dx, y)) {
          if (grid.isWalkableAt(x + dx, y - dy)) neighborsToJump.add((dx, -dy));
        }
      } else {
        // --- Straight Parent ---
        if (dx == 0) { // Moving vertically (dy is -1 or 1)
          if (grid.isWalkableAt(x, y + dy)) {
            neighborsToJump.add((0, dy)); // Natural neighbor
            // Check forced neighbors
            if (!grid.isWalkableAt(x + 1, y) && grid.isWalkableAt(x + 1, y + dy)) {
              neighborsToJump.add((1, dy));
            }
            if (!grid.isWalkableAt(x - 1, y) && grid.isWalkableAt(x - 1, y + dy)) {
              neighborsToJump.add((-1, dy));
            }
          }
        } else { // Moving horizontally (dx is -1 or 1, dy is 0)
          if (grid.isWalkableAt(x + dx, y)) {
            neighborsToJump.add((dx, 0)); // Natural neighbor
            // Check forced neighbors
            if (!grid.isWalkableAt(x, y + 1) && grid.isWalkableAt(x + dx, y + 1)) {
              neighborsToJump.add((dx, 1));
            }
            if (!grid.isWalkableAt(x, y - 1) && grid.isWalkableAt(x + dx, y - 1)) {
              neighborsToJump.add((dx, -1));
            }
          }
        }
      }
    } else {
      // --- Start Node ---
      // Explore all walkable neighbors initially
      final allNeighbors = grid.getNeighbors(node, allowDiagonal: true, dontCrossCorners: false);
      for (final neighborNode in allNeighbors) {
        neighborsToJump.add((neighborNode.x - x, neighborNode.y - y));
      }
    }

    // --- Perform Jump for each valid direction ---
    for (final dir in neighborsToJump) {
      final jumpPointCoords = _jump(x, y, dir.$1, dir.$2, grid, endNode);

      if (jumpPointCoords != null) {
        final jx = jumpPointCoords.$1;
        final jy = jumpPointCoords.$2;
        final jumpNode = grid.getNodeAt(jx, jy);

        jumpNode.resetIfNeeded(searchId); // Ensure state is fresh

        // Skip if already expanded in this search
        if (jumpNode.closed) continue;

        // Calculate cost to reach the jump point via the current node
        // Use Octile distance for g-cost calculation as JPS assumes grid movement
        final dist = Heuristics.octile((x - jx).abs(), (y - jy).abs());
        final tentativeG = node.g + dist;

        // If this path is better OR the jump point hasn't been opened yet
        if (tentativeG < jumpNode.g || !jumpNode.opened) {
          jumpNode.g = tentativeG;
          jumpNode.h = weight * heuristic((jx - endNode.x).abs(), (jy - endNode.y).abs());
          jumpNode.parent = node; // Parent is the node we jumped *from*

          if (!jumpNode.opened) {
            openList.add(jumpNode);
            jumpNode.opened = true;
          } else {
            // Already in open list, update priority (HeapPriorityQueue handles this)
          }
        }
      }
    }
  }

  /// Recursively searches ("jumps") in a given direction (dx, dy) from (x, y)
  /// until a jump point is found or the path is blocked.
  ///
  /// A jump point is defined by JPS rules (goal node, forced neighbor, etc.).
  ///
  /// [x], [y] Current coordinates during the jump.
  /// [dx], [dy] Direction of the jump (-1, 0, or 1 for each).
  /// [grid] The grid being searched.
  /// [endNode] The target node.
  ///
  /// Returns the coordinates `(x, y)` of the jump point if found, otherwise `null`.
  (int, int)? _jump(int x, int y, int dx, int dy, Grid grid, Node endNode) {
    final nextX = x + dx;
    final nextY = y + dy;

    // --- Base Cases: Stop Jumping ---
    // 1. Hit grid boundary or unwalkable node
    if (!grid.isWalkableAt(nextX, nextY)) {
      return null;
    }
    // 2. Reached the end node
    if (nextX == endNode.x && nextY == endNode.y) {
      // --- Added Check for Surrounded Goal ---
      // If moving diagonally to the goal, check if both intermediate cardinal
      // neighbors are blocked. If so, this path is invalid according to the
      // typical interpretation of 'surrounded'.
      if (dx != 0 && dy != 0) { // Diagonal move
        final nx1 = x + dx; // Same as nextX
        final ny1 = y;
        final nx2 = x;
        final ny2 = y + dy; // Same as nextY
        if (!grid.isWalkableAt(nx1, ny1) && !grid.isWalkableAt(nx2, ny2)) {
          return null; // Cannot reach diagonally surrounded goal
        }
      }
      // --- End Added Check ---
      return (nextX, nextY); // Otherwise, goal reached normally
    }

    // --- Check for Forced Neighbors (makes current node a jump point) ---
    if (dx != 0 && dy != 0) {
      // -- Diagonal Jump --
      // Check for forced neighbors horizontally and vertically
      // Standard JPS Forced Neighbor Check for Diagonal Moves:
      // Check if moving perpendicular to the jump direction is blocked,
      // but the diagonal move past that blockage is open.
      if ((grid.isWalkableAt(nextX - dx, nextY + dy) && !grid.isWalkableAt(nextX - dx, nextY)) || // Condition 1
          (grid.isWalkableAt(nextX + dx, nextY - dy) && !grid.isWalkableAt(nextX, nextY - dy))) { // Condition 2
        return (nextX, nextY);
      }
      // Check further jumps horizontally and vertically recursively
      if (_jump(nextX, nextY, dx, 0, grid, endNode) != null ||
          _jump(nextX, nextY, 0, dy, grid, endNode) != null) {
        return (nextX, nextY);
      }
    } else {
      // -- Straight Jump --
      if (dx != 0) { // Horizontal
        if ((grid.isWalkableAt(nextX + dx, nextY + 1) && !grid.isWalkableAt(nextX, nextY + 1)) ||
            (grid.isWalkableAt(nextX + dx, nextY - 1) && !grid.isWalkableAt(nextX, nextY - 1))) {
           return (nextX, nextY);
        }
         // JPS+ extension: Check one step ahead horizontally for forced neighbors
         // if ((grid.isWalkableAt(nextX + dx, nextY + 1) && grid.isWalkableAt(nextX, nextY + 1)) ||
         //     (grid.isWalkableAt(nextX + dx, nextY - 1) && grid.isWalkableAt(nextX, nextY - 1))) {
         //    // Potential forced neighbor ahead, but not immediately adjacent
         // }
      } else { // Vertical (dy != 0)
        if ((grid.isWalkableAt(nextX + 1, nextY + dy) && !grid.isWalkableAt(nextX + 1, nextY)) ||
            (grid.isWalkableAt(nextX - 1, nextY + dy) && !grid.isWalkableAt(nextX - 1, nextY))) {
           return (nextX, nextY);
        }
         // JPS+ extension: Check one step ahead vertically
         // if ((grid.isWalkableAt(nextX + 1, nextY + dy) && grid.isWalkableAt(nextX + 1, nextY)) ||
         //     (grid.isWalkableAt(nextX - 1, nextY + dy) && grid.isWalkableAt(nextX - 1, nextY))) {
         //    // Potential forced neighbor ahead
         // }
      }
    }

    // --- Recursive Step: Continue Jumping ---
    // If moving diagonally, always continue the diagonal jump after checking
    // horizontal/vertical sub-jumps (as per standard JPS).
    // If moving straight, continue straight only if no forced neighbors were found.
    // (This implementation simplifies and always continues the jump)
    return _jump(nextX, nextY, dx, dy, grid, endNode);
  }
}
