import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the Bi-directional A* (A-star) algorithm.
///
/// This algorithm performs two simultaneous A* searches: one starting from the
/// `startNode` and moving towards the `endNode`, and another starting from the
/// `endNode` and moving towards the `startNode`. The search terminates when the
/// frontiers of the two searches meet, or when a termination condition based on
/// the current best path cost is met.
///
/// By searching from both ends, Bi-directional A* can often find the shortest
/// path by exploring significantly fewer nodes compared to unidirectional A*,
/// especially in large, open grids.
///
/// It maintains two separate open lists (priority queues ordered by `f`-cost),
/// two sets of cost (`g`-cost) maps, two parent pointer maps, and a shared
/// `visited` map to track which search has processed which node.
///
/// Like standard A*, it requires an admissible heuristic to guarantee optimality.
/// The heuristic for the backward search (from end to start) should estimate the
/// cost from the current node to the *start* node.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [AStarFinder] for the unidirectional version.
class BiAStarFinder extends PathFinder {
  // Constants to mark which search visited/closed a node
  // Using integers allows storing this state directly if Node had a general purpose field,
  // but here we use an external map `visited`.
  // static const int _closedByStart = 1; // Visited/Closed by forward search
  // static const int _closedByEnd = 2;   // Visited/Closed by backward search

  /// Creates a Bi-directional A* pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost. It's used
  ///   for both forward (to end) and backward (to start) searches.
  /// - `weight`: Weight applied to the heuristic (`h`-cost) in both directions.
  BiAStarFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    super.heuristic, // Pass through constructor value or base default
    super.weight = 1.0,
  });

  // Constants used in the 'visited' map
  static const int _visitedByStart = 1;
  static const int _visitedByEnd = 2;

  /// Finds the shortest path using the Bi-directional A* algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface by running two A* searches
  /// concurrently from the start and end nodes.
  ///
  /// Returns a list of [Node]s representing the path from start to end
  /// (inclusive), or an empty list if no path is found.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId; // Use searchId for node reset
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      return []; // Start or end out of bounds
    }

    // Data structures for both searches
    final openListStart = HeapPriorityQueue<Node>((a, b) => a.f.compareTo(b.f));
    final openListEnd = HeapPriorityQueue<Node>((a, b) => a.f.compareTo(b.f));
    // Use Node properties for g, h, f, parent, opened, closed, managed by searchId
    // Need a way to store g-cost *from the end* for the backward search.
    // We can potentially reuse node.g if we are careful or use external maps.
    // Let's use external maps for clarity for g-costs and parents from each direction.
    final gCostsStart = <Node, double>{};
    final gCostsEnd = <Node, double>{};
    final parentsStart = <Node, Node>{};
    final parentsEnd = <Node, Node>{};
    // Map to track which search has visited/closed a node (1=start, 2=end)
    final visited = <Node, int>{};

    double bestPathCost = double.infinity; // Cost of the best complete path found so far
    Node? meetingNode; // Node where the two searches meet for the best path

    // Reset start/end nodes specifically for this search
    startNode.reset(searchId);
    endNode.reset(searchId);

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }

    // Initialize start node for forward search
    gCostsStart[startNode] = 0;
    startNode.h = weight * heuristic((startX - endX).abs(), (startY - endY).abs());
    // f = g + h = 0 + h
    openListStart.add(startNode);
    visited[startNode] = _visitedByStart;
    startNode.opened = true; // Mark as opened in general for this searchId

    // Initialize end node for backward search
    gCostsEnd[endNode] = 0;
    // Heuristic for backward search estimates cost to START node
    endNode.h = weight * heuristic((endX - startX).abs(), (endY - startY).abs());
    // f = g + h = 0 + h
    openListEnd.add(endNode);
    visited[endNode] = _visitedByEnd;
    endNode.opened = true; // Mark as opened in general for this searchId


    // 2. Main Search Loop - Continue while both open lists have nodes
    while (openListStart.isNotEmpty && openListEnd.isNotEmpty) {

      // --- Termination Condition ---
      // Check if the sum of the minimum potential costs from both searches
      // meets or exceeds the cost of the best complete path found so far.
      // Peek at the lowest f-cost nodes in each queue.
      final minPotentialCostStart = gCostsStart[openListStart.first]! + openListStart.first.h;
      final minPotentialCostEnd = gCostsEnd[openListEnd.first]! + openListEnd.first.h;
      // A common termination condition: cost_start + cost_end >= bestPathCost
      // More sophisticated conditions exist, but this is a reasonable one.
      if (meetingNode != null && (minPotentialCostStart + minPotentialCostEnd) >= bestPathCost) {
           return _biBacktrace(meetingNode, parentsStart, parentsEnd);
      }

      // --- Expand from Start ---
      if (openListStart.isNotEmpty) { // Check again in case list emptied
        final currentStart = openListStart.removeFirst();
        currentStart.closed = true; // Mark closed for this search direction

        // Check if this node was already visited/closed by the *other* search
        if (visited[currentStart] == _visitedByEnd) {
          final pathCost = gCostsStart[currentStart]! + gCostsEnd[currentStart]!;
          if (pathCost < bestPathCost) {
            bestPathCost = pathCost;
            meetingNode = currentStart;
          }
        }

        // Process neighbors for the forward search
        final neighborsStart = grid.getNeighbors(currentStart, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsStart) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          // Skip if unwalkable or already closed *by the start search*
          if (!neighbor.isWalkable || visited[neighbor] == _visitedByStart) continue;

          // Cost to move onto neighbor includes its weight
          final tentativeGStart = gCostsStart[currentStart]! + (getMovementCost(currentStart, neighbor) * neighbor.weight);

          // Check if visited by the end search - potential meeting point
          if (visited[neighbor] == _visitedByEnd) {
            final pathCost = tentativeGStart + gCostsEnd[neighbor]!;
            if (pathCost < bestPathCost) {
              bestPathCost = pathCost;
              meetingNode = neighbor;
              // Update parents for this potential best path
              parentsStart[neighbor] = currentStart;
              // parentsEnd[neighbor] should already be set from the other search
            }
          }

          // Update neighbor if this path from start is better
          final currentGStart = gCostsStart[neighbor] ?? double.infinity;
          if (tentativeGStart < currentGStart) {
            gCostsStart[neighbor] = tentativeGStart;
            parentsStart[neighbor] = currentStart;
            neighbor.g = tentativeGStart; // Update node's g for priority queue
            neighbor.h = weight * heuristic((neighbor.x - endX).abs(), (neighbor.y - endY).abs());
            // f is calculated implicitly by node.f getter (g + h)

            // Add or update in open list
            if (visited[neighbor] != _visitedByStart) { // Check if not already added by start search
               openListStart.add(neighbor);
               visited[neighbor] = _visitedByStart; // Mark visited by start
               neighbor.opened = true; // General opened flag for searchId
            } else {
               // Already in open list, HeapPriorityQueue handles update
            }
          }
        }
      }

      // --- Expand from End ---
      if (openListEnd.isNotEmpty) { // Check again
        final currentEnd = openListEnd.removeFirst();
        currentEnd.closed = true; // Mark closed for this search direction

        // Check if this node was already visited/closed by the *other* search
        if (visited[currentEnd] == _visitedByStart) {
          final pathCost = gCostsEnd[currentEnd]! + gCostsStart[currentEnd]!;
          if (pathCost < bestPathCost) {
            bestPathCost = pathCost;
            meetingNode = currentEnd;
          }
        }

        // Process neighbors for the backward search
        final neighborsEnd = grid.getNeighbors(currentEnd, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsEnd) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          // Skip if unwalkable or already closed *by the end search*
          if (!neighbor.isWalkable || visited[neighbor] == _visitedByEnd) continue;

          // Cost to move onto neighbor includes its weight
          final tentativeGEnd = gCostsEnd[currentEnd]! + (getMovementCost(currentEnd, neighbor) * neighbor.weight); // Cost from end

          // Check if visited by the start search - potential meeting point
          if (visited[neighbor] == _visitedByStart) {
            final pathCost = tentativeGEnd + gCostsStart[neighbor]!;
            if (pathCost < bestPathCost) {
              bestPathCost = pathCost;
              meetingNode = neighbor;
              // Update parents for this potential best path
              parentsEnd[neighbor] = currentEnd;
              // parentsStart[neighbor] should already be set
            }
          }

          // Update neighbor if this path from end is better
          final currentGEnd = gCostsEnd[neighbor] ?? double.infinity;
          if (tentativeGEnd < currentGEnd) {
            gCostsEnd[neighbor] = tentativeGEnd;
            parentsEnd[neighbor] = currentEnd;
            neighbor.g = tentativeGEnd; // Update node's g for priority queue (backward search)
            // Heuristic towards START node
            neighbor.h = weight * heuristic((neighbor.x - startX).abs(), (neighbor.y - startY).abs());
             // f is calculated implicitly by node.f getter (g + h)

            // Add or update in open list
            if (visited[neighbor] != _visitedByEnd) { // Check if not already added by end search
               openListEnd.add(neighbor);
               visited[neighbor] = _visitedByEnd; // Mark visited by end
               neighbor.opened = true; // General opened flag
            } else {
               // Already in open list, HeapPriorityQueue handles update
            }
          }
        }
      }
    } // End while loop

    // 3. No Path Found or Loop Terminated
    // If a meeting node was found, reconstruct the path. Otherwise, return empty.
    return meetingNode != null ? _biBacktrace(meetingNode, parentsStart, parentsEnd) : [];
  }

  /// Reconstructs the full path from the meeting point using the parent maps
  /// generated by the forward and backward searches.
  ///
  /// [meetingNode] The node where the two searches met for the best path found.
  /// [parentsStart] Map storing parent pointers from the forward search (start -> meeting).
  /// [parentsEnd] Map storing parent pointers from the backward search (end -> meeting).
  ///
  /// Returns the reconstructed path as a list of [Node]s from start to end.
  List<Node> _biBacktrace(Node meetingNode, Map<Node, Node> parentsStart, Map<Node, Node> parentsEnd) {
    // Trace path from meeting node back to start node
    final pathFromStart = <Node>[];
    Node? current = meetingNode;
    while (current != null) {
      pathFromStart.add(current);
      current = parentsStart[current]; // Follow parents towards start
    }
    // pathFromStart is now [meetingNode, ..., startNode]

    // Trace path from meeting node back to end node (excluding meeting node itself)
    final pathFromEnd = <Node>[];
    current = parentsEnd[meetingNode]; // Start from parent towards end
    while (current != null) {
      pathFromEnd.add(current);
      current = parentsEnd[current]; // Follow parents towards end
    }
    // pathFromEnd is now [nodeBeforeMeeting_End, ..., endNode]

    // Combine the paths: reverse start path and append end path
    // Result: [startNode, ..., meetingNode, nodeBeforeMeeting_End, ..., endNode]
    return pathFromStart.reversed.toList()..addAll(pathFromEnd);
  }
}
