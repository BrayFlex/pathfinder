import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the Best-First Search algorithm.
///
/// Best-First Search is an informed search algorithm that explores a graph by
/// expanding the most promising node chosen according to a specified rule.
/// In this common implementation (often called Greedy Best-First Search),
/// "most promising" means the node with the lowest heuristic cost (`h`-cost)
/// to the target, regardless of the cost already incurred (`g`-cost) to reach that node.
///
/// It uses a priority queue (open list) ordered solely by the `h`-cost.
/// Because it greedily follows the path that looks closest to the goal based
/// on the heuristic, it can be very fast in finding *a* path, but it does
/// **not** guarantee finding the *shortest* path (unlike A* or Dijkstra).
/// It can get stuck in dead ends or follow suboptimal routes if the heuristic
/// is misleading.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [AStarFinder] for a shortest-path guarantee (usually preferred).
/// @seealso [Heuristics] for available heuristic functions.
class BestFirstFinder extends PathFinder {
  /// Creates a Best-First Search pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost to the target.
  ///   This is the primary factor driving the search.
  /// - `weight`: Inherited but **typically ignored** by Best-First Search's
  ///   prioritization logic, which focuses solely on the `h`-cost.
  BestFirstFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    super.heuristic, // Pass heuristic from constructor or use base default
    super.weight = 1.0, // Keep for consistency, but not used in priority
  });

  /// Finds a path using the Best-First Search algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface. Prioritizes nodes
  /// based solely on their heuristic cost (`h`-cost) to the target.
  ///
  /// Returns a list of [Node]s representing the path found, or an empty list
  /// if no path exists. **Note:** The path found is not guaranteed to be the shortest.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId;
    // Priority queue ordered only by heuristic cost (h)
    final openList = HeapPriorityQueue<Node>((a, b) => a.h.compareTo(b.h));
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
    // g-cost is not used for prioritization in Best-First, but might be useful
    // if path cost needs to be calculated later (though this finder doesn't guarantee shortest).
    startNode.g = 0;
    startNode.h = heuristic((startX - endNode.x).abs(), (startY - endNode.y).abs());
    // startNode.parent is null from reset
    startNode.opened = true;
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      // Get node with the lowest H cost
      final currentNode = openList.removeFirst();
      currentNode.closed = true; // Mark as visited

      // --- Goal Check ---
      if (currentNode == endNode) {
        // Path found (but maybe not the shortest)
        return PathFinder.backtrace(endNode);
      }

      // --- Process Neighbors ---
      final neighbors = grid.getNeighbors(
        currentNode,
        allowDiagonal: allowDiagonal,
        dontCrossCorners: dontCrossCorners,
      );

      for (final neighbor in neighbors) {
        neighbor.resetIfNeeded(searchId); // Ensure state is fresh

        // Skip unwalkable, closed, or already opened nodes.
        // Best-First typically doesn't revisit nodes once they are added to open/closed.
        if (!neighbor.isWalkable || neighbor.closed || neighbor.opened) {
          continue;
        }

        // Set parent and calculate heuristic for the neighbor
        neighbor.parent = currentNode;
        neighbor.h = heuristic((neighbor.x - endNode.x).abs(), (neighbor.y - endNode.y).abs());
        // g-cost could be calculated for path length, but isn't used for search decisions:
        // neighbor.g = currentNode.g + getMovementCost(currentNode, neighbor);

        // Add neighbor to the open list and mark it as opened
        neighbor.opened = true;
        openList.add(neighbor);
      }
    }

    // 3. No Path Found
    return [];
  }
}
