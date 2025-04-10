import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- Evade Steering Behavior ---
// Explanation:
// The Evade behavior allows an agent (evader) to intelligently avoid a moving
// target (pursuer). Unlike Flee, which moves directly away from the target's
// current position, Evade predicts the pursuer's future position and steers
// away from that predicted location.
//
// 1. Setup: We create two agents, an 'evader' and a 'pursuer'. The pursuer is
//    set up to move towards the evader's initial position.
//
// 2. Behavior Creation: We instantiate the Evade behavior for the 'evader',
//    passing the 'pursuer' as the targetAgent. Optional parameters like
//    maxPredictionTime (to limit how far ahead it predicts) and evadeRadius
//    (to only activate when the pursuer is close) can be set.
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force for the 'evader' using evadeBehavior.calculateSteering().
//      This involves predicting the pursuer's future position based on relative
//      positions and velocities, and then calculating a Flee force away from that
//      predicted point.
//    - Apply the steering force to the 'evader'.
//    - Update the 'pursuer's position (in this simple case, it just moves straight).
//    - Print the states to observe the interaction.
//
// 4. Result: The simulation output shows the 'evader' reacting to the 'pursuer'.
//    Instead of waiting for the pursuer to get close, the evader should start
//    moving away from the *intercept course* of the pursuer, demonstrating the
//    predictive nature of the Evade behavior. The evader's path will likely curve
//    away from the pursuer's line of movement.

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

  // Simple update for the pursuer (moves straight)
  void updateSimple(double deltaTime) {
     position += velocity * deltaTime;
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Evade Behavior Example ---");

  // Create the evader agent
  final evader = SimpleAgent(
    position: Vector2(100.0, 100.0),
    velocity: Vector2(0.0, 0.0), // Start stationary or moving slowly
    maxSpeed: 70.0,
    maxForce: 40.0,
  );
  print("Evader Initial Position: ${evader.position.storage.toList()}");
  print("Evader Initial Velocity: ${evader.velocity.storage.toList()}");

  // Create the pursuer agent, moving towards the evader's initial position
  final pursuer = SimpleAgent(
    position: Vector2(300.0, 100.0), // Start to the right
    velocity: Vector2(-50.0, 0.0), // Moving left, towards the evader
    maxSpeed: 50.0, // Pursuer speed
    maxForce: 0.0, // Pursuer doesn't steer in this simple example
  );
  print("Pursuer Initial Position: ${pursuer.position.storage.toList()}");
  print("Pursuer Initial Velocity: ${pursuer.velocity.storage.toList()}");


  // --- 2. Create Evade Behavior ---

  // Define parameters for the Evade behavior
  final double? maxPredictionTime = 1.5; // Optional: Limit prediction lookahead (seconds)
  final double? evadeRadius = null; // Optional: Only evade if pursuer is within this distance

  print("Creating Evade behavior for the evader, targeting the pursuer.");
  if (maxPredictionTime != null) print("  Max Prediction Time: $maxPredictionTime");
  if (evadeRadius != null) print("  Evade Radius: $evadeRadius");

  // Create the Evade behavior instance for the evader
  final evadeBehavior = Evade(
    targetAgent: pursuer,
    maxPredictionTime: maxPredictionTime,
    evadeRadius: evadeRadius,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 30; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force for the evader
    final steeringForce = evadeBehavior.calculateSteering(evader);

    // Apply the steering force to the evader
    evader.applySteering(steeringForce, deltaTime);

    // Update the pursuer (simple straight movement)
    pursuer.updateSimple(deltaTime);

    // Print agent states
    print("Step ${i + 1}: "
          "Evader Pos=${evader.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, Vel=${evader.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "Pursuer Pos=${pursuer.position.storage.map((e) => e.toStringAsFixed(1)).toList()} | "
          "EvadeForce: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

     // Optional: Stop if agents get very far apart
     if (evader.position.distanceToSquared(pursuer.position) > 400 * 400) {
        print("\nAgents are far apart.");
        // break;
     }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Evader Final Position: ${evader.position.storage.toList()}");
  print("Evader Final Velocity: ${evader.velocity.storage.toList()}");
  print("Pursuer Final Position: ${pursuer.position.storage.toList()}");
  print("----------------------------------");
}