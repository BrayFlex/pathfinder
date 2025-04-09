import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid for neighbor queries
import '../utils/vector_utils.dart'; // Although not directly used, good practice

/// {@template unaligned_collision_avoidance}
/// **Unaligned Collision Avoidance** steering behavior: avoids moving agents.
///
/// This behavior steers an agent to avoid potential future collisions with other
/// moving agents in its vicinity. Unlike simple [Separation] which only pushes
/// agents apart based on current positions, this behavior predicts the trajectories
/// of the agent and its neighbors to find the *time* and *location* of their
/// closest point of approach (CPA).
///
/// If a potential collision (CPA distance is less than the sum of the agents' radii)
/// is predicted to occur within a specified time window ([maxPredictionTime]),
/// the behavior calculates a steering force to avoid it. The force generally pushes
/// the agent away from the predicted relative position at the CPA. The strength
/// of the force is scaled by [avoidanceForceMultiplier] and an urgency factor
/// based on how soon the potential collision is predicted to occur.
///
/// This behavior relies on a [SpatialHashGrid] (or a similar spatial partitioning
/// structure) to efficiently query for nearby agents ("potential threats") within
/// a relevant radius, avoiding expensive checks against all agents in the simulation.
///
/// The core calculation involves:
/// 1. Querying the [spatialGrid] for nearby agents.
/// 2. For each neighbor, calculating the relative position and velocity.
/// 3. Calculating the time (`timeToClosest`) until the CPA using relative velocity.
/// 4. Filtering out neighbors where CPA is in the past, too far in the future
///    ([maxPredictionTime]), or where agents are moving apart.
/// 5. Calculating the separation distance at the CPA.
/// 6. Checking if this separation is less than the combined radii (potential collision).
/// 7. Identifying the neighbor representing the *most imminent* threat (smallest
///    positive `timeToClosest`).
/// 8. If a threat is found, calculating a steering force that pushes the agent
///    away from the relative position at the CPA, scaled by urgency.
/// {@endtemplate}
/// @seealso [Separation] for simpler avoidance based on current positions.
/// @seealso [ObstacleAvoidance] for avoiding static obstacles.
/// @seealso [SpatialHashGrid] for efficient neighbor querying.
class UnalignedCollisionAvoidance extends SteeringBehavior {
  /// The [SpatialHashGrid] used to efficiently find nearby agents within a
  /// relevant query radius. The grid should be populated with all agents
  /// that should be considered for avoidance.
  final SpatialHashGrid spatialGrid;

  /// The maximum time (in seconds) into the future to predict potential collisions.
  /// Only predicted collisions occurring within this time window will trigger an
  /// avoidance response. Defaults to `2.0` seconds. Must be non-negative.
  final double maxPredictionTime;

  /// A multiplier scaling the strength of the calculated avoidance steering force.
  /// Higher values lead to stronger, potentially more abrupt, avoidance maneuvers.
  /// Defaults to `100.0`.
  final double avoidanceForceMultiplier;

  /// Creates an [UnalignedCollisionAvoidance] behavior.
  ///
  /// {@macro unaligned_collision_avoidance}
  /// [spatialGrid] The spatial hash grid containing other agents for neighbor queries.
  /// [maxPredictionTime] How far ahead (seconds) to predict potential collisions
  ///   (default: `2.0`, must be >= 0).
  /// [avoidanceForceMultiplier] Strength multiplier for the avoidance force
  ///   (default: `100.0`).
  UnalignedCollisionAvoidance({
    required this.spatialGrid,
    this.maxPredictionTime = 2.0,
    this.avoidanceForceMultiplier = 100.0,
  }) : assert(maxPredictionTime >= 0, 'maxPredictionTime cannot be negative.');
       // avoidanceForceMultiplier can reasonably be zero or negative.


  // --- Optimization: Pre-allocated vectors to reduce GC pressure ---
  final Vector2 _relativePosition = Vector2.zero();
  final Vector2 _relativeVelocity = Vector2.zero();
  final Vector2 _separationAtClosest = Vector2.zero();
  final Vector2 _avoidanceDir = Vector2.zero();
  final Vector2 _steeringForce = Vector2.zero(); // Re-added for clarity
  final Vector2 _desiredVelocity = Vector2.zero();
  final Vector2 _finalSteering = Vector2.zero();
  final Vector2 _firstThreatRelativeVelocity = Vector2.zero(); // Store rel vel of first threat
  // --- End Optimization ---

  /// Calculates the unaligned collision avoidance steering force.
  ///
  /// Implements the CPA prediction and avoidance logic:
  /// 1. Queries the [spatialGrid] for nearby agents within a radius determined
  ///    by speed and [maxPredictionTime].
  /// 2. Iterates through potential threats:
  ///    a. Calculates relative position and velocity.
  ///    b. Calculates time to closest point of approach (`timeToClosest`).
  ///    c. Ignores threats if CPA is in the past, too far in the future, or
  ///       if agents are effectively stationary relative to each other.
  ///    d. Calculates the separation vector at the CPA.
  ///    e. Checks if the separation distance at CPA is less than combined radii.
  ///    f. If a potential collision is detected, updates the `firstThreat` if
  ///       this collision is more imminent (smaller `timeToClosest`) than any
  ///       previous threat found. Stores the separation vector at CPA and relative velocity for the threat.
  /// 3. If a `firstThreat` was identified:
  ///    a. Calculates an avoidance steering direction opposite to the separation
  ///       vector at CPA.
  ///    b. Scales this direction by `avoidanceForceMultiplier` and an urgency factor to get a base force.
  ///    c. Calculates the desired velocity change based on this force.
  ///    d. Returns the final steering force (desired velocity - current velocity).
  /// 4. If no threats are found, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    // This implementation reuses pre-allocated Vector2 instances to minimize GC pressure.

    double minTimeToCollision = double.infinity;
    Agent? firstThreat;
    Vector2? firstThreatRelativePosAtCPA; // Stores separation vector at CPA for the most imminent threat

    // 1. Determine query radius and find potential threats.
    // Query radius needs to account for both agent's movement and potential threat's movement.
    // Estimate max relative speed as agent.maxSpeed * 2 for simplicity.
    // Add combined radii estimate (agent.radius * 2). Add a small buffer.
    final agentRadiusFactor = (agent.radius > 0 ? agent.radius : 1.0);
    final queryRadius = (agent.maxSpeed * 2.0 * maxPredictionTime) + (agentRadiusFactor * 2.0) + 10.0; // Increased radius significantly
    final potentialThreats = spatialGrid.queryRadius(agent.position, queryRadius);

    // 2. Iterate through potential threats to find the most imminent collision.
    for (final other in potentialThreats) {
      if (other == agent) continue; // Skip self

      _relativePosition.setFrom(other.position);
      _relativePosition.sub(agent.position);
      _relativeVelocity.setFrom(other.velocity);
      _relativeVelocity.sub(agent.velocity);
      final relativeSpeedSq = _relativeVelocity.length2;

      if (relativeSpeedSq < 1e-6) continue;

      final timeToClosest = -_relativePosition.dot(_relativeVelocity) / relativeSpeedSq;

      if (timeToClosest <= 1e-9 || timeToClosest > maxPredictionTime) continue;

      _separationAtClosest.setFrom(_relativeVelocity);
      _separationAtClosest.scale(timeToClosest);
      _separationAtClosest.add(_relativePosition);
      final separationDistSq = _separationAtClosest.length2;

      final combinedRadius = (agent.radius > 0 ? agent.radius : 0.1) + (other.radius > 0 ? other.radius : 0.1);
      final combinedRadiusSq = combinedRadius * combinedRadius;

      // Check if separation at CPA is less than combined radii (potential collision).
      // Add a small epsilon to the check for robustness against floating point issues.
      if (separationDistSq < combinedRadiusSq - 1e-6) { // Added epsilon
        if (timeToClosest < minTimeToCollision) {
          minTimeToCollision = timeToClosest;
          firstThreat = other;
          firstThreatRelativePosAtCPA = Vector2.copy(_separationAtClosest);
          _firstThreatRelativeVelocity.setFrom(_relativeVelocity); // Store rel vel for this threat
        }
      }
    }

    // 3. If an imminent threat was found, calculate avoidance force.
    if (firstThreat != null && firstThreatRelativePosAtCPA != null) {

      _avoidanceDir.setFrom(firstThreatRelativePosAtCPA);
      _avoidanceDir.negate(); // Point away from the other agent's position at CPA

      if (_avoidanceDir.length2 > 1e-9) {
         _avoidanceDir.normalize();
      } else {
         // Fallback for direct hit prediction: Use perpendicular to the *first threat's* relative velocity
         _avoidanceDir.setValues(-_firstThreatRelativeVelocity.y, _firstThreatRelativeVelocity.x);
         if (_avoidanceDir.length2 > 1e-9) _avoidanceDir.normalize(); else _avoidanceDir.setValues(1,0); // Absolute fallback
      }

      // Scale the force based on urgency (time remaining until CPA).
      final urgencyFactor = ((maxPredictionTime - minTimeToCollision) / (maxPredictionTime + 1e-9)).clamp(0.0, 1.0);

      // Calculate the steering force directly
      _steeringForce
        ..setFrom(_avoidanceDir)
        ..scale(avoidanceForceMultiplier * urgencyFactor * urgencyFactor); // Square urgency for stronger reaction

      // Return the calculated force. The SteeringManager should handle truncation.
      return _steeringForce;
    }

    // 4. No imminent collision detected.
    return Vector2.zero();
  }
}
