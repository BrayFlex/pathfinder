import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- WallFollowing Steering Behavior ---
// Explanation:
// The Wall Following behavior steers an agent to move parallel to nearby walls
// (represented as WallSegments) while trying to maintain a desired distance.
// It uses virtual "feelers" projected from the agent to detect intersections
// with walls.
//
// 1. Setup: We define one or more ExampleWallSegment instances. We create an agent
//    positioned near a wall, moving roughly parallel to it.
//
// 2. Behavior Creation: We instantiate the WallFollowing behavior, providing the
//    list of walls, a desiredDistance (target distance to maintain), feelerLength
//    (how far to look ahead/sideways), and a wallForceMultiplier (strength of
//    correction). A cast `as List<WallSegment>` is used.
//    (Note: The provided WallFollowing code didn't explicitly use desiredDistance,
//    but it's a standard parameter for this behavior, so included conceptually).
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force using followBehavior.calculateSteering().
//      The behavior projects feelers, checks for intersections with walls. If a
//      feeler hits a wall, a force is calculated primarily along the wall's normal
//      to push the agent away (or potentially pull it closer if too far, depending
//      on implementation details and desiredDistance). A smaller tangential force
//      might also be added to encourage forward movement.
//    - Apply the force to the agent.
//    - Print the agent's state.
//
// 4. Result: The simulation output shows the agent moving along the wall. If it
//    gets too close, the steering force should push it away (e.g., downwards if
//    following the top edge of the horizontal wall). If it gets too far (and the
//    implementation considers desiredDistance), it might steer closer. As it
//    approaches the corner, the feelers hitting the vertical wall should cause it
//    to turn and follow that wall.

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

/// Minimal WallSegment implementation for demonstration purposes.
/// Assumes it has start, end, and normal properties.
/// In the actual library, this would likely be part of obstacle.dart.
class ExampleWallSegment {
  final Vector2 start;
  final Vector2 end;
  late final Vector2 normal; // Normal pointing "outwards" from the wall

  ExampleWallSegment({required this.start, required this.end}) {
    // Calculate normal (assuming clockwise winding for "outside")
    final tangent = (end - start).normalized();
    normal = Vector2(tangent.y, -tangent.x); // Perpendicular vector
  }
}


void main() {
  // --- 1. Setup ---
  print("--- Wall Following Behavior Example ---");

  // Create wall segments
  final walls = [
    // A horizontal wall segment
    ExampleWallSegment(start: Vector2(50.0, 150.0), end: Vector2(350.0, 150.0)),
    // A vertical wall segment connected to the first
    ExampleWallSegment(start: Vector2(350.0, 150.0), end: Vector2(350.0, 300.0)),
  ];
  print("Created ${walls.length} wall segments.");
  print("  Wall 0: ${walls[0].start.storage.toList()} -> ${walls[0].end.storage.toList()}, Normal: ${walls[0].normal.storage.toList()}");
  print("  Wall 1: ${walls[1].start.storage.toList()} -> ${walls[1].end.storage.toList()}, Normal: ${walls[1].normal.storage.toList()}");


  // Create an agent starting near the horizontal wall, moving parallel to it
  final agent = SimpleAgent(
    position: Vector2(70.0, 130.0), // Start below and near the start of the horizontal wall
    velocity: Vector2(60.0, 0.0),  // Moving right, parallel to the wall
    maxSpeed: 60.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create WallFollowing Behavior ---

  // Define parameters for the WallFollowing behavior
  final double desiredDistance = 20.0; // Target distance from the wall
  final double feelerLength = 50.0;    // How far the feelers project
  final double wallForceMultiplier = 80.0; // Strength of the corrective force

  print("Creating WallFollowing behavior with:");
  print("  Desired Distance: $desiredDistance");
  print("  Feeler Length: $feelerLength");
  print("  Force Multiplier: $wallForceMultiplier");

  // Create the WallFollowing behavior instance
  // NOTE: We need to cast our example walls to the type expected.
  // This assumes the library's WallFollowing expects List<WallSegment>.
  final followBehavior = WallFollowing(
    walls: walls as List<WallSegment>, // Cast needed here
    desiredDistance: desiredDistance, // This parameter seems missing in the provided code, assuming it exists conceptually
    feelerLength: feelerLength,
    wallForceMultiplier: wallForceMultiplier,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 60; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force from the WallFollowing behavior
    final steeringForce = followBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state at this step
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()} (Speed: ${agent.velocity.length.toStringAsFixed(1)}), "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Add boundary checks or stop conditions
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}