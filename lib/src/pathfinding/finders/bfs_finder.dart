import 'dart:collection'; // For Queue

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart'; // Import needed for base class constructor

/// A pathfinder that implements the Breadth-First Search (BFS) algorithm.
///
/// BFS is an uninformed search algorithm that explores the grid level by level,
/// starting from the source node. It uses a FIFO (First-In, First-Out) queue
/// to manage the nodes to visit.
///
/// BFS guarantees finding the shortest path in terms of the **number of steps**
/// (i.e., the path with the fewest nodes) on an **unweighted grid** (where all
/// movement costs are uniform, typically 1). It does **not** consider node weights
/// or use heuristics, making it less suitable for grids with varying terrain costs
/// or when a faster (but potentially non-optimal) path is acceptable using heuristics.
///
/// For weighted grids, use [DijkstraFinder] or [AStarFinder] to find the shortest
/// path based on accumulated cost.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [DijkstraFinder], [AStarFinder] for shortest paths on weighted grids.
class BreadthFirstFinder extends PathFinder {
  /// Creates a Breadth-First Search pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: Inherited but **ignored** by BFS.
  /// - `weight`: Inherited but **ignored** by BFS.
  BreadthFirstFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    // Heuristic and weight are not used by BFS but are part of the base class
    // Pass dummy values for ignored parameters to base constructor
    super.heuristic = Heuristics.manhattan, // Ignored
    super.weight = 1.0, // Ignored
  });

  /// Finds the shortest path in terms of number of steps using BFS.
  ///
  /// Implements the [PathFinder.findPath] interface using a FIFO queue.
  /// Ignores node weights and heuristics.
  ///
  /// Returns a list of [Node]s representing the path from start to end
  /// (inclusive), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId;
    final openList = Queue<Node>(); // FIFO Queue for BFS
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
    // g and h costs are not used by BFS
    // startNode.parent is null from reset
    startNode.opened = true; // Mark as visited/queued for this search
    openList.add(startNode);

    // 2. Main Search Loop
    while (openList.isNotEmpty) {
      final currentNode = openList.removeFirst(); // Dequeue from front
      // Mark as closed *after* dequeuing in BFS to handle queue correctly
      currentNode.closed = true;

      // --- Goal Check ---
      if (currentNode == endNode) {
        // Path found!
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

        // Skip unwalkable nodes or nodes already visited/queued in this search.
        // In BFS, 'opened' means it's either in the queue or has been processed.
        if (!neighbor.isWalkable || neighbor.opened || neighbor.closed) {
          continue;
        }

        // Set parent for path reconstruction
        neighbor.parent = currentNode;
        // Mark as visited/queued
        neighbor.opened = true;
        // Enqueue the neighbor
        openList.add(neighbor);
      }
    }

    // 3. No Path Found
    // The queue became empty, but the end node was never reached.
    return [];
  }
}
