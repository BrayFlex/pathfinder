import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../obstacle.dart'; // Requires WallSegment to be defined here or imported
import '../steering_behavior.dart';

/// {@template wall_following}
/// **Wall Following** steering behavior: guides an agent along walls.
///
/// This behavior attempts to keep an agent moving parallel to nearby walls
/// (represented as [WallSegment] obstacles) while maintaining a specified
/// [desiredDistance]. It achieves this by projecting virtual "feelers" from the
/// agent in various directions (typically forward and slightly angled to the sides).
///
/// The behavior checks if any of these feelers intersect with the provided [walls].
/// If an intersection is detected, it identifies the closest intersection point.
/// A steering force is then calculated based on this closest intersection:
/// - The primary force component pushes the agent away from the wall along the
///   wall's normal vector. The magnitude of this force is typically proportional
///   to how much the feeler has "penetrated" the desired distance band around the wall.
/// - A secondary, smaller force component might be added parallel to the wall's
///   tangent to encourage continued forward movement along the wall.
///
/// The lengths of the feelers ([feelerLength]) determine how far ahead the agent
/// "looks" for walls. The [wallForceMultiplier] scales the overall strength of
/// the corrective steering force.
///
/// **Note:** This implementation assumes [WallSegment] obstacles are defined in
/// `obstacle.dart` (or imported) and have `start`, `end`, and `normal` properties.
/// The feeler setup and force calculation logic might require tuning for optimal
/// behavior in different scenarios.
/// {@endtemplate}
class WallFollowing extends SteeringBehavior {
  /// A list containing the [WallSegment] obstacles in the environment that the
  /// agent should follow. Assumes `WallSegment` has `start`, `end`, and `normal` properties.
  final List<WallSegment> walls;

  /// The desired distance the agent should try to maintain from any detected wall.
  /// Must be non-negative. Defaults to `10.0`.
  final double desiredDistance;

  /// The length of the virtual feelers projected from the agent to detect walls.
  /// Longer feelers allow earlier detection but might cause reactions to distant walls.
  /// Must be positive. Defaults to `50.0`.
  final double feelerLength;

  /// A multiplier scaling the steering force calculated to push the agent away
  /// from or along the wall. Higher values result in stronger reactions.
  /// Defaults to `50.0`.
  final double wallForceMultiplier;

  /// Internal list storing the feeler vectors relative to the agent's local space
  /// (where +X is forward). These are transformed into world space during calculation.
  final List<Vector2> _feelers = [];

  /// Creates a [WallFollowing] behavior.
  ///
  /// Initializes a default set of three feelers (forward, 45 deg left, 45 deg right).
  ///
  /// {@macro wall_following}
  /// [walls] List of [WallSegment] obstacles representing the walls.
  /// [desiredDistance] The target distance to keep from walls (default: `10.0`, >= 0).
  /// [feelerLength] How far the feelers project (default: `50.0`, > 0).
  /// [wallForceMultiplier] Strength of the wall avoidance/following force (default: `50.0`).
  WallFollowing({
    required this.walls,
    this.desiredDistance = 10.0,
    this.feelerLength = 50.0,
    this.wallForceMultiplier = 50.0,
  }) : assert(desiredDistance >= 0, 'desiredDistance cannot be negative.'),
       assert(feelerLength > 0, 'feelerLength must be positive.')
       // wallForceMultiplier can be zero or negative if desired.
  {
    // Initialize feelers relative to agent's local forward direction (+X).
    // This setup uses 3 feelers: one straight ahead, two angled at 45 degrees.
    // Feelers are defined by their endpoint relative to the agent if agent is at (0,0) facing (1,0).
    if (feelerLength > 0) {
      // Feeler 1: Straight ahead
      _feelers.add(Vector2(feelerLength, 0));
      // Feeler 2: 45 degrees left (assuming +Y is left in local space)
      _feelers.add(Vector2(feelerLength * 0.70710678118, feelerLength * 0.70710678118)); // cos(45), sin(45)
      // Feeler 3: 45 degrees right (assuming -Y is right in local space)
      _feelers.add(Vector2(feelerLength * 0.70710678118, -feelerLength * 0.70710678118)); // cos(45), -sin(45)
    }
  }

  /// Calculates the wall following steering force.
  ///
  /// 1. Determines agent's heading and side vectors based on velocity.
  /// 2. Initializes tracking variables for the closest wall intersection.
  /// 3. Iterates through each predefined feeler:
  ///    a. Transforms the local feeler vector into a world-space end point.
  ///    b. Defines a line segment representing the feeler (agent pos to feeler end).
  ///    c. Iterates through each wall segment:
  ///       i. Checks for intersection between the feeler segment and the wall segment
  ///          using [_lineSegmentIntersection].
  ///       ii. If an intersection occurs and is closer than the current closest,
  ///           updates the closest wall, intersection point, and the feeler involved.
  /// 4. If a closest intersection was found:
  ///    a. Calculates a primary steering force along the wall's normal vector,
  ///       scaled by how much the feeler "penetrated" beyond the intersection point.
  ///    b. (Optionally) Adds a smaller secondary force parallel to the wall's tangent
  ///       to encourage forward movement.
  ///    c. Returns the combined force.
  /// 5. If no intersection was found, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    // Cannot follow walls if not moving (need heading).
    if (agent.velocity.length2 < 1e-6) return Vector2.zero();

    // Agent's current orientation vectors.
    final agentHeading = agent.velocity.normalized();
    final agentSide = Vector2(-agentHeading.y, agentHeading.x); // Perpendicular left

    // Variables to store details of the closest intersection found.
    double minDistanceToIntersectionSq = double.infinity;
    WallSegment? closestWallSegment;
    Vector2? closestIntersectionPointWorld;
    // Vector2? feelerVectorWorld; // Could store the specific feeler vector that hit

    // Check each feeler for intersections with walls.
    for (final feelerLocal in _feelers) {
      // Transform local feeler endpoint to world space.
      // feelerEndWorld = agent.position + localX * heading + localY * side
      final feelerEndX = agent.position.x + feelerLocal.x * agentHeading.x + feelerLocal.y * agentSide.x;
      final feelerEndY = agent.position.y + feelerLocal.x * agentHeading.y + feelerLocal.y * agentSide.y;
      final feelerEndWorld = Vector2(feelerEndX, feelerEndY);

      // Define the feeler line segment in world space.
      final feelerStartWorld = agent.position;

      // Find the closest intersection point for *this* feeler across all walls.
      for (final wall in walls) {
        final intersectionPoint = _lineSegmentIntersection(
            feelerStartWorld, feelerEndWorld, wall.start, wall.end);

        if (intersectionPoint != null) {
          // Calculate squared distance to this intersection point.
          final distanceSq = agent.position.distanceToSquared(intersectionPoint);

          // If this intersection is closer than any found so far, record it.
          if (distanceSq < minDistanceToIntersectionSq) {
            minDistanceToIntersectionSq = distanceSq;
            closestWallSegment = wall;
            closestIntersectionPointWorld = intersectionPoint;
            // feelerVectorWorld = feelerEndWorld - feelerStartWorld; // Store feeler if needed
          }
        }
      }
    }

    // If a feeler intersected with a wall, calculate the steering force.
    Vector2 steeringForce = Vector2.zero(); // Initialize force
    if (closestWallSegment != null && closestIntersectionPointWorld != null) {
      final wallNormal = closestWallSegment.normal;

      // Calculate a force component perpendicular to the wall (along the normal).
      // The magnitude should be stronger the deeper the feeler penetrates.
      // Simplified: Scale force by how far the intersection point is *short* of the full feeler length.
      final distanceToIntersection = sqrt(minDistanceToIntersectionSq);
      final penetration = feelerLength - distanceToIntersection;

      // Ensure force is applied only if there's penetration and scale it.
      if (penetration > 0) {
        // Force direction is along the wall normal (away from the wall).
        // Magnitude is proportional to penetration and the multiplier.
        steeringForce = wallNormal * (penetration * wallForceMultiplier / feelerLength);
      }

      // Optional: Add a small force component parallel to the wall to encourage
      // forward movement along the wall. This helps prevent getting stuck.
      // final wallTangent = Vector2(-wallNormal.y, wallNormal.x); // Or (wallNormal.y, -wallNormal.x)
      // steeringForce.add(wallTangent * someSmallFactor);
    }

    // The SteeringManager will truncate the final force.
    return steeringForce;
  }

  /// Internal helper: Checks for intersection between two line segments (p1-p2 and p3-p4).
  ///
  /// Uses the standard line segment intersection algorithm based on parameters `t` and `u`.
  ///
  /// [p1] Start point of the first segment (e.g., feeler start).
  /// [p2] End point of the first segment (e.g., feeler end).
  /// [p3] Start point of the second segment (e.g., wall start).
  /// [p4] End point of the second segment (e.g., wall end).
  ///
  /// Returns the [Vector2] intersection point if the segments intersect,
  /// otherwise returns `null`.
  Vector2? _lineSegmentIntersection(Vector2 p1, Vector2 p2, Vector2 p3, Vector2 p4) {
    // Calculate denominator
    final double d = (p1.x - p2.x) * (p3.y - p4.y) - (p1.y - p2.y) * (p3.x - p4.x);

    // Check if lines are parallel (denominator is zero or very close)
    if (d.abs() < 1e-6) {
      return null;
    }

    // Calculate parameter t for the first segment (p1-p2)
    final double t = ((p1.x - p3.x) * (p3.y - p4.y) - (p1.y - p3.y) * (p3.x - p4.x)) / d;

    // Calculate parameter u for the second segment (p3-p4)
    final double u = -((p1.x - p2.x) * (p1.y - p3.y) - (p1.y - p2.y) * (p1.x - p3.x)) / d;

    // Check if the intersection point lies within both segments (0 <= t <= 1 and 0 <= u <= 1)
    if (t >= 0 && t <= 1 && u >= 0 && u <= 1) {
      // Calculate the intersection point: p1 + t * (p2 - p1)
      return Vector2(p1.x + t * (p2.x - p1.x), p1.y + t * (p2.y - p1.y));
    }

    // Segments do not intersect within their bounds.
    return null;
  }
}
