import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../flow_field.dart'; // Requires FlowField to be defined here or imported
import '../steering_behavior.dart';

/// {@template flow_field_following}
/// **Flow Field Following** steering behavior: aligns agent movement with a flow field.
///
/// This behavior steers the agent to move in the direction specified by a
/// [FlowField] at a particular sample point. A flow field typically divides the
/// environment into a grid, with each cell containing a vector indicating the
/// desired direction of movement within that cell. This is often used for large
/// group navigation where pre-calculating the field is more efficient than
/// individual pathfinding for every agent.
///
/// The behavior determines a sample position:
/// - If [predictionDistance] is provided and positive, it predicts the agent's
///   future position based on its current velocity and samples the field there.
///   This allows the agent to anticipate changes in the flow field.
/// - Otherwise, it samples the field at the agent's current position.
///
/// It then looks up the desired flow vector from the [flowField] at the sample
/// position. This desired flow vector is treated as the desired velocity direction.
/// The behavior calculates the steering force needed to align the agent's current
/// velocity with this desired velocity (moving at [Agent.maxSpeed]).
///
/// **Note:** This implementation assumes a [FlowField] class is defined (likely
/// in `flow_field.dart` or imported) and provides a `lookup(Vector2 position)`
/// method that returns the desired flow vector ([Vector2]) at the given world position.
/// {@endtemplate}
/// @seealso [FlowField]
class FlowFieldFollowing extends SteeringBehavior {
  /// The [FlowField] instance that defines the desired movement directions
  /// across the environment.
  final FlowField flowField;

  /// Optional: How far ahead (in world units) along the agent's current velocity
  /// vector to predict its position when sampling the [flowField].
  /// If `null` or zero (the default), the field is sampled at the agent's
  /// current position. Using a positive prediction distance can help the agent
  /// anticipate turns or changes in the flow field more smoothly.
  /// Must be non-negative if provided.
  final double? predictionDistance;

  /// Creates a [FlowFieldFollowing] behavior.
  ///
  /// {@macro flow_field_following}
  /// [flowField] The [FlowField] defining the desired movement directions.
  /// [predictionDistance] Optional distance ahead to sample the field (>= 0).
  ///   Defaults to `null` (sample at current position).
  FlowFieldFollowing({
    required this.flowField,
    this.predictionDistance,
  }) : assert(predictionDistance == null || predictionDistance >= 0,
               'predictionDistance cannot be negative.');


  /// Calculates the flow field following steering force.
  ///
  /// 1. Determines the position at which to sample the flow field (current or predicted).
  /// 2. Looks up the desired flow vector from the [flowField] at that position.
  /// 3. If the flow vector is non-zero, calculates a desired velocity in that
  ///    direction at the agent's maximum speed.
  /// 4. Computes and returns the steering force required to achieve the desired velocity
  ///    (desired velocity - current velocity).
  /// 5. If the flow vector is zero, returns `Vector2.zero()`.
  @override
  Vector2 calculateSteering(Agent agent) {
    Vector2 samplePosition;

    // 1. Determine the position to sample the flow field.
    // Predict ahead if distance is positive and agent is moving.
    if (predictionDistance != null &&
        predictionDistance! > 1e-6 && // Use epsilon for robustness
        agent.velocity.length2 > 1e-6)
    {
      // Avoid normalizing zero vector if velocity is negligible.
      samplePosition = agent.position + (agent.velocity.normalized() * predictionDistance!);
    } else {
      // Sample at the agent's current position.
      samplePosition = agent.position;
    }

    // 2. Lookup the desired flow direction from the field.
    final desiredFlow = flowField.lookup(samplePosition);

    // If the desired flow is zero, no steering is needed from this behavior
    if (desiredFlow.length2 == 0) {
      return Vector2.zero();
    }

    // Calculate desired velocity based on the flow direction at max speed
    final desiredVelocity = desiredFlow.normalized() * agent.maxSpeed;

    // Calculate the steering force (Desired Velocity - Current Velocity)
    final steeringForce = desiredVelocity - agent.velocity;

    // SteeringManager will truncate
    return steeringForce;
  }
}
