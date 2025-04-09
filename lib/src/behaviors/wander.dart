import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/vector_utils.dart'; // Although not directly used, good practice

/// {@template wander}
/// **Wander** steering behavior: produces seemingly random, natural-looking movement.
///
/// This behavior simulates exploration or idling by projecting a virtual circle
/// ahead of the agent and steering towards a target point that randomly moves
/// along the circumference of this circle.
///
/// Key parameters control the wander effect:
/// - [circleDistance]: How far ahead the center of the virtual wander circle is placed.
/// - [circleRadius]: The radius of the wander circle, determining the maximum
///   lateral displacement the wander target can have.
/// - [angleChangePerSecond]: The maximum amount (in radians) the target angle
///   on the circle can change per second. This controls how quickly the wander
///   direction shifts.
///
/// The behavior maintains an internal `_wanderAngle`. In each calculation step:
/// 1. A small random displacement is added to `_wanderAngle` (scaled by
///    [angleChangePerSecond] and a small random value between -0.5 and 0.5).
/// 2. The wander circle's center is calculated based on the agent's current
///    heading (or a default heading if stationary) and [circleDistance].
/// 3. The target point on the circle's circumference is calculated using the
///    updated `_wanderAngle` and [circleRadius].
/// 4. A steering force is calculated to direct the agent towards this wander target,
///    typically aiming for [Agent.maxSpeed].
///
/// An optional [seed] can be provided to the constructor for deterministic random
/// angle changes, useful for testing or reproducible scenarios.
/// {@endtemplate}
class Wander extends SteeringBehavior {
  /// Distance ahead of the agent to project the center of the wander circle.
  /// Must be non-negative.
  final double circleDistance;

  /// Radius of the wander circle. Determines the magnitude of the random displacement.
  /// Must be non-negative.
  final double circleRadius;

  /// Maximum change in the wander angle (in radians) per second. Controls the
  /// "jitter" or rate of direction change. Must be non-negative.
  final double angleChangePerSecond;

  /// Internal random number generator. Seeded if a seed is provided.
  final Random _random;

  /// Current angle on the wander circle (in radians).
  double _wanderAngle = 0.0;

  /// Creates a [Wander] behavior.
  ///
  /// {@macro wander}
  /// [circleDistance] Distance to the wander circle's center (>= 0).
  /// [circleRadius] Radius of the wander circle (>= 0).
  /// [angleChangePerSecond] Max angle change per second (radians, >= 0).
  /// [seed] Optional seed for the internal random number generator for
  ///   deterministic behavior.
  Wander({
    required this.circleDistance,
    required this.circleRadius,
    required this.angleChangePerSecond,
    int? seed,
  }) : assert(circleDistance >= 0, 'circleDistance cannot be negative.'),
       assert(circleRadius >= 0, 'circleRadius cannot be negative.'),
       assert(angleChangePerSecond >= 0, 'angleChangePerSecond cannot be negative.'),
       _random = Random(seed) {
         // Initialize angle randomly if not seeded, or deterministically if seeded.
         _wanderAngle = _random.nextDouble() * 2 * pi;
       }

  // --- Optimization: Pre-allocated vectors ---
  final Vector2 _circleCenter = Vector2.zero();
  final Vector2 _displacement = Vector2.zero();
  final Vector2 _wanderTarget = Vector2.zero();
  final Vector2 _desiredVelocity = Vector2.zero();
  final Vector2 _steeringForce = Vector2.zero();
  // --- End Optimization ---

  /// Calculates the wander steering force.
  @override
  Vector2 calculateSteering(Agent agent) {
    // 1. Calculate random angle change for this step.
    // Assuming calculateSteering is called roughly based on frame time,
    // but we don't have deltaTime here. Use a fixed small random change per call.
    // A better approach might involve passing deltaTime or using a fixed update rate.
    // For now, use angleChangePerSecond directly, scaled by a small random factor.
    final double angleChange = angleChangePerSecond * (_random.nextDouble() - 0.5); // Random change between +/- angleChange/2
    _wanderAngle += angleChange;

    // 2. Calculate the center of the wander circle ahead of the agent.
    // Use current velocity direction or a default if stationary.
    _circleCenter.setFrom(agent.velocity);
    if (_circleCenter.length2 < 1e-6) {
      // Agent is stationary, use a default heading (e.g., positive X)
      _circleCenter.setValues(1.0, 0.0);
    }
    _circleCenter.normalize();
    _circleCenter.scale(circleDistance);
    _circleCenter.add(agent.position); // World position of circle center

    // 3. Calculate the target point on the circle's circumference.
    // Use the agent's local coordinate system temporarily for displacement.
    // Displacement on circle relative to circle center.
    _displacement.setValues(cos(_wanderAngle), sin(_wanderAngle));
    _displacement.scale(circleRadius);

    // Convert displacement to world space? No, target is world space.
    // Target = CircleCenter + Displacement (already world space relative to agent heading)
    // We need to transform the displacement based on agent heading.
    // Let H = heading, S = side vector
    // Target = CircleCenter + Displacement.x * H + Displacement.y * S
    final agentHeading = agent.velocity.normalized(); // Recalculate or use from above
    final agentSide = Vector2(-agentHeading.y, agentHeading.x);

    _wanderTarget
      ..setFrom(agentHeading)..scale(_displacement.x) // Displacement along heading
      ..add(agentSide..scale(_displacement.y)) // Displacement along side
      ..add(_circleCenter); // Add circle center offset

    // 4. Calculate steering force towards the wander target.
    _desiredVelocity.setFrom(_wanderTarget);
    _desiredVelocity.sub(agent.position); // Vector from agent to target
    _desiredVelocity.normalize();
    _desiredVelocity.scale(agent.maxSpeed);

    _steeringForce
      ..setFrom(_desiredVelocity)
      ..sub(agent.velocity);

    // SteeringManager will truncate
    return _steeringForce;
  }

  /// Gets the current internal wander angle. Useful for debugging/testing.
  double get debugWanderAngle => _wanderAngle;
}
