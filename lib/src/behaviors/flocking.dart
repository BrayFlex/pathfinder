import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid for neighbor queries
import 'alignment.dart';
import 'cohesion.dart';
import 'separation.dart';

/// {@template flocking}
/// **Flocking** steering behavior: simulates group movement like birds or fish.
///
/// This behavior combines three fundamental steering behaviors:
/// - [Separation]: Steers to avoid crowding local neighbors.
/// - [Cohesion]: Steers towards the average position of local neighbors.
/// - [Alignment]: Steers towards the average heading of local neighbors.
///
/// By calculating the steering forces from these three components and combining
/// them using specified weights ([separationWeight], [cohesionWeight],
/// [alignmentWeight]), this behavior produces emergent flocking, schooling, or
/// herding effects within a group of agents.
///
/// It requires a [SpatialHashGrid] to efficiently query for neighbors needed by
/// the component behaviors. Parameters like neighborhood radii and view angles
/// for the component behaviors are configured during the [Flocking] behavior's
/// creation.
///
/// The relative weights of the three components significantly influence the
/// overall flocking style:
/// - Higher `separationWeight` leads to looser flocks.
/// - Higher `cohesionWeight` leads to tighter, more clumped flocks.
/// - Higher `alignmentWeight` leads to more ordered and directionally consistent flocks.
/// {@endtemplate}
/// @seealso [Separation], [Cohesion], [Alignment]
/// @seealso [SpatialHashGrid]
class Flocking extends SteeringBehavior {
  /// The [SpatialHashGrid] passed to the underlying [Separation], [Cohesion],
  /// and [Alignment] behaviors for efficient neighbor lookups.
  final SpatialHashGrid spatialGrid;

  /// Internal instance of the [Separation] behavior.
  late final Separation _separation;
  /// Internal instance of the [Cohesion] behavior.
  late final Cohesion _cohesion;
  /// Internal instance of the [Alignment] behavior.
  late final Alignment _alignment;

  /// Weight multiplier applied to the force calculated by the [Separation] component.
  /// Controls the strength of the tendency to avoid crowding. Defaults to `1.5`.
  final double separationWeight;
  /// Weight multiplier applied to the force calculated by the [Cohesion] component.
  /// Controls the strength of the tendency to move towards the group center. Defaults to `1.0`.
  final double cohesionWeight;
  /// Weight multiplier applied to the force calculated by the [Alignment] component.
  /// Controls the strength of the tendency to align heading with neighbors. Defaults to `1.0`.
  final double alignmentWeight;

  /// Creates a [Flocking] behavior by initializing and configuring the underlying
  /// [Separation], [Cohesion], and [Alignment] behaviors.
  ///
  /// {@macro flocking}
  /// [spatialGrid] The spatial hash grid containing all agents participating in the flock.
  /// [separationDistance] The desired minimum distance for the [Separation] component.
  /// [cohesionRadius] The neighborhood radius used by the [Cohesion] component.
  /// [alignmentRadius] The neighborhood radius used by the [Alignment] component.
  /// [viewAngle] Optional field of view constraint (radians) applied uniformly to
  ///   all three component behaviors. If `null`, components consider neighbors in all directions.
  /// [separationWeight] Weight multiplier for the [Separation] force (default: `1.5`).
  /// [cohesionWeight] Weight multiplier for the [Cohesion] force (default: `1.0`).
  /// [alignmentWeight] Weight multiplier for the [Alignment] force (default: `1.0`).
  Flocking({
    required this.spatialGrid,
    required double separationDistance,
    required double cohesionRadius,
    required double alignmentRadius,
    double? viewAngle,
    this.separationWeight = 1.5,
    this.cohesionWeight = 1.0,
    this.alignmentWeight = 1.0,
  }) {
    // Initialize the component behaviors, passing the shared spatial grid and parameters.
    _separation = Separation(
      spatialGrid: spatialGrid,
      desiredSeparation: separationDistance,
      viewAngle: viewAngle,
    );
    _cohesion = Cohesion(
      spatialGrid: spatialGrid,
      neighborhoodRadius: cohesionRadius,
      viewAngle: viewAngle,
    );
    _alignment = Alignment(
      spatialGrid: spatialGrid,
      neighborhoodRadius: alignmentRadius,
      viewAngle: viewAngle,
    );
  }

  /// Calculates the combined flocking steering force.
  ///
  /// 1. Calls `calculateSteering` on the internal [Separation], [Cohesion],
  ///    and [Alignment] instances.
  /// 2. Scales the resulting forces by their respective weights
  ///    ([separationWeight], [cohesionWeight], [alignmentWeight]).
  /// 3. Sums the weighted forces.
  /// 4. Returns the total combined force. The [SteeringManager] will handle
  ///    truncating this force to the agent's `maxForce`.
  @override
  Vector2 calculateSteering(Agent agent) {
    // Calculate forces from each component behavior.
    final separationForce = _separation.calculateSteering(agent);
    final cohesionForce = _cohesion.calculateSteering(agent);
    final alignmentForce = _alignment.calculateSteering(agent);

    // Apply weights - scale the forces directly if weights are not 1.0
    // Avoid unnecessary scaling if weight is 1.0
    if (separationWeight != 1.0) separationForce.scale(separationWeight);
    if (cohesionWeight != 1.0) cohesionForce.scale(cohesionWeight);
    if (alignmentWeight != 1.0) alignmentForce.scale(alignmentWeight);

    // Combine the weighted forces.
    // Avoid creating a new vector if possible, reuse one of the force vectors.
    final totalForce = separationForce; // Start with separation
    totalForce.add(cohesionForce);
    totalForce.add(alignmentForce);

    // The SteeringManager is responsible for truncating the final combined force
    // based on the agent's maxForce.
    return totalForce;
  }

  // Note: Updating parameters (like separationDistance, weights, etc.) after
  // creation currently requires creating a new Flocking instance.
  // If dynamic updates are needed, the component behaviors (_separation, etc.)
  // would need public setters for their parameters, and this class could
  // provide methods to delegate those updates.
}
