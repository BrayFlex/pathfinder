import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

// --- Containment Steering Behavior ---
// Explanation:
// The Containment behavior prevents an agent from leaving a defined boundary
// (in this case, a rectangle). It works by predicting the agent's future position.
// If the predicted position is outside the boundary, it calculates a steering
// force to push the agent back inside.
//
// 1. Setup: We define a rectangular boundary using an example class and create
//    an agent positioned near an edge, moving towards it.
//
// 2. Behavior Creation: We instantiate the Containment behavior, providing the
//    boundary object, a predictionDistance (how far ahead to look), and a
//    forceMultiplier (how strongly to push back). A cast `as RectangleBoundary`
//    is used, assuming our example class matches the expected interface.
//
// 3. Simulation: In a loop, we:
//    - Predict the agent's future position based on its current velocity.
//    - Calculate the steering force using containmentBehavior.calculateSteering().
//      If the predicted position is outside the boundary, this force will be non-zero,
//      pushing the agent away from the edge it's about to cross.
//    - Apply the force to the agent.
//    - Print the agent's state, including the predicted position and the calculated force.
//
// 4. Result: The simulation output shows the agent moving towards the boundary.
//    As its predicted position goes outside, the containment force becomes active
//    (non-zero, likely pointing left in this case), altering the agent's velocity
//    to keep it within the defined area. The agent should "bounce" off or slide
//    along the boundary edge.

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

/// Minimal RectangleBoundary implementation for demonstration purposes.
/// Assumes it has minCorner, maxCorner, position (center), and containsPoint.
/// In the actual library, this would likely be part of obstacle.dart.
class ExampleRectangleBoundary {
  final Vector2 minCorner;
  final Vector2 maxCorner;
  late final Vector2 position; // Center

  ExampleRectangleBoundary(this.minCorner, this.maxCorner) {
     position = (minCorner + maxCorner) * 0.5;
  }

  bool containsPoint(Vector2 point) {
    return point.x >= minCorner.x &&
           point.x <= maxCorner.x &&
           point.y >= minCorner.y &&
           point.y <= maxCorner.y;
  }
}


void main() {
  // --- 1. Setup ---
  print("--- Containment Behavior Example ---");

  // Define the boundary
  final boundaryMin = Vector2(50.0, 50.0);
  final boundaryMax = Vector2(450.0, 350.0);
  // Use the example boundary class defined above
  final boundary = ExampleRectangleBoundary(boundaryMin, boundaryMax);

  print("Boundary defined from ${boundaryMin.storage.toList()} to ${boundaryMax.storage.toList()}");

  // Create an agent starting inside the boundary, moving towards an edge
  final agent = SimpleAgent(
    position: Vector2(400.0, 100.0), // Start near the right edge
    velocity: Vector2(60.0, 10.0),   // Moving right and slightly up
    maxSpeed: 80.0,
    maxForce: 60.0, // Give it a reasonable force to react
  );
  print("Agent Initial Position: ${agent.position.storage.toList()}");
  print("Agent Initial Velocity: ${agent.velocity.storage.toList()}");

  // --- 2. Create Containment Behavior ---

  // Define parameters for the Containment behavior
  final double predictionDistance = 30.0; // How far ahead to check
  final double forceMultiplier = 100.0; // Strength of the push-back force

  print("Creating Containment behavior with prediction: $predictionDistance, multiplier: $forceMultiplier");

  // Create the Containment behavior instance
  // NOTE: We need to cast our example boundary to the type expected by Containment.
  // This assumes the library's Containment expects an object with the necessary
  // properties (minCorner, maxCorner, position, containsPoint).
  // If the library strictly requires `RectangleBoundary` from `obstacle.dart`,
  // this example would need adjustment or `obstacle.dart` would need to be imported/defined.
  final containmentBehavior = Containment(
    boundary: boundary as RectangleBoundary, // Cast needed here
    predictionDistance: predictionDistance,
    forceMultiplier: forceMultiplier,
  );

  // --- 3. Simulation Loop (Simplified) ---

  final double deltaTime = 0.1; // Time step
  final int maxSteps = 30; // Limit simulation steps

  print("\nSimulating agent movement (max $maxSteps steps, dt=$deltaTime):");

  for (int i = 0; i < maxSteps; i++) {
    // Predict future position (for logging purposes)
    final futurePosition = agent.position + (agent.velocity.normalized() * predictionDistance);
    final isPredictionInside = boundary.containsPoint(futurePosition);

    // Calculate the steering force from the Containment behavior
    final steeringForce = containmentBehavior.calculateSteering(agent);

    // Apply the steering force to the agent's movement
    agent.applySteering(steeringForce, deltaTime);

    // Print agent state and prediction info
    print("Step ${i + 1}: Pos=${agent.position.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "Vel=${agent.velocity.storage.map((e) => e.toStringAsFixed(1)).toList()}, "
          "PredPos: ${futurePosition.storage.map((e) => e.toStringAsFixed(1)).toList()} (Inside: $isPredictionInside), "
          "Force: ${steeringForce.storage.map((e) => e.toStringAsFixed(1)).toList()}");

    // Optional: Stop if agent is pushed back significantly or stops
    if (steeringForce.length > 1.0 && agent.velocity.length < 1.0 && i > 5) {
       // print("\nAgent stopped or pushed back significantly.");
       // break;
    }
  }

  // --- 4. Output / Verification ---
  print("\nSimulation finished.");
  print("Agent Final Position: ${agent.position.storage.toList()}");
  print("Agent Final Velocity: ${agent.velocity.storage.toList()}");
  print("----------------------------------");
}