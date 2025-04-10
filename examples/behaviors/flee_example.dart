import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
// No Random needed for this basic example

// --- Flee Steering Behavior ---
// Explanation:
// The Flee behavior calculates a steering force that directs an agent to move
// directly away from a specified static target position at its maximum speed.
// It's the opposite of the Seek behavior.
//
// 1. Setup: We define a static target position and create a SimpleAgent positioned
//    nearby.
//
// 2. Behavior Creation: We instantiate the Flee behavior, providing the target
//    position. An optional fleeRadius can be set, causing the behavior to only
//    activate when the agent is within that distance of the target.
//
// 3. Simulation: In a loop, we repeatedly:
//    - Calculate the steering force using fleeBehavior.calculateSteering(). If the
//      agent is within the fleeRadius (if set), this force will point directly
//      away from the target, aiming for maxSpeed.
//    - Apply the force to the agent using agent.applySteering().
//    - Print the agent's state.
//
// 4. Result: The simulation output shows the agent accelerating directly away
//    from the target position. If a fleeRadius was set, the steering force would
//    become zero once the agent moved beyond that distance from the target.

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
}

void main() {
  // --- 1. Setup ---
  print("--- Flee Behavior Example ---");

  // Define the static target position the agent should flee from
  final targetPosition = Vector2(150.0, 150.0);
  print("Target Position (to flee from): ${targetPosition.storage.toList()}");

  // Create an agent starting near the target
  final agent = SimpleAgent(
    position: Vector2(160.0, 160.0), // Start close to the target
    velocity: Vector2(0.0, 0.0),     // Start stationary
    maxSpeed: 80.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create Flee Behavior ---

  // Define parameters for the Flee behavior
  final double? fleeRadius = 100.0; // Optional: Only flee if target is within this distance

  print("Creating Flee behavior targeting: ${targetPosition.storage.toList()}");
  if (fleeRadius != null) print("  Flee Radius: $fleeRadius");

  // Create the Flee behavior instance
  final fleeBehavior = Flee(
    target: targetPosition,
    fleeRadius: fleeRadius,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 30; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate distance to target for observation
    final distanceToTarget = agent.position.distanceTo(targetPosition);

    // Calculate the steering force from the Flee behavior
    final steeringForce = fleeBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "DistToTarget: ${distanceToTarget.toStringAsFixed(1)}, "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent gets far enough away (especially if fleeRadius is used)
    if (fleeRadius != null && distanceToTarget > fleeRadius * 1.1) {
       print("\nAgent is outside the flee radius.");
       // break;
    }
     if (distanceToTarget > 300) { // General distance check
        print("\nAgent is far from the target.");
        break;
     }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}