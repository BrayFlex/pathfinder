import 'package:vector_math/vector_math_64.dart';

import 'steering_manager.dart'; // For doc links

/// Represents an autonomous agent in the simulation that can be steered.
///
/// This interface defines the contract for any entity (like a character,
/// vehicle, or boid) that needs to be controlled by the steering behaviors
/// provided in this library. By implementing this interface on your own
/// game objects, you allow the [SteeringManager] to calculate and apply
/// steering forces to them.
///
/// Implementors must provide getters for physical properties like position,
/// velocity, maximum speed, maximum force, and mass. They must also implement
/// the [applySteering] method, which defines how the calculated steering force
/// affects the agent's movement within the specific game or simulation loop.
///
/// ```dart
/// class MyGameObject extends GameEntity implements Agent {
///   @override
///   Vector2 position = Vector2.zero();
///   @override
///   Vector2 velocity = Vector2.zero();
///   @override
///   double maxSpeed = 100.0;
///   @override
///   double maxForce = 10.0;
///   @override
///   double mass = 1.0;
///   @override
///   double radius = 10.0; // Optional, but useful for some behaviors
///
///   late final SteeringManager steering;
///
///   MyGameObject() {
///     steering = SteeringManager(this);
///     // Add behaviors...
///     steering.add(Seek(target: Vector2(100, 100)));
///   }
///
///   @override
///   void applySteering(Vector2 steeringForce, double dt) {
///     // Apply physics based on the game engine or simulation needs
///     Vector2 acceleration = steeringForce / mass;
///     velocity = (velocity + acceleration * dt).clampMagnitude(maxSpeed);
///     position += velocity * dt;
///     // Update sprite rotation, etc.
///   }
///
///   void update(double dt) {
///     steering.update(dt); // Calculates and applies steering
///     // Other game logic...
///   }
/// }
/// ```
///
/// @seealso [SteeringManager], [SteeringBehavior]
abstract interface class Agent {
  /// The current position of the agent in 2D world space.
  ///
  /// This is the primary location identifier used by steering behaviors.
  Vector2 get position;

  /// The current velocity vector of the agent.
  ///
  /// Represents the direction and magnitude (speed) of the agent's current
  /// movement. Used by behaviors to predict future positions or calculate
  /// necessary changes in direction.
  Vector2 get velocity;

  /// The maximum speed the agent is allowed to travel at.
  ///
  /// This value is used by the agent's [applySteering] implementation to
  /// clamp the magnitude of the [velocity] vector after applying acceleration.
  /// Units should be consistent (e.g., pixels per second).
  double get maxSpeed;

  /// The maximum magnitude of the steering force that can be applied to the
  /// agent in a single simulation step.
  ///
  /// This value is used by the [SteeringManager] to truncate the combined
  /// steering force calculated from all active behaviors. It limits how
  /// sharply an agent can turn or change speed.
  double get maxForce;

  /// The mass of the agent.
  ///
  /// Used in the calculation of acceleration from force (`acceleration = force / mass`).
  /// A higher mass results in slower acceleration for the same applied force,
  /// simulating inertia. Must be greater than zero.
  double get mass;

  /// The approximate radius of the agent, used for spatial calculations.
  ///
  /// This is primarily used by group behaviors like [Separation] or avoidance
  /// behaviors to determine proximity to other agents or obstacles.
  /// If not relevant for the specific behaviors used, it can default to 0.0.
  /// Units should be consistent with world space units.
  double get radius => 0.0;

  /// Updates the agent's state (velocity and position) based on the
  /// calculated steering force.
  ///
  /// This method is called by the [SteeringManager.update] method after the
  /// combined steering force for the current step has been calculated.
  /// The implementation should apply physics rules appropriate for the game
  /// or simulation.
  ///
  /// A typical implementation involves:
  /// 1. Calculating acceleration: `acceleration = steeringForce / mass`.
  /// 2. Updating velocity: `newVelocity = velocity + acceleration * deltaTime`.
  /// 3. Clamping velocity: `velocity = newVelocity.clampMagnitude(maxSpeed)`.
  /// 4. Updating position: `position = position + velocity * deltaTime`.
  ///
  /// [steeringForce] The combined steering force calculated by the
  ///   [SteeringManager] for this update step. This force has already been
  ///   truncated by the agent's [maxForce].
  /// [deltaTime] The time elapsed since the last update, typically in seconds.
  ///   Used for time-based physics integration.
  void applySteering(Vector2 steeringForce, double deltaTime);
}
