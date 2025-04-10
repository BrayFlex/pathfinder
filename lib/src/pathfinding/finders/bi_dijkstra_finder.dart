import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart'; // Import needed for base class constructor

/// A pathfinder that implements the Bi-directional Dijkstra algorithm.
///
/// This algorithm performs two simultaneous Dijkstra searches: one starting from
/// the `startNode` and expanding outwards, and another starting from the `endNode`
/// and expanding outwards. Both searches prioritize nodes based solely on their
/// accumulated cost (`g`-cost) from their respective starting points.
///
/// The search terminates when the frontiers meet, or when a termination condition
/// based on the sum of the minimum costs in both open lists is met. By searching
/// from both ends, it can often find the shortest path by exploring fewer nodes
/// than unidirectional Dijkstra, especially on large grids.
///
/// Like standard Dijkstra, this algorithm guarantees finding the shortest path
/// in terms of accumulated cost (considering node weights from the [Grid]). It
/// does **not** use heuristics.
///
/// It maintains two separate open lists (priority queues ordered by `g`-cost),
/// two sets of cost (`g`-cost) maps, two parent pointer maps, and a shared
/// `visited` map to track which search has processed which node.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [DijkstraFinder] for the unidirectional version.
/// @seealso [BiAStarFinder] for a bidirectional heuristic search.
class BiDijkstraFinder extends PathFinder {
  // Constants used in the 'visited' map
  static const int _visitedByStart = 1;
  static const int _visitedByEnd = 2;

  /// Creates a Bi-directional Dijkstra pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: Inherited but **ignored** by Dijkstra.
  /// - `weight`: Inherited but **ignored** by Dijkstra.
  ///
  /// The algorithm *does* consider node weights ([Node.weight]) defined in the
  /// [Grid] when calculating the path cost (`g`-cost).
  BiDijkstraFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    // Pass dummy values for ignored parameters to base constructor
    super.heuristic = Heuristics.manhattan, // Ignored
    super.weight = 1.0, // Ignored
  });

  /// Finds the shortest path using the Bi-directional Dijkstra algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface by running two Dijkstra
  /// searches concurrently, prioritizing nodes based on accumulated cost (`g`).
  /// Ignores heuristics.
  ///
  /// Returns a list of [Node]s representing the shortest path found, or an
  /// empty list if no path exists.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    // 1. Initialization
    final searchId = ++grid.currentSearchId;
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      return []; // Start or end out of bounds
    }

    // Data structures for both searches
    // Need external maps for g-costs and parents as Node.g is used by both searches
    final gCostsStart = <Node, double>{};
    final gCostsEnd = <Node, double>{};
    final parentsStart = <Node, Node>{};
    final parentsEnd = <Node, Node>{};
    // Map to track which search has visited/closed a node (1=start, 2=end)
    final visited = <Node, int>{};

    // Priority queues ordered by g-cost from their respective origins
    final openListStart = HeapPriorityQueue<Node>((a, b) => gCostsStart[a]!.compareTo(gCostsStart[b]!));
    final openListEnd = HeapPriorityQueue<Node>((a, b) => gCostsEnd[a]!.compareTo(gCostsEnd[b]!));

    double bestPathCost = double.infinity; // Cost of the best complete path found so far
    Node? meetingNode; // Node where the two searches meet for the best path

    // Reset start/end nodes
    startNode.reset(searchId);
    endNode.reset(searchId);

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }
    if (startNode == endNode) {
      return [startNode];
    }

    // Initialize start node for forward search
    gCostsStart[startNode] = 0;
    openListStart.add(startNode);
    visited[startNode] = _visitedByStart;
    startNode.opened = true; // Use node state for general open/closed status in this search run

    // Initialize end node for backward search
    gCostsEnd[endNode] = 0;
    openListEnd.add(endNode);
    visited[endNode] = _visitedByEnd;
    endNode.opened = true;

    // 2. Main Search Loop
    while (openListStart.isNotEmpty && openListEnd.isNotEmpty) {

      // --- Termination Condition ---
      // Check if the sum of minimum costs from both open lists meets or exceeds
      // the best complete path found so far.
      final minCostSum = gCostsStart[openListStart.first]! + gCostsEnd[openListEnd.first]!;
      if (meetingNode != null && minCostSum >= bestPathCost) {
        return _biBacktrace(meetingNode, parentsStart, parentsEnd);
      }

      // --- Expand from Start ---
      if (openListStart.isNotEmpty) { // Check again
        final currentStart = openListStart.removeFirst();
        // Use the 'visited' map to track closure specific to this direction
        // Node.closed is not used here to avoid conflict between searches

        // Process neighbors for the forward search
        final neighborsStart = grid.getNeighbors(currentStart, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsStart) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          // Skip if unwalkable or already closed *by the start search*
          if (!neighbor.isWalkable || visited[neighbor] == _visitedByStart) continue;

          final tentativeGStart = gCostsStart[currentStart]! + getMovementCost(currentStart, neighbor);

          // Check if visited by the end search - potential meeting point
          if (visited[neighbor] == _visitedByEnd) {
            final pathCost = tentativeGStart + gCostsEnd[neighbor]!;
            if (pathCost < bestPathCost) {
              bestPathCost = pathCost;
              meetingNode = neighbor;
              parentsStart[neighbor] = currentStart; // Update parent for this path
            }
          }

          // Update neighbor if this path from start is better
          final currentGStart = gCostsStart[neighbor] ?? double.infinity;
          if (tentativeGStart < currentGStart) {
            gCostsStart[neighbor] = tentativeGStart;
            parentsStart[neighbor] = currentStart;
            neighbor.opened = true; // Mark as potentially open

            // Add or update in open list
            // Check if already visited by start to avoid redundant adds/updates
            if (visited[neighbor] != _visitedByStart) {
               openListStart.add(neighbor);
               visited[neighbor] = _visitedByStart; // Mark visited by start
            } else {
               // Already in open list, HeapPriorityQueue handles update
            }
          }
        }
      }

      // --- Expand from End ---
      if (openListEnd.isNotEmpty) { // Check again
        final currentEnd = openListEnd.removeFirst();
        // Use the 'visited' map to track closure specific to this direction

        // Process neighbors for the backward search
        final neighborsEnd = grid.getNeighbors(currentEnd, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsEnd) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          // Skip if unwalkable or already closed *by the end search*
          if (!neighbor.isWalkable || visited[neighbor] == _visitedByEnd) continue;

          final tentativeGEnd = gCostsEnd[currentEnd]! + getMovementCost(currentEnd, neighbor); // Cost from end

          // Check if visited by the start search - potential meeting point
          if (visited[neighbor] == _visitedByStart) {
            final pathCost = tentativeGEnd + gCostsStart[neighbor]!;
            if (pathCost < bestPathCost) {
              bestPathCost = pathCost;
              meetingNode = neighbor;
              parentsEnd[neighbor] = currentEnd; // Update parent for this path
            }
          }

          // Update neighbor if this path from end is better
          final currentGEnd = gCostsEnd[neighbor] ?? double.infinity;
          if (tentativeGEnd < currentGEnd) {
            gCostsEnd[neighbor] = tentativeGEnd;
            parentsEnd[neighbor] = currentEnd;
            neighbor.opened = true; // Mark as potentially open

            // Add or update in open list
            if (visited[neighbor] != _visitedByEnd) {
               openListEnd.add(neighbor);
               visited[neighbor] = _visitedByEnd; // Mark visited by end
            } else {
               // Already in open list, HeapPriorityQueue handles update
            }
          }
        }
      }
    } // End while loop

    // 3. No Path Found or Loop Terminated
    return meetingNode != null ? _biBacktrace(meetingNode, parentsStart, parentsEnd) : [];
  }

  /// Reconstructs the full path from the meeting point using the parent maps.
  /// Identical to the one used in BiAStarFinder.
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
    return pathFromStart.reversed.toList()..addAll(pathFromEnd);
  }
}
