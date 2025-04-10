import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';
// No Random needed for this basic example

// --- ObstacleAvoidance Steering Behavior ---
// Explanation:
// The Obstacle Avoidance behavior steers an agent to avoid collisions with
// static obstacles (currently CircleObstacles). It projects a "detection box"
// forward based on the agent's velocity and checks for intersections with obstacles.
// If a potential collision is detected, it applies a lateral force to steer the
// agent away.
//
// 1. Setup: We define some ExampleCircleObstacle instances and create an agent
//    moving towards them. The agent's radius is also important for the calculation.
//
// 2. Behavior Creation: We instantiate the ObstacleAvoidance behavior, providing
//    the list of obstacles, a detectionBoxLength (how far ahead to look), and an
//    avoidanceForceMultiplier (strength of the push). A cast `as List<Obstacle>`
//    is used, assuming our example class matches the expected interface.
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force using avoidanceBehavior.calculateSteering().
//      If the agent's projected path intersects an obstacle within the detection
//      box length (considering both agent and obstacle radii), a non-zero force
//      perpendicular to the agent's heading is generated.
//    - Apply the force to the agent.
//    - Print the agent's state and the calculated force.
//
// 4. Result: The simulation output shows the agent moving towards the obstacles.
//    As it gets close and the detection box intersects an obstacle, the steering
//    force becomes active (non-zero), pushing the agent sideways (likely upwards
//    or downwards in this setup) to avoid the collision. The agent's path should
//    curve around the obstacle(s).

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
  double radius; // Agent radius is important for obstacle avoidance!
  @override
  double mass;

  SimpleAgent({
    required this.position,
    required this.velocity,
    this.maxSpeed = 100.0,
    this.maxForce = 50.0,
    this.radius = 8.0, // Give agent some size
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

/// Minimal CircleObstacle implementation for demonstration purposes.
/// Assumes it has position and radius properties.
/// In the actual library, this would likely be part of obstacle.dart.
class ExampleCircleObstacle {
  final Vector2 position;
  final double radius;

  ExampleCircleObstacle({required this.position, required this.radius});
}

void main() {
  // --- 1. Setup ---
  print("--- Obstacle Avoidance Example ---");

  // Create obstacles
  final obstacles = [
    ExampleCircleObstacle(position: Vector2(200.0, 100.0), radius: 30.0),
    ExampleCircleObstacle(position: Vector2(350.0, 150.0), radius: 40.0),
  ];
  print("Created ${obstacles.length} obstacles:");
  for (int i = 0; i < obstacles.length; i++) {
    print("  Obstacle $i: Pos=${obstacles[i].position.storage.toList()}, Radius=${obstacles[i].radius}");
  }


  // Create an agent starting before the obstacles, moving towards them
  final agent = SimpleAgent(
    position: Vector2(50.0, 100.0),
    velocity: Vector2(70.0, 10.0), // Moving right and slightly up
    maxSpeed: 70.0,
    maxForce: 50.0,
    radius: 8.0, // Agent's radius
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");
  print("Agent Radius: ${agent.radius}");

  // --- 2. Create ObstacleAvoidance Behavior ---

  // Define parameters for the ObstacleAvoidance behavior
  final double detectionBoxLength = 80.0; // How far ahead the agent "looks"
  final double avoidanceForceMultiplier = 120.0; // Strength of the avoidance force

  print("Creating ObstacleAvoidance behavior with:");
  print("  Detection Box Length: $detectionBoxLength");
  print("  Avoidance Force Multiplier: $avoidanceForceMultiplier");

  // Create the ObstacleAvoidance behavior instance
  // NOTE: We need to cast our example obstacles to the type expected.
  // The behavior internally checks for CircleObstacle type.
  // This assumes the library's ObstacleAvoidance expects List<Obstacle>.
  final avoidanceBehavior = ObstacleAvoidance(
    obstacles: obstacles as List<Obstacle>, // Cast needed here
    detectionBoxLength: detectionBoxLength,
    avoidanceForceMultiplier: avoidanceForceMultiplier,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 40; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force from the ObstacleAvoidance behavior
    final steeringForce = avoidanceBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent has clearly passed the obstacles
    if (agent.position.x > 450 && i > 10) {
       print("\nAgent has likely passed the obstacles.");
       break;
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}