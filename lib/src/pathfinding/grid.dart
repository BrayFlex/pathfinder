import 'node.dart';
import 'pathfinder_base.dart'; // For doc links

/// Represents the 2D grid map used as the search space for pathfinding algorithms.
///
/// This class manages a 2D array of [Node] objects, representing the discrete
/// cells or locations within the environment. It provides methods for accessing
/// nodes, checking their walkability status, retrieving neighbors based on
/// movement rules (cardinal/diagonal), and managing node state efficiently
/// between pathfinding searches.
///
/// Grids can be initialized with dimensions and optionally a matrix defining
/// obstacles. Node weights can also be set to represent varying terrain costs.
///
/// ```dart
/// // Create a 10x10 grid, all walkable with default weight 1.0
/// var grid = Grid(10, 10);
///
/// // Create a 5x5 grid from a matrix (0=walkable, 1=obstacle)
/// var obstacleMatrix = [
///   [0, 0, 0, 0, 0],
///   [0, 1, 1, 0, 0], // Obstacles at (1,1) and (2,1)
///   [0, 0, 0, 1, 0], // Obstacle at (3,2)
///   [0, 1, 0, 0, 0], // Obstacle at (1,3)
///   [0, 0, 0, 0, 0],
/// ];
/// var gridFromMatrix = Grid(5, 5, matrix: obstacleMatrix);
///
/// // Modify the grid dynamically
/// grid.setWalkableAt(2, 3, false); // Add an obstacle
/// grid.setWeightAt(4, 4, 5.0);   // Make cell (4,4) high cost (e.g., swamp)
///
/// // Use the grid with a pathfinder
/// var finder = AStarFinder(allowDiagonal: true);
/// var path = finder.findPath(0, 0, 9, 9, grid);
/// ```
///
/// @seealso [Node], [PathFinder]
class Grid {
  /// The width of the grid in number of nodes (columns).
  final int width;

  /// The height of the grid in number of nodes (rows).
  final int height;

  /// The internal 2D list representing the grid nodes.
  /// Access via `_nodes[y][x]`, where `y` is the row index and `x` is the
  /// column index. Direct access is discouraged; use [getNodeAt] instead.
  late final List<List<Node>> _nodes;

  /// A counter used to uniquely identify pathfinding search runs.
  ///
  /// This ID is incremented by a [PathFinder] before starting a search
  /// (`grid.currentSearchId++`). Each [Node] stores the `searchId` of the last
  /// search it participated in. When a node is accessed during a search, it
  /// compares its stored `searchId` with the grid's `currentSearchId`. If they
  /// differ, the node knows it needs to reset its pathfinding state (like `g`,
  /// `h`, `f` costs, `parent`, `isOpen`, `isClosed`) before being used in the
  /// new search.
  ///
  /// This mechanism avoids the need to iterate through all nodes in the grid
  /// to reset them before each search, significantly improving performance,
  /// especially for large grids or frequent pathfinding calls. It also often
  /// eliminates the need to [clone] the grid for every search, unless the
  /// underlying walkability or weights need to be preserved in their pre-search
  /// state for other purposes.
  int currentSearchId = 0;

  /// Creates a grid with the specified dimensions and optional initial state.
  ///
  /// All nodes are initialized as walkable with the [defaultWeight] unless
  /// an obstacle [matrix] is provided.
  ///
  /// Throws [ArgumentError] if width or height are non-positive, or if the
  /// provided matrix dimensions do not match the specified width and height.
  ///
  /// [width] The number of columns in the grid (must be > 0).
  /// [height] The number of rows in the grid (must be > 0).
  /// [matrix] An optional 2D list (`List<List<int>>`) defining obstacles.
  ///   The outer list represents rows (y), the inner list represents columns (x).
  ///   A value of `0` indicates a walkable node, while any non-zero value
  ///   (typically `1`) indicates an unwalkable node (obstacle).
  ///   If provided, `matrix.length` must equal `height` and all inner lists'
  ///   lengths must equal `width`.
  /// [defaultWeight] The default movement cost associated with walkable nodes.
  ///   Defaults to `1.0`. Used by pathfinding algorithms to calculate path costs.
  ///   Higher weights represent more difficult terrain. Must be >= 1.0.
  Grid(this.width, this.height, {List<List<int>>? matrix, double defaultWeight = 1.0}) {
    if (width <= 0 || height <= 0) {
      throw ArgumentError('Grid dimensions must be positive.');
    }
    if (defaultWeight < 1.0) {
      // Allow 1.0, as it's the base cost.
      throw ArgumentError('Node weight cannot be less than 1.0.');
    }
    if (matrix != null) {
      if (matrix.length != height || matrix.any((row) => row.length != width)) {
        throw ArgumentError('Matrix dimensions do not match grid dimensions.');
      }
    }

    _nodes = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          bool isWalkable = true;
          double weight = defaultWeight;
          if (matrix != null) {
            // Assuming 0 is walkable, non-zero is blocked
            isWalkable = matrix[y][x] == 0;
            // Could extend matrix format to include weights if needed
          }
          return Node(x, y, isWalkable: isWalkable, weight: weight);
        },
        growable: false, // Optimize inner list
      ),
      growable: false, // Optimize outer list
    );
  }

  /// Internal constructor used by [clone].
  Grid._internal(this.width, this.height, this._nodes);


  /// Gets the [Node] instance at the specified grid coordinates.
  ///
  /// Throws a [RangeError] if the coordinates `(x, y)` are outside the
  /// valid grid bounds (0 <= x < width, 0 <= y < height).
  ///
  /// [x] The column index (0-based).
  /// [y] The row index (0-based).
  /// Returns the [Node] at the given coordinates.
  Node getNodeAt(int x, int y) {
    // isInside check is implicitly handled by List bounds checking,
    // but explicit check provides clearer error for user.
    if (!isInside(x, y)) {
      // Consider throwing ArgumentError instead of RangeError for consistency?
      // RangeError seems appropriate for index access.
      throw RangeError('Coordinates ($x, $y) are outside grid bounds ($width x $height).');
    }
    // Note: Access is _nodes[y][x] due to List<List<Node>> structure (rows outer, cols inner)
    return _nodes[y][x];
  }

  /// Checks if the given grid coordinates `(x, y)` are within the valid
  /// boundaries of the grid (inclusive).
  ///
  /// [x] The column index to check.
  /// [y] The row index to check.
  /// Returns `true` if `0 <= x < width` and `0 <= y < height`, `false` otherwise.
  bool isInside(int x, int y) {
    return x >= 0 && x < width && y >= 0 && y < height;
  }

  /// Checks if the node at the specified grid coordinates `(x, y)` is walkable.
  ///
  /// A node is considered walkable if it is within the grid boundaries
  /// (checked by [isInside]) and its `isWalkable` property is `true`.
  ///
  /// [x] The column index of the node.
  /// [y] The row index of the node.
  /// Returns `true` if the node exists and is walkable, `false` otherwise
  /// (including if the coordinates are out of bounds).
  bool isWalkableAt(int x, int y) {
    // Avoid potential RangeError by checking isInside first.
    return isInside(x, y) && _nodes[y][x].isWalkable;
  }

  /// Sets the walkability status of the node at the specified coordinates.
  ///
  /// Allows dynamic modification of the grid, for example, to add or remove
  /// obstacles after the grid has been created.
  ///
  /// Throws a [RangeError] if the coordinates `(x, y)` are outside grid bounds.
  ///
  /// [x] The column index of the node to modify.
  /// [y] The row index of the node to modify.
  /// [isWalkable] The new walkability status (`true` for walkable, `false` for obstacle).
  void setWalkableAt(int x, int y, bool isWalkable) {
    // getNodeAt handles the bounds check and throws RangeError if needed.
    getNodeAt(x, y).isWalkable = isWalkable;
  }

  /// Sets the movement weight (cost) of the node at the specified coordinates.
  ///
  /// Allows dynamic modification of terrain costs after the grid is created.
  /// The weight must be >= 1.0.
  ///
  /// Throws a [RangeError] if coordinates `(x, y)` are outside grid bounds.
  /// Throws an [ArgumentError] if [weight] is less than 1.0.
  ///
  /// [x] The column index of the node to modify.
  /// [y] The row index of the node to modify.
  /// [weight] The new movement cost for the node (must be >= 1.0).
  void setWeightAt(int x, int y, double weight) {
     if (weight < 1.0) {
       throw ArgumentError('Node weight cannot be less than 1.0.');
     }
     // getNodeAt handles the bounds check and throws RangeError if needed.
    getNodeAt(x, y).weight = weight;
  }

  /// Retrieves a list of walkable neighboring nodes for a given [node].
  ///
  /// This method is crucial for pathfinding algorithms to explore the grid.
  /// It considers grid boundaries, node walkability, and movement rules
  /// specified by the optional parameters.
  ///
  /// [node] The central node for which to find neighbors.
  /// [allowDiagonal] If `true`, allows diagonal neighbors to be included.
  ///   Defaults to `false`.
  /// [dontCrossCorners] If `true` and `allowDiagonal` is also `true`, prevents
  ///   diagonal movement across the corner of an unwalkable node. For example,
  ///   to move from (0,0) to (1,1), both (1,0) and (0,1) must be walkable.
  ///   If `false`, diagonal movement only requires the target diagonal cell
  ///   itself to be walkable. Defaults to `false`.
  ///
  /// Returns a list of [Node] objects representing the valid, walkable neighbors.
  /// The list will be empty if the node has no walkable neighbors according
  /// to the specified rules.
  List<Node> getNeighbors(Node node, {bool allowDiagonal = false, bool dontCrossCorners = false}) {
    // If the node itself is not walkable, it has no neighbors from a pathfinding perspective.
    if (!node.isWalkable) {
      return [];
    }

    final neighbors = <Node>[];
    final x = node.x;
    final y = node.y;

    // Cardinal directions (N, S, E, W)
    bool n = false, s = false, e = false, w = false;
    // Diagonal directions (NE, SE, SW, NW)
    bool ne = false, se = false, sw = false, nw = false;

    // --- Check cardinal neighbors ---
    // North
    if (isWalkableAt(x, y - 1)) {
      neighbors.add(_nodes[y - 1][x]);
      n = true;
    }
    // South
    if (isWalkableAt(x, y + 1)) {
      neighbors.add(_nodes[y + 1][x]);
      s = true;
    }
    // East
    if (isWalkableAt(x + 1, y)) {
      neighbors.add(_nodes[y][x + 1]);
      e = true;
    }
    // West
    if (isWalkableAt(x - 1, y)) {
      neighbors.add(_nodes[y][x - 1]);
      w = true;
    }

    // --- Check diagonal neighbors ---
    if (!allowDiagonal) {
      return neighbors;
    }

    if (dontCrossCorners) {
      // Need walkable cardinal neighbors to allow diagonal move
      ne = n && e;
      se = s && e;
      sw = s && w;
      nw = n && w;
    } else {
      // Only need the diagonal cell itself to be walkable
      ne = isWalkableAt(x + 1, y - 1);
      se = isWalkableAt(x + 1, y + 1);
      sw = isWalkableAt(x - 1, y + 1);
      nw = isWalkableAt(x - 1, y - 1);
    }

    // North-East
    if (ne && isWalkableAt(x + 1, y - 1)) {
       neighbors.add(_nodes[y - 1][x + 1]);
    }
    // South-East
    if (se && isWalkableAt(x + 1, y + 1)) {
       neighbors.add(_nodes[y + 1][x + 1]);
    }
    // South-West
    if (sw && isWalkableAt(x - 1, y + 1)) {
       neighbors.add(_nodes[y + 1][x - 1]);
    }
    // North-West
    if (nw && isWalkableAt(x - 1, y - 1)) {
       neighbors.add(_nodes[y - 1][x - 1]);
    }

    return neighbors;
  }


  /// Creates a deep copy of the grid.
  ///
  /// This is crucial because pathfinding algorithms modify node states (costs,
  /// parent pointers, visited status). Cloning ensures each search starts
  /// with a fresh grid state.
  /// Note: With the Search ID optimization, cloning might not be strictly
  /// necessary if the user is okay with the grid state being managed internally.
  /// However, cloning provides a guarantee of an isolated state if needed.
  Grid clone() {
    // Cloning still creates new Node instances, implicitly resetting state
    // relative to the original grid, but doesn't copy the _lastResetSearchId.
    // The search ID mechanism works independently on the cloned grid.
    final newNodes = List.generate(
      height,
      (y) => List.generate(
        width,
        (x) {
          final originalNode = _nodes[y][x];
          // Create a new node instance, copying structural properties
          final newNode = Node(
            originalNode.x,
            originalNode.y,
            isWalkable: originalNode.isWalkable,
            weight: originalNode.weight,
          );
          // Pathfinding-specific data is implicitly reset by creating a new Node
          // If Node had complex state, we might need newNode.reset() here.
          return newNode;
        },
        growable: false,
      ),
      growable: false,
    );
    return Grid._internal(width, height, newNodes);
  }
}
