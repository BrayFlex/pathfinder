import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

// --- Cohesion Steering Behavior ---
// Explanation:
// The Cohesion behavior steers an agent towards the average position (center of mass)
// of its local neighbors. It encourages agents in a group to stay together.
// It's often used in combination with Separation and Alignment for flocking.
//
// 1. Setup: We create a SpatialHashGrid and populate it with agents. Some agents
//    are placed close to 'mainAgent' to act as neighbors, while others are distant.
//
// 2. Behavior Creation: We instantiate the Cohesion behavior, providing the
//    spatialGrid and a neighborhoodRadius. Neighbors outside this radius are ignored.
//    An optional viewAngle could further filter neighbors.
//
// 3. Simulation: We calculate the steering force for 'mainAgent'. The behavior
//    queries the spatialGrid for neighbors within the radius, calculates their
//    average position (center of mass), and then calculates a steering force
//    (using Seek logic internally) to move 'mainAgent' towards that center point.
//    We apply this force for one time step.
//
// 4. Result: The output shows the calculated force and the agent's state after
//    applying the force. Since 'mainAgent' started at the center of its initial
//    neighbors, the initial steering force might be small. If the neighbors were
//    offset, the agent would start moving towards their average position.
//
// Note: Like Alignment, accurate simulation requires updating the SpatialHashGrid
// each frame as agents move.

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
  print("--- Cohesion Behavior Example ---");

  // Define grid parameters
  final double gridCellSize = 50.0;
  final spatialGrid = SpatialHashGrid(cellSize: gridCellSize);

  // Create agents, some clustered together, some further away
  final List<SimpleAgent> agents = [];
  final Random random = Random();
  final double worldWidth = 1000.0;
  final double worldHeight = 1000.0;

  print("Creating agents (some clustered)...");
  // Agent 0 (our test agent)
  final mainAgent = SimpleAgent(
    position: Vector2(worldWidth * 0.5, worldHeight * 0.5), // Center
    velocity: Vector2(0, 0), // Start stationary
    maxSpeed: 50.0,
    maxForce: 30.0,
  );
  agents.add(mainAgent);

  // Add neighbors close to the main agent
  for (int i = 0; i < 5; i++) {
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * 40 + 10; // 10 to 50 units away
    final neighborPos = mainAgent.position + Vector2(cos(angle) * distance, sin(angle) * distance);
    agents.add(SimpleAgent(
      position: neighborPos,
      velocity: Vector2(random.nextDouble() * 10 - 5, random.nextDouble() * 10 - 5),
    ));
  }
  // Add some distant agents
  for (int i = 0; i < 5; i++) {
     agents.add(SimpleAgent(
      position: Vector2(random.nextDouble() * worldWidth, random.nextDouble() * worldHeight),
      velocity: Vector2(random.nextDouble() * 10 - 5, random.nextDouble() * 10 - 5),
    ));
  }


  // Add agents to the spatial grid.
  print("Adding agents to SpatialHashGrid...");
  for (final agent in agents) {
    spatialGrid.add(agent);
  }

  print("Agent Initial Position: ${mainAgent.position.storage.toList()}");
  print("Agent Initial Velocity: ${mainAgent.velocity.storage.toList()}");

  // --- 2. Create Cohesion Behavior ---

  // Define parameters for the Cohesion behavior
  final double neighborhoodRadius = 60.0; // How far the agent looks for neighbors
  final double? viewAngle = null; // Optional: radians. null means 360 view.

  print("Creating Cohesion behavior with radius: $neighborhoodRadius");

  // Create the Cohesion behavior instance
  final cohesionBehavior = Cohesion(
    spatialGrid: spatialGrid,
    neighborhoodRadius: neighborhoodRadius,
    viewAngle: viewAngle,
  );

  // --- 3. Simulation Step (Simplified) ---

  final double deltaTime = 0.1; // Example time step

  print("Calculating steering force for one agent...");
  // Calculate the steering force from the Cohesion behavior.
  // This force attempts to steer 'mainAgent' towards the center of mass of its neighbors.
  final steeringForce = cohesionBehavior.calculateSteering(mainAgent);

  print("Calculated Cohesion Steering Force: ${steeringForce.storage.toList()}");

  // Apply the steering force to the agent's movement
  print("Applying force and updating agent state (deltaTime: ${deltaTime}s)...");
  mainAgent.applySteering(steeringForce, deltaTime);

  // --- 4. Output / Verification ---

  print("Agent Final Position: ${mainAgent.position.storage.toList()}");
  print("Agent Final Velocity: ${mainAgent.velocity.storage.toList()}");
  print("----------------------------------");
}