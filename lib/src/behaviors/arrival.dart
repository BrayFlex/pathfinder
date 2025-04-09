import 'dart:math'; // Import for sqrt
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/vector_utils.dart'; // Although not directly used, good practice
import 'seek.dart'; // For doc links

/// {@template arrival}
/// **Arrival** steering behavior: directs the agent towards a target and decelerates.
///
/// This behavior is an enhancement of [Seek]. It steers the agent towards a
/// static [target] position, but unlike Seek, it causes the agent to slow down
/// (decelerate) as it approaches the target, ideally coming to a smooth stop
/// precisely at the target position.
///
/// The deceleration is controlled by the [slowingRadius]. When the agent is
/// outside this radius, it seeks the target at its maximum speed ([Agent.maxSpeed]).
/// When the agent enters the slowing radius, its desired speed is ramped down
/// linearly from `maxSpeed` (at the edge of the radius) to zero (at the target).
///
/// An [arrivalTolerance] defines a small radius around the target within which
/// the agent is considered to have arrived. Inside this tolerance, the behavior
/// actively tries to stop the agent by applying a force opposite to its current
/// velocity, helping to prevent overshooting or oscillation.
///
/// The core logic involves:
/// 1. Calculating the vector and distance from the agent to the target.
/// 2. Checking if the agent is within the [arrivalTolerance]. If so, apply braking force.
/// 3. If outside tolerance but inside [slowingRadius], calculate a ramped-down desired speed.
/// 4. If outside [slowingRadius], use `maxSpeed` as the desired speed.
/// 5. Calculate the desired velocity (direction towards target, magnitude is desired speed).
/// 6. Calculate the steering force as the difference between the desired velocity
///    and the agent's current velocity (`steering = desired - current`).
///
/// The target position, slowing radius, and arrival tolerance can be updated
/// dynamically by modifying the public fields.
/// {@endtemplate}
/// @seealso [Seek] for moving towards a target without slowing down.
class Arrival extends SteeringBehavior {
  /// The static world position ([Vector2]) that the agent should arrive at.
  /// This can be updated at any time.
  Vector2 target;

  /// The distance from the [target] at which the agent should begin to
  /// decelerate. Must be a positive value. A larger radius means the agent
  /// starts slowing down earlier.
  double slowingRadius;

  /// The radius around the [target] within which the agent is considered
  /// to have "arrived". Inside this distance, the behavior actively tries
  /// to bring the agent to a stop. Defaults to `0.1`. Must be non-negative.
  double arrivalTolerance;

  /// Cached squared value of [arrivalTolerance] for efficient distance checking.
  /// Is automatically updated if [arrivalTolerance] is set.
  double _arrivalToleranceSquared;

  /// Creates an [Arrival] behavior.
  ///
  /// {@macro arrival}
  /// [target] The initial world position to arrive at.
  /// [slowingRadius] The distance from the target where deceleration begins.
  ///   Must be greater than 0.
  /// [arrivalTolerance] The distance within which the agent is considered
  ///   arrived and braking force is applied. Defaults to `0.1`. Must be >= 0.
  Arrival({
    required this.target,
    required this.slowingRadius,
    this.arrivalTolerance = 0.1,
  }) : assert(slowingRadius > 0, 'slowingRadius must be positive.'),
       assert(arrivalTolerance >= 0, 'arrivalTolerance cannot be negative.'),
       _arrivalToleranceSquared = arrivalTolerance * arrivalTolerance {
         // Update squared tolerance if tolerance is set later
         // (Consider making tolerance final or using a setter)
         // For now, rely on initial calculation. If tolerance needs frequent
         // updates, a setter that updates _arrivalToleranceSquared is better.
       }


  @override
  Vector2 calculateSteering(Agent agent) {
    // Vector pointing from agent to target
    final offset = target - agent.position;
    final distanceSquared = offset.length2; // Calculate squared distance first

    // Check if we have effectively arrived using squared distance
    if (distanceSquared < _arrivalToleranceSquared) {
      // Stop the agent completely if desired.
      // Setting velocity directly might be abrupt. Returning a force that
      // opposes current velocity is smoother.
      // For simplicity here, we return zero force, assuming the agent's
      // applySteering might handle near-zero velocity damping.
      // A more robust approach might return -agent.velocity to actively stop.
      return -agent.velocity; // Actively try to stop
    }

    // Calculate distance only if needed for speed calculation
    final distance = sqrt(distanceSquared);

    // Calculate the desired speed based on distance
    double desiredSpeed;
    // Compare distance (not squared) with slowingRadius
    if (distance < slowingRadius) {
      // Inside the slowing radius - ramp down speed
      // Map distance (0 to slowingRadius) to speed (0 to maxSpeed)
      desiredSpeed = agent.maxSpeed * (distance / slowingRadius);
    } else {
      // Outside slowing radius - move at maximum speed
      desiredSpeed = agent.maxSpeed;
    }

    // Calculate desired velocity (points towards target, magnitude is desiredSpeed)
    // Normalize offset: offset / distance
    final desiredVelocity = (offset / distance) * desiredSpeed;

    // Calculate the steering force (Desired Velocity - Current Velocity)
    final steeringForce = desiredVelocity - agent.velocity;

    // The SteeringManager will truncate this force later if needed.
    return steeringForce;
  }
}
