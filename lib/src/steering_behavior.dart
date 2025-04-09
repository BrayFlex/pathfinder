import 'package:vector_math/vector_math_64.dart';

import 'agent.dart';
import 'steering_manager.dart'; // For doc links

/// Abstract base class for all steering behaviors.
///
/// Steering behaviors encapsulate specific movement logic, such as seeking a
/// target, fleeing from a point, avoiding obstacles, or following a path.
/// Each concrete behavior (e.g., [Seek], [Flee], [Wander]) extends this class
/// and implements the [calculateSteering] method.
///
/// Instances of `SteeringBehavior` are added to an agent's [SteeringManager],
/// which combines the forces from multiple active behaviors (using weighting)
/// to produce a final steering force applied to the [Agent].
///
/// @seealso [SteeringManager], [Agent]
abstract class SteeringBehavior {
  /// Calculates the steering force vector for this specific behavior.
  ///
  /// This method contains the core logic for the behavior. It takes the
  /// current state of the [agent] (position, velocity, etc.) and calculates
  /// a steering force vector aimed at achieving the behavior's goal (e.g.,
  /// moving towards a target for [Seek], moving away for [Flee]).
  ///
  /// The returned vector represents the *desired change* in velocity. It is
  /// typically **not** clamped by the agent's `maxForce` within this method;
  /// the [SteeringManager] handles the final force truncation after combining
  /// forces from all active behaviors.
  ///
  /// If the behavior determines that no steering adjustment is needed in the
  /// current situation (e.g., an [Arrival] behavior when the agent is already
  /// at the target), it should return `Vector2.zero()`.
  ///
  /// [agent] The agent for which to calculate the steering force. The behavior
  ///   uses the agent's properties (position, velocity, maxSpeed, etc.) to
  ///   compute the appropriate force.
  ///
  /// Returns a [Vector2] representing the calculated steering force for this
  ///   behavior.
  Vector2 calculateSteering(Agent agent);
}
