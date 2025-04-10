import 'package:vector_math/vector_math_64.dart';
// Removed dart:ui import

import 'behaviors/flow_field_following.dart'; // For doc links

// Removed unused _lerpVector2 helper function

/// Represents a 2D grid-based flow field (also known as a vector field).
///
/// A flow field defines a desired direction of movement ([Vector2]) for any
/// given location within its bounds. It's typically represented as a grid where
/// each cell stores a flow vector. This is often used to guide large numbers of
/// agents efficiently, as the field can be pre-calculated (e.g., using pathfinding
/// costs or potential field methods) and then simply looked up by agents.
///
/// The [FlowFieldFollowing] behavior uses this class to determine the desired
/// velocity for an agent based on its position (or predicted position) within the field.
///
/// This implementation uses bilinear interpolation in the [lookup] method to provide
/// smoother transitions between cell vectors when an agent is positioned between
/// cell centers.
///
/// @seealso [FlowFieldFollowing]
class FlowField {
  /// The world-space position ([Vector2]) of the bottom-left corner of the
  /// flow field grid.
  final Vector2 origin;

  /// The size (width and height) of each square cell in the grid. Must be positive.
  final double cellSize;

  /// The number of columns in the grid (horizontal dimension). Must be positive.
  final int columns;

  /// The number of rows in the grid (vertical dimension). Must be positive.
  final int rows;

  /// The internal grid data storing the flow vector ([Vector2]) for each cell.
  /// Vectors are stored in a flat list in row-major order. Access using
  /// index `row * columns + col`.
  final List<Vector2> _field;

  /// Creates a `FlowField` with the specified dimensions and properties.
  ///
  /// Initializes all cells with the [defaultFlow] vector if provided, otherwise
  /// defaults to `Vector2(1, 0)` (pointing right).
  ///
  /// Throws an [AssertionError] if [cellSize], [columns], or [rows] are not positive.
  ///
  /// [origin] The world-space position of the bottom-left corner of the grid.
  /// [cellSize] The width and height of each grid cell (> 0).
  /// [columns] The number of columns in the grid (> 0).
  /// [rows] The number of rows in the grid (> 0).
  /// [defaultFlow] Optional default flow vector ([Vector2]) to initialize all
  ///   cells. Defaults to `Vector2(1, 0)`. The provided vector is cloned for each cell.
  FlowField({
    required this.origin,
    required this.cellSize,
    required this.columns,
    required this.rows,
    Vector2? defaultFlow,
  })  : assert(cellSize > 0, 'cellSize must be positive'),
        assert(columns > 0, 'columns must be positive'),
        assert(rows > 0, 'rows must be positive'),
        // Initialize the flat list with cloned default flow vectors.
        _field = List.generate(
            columns * rows,
            (_) => (defaultFlow ?? Vector2(1, 0)).clone(), // Clone default vector
            growable: false);

  /// Gets the total width of the flow field grid in world units.
  double get width => columns * cellSize;

  /// Gets the total height of the flow field grid in world units.
  double get height => rows * cellSize;

  /// Sets the flow vector for a specific grid cell.
  ///
  /// If the provided [col] or [row] indices are out of bounds, the call is ignored.
  ///
  /// [col] The column index (0 <= col < columns).
  /// [row] The row index (0 <= row < rows).
  /// [flow] The [Vector2] representing the desired flow direction and magnitude
  ///   for this cell. The vector is copied into the internal storage.
  void setFlow(int col, int row, Vector2 flow) {
    // Check bounds before accessing the flat list
    if (col >= 0 && col < columns && row >= 0 && row < rows) {
      // Calculate the 1D index for the flat list (row-major order)
      final index = row * columns + col;
      // Set the flow vector using setFrom to copy values
      _field[index].setFrom(flow);
    }
    // else: Ignore out-of-bounds requests silently. Could throw an error instead.
  }

  /// Gets the raw flow vector for a specific grid cell without interpolation or clamping.
  ///
  /// Returns `null` if the provided [col] or [row] indices are out of bounds.
  /// Use this primarily for debugging or direct visualization of the raw field data.
  /// For agent behavior, prefer the [lookup] method which handles interpolation
  /// and clamping.
  ///
  /// [col] The column index (0 <= col < columns).
  /// [row] The row index (0 <= row < rows).
  ///
  /// Returns the [Vector2] at the specified cell, or `null` if out of bounds.
  Vector2? getFlowAt(int col, int row) {
    // Check bounds before accessing the flat list
    if (col >= 0 && col < columns && row >= 0 && row < rows) {
      final index = row * columns + col;
      return _field[index]; // Return the direct vector reference
    }
    return null; // Out of bounds
  }

  /// Looks up the flow vector at a given world position using bilinear interpolation.
  ///
  /// This method calculates the appropriate flow vector for any given
  /// [worldPosition] within or near the flow field's bounds.
  ///
  /// 1. Converts the `worldPosition` into floating-point grid coordinates (gridX, gridY).
  /// 2. Clamps these coordinates to stay within the valid grid index range
  ///    (`0` to `columns-1` and `0` to `rows-1`). This handles positions outside the grid.
  /// 3. Identifies the four grid cells surrounding the clamped coordinates.
  /// 4. Calculates interpolation factors (`tx`, `ty`) based on the fractional part
  ///    of the clamped coordinates.
  /// 5. Retrieves the flow vectors from the four surrounding cells.
  /// 6. Performs bilinear interpolation using the factors and the four vectors
  ///    to calculate the final interpolated flow vector at the exact position.
  ///
  /// This interpolation provides smoother transitions for agents moving between cells,
  /// compared to simply returning the vector of the single cell containing the position.
  ///
  /// [worldPosition] The position ([Vector2]) in world space to sample the flow field at.
  ///
  /// Returns the calculated flow [Vector2] at that position (interpolated and clamped).
  Vector2 lookup(Vector2 worldPosition) {
    // 1. Convert world position to floating-point grid coordinates relative to origin.
    final double gridX = (worldPosition.x - origin.x) / cellSize;
    final double gridY = (worldPosition.y - origin.y) / cellSize;

    // 2. Clamp coordinates to be within grid bounds (using indices 0 to N-1)
    final double clampedX = gridX.clamp(0.0, columns - 1.0);
    final double clampedY = gridY.clamp(0.0, rows - 1.0);

    // 3. Get integer indices of the bottom-left cell for interpolation
    final int col0 = clampedX.floor();
    final int row0 = clampedY.floor();

    // 4. Calculate interpolation factors (weights) 0.0 to 1.0
    final double tx = clampedX - col0;
    final double ty = clampedY - row0;

    // 5. Get indices of the four surrounding cells, clamping at edges
    final int c0 = col0;
    final int r0 = row0;
    // Ensure indices do not exceed bounds, especially when tx/ty are exactly 1.0
    final int c1 = (col0 >= columns - 1) ? col0 : col0 + 1;
    final int r1 = (row0 >= rows - 1) ? row0 : row0 + 1;

    // 6. Get flow vectors for the four surrounding cells
    final Vector2 flow00 = _field[r0 * columns + c0]; // Bottom-left
    final Vector2 flow10 = _field[r0 * columns + c1]; // Bottom-right
    final Vector2 flow01 = _field[r1 * columns + c0]; // Top-left
    final Vector2 flow11 = _field[r1 * columns + c1]; // Top-right

    // 7. Bilinear interpolation (Manual)
    // Interpolate horizontally along the bottom row: flow00 * (1-tx) + flow10 * tx
    final double bottomX = flow00.x * (1.0 - tx) + flow10.x * tx;
    final double bottomY = flow00.y * (1.0 - tx) + flow10.y * tx;
    // Interpolate horizontally along the top row: flow01 * (1-tx) + flow11 * tx
    final double topX = flow01.x * (1.0 - tx) + flow11.x * tx;
    final double topY = flow01.y * (1.0 - tx) + flow11.y * tx;
    // Interpolate vertically between bottom and top results: bottom * (1-ty) + top * ty
    final double finalX = bottomX * (1.0 - ty) + topX * ty;
    final double finalY = bottomY * (1.0 - ty) + topY * ty;

    return Vector2(finalX, finalY);
  }

  // Helper to get flow vector, clamping indices to grid bounds.
  // This was implicitly handled by the clamping logic before, but let's keep it explicit.
  // This is not used in the current implementation but could be useful for test cases.
  // Vector2 _getFlowClamped(int col, int row) {
  //   final c = col.clamp(0, columns - 1);
  //   final r = row.clamp(0, rows - 1);
  //   return _field[r * columns + c];
  // }
}
