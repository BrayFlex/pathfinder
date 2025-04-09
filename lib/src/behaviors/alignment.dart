import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid for neighbor queries
import 'cohesion.dart'; // For doc links
import 'separation.dart'; // For doc links
import 'flocking.dart'; // For doc links

/// {@template alignment}
/// **Alignment** steering behavior: steers towards the average heading of local neighbors.
///
/// This behavior, one of the classic components of flocking (along with
/// [Cohesion] and [Separation]), encourages agents in a group to move in roughly
/// the same direction. It calculates a steering force that attempts to align the
/// agent's current velocity vector with the average velocity vector of its
/// nearby neighbors.
///
/// It works by:
/// 1. Querying a [SpatialHashGrid] (or similar structure) to find neighboring
///    agents within a specified [neighborhoodRadius].
/// 2. Optionally filtering these neighbors to only include those within a
///    limited field of view ([viewAngle]) relative to the agent's heading.
/// 3. Calculating the average velocity vector of all considered neighbors
///    (ignoring neighbors that are stationary).
/// 4. If an average velocity is found (i.e., there were moving neighbors),
///    this average velocity is treated as the "desired" velocity.
/// 5. Calculating the steering force required to change the agent's current
///    velocity towards this desired average velocity.
///
/// If no moving neighbors are found within the radius (and optional view angle),
/// the behavior produces no steering force.
/// {@endtemplate}
/// @seealso [Cohesion], [Separation], [Flocking]
/// @seealso [SpatialHashGrid]
class Alignment extends SteeringBehavior {
  /// The [SpatialHashGrid] used to efficiently find nearby agents within the
  /// [neighborhoodRadius]. The grid should contain all agents relevant to the
  /// alignment calculation.
  final SpatialHashGrid spatialGrid;

  /// The maximum distance from the agent within which other agents are considered
  /// "neighbors" for calculating the average heading. Must be greater than 0.
  final double neighborhoodRadius;

  /// Optional: The field of view angle (in radians) relative to the agent's
  /// current heading. If set, only neighbors within this angular range
  /// are considered for calculating the average heading.
  /// If `null` (the default), neighbors in all directions (360 degrees) are considered.
  final double? viewAngle;

  /// Creates an [Alignment] behavior.
  ///
  /// {@macro alignment}
  /// [spatialGrid] The spatial hash grid containing agents for neighbor queries.
  /// [neighborhoodRadius] The maximum distance to consider neighbors (> 0).
  /// [viewAngle] Optional field of view constraint in radians (e.g., `pi` for 180 degrees).
  ///   If provided, must be non-negative.
  Alignment({
    required this.spatialGrid,
    required this.neighborhoodRadius,
    this.viewAngle,
  }) : assert(neighborhoodRadius > 0, 'neighborhoodRadius must be positive'),
       assert(viewAngle == null || viewAngle >= 0, 'viewAngle cannot be negative.');


  /// Calculates the alignment steering force.
  ///
  /// 1. Queries the [spatialGrid] for neighbors within [neighborhoodRadius].
  /// 2. Iterates through neighbors, skipping self.
  /// 3. Optionally checks if neighbor is within [viewAngle].
  /// 4. Accumulates the velocity vectors of valid, moving neighbors.
  /// 5. If any moving neighbors were found:
  ///    a. Calculates the average velocity vector.
  ///    b. Treats this average velocity as the desired velocity (normalized and
  ///       scaled to the agent's max speed).
  ///    c. Calculates and returns the steering force required to achieve this
  ///       desired velocity (desired - current).
  /// 6. If no moving neighbors were found, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    final averageVelocity = Vector2.zero(); // Accumulates neighbor velocities
    int neighborsCount = 0;
    // Calculate heading only if viewAngle is used and agent is moving.
    final agentHeading = (viewAngle != null && agent.velocity.length2 > 1e-6)
        ? agent.velocity.normalized()
        : null;

    // 1. Query for potential neighbors.
    final potentialNeighbors = spatialGrid.queryRadius(agent.position, neighborhoodRadius);

    // 2. Iterate through neighbors, accumulate velocities.
    for (final other in potentialNeighbors) {
      if (other == agent) continue; // Skip self

      // Check distance.
      final distanceSquared = agent.position.distanceToSquared(other.position);
      if (distanceSquared < neighborhoodRadius * neighborhoodRadius) {

        // 3. Optional: Check if neighbor is within the view angle.
        if (agentHeading != null && viewAngle != null) {
          final toOther = other.position - agent.position;
          if (toOther.length2 > 1e-6) {
             final directionToOther = toOther.normalized();
             final angle = agentHeading.angleToSigned(directionToOther);
             if (angle.abs() > viewAngle! * 0.5) {
               continue; // Neighbor is outside the field of view.
             }
          } else {
             continue; // Neighbor is at the same position.
          }
        }

        // 4. Accumulate velocity if neighbor is moving.
        // Alignment only makes sense with moving neighbors.
        if (other.velocity.length2 > 1e-6) {
           averageVelocity.add(other.velocity);
           neighborsCount++;
        }
      }
    }

    // 5. Calculate steering force if moving neighbors were found.
    if (neighborsCount > 0) {
      // Calculate the average velocity.
      averageVelocity.scale(1.0 / neighborsCount);

      // Calculate desired velocity based on the average velocity direction.
      // We want to match the average direction at the agent's max speed.
      if (averageVelocity.length2 > 1e-6) {
         final desiredVelocity = averageVelocity.normalized() * agent.maxSpeed;
         // Calculate the steering force required to achieve this desired velocity.
         final steeringForce = desiredVelocity - agent.velocity;
         return steeringForce; // SteeringManager will truncate magnitude later.
      }
      // else: Average velocity is zero (e.g., neighbors moving in opposite directions).
    }

    // 6. No moving neighbors found within criteria.
    return Vector2.zero();
  }
}
