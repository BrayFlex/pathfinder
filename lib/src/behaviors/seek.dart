import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/vector_utils.dart'; // Although not directly used, good practice
import 'arrival.dart'; // For doc links

/// {@template seek}
/// **Seek** steering behavior: directs the agent towards a target position.
///
/// This behavior calculates a steering force that directs the agent to move
/// towards a specified static [target] position at its maximum possible speed
/// ([Agent.maxSpeed]).
///
/// The core logic involves:
/// 1. Calculating the vector from the agent's current position to the target.
/// 2. Normalizing this vector to get the desired direction.
/// 3. Scaling the direction vector by the agent's `maxSpeed` to get the desired velocity.
/// 4. Calculating the steering force as the difference between the desired velocity
///    and the agent's current velocity (`steering = desired - current`).
///
/// Seek does **not** cause the agent to slow down as it approaches the target.
/// For behavior that includes deceleration near the target, use the [Arrival]
/// behavior instead.
///
/// The target position can be updated dynamically by modifying the public [target] field.
/// {@endtemplate}
/// @seealso [Arrival] for seeking with deceleration.
/// @seealso [Flee] for the opposite behavior (moving away).
/// @seealso [Pursuit] for seeking a moving target.
class Seek extends SteeringBehavior {
  /// The static world position ([Vector2]) that the agent should move towards.
  /// This can be updated at any time to change the agent's destination.
  Vector2 target;

  /// Creates a [Seek] behavior.
  ///
  /// [target] The initial world position to seek.
  /// {@macro seek}
  Seek({required this.target});

  @override
  Vector2 calculateSteering(Agent agent) {
    // Calculate the vector pointing from the agent to the target
    final desiredVelocity = target - agent.position;

    // Check if we are already at the target (or very close).
    // Avoid division by zero or normalization issues if distance is negligible.
    // Using length2 for efficiency.
    const double closeEnoughSquared = 0.01 * 0.01; // e.g., within 0.01 units
    if (desiredVelocity.length2 < closeEnoughSquared) {
      // Optionally, set velocity to zero if precise stopping is needed,
      // but Seek itself doesn't guarantee stopping. Arrival does.
      return Vector2.zero();
    }

    // Calculate desired velocity at maximum speed.
    desiredVelocity.normalize();
    desiredVelocity.scale(agent.maxSpeed);

    // Calculate the steering force (Desired Velocity - Current Velocity).
    final steeringForce = desiredVelocity - agent.velocity;

    // The SteeringManager will truncate this force later if needed.
    return steeringForce;
  }
}
