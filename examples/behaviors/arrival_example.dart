import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- Arrival Steering Behavior ---
// Explanation:
// The Arrival behavior steers an agent towards a target position, similar to Seek,
// but with the crucial addition of deceleration. As the agent gets closer to the
// target (within the 'slowingRadius'), the behavior calculates a desired speed
// that ramps down linearly, aiming for zero speed at the target itself.
//
// 1. Setup: We define a target position and create a SimpleAgent positioned
//    elsewhere, giving it some initial velocity.
//
// 2. Behavior Creation: We instantiate the Arrival behavior, providing the
//    target position, a slowingRadius (where deceleration begins), and an
//    arrivalTolerance (a small radius around the target where the agent is
//    considered arrived and active braking occurs).
//
// 3. Simulation: In a loop, we repeatedly:
//    - Calculate the steering force using arrivalBehavior.calculateSteering().
//      Inside the slowing radius, this force will aim to reduce the agent's speed.
//      Inside the arrival tolerance, it actively brakes (-agent.velocity).
//    - Apply the force to the agent using agent.applySteering().
//    - Print the agent's state to observe its movement and deceleration.
//
// 4. Result: The simulation output shows the agent moving towards the target.
//    As it enters the slowingRadius, its speed decreases. Ideally, it comes
//    to a near stop very close to the targetPosition, within the arrivalTolerance.
//    Fine-tuning maxSpeed, maxForce, slowingRadius, and arrivalTolerance might be
//    needed for perfectly smooth arrival without overshooting, depending on the
//    simulation's physics and time step.

/// Minimal Agent class implementation for demonstration purposes.
/// (Same as in alignment_example.dart)
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
  print("--- Arrival Behavior Example ---");

  // Define the target position the agent should arrive at
  final targetPosition = Vector2(200.0, 150.0);
  print("Target Position: ${targetPosition.storage.toList()}");

  // Create an agent starting away from the target, with some initial velocity
  final agent = SimpleAgent(
    position: Vector2(10.0, 10.0),
    velocity: Vector2(30.0, 10.0), // Initial velocity towards the general direction
    maxSpeed: 80.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create Arrival Behavior ---

  // Define parameters for the Arrival behavior
  final double slowingRadius = 100.0; // Distance from target to start slowing down
  final double arrivalTolerance = 2.0; // Distance within which agent is considered 'arrived'

  print("Creating Arrival behavior with slowingRadius: $slowingRadius, tolerance: $arrivalTolerance");

  // Create the Arrival behavior instance
  final arrivalBehavior = Arrival(
    target: targetPosition,
    slowingRadius: slowingRadius,
    arrivalTolerance: arrivalTolerance,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 50; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate distance to target for observation
    final distanceToTarget = agent.position.distanceTo(targetPosition);

    // Calculate the steering force from the Arrival behavior
    final steeringForce = arrivalBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "DistToTarget: ${distanceToTarget.toStringAsFixed(1)}");

    // Check if the agent has effectively arrived (within tolerance)
    if (distanceToTarget < arrivalTolerance && agent.velocity.length < 0.5) {
      print("\nAgent has arrived at the target (or very close and slow).");
      break;
    }
     // Check if agent overshot and is moving away significantly
    if (i > 5 && agent.velocity.dot(targetPosition - agent.position) < 0 && distanceToTarget > slowingRadius * 0.5) {
       print("\nAgent seems to be moving away after potentially overshooting.");
       // break; // Optional: stop if moving away
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}