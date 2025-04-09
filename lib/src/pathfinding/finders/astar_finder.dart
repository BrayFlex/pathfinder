import 'dart:math';

import 'dart:math';

import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the A* (A-star) search algorithm.
///
/// A* is an informed search algorithm widely used for finding the shortest path
/// between two nodes (start and end) on a graph, such as a grid map ([Grid]).
/// It balances the actual cost incurred so far to reach a node (`g`-cost) with
/// an estimated heuristic cost from that node to the target (`h`-cost).
///
/// The total estimated cost (`f`-cost) for a node is `f = g + h`. A* explores
/// the grid by prioritizing nodes with the lowest `f`-cost, using a priority
/// queue (the "open list") to manage nodes yet to be fully evaluated.
///
/// This implementation uses a [HeapPriorityQueue] for efficient open list
/// management and leverages the `currentSearchId` mechanism from [Grid] and [Node]
/// for efficient node state resetting between searches.
///
/// A* guarantees finding the shortest path if the heuristic function used is
/// admissible (never overestimates the true cost) and consistent (optional, but
/// improves efficiency).
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [Heuristics] for available heuristic functions.
/// @seealso [Grid], [Node]
class AStarFinder extends PathFinder {
  /// Creates an A* pathfinder instance with configurable options.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost to the target.
  ///   Crucial for A*'s performance and optimality. Ensure the chosen heuristic
  ///   matches the movement rules (e.g., use [Heuristics.diagonal] if diagonal
  ///   movement cost is sqrt(2)).
  /// - `weight`: Weight applied to the heuristic (`h`-cost). A weight > 1 can
  ///   speed up the search but may sacrifice optimality (Weighted A*).
  AStarFinder({
    super.allowDiagonal = false, // Default to cardinal movement
    super.dontCrossCorners = false, // Default corner rule
    super.heuristic, // Pass heuristic from constructor or use base default
    super.weight = 1.0, // Default weight (standard A*)
  });

  /// Finds the shortest path using the A* algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface.
  ///
  /// Returns a list of [Node]s representing the path from start to end
  /// (inclusive), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId; // Unique ID for this search run
    final openList = HeapPriorityQueue<Node>((a, b) => a.f.compareTo(b.f)); // Min-heap based on F cost
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      // Handle cases where start/end coordinates are out of bounds
      return [];
    }

    // Ensure nodes are reset for this search ID
    startNode.reset(searchId); // Force reset start node
    endNode.resetIfNeeded(searchId); // Reset end node if needed

    // Basic validation: Check if start or end are unwalkable
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return []; // Path is impossible
    }

    // Initialize start node's costs and add it to the open list
    startNode.g = 0;
    startNode.h = weight * heuristic( (startNode.x - endNode.x).abs(), (startNode.y - endNode.y).abs() );
    // startNode.parent is already null from reset
    startNode.opened = true; // Mark as currently in the open list for this search
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      // Get node with the lowest F cost from the open list
      final currentNode = openList.removeFirst();
      currentNode.closed = true; // Mark as fully evaluated for this search

      // --- Goal Check ---
      if (currentNode == endNode) {
        // Path found! Reconstruct and return it.
        return PathFinder.backtrace(endNode);
      }

      // --- Process Neighbors ---
      final neighbors = grid.getNeighbors(
        currentNode,
        allowDiagonal: allowDiagonal,
        dontCrossCorners: dontCrossCorners,
      );

      for (final neighbor in neighbors) {
        // Ensure neighbor state is fresh for this search run
        neighbor.resetIfNeeded(searchId);

        // Skip unwalkable nodes or nodes already fully evaluated in this search
        if (!neighbor.isWalkable || neighbor.closed) {
          continue;
        }

        // Calculate the cost to reach this neighbor through the current node (`g`-cost)
        final tentativeG = currentNode.g + getMovementCost(currentNode, neighbor);

        // Check if this path to the neighbor is better than any previously found path
        // OR if the neighbor hasn't been evaluated yet (neighbor.g is default 0 from reset).
        // The resetIfNeeded ensures g is 0 if not visited in this search.
        // We only need to check if the new path is strictly better.
        if (tentativeG < neighbor.g || !neighbor.opened) {
          // Found a better path to this neighbor OR it's the first time reaching it.
          neighbor.g = tentativeG;
          // Calculate heuristic cost only if needed (first time or path improved)
          neighbor.h = weight * heuristic( (neighbor.x - endNode.x).abs(), (neighbor.y - endNode.y).abs() );
          neighbor.parent = currentNode; // Set parent for path reconstruction

          if (!neighbor.opened) {
            // If neighbor wasn't in the open list, add it.
            openList.add(neighbor);
            neighbor.opened = true; // Mark as opened for this search
          } else {
            // If neighbor WAS already in the open list, update its position
            // in the priority queue because its F cost has changed.
            // HeapPriorityQueue handles this automatically when the object's
            // comparison value changes (due to changing 'f'). Re-adding might
            // also work depending on queue implementation, but letting the queue
            // manage updates is generally preferred if supported.
            // No explicit update needed for HeapPriorityQueue if using object identity.
            // If using a queue that doesn't auto-update, you might need:
            // openList.remove(neighbor); openList.add(neighbor);
          }
        }
      }
    }

    // 3. No Path Found
    // The open list became empty, but the end node was never reached.
    return [];
  }
}
