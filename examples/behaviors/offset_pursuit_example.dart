import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- OffsetPursuit Steering Behavior ---
// Explanation:
// The Offset Pursuit behavior allows an agent (follower) to maintain a specific
// position relative to a moving target (leader). The desired position is defined
// by an 'offset' vector in the *leader's local coordinate space*.
//
// 1. Setup: We create a 'leader' agent moving with a constant velocity and a
//    'follower' agent starting elsewhere.
//
// 2. Behavior Creation: We define the desired 'localOffset' (e.g., behind and to
//    the left of the leader). We then instantiate the OffsetPursuit behavior for
//    the follower, providing the leader, the localOffset, and parameters controlling
//    the Arrival logic used to reach the offset point (slowingRadius, arrivalTolerance)
//    and prediction (maxPredictionTime).
//
// 3. Simulation: In a loop, we:
//    - Update the leader's position.
//    - Calculate the steering force for the 'follower' using offsetBehavior.calculateSteering().
//      This involves predicting the leader's future position, transforming the
//      localOffset into a world-space target point relative to that future position,
//      and then using Arrival logic to steer towards that world-space target point.
//    - Apply the steering force to the 'follower'.
//    - Print the states, including the actual world offset between the agents.
//
// 4. Result: The simulation output shows the 'follower' moving towards and then
//    attempting to maintain the desired offset relative to the moving 'leader'.
//    The 'ActualOffset' printed should converge towards the world-space equivalent
//    of the 'localOffset' as the simulation progresses. The follower uses Arrival
//    logic, so it should slow down as it gets very close to the target offset point.

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

  // Simple update for the leader (moves straight)
  void updateSimple(double deltaTime) {
     position += velocity * deltaTime;
     // Optional: Add slight wander or path for leader
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Offset Pursuit Behavior Example ---");

  // Create the leader agent
  final leader = SimpleAgent(
    position: Vector2(50.0, 100.0),
    velocity: Vector2(40.0, 0.0), // Moving right
    maxSpeed: 40.0,
    maxForce: 10.0,
  );
  print("Leader Initial Position: ${leader.position.storage.toList()}");
  print("Leader Initial Velocity: ${leader.velocity.storage.toList()}");

  // Create the follower agent, starting somewhere else
  final follower = SimpleAgent(
    position: Vector2(30.0, 80.0),
    velocity: Vector2(0.0, 0.0), // Start stationary
    maxSpeed: 60.0, // Follower can be faster
    maxForce: 40.0,
  );
  print("Follower Initial Position: ${follower.position.storage.toList()}");
  print("Follower Initial Velocity: ${follower.velocity.storage.toList()}");

  // --- 2. Create OffsetPursuit Behavior ---

  // Define the desired offset in the *leader's local space*
  // (+X is leader's forward, +Y is leader's left)
  final Vector2 localOffset = Vector2(-20.0, 15.0); // 20 units behind, 15 units to the left
  print("Desired Local Offset (Behind, Left): ${localOffset.storage.toList()}");

  // Define other parameters for the behavior (uses Arrival logic)
  final double slowingRadius = 30.0; // Radius to start slowing down when approaching offset point
  final double arrivalTolerance = 1.0; // Tolerance for being "at" the offset point
  final double maxPredictionTime = 1.0; // How far ahead to predict leader's position

  print("Creating OffsetPursuit behavior with:");
  print("  Slowing Radius: $slowingRadius");
  print("  Arrival Tolerance: $arrivalTolerance");
  print("  Max Prediction Time: $maxPredictionTime");

  // Create the OffsetPursuit behavior instance for the follower
  final offsetBehavior = OffsetPursuit(
    targetAgent: leader,
    offset: localOffset,
    slowingRadius: slowingRadius,
    arrivalTolerance: arrivalTolerance,
    maxPredictionTime: maxPredictionTime,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 60; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Update the leader's position
    leader.updateSimple(deltaTime);

    // Calculate the steering force for the follower
    final steeringForce = offsetBehavior.calculateSteering(follower);

    // Apply the steering force to the follower
    follower.applySteering(steeringForce, deltaTime);

    // Calculate the current world offset for logging
    // Transform leader's local offset to world space
    Vector2 currentWorldOffsetTarget;
    final leaderHeading = leader.velocity.normalized();
    final leaderSide = Vector2(-leaderHeading.y, leaderHeading.x);
    final worldOffset = (leaderHeading * localOffset.x) + (leaderSide * localOffset.y);
    currentWorldOffsetTarget = leader.position + worldOffset;
    final actualOffset = follower.position - leader.position;


    // Print agent states and offset info
    print("Step ${i + 1}: "
          "Leader Pos=${leader.position.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Follower Pos=${follower.position.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          // "TargetOffsetPos: ${currentWorldOffsetTarget.storage.map((e) => e.toStringAsFixed(1)).toList()} | " // Target point in world
          "ActualOffset: ${actualOffset.storage.map((e) => e.toStringAsFixed(1)).toList()} | " // Actual world offset
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