import 'package:collection/collection.dart'; // Added import

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the Bi-directional Best-First Search algorithm.
///
/// This algorithm performs two simultaneous Best-First searches: one starting
/// from the `startNode` and moving towards the `endNode`, and another starting
/// from the `endNode` and moving towards the `startNode`. Both searches prioritize
/// nodes based solely on their heuristic cost (`h`-cost) to their respective targets.
///
/// The search terminates as soon as a node visited by one search is encountered
/// by the other search (i.e., the frontiers meet).
///
/// Like unidirectional Best-First Search, this algorithm is often very fast at
/// finding *a* path because it greedily explores nodes that seem closest to the
/// target. However, because it ignores the actual path cost (`g`-cost), it does
/// **not** guarantee finding the *shortest* path.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [BestFirstFinder] for the unidirectional version.
/// @seealso [BiAStarFinder] for a bidirectional search that guarantees optimality.
class BiBestFirstFinder extends PathFinder {
  // Constants used in the 'visited' map
  static const int _visitedByStart = 1;
  static const int _visitedByEnd = 2;

  /// Creates a Bi-directional Best-First Search pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost. This is the
  ///   sole factor driving node prioritization in both search directions.
  /// - `weight`: Inherited but **ignored** by Best-First Search prioritization.
  BiBestFirstFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    super.heuristic, // Pass through constructor value or base default
    super.weight = 1.0, // Ignored
  });

  /// Finds a path using the Bi-directional Best-First Search algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface by running two Best-First
  /// searches concurrently, prioritizing nodes based solely on heuristic cost (`h`).
  ///
  /// Returns a list of [Node]s representing the first path found when the searches
  /// meet, or an empty list if no path exists. **Note:** The path found is not
  /// guaranteed to be the shortest.
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
    final openListStart = HeapPriorityQueue<Node>((a, b) => a.h.compareTo(b.h)); // Order by h-cost
    final openListEnd = HeapPriorityQueue<Node>((a, b) => a.h.compareTo(b.h));   // Order by h-cost
    final parentsStart = <Node, Node>{};
    final parentsEnd = <Node, Node>{};
    // Use Node.opened and Node.closed managed by searchId for visited state
    // Need a way to distinguish which search visited/closed. Use external map.
    final visited = <Node, int>{}; // 1: start, 2: end

    // Reset start/end nodes
    startNode.reset(searchId);
    endNode.reset(searchId);

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }

    // Handle the trivial case where start and end are the same.
    if (startNode == endNode) {
      return [startNode];
    }

    // Initialize start node for forward search
    startNode.h = heuristic((startX - endX).abs(), (startY - endY).abs());
    openListStart.add(startNode);
    visited[startNode] = _visitedByStart;
    parentsStart[startNode] = startNode; // Mark start as its own parent for backtrace termination
    startNode.opened = true;

    // Initialize end node for backward search
    endNode.h = heuristic((endX - startX).abs(), (endY - startY).abs()); // Heuristic to start
    openListEnd.add(endNode);
    visited[endNode] = _visitedByEnd;
    parentsEnd[endNode] = endNode; // Mark end as its own parent
    endNode.opened = true;

    // 2. Main Search Loop
    while (openListStart.isNotEmpty && openListEnd.isNotEmpty) {

      // --- Expand from Start ---
      if (openListStart.isNotEmpty) {
        final currentStart = openListStart.removeFirst();
        currentStart.closed = true; // Mark closed for this search direction

        final neighborsStart = grid.getNeighbors(currentStart, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsStart) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          if (!neighbor.isWalkable || visited[neighbor] == _visitedByStart) {
             // Skip unwalkable or already visited *by this search*
             continue;
          }

          // Check if met the other search
          if (visited[neighbor] == _visitedByEnd) {
            parentsStart[neighbor] = currentStart; // Set parent for the meeting node
            return _biBacktrace(neighbor, parentsStart, parentsEnd); // Path found!
          }

          // Mark visited, set parent, calculate heuristic, add to open list
          visited[neighbor] = _visitedByStart;
          parentsStart[neighbor] = currentStart;
          neighbor.h = heuristic((neighbor.x - endX).abs(), (neighbor.y - endY).abs());
          neighbor.opened = true;
          openListStart.add(neighbor);
        }
      }

      // --- Expand from End ---
      if (openListEnd.isNotEmpty) {
        final currentEnd = openListEnd.removeFirst();
        currentEnd.closed = true; // Mark closed for this search direction

        final neighborsEnd = grid.getNeighbors(currentEnd, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighborsEnd) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          if (!neighbor.isWalkable || visited[neighbor] == _visitedByEnd) {
             // Skip unwalkable or already visited *by this search*
             continue;
          }

          // Check if met the other search
          if (visited[neighbor] == _visitedByStart) {
            parentsEnd[neighbor] = currentEnd; // Set parent for the meeting node
            return _biBacktrace(neighbor, parentsStart, parentsEnd); // Path found!
          }

          // Mark visited, set parent, calculate heuristic, add to open list
          visited[neighbor] = _visitedByEnd;
          parentsEnd[neighbor] = currentEnd;
          neighbor.h = heuristic((neighbor.x - startX).abs(), (neighbor.y - startY).abs()); // Heuristic to start
          neighbor.opened = true;
          openListEnd.add(neighbor);
        }
      }
    } // End while loop

    // 3. No Path Found
    return [];
  }

  /// Reconstructs the path from the meeting point using separate parent maps.
  /// Identical to the one used in BiAStarFinder.
  ///
  /// [meetingNode] The node where the two searches met.
  /// [parentsStart] Map storing parent pointers from the forward search (start -> meeting).
  /// [parentsEnd] Map storing parent pointers from the backward search (end -> meeting).
  ///
  /// Returns the reconstructed path as a list of [Node]s from start to end.
  List<Node> _biBacktrace(Node meetingNode, Map<Node, Node> parentsStart, Map<Node, Node> parentsEnd) {
    final pathFromStart = <Node>[];
    Node? current = meetingNode;
    // Trace back from meeting point to start node
    while (current != null && parentsStart[current] != current) { // Stop at start node marker
      pathFromStart.add(current);
      current = parentsStart[current];
    }
    if (current != null) pathFromStart.add(current); // Add the actual start node

    final pathFromEnd = <Node>[];
    current = parentsEnd[meetingNode]; // Start from the node *before* the meeting node in the end path
    // Trace back from node before meeting point to end node
    while (current != null && parentsEnd[current] != current) { // Stop at end node marker
      pathFromEnd.add(current);
      current = parentsEnd[current];
    }
     if (current != null) pathFromEnd.add(current); // Add the actual end node

    // Combine: [start...meeting] + [meeting_neighbor_from_end...end]
    return pathFromStart.reversed.toList()..addAll(pathFromEnd);
  }
}
