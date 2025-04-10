import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import 'seek.dart'; // For doc links

/// {@template flee}
/// **Flee** steering behavior: directs the agent *away* from a target position.
///
/// This behavior calculates a steering force that directs the agent to move
/// directly away from a specified static [target] position at its maximum
/// possible speed ([Agent.maxSpeed]). It is the inverse of the [Seek] behavior.
///
/// An optional [fleeRadius] can be specified. If provided, the fleeing behavior
/// will only activate when the target is within this distance from the agent.
/// If the target is outside the radius, this behavior produces no steering force.
///
/// The core logic involves:
/// 1. Checking if the target is within the optional [fleeRadius] (if provided).
/// 2. Calculating the vector from the target to the agent's current position.
/// 3. Normalizing this vector to get the desired direction (away from the target).
/// 4. Scaling the direction vector by the agent's `maxSpeed` to get the desired velocity.
/// 5. Calculating the steering force as the difference between the desired velocity
///    and the agent's current velocity (`steering = desired - current`).
///
/// The target position and flee radius can be updated dynamically by modifying
/// the public [target] and [fleeRadius] fields.
/// {@endtemplate}
/// @seealso [Seek] for the opposite behavior (moving towards).
/// @seealso [Evade] for fleeing a moving target.
class Flee extends SteeringBehavior {
  /// The static world position ([Vector2]) that the agent should move away from.
  /// This can be updated at any time.
  Vector2 target;

  /// Optional: The radius around the **target** position. Fleeing only occurs
  /// if the agent is within this distance from the [target].
  /// If `null` (the default), the agent will always attempt to flee from the
  /// target, regardless of distance.
  /// If set, must be a positive value.
  double? fleeRadius;

  /// Creates a [Flee] behavior.
  ///
  /// {@macro flee}
  /// [target] The initial world position to flee from.
  /// [fleeRadius] Optional distance from the [target] within which fleeing
  ///   should activate. If null, fleeing is always active.
  Flee({required this.target, this.fleeRadius}) {
    assert(fleeRadius == null || fleeRadius! > 0, 'fleeRadius must be positive if set.');
  }


  @override
  Vector2 calculateSteering(Agent agent) {
    // Vector pointing from target towards the agent
    final offset = agent.position - target;
    final distanceSquared = offset.length2;

    // Check if target is outside the optional flee radius
    if (fleeRadius != null && distanceSquared > fleeRadius! * fleeRadius!) {
      // Agent is far enough away, no need to flee further.
      return Vector2.zero();
    }

    // Avoid division by zero or normalization issues if agent is exactly at the target
    if (distanceSquared < 0.0001) {
      // If exactly at the target, maybe flee in a default direction?
      // Or just return zero force. For now, return zero.
      // A small random push could also work.
      return Vector2.zero();
    }

    // Calculate desired velocity at maximum speed, pointing away from target.
    final desiredVelocity = offset.normalized() * agent.maxSpeed;

    // Calculate the steering force (Desired Velocity - Current Velocity).
    final steeringForce = desiredVelocity - agent.velocity;

    // The SteeringManager will truncate this force later if needed.
    return steeringForce;
  }
}
