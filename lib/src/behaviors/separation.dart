import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid for neighbor queries
import '../utils/vector_utils.dart'; // Although not directly used, good practice
import 'alignment.dart'; // For doc links
import 'cohesion.dart'; // For doc links
import 'flocking.dart'; // For doc links

/// {@template separation}
/// **Separation** steering behavior: avoids crowding local neighbors.
///
/// This behavior, one of the classic components of flocking (along with
/// [Alignment] and [Cohesion]), steers an agent to move away from its nearby
/// neighbors to prevent agents from bunching up too closely.
///
/// It works by:
/// 1. Querying a [SpatialHashGrid] (or similar structure) to find neighboring
///    agents within a specified [desiredSeparation] distance.
/// 2. Optionally filtering these neighbors to only include those within a
///    limited field of view ([viewAngle]) relative to the agent's heading.
/// 3. For each considered neighbor that is closer than [desiredSeparation]:
///    a. Calculating a repulsive force vector pointing directly away from the neighbor.
///    b. Scaling the magnitude of this force inversely proportional to the
///       distance to the neighbor (closer neighbors exert a stronger repulsion).
/// 4. Summing the repulsive forces from all relevant neighbors.
/// 5. Calculating the final steering force required to achieve a velocity
///    aligned with the combined repulsive force.
///
/// This behavior helps maintain personal space within a group or crowd.
/// {@endtemplate}
/// @seealso [Alignment], [Cohesion], [Flocking]
/// @seealso [SpatialHashGrid]
class Separation extends SteeringBehavior {
  /// The [SpatialHashGrid] used to efficiently find nearby agents within the
  /// [desiredSeparation] radius. The grid should contain all agents relevant
  /// to the separation calculation.
  final SpatialHashGrid spatialGrid;

  /// The desired minimum distance to maintain between this agent and its neighbors.
  /// The repulsive force is calculated for neighbors closer than this distance.
  /// Must be greater than 0.
  final double desiredSeparation;

  /// Optional: The field of view angle (in radians) relative to the agent's
  /// current heading. If set, only neighbors within this angular range
  /// (e.g., `viewAngle / 2` to the left and right) are considered for separation.
  /// If `null` (the default), neighbors in all directions (360 degrees) are considered.
  final double? viewAngle;

  /// Creates a [Separation] behavior.
  ///
  /// {@macro separation}
  /// [spatialGrid] The spatial hash grid containing agents for neighbor queries.
  /// [desiredSeparation] The target minimum distance to keep from neighbors (> 0).
  /// [viewAngle] Optional field of view constraint in radians (e.g., `pi` for 180 degrees).
  ///   If provided, must be non-negative.
  Separation({
    required this.spatialGrid,
    required this.desiredSeparation,
    this.viewAngle,
  }) : assert(desiredSeparation > 0, 'desiredSeparation must be positive'),
       assert(viewAngle == null || viewAngle >= 0, 'viewAngle cannot be negative.');


  /// Calculates the separation steering force.
  ///
  /// 1. Queries the [spatialGrid] for neighbors within [desiredSeparation].
  /// 2. Iterates through neighbors, skipping self.
  /// 3. Calculates distance and checks if within `desiredSeparation`.
  /// 4. Optionally checks if neighbor is within [viewAngle].
  /// 5. Calculates repulsive force (away from neighbor, scaled inversely by distance).
  /// 6. Sums repulsive forces.
  /// 7. If any repulsive forces were added, calculates the final steering vector
  ///    (desired velocity based on total repulsion - current velocity).
  /// 8. Returns the final steering vector or `Vector2.zero()` if no neighbors
  ///    were close enough.
  @override
  Vector2 calculateSteering(Agent agent) {
    final steeringForceSum = Vector2.zero(); // Use a more descriptive name
    int neighborsCount = 0;
    // Calculate heading only if viewAngle is used and agent is moving.
    final agentHeading = (viewAngle != null && agent.velocity.length2 > 1e-6)
        ? agent.velocity.normalized()
        : null;

    // 1. Query for potential neighbors.
    // Use desiredSeparation as the query radius. SpatialHashGrid might return
    // items slightly outside this radius due to cell-based querying, so we
    // double-check the distance below.
    final potentialNeighbors = spatialGrid.queryRadius(agent.position, desiredSeparation);

    // 2. Iterate through neighbors and calculate repulsive forces.
    for (final other in potentialNeighbors) {
      if (other == agent) continue; // Skip self

      // Vector pointing from agent to the other agent.
      final toOther = other.position - agent.position;
      final distanceSquared = toOther.length2;

      // Check if within desired separation (and not exactly at the same position).
      if (distanceSquared > 1e-6 && distanceSquared < desiredSeparation * desiredSeparation) {

        // 3. Optional: Check if neighbor is within the view angle.
        if (agentHeading != null && viewAngle != null) {
          // Need normalized direction vector for angle calculation.
          final directionToOther = toOther.normalized();
          // Calculate angle between agent's heading and direction to neighbor.
          final angle = agentHeading.angleToSigned(directionToOther);
          // Check if the absolute angle exceeds half the view angle.
          if (angle.abs() > viewAngle! * 0.5) {
            continue; // Neighbor is outside the field of view.
          }
        }

        // 4. Calculate repulsive force.
        // Force points away from the neighbor (-toOther).
        // Magnitude is inversely proportional to distance (stronger when closer).
        // Using 1/distance scaling for linear falloff.
        final distance = sqrt(distanceSquared);
        // Normalize the direction away from the neighbor.
        final repulsiveDirection = -toOther / distance; // Normalized vector pointing away
        // Scale force: desiredSeparation / distance gives a factor > 1 when closer than desired.
        final repulsiveForce = repulsiveDirection * (desiredSeparation / distance);

        steeringForceSum.add(repulsiveForce);
        neighborsCount++;
      }
    }

    // 5. Calculate final steering force if any neighbors were considered.
    if (neighborsCount > 0) {
      // Optional: Average the force by dividing by neighborsCount. This can
      // sometimes produce smoother behavior, but often simply using the sum is fine.
      // steeringForceSum.scale(1.0 / neighborsCount);

      // Convert the summed repulsive force into a desired velocity change.
      // We want to move in the direction of the combined repulsion.
      if (steeringForceSum.length2 > 1e-6) {
         // Calculate desired velocity in the direction of the summed force, at max speed.
         final desiredVelocity = steeringForceSum.normalized() * agent.maxSpeed;
         // Calculate the final steering force required to achieve this desired velocity.
         final finalSteering = desiredVelocity - agent.velocity;
         return finalSteering; // SteeringManager will truncate magnitude later.
      }
    }

    // No neighbors close enough or no net repulsive force.
    return Vector2.zero();
  }
}
