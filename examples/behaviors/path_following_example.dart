import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- PathFollowing Steering Behavior ---
// Explanation:
// The Path Following behavior guides an agent along a predefined sequence of
// connected line segments (a Path). It tries to keep the agent within a defined
// radius of the path and encourages progression towards the path's end.
//
// 1. Setup: We define a series of waypoints and create a Path object using them,
//    specifying a radius for the path corridor. We create an agent near the start.
//
// 2. Behavior Creation: We instantiate the PathFollowing behavior, providing the
//    Path object and a predictionDistance. This distance determines how far ahead
//    on the path the agent targets, influencing how it anticipates turns.
//
// 3. Simulation: In a loop, we:
//    - Calculate the steering force using followBehavior.calculateSteering().
//      The behavior predicts the agent's future position, finds the closest point
//      on the path to that prediction, and calculates a target point further along
//      the path. It then generates a steering force (using Seek logic) towards
//      this future path target, or back towards the path spine if the agent is too far off.
//    - Apply the force to the agent.
//    - Print the agent's state and optionally debug info from the behavior
//      (like the current target segment).
//
// 4. Result: The simulation output shows the agent moving along the defined path.
//    It should navigate the turns defined by the waypoints. If it starts off the
//    path, it should steer back towards it. The predictionDistance affects how
//    smoothly it takes corners (larger values might cut corners more).

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

// Note: Using the actual Path class from the library
// import 'package:pathfinder/src/path.dart'; // Assuming path.dart exists

void main() {
  // --- 1. Setup ---
  print("--- Path Following Behavior Example ---");

  // Define the waypoints for the path
  final waypoints = [
    Vector2(50.0, 50.0),
    Vector2(300.0, 80.0),
    Vector2(400.0, 250.0),
    Vector2(100.0, 300.0),
  ];
  final double pathRadius = 15.0; // How wide the path corridor is
  final bool loopPath = false; // Should the path loop back to the start?

  // Create the Path object using the 'points' parameter
  final path = Path(points: waypoints, radius: pathRadius, loop: loopPath);
  print("Created Path with ${path.points.length} waypoints and radius $pathRadius.");

  // Create an agent starting near the beginning of the path
  final agent = SimpleAgent(
    position: Vector2(40.0, 60.0), // Start slightly off the first waypoint
    velocity: Vector2(50.0, 0.0),  // Initial velocity somewhat along the first segment
    maxSpeed: 70.0,
    maxForce: 40.0,
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create PathFollowing Behavior ---

  // Define parameters for the PathFollowing behavior
  final double predictionDistance = 25.0; // How far ahead to predict/target along the path

  print("Creating PathFollowing behavior with prediction distance: $predictionDistance");

  // Create the PathFollowing behavior instance
  final followBehavior = PathFollowing(
    path: path,
    predictionDistance: predictionDistance,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 80; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Calculate the steering force from the PathFollowing behavior
    final steeringForce = followBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Get debug info from the behavior
    final closestPoint = followBehavior.debugLastClosestPoint;
    final currentSegment = followBehavior.debugCurrentSegmentIndex;

    // Print agent state and path following info
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "TargetSegment: $currentSegment, "
          // "ClosestPt: ${closestPoint.storage.map((e) => e.toStringAsFixed(1)).toList()}, " // Uncomment for more debug
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent reaches near the end of a non-looping path
    // Access the points list via the 'points' getter
    if (!path.loop && agent.position.distanceToSquared(path.points.last) < (pathRadius * pathRadius * 4)) {
       print("\nAgent is near the end of the path.");
       // break; // Uncomment to stop simulation early
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}