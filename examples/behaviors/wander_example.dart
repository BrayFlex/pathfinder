import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math'; // For Random and math functions (cos, sin, pi)

// --- Wander Steering Behavior ---
// Explanation:
// The Wander behavior produces seemingly random, natural-looking movement.
// It projects a virtual circle ahead of the agent and steers towards a target
// point that randomly moves along the circumference of this circle.
//
// 1. Setup: We create a SimpleAgent with some initial velocity.
//
// 2. Behavior Creation: We instantiate the Wander behavior, providing parameters:
//    - circleDistance: How far ahead the virtual circle's center is projected.
//    - circleRadius: The radius of the circle, controlling the magnitude of the
//      random displacement.
//    - angleChangePerSecond: Controls how quickly the target point on the circle
//      can shift its angle randomly.
//    - (Optional) seed: For deterministic random behavior during testing.
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force using wanderBehavior.calculateSteering().
//      The behavior updates its internal wander angle slightly, calculates the
//      position of the wander circle center ahead of the agent, determines the
//      target point on the circle based on the new angle, and generates a steering
//      force towards that target.
//    - Apply the force to the agent.
//    - Print the agent's state.
//
// 4. Result: The simulation output shows the agent moving in a non-straight path.
//    Its velocity vector changes direction gradually over time, creating a meandering
//    or wandering effect. The "randomness" comes from the small, continuous changes
//    to the target angle on the wander circle.

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
  print("--- Wander Behavior Example ---");

  // Create an agent
  final agent = SimpleAgent(
    position: Vector2(200.0, 200.0),
    velocity: Vector2(30.0, 0.0), // Start with some initial velocity
    maxSpeed: 50.0,
    maxForce: 20.0, // Lower maxForce can lead to smoother wandering
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create Wander Behavior ---

  // Define parameters for the Wander behavior
  final double circleDistance = 50.0; // How far ahead the wander circle center is
  final double circleRadius = 25.0;   // Radius of the wander circle (magnitude of displacement)
  final double angleChangePerSecond = pi / 2; // Max random angle change per second (90 degrees)
  final int? seed = null; // Optional seed for deterministic random changes

  print("Creating Wander behavior with:");
  print("  Circle Distance: $circleDistance");
  print("  Circle Radius: $circleRadius");
  print("  Angle Change Per Second: ${angleChangePerSecond.toStringAsFixed(2)} radians");
  if (seed != null) print("  Using Random Seed: $seed");

  // Create the Wander behavior instance
  final wanderBehavior = Wander(
    circleDistance: circleDistance,
    circleRadius: circleRadius,
    angleChangePerSecond: angleChangePerSecond,
    seed: seed,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 100; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force from the Wander behavior
    final steeringForce = wanderBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          // "WanderAngle: ${wanderBehavior.debugWanderAngle.toStringAsFixed(2)}, " // Optional debug info
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Add boundary wrap-around or containment
    // agent.position.x = (agent.position.x + 400) % 400;
    // agent.position.y = (agent.position.y + 400) % 400;
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}