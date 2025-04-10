import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:vector_math/vector_math_64.dart';

// --- UnalignedCollisionAvoidance Steering Behavior ---
// Explanation:
// The Unaligned Collision Avoidance behavior steers an agent to avoid potential
// future collisions with other *moving* agents. It predicts the time and location
// of the closest point of approach (CPA) between agents based on their current
// velocities. If a collision (CPA distance < combined radii) is predicted within
// a certain time window (maxPredictionTime), it applies a steering force.
//
// 1. Setup: We create a SpatialHashGrid and two agents (A and B) initially moving
//    towards each other on a potential collision course. Agent radii are important.
//
// 2. Behavior Creation: We instantiate the UnalignedCollisionAvoidance behavior
//    for both agents (they will avoid each other). We provide the spatialGrid,
//    maxPredictionTime, and an avoidanceForceMultiplier.
//
// 3. Simulation: In a loop, we:
//    - Update the SpatialHashGrid with current agent positions.
//    - Calculate the avoidance steering force for each agent using the behavior.
//      The behavior queries the grid for nearby agents, calculates relative motion,
//      predicts the CPA, and if a collision is imminent, generates a force to
//      steer away from the predicted collision point/time. The force is stronger
//      for more imminent collisions.
//    - Apply the calculated forces to update the agents.
//    - Print the states and forces.
//
// 4. Result: The simulation output shows the agents initially moving towards each other.
//    As the predicted CPA becomes imminent and within the collision threshold, the
//    avoidance forces become non-zero, causing the agents to alter their trajectories
//    (likely steering slightly up or down relative to each other in this case) to
//    avoid the head-on collision. They should pass each other safely.

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
  double radius; // Agent radius is crucial for collision detection!
  @override
  double mass;

  SimpleAgent({
    required this.position,
    required this.velocity,
    this.maxSpeed = 100.0,
    this.maxForce = 50.0,
    this.radius = 10.0, // Give agents a noticeable radius
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

  // Simple update for an agent not using steering (moves straight)
  void updateSimple(double deltaTime) {
     position += velocity * deltaTime;
  }
}

void main() {
  // --- 1. Setup ---
  print("--- Unaligned Collision Avoidance Example ---");

  // Define grid parameters
  final double gridCellSize = 50.0; // Should be related to interaction radii/prediction
  final spatialGrid = SpatialHashGrid(cellSize: gridCellSize);

  // Create agents on a collision course
  final agentA = SimpleAgent(
    position: Vector2(50.0, 100.0),
    velocity: Vector2(60.0, 0.0), // Moving right
    maxSpeed: 60.0,
    maxForce: 50.0,
    radius: 10.0,
  );
  final agentB = SimpleAgent(
    position: Vector2(250.0, 105.0), // Slightly offset vertically
    velocity: Vector2(-60.0, 0.0), // Moving left
    maxSpeed: 60.0,
    maxForce: 50.0, // Agent B will also avoid A
    radius: 10.0,
  );

  final List<SimpleAgent> agents = [agentA, agentB];

  print("Agent A Initial Pos: ${agentA.position.storage.toList()}, Vel: ${agentA.velocity.storage.toList()}");
  print("Agent B Initial Pos: ${agentB.position.storage.toList()}, Vel: ${agentB.velocity.storage.toList()}");

  // --- 2. Create UnalignedCollisionAvoidance Behavior ---

  // Define parameters for the behavior
  final double maxPredictionTime = 2.0; // How far ahead (seconds) to predict collisions
  final double avoidanceForceMultiplier = 150.0; // Strength of the avoidance force

  print("Creating UnalignedCollisionAvoidance behavior with:");
  print("  Max Prediction Time: $maxPredictionTime");
  print("  Avoidance Force Multiplier: $avoidanceForceMultiplier");

  // Create behavior instances (can be reused, but create one per agent for clarity)
  final avoidanceBehaviorA = UnalignedCollisionAvoidance(
    spatialGrid: spatialGrid,
    maxPredictionTime: maxPredictionTime,
    avoidanceForceMultiplier: avoidanceForceMultiplier,
  );
   final avoidanceBehaviorB = UnalignedCollisionAvoidance(
    spatialGrid: spatialGrid,
    maxPredictionTime: maxPredictionTime,
    avoidanceForceMultiplier: avoidanceForceMultiplier,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 25; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // IMPORTANT: Update the spatial grid each step
    spatialGrid.clear();
    for (final agent in agents) {
      spatialGrid.add(agent);
    }

    // Calculate steering forces first
    final forceA = avoidanceBehaviorA.calculateSteering(agentA);
    final forceB = avoidanceBehaviorB.calculateSteering(agentB);

    // Apply forces to update agents
    agentA.applySteering(forceA, deltaTime);
    agentB.applySteering(forceB, deltaTime);

    // Print agent states and forces
    final distance = agentA.position.distanceTo(agentB.position);
    print("Step ${i + 1}: Dist: ${distance.toStringAsFixed(1)}");
    print("  Agent A: Pos=${agentA.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agentA.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Force: ${forceA.storage.map((e) => e.toStringAsFixed(1)).toList()}");
    print("  Agent B: Pos=${agentB.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agentB.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Force: ${forceB.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agents have passed each other
    // Check if relative velocity points away and distance is increasing
    final relativePos = agentB.position - agentA.position;
    final relativeVel = agentB.velocity - agentA.velocity;
    if (relativePos.dot(relativeVel) > 0 && distance > 50 && i > 5) {
       print("\nAgents appear to have passed each other.");
       break;
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent A Final Position: ${agentA.position.storage.toList()}");
  print("Agent B Final Position: ${agentB.position.storage.toList()}");
  print("----------------------------------");
}