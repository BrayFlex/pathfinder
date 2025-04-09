import 'dart:math';

import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../grid.dart';
import '../node.dart';
import '../pathfinder_base.dart';
import '../heuristics.dart';

/// A pathfinder that implements the Iterative Deepening A* (IDA*) algorithm.
///
/// IDA* combines the shortest path guarantee of A* with the low memory usage
/// of depth-first search (DFS). It performs a sequence of bounded DFS traversals.
/// Each traversal explores paths only up to a certain total estimated cost (`f = g + h`)
/// limit, called the "threshold".
///
/// The initial threshold is set to the heuristic estimate from the start node to
/// the end node. In each iteration:
/// 1. A DFS is performed, pruning any path whose `f`-cost exceeds the current threshold.
/// 2. If the target node is found during the DFS, the path is returned (guaranteed
///    to be optimal because the threshold started at the minimum possible `f`-cost).
/// 3. If the target is not found, the threshold for the next iteration is set to
///    the minimum `f`-cost encountered among all the paths that were pruned
///    (i.e., the smallest cost that exceeded the previous threshold).
/// 4. The process repeats with the new, higher threshold.
///
/// This avoids storing a large open list like A*, making it suitable for problems
/// with huge search spaces where memory is a constraint. However, it can revisit
/// nodes multiple times across different iterations, which might lead to longer
/// execution times compared to A* in some cases.
///
/// An [iterationLimit] is included as a safety measure to prevent potential
/// infinite loops in scenarios with unreachable targets or problematic heuristics,
/// although theoretically, IDA* should terminate if a path exists or prove no
/// path exists by exceeding a reasonable cost bound.
///
/// @seealso [PathFinder] for the base class and common options.
/// @seealso [AStarFinder] for the standard A* implementation (uses more memory).
class IDAStarFinder extends PathFinder {
  /// Maximum number of nodes to process within a single depth-first search
  /// iteration. This acts as a safeguard against potential infinite loops or
  /// excessively long searches, especially if the target is unreachable or the
  /// heuristic/grid setup is unusual. Defaults to `1,000,000`.
  final int iterationLimit;

  /// Creates an IDA* pathfinder instance.
  ///
  /// Inherits options from [PathFinder]:
  /// - `allowDiagonal`: Whether diagonal movement is permitted.
  /// - `dontCrossCorners`: Rule for diagonal movement past corners.
  /// - `heuristic`: The [HeuristicFunction] used to estimate cost (`h`-cost) and
  ///   set the initial threshold. Must be admissible for optimality.
  /// - `weight`: Weight applied to the heuristic (`h`-cost).
  ///
  /// Additional IDA* specific options:
  /// - [iterationLimit]: Safety limit for nodes processed per DFS iteration
  ///   (default: `1,000,000`).
  IDAStarFinder({
    super.allowDiagonal = false,
    super.dontCrossCorners = false,
    super.heuristic, // Pass through constructor value or base default
    super.weight,    // Pass through constructor value or base default
    this.iterationLimit = 1000000,
  });

  /// Finds the shortest path using the IDA* algorithm.
  ///
  /// Implements the [PathFinder.findPath] interface by performing iterative
  /// depth-first searches with increasing cost thresholds.
  ///
  /// Returns a list of [Node]s representing the shortest path found, or an
  /// empty list if no path exists or the search exceeds limits.
  @override
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid) {
    Node startNode;
    Node endNode;

    try {
      startNode = grid.getNodeAt(startX, startY);
      endNode = grid.getNodeAt(endX, endY);
    } catch (e) {
      return []; // Start or end out of bounds
    }

    // Basic validation
    if (!startNode.isWalkable || !endNode.isWalkable) {
      return [];
    }

    // Note: IDA* doesn't use the Grid's searchId mechanism for node reset,
    // as nodes are revisited across iterations. State (like parent) is managed
    // within the recursive _search calls.

    // Initial threshold based on heuristic from start to end.
    double threshold = weight * heuristic((startX - endNode.x).abs(), (startY - endNode.y).abs());

    // Iteratively deepen the search with increasing thresholds.
    while (true) {
      // Perform a bounded DFS starting from the start node.
      // Pass 0 for initial gCost and node count.
      final result = _search(startNode, 0.0, threshold, endNode, grid, 0);

      if (result is List<Node>) {
        // Path found within the current threshold.
        return result;
      }

      if (result == double.infinity) {
        // Search exhausted (possibly hit iteration limit or no path exists
        // within reasonable cost bounds).
        return [];
      }

      // Target not found in this iteration. Update threshold for the next DFS.
      // The result is the minimum f-cost that exceeded the previous threshold.
      threshold = result as double;

      // Optional safety check: Prevent excessively large thresholds if no path exists.
      // This limit might need tuning based on expected path costs.
      final maxPossibleCost = grid.width * grid.height * 10.0; // Heuristic upper bound
      if (threshold > maxPossibleCost) {
         // print("IDA* threshold exceeded a reasonable limit ($threshold > $maxPossibleCost), assuming no path exists.");
         return [];
      }
    }
  }

  /// Performs a recursive, depth-first search bounded by the cost [threshold].
  ///
  /// This is the core recursive function of IDA*. It explores paths from the
  /// [currentNode] as long as their estimated total cost (`f = g + h`) does not
  /// exceed the [threshold].
  ///
  /// It temporarily sets the `parent` property of nodes during traversal to
  /// allow path reconstruction if the goal is found.
  ///
  /// [currentNode] The node currently being explored.
  /// [gCost] The actual cost accumulated to reach the `currentNode`.
  /// [threshold] The maximum allowed `f`-cost for the current DFS iteration.
  /// [endNode] The target node of the search.
  /// [grid] The grid being searched.
  /// [nodesProcessed] Counter for nodes visited in this specific DFS iteration
  ///   (used for the [iterationLimit] safety check).
  ///
  /// Returns:
  /// - A `List<Node>` representing the path if the [endNode] is found.
  /// - A `double` representing the minimum `f`-cost encountered that exceeded
  ///   the [threshold], which will be used as the threshold for the next iteration.
  /// - `double.infinity` if the [iterationLimit] is reached, indicating search failure.
  dynamic _search(Node currentNode, double gCost, double threshold, Node endNode, Grid grid, int nodesProcessed) {
    // --- Safety Check ---
    if (nodesProcessed > iterationLimit) {
      // print("IDA* iteration limit reached during DFS.");
      return double.infinity; // Indicate failure due to limit
    }

    // --- Calculate Costs ---
    // Note: We don't use node.g directly as it might be from a previous iteration.
    // We pass the current path's gCost down the recursion.
    final hCost = weight * heuristic((currentNode.x - endNode.x).abs(), (currentNode.y - endNode.y).abs());
    final fCost = gCost + hCost;

    // --- Pruning ---
    // If the estimated cost to reach the goal through this node exceeds the
    // current threshold, prune this path and return the exceeding cost.
    if (fCost > threshold) {
      return fCost;
    }

    // --- Goal Check ---
    if (currentNode == endNode) {
      // Target found! Reconstruct the path using the parent pointers set
      // during this successful DFS traversal.
       final path = <Node>[];
       Node? temp = currentNode;
       while(temp != null) {
         path.add(temp);
         // Follow the parent links set *within this specific _search call stack*.
         temp = temp.parent;
       }
       return path.reversed.toList();
    }

    // --- Explore Neighbors ---
    double minExceededCost = double.infinity; // Track the minimum cost > threshold found in sub-branches

    final neighbors = grid.getNeighbors(
      currentNode,
      allowDiagonal: allowDiagonal,
      dontCrossCorners: dontCrossCorners,
    );

    // Optional: Sort neighbors by heuristic for potentially faster goal finding,
    // though not strictly required by IDA*.
    // neighbors.sort((a, b) => heuristic(...a...).compareTo(heuristic(...b...)));

    for (final neighbor in neighbors) {
      // Basic cycle check: Don't immediately go back to the node we just came from.
      // More complex cycle detection isn't typically needed in IDA* on grids
      // because the increasing threshold naturally handles longer paths.
      if (neighbor == currentNode.parent) {
         continue;
      }

      if (!neighbor.isWalkable) continue;

      // Calculate cost to reach the neighbor. getMovementCost already includes weight.
      final newGCost = gCost + getMovementCost(currentNode, neighbor);

      // --- Recursive Call ---
      // Temporarily set the parent for this path exploration.
      final originalParent = neighbor.parent; // Store parent from previous iterations/paths
      neighbor.parent = currentNode;

      final result = _search(neighbor, newGCost, threshold, endNode, grid, nodesProcessed + 1);

      // Restore the original parent if this recursive call didn't find the goal.
      // This is crucial because the node might be visited again via a different path
      // in the same or a later iteration.
      if (result is! List<Node>) {
         neighbor.parent = originalParent;
      }
      // --- End Recursive Call ---


      if (result is List<Node>) {
        // Path found down this branch, return it up the call stack.
        return result;
      }

      // If the recursive call returned a cost (meaning it exceeded the threshold),
      // update our minimum exceeded cost if this one is lower.
      if (result < minExceededCost) {
        minExceededCost = result as double;
      }
    }

    // If no path was found from this node within the threshold, return the
    // minimum cost found that exceeded the threshold in its sub-branches.
    return minExceededCost;
  }
}
