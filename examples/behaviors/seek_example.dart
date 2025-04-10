import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
// No Random needed for this basic example

// --- Seek Steering Behavior ---
// Explanation:
// The Seek behavior calculates a steering force that directs an agent to move
// towards a specified static target position at its maximum possible speed.
// It's one of the simplest steering behaviors.
//
// 1. Setup: We define a static target position and create a SimpleAgent positioned
//    elsewhere, starting stationary.
//
// 2. Behavior Creation: We instantiate the Seek behavior, providing the target
//    position.
//
// 3. Simulation: In a loop, we repeatedly:
//    - Calculate the steering force using seekBehavior.calculateSteering(). This
//      force points directly towards the target, aiming for maxSpeed.
//    - Apply the force to the agent using agent.applySteering().
//    - Print the agent's state.
//
// 4. Result: The simulation output shows the agent accelerating and moving in a
//    straight line directly towards the target position. Unlike Arrival, Seek
//    does not slow the agent down as it approaches the target; it will likely
//    overshoot if the simulation continues.

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
  print("--- Seek Behavior Example ---");

  // Define the static target position the agent should seek
  final targetPosition = Vector2(250.0, 200.0);
  print("Target Position (to seek): ${targetPosition.storage.toList()}");

  // Create an agent starting away from the target
  final agent = SimpleAgent(
    position: Vector2(50.0, 50.0),
    velocity: Vector2(0.0, 0.0), // Start stationary
    maxSpeed: 80.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create Seek Behavior ---

  print("Creating Seek behavior targeting: ${targetPosition.storage.toList()}");

  // Create the Seek behavior instance
  final seekBehavior = Seek(
    target: targetPosition,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 40; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate distance to target for observation
    final distanceToTarget = agent.position.distanceTo(targetPosition);

    // Calculate the steering force from the Seek behavior
    final steeringForce = seekBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "DistToTarget: ${distanceToTarget.toStringAsFixed(1)}, "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent gets very close to target
    // Note: Seek doesn't guarantee stopping, Arrival does.
    if (distanceToTarget < agent.radius + 1.0) {
       print("\nAgent is very close to the target.");
       break;
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}