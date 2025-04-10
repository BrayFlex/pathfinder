import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
// No Random needed for this basic example

// --- Pursuit Steering Behavior ---
// Explanation:
// The Pursuit behavior enables an agent (pursuer) to intercept a moving target.
// Unlike Seek (which aims at the target's current position), Pursuit predicts
// the target's future position based on current velocities and distance, and
// steers towards that predicted intercept point.
//
// 1. Setup: We create two agents, a 'target' moving at a constant velocity and
//    a 'pursuer' starting elsewhere. The pursuer should generally have a higher
//    maxSpeed than the target to be able to intercept effectively.
//
// 2. Behavior Creation: We instantiate the Pursuit behavior for the 'pursuer',
//    passing the 'target' agent. An optional maxPredictionTime can limit how
//    far into the future the prediction looks.
//
// 3. Simulation: In a loop, we:
//    - Update the target's position.
//    - Calculate the steering force for the 'pursuer' using pursuitBehavior.calculateSteering().
//      This involves predicting the target's future position and calculating a
//      Seek force towards that point.
//    - Apply the steering force to the 'pursuer'.
//    - Print the states.
//
// 4. Result: The simulation output shows the 'pursuer' moving not directly at the
//    target's current position, but towards where the target *will be*. This leads
//    to a more direct interception course compared to a simple Seek, which often
//    results in a tail chase. The pursuer should eventually reach the target.

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

  // Simple update for the target (moves straight)
  void updateSimple(double deltaTime) {
     position += velocity * deltaTime;
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Pursuit Behavior Example ---");

  // Create the target agent (quarry)
  final target = SimpleAgent(
    position: Vector2(100.0, 50.0),
    velocity: Vector2(0.0, 40.0), // Moving straight up
    maxSpeed: 40.0,
    maxForce: 0.0, // Target doesn't steer
  );
  print("Target Initial Position: ${target.position.storage.toList()}");
  print("Target Initial Velocity: ${target.velocity.storage.toList()}");

  // Create the pursuer agent
  final pursuer = SimpleAgent(
    position: Vector2(200.0, 50.0), // Start to the right of the target
    velocity: Vector2(0.0, 0.0),   // Start stationary
    maxSpeed: 70.0, // Pursuer should ideally be faster than target
    maxForce: 40.0,
  );
  print("Pursuer Initial Position: ${pursuer.position.storage.toList()}");
  print("Pursuer Initial Velocity: ${pursuer.velocity.storage.toList()}");

  // --- 2. Create Pursuit Behavior ---

  // Define parameters for the Pursuit behavior
  final double? maxPredictionTime = 2.0; // Optional: Limit prediction lookahead (seconds)

  print("Creating Pursuit behavior for the pursuer, targeting the target.");
  if (maxPredictionTime != null) print("  Max Prediction Time: $maxPredictionTime");

  // Create the Pursuit behavior instance for the pursuer
  final pursuitBehavior = Pursuit(
    targetAgent: target,
    maxPredictionTime: maxPredictionTime,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 40; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Update the target's position (simple straight movement)
    target.updateSimple(deltaTime);

    // Calculate the steering force for the pursuer
    final steeringForce = pursuitBehavior.calculateSteering(pursuer);

    // Apply the steering force to the pursuer
    pursuer.applySteering(steeringForce, deltaTime);

    // Print agent states
    final distance = pursuer.position.distanceTo(target.position);
    print("Step ${i + 1}: "
          "Target Pos=${target.position.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Pursuer Pos=${pursuer.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, Vel=${pursuer.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Dist: ${distance.toStringAsFixed(1)} | "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

     // Optional: Stop if pursuer gets very close to target
     if (distance < pursuer.radius + target.radius + 1.0) {
        print("\nPursuer has reached the target.");
        break;
     }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Target Final Position: ${target.position.storage.toList()}");
  print("Pursuer Final Position: ${pursuer.position.storage.toList()}");
  print("Pursuer Final Velocity: ${pursuer.velocity.storage.toList()}");
  print("----------------------------------");
}