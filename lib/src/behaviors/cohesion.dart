import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid for neighbor queries
import 'alignment.dart'; // For doc links
import 'separation.dart'; // For doc links
import 'flocking.dart'; // For doc links
import 'seek.dart'; // For doc links (uses Seek logic)

/// {@template cohesion}
/// **Cohesion** steering behavior: steers towards the center of local neighbors.
///
/// This behavior, one of the classic components of flocking (along with
/// [Alignment] and [Separation]), encourages agents to stay together as a group.
/// It calculates a steering force that directs the agent towards the average
/// position (center of mass) of its nearby neighbors.
///
/// It works by:
/// 1. Querying a [SpatialHashGrid] (or similar structure) to find neighboring
///    agents within a specified [neighborhoodRadius].
/// 2. Optionally filtering these neighbors to only include those within a
///    limited field of view ([viewAngle]) relative to the agent's heading.
/// 3. Calculating the average position (center of mass) of all considered neighbors.
/// 4. Calculating a steering force to [Seek] towards this calculated center of mass.
///
/// If no neighbors are found within the radius (and optional view angle), the
/// behavior produces no steering force.
/// {@endtemplate}
/// @seealso [Alignment], [Separation], [Flocking]
/// @seealso [SpatialHashGrid]
class Cohesion extends SteeringBehavior {
  /// The [SpatialHashGrid] used to efficiently find nearby agents within the
  /// [neighborhoodRadius]. The grid should contain all agents relevant to the
  /// cohesion calculation.
  final SpatialHashGrid spatialGrid;

  /// The maximum distance from the agent within which other agents are considered
  /// "neighbors" for calculating the center of mass. Must be greater than 0.
  final double neighborhoodRadius;

  /// Optional: The field of view angle (in radians) relative to the agent's
  /// current heading. If set, only neighbors within this angular range
  /// are considered for calculating the center of mass.
  /// If `null` (the default), neighbors in all directions (360 degrees) are considered.
  final double? viewAngle;

  /// Creates a [Cohesion] behavior.
  ///
  /// {@macro cohesion}
  /// [spatialGrid] The spatial hash grid containing agents for neighbor queries.
  /// [neighborhoodRadius] The maximum distance to consider neighbors (> 0).
  /// [viewAngle] Optional field of view constraint in radians (e.g., `pi` for 180 degrees).
  ///   If provided, must be non-negative.
  Cohesion({
    required this.spatialGrid,
    required this.neighborhoodRadius,
    this.viewAngle,
  }) : assert(neighborhoodRadius > 0, 'neighborhoodRadius must be positive'),
       assert(viewAngle == null || viewAngle >= 0, 'viewAngle cannot be negative.');


  /// Calculates the cohesion steering force.
  ///
  /// 1. Queries the [spatialGrid] for neighbors within [neighborhoodRadius].
  /// 2. Iterates through neighbors, skipping self.
  /// 3. Optionally checks if neighbor is within [viewAngle].
  /// 4. Accumulates the positions of valid neighbors.
  /// 5. If any neighbors were found:
  ///    a. Calculates the average position (center of mass).
  ///    b. Calculates and returns the steering force to [Seek] the center of mass.
  /// 6. If no neighbors were found, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    final centerOfMass = Vector2.zero(); // Accumulates neighbor positions
    int neighborsCount = 0;
    // Calculate heading only if viewAngle is used and agent is moving.
    final agentHeading = (viewAngle != null && agent.velocity.length2 > 1e-6)
        ? agent.velocity.normalized()
        : null;

    // 1. Query for potential neighbors.
    final potentialNeighbors = spatialGrid.queryRadius(agent.position, neighborhoodRadius);

    // 2. Iterate through neighbors, accumulate positions.
    for (final other in potentialNeighbors) {
      if (other == agent) continue; // Skip self

      // Check distance (SpatialHashGrid query might be slightly inaccurate at edges).
      final distanceSquared = agent.position.distanceToSquared(other.position);
      if (distanceSquared < neighborhoodRadius * neighborhoodRadius) {

        // 3. Optional: Check if neighbor is within the view angle.
        if (agentHeading != null && viewAngle != null) {
          final toOther = other.position - agent.position;
          // Need normalized direction for angle check. Avoid normalizing zero vector.
          if (toOther.length2 > 1e-6) {
             final directionToOther = toOther.normalized();
             final angle = agentHeading.angleToSigned(directionToOther);
             if (angle.abs() > viewAngle! * 0.5) {
               continue; // Neighbor is outside the field of view.
             }
          } else {
             continue; // Neighbor is at the same position, ignore for angle check.
          }
        }

        // 4. Accumulate position if neighbor is valid.
        centerOfMass.add(other.position);
        neighborsCount++;
      }
    }

    // 5. Calculate steering force if neighbors were found.
    if (neighborsCount > 0) {
      // Calculate the average position (center of mass).
      centerOfMass.scale(1.0 / neighborsCount);

      // Calculate steering force to seek the center of mass.
      // Reusing Seek logic: calculate desired velocity towards center, then steering force.
      final desiredVelocity = centerOfMass - agent.position;

      // If already very close to the center, no force needed.
      if (desiredVelocity.length2 < 0.01 * 0.01) { // Use squared tolerance
         return Vector2.zero();
      }

      // Calculate desired velocity and steering force.
      desiredVelocity.normalize();
      desiredVelocity.scale(agent.maxSpeed);
      final steeringForce = desiredVelocity - agent.velocity;

      return steeringForce; // SteeringManager will truncate magnitude later.
    }

    // 6. No neighbors found.
    return Vector2.zero();
  }
}
