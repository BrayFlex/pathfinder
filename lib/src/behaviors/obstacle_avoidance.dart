import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../obstacle.dart';
import '../steering_behavior.dart';

/// {@template obstacle_avoidance}
/// **Obstacle Avoidance** steering behavior: steers to avoid static obstacles.
///
/// This behavior helps an agent navigate around predefined static obstacles
/// (currently only supports [CircleObstacle]). It works by projecting a
/// virtual "detection box" or feeler forward from the agent, aligned with its
/// current velocity. The length of this box is determined by [detectionBoxLength]
/// (potentially scaled by speed, though currently fixed in this implementation).
///
/// The behavior iterates through the provided list of [obstacles] and checks
/// for potential intersections between the detection box and the obstacles'
/// bounding shapes (considering both the obstacle's radius and the agent's radius).
///
/// If one or more obstacles intersect the detection box, the behavior identifies
/// the closest intersecting obstacle. It then calculates a steering force that
/// pushes the agent laterally (perpendicular to its heading) away from that
/// obstacle. The strength of this force is influenced by the
/// [avoidanceForceMultiplier] and is typically scaled based on how close the
/// obstacle is (closer obstacles generate stronger avoidance forces).
///
/// If no obstacles intersect the detection box, the behavior produces zero force.
///
/// **Note:** This implementation is currently optimized for and only considers
/// obstacles of type [CircleObstacle]. Other obstacle types in the list will be ignored.
/// {@endtemplate}
class ObstacleAvoidance extends SteeringBehavior {
  /// The list of static [Obstacle]s in the environment that the agent should
  /// attempt to avoid. Currently, only instances of [CircleObstacle] are processed.
  final List<Obstacle> obstacles;

  /// The nominal length of the detection box projected ahead of the agent.
  /// This determines how far ahead the agent "looks" for obstacles. A longer
  /// box allows for earlier detection but might react to distant obstacles.
  /// A common practice is to scale this length based on the agent's current
  /// speed, but this implementation uses a fixed length for simplicity.
  /// Must be non-negative. Defaults to `50.0`.
  final double detectionBoxLength;

  /// A multiplier that scales the magnitude of the calculated avoidance force.
  /// Higher values result in stronger, potentially more abrupt, avoidance maneuvers.
  /// Lower values result in gentler avoidance. Defaults to `100.0`.
  final double avoidanceForceMultiplier;

  /// Creates an [ObstacleAvoidance] behavior.
  ///
  /// {@macro obstacle_avoidance}
  /// [obstacles] A list of obstacles ([CircleObstacle] instances) to avoid.
  /// [detectionBoxLength] How far ahead to project the detection box
  ///   (default: `50.0`, must be >= 0).
  /// [avoidanceForceMultiplier] Strength multiplier for the avoidance steering
  ///   force (default: `100.0`).
  ObstacleAvoidance({
    required this.obstacles,
    this.detectionBoxLength = 50.0,
    this.avoidanceForceMultiplier = 100.0,
  }) : assert(detectionBoxLength >= 0, 'detectionBoxLength cannot be negative.');
       // avoidanceForceMultiplier can reasonably be zero or negative if desired.


  // --- Optimization: Pre-allocated vectors to reduce GC pressure ---
  final Vector2 _heading = Vector2.zero();
  final Vector2 _toObstacle = Vector2.zero();
  final Vector2 _closestPointOnHeading = Vector2.zero();
  final Vector2 _agentToObstacle = Vector2.zero();
  final Vector2 _lateralProjection = Vector2.zero();
  final Vector2 _avoidanceForce = Vector2.zero();
  Vector2 _lastRawAvoidanceForce = Vector2.zero(); // For debugging/testing
  // --- End Optimization ---

  /// Calculates the obstacle avoidance steering force for the given [agent].
  ///
  /// 1. Returns zero force if the agent is not moving.
  /// 2. Determines the agent's heading and the effective detection box length.
  /// 3. Iterates through the list of [obstacles] (currently only [CircleObstacle]s).
  /// 4. For each obstacle, projects its center onto the agent's heading vector.
  /// 5. Checks if the obstacle is generally ahead of the agent and within the
  ///    detection box length based on the projection.
  /// 6. Calculates the distance between the obstacle's center and the closest
  ///    point on the agent's heading line.
  /// 7. If this distance is less than the sum of the agent's radius and the
  ///    obstacle's radius, an intersection is detected.
  /// 8. Keeps track of the *closest* intersecting obstacle based on the
  ///    projection distance (`minIntersectionDistance`).
  /// 9. If a closest intersecting obstacle is found:
  ///    a. Calculates the lateral vector component from the agent to the obstacle
  ///       (perpendicular to the agent's heading).
  ///    b. Creates an avoidance force that opposes this lateral component (pushes
  ///       the agent sideways away from the obstacle).
  ///    c. Scales this force using [avoidanceForceMultiplier] and a proximity
  ///       factor (stronger force for closer obstacles along the heading).
  ///    d. Returns the calculated avoidance force.
  /// 10. If no obstacles intersect the detection box, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    // This implementation reuses pre-allocated Vector2 instances to minimize GC pressure.

    // Cannot avoid obstacles if not moving.
    if (agent.velocity.length2 < 1e-6) {
      return _avoidanceForce..setZero();
    }

    // Determine detection box length (currently fixed, could scale with speed).
    // Example scaling: final dynamicDetectionLength = detectionBoxLength * (agent.velocity.length / agent.maxSpeed);
    final dynamicDetectionLength = detectionBoxLength;

    // Calculate agent's heading (normalized velocity).
    _heading.setFrom(agent.velocity);
    _heading.normalize();

    // Variables to track the closest intersecting obstacle found so far.
    Obstacle? closestObstacle;
    double minIntersectionDistance = double.infinity;
    // Note: _localIntersectionPoint is not strictly needed with the current force calculation.

    // Iterate through obstacles to find the closest potential collision.
    for (final obstacle in obstacles) {
      // --- Basic Collision Check ---
      // TODO: Extend to support other Obstacle types (e.g., AABB, Polygon) - I need to port that over from my old game engine.
      if (obstacle is! CircleObstacle) continue;

      final obstaclePos = obstacle.position;
      // Effective radius for collision check includes both agent and obstacle radius.
      final radiusSum = (agent.radius > 0 ? agent.radius : 0.1) + obstacle.radius; // Ensure agent radius > 0 for check
      final radiusSumSq = radiusSum * radiusSum;

      // Vector from agent to the obstacle's center.
      _toObstacle.setFrom(obstaclePos);
      _toObstacle.sub(agent.position);

      // Project the obstacle's relative position onto the agent's heading vector.
      // This gives the distance along the heading to the point closest to the obstacle center.
      final projection = _toObstacle.dot(_heading);

      // Check if the obstacle is behind the agent or too far ahead (beyond detection box).
      if (projection < 0 || projection > dynamicDetectionLength) {
        continue;
      }

      // Calculate the closest point on the agent's heading line to the obstacle center.
      _closestPointOnHeading
        ..setFrom(_heading)
        ..scale(projection)
        ..add(agent.position); // World position of the closest point on heading

      // Calculate the squared distance from the obstacle center to this closest point on the heading line.
      final distToClosestPointSq = obstaclePos.distanceToSquared(_closestPointOnHeading);

      // Check if the obstacle intersects the agent's path (within the combined radius).
      if (distToClosestPointSq < radiusSumSq) {
        // Potential collision detected!
        // Check if this is the closest collision found so far along the heading.
        if (projection < minIntersectionDistance) {
          minIntersectionDistance = projection;
          closestObstacle = obstacle;
          // We only need to know *which* obstacle is closest for the force calculation below.
        }
      }
    }

    // --- Calculate Avoidance Force ---
    if (closestObstacle != null) {
      // Calculate a steering force perpendicular to the agent's heading,
      // pushing away from the obstacle's lateral position.

      // Vector from agent to the closest obstacle's center.
      _agentToObstacle.setFrom(closestObstacle.position);
      _agentToObstacle.sub(agent.position);

      // Calculate the lateral component of _agentToObstacle relative to _heading.
      // lateral = agentToObstacle - (agentToObstacle DOT heading) * heading
      final dotProduct = _agentToObstacle.dot(_heading);
      _lateralProjection.setFrom(_heading);
      _lateralProjection.scale(dotProduct); // Parallel component
      _lateralProjection.setFrom(_agentToObstacle); // Reset to full vector
      _lateralProjection.sub(_heading * dotProduct); // Subtract parallel -> Lateral component

      // The avoidance force should oppose the lateral projection.
      // Normalize the lateral component to get direction, then negate.
      if (_lateralProjection.length2 > 1e-6) { // Avoid normalizing zero vector
         _avoidanceForce.setFrom(_lateralProjection);
         _avoidanceForce.normalize();
         _avoidanceForce.negate(); // Point away laterally

         // Scale the force: stronger force for closer obstacles (along heading).
         // Proximity factor goes from 0 (far end of box) to 1 (at agent's position).
         final proximityFactor = (dynamicDetectionLength - minIntersectionDistance) / dynamicDetectionLength;
         _avoidanceForce.scale(avoidanceForceMultiplier * proximityFactor);

         // This force is returned directly; SteeringManager will truncate it.
         _lastRawAvoidanceForce.setFrom(_avoidanceForce); // Store raw force before returning
         return _avoidanceForce;
      }
      // else: Lateral projection is zero (obstacle is directly ahead/behind),
      // potentially handle this case? For now, falls through to zero force.
    }

    // No intersecting obstacles found within the detection box.
    _lastRawAvoidanceForce.setZero(); // Store zero raw force
    return _avoidanceForce..setZero();
  }

  /// Gets the last calculated raw avoidance force before velocity subtraction.
  /// Useful for debugging or testing the scaling logic.
  Vector2 get debugLastRawAvoidanceForce => _lastRawAvoidanceForce;
}
