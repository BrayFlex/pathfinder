import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import 'flee.dart'; // For doc links
import 'pursuit.dart'; // For doc links

/// {@template evade}
/// **Evade** steering behavior: flees from a predicted future position of a target agent.
///
/// This behavior enables an agent (the evader) to intelligently avoid a moving
/// pursuer ([targetAgent]). It is the inverse of [Pursuit]. Instead of simply
/// fleeing from the pursuer's current position (like [Flee]), Evade predicts
/// the pursuer's future position and steers to move away from that predicted location.
///
/// The prediction logic mirrors [Pursuit]: it estimates the time (`T`) it would
/// take the pursuer to reach the evader (`T = distance / pursuerSpeed`, using the
/// *evader's* maxSpeed as an approximation for the pursuer's speed for simplicity)
/// and calculates the pursuer's future position as
/// `target.position + target.velocity * T`.
///
/// An optional [maxPredictionTime] limits how far into the future the prediction looks.
/// An optional [evadeRadius] can be specified, causing the behavior to only activate
/// when the pursuer is within this distance.
///
/// If the pursuer is stationary, the behavior defaults to simple [Flee] from its
/// current position.
/// {@endtemplate}
/// @seealso [Flee] for fleeing a static target.
/// @seealso [Pursuit] for the opposite behavior (intercepting a moving target).
class Evade extends SteeringBehavior {
  /// The target [Agent] (pursuer) to evade.
  /// The behavior will access `targetAgent.position` and `targetAgent.velocity`.
  final Agent targetAgent;

  /// Optional: The maximum time (in seconds) into the future to predict the
  /// pursuer's position. If the calculated prediction time exceeds this value,
  /// it will be clamped. Helps prevent erratic evasion from distant targets.
  /// If `null`, the prediction time is not explicitly limited.
  final double? maxPredictionTime;

  /// Optional: The radius around the **evader**. Evasion only occurs if the
  /// [targetAgent] (pursuer) is within this distance from the evader.
  /// If `null` (the default), the agent will always attempt to evade the
  /// pursuer, regardless of distance.
  /// If set, must be a positive value.
  final double? evadeRadius;

  /// Creates an [Evade] behavior.
  ///
  /// {@macro evade}
  /// [targetAgent] The agent (pursuer) to evade.
  /// [maxPredictionTime] Optional limit on the prediction time (seconds).
  ///   Must be non-negative if provided.
  /// [evadeRadius] Optional distance from the evader within which evasion
  ///   should activate. If null, evasion is always active. Must be positive if set.
  Evade({
    required this.targetAgent,
    this.maxPredictionTime,
    this.evadeRadius,
  }) {
     assert(maxPredictionTime == null || maxPredictionTime! >= 0,
            'maxPredictionTime cannot be negative.');
     assert(evadeRadius == null || evadeRadius! > 0,
            'evadeRadius must be positive if set.');
  }


  /// Calculates the evade steering force for the given [agent].
  ///
  /// Implements the prediction and flee logic:
  /// 1. Calculates distance to the target agent (pursuer).
  /// 2. If pursuer is outside [evadeRadius] (if set), returns zero force.
  /// 3. If pursuer is stationary, defaults to fleeing the current position.
  /// 4. Estimates prediction time based on distance and evader's max speed.
  /// 5. Clamps prediction time if [maxPredictionTime] is set.
  /// 6. Calculates the pursuer's predicted future position.
  /// 7. Uses internal `_flee` helper to calculate steering away from the future position.
  @override
  Vector2 calculateSteering(Agent agent) {
    // 1. Calculate vector and distance to the target agent (pursuer).
    final offset = targetAgent.position - agent.position;
    final distance = offset.length;

    // 2. Check if pursuer is outside the activation radius.
    if (evadeRadius != null && distance > evadeRadius!) {
      return Vector2.zero(); // Pursuer is too far away, no need to evade.
    }

    // 3. Check if pursuer is stationary.
    const double speedThreshold = 0.1; // Threshold to consider target stationary
    if (targetAgent.velocity.length2 < speedThreshold * speedThreshold) {
      // Pursuer is not moving (or moving very slowly), just flee current position.
      return _flee(agent, targetAgent.position);
    }

    // 4. Estimate the prediction time 'T'.
    // Use evader's maxSpeed as approximation for pursuer's speed for simplicity.
    // Avoid division by zero.
    double predictionTime = (agent.maxSpeed > 1e-6) ? distance / agent.maxSpeed : 0;

    // 5. Clamp prediction time if maxPredictionTime is specified.
    if (maxPredictionTime != null && predictionTime > maxPredictionTime!) {
      predictionTime = maxPredictionTime!;
    }

    // 6. Predict the pursuer's future position.
    // futurePosition = target.position + target.velocity * predictionTime
    // Reuse 'offset' vector to store future position to save allocation.
    final futurePosition = offset // Reusing offset vector instance
      ..setFrom(targetAgent.velocity)
      ..scale(predictionTime)
      ..add(targetAgent.position);

    // 7. Flee from the predicted future position.
    return _flee(agent, futurePosition);
  }

  /// Internal helper function to perform the Flee calculation from a given point.
  /// Reuses the core logic of the Flee behavior.
  ///
  /// [agent] The agent applying the flee force.
  /// [targetPosition] The world position to flee from.
  /// Returns the calculated steering force vector.
  Vector2 _flee(Agent agent, Vector2 targetPosition) {
    // Calculate desired velocity: vector away from target at max speed
    final desiredVelocity = agent.position - targetPosition;

    // If agent is exactly at the target (or predicted target), desiredVelocity is zero.
    // In this case, provide a default push away from the target's *current* position
    // to ensure some evasive action occurs.
    if (desiredVelocity.length2 < 1e-9) { // Use a small epsilon
      desiredVelocity.setFrom(agent.position - targetAgent.position); // Flee current pos as fallback
      // If still zero (agent on top of target), pick an arbitrary direction?
      if (desiredVelocity.length2 < 1e-9) {
        desiredVelocity.setValues(agent.maxSpeed, 0); // Default push right
      } else {
         desiredVelocity.length = agent.maxSpeed; // Scale to max speed
      }
    } else {
       desiredVelocity.normalize();
       desiredVelocity.scale(agent.maxSpeed);
    }


    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
  }
}
