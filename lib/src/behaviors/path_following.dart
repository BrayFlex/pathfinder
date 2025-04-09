import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../path.dart';
import '../steering_behavior.dart';

/// {@template path_following}
/// **Path Following** steering behavior: guides an agent along a predefined [Path].
///
/// This behavior steers the agent to follow a sequence of connected line segments
/// defined by a [Path] object. It tries to keep the agent within the path's
/// specified [Path.radius] and encourages progression towards the end of the path.
///
/// The core logic involves:
/// 1. Predicting the agent's future position based on its current velocity and
///    a [predictionDistance].
/// 2. Finding the point on the path segments (near the agent's current segment)
///    that is closest to this predicted future position.
/// 3. If the predicted future position is significantly "off-path" (further than
///    [Path.radius] from the closest point), the behavior steers the agent back
///    towards that closest point on the path spine (using Seek logic).
/// 4. If the predicted future position is "on-path" (within the radius), the
///    behavior calculates a target point further along the path (by moving
///    [predictionDistance] along the current path segment from the closest point)
///    and steers the agent towards that future point on the path (using Seek logic).
/// 5. The behavior tracks the current path segment (`_currentSegmentIndex`) the
///    agent is aiming for and advances this index as the agent progresses.
///
/// This implementation checks a few segments ahead (`segmentsToCheck`) when finding
/// the closest point to handle turns more smoothly.
/// {@endtemplate}
/// @seealso [Path]
class PathFollowing extends SteeringBehavior {
  /// The [Path] object defining the route the agent should follow.
  /// This object contains the waypoints, radius, and loop behavior.
  /// Note: This is marked `final`. To change the path, a new instance of
  /// `PathFollowing` needs to be created and added to the `SteeringManager`.
  final Path path;

  /// How far ahead (in world units) along the agent's current velocity vector
  /// to project its future position for path prediction. A larger distance
  /// anticipates turns earlier but might cut corners more. Defaults to `20.0`.
  /// Must be non-negative.
  final double predictionDistance;

  /// Internal state: Tracks the index of the path segment the agent is currently
  /// nearest to or aiming towards. Used to optimize the search for the closest
  /// point on the path and to manage progression along the path.
  int _currentSegmentIndex = 0;

  /// Internal state: Stores the last calculated closest point on the path spine
  /// to the agent's predicted future position. Primarily for debugging or visualization.
  Vector2 _lastClosestPoint = Vector2.zero();

  /// Creates a [PathFollowing] behavior.
  ///
  /// {@macro path_following}
  /// [path] The [Path] object defining the route.
  /// [predictionDistance] How far ahead to predict the agent's position
  ///   (default: `20.0`, must be >= 0).
  PathFollowing({
    required this.path,
    this.predictionDistance = 20.0,
  }) : assert(predictionDistance >= 0, 'predictionDistance cannot be negative.');


  /// Calculates the path following steering force.
  ///
  /// Implements the prediction, path projection, and steering logic described
  /// in the class documentation.
  @override
  Vector2 calculateSteering(Agent agent) {
    // Cannot follow a path if not moving (or moving very slowly)
    // as prediction relies on velocity direction.
    if (agent.velocity.length2 < 1e-6) {
      // If not moving, maybe seek the start of the path? Or just do nothing.
      // For now, do nothing if velocity is zero.
      return Vector2.zero();
    }

    // 1. Predict future position
    final futurePosition = agent.position + (agent.velocity.normalized() * predictionDistance);

    // 2. Find the closest point on the *current or next* path segment(s)
    //    to the predicted future position. This requires checking multiple segments
    //    to handle turns smoothly.
    Vector2 closestPointOnPath = Vector2.zero();
    double minDistanceSq = double.infinity;
    int bestSegmentIndex = _currentSegmentIndex; // Start search from current segment

    // Check a few segments ahead (e.g., current and next 2)
    // Adjust the number of segments to check based on path complexity/agent speed.
    const int segmentsToCheck = 3;
    for (int i = 0; i < segmentsToCheck; ++i) {
      int segmentIndex = (_currentSegmentIndex + i) % path.segmentCount;
      if (!path.loop && (_currentSegmentIndex + i) >= path.segmentCount) {
        // Don't wrap around if not looping and we've reached the end
        segmentIndex = path.segmentCount - 1; // Clamp to last segment
      }

      final segmentStart = path.getSegmentStart(segmentIndex);
      final segmentEnd = path.getSegmentEnd(segmentIndex);
      final pointOnSegment = _getClosestPointOnSegment(
          segmentStart, segmentEnd, futurePosition);
      final distanceSq = futurePosition.distanceToSquared(pointOnSegment);

      if (distanceSq < minDistanceSq) {
        minDistanceSq = distanceSq;
        closestPointOnPath = pointOnSegment;
        bestSegmentIndex = segmentIndex; // Remember which segment was closest
      }

      if (!path.loop && segmentIndex == path.segmentCount - 1) {
        break; // Stop checking if we hit the end of a non-looping path
      }
    }

    // Update the current segment if the best match is ahead
    // This logic helps the agent progress along the path segments.
    // Simple approach: if the best segment is ahead of current, update.
    // More robust logic might be needed for complex paths or high speeds.
    if (bestSegmentIndex != _currentSegmentIndex) {
       // Basic check: allow moving forward, handle looping wrap-around
       int diff = bestSegmentIndex - _currentSegmentIndex;
       if (diff > 0 || (path.loop && diff < -(path.segmentCount ~/ 2))) {
          _currentSegmentIndex = bestSegmentIndex;
       } else if (!path.loop && bestSegmentIndex == path.segmentCount - 1 && _currentSegmentIndex != bestSegmentIndex) {
         // Allow moving to the last segment if not looping
         _currentSegmentIndex = bestSegmentIndex;
       }
    }
     _lastClosestPoint = closestPointOnPath.clone(); // Store for potential debugging/drawing


    // 3. Check if the future position is off-path
    final distanceToPath = sqrt(minDistanceSq);
    Vector2 steeringTarget;

    if (distanceToPath > path.radius) {
      // Off-path: Steer back towards the closest point on the path spine
      steeringTarget = closestPointOnPath;
    } else {
      // On-path: Steer towards a point slightly ahead on the path
      final currentSegmentStart = path.getSegmentStart(_currentSegmentIndex);
      final currentSegmentEnd = path.getSegmentEnd(_currentSegmentIndex);
      final segmentDirection = (currentSegmentEnd - currentSegmentStart).normalized();

      // Target point is the closest point + a lookahead distance along the segment
      steeringTarget = closestPointOnPath + (segmentDirection * predictionDistance);
    }

    // 4. Use Seek logic to steer towards the calculated target
    return _seek(agent, steeringTarget);
  }

  /// Internal helper: Finds the closest point on a line segment (defined by
  /// points [a] and [b]) to a given point [p].
  ///
  /// Uses vector projection to find the parameter `t` along the segment AB
  /// that corresponds to the point closest to P, then clamps `t` to the range
  /// [0, 1] to ensure the point lies *on* the segment.
  ///
  /// [a] Start point of the line segment.
  /// [b] End point of the line segment.
  /// [p] The point to find the closest point on the segment to.
  /// Returns the [Vector2] coordinates of the closest point on the segment AB.
  Vector2 _getClosestPointOnSegment(Vector2 a, Vector2 b, Vector2 p) {
    // Vector from A to P
    final ap = p - a;
    // Vector from A to B (the segment direction and length)
    final ab = b - a;
    final abLengthSq = ab.length2;

    if (abLengthSq == 0.0) {
      return a; // Segment is just a point
    }

    // Project p onto the line defined by ab
    double t = ap.dot(ab) / abLengthSq;

    // Clamp t to the range [0, 1] to stay within the segment
    t = t.clamp(0.0, 1.0);

    // Calculate the closest point on the segment
    return a + (ab * t);
  }

   /// Internal helper function to perform the Seek calculation towards a target point.
   /// Reuses the core logic of the Seek behavior.
   ///
   /// [agent] The agent applying the seek force.
   /// [targetPosition] The world position to seek towards.
   /// Returns the calculated steering force vector.
  Vector2 _seek(Agent agent, Vector2 targetPosition) {
    // Calculate desired velocity: vector towards target at max speed
    final desiredVelocity = targetPosition - agent.position;

    // Avoid normalizing zero vector if already at target
    if (desiredVelocity.length2 < 1e-6) {
      return Vector2.zero();
    }

    desiredVelocity.normalize();
    desiredVelocity.scale(agent.maxSpeed);

    // Calculate steering force: desired velocity - current velocity
    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
  }

  /// Resets the internal state of the behavior.
  ///
  /// This should be called if the agent is teleported or moved discontinuously,
  /// as the internal `_currentSegmentIndex` might become invalid. It resets
  /// the tracking to the start of the path (segment 0).
  ///
  /// A more sophisticated reset could potentially find the path segment closest
  /// to the agent's new position.
  void reset() {
    _currentSegmentIndex = 0;
    _lastClosestPoint = Vector2.zero();
  }

  /// Gets the last calculated closest point on the path spine to the agent's
  /// predicted future position. Useful for debugging or visualizing the
  /// behavior's internal state.
  Vector2 get debugLastClosestPoint => _lastClosestPoint;

  /// Gets the index of the path segment the behavior is currently targeting.
  /// Useful for debugging or visualizing the agent's progress along the path.
  int get debugCurrentSegmentIndex => _currentSegmentIndex;
}
