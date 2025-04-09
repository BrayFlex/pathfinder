import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart'; // Import needed for base class constructor

/// A pathfinder that implements Dijkstra's algorithm.
///
/// Dijkstra's algorithm is an uninformed search algorithm that finds the shortest
/// path between a start node and all other reachable nodes in a weighted graph
/// (or grid). It explores the graph by prioritizing nodes with the lowest
/// accumulated cost (`g`-cost) from the start node.
///
/// It uses a priority queue (open list) ordered by `g`-cost. Unlike A*, it does
/// **not** use heuristics (`h`-cost) to estimate the distance to the target.
/// This guarantees finding the absolute shortest path in terms of accumulated cost
/// (considering node weights from the [Grid]), but it may explore more nodes
/// than A* in many cases, especially in large, open areas.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [AStarFinder] which uses heuristics for potentially faster searches.
/// @seealso [BreadthFirstFinder] for shortest path in terms of steps on unweighted grids.
class DijkstraFinder extends PathFinder {
  /// Creates a Dijkstra pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: Inherited but **ignored** by Dijkstra's algorithm.
  /// - `weight`: Inherited but **ignored** by Dijkstra's algorithm.
  ///
  /// The algorithm *does* consider node weights ([Node.weight]) defined in the
  /// [Grid] when calculating the path cost (`g`-cost).
  DijkstraFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    // Heuristic and weight are not used by Dijkstra but are part of the base class
    // Pass dummy values for ignored parameters to base constructor
    super.heuristic = Heuristics.manhattan, // Ignored
    super.weight = 1.0, // Ignored
  });

  /// Finds the shortest path using Dijkstra's algorithm based on accumulated cost.
  ///
  /// Implements the [PathFinder.findPath] interface using a priority queue
  /// ordered by `g`-cost. Ignores heuristics.
  ///
  /// Returns a list of [Node]s representing the path from start to end
  /// (inclusive), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId;
    // Priority queue ordered only by accumulated cost (g)
    final openList = HeapPriorityQueue<Node>((a, b) => a.g.compareTo(b.g));
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
    startNode.g = 0; // Cost from start to start is 0
    // h is not used by Dijkstra
    // startNode.parent is null from reset
    startNode.opened = true; // Mark as in the open list for this search
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      // Get node with the lowest G cost
      final currentNode = openList.removeFirst();
      currentNode.closed = true; // Mark as fully evaluated

      // --- Goal Check ---
      if (currentNode == endNode) {
        // Shortest path found!
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

        // Skip unwalkable or already fully evaluated nodes
        if (!neighbor.isWalkable || neighbor.closed) {
          continue;
        }

        // Calculate the cost to reach this neighbor through the current node
        final tentativeG = currentNode.g + getMovementCost(currentNode, neighbor);

        // Check if this path is better than any previously found path to the neighbor
        // OR if the neighbor hasn't been reached before in this search.
        if (tentativeG < neighbor.g || !neighbor.opened) {
          // Found a better path or first time reaching neighbor.
          neighbor.g = tentativeG;
          neighbor.parent = currentNode;

          if (!neighbor.opened) {
            // Add to open list if it's not already there.
            openList.add(neighbor);
            neighbor.opened = true;
          } else {
            // If already in the open list, update its position in the queue
            // because its cost (g) has decreased. HeapPriorityQueue handles this.
            // No explicit update needed for HeapPriorityQueue.
          }
        }
      }
    }

    // 3. No Path Found
    return [];
  }
}
