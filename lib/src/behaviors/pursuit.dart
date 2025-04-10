import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import 'seek.dart'; // For doc links and internal _seek call

/// {@template pursuit}
/// **Pursuit** steering behavior: intercepts a moving target agent.
///
/// This behavior enables an agent (the pursuer) to intelligently intercept
/// another moving agent (the quarry or [targetAgent]). Unlike simple [Seek],
/// which aims directly at the target's current position (often resulting in a
/// tail chase), Pursuit predicts the target's future position and steers towards
/// that predicted location.
///
/// The prediction is based on the distance between the agents and their relative
/// speeds. A simple estimation for the time (`T`) it will take the pursuer to
/// reach the target is calculated (`T = distance / pursuerSpeed`). The target's
/// future position is then estimated as `target.position + target.velocity * T`.
///
/// An optional [maxPredictionTime] can be provided to limit how far into the
/// future the prediction looks. This can prevent the pursuer from overshooting
/// or chasing wildly if the target is very far away or changes direction abruptly.
///
/// If the target is stationary or very close, the behavior defaults to simple
/// [Seek] towards the target's current position.
/// {@endtemplate}
/// @seealso [Seek] for pursuing a static target.
/// @seealso [Evade] for the opposite behavior (fleeing a predicted position).
class Pursuit extends SteeringBehavior {
  /// The target [Agent] being pursued.
  /// The behavior will access `targetAgent.position` and `targetAgent.velocity`.
  final Agent targetAgent;

  /// Optional: The maximum time (in seconds) into the future to predict the
  /// target's position. If the calculated prediction time based on distance
  /// and speed exceeds this value, it will be clamped to `maxPredictionTime`.
  /// Helps prevent overly long predictions for distant or fast targets.
  /// If `null`, the prediction time is not explicitly limited.
  final double? maxPredictionTime;

  /// Creates a [Pursuit] behavior.
  ///
  /// {@macro pursuit}
  /// [targetAgent] The agent to pursue.
  /// [maxPredictionTime] Optional limit on the prediction time (seconds).
  ///   Must be non-negative if provided.
  Pursuit({required this.targetAgent, this.maxPredictionTime}) {
     assert(maxPredictionTime == null || maxPredictionTime! >= 0,
            'maxPredictionTime cannot be negative.');
  }


  /// Calculates the pursuit steering force for the given [agent].
  ///
  /// Implements the prediction logic:
  /// 1. Calculates distance to the target agent.
  /// 2. If target is slow or close, defaults to seeking the current position.
  /// 3. Estimates prediction time based on distance and pursuer's max speed.
  /// 4. Clamps prediction time if [maxPredictionTime] is set.
  /// 5. Calculates the target's predicted future position.
  /// 6. Uses internal `_seek` helper to calculate steering towards the future position.
  @override
  Vector2 calculateSteering(Agent agent) {
    // 1. Calculate vector and distance to the target agent.
    final offset = targetAgent.position - agent.position;
    final distance = offset.length;

    // 2. Check if target is stationary or agent is very close.
    const double speedThreshold = 0.1; // Threshold to consider target stationary
    const double closeDistance = 0.1;  // Threshold to consider agent very close
    if (targetAgent.velocity.length2 < speedThreshold * speedThreshold ||
        distance < closeDistance) {
      // Target is stationary or too close for meaningful prediction, just seek.
      return _seek(agent, targetAgent.position);
    }

    // 3. Estimate the prediction time 'T'.
    // A simple estimate is distance / pursuer's max speed.
    // More sophisticated estimates could use relative velocity, but this is common.
    // Avoid division by zero if maxSpeed is zero (though unlikely for a pursuer).
    double predictionTime = (agent.maxSpeed > 1e-6) ? distance / agent.maxSpeed : 0;

    // 4. Clamp prediction time if maxPredictionTime is specified.
    if (maxPredictionTime != null && predictionTime > maxPredictionTime!) {
      predictionTime = maxPredictionTime!;
    }

    // 5. Predict the target's future position.
    // futurePosition = target.position + target.velocity * predictionTime
    // Reuse 'offset' vector to store future position to save allocation. NO - this caused bugs. Create new vector.
    // Note: This simple prediction assumes constant velocity of the target.
    final futurePosition = targetAgent.position + (targetAgent.velocity * predictionTime);

    // 6. Seek the predicted future position.
    return _seek(agent, futurePosition);
  }

  /// Internal helper function to perform the Seek calculation towards a given point.
  /// Reuses the core logic of the Seek behavior to avoid duplication.
  ///
  /// [agent] The agent applying the seek force.
  /// [targetPosition] The world position to seek towards.
  /// Returns the calculated steering force vector.
  Vector2 _seek(Agent agent, Vector2 targetPosition) {
    // Calculate desired velocity: vector towards target at max speed
    final desiredVelocity = targetPosition - agent.position;

    // Check if already very close to the target position
    const double closeEnoughSquared = 0.01 * 0.01;
    if (desiredVelocity.length2 < closeEnoughSquared) {
      return Vector2.zero();
    }

    desiredVelocity.normalize();
    desiredVelocity.scale(agent.maxSpeed);

    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
  }
}
