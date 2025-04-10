import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
// No Random needed for this basic example

// --- FlowFieldFollowing Steering Behavior ---
// Explanation:
// The Flow Field Following behavior steers an agent to align its movement with
// a predefined vector field (FlowField). The field defines a desired direction
// of movement at different points in space.
//
// 1. Setup: We define a simple ExampleFlowField that always returns a vector
//    pointing right. We create an agent with an initial velocity that opposes
//    this flow.
//
// 2. Behavior Creation: We instantiate the FlowFieldFollowing behavior, passing
//    it our flow field object. An optional predictionDistance allows the agent
//    to sample the field slightly ahead of its current position, anticipating changes.
//    A cast `as FlowField` is used, assuming our example class matches the expected interface.
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force using followBehavior.calculateSteering().
//      The behavior looks up the desired flow vector from the field (at the agent's
//      current or predicted position) and calculates a force to steer the agent's
//      velocity towards that direction.
//    - Apply the force to the agent.
//    - Print the agent's state.
//
// 4. Result: The simulation output shows the agent, initially moving against the
//    flow, gradually turning its velocity to align with the flow field's direction
//    (to the right in this example). The steering force actively works to change
//    the agent's velocity until it matches the field's direction.

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

/// Minimal FlowField implementation for demonstration purposes.
/// Assumes it has a lookup method returning a direction vector.
/// In the actual library, this would likely be part of flow_field.dart
/// and could be based on a grid, noise function, etc.
class ExampleFlowField {
  /// Returns a flow vector based on the position.
  /// This simple example always returns a vector pointing right.
  Vector2 lookup(Vector2 position) {
    // A real flow field would have complex logic here, e.g., based on grid cells:
    // int cellX = (position.x / cellSize).floor();
    // int cellY = (position.y / cellSize).floor();
    // return gridVectors[cellX][cellY];
    return Vector2(1.0, 0.0); // Always flow right
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Flow Field Following Example ---");

  // Create an instance of our example flow field
  final flowField = ExampleFlowField();
  print("Created ExampleFlowField (always flows right -> [1.0, 0.0])");

  // Create an agent starting with velocity opposing the flow field
  final agent = SimpleAgent(
    position: Vector2(100.0, 100.0),
    velocity: Vector2(-30.0, 20.0), // Initial velocity moving left-upish
    maxSpeed: 60.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create FlowFieldFollowing Behavior ---

  // Define parameters for the FlowFieldFollowing behavior
  final double? predictionDistance = 10.0; // Optional: Look ahead distance

  print("Creating FlowFieldFollowing behavior.");
  if (predictionDistance != null) print("  Prediction Distance: $predictionDistance");

  // Create the FlowFieldFollowing behavior instance
  // NOTE: We need to cast our example flow field to the type expected.
  // This assumes the library's FlowFieldFollowing expects an object with a
  // `lookup(Vector2)` method. If it requires a specific class from
  // `flow_field.dart`, this example needs adjustment.
  final followBehavior = FlowFieldFollowing(
    flowField: flowField as FlowField, // Cast needed here
    predictionDistance: predictionDistance,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 30; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force from the FlowFieldFollowing behavior
    final steeringForce = followBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent is moving strongly with the field
    if (agent.velocity.dot(Vector2(1.0, 0.0)) > agent.maxSpeed * 0.9 && i > 5) {
       print("\nAgent is moving predominantly with the flow field.");
       // break;
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}