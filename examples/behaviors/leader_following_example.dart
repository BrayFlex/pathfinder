import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart'; // Needed if using separation
import 'package:vector_math/vector_math_64.dart';

// --- LeaderFollowing Steering Behavior ---
// Explanation:
// The Leader Following behavior enables an agent (follower) to follow a designated
// leader agent, maintaining a position slightly behind the leader. It combines
// Arrival (to smoothly reach the follow point), Evade (to avoid collision if the
// follower gets in front), and optionally Separation (to keep distance from other followers).
//
// 1. Setup: We create a 'leader' agent with a constant velocity and a 'follower'
//    agent starting nearby. (Optional: A SpatialHashGrid and more followers could
//    be added if testing the Separation component).
//
// 2. Behavior Creation: We instantiate the LeaderFollowing behavior for the 'follower',
//    passing the 'leader' agent and key parameters:
//    - leaderBehindDistance: The target distance behind the leader.
//    - leaderSightDistance/Radius: Defines a zone in front of the leader; if the
//      follower enters this zone, Evade takes priority.
//    - (Optional) spatialGrid/followerSeparation: Enables Separation among followers.
//
// 3. Simulation: In a loop, we:
//    - Update the leader's position.
//    - (Optional) Update the spatial grid if using Separation.
//    - Calculate the steering force for the 'follower' using followBehavior.calculateSteering().
//      The behavior calculates the target point behind the leader, checks if evasion
//      is needed, calculates Arrival/Evade forces, and adds Separation force if enabled.
//    - Apply the steering force to the 'follower'.
//    - Print the states.
//
// 4. Result: The simulation output shows the 'follower' accelerating towards the
//    moving point behind the 'leader'. It should settle at roughly the specified
//    'leaderBehindDistance'. If the follower were to somehow get in front and within
//    the leader's sight cone, the steering force would reflect the Evade behavior
//    pushing it out of the way.

/// Minimal Agent class implementation for demonstration purposes.
/// (Same as in previous examples)
class SimpleAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce;
  @override
  double radius;
  @override
  double mass;

  SimpleAgent({
    required this.position,
    required this.velocity,
    this.maxSpeed = 100.0,
    this.maxForce = 50.0,
    this.radius = 5.0,
    this.mass = 1.0,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    if (steeringForce.length2 > maxForce * maxForce) {
      steeringForce = steeringForce.normalized() * maxForce;
    }
    Vector2 acceleration = (mass > 1e-6) ? steeringForce / mass : Vector2.zero();
    velocity += acceleration * deltaTime;
    if (velocity.length2 > maxSpeed * maxSpeed) {
      velocity = velocity.normalized() * maxSpeed;
    }
    position += velocity * deltaTime;
  }

  // Simple update for the leader (moves straight, could be more complex)
  void updateSimple(double deltaTime) {
     position += velocity * deltaTime;
     // Optional: Add slight wander or path for leader
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Leader Following Behavior Example ---");

  // Create the leader agent
  final leader = SimpleAgent(
    position: Vector2(50.0, 100.0),
    velocity: Vector2(40.0, 0.0), // Moving right
    maxSpeed: 40.0,
    maxForce: 10.0, // Leader might have some minor steering/corrections
  );
  print("Leader Initial Position: ${leader.position.storage.toList()}");
  print("Leader Initial Velocity: ${leader.velocity.storage.toList()}");

  // Create the follower agent, starting behind the leader
  final follower = SimpleAgent(
    position: Vector2(20.0, 110.0), // Start slightly behind and offset
    velocity: Vector2(0.0, 0.0),    // Start stationary
    maxSpeed: 50.0, // Follower can be slightly faster than leader
    maxForce: 30.0,
  );
  print("Follower Initial Position: ${follower.position.storage.toList()}");
  print("Follower Initial Velocity: ${follower.velocity.storage.toList()}");

  // Optional: Setup for Separation (if used)
  // final spatialGrid = SpatialHashGrid(cellSize: 50.0);
  // final List<SimpleAgent> followers = [follower]; // Add more followers if needed
  // spatialGrid.add(follower);

  // --- 2. Create LeaderFollowing Behavior ---

  // Define parameters for the LeaderFollowing behavior
  final double leaderBehindDistance = 30.0; // How far behind the leader to follow
  final double leaderSightDistance = 40.0; // How far ahead leader "looks" for evasion
  final double leaderSightRadius = 15.0;   // Width of leader's "sight" cone

  // Optional: Parameters for Separation among followers
  final SpatialHashGrid? separationGrid = null; // Set to spatialGrid if using separation
  final double? followerSeparation = null; // e.g., 20.0; Requires separationGrid

  print("Creating LeaderFollowing behavior for the follower:");
  print("  Leader Behind Distance: $leaderBehindDistance");
  print("  Leader Sight Distance: $leaderSightDistance");
  print("  Leader Sight Radius: $leaderSightRadius");
  if (followerSeparation != null) print("  Follower Separation: $followerSeparation");


  // Create the LeaderFollowing behavior instance for the follower
  final followBehavior = LeaderFollowing(
    leader: leader,
    leaderBehindDistance: leaderBehindDistance,
    leaderSightDistance: leaderSightDistance,
    leaderSightRadius: leaderSightRadius,
    spatialGrid: separationGrid, // Pass grid if using separation
    followerSeparation: followerSeparation, // Pass distance if using separation
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 50; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Optional: Update spatial grid if using separation
    // if (separationGrid != null) {
    //   separationGrid.clear();
    //   for (final f in followers) { separationGrid.add(f); }
    // }

    // Update the leader's position (simple straight movement)
    leader.updateSimple(deltaTime);

    // Calculate the steering force for the follower
    final steeringForce = followBehavior.calculateSteering(follower);

    // Apply the steering force to the follower
    follower.applySteering(steeringForce, deltaTime);

    // Print agent states
    print("Step ${i + 1}: "
          "Leader Pos=${leader.position.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Follower Pos=${follower.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, Vel=${follower.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

     // Optional: Add boundary wrap-around for leader/follower if needed
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Leader Final Position: ${leader.position.storage.toList()}");
  print("Follower Final Position: ${follower.position.storage.toList()}");
  print("Follower Final Velocity: ${follower.velocity.storage.toList()}");
  print("----------------------------------");
}