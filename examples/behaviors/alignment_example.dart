import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart'; // Added import
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

// --- Alignment Steering Behavior ---
// Explanation:
// The Alignment behavior aims to steer an agent so that its velocity vector
// matches the average velocity vector of its nearby neighbors. It's a key
// component of flocking simulations.
//
// 1. Setup: We create a SpatialHashGrid for efficient neighbor lookups and
//    populate it with several SimpleAgent instances having random positions
//    and initial velocities.
//
// 2. Behavior Creation: We instantiate the Alignment behavior, providing the
//    spatialGrid and a neighborhoodRadius. An optional viewAngle could limit
//    the search to agents within a specific field of view relative to the
//    agent's current heading.
//
// 3. Simulation: We calculate the steering force for 'mainAgent'. The behavior
//    queries the spatialGrid for neighbors within the radius (and view angle,
//    if specified), calculates their average velocity, and determines the force
//    needed for 'mainAgent' to steer towards that average velocity. We then
//    apply this force using a simplified physics update.
//
// 4. Result: The output shows the calculated force and the agent's state after
//    applying the force for one time step. The agent's velocity should have
//    shifted slightly towards the average velocity of its initial neighbors
//    (assuming it had neighbors within the radius).
//
// Note: For accurate results in a continuous simulation, agents' positions
// in the SpatialHashGrid must be updated each frame using `spatialGrid.clear()`
// and re-adding agents, or using `spatialGrid.updateAgent()`.

/// Minimal Agent class implementation for demonstration purposes.
/// In a real application, this would be your game or simulation agent class.
class SimpleAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce; // Max steering force magnitude
  @override
  double radius; // Agent's size, potentially used by other behaviors or grid
  @override
  double mass; // Agent's mass, used in physics calculations

  SimpleAgent({
    required this.position,
    required this.velocity,
    this.maxSpeed = 100.0,
    this.maxForce = 50.0,
    this.radius = 5.0,
    this.mass = 1.0, // Default mass to 1.0
  });

  /// Applies the steering force to update the agent's velocity and position.
  /// This is a required method from the Agent interface.
  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // Ensure steering force doesn't exceed maxForce
    if (steeringForce.length2 > maxForce * maxForce) {
      steeringForce = steeringForce.normalized() * maxForce;
    }

    // Acceleration = Force / Mass
    // Handle potential division by zero if mass is zero or negative
    Vector2 acceleration = (mass > 1e-6) ? steeringForce / mass : Vector2.zero();

    // Update velocity: v = u + at
    velocity += acceleration * deltaTime;

    // Ensure velocity doesn't exceed maxSpeed
    if (velocity.length2 > maxSpeed * maxSpeed) {
      velocity = velocity.normalized() * maxSpeed;
    }

    // Update position: s = s + vt
    position += velocity * deltaTime;
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Alignment Behavior Example ---");

  // Define grid parameters
  final double gridCellSize = 50.0; // Should be related to query radius or agent size
  // The grid dimensions are implicit and grow as needed.
  final spatialGrid = SpatialHashGrid(cellSize: gridCellSize);

  // Create agents with random positions and velocities
  final List<SimpleAgent> agents = [];
  final Random random = Random();
  // Define the world boundaries for placing agents in the example
  final double worldWidth = 1000.0;
  final double worldHeight = 1000.0;

  print("Creating 50 agents...");
  for (int i = 0; i < 50; i++) {
    final agent = SimpleAgent(
      position: Vector2(random.nextDouble() * worldWidth, random.nextDouble() * worldHeight),
      // Give agents some initial random velocity for alignment to work
      velocity: Vector2(random.nextDouble() * 40 - 20, random.nextDouble() * 40 - 20), // Range -20 to +20
      maxSpeed: 50.0,
      maxForce: 30.0,
    );
    agents.add(agent);
  }

  // Add agents to the spatial grid.
  // IMPORTANT: In a real simulation, the grid needs to be updated each frame
  // using spatialGrid.update(agent) for moving agents, or spatialGrid.clear()
  // and re-adding all agents.
  print("Adding agents to SpatialHashGrid...");
  for (final agent in agents) {
    spatialGrid.add(agent); // Corrected method name
  }

  // Select one agent to demonstrate the behavior
  final mainAgent = agents[0];
  print("Agent Initial Position: ${mainAgent.position.storage.toList()}");
  print("Agent Initial Velocity: ${mainAgent.velocity.storage.toList()}");

  // --- 2. Create Alignment Behavior ---

  // Define parameters for the Alignment behavior
  final double neighborhoodRadius = 60.0; // How far the agent looks for neighbors
  final double? viewAngle = null; // Optional: radians (e.g., pi). null means 360 view.

  print("Creating Alignment behavior with radius: $neighborhoodRadius");

  // Create the Alignment behavior instance
  final alignmentBehavior = Alignment(
    spatialGrid: spatialGrid,
    neighborhoodRadius: neighborhoodRadius,
    viewAngle: viewAngle, // Can be omitted if null
  );

  // --- 3. Simulation Step (Simplified) ---

  // In a real application, this would be part of a game loop.
  final double deltaTime = 0.1; // Example time step

  print("Calculating steering force for one agent...");
  // Calculate the steering force from the Alignment behavior.
  // This force attempts to make 'mainAgent' align its velocity with its neighbors.
  final steeringForce = alignmentBehavior.calculateSteering(mainAgent);

  print("Calculated Alignment Steering Force: ${steeringForce.storage.toList()}");

  // Apply the steering force using the Agent's method
  print("Applying force and updating agent state (deltaTime: ${deltaTime}s)...");
  mainAgent.applySteering(steeringForce, deltaTime);

  // --- 4. Output / Verification ---

  print("Agent Final Position: ${mainAgent.position.storage.toList()}");
  print("Agent Final Velocity: ${mainAgent.velocity.storage.toList()}");
  print("----------------------------------");
}