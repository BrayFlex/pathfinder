import 'dart:math';

import 'pathfinder_base.dart'; // For doc links

/// Defines the function signature for heuristic functions used in pathfinding.
///
/// Heuristic functions provide an estimated cost (a guess) of moving from a
/// given node to the target node. This estimate is used by informed search
/// algorithms like A* ([AStarFinder]) and Best-First Search ([BestFirstFinder])
/// to prioritize nodes that appear closer to the target.
///
/// A heuristic must be **admissible**, meaning it **never overestimates** the
/// actual cost to reach the target. It should also ideally be **consistent**
/// (or monotonic), meaning the estimated cost from A to Target should be less
/// than or equal to the cost of moving from A to a neighbor B plus the estimated
/// cost from B to Target. Admissibility is crucial for guaranteeing optimality
/// in algorithms like A*, while consistency can improve efficiency.
///
/// The function takes the difference in x ([dx]) and y ([dy]) coordinates
/// between the current node and the target node as input.
///
/// [dx] The absolute difference in x-coordinates (`abs(currentNode.x - targetNode.x)`).
/// [dy] The absolute difference in y-coordinates (`abs(currentNode.y - targetNode.y)`).
/// Returns the estimated cost as a `double`.
typedef HeuristicFunction = double Function(int dx, int dy);

/// Provides a collection of common, static heuristic functions suitable for
/// grid-based pathfinding.
///
/// These functions can be passed to the constructor of heuristic-based
/// [PathFinder] implementations (like [AStarFinder]).
///
/// Choosing the right heuristic depends on the allowed movement on the grid:
/// - **Manhattan:** Use when only cardinal movement (4 directions) is allowed,
///   or when diagonal movement has the same cost as cardinal movement.
/// - **Octile/Chebyshev:** Use when diagonal movement is allowed and costs the
///   same as cardinal movement (cost = 1).
/// - **Diagonal:** Use when diagonal movement is allowed but costs more than
///   cardinal movement (typically sqrt(2) times the cardinal cost).
/// - **Euclidean:** Calculates the true straight-line distance. Admissible, but
///   often less efficient in grid searches than the others because it involves
///   a square root calculation and might explore more nodes if the grid distance
///   differs significantly from the straight-line distance.
///
/// @seealso [PathFinder], [HeuristicFunction]
class Heuristics {
  /// Calculates the Manhattan distance heuristic.
  ///
  /// This is the distance between two points measured along axes at right angles.
  /// It's calculated as `abs(dx) + abs(dy)`.
  ///
  /// Suitable for grids where only cardinal movement (4 directions) is allowed,
  /// or where diagonal movement costs the same as cardinal movement (cost = 1).
  /// It is admissible and consistent under these conditions.
  ///
  /// [dx] The absolute difference in x-coordinates.
  /// [dy] The absolute difference in y-coordinates.
  /// Returns the Manhattan distance.
  static double manhattan(int dx, int dy) {
    // No need for abs() as typedef specifies dx/dy are already differences.
    // Caller should provide absolute differences if needed, but typically
    // pathfinders calculate dx = abs(node.x - end.x), dy = abs(node.y - end.y).
    // Let's assume dx, dy can be negative based on typedef description.
    return (dx.abs() + dy.abs()).toDouble();
  }

  /// Calculates the Euclidean distance heuristic.
  ///
  /// This is the straight-line ("as the crow flies") distance between two points.
  /// It's calculated as `sqrt(dx*dx + dy*dy)`.
  ///
  /// It is always admissible. However, it can be computationally more expensive
  /// due to the square root and might be less performant than other heuristics
  /// in grid-based searches if the optimal path significantly deviates from a
  /// straight line.
  ///
  /// [dx] The difference in x-coordinates.
  /// [dy] The difference in y-coordinates.
  /// Returns the Euclidean distance.
  static double euclidean(int dx, int dy) {
    // dx and dy could be negative here based on typedef description.
    final dxDouble = dx.toDouble();
    final dyDouble = dy.toDouble();
    return sqrt(dxDouble * dxDouble + dyDouble * dyDouble);
  }

  /// Calculates the Octile distance heuristic.
  ///
  /// This heuristic considers movement in 8 directions (cardinal and diagonal)
  /// where the cost of diagonal movement is assumed to be the **same** as the
  /// cost of cardinal movement (cost = 1).
  /// It's calculated as `max(abs(dx), abs(dy))`.
  ///
  /// Suitable for grids where diagonal movement is allowed and costs 1.
  /// It is admissible and consistent under these conditions.
  /// Also known as Chebyshev distance.
  ///
  /// [dx] The absolute difference in x-coordinates.
  /// [dy] The absolute difference in y-coordinates.
  /// Returns the Octile distance (assuming diagonal cost is sqrt(2) and cardinal is 1).
  /// This is often called Diagonal distance when costs differ.
  static double octile(int dx, int dy) {
    // Assuming dx, dy can be negative based on typedef description.
    final dxa = dx.abs();
    final dya = dy.abs();
    const double d1 = 1.0; // Cost of cardinal movement
    const double d2 = 1.414213562373095; // Cost of diagonal movement (~sqrt(2))
    // Using the alternate equivalent formula for Octile/Diagonal distance
    return d1 * max(dxa, dya) + (d2 - d1) * min(dxa, dya);
  }

  /// Calculates the Chebyshev distance heuristic (equivalent to Octile IF costs are equal).
  /// Calculates max(abs(dx), abs(dy)).
  ///
  /// Provided for clarity as the name "Chebyshev distance" is also commonly used
  /// for `max(abs(dx), abs(dy))`.
  ///
  /// Suitable for grids where diagonal movement is allowed and costs the same
  /// as cardinal movement (cost = 1).
  ///
  /// [dx] The absolute difference in x-coordinates.
  /// [dy] The absolute difference in y-coordinates.
  /// Returns the Chebyshev distance.
  static double chebyshev(int dx, int dy) {
    // Assuming dx, dy can be negative based on typedef description.
    return max(dx.abs(), dy.abs()).toDouble(); // Correct Chebyshev implementation
  }

  /// Calculates the Diagonal distance heuristic (often used synonymously with Octile when costs differ).
  ///
  /// This heuristic considers movement in 8 directions but assumes diagonal
  /// movement costs **more** than cardinal movement. It typically assumes a
  /// cardinal cost (`D` or `d1`) of 1 and a diagonal cost (`D2` or `d2`) of `sqrt(2)`.
  ///
  /// Formula: `d1 * max(abs(dx), abs(dy)) + (d2 - d1) * min(abs(dx), abs(dy))`
  /// This represents the cost of moving diagonally as much as possible, then
  /// cardinally for the remainder.
  ///
  /// Suitable for grids where diagonal movement is allowed and costs `sqrt(2)`.
  /// It is admissible and consistent under these conditions.
  ///
  /// [dx] The absolute difference in x-coordinates.
  /// [dy] The absolute difference in y-coordinates.
  /// Returns the Diagonal distance.
  static double diagonal(int dx, int dy) {
    // Assuming dx, dy can be negative based on typedef description.
    final dxa = dx.abs();
    final dya = dy.abs();
    // Define standard costs assumed by this heuristic.
    // PathFinder.getMovementCost should ideally use the same constants.
    const double d1 = 1.0; // Cost of cardinal movement
    const double d2 = 1.414213562373095; // Cost of diagonal movement (~sqrt(2))

    // Formula: d1 * (dxa + dya) + (d2 - 2 * d1) * min(dxa, dya);
    // More intuitive version:
    return d1 * max(dxa, dya) + (d2 - d1) * min(dxa, dya);
  }
}
