import 'grid.dart'; // For doc links

/// Represents a single node or cell within a pathfinding [Grid].
///
/// Each node stores its grid coordinates (`x`, `y`), its structural properties
/// like walkability ([isWalkable]) and movement cost ([weight]), and temporary
/// data used by pathfinding algorithms during a search. This temporary data
/// includes costs ([g], [h], [f]), parent references for path reconstruction
/// ([parent]), and status flags ([opened], [closed]).
///
/// The pathfinding state is efficiently managed using a search ID mechanism
/// ([resetIfNeeded], [reset]) tied to the [Grid.currentSearchId], allowing
/// nodes to reset their state lazily only when accessed by a new search,
/// often avoiding the need for full grid cloning or iteration.
///
/// @seealso [Grid], [PathFinder]
class Node {
  /// The x-coordinate (column index) of the node in the grid.
  final int x;

  /// The y-coordinate (row index) of the node in the grid.
  final int y;

  /// Indicates whether this node can be traversed by an agent.
  /// `true` if the node is walkable, `false` if it's an obstacle.
  /// This can be modified after creation using [Grid.setWalkableAt].
  bool isWalkable;

  /// The movement cost multiplier for traversing this node.
  /// Defaults to `1.0`. Higher values represent more difficult terrain
  /// (e.g., swamps, hills). Must be >= 1.0. Pathfinding algorithms use this
  /// weight when calculating the cost ([g]) of moving between nodes.
  /// This can be modified after creation using [Grid.setWeightAt].
  double weight;

  // --- Pathfinding Algorithm Data ---
  // These fields store temporary state used during a pathfinding search.
  // They are managed by the node's reset mechanism ([resetIfNeeded], [reset])
  // in conjunction with the Grid's currentSearchId.

  /// The parent node that leads to this node along the currently known best path
  /// from the start node. Used by [PathFinder.backtrace] to reconstruct the
  /// final path after the target node is reached. `null` if the node hasn't
  /// been reached or is the start node.
  Node? parent;

  /// The actual cost of the path from the start node to this node, as calculated
  /// by the pathfinding algorithm so far (often called the "g-cost").
  double g = 0;

  /// The estimated heuristic cost from this node to the target node (often
  /// called the "h-cost"). This value is calculated using the heuristic function
  /// provided to the [PathFinder].
  double h = 0;

  /// The total estimated cost of the path from the start node to the target node
  /// going through this node. It's calculated as `f = g + h`. Pathfinding
  /// algorithms like A* use this value to prioritize which nodes to explore next.
  double get f => g + h;

  /// Flag indicating whether the node has been added to the "closed set" by the
  /// pathfinding algorithm. The closed set contains nodes that have already been
  /// fully evaluated and do not need to be considered again in the current search.
  /// (Note: Some algorithms like Jump Point Search might use this flag differently).
  bool closed = false;

  /// Flag indicating whether the node is currently in the "open set" (or "frontier")
  /// of the pathfinding algorithm. The open set contains nodes that have been
  /// discovered but not yet fully evaluated. Algorithms typically select the
  /// most promising node from the open set to evaluate next.
  bool opened = false;

  /// Internal state tracking the ID of the search run that last reset this node.
  /// Used by [resetIfNeeded] to determine if the node's pathfinding data
  /// ([g], [h], [parent], [opened], [closed]) is stale and needs resetting.
  int _lastResetSearchId = -1;

  /// Creates a new node with specified coordinates and properties.
  ///
  /// [x] The x-coordinate (column) in the grid.
  /// [y] The y-coordinate (row) in the grid.
  /// [isWalkable] Whether the node is initially traversable (defaults to `true`).
  /// [weight] The initial movement cost multiplier (defaults to `1.0`, must be >= 1.0).
  Node(this.x, this.y, {this.isWalkable = true, this.weight = 1.0}) {
     // Ensure initial weight is valid, although Grid constructor also checks defaultWeight.
     // Grid.setWeightAt provides the primary validation for runtime changes.
     assert(weight >= 1.0, 'Node weight cannot be less than 1.0');
  }


  /// Resets the node's pathfinding state if it hasn't been reset for the
  /// current search run.
  ///
  /// This method implements the lazy state reset optimization. It compares the
  /// [currentSearchId] (obtained from `Grid.currentSearchId` at the start of
  /// a pathfinding search) with the node's [_lastResetSearchId].
  ///
  /// If the IDs differ, it means the node's current pathfinding data (`g`, `h`,
  /// `parent`, `opened`, `closed`) is from a previous search and is stale.
  /// In this case, it calls [reset] to clear the state and updates
  /// [_lastResetSearchId] to the [currentSearchId].
  ///
  /// If the IDs match, the node has already been reset for the current search
  /// (or is being encountered again within the same search), and no action is taken.
  ///
  /// Pathfinding algorithms should call this method on a node before using its
  /// pathfinding state variables (`g`, `h`, `f`, `parent`, `opened`, `closed`).
  ///
  /// [currentSearchId] The ID of the current pathfinding search run, typically
  ///   incremented by the [PathFinder] via `grid.currentSearchId++`.
  /// Returns `true` if the node state was reset, `false` otherwise.
  bool resetIfNeeded(int currentSearchId) {
    if (_lastResetSearchId != currentSearchId) {
      reset(currentSearchId);
      return true;
    }
    return false;
  }

  /// Forcefully resets the pathfinding-specific data ([g], [h], [parent],
  /// [opened], [closed]) for this node and updates its internal reset marker
  /// to the given [currentSearchId].
  ///
  /// This method is primarily called internally by [resetIfNeeded]. It can
  /// also be called directly if an explicit reset is required outside the
  /// typical lazy reset mechanism, though this is usually unnecessary.
  ///
  /// Note: This does **not** reset the node's structural properties like
  /// [isWalkable] or [weight].
  ///
  /// [currentSearchId] The search ID to associate with this reset state.
  void reset(int currentSearchId) {
    g = 0;
    h = 0;
    parent = null;
    closed = false;
    opened = false;
    _lastResetSearchId = currentSearchId;
  }

  /// Returns a string representation of the node, primarily for debugging.
  @override
  String toString() {
    return 'Node($x, $y, walkable: $isWalkable, weight: $weight)';
  }

  /// Nodes are considered equal if they have the same x and y coordinates.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Node &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y;

  /// Computes a hash code based on the node's x and y coordinates.
  @override
  int get hashCode => x.hashCode ^ y.hashCode;
}
