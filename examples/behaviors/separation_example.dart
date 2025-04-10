import 'package:pathfinder/pathfinder.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:vector_math/vector_math_64.dart';
import 'dart:math';

// --- Separation Steering Behavior ---
// Explanation:
// The Separation behavior steers an agent to move away from its nearby neighbors
// to avoid crowding. It calculates a repulsive force for each neighbor within a
// specified 'desiredSeparation' distance, with the force being stronger for
// closer neighbors.
//
// 1. Setup: We create a SpatialHashGrid and populate it with agents. Crucially,
//    we place several neighbors very close to 'mainAgent', likely within the
//    'desiredSeparation' distance.
//
// 2. Behavior Creation: We instantiate the Separation behavior, providing the
//    spatialGrid and the desiredSeparation distance. Neighbors outside this
//    distance (or optional viewAngle) are ignored.
//
// 3. Simulation: We calculate the steering force for 'mainAgent'. The behavior
//    queries the spatialGrid for neighbors within the desiredSeparation radius.
//    For each close neighbor found, it calculates a repulsive force pointing away
//    from that neighbor. These forces are summed up, and a final steering force
//    is generated to move the agent in the direction of the net repulsion.
//    We apply this force for one time step.
//
// 4. Result: The output shows the calculated force and the agent's state after
//    applying it. Since 'mainAgent' started with close neighbors, the steering
//    force should be non-zero, pushing the agent away from the average position
//    of those close neighbors. The agent's position and velocity reflect this push.
//
// Note: Like other flocking behaviors, accurate simulation requires updating the
// SpatialHashGrid each frame as agents move.

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
  print("--- Separation Behavior Example ---");

  // Define grid parameters
  final double gridCellSize = 30.0; // Should be related to desiredSeparation
  final spatialGrid = SpatialHashGrid(cellSize: gridCellSize);

  // Create agents, placing some very close to the main agent
  final List<SimpleAgent> agents = [];
  final Random random = Random();

  print("Creating agents (some very close)...");
  // Agent 0 (our test agent)
  final mainAgent = SimpleAgent(
    position: Vector2(200.0, 200.0), // Center
    velocity: Vector2(0, 0), // Start stationary
    maxSpeed: 50.0,
    maxForce: 40.0,
  );
  agents.add(mainAgent);

  // Add neighbors very close to the main agent
  for (int i = 0; i < 3; i++) {
    final angle = random.nextDouble() * 2 * pi;
    final distance = random.nextDouble() * 15 + 5; // 5 to 20 units away (likely within separation distance)
    final neighborPos = mainAgent.position + Vector2(cos(angle) * distance, sin(angle) * distance);
    agents.add(SimpleAgent(
      position: neighborPos,
      velocity: Vector2(0, 0), // Stationary neighbors for simplicity
    ));
    print("  Added close neighbor at: ${neighborPos.storage.map((e) => e.toStringAsFixed(1)).toList()} (Dist: ${distance.toStringAsFixed(1)})");
  }
  // Add some distant agents (should be ignored by separation)
  for (int i = 0; i < 5; i++) {
     agents.add(SimpleAgent(
      position: Vector2(random.nextDouble() * 400, random.nextDouble() * 400),
      velocity: Vector2(0, 0),
    ));
  }

  // Add agents to the spatial grid.
  print("Adding agents to SpatialHashGrid...");
  for (final agent in agents) {
    spatialGrid.add(agent);
  }

  print("Agent Initial Position: ${mainAgent.position.storage.toList()}");

  // --- 2. Create Separation Behavior ---

  // Define parameters for the Separation behavior
  final double desiredSeparation = 25.0; // Target minimum distance from neighbors
  final double? viewAngle = null; // Optional: radians. null means 360 view.

  print("Creating Separation behavior with desired separation: $desiredSeparation");

  // Create the Separation behavior instance
  final separationBehavior = Separation(
    spatialGrid: spatialGrid,
    desiredSeparation: desiredSeparation,
    viewAngle: viewAngle,
  );

  // --- 3. Simulation Step (Simplified) ---

  final double deltaTime = 0.1; // Example time step

  print("Calculating steering force for the main agent...");
  // Calculate the steering force from the Separation behavior.
  // This force should push 'mainAgent' away from its close neighbors.
  final steeringForce = separationBehavior.calculateSteering(mainAgent);

  print("Calculated Separation Steering Force: ${steeringForce.storage.toList()}");

  // Apply the steering force to the agent's movement
  print("Applying force and updating agent state (deltaTime: ${deltaTime}s)...");
  mainAgent.applySteering(steeringForce, deltaTime);

  // --- 4. Output / Verification ---

  print("Agent Final Position: ${mainAgent.position.storage.toList()}");
  print("Agent Final Velocity: ${mainAgent.velocity.storage.toList()}");
  print("----------------------------------");
}