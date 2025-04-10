import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

// --- Flocking Steering Behavior ---
// Explanation:
// The Flocking behavior simulates group movement patterns like birds or fish
// by combining three simpler behaviors:
// - Separation: Steers to avoid crowding local neighbors.
// - Cohesion: Steers towards the average position (center of mass) of local neighbors.
// - Alignment: Steers towards the average heading (velocity) of local neighbors.
//
// 1. Setup: We create a SpatialHashGrid and populate it with multiple agents
//    having random initial positions and velocities.
//
// 2. Behavior Creation: We instantiate the Flocking behavior, providing the
//    spatialGrid and parameters for the underlying Separation, Cohesion, and
//    Alignment components (distances/radii). We also provide weights to control
//    the relative influence of each component behavior on the final steering force.
//
// 3. Simulation: In a loop, we:
//    - Update the SpatialHashGrid with the current agent positions (crucial!).
//    - Calculate the combined flocking steering force for each agent using
//      flockingBehavior.calculateSteering().
//    - Apply the calculated forces to update each agent's position and velocity.
//    - (Optional) Implement boundary handling (like wrap-around) to keep agents
//      within the simulation area.
//
// 4. Result: Over time, the agents should exhibit emergent flocking behavior.
//    They will try to stay close together (Cohesion), avoid bumping into each
//    other (Separation), and move in roughly the same direction (Alignment).
//    The exact nature of the flock depends heavily on the chosen parameters and weights.

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
  print("--- Flocking Behavior Example ---");

  // Define grid parameters
  final double gridCellSize = 50.0; // Should be related to interaction radii
  final spatialGrid = SpatialHashGrid(cellSize: gridCellSize);

  // Create agents
  final List<SimpleAgent> agents = [];
  final Random random = Random();
  final double worldWidth = 1000.0;
  final double worldHeight = 1000.0;
  final int numAgents = 50;

  print("Creating $numAgents agents...");
  for (int i = 0; i < numAgents; i++) {
    agents.add(SimpleAgent(
      position: Vector2(random.nextDouble() * worldWidth, random.nextDouble() * worldHeight),
      velocity: Vector2(random.nextDouble() * 40 - 20, random.nextDouble() * 40 - 20),
      maxSpeed: 60.0,
      maxForce: 30.0,
      radius: 4.0,
    ));
  }

  // --- 2. Create Flocking Behavior ---

  // Define parameters for the Flocking behavior's components
  final double separationDistance = 25.0; // Desired minimum distance between agents
  final double alignmentRadius = 50.0;   // Radius for checking neighbors' alignment
  final double cohesionRadius = 60.0;    // Radius for checking neighbors' center of mass
  final double? viewAngle = null;       // Optional view angle constraint (radians)

  // Define weights for each component
  final double separationWeight = 1.8;
  final double alignmentWeight = 1.0;
  final double cohesionWeight = 1.0;

  print("Creating Flocking behavior with:");
  print("  Separation Distance: $separationDistance (Weight: $separationWeight)");
  print("  Alignment Radius: $alignmentRadius (Weight: $alignmentWeight)");
  print("  Cohesion Radius: $cohesionRadius (Weight: $cohesionWeight)");
  if (viewAngle != null) print("  View Angle: $viewAngle");

  // Create the Flocking behavior instance.
  // Note: This single behavior instance can be reused for all agents,
  // as it calculates forces based on the agent passed to calculateSteering.
  final flockingBehavior = Flocking(
    spatialGrid: spatialGrid,
    separationDistance: separationDistance,
    alignmentRadius: alignmentRadius,
    cohesionRadius: cohesionRadius,
    viewAngle: viewAngle,
    separationWeight: separationWeight,
    alignmentWeight: alignmentWeight,
    cohesionWeight: cohesionWeight,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 50; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // IMPORTANT: Update the spatial grid each step
    spatialGrid.clear();
    for (final agent in agents) {
      spatialGrid.add(agent);
    }

    // Calculate steering forces for all agents first
    final Map<SimpleAgent, Vector2> forces = {};
    for (final agent in agents) {
      forces[agent] = flockingBehavior.calculateSteering(agent);
    }

    // Apply forces to update agents
    for (final agent in agents) {
      agent.applySteering(forces[agent]!, deltaTime);

      // Optional: Keep agents within bounds (simple wrap-around)
      agent.position.x = (agent.position.x + worldWidth) % worldWidth;
      agent.position.y = (agent.position.y + worldHeight) % worldHeight;
    }

    // Print state of the first few agents
    if ((i + 1) % 5 == 0) { // Print every 5 steps
       print("Step ${i + 1}:");
       for(int j=0; j< min(3, agents.length); ++j) {
          final agent = agents[j];
          print("  Agent $j: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
                "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()}");
       }
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  // Output final state of first agent for reference
  if (agents.isNotEmpty) {
     print("Agent 0 Final Position: ${agents[0].position.storage.toList()}");
     print("Agent 0 Final Velocity: ${agents[0].velocity.storage.toList()}");
  }
  print("----------------------------------");
}