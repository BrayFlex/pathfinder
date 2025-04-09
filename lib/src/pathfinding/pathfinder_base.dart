import 'grid.dart';
import 'node.dart';
import 'heuristics.dart';

/// Abstract base class for all grid-based pathfinding algorithms.
///
/// This class defines the common interface (`findPath`) and configuration options
/// shared by different pathfinding implementations (like A*, Dijkstra, JPS).
/// Concrete pathfinder classes (e.g., [AStarFinder], [DijkstraFinder]) should
/// extend this class and implement the [findPath] method with their specific
/// search logic.
///
/// Common configuration options like movement rules ([allowDiagonal],
/// [dontCrossCorners]) and heuristic usage ([heuristic], [weight]) are
/// handled in this base class constructor.
///
/// @seealso [Grid], [Node], [Heuristics]
abstract class PathFinder {
  /// Determines whether diagonal movement between nodes is permitted during the search.
  /// If `false`, only cardinal (horizontal/vertical) movement is considered.
  final bool allowDiagonal;

  /// If diagonal movement ([allowDiagonal] is `true`), this specifies whether
  /// movement is permitted diagonally across the corner of an unwalkable node.
  /// If `true`, diagonal movement from A to B is only allowed if both intermediate
  /// cardinal neighbors (forming the corner) are walkable.
  /// If `false`, diagonal movement only requires the target diagonal node B
  /// itself to be walkable.
  final bool dontCrossCorners;

  /// The heuristic function used by the algorithm to estimate the cost from a
  /// given node to the target node. This is crucial for informed search
  /// algorithms like A* and Best-First Search. It is ignored by uninformed
  /// algorithms like Dijkstra and BFS.
  /// Defaults to [Heuristics.manhattan].
  /// @seealso [Heuristics] for available standard heuristics.
  final HeuristicFunction heuristic;

  /// A weight applied to the heuristic estimate ([Node.h]). A weight > 1.0
  /// can sometimes speed up A* search by making it more "greedy" but may
  /// sacrifice path optimality (Weighted A*). A weight of 1.0 results in
  /// standard A*. Defaults to `1.0`.
  final double weight;

  /// Constructor for the base pathfinder, initializing common options.
  ///
  /// Subclasses should call this constructor via `super(...)` to pass along
  /// the configuration options.
  ///
  /// [allowDiagonal] Sets whether diagonal movement is allowed (default: `false`).
  /// [dontCrossCorners] Sets the corner-crossing rule for diagonal movement
  ///   (default: `false`). Only relevant if `allowDiagonal` is `true`.
  /// [heuristic] The heuristic function to use (default: [Heuristics.manhattan]).
  ///   Relevant for A*, BestFirst, etc.
  /// [weight] The weight applied to the heuristic (default: `1.0`). Relevant
  ///   for heuristic-based searches.
  PathFinder({
    this.allowDiagonal = false,
    this.dontCrossCorners = false,
    this.heuristic = Heuristics.manhattan,
    this.weight = 1.0,
  }) {
    // Basic validation for weight could be added here if desired, e.g., assert(weight >= 0);
  }

  /// Finds a path between the start and end coordinates on the given grid.
  ///
  /// This is the core method that must be implemented by concrete subclasses.
  /// It performs the search algorithm logic.
  ///
  /// Before starting the search, implementations should typically:
  /// 1. Increment the grid's search ID: `grid.currentSearchId++`.
  /// 2. Obtain start and end nodes using `grid.getNodeAt`.
  /// 3. Handle edge cases (start/end out of bounds, start == end, unwalkable start/end).
  /// 4. Initialize the open list/set with the start node.
  /// 5. Reset the start node's state using `startNode.resetIfNeeded(grid.currentSearchId)`.
  ///
  /// During the search, implementations should use `node.resetIfNeeded(grid.currentSearchId)`
  /// on each node before accessing its pathfinding state (`g`, `h`, `parent`, etc.).
  /// They should use `grid.getNeighbors(node, allowDiagonal: ..., dontCrossCorners: ...)`
  /// to find valid neighbors based on the finder's configuration.
  ///
  /// If a path is found, the implementation should typically use the static
  /// [backtrace] method to reconstruct the path from the end node's parent chain.
  ///
  /// [startX], [startY] Coordinates of the starting node.
  /// [endX], [endY] Coordinates of the target node.
  /// [grid] The [Grid] instance representing the search space. Note that the
  ///   algorithm will modify the state of nodes within this grid during the
  ///   search (costs, parent pointers, open/closed status). Thanks to the
  ///   `currentSearchId` mechanism, cloning the grid ([Grid.clone]) before
  ///   calling `findPath` is often **not required** unless you need to preserve
  ///   the grid's node state from before the search for other purposes.
  ///
  /// Returns a list of [Node] objects representing the path from the start node
  /// to the end node (inclusive). The list is ordered from start to end.
  /// Returns an empty list (`[]`) if no path is found.
  List<Node> findPath(int startX, int startY, int endX, int endY, Grid grid);

  /// Reconstructs the path by backtracking from the end node using parent references.
  ///
  /// This is a static utility method commonly used by `findPath` implementations
  /// once the target node has been reached and its `parent` chain reflects the
  /// path found.
  ///
  /// [node] The target [Node] from which to backtrack.
  ///
  /// Returns a list of [Node] objects representing the path, ordered from the
  /// start node to the provided end [node].
  static List<Node> backtrace(Node node) {
    final path = <Node>[];
    Node? current = node; // Start from the end node itself
    while (current != null) {
      path.add(current);
      current = current.parent;
    }
    // The path is currently from end to start, so reverse it.
    return path.reversed.toList();
  }

   /// Calculates the cost of moving between two adjacent nodes.
   ///
   /// This helper method considers the base weight of the destination node
   /// ([Node.weight]) and applies an additional cost factor for diagonal movement
   /// if applicable (approximating sqrt(2)).
   ///
   /// Pathfinding algorithms use this to calculate the `g` cost when moving
   /// from one node to a neighbor.
   ///
   /// [nodeA] The node being moved from.
   /// [nodeB] The adjacent destination node being moved to.
   ///
   /// Returns the calculated movement cost.
   double getMovementCost(Node nodeA, Node nodeB) {
    // This base implementation assumes nodeA and nodeB are adjacent.
    // More complex implementations could handle non-adjacent nodes if needed,
    // but standard grid pathfinders rely on adjacency.
    final dx = (nodeA.x - nodeB.x).abs();
    final dy = (nodeA.y - nodeB.y).abs();

    // Start with the intrinsic cost (weight) of the node being entered.
    double cost = nodeB.weight;

    // Apply diagonal cost multiplier if moving diagonally *and* the specific
    // algorithm requires it (like A*). For step-based counts (like BFS, or potentially
    // how IDA* length is being compared in tests), treat all steps as cost 1 initially.
    // Let the algorithm's g-cost accumulation handle weights.
    // if (dx == 1 && dy == 1) {
    //   cost *= 1.414213562373095; // ~ sqrt(2)
    // }
    // Return base weight for cardinal, or base weight * sqrt(2) for diagonal?
    // Let's simplify for now: return 1 * weight for any move.
    // This might break optimality for A* if heuristic assumes sqrt(2), but might fix length issues.
    // Revert: Let's keep the sqrt(2) but ensure it's only applied when needed.
    // The base cost should just be the weight. The pathfinder adds this base cost.
    // A* adds getMovementCost which includes sqrt(2). IDA* adds getMovementCost.
    // Maybe the issue is IDA* path length vs cost?

    // Let's try the original logic again, maybe the IDA* implementation had another bug.
     if (dx == 1 && dy == 1) {
       cost *= 1.414213562373095; // ~ sqrt(2)
     }
     // For cardinal movement (dx=1, dy=0 or dx=0, dy=1), cost remains nodeB.weight.

     return cost;
  }
}
