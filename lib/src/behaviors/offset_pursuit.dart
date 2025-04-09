import 'package:vector_math/vector_math_64.dart';
import 'dart:math'; // For max()

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/vector_utils.dart'; // Although not directly used, good practice
import 'arrival.dart'; // For doc links (uses Arrival logic)
import 'pursuit.dart'; // For doc links (uses prediction logic)

/// {@template offset_pursuit}
/// **Offset Pursuit** steering behavior: maintains a specific offset from a moving target.
///
/// This behavior allows an agent to follow another moving agent ([targetAgent])
/// while maintaining a specified relative position ([offset]). This is useful
/// for implementing formations (e.g., wingmen flying beside a leader), camera
/// following, or any scenario where an agent needs to stay near another but not
/// directly on top of it.
///
/// It works by:
/// 1. Predicting the [targetAgent]'s future position, similar to [Pursuit].
/// 2. Calculating the desired world-space offset position based on the target's
///    predicted future position and orientation (derived from its velocity).
///    The desired [offset] is provided in the *target's local space* (where +X
///    is typically forward, and +Y is typically left or up depending on convention).
/// 3. Using [Arrival]-like logic to steer the agent towards this calculated
///    world-space offset point, allowing it to slow down smoothly as it gets close.
///
/// Parameters like [slowingRadius] and [arrivalTolerance] control the arrival
/// aspect of the behavior at the offset point. [maxPredictionTime] limits the
/// prediction lookahead, similar to [Pursuit] and [Evade].
/// {@endtemplate}
/// @seealso [Pursuit], [Evade], [Arrival]
class OffsetPursuit extends SteeringBehavior {
  /// The target [Agent] being followed.
  /// The behavior accesses `targetAgent.position` and `targetAgent.velocity`.
  final Agent targetAgent;

  /// The desired offset from the [targetAgent]'s position, specified in the
  /// **target agent's local coordinate space**.
  ///
  /// It's assumed that the target agent's local +X axis points in the direction
  /// of its velocity (forward) and the +Y axis is perpendicular (e.g., left).
  /// - `Vector2(dx, dy)` where `dx` is distance along the target's forward/backward axis.
  /// - `Vector2(dx, dy)` where `dy` is distance along the target's side/up axis.
  ///
  /// Example: `Vector2(-10, 5)` could mean 10 units directly behind the target
  /// and 5 units to its left.
  /// Example: `Vector2(0, -15)` could mean 15 units directly to the target's right.
  final Vector2 offset;

  /// Optional: The maximum time (in seconds) into the future to predict the
  /// [targetAgent]'s position for calculating the offset point. Limits lookahead.
  /// If `null`, prediction time is based purely on distance and speed.
  /// Must be non-negative if provided. Defaults to 1.0.
  final double maxPredictionTime;

  /// The distance from the calculated world-space offset point at which the
  /// pursuing agent should start slowing down, using [Arrival] logic.
  /// Must be greater than 0. Defaults to `5.0`.
  final double slowingRadius;

  /// The tolerance radius around the calculated world-space offset point.
  /// Within this distance, the agent is considered "arrived" at the offset,
  /// and the internal [Arrival] logic will apply braking force.
  /// Must be non-negative. Defaults to `0.5`.
  final double arrivalTolerance;

  /// Creates an [OffsetPursuit] behavior.
  ///
  /// {@macro offset_pursuit}
  /// [targetAgent] The agent being followed.
  /// [offset] The desired offset in the target's local coordinate space.
  /// [slowingRadius] Distance to start slowing down for arrival at the offset
  ///   point (default: `5.0`, must be > 0).
  /// [arrivalTolerance] Distance within which the agent is considered arrived
  ///   at the offset (default: `0.5`, must be >= 0).
  /// [maxPredictionTime] Optional limit on prediction time (seconds, default: 1.0).
  ///   Must be non-negative if provided.
  OffsetPursuit({
    required this.targetAgent,
    required this.offset,
    this.slowingRadius = 5.0,
    this.arrivalTolerance = 0.5,
    this.maxPredictionTime = 1.0, // Provide a default
  }) : assert(slowingRadius > 0, 'slowingRadius must be positive'),
       assert(arrivalTolerance >= 0, 'arrivalTolerance cannot be negative.'),
       assert(maxPredictionTime >= 0, 'maxPredictionTime cannot be negative.');


  /// Calculates the offset pursuit steering force.
  ///
  /// 1. Estimates prediction time based on distance to the target agent and *leader's* speed.
  /// 2. Clamps prediction time using [maxPredictionTime].
  /// 3. Predicts the target agent's future position.
  /// 4. Determines the target agent's future orientation (using velocity).
  /// 5. Transforms the local [offset] into a world-space vector relative to the
  ///    target's future position and orientation.
  /// 6. Calculates the final world-space target point (future position + world offset).
  /// 7. Uses internal `_arrive` helper to steer towards the world-space target point.
  @override
  Vector2 calculateSteering(Agent agent) {
    // 1. Estimate prediction time based on distance and *leader's* speed.
    final distanceToTarget = (targetAgent.position - agent.position).length;
    final leaderSpeed = targetAgent.velocity.length;
    double predictionTime = (leaderSpeed > 1e-6) ? distanceToTarget / leaderSpeed : 0;

    // 2. Clamp prediction time.
    if (predictionTime > maxPredictionTime) {
      predictionTime = maxPredictionTime;
    }

    // 3. Predict the target's future position.
    final futurePosition =
        targetAgent.position + (targetAgent.velocity * predictionTime);

    // 4. Calculate the world-space offset point.
    Vector2 worldOffsetPoint;
    final targetVelocity = targetAgent.velocity;
    if (targetVelocity.length2 < 1e-6) {
      // Target stationary: Offset from current position without rotation.
      worldOffsetPoint = targetAgent.position + offset;
    } else {
      // Target moving: Transform offset based on target's heading.
      final targetForward = targetVelocity.normalized();
      final targetSide = Vector2(-targetForward.y, targetForward.x); // Perpendicular left

      // Transform local offset to world space relative to future position
      final worldOffset = (targetForward * offset.x) + (targetSide * offset.y);
      worldOffsetPoint = futurePosition + worldOffset;
    }

    // 5. Use Arrival logic to steer towards the world-space offset point.
    return _arrive(agent, worldOffsetPoint);
  }

  /// Internal helper function to perform the Arrival calculation towards a target point.
  /// Reuses the core logic of the Arrival behavior.
  ///
  /// [agent] The agent applying the arrival force.
  /// [targetPosition] The world position to arrive at.
  /// Returns the calculated steering force vector.
  Vector2 _arrive(Agent agent, Vector2 targetPosition) {
    // Vector from agent to the target offset point
    final offsetToTarget = targetPosition - agent.position;
    final distance = offsetToTarget.length;

    // Check if agent has effectively arrived at the offset point
    if (distance < arrivalTolerance) {
      // Apply braking force to stop at the offset point
      return -agent.velocity;
    }

    double desiredSpeed;
    if (distance < slowingRadius) {
      // Inside slowing radius, ramp down speed
      // Ensure slowingRadius is not zero to avoid division by zero
      final effectiveSlowingRadius = max(slowingRadius, 1e-6);
      desiredSpeed = agent.maxSpeed * (distance / effectiveSlowingRadius);
    } else {
      desiredSpeed = agent.maxSpeed;
    }

    // Avoid normalization issues if distance is extremely small
    if (distance < 1e-6) return Vector2.zero(); // Avoid division by zero

    final desiredVelocity = (offsetToTarget / distance) * desiredSpeed;
    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
  }
}
