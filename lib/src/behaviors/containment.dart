import 'dart:math';
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../obstacle.dart'; // Requires RectangleBoundary to be defined here or imported
import '../steering_behavior.dart';

/// {@template containment}
/// **Containment** steering behavior: keeps an agent within a boundary.
///
/// This behavior prevents an agent from moving outside a specified area,
/// typically defined by a [RectangleBoundary]. It works by predicting the
/// agent's future position based on its current velocity and a given
/// [predictionDistance].
///
/// If the predicted future position lies outside the [boundary], the behavior
/// calculates a steering force to push the agent back towards the inside.
/// The force direction is generally perpendicular to the boundary edge that
/// the agent is predicted to cross. The magnitude of the force is scaled by
/// the [forceMultiplier] and can also be influenced by how far outside the
/// boundary the predicted position is (stronger force for deeper predicted penetrations).
///
/// If the predicted position is inside the boundary, this behavior produces no
/// steering force.
///
/// **Note:** This implementation assumes a [RectangleBoundary] obstacle type is
/// defined in `obstacle.dart` (or imported) and provides `minCorner`, `maxCorner`,
/// `position` (center), and `containsPoint` methods/properties.
/// {@endtemplate}
class Containment extends SteeringBehavior {
  /// The [RectangleBoundary] defining the area within which the agent should remain.
  final RectangleBoundary boundary;

  /// How far ahead (in world units) along the agent's current velocity vector
  /// to predict its future position for boundary checking. Defaults to `10.0`.
  /// Must be non-negative.
  final double predictionDistance;

  /// A multiplier scaling the strength of the corrective steering force applied
  /// when the agent is predicted to leave the boundary. Higher values result
  /// in stronger "push back". Defaults to `100.0`.
  final double forceMultiplier;

  /// Creates a [Containment] behavior.
  ///
  /// {@macro containment}
  /// [boundary] The [RectangleBoundary] defining the allowed area.
  /// [predictionDistance] How far ahead to predict the agent's position
  ///   (default: `10.0`, must be >= 0).
  /// [forceMultiplier] Strength multiplier for the corrective steering force
  ///   (default: `100.0`).
  Containment({
    required this.boundary,
    this.predictionDistance = 10.0,
    this.forceMultiplier = 100.0,
  }) : assert(predictionDistance >= 0, 'predictionDistance cannot be negative.');
       // forceMultiplier can reasonably be zero or negative if desired.


  /// Calculates the containment steering force.
  ///
  /// 1. Predicts the agent's future position based on velocity and [predictionDistance].
  /// 2. Checks if the future position is inside the [boundary] using `boundary.containsPoint`.
  /// 3. If inside, returns zero force.
  /// 4. If outside, determines which boundary edge(s) are crossed.
  /// 5. Calculates a corrective force vector pointing back inside (generally
  ///    perpendicular to the crossed edge).
  /// 6. Scales the force based on [forceMultiplier] and how far the prediction
  ///    is outside the boundary.
  /// 7. Calculates a desired velocity based on the corrective force direction.
  /// 8. Returns the final steering force (desired velocity - current velocity).
  @override
  Vector2 calculateSteering(Agent agent) {
    // Removed early return for zero velocity. Prediction logic handles it.

    // 1. Predict future position
    // Using a temporary vector for calculation if needed, or direct calculation.
    final futurePosition = agent.position + (agent.velocity.normalized() * predictionDistance);

    // 2. Check if prediction is inside the boundary
    if (boundary.containsPoint(futurePosition)) {
      // Prediction is safely inside, no corrective force needed from this behavior.
      return Vector2.zero();
    }

    // 3. Prediction is outside - calculate corrective force
    final correctiveForce = Vector2.zero(); // Initialize force vector
    double maxPenetrationFactor = 0.0; // Track how far out the prediction is (0 to 1+)

    // Check penetration on each axis
    if (futurePosition.x < boundary.minCorner.x) {
      correctiveForce.x = 1.0; // Force points right
      maxPenetrationFactor = max(maxPenetrationFactor,
          (boundary.minCorner.x - futurePosition.x) / predictionDistance);
    } else if (futurePosition.x > boundary.maxCorner.x) {
      correctiveForce.x = -1.0; // Force points left
      maxPenetrationFactor = max(maxPenetrationFactor,
          (futurePosition.x - boundary.maxCorner.x) / predictionDistance);
    }

    if (futurePosition.y < boundary.minCorner.y) {
      correctiveForce.y = 1.0; // Force points up (assuming Y increases upwards)
      maxPenetrationFactor = max(maxPenetrationFactor,
          (boundary.minCorner.y - futurePosition.y) / predictionDistance);
    } else if (futurePosition.y > boundary.maxCorner.y) {
      correctiveForce.y = -1.0; // Force points down
      maxPenetrationFactor = max(maxPenetrationFactor,
          (futurePosition.y - boundary.maxCorner.y) / predictionDistance);
    }

    // 4. Normalize and scale the corrective force
    if (correctiveForce.length2 > 1e-6) {
      correctiveForce.normalize();
      // Scale force: make it stronger the further the prediction is outside.
      // Clamp factor to avoid excessively small/large forces near boundary.
      correctiveForce.scale(forceMultiplier * maxPenetrationFactor.clamp(0.1, 1.5)); // Allow slightly > 1 factor
    } else {
      // This case should ideally not happen if boundary.containsPoint was false,
      // but as a fallback, apply a gentle push towards the boundary center.
      correctiveForce.setFrom(boundary.position - agent.position);
      if (correctiveForce.length2 > 1e-6) {
         correctiveForce.normalize();
         correctiveForce.scale(forceMultiplier * 0.1); // Small force towards center
      } else {
         return Vector2.zero(); // Already at center or very close
       }
     }

     // 5. Return the calculated corrective force directly.
     // The SteeringManager will handle converting this force into a velocity
     // change and applying truncation based on agent.maxForce.
     return correctiveForce;
  }
}
