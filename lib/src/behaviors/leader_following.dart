import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';
import '../steering_behavior.dart';
import '../utils/spatial_hash_grid.dart'; // Requires SpatialHashGrid if separation is used
import 'arrival.dart';
import 'evade.dart';
import 'separation.dart';

/// {@template leader_following}
/// **Leader Following** steering behavior: makes an agent follow a designated leader.
///
/// This behavior enables an agent (the follower) to follow a specific [leader]
/// agent, maintaining a position slightly behind the leader. It intelligently
/// combines several underlying steering behaviors to achieve this:
///
/// - **Arrival:** The primary component steers the follower towards a dynamically
///   calculated point located [leaderBehindDistance] behind the leader's current
///   position (based on the leader's heading). It uses [Arrival] logic to slow
///   down smoothly as it approaches this following point.
/// - **Evade:** If the follower gets too close and *in front* of the leader
///   (within the leader's "sight" defined by [leaderSightDistance] and
///   [leaderSightRadius]), this component activates to steer the follower quickly
///   out of the leader's path, preventing collisions and maintaining formation.
/// - **Separation (Optional):** If a [spatialGrid] and `followerSeparation`
///   distance are provided, this component activates to steer the follower away
///   from *other nearby followers* (not the leader), preventing followers from
///   clumping together.
///
/// The behavior prioritizes evasion if the follower is in the leader's way;
/// otherwise, it focuses on arriving at the follow point, potentially modified
/// by separation forces.
/// {@endtemplate}
/// @seealso [Arrival], [Evade], [Separation]
class LeaderFollowing extends SteeringBehavior {
  /// The [Agent] instance designated as the leader to be followed.
  final Agent leader;

  /// The [SpatialHashGrid] used for the optional [Separation] behavior among
  /// followers. If `followerSeparation` is specified in the constructor, this
  /// grid must be provided and should contain all follower agents. If `null`,
  /// separation between followers is disabled.
  final SpatialHashGrid? spatialGrid;

  /// The desired distance the follower should maintain *behind* the [leader].
  /// This distance is measured along the leader's backward heading vector.
  /// Must be non-negative.
  final double leaderBehindDistance;

  /// The distance ahead of the [leader] used to define the leader's "line of sight".
  /// If the follower enters this zone ahead of the leader, the [Evade] behavior
  /// might be triggered. Must be non-negative. Defaults to `30.0`.
  final double leaderSightDistance;

  /// The radius or width of the leader's "line of sight". If the follower is
  /// ahead of the leader (within [leaderSightDistance]) and also within this
  /// lateral distance from the leader's heading vector, evasion is triggered.
  /// Must be non-negative. Defaults to `10.0`.
  final double leaderSightRadius;

  // --- Internal Component Behaviors ---
  /// Internal [Arrival] behavior used to steer towards the follow point behind the leader.
  late final Arrival _arrival;
  /// Optional internal [Separation] behavior used to keep followers apart.
  late final Separation? _separation;
  /// Internal [Evade] behavior used to get out of the leader's way.
  late final Evade _evade;
  // --- End Internal Behaviors ---

  /// Creates a [LeaderFollowing] behavior.
  ///
  /// {@macro leader_following}
  /// [leader] The agent to follow.
  /// [leaderBehindDistance] Target distance to maintain behind the leader (>= 0).
  /// [leaderSightDistance] How far ahead the leader "looks" for followers in
  ///   the way (default: `30.0`, >= 0).
  /// [leaderSightRadius] Width of the leader's sight line for evasion
  ///   (default: `10.0`, >= 0).
  /// [spatialGrid] Optional spatial grid for separation among followers. Required
  ///   if `followerSeparation` is set.
  /// [followerSeparation] Optional desired separation distance between followers.
  ///   If set (> 0), requires [spatialGrid] to be provided. Enables the internal
  ///   [Separation] behavior.
  LeaderFollowing({
    required this.leader,
    required this.leaderBehindDistance,
    this.leaderSightDistance = 30.0,
    this.leaderSightRadius = 10.0,
    this.spatialGrid,
    double? followerSeparation,
  }) : assert(leaderBehindDistance >= 0, 'leaderBehindDistance cannot be negative.'),
       assert(leaderSightDistance >= 0, 'leaderSightDistance cannot be negative.'),
       assert(leaderSightRadius >= 0, 'leaderSightRadius cannot be negative.'),
       assert(followerSeparation == null || followerSeparation > 0,
              'followerSeparation must be positive if set.'),
       assert(followerSeparation == null || spatialGrid != null,
              'spatialGrid must be provided if followerSeparation is set.')
  {
    // Initialize internal Arrival behavior. Target is updated dynamically.
    // Use half the behind distance as the slowing radius for Arrival.
    _arrival = Arrival(
        target: Vector2.zero(),
        slowingRadius: leaderBehindDistance * 0.5,
        // Use a small tolerance for arrival at the follow point
        arrivalTolerance: 0.5
    );

    // Initialize optional Separation behavior.
    if (spatialGrid != null && followerSeparation != null) {
      // We've asserted spatialGrid is not null and followerSeparation > 0 here.
      _separation = Separation(
          spatialGrid: spatialGrid!,
          desiredSeparation: followerSeparation
          // Note: viewAngle for separation could be added as another parameter if needed.
      );
    } else {
      _separation = null;
    }

    // Initialize Evade behavior - target is always the leader.
    // Use default Evade parameters (no max prediction time or evade radius).
    _evade = Evade(targetAgent: leader);
  }

  /// Calculates the leader following steering force.
  ///
  /// 1. Determines the leader's heading.
  /// 2. Calculates the target follow point behind the leader.
  /// 3. Calculates a point ahead of the leader for the evasion check.
  /// 4. Checks if the current agent (follower) is within the leader's "sight cone".
  /// 5. If in the way, calculates and prioritizes the [Evade] force.
  /// 6. If not in the way, calculates the [Arrival] force towards the follow point.
  /// 7. If separation is enabled, calculates and adds the [Separation] force.
  /// 8. Returns the combined steering force.
  @override
  Vector2 calculateSteering(Agent agent) {
    final leaderVelocity = leader.velocity;
    final leaderHeading = (leaderVelocity.length2 > 1e-6) ? leaderVelocity.normalized() : null;

    // --- Calculate Target Points ---
    Vector2 targetBehind; // The point the follower should arrive at
    if (leaderHeading != null) {
      // Calculate point behind leader based on heading
      final behindOffset = -leaderHeading * leaderBehindDistance;
      targetBehind = leader.position + behindOffset;
    } else {
      // Leader is stationary, just target slightly behind current position
      // (using a default backward direction, e.g., negative X)
      targetBehind = leader.position - Vector2(leaderBehindDistance, 0);
    }

    // --- Evasion Check ---
    Vector2 steeringForce = Vector2.zero(); // Initialize total force
    // bool isEvading = false; // Flag not needed if we return directly
    if (leaderHeading != null) {
      // Vector from leader to the follower agent
      final toAgent = agent.position - leader.position;
      // Project this vector onto the leader's heading
      final projectionOntoHeading = toAgent.dot(leaderHeading);
      // Calculate squared lateral distance from leader's path
      final lateralDistanceSq = (toAgent - (leaderHeading * projectionOntoHeading)).length2;

      // Check if follower is ahead of leader, within sight distance, and within sight radius
      if (projectionOntoHeading > 0 && // Ahead of leader
          projectionOntoHeading < leaderSightDistance && // Within sight distance
          lateralDistanceSq < leaderSightRadius * leaderSightRadius) // Within sight radius
      {
        // Follower is in the leader's way - prioritize evasion!
        print("LeaderFollowing: EVADING!"); // Debug print
        return _evade.calculateSteering(agent);
        // isEvading = true; // Flag not needed if we return here.
      }
    }

    // --- Arrival Calculation (if not evading) ---
    // If we reach here, the agent is not in the leader's sight cone.
    // if (!isEvading) { // Condition not needed as we return early if evading
      // Update the target for the internal Arrival behavior
      _arrival.target = targetBehind;
      // Calculate arrival force towards the point behind the leader
      steeringForce = _arrival.calculateSteering(agent);
    // }

    // --- Separation Calculation (Optional) ---
    if (_separation != null) {
      // Calculate separation force from other followers
      final separationForce = _separation!.calculateSteering(agent);
      // Add separation force to the total (SteeringManager handles weighting later if needed)
      // Note: If using SteeringManager weights, Flocking might be a better model.
      // Here, we simply add the forces before returning.
      steeringForce.add(separationForce);
    }

    // The SteeringManager will truncate the final combined force.
    return steeringForce;
  }
}
