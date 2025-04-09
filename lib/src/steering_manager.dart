import 'package:vector_math/vector_math_64.dart';

import 'agent.dart';
import 'steering_behavior.dart';
import 'utils/vector_utils.dart';

/// Manages a collection of [SteeringBehavior] instances for a single [Agent].
///
/// This class is central to applying steering behaviors. It holds a list of
/// active behaviors, calculates the steering force contribution from each one,
/// applies specified weights, sums the forces, and truncates the result to
/// respect the agent's `maxForce` limit.
///
/// Typically, you create one `SteeringManager` per agent that needs steering.
/// You then add desired behaviors (like [Seek], [AvoidObstacles], [Wander])
/// to the manager. In your game loop's update phase, you call the manager's
/// [update] method, which calculates the final steering force and calls the
/// agent's [Agent.applySteering] method to update its physics state.
///
/// ```dart
/// // In your Agent's initialization:
/// steeringManager = SteeringManager(this);
/// steeringManager.add(Seek(target: enemy.position));
/// steeringManager.add(Separation(neighbors: otherAgents), weight: 1.5); // Prioritize separation
///
/// // In your Agent's update loop:
/// void update(double dt) {
///   steeringManager.update(dt);
///   // ... other update logic
/// }
/// ```
///
/// @seealso [Agent], [SteeringBehavior]
class SteeringManager {
  /// The [Agent] instance that this manager controls.
  final Agent agent;

  /// Internal list storing active behaviors and their associated weights.
  final List<WeightedBehavior> _behaviors = [];

  /// Creates a `SteeringManager` associated with the specified [agent].
  ///
  /// [agent] The agent whose movement will be controlled by this manager.
  SteeringManager(this.agent);

  /// Adds a [SteeringBehavior] to the manager's active list.
  ///
  /// The behavior's calculated force will be included in the combined steering
  /// calculation during the [update] or [calculateSteering] call.
  ///
  /// [behavior] The steering behavior instance to add.
  /// [weight] An optional weighting factor for this behavior's contribution.
  ///   Defaults to `1.0`. A higher weight gives the behavior more influence
  ///   relative to other behaviors when their forces are combined. A weight
  ///   of `0.0` effectively disables the behavior without removing it.
  ///   Negative weights are generally not recommended unless specific effects
  ///   are intended.
  void add(SteeringBehavior behavior, {double weight = 1.0}) {
    // Consider checking if the same behavior instance is already added?
    // For now, allows duplicates which might be intended in some cases.
    _behaviors.add(WeightedBehavior(behavior, weight));
  }

  /// Removes a specific [SteeringBehavior] instance from the manager.
  ///
  /// If the behavior was added multiple times (which is possible but perhaps
  /// unusual), this removes the first occurrence found.
  ///
  /// [behavior] The exact behavior instance to remove.
  void remove(SteeringBehavior behavior) {
    _behaviors.removeWhere((wb) => wb.behavior == behavior);
  }

  /// Removes all steering behaviors currently managed.
  void clear() {
    _behaviors.clear();
  }

  /// Calculates the combined steering force from all active behaviors.
  ///
  /// This method performs the core logic of the manager:
  /// 1. Iterates through all added [WeightedBehavior]s.
  /// 2. Calls `calculateSteering` on each behavior to get its force contribution.
  /// 3. Multiplies the behavior's force by its assigned weight.
  /// 4. Sums all weighted forces into a single `totalForce` vector.
  /// 5. Truncates the `totalForce` magnitude to the [agent]'s `maxForce`.
  ///
  /// This method only calculates the force; it does **not** apply it to the
  /// agent. Use the [update] method for calculation and application in one step.
  ///
  /// Returns the final calculated and truncated steering [Vector2]. Returns
  /// `Vector2.zero()` if no behaviors are active.
  Vector2 calculateSteering() {
    final totalForce = Vector2.zero();

    if (_behaviors.isEmpty) {
      return totalForce;
    }

    // Accumulate forces from all behaviors
    for (final weightedBehavior in _behaviors) {
      // Skip behaviors with zero weight
      if (weightedBehavior.weight == 0.0) continue;

      final behaviorForce = weightedBehavior.behavior.calculateSteering(agent);

      // Apply weight if it's not 1.0
      if (weightedBehavior.weight != 1.0) {
        // Avoid modifying the original vector if behavior is reused elsewhere
        totalForce.addScaled(behaviorForce, weightedBehavior.weight);
      } else {
        totalForce.add(behaviorForce);
      }
    }

    // Truncate the combined force to the agent's maximum capability.
    // Ensure VectorUtils.truncate handles zero vectors correctly if needed.
    VectorUtils.truncate(totalForce, agent.maxForce);

    return totalForce;
  }

  /// Calculates the combined steering force and applies it to the agent.
  ///
  /// This is the primary method to call in your game loop's update phase.
  /// It acts as a convenience method that first calls [calculateSteering]
  /// to get the final steering force, and then calls the associated
  /// [agent]'s [Agent.applySteering] method, passing the calculated force
  /// and the provided [deltaTime].
  ///
  /// [deltaTime] The time elapsed since the last update frame, typically in
  ///   seconds. This is passed directly to the [Agent.applySteering] method
  ///   for physics integration.
  void update(double deltaTime) {
    final steeringForce = calculateSteering();
    agent.applySteering(steeringForce, deltaTime);
  }
}

/// Internal helper class to associate a [SteeringBehavior] with a weight.
class WeightedBehavior {
  /// The steering behavior instance.
  final SteeringBehavior behavior;
  /// The weighting factor applied to this behavior's force contribution.
  final double weight;

  /// Creates a weighted behavior pair.
  WeightedBehavior(this.behavior, this.weight);
}
