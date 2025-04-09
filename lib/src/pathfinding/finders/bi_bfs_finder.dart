import 'dart:collection'; // For Queue

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart'; // Import needed for base class constructor

/// A pathfinder that implements the Bi-directional Breadth-First Search (Bi-BFS) algorithm.
///
/// This algorithm performs two simultaneous Breadth-First Searches: one starting
/// from the `startNode` and expanding outwards, and another starting from the
/// `endNode` and expanding outwards. Both searches use FIFO queues and explore
/// the grid level by level.
///
/// The search terminates as soon as a node visited by one search is encountered
/// by the other search. Because BFS explores layer by layer, the first time the
/// two search frontiers meet, the path found by combining the paths from the start
/// and end to the meeting point is guaranteed to be the shortest path in terms
/// of the **number of steps** (nodes traversed).
///
/// Like standard BFS, Bi-BFS ignores node weights and heuristics. It is most
/// effective on unweighted grids. By searching from both ends, it can often find
/// the shortest path much faster than unidirectional BFS, especially on large maps,
/// as the search radius required from each end is smaller.
///
/// This implementation uses the `Node.opened` and `Node.closed` flags slightly
/// differently to distinguish which search visited a node first.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [BreadthFirstFinder] for the unidirectional version.
/// @seealso [BiDijkstraFinder], [BiAStarFinder] for bidirectional searches on weighted grids.
class BiBreadthFirstFinder extends PathFinder {
  // We repurpose Node flags slightly for Bi-BFS state tracking within a search run.
  // Node.opened = true means the node has been reached by *either* search.
  // Node.closed = true means reached by START search.
  // Node.closed = false (and opened = true) means reached by END search.
  // This avoids needing an external 'visited' map like in Bi-A*.

  /// Creates a Bi-directional BFS pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: Inherited but **ignored** by Bi-BFS.
  /// - `weight`: Inherited but **ignored** by Bi-BFS.
  BiBreadthFirstFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    // Heuristic and weight are not used by BFS
    // Pass dummy values for ignored parameters to base constructor
    super.heuristic = Heuristics.manhattan, // Ignored
    super.weight = 1.0, // Ignored
  });

  /// Finds the shortest path (in number of steps) using Bi-directional BFS.
  ///
  /// Implements the [PathFinder.findPath] interface using two FIFO queues,
  /// expanding one level from each direction in each iteration. Ignores node
  /// weights and heuristics.
  ///
  /// Returns a list of [Node]s representing the path from start to end
  /// (inclusive), or an empty list if no path is found.
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

    final openListStart = Queue<Node>();
    final openListEnd = Queue<Node>();

    // Reset nodes
    startNode.reset(searchId);
    endNode.reset(searchId);

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }
    if (startNode == endNode) {
      return [startNode]; // Path is just the start node
    }


    // Initialize start and end nodes
    // Use node.opened to mark if visited by *any* search in this run.
    // Use node.closed to distinguish *which* search visited first:
    //   true = visited by start search
    //   false = visited by end search
    startNode.opened = true;
    startNode.closed = true; // Mark visited by start
    openListStart.add(startNode);
    // Parent for start is null (already set by reset)

    endNode.opened = true;
    endNode.closed = false; // Mark visited by end
    openListEnd.add(endNode);
    // Parent for end is null (already set by reset)


    // 2. Main Search Loop - Alternate expanding levels from start and end
    while (openListStart.isNotEmpty && openListEnd.isNotEmpty) {

      // --- Expand one level from Start ---
      int countStart = openListStart.length;
      for (int i = 0; i < countStart; ++i) {
        final currentNode = openListStart.removeFirst();

        final neighbors = grid.getNeighbors(currentNode, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighbors) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          if (!neighbor.isWalkable) continue;

          // Check if already visited
          if (neighbor.opened) {
            // If visited by the END search (neighbor.closed == false), we've met!
            if (!neighbor.closed) {
              // currentNode is from start search, neighbor is from end search
              return _biBacktrace(currentNode, neighbor);
            }
            // Else: Already visited by START search, ignore.
            continue;
          }

          // First time visiting this node (from start search)
          neighbor.parent = currentNode;
          neighbor.opened = true;
          neighbor.closed = true; // Mark visited by start
          openListStart.add(neighbor);
        }
      }

      // --- Expand one level from End ---
      int countEnd = openListEnd.length;
      for (int i = 0; i < countEnd; ++i) {
        final currentNode = openListEnd.removeFirst();

        final neighbors = grid.getNeighbors(currentNode, allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
        for (final neighbor in neighbors) {
          neighbor.resetIfNeeded(searchId); // Ensure state is fresh

          if (!neighbor.isWalkable) continue;

          // Check if already visited
          if (neighbor.opened) {
            // If visited by the START search (neighbor.closed == true), we've met!
            if (neighbor.closed) {
              // neighbor is from start search, currentNode is from end search
              return _biBacktrace(neighbor, currentNode);
            }
            // Else: Already visited by END search, ignore.
            continue;
          }

          // First time visiting this node (from end search)
          neighbor.parent = currentNode;
          neighbor.opened = true;
          neighbor.closed = false; // Mark visited by end
          openListEnd.add(neighbor);
        }
      }
    } // End while loop

    // 3. No Path Found
    return [];
  }

  /// Reconstructs the path from the two nodes where the searches met.
  ///
  /// [nodeA] The node reached by the search originating from the start node.
  /// [nodeB] The node reached by the search originating from the end node
  ///   (this is the same grid cell as nodeA, but potentially a different Node
  ///   instance if grid cloning occurred, though unlikely with searchId reset).
  ///   Its parent chain leads back to the end node.
  ///
  /// Returns the combined path from start to end.
  List<Node> _biBacktrace(Node nodeA, Node nodeB) {
    // Trace path from nodeA back to the start node
    final pathA = PathFinder.backtrace(nodeA);
    // Trace path from nodeB back to the end node
    final pathB = PathFinder.backtrace(nodeB);

    // pathA is [start..nodeA]
    // pathA is [start..nodeA] (node before meeting point from start)
    // pathB is [end..nodeB] (meeting point from end)
    // We need path from start to nodeA, then path from nodeB to end (reversed)
    // Result: [start..nodeA] + [nodeB..end]

    return pathA + pathB.reversed.toList();
  }
}
