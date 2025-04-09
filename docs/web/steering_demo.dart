/// Logic for the interactive steering behaviors demo page.
///
/// This file sets up the canvas, agents, obstacles, paths, and UI controls
/// to demonstrate various steering behaviors provided by the `pathfinder` package.
/// It includes:
/// - Configuration constants.
/// - A `DemoAgent` class implementing the `Agent` interface.
/// - A `CustomContainment` behavior extending the base `Containment`.
/// - Descriptions for each behavior.
/// - The main `SteeringDemo` class managing the simulation loop, UI, and scenarios.
/// - Scenario setup functions for each behavior.
/// - UI control generation logic.
/// - The main entry point `setupSteeringDemo`.

import 'dart:js_interop'; // Needed for JS types like JSString, JSNumber, etc.
import 'package:web/web.dart' as web; // Use prefix 'web' to avoid collisions
import 'dart:math' as math;

import 'package:pathfinder/pathfinder.dart'; // Main package export
// Specific imports needed for this demo
import 'package:pathfinder/src/pathfinding/finders/dijkstra_finder.dart';
import 'package:pathfinder/src/pathfinding/grid.dart';
import 'package:pathfinder/src/pathfinding/node.dart' as pf; // Use prefix 'pf'
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:vector_math/vector_math_64.dart';
// --- Configuration ---
const double canvasWidth = 800;
const double canvasHeight = 600;
const double defaultAgentRadius = 10.0;
const String defaultBehavior = 'Seek';

// --- Helper Functions ---
/// Generates a random Vector2 within the specified bounds.
Vector2 randomVector2(double minX, double maxX, double minY, double maxY) {
  final random = math.Random();
  return Vector2(
    minX + random.nextDouble() * (maxX - minX),
    minY + random.nextDouble() * (maxY - minY),
  );
}

// --- Demo Agent ---
/// Represents an agent in the steering demo, implementing the [Agent] interface.
///
/// This class holds the agent's state (position, velocity, etc.), manages its
/// steering behaviors via a [SteeringManager], and handles drawing itself on the canvas.
class DemoAgent implements Agent {
  final web.CanvasRenderingContext2D ctx;
  String color = 'blue'; // Default color

  // Agent state variables - implementing the Agent interface
  @override
  Vector2 position; // Current position vector.
  @override
  Vector2 velocity = Vector2.zero(); // Current velocity vector.

  // Make properties mutable for UI control
  @override
  double maxSpeed; // Maximum speed the agent can travel (pixels/second).
  @override
  double maxForce; // Maximum steering force the agent can apply.
  @override
  double mass; // Mass of the agent, affecting acceleration.
  @override
  double radius; // Radius of the agent, used for drawing and separation.

  // Steering manager for this agent
  /// Manages the steering behaviors attached to this agent.
  late final SteeringManager steeringManager;

  // Store references to behaviors AND their weights for easy access/modification
  /// Stores references to active behaviors and their weights for easy access and modification.
  final Map<Type, ({SteeringBehavior behavior, double weight})> activeBehaviors = {};

  DemoAgent({
    required this.ctx,
    required this.position,
    this.radius = defaultAgentRadius,
    this.mass = 1.0,
    this.maxSpeed = 150.0, // pixels per second
    this.maxForce = 200.0, // magnitude of steering force
  }) {
    // Initialize the steering manager, passing this agent instance
    steeringManager = SteeringManager(this);
  }

  /// Adds a steering behavior to the agent's [SteeringManager] and tracks it locally.
  void addBehavior(SteeringBehavior behavior, {double weight = 1.0}) {
      steeringManager.add(behavior, weight: weight);
      activeBehaviors[behavior.runtimeType] = (behavior: behavior, weight: weight);
  }

  /// Removes a steering behavior of the specified type [T] from the agent.
  void removeBehavior<T extends SteeringBehavior>() {
      final record = activeBehaviors.remove(T);
      if (record != null) {
          steeringManager.remove(record.behavior);
      }
  }

  /// Gets the active steering behavior of the specified type [T], if present.
  T? getBehavior<T extends SteeringBehavior>() {
      return activeBehaviors[T]?.behavior as T?;
  }

  /// Gets the weight of the active steering behavior of the specified type [T].
  /// Defaults to 1.0 if the behavior is not found.
  double getBehaviorWeight<T extends SteeringBehavior>() {
      return activeBehaviors[T]?.weight ?? 1.0; // Default to 1.0 if not found
  }

  /// Removes all steering behaviors from the agent.
  void clearBehaviors() {
      steeringManager.clear();
      activeBehaviors.clear();
  }

/// Draws the agent on the canvas.
void draw() {
    // Draw body
    ctx.beginPath();
    ctx.arc(position.x, position.y, radius, 0, math.pi * 2);
    ctx.fillStyle = color.toJS; // Cast to JSAny (JSString is a subtype)
    ctx.fill();
    ctx.strokeStyle = 'black'.toJS; // Cast to JSAny
    ctx.lineWidth = 1;
    ctx.stroke();

    // Draw velocity vector (optional, for debugging/visualization)
    if (velocity.length2 > 0.01) { // Use length2 for efficiency
      ctx.beginPath();
      ctx.moveTo(position.x, position.y);
      // Scale velocity for visibility
      final heading = velocity.normalized();
      ctx.lineTo(position.x + heading.x * radius * 1.5, position.y + heading.y * radius * 1.5);
      ctx.strokeStyle = 'red'.toJS; // Cast to JSAny
      ctx.lineWidth = 2;
      ctx.stroke();
    }
  }

  /// Applies the calculated steering force to update the agent's velocity and position.
  /// This method is called by the [SteeringManager] after calculating the combined force.
  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // Apply standard physics: acceleration = force / mass
    // Ensure mass is not zero to avoid division errors
    final acceleration = (mass > 0.0001) ? steeringForce / mass : Vector2.zero();

    // Update velocity: v = u + at
    velocity.add(acceleration * deltaTime);

    // Clamp velocity to maxSpeed
    if (velocity.length2 > maxSpeed * maxSpeed) {
      velocity.normalize();
      velocity.scale(maxSpeed);
    }

    // Update position: s = s + vt
    position.add(velocity * deltaTime);

    // Bounds checking is now handled by the Containment behavior where needed
  }
}

// --- Custom Containment Behavior ---
/// A custom containment behavior that applies an increasingly stronger force
/// the further the agent moves outside the defined boundary.
///
/// This provides a "softer" boundary compared to the standard `Containment`
/// which might apply maximum force immediately.
class CustomContainment extends Containment {
  /// Factor determining how much the containment force increases per pixel
  /// the agent penetrates beyond the boundary.
  final double forceMultiplierIncrease;

  // Constructor using super-parameters for Containment fields
  CustomContainment({
    required super.boundary,
    super.predictionDistance = 30.0,
    this.forceMultiplierIncrease = 0.5, // Initialize its own field
  }); // No need for ': super()' when using super-parameters

  /// Calculates the containment force based on predicted future position.
  /// The force magnitude increases proportionally to the penetration depth.
  @override
  Vector2 calculateForce(Agent agent, double deltaTime) {
    Vector2 steeringForce = Vector2.zero();
    // Predict future position slightly ahead
    // Use a fraction of predictionDistance for responsiveness, adjust as needed
    Vector2 futurePosition = agent.position + (agent.velocity * predictionDistance * 0.1); // Shorter prediction horizon

    // Check X bounds
    if (futurePosition.x < boundary.minCorner.x) {
      double penetration = boundary.minCorner.x - futurePosition.x;
      // Apply force proportional to penetration, scaled by agent's maxSpeed/maxForce
      // Ensure force points inwards (positive X)
      steeringForce.x = agent.maxForce * (penetration / agent.radius) * forceMultiplierIncrease;
    } else if (futurePosition.x > boundary.maxCorner.x) {
      double penetration = futurePosition.x - boundary.maxCorner.x;
      // Ensure force points inwards (negative X)
      steeringForce.x = -agent.maxForce * (penetration / agent.radius) * forceMultiplierIncrease;
    }

    // Check Y bounds
    if (futurePosition.y < boundary.minCorner.y) {
      double penetration = boundary.minCorner.y - futurePosition.y;
      // Ensure force points inwards (positive Y)
      steeringForce.y = agent.maxForce * (penetration / agent.radius) * forceMultiplierIncrease;
    } else if (futurePosition.y > boundary.maxCorner.y) {
      double penetration = futurePosition.y - boundary.maxCorner.y;
      // Ensure force points inwards (negative Y)
      steeringForce.y = -agent.maxForce * (penetration / agent.radius) * forceMultiplierIncrease;
    }


    return steeringForce;
  }
}


// --- Behavior Descriptions ---
/// Provides textual descriptions and interaction hints for each steering behavior.
final Map<String, ({String description, String interaction})> behaviorInfo = {
  'Seek': (
    description: 'Agent moves towards a target position.',
    interaction: 'Click on the canvas to set the target position (green circle).'
  ),
  'Flee': (
    description: 'Agent moves away from a target position.',
    interaction: 'Click on the canvas to set the flee target position (green circle).'
  ),
  'Arrival': (
    description: 'Agent moves towards a target position, slowing down as it approaches.',
    interaction: 'Click on the canvas to set the target position (green circle).'
  ),
  'Wander': (
    description: 'Agent moves randomly using a projected circle and target displacement.',
    interaction: 'No user interaction.'
  ),
  'Pursuit': (
    description: 'Agent (red) predicts the future position of a target agent (green) and intercepts it.',
    interaction: 'No user interaction.'
  ),
  'Evade': (
    description: 'Agent (blue) predicts the future position of a pursuer (red) and moves away.',
    interaction: 'No user interaction.'
  ),
  'Offset Pursuit': (
    description: 'Agent (purple) maintains a specific offset position relative to a leader agent (green).',
    interaction: 'No user interaction.'
  ),
  'Obstacle Avoidance': (
    description: 'Agent attempts to steer around obstacles (grey circles) while moving towards a target.',
    interaction: 'Click on the canvas to set the seek target position (green circle).'
  ),
  'Path Following': (
    description: 'Agent follows a predefined path (purple line).',
    interaction: 'No user interaction.'
  ),
  'Wall Following': (
    description: 'Agent attempts to follow along walls (black lines) maintaining a set distance.',
    interaction: 'No user interaction.'
  ),
  'Containment': (
    description: 'Agent is kept within defined boundaries (light grey rectangle). Force increases further outside.',
    interaction: 'No user interaction.'
  ),
  'Flow Field Following': (
    description: 'Agent follows vectors defined in a flow field. (Demo field points towards the bottom right).',
    interaction: 'No user interaction.'
  ),
  'Unaligned Collision Avoidance': (
    description: 'Placeholder demo showing multiple agents wandering. Separation is used to prevent overlap, but true Unaligned Collision Avoidance (like RVO) is not implemented.',
    interaction: 'No user interaction.'
  ),
  'Separation': (
    description: 'Agents steer to avoid crowding local flockmates.',
    interaction: 'No user interaction.'
  ),
  'Cohesion': (
    description: 'Agents steer to move toward the average position of local flockmates.',
    interaction: 'No user interaction.'
  ),
  'Alignment': (
    description: 'Agents steer towards the average heading of local flockmates.',
    interaction: 'No user interaction.'
  ),
  'Flocking': (
    description: 'Combines Separation, Cohesion, and Alignment to simulate flocking behavior.',
    interaction: 'No user interaction.'
  ),
  'Leader Following': (
    description: 'Agents (teal) follow a leader agent (orange), maintaining position and avoiding crowding.',
    interaction: 'No user interaction.'
  ),
};

// --- Main Demo Class ---
/// Manages the overall steering behavior demonstration, including the canvas,
/// UI elements, agents, obstacles, and the main simulation loop.
class SteeringDemo {
  late web.HTMLCanvasElement canvas;
  late web.CanvasRenderingContext2D ctx;
  late web.HTMLSelectElement behaviorSelector;
  late web.HTMLDivElement parameterPanel; // This is the inner panel for parameters
  late web.HTMLDivElement controlsPanel; // This is the main #controls container
  late web.HTMLButtonElement resetButton;
  late web.HTMLButtonElement paramsToggleButton; // Button to toggle overlay
  late web.HTMLInputElement randomizeParamsCheckbox; // Checkbox for randomization
  late web.HTMLDivElement agentRandomizationControl; // Container for the checkbox

  List<DemoAgent> agents = [];
  List<CircleObstacle> obstacles = []; // Specify type for clarity
  Path? currentPath;
  SpatialHashGrid? spatialGrid; // For optimizing flocking/separation
  Vector2? targetPosition; // For behaviors like Seek, Flee, Arrival
  DemoAgent? targetAgent; // For behaviors like Pursuit, Evade
  RectangleBoundary? worldBoundary; // Renamed for clarity
  List<WallSegment> walls = [];
  FlowField? flowField; // For Flow Field Following demo

  // Store original parameters for randomization reset
  final Map<DemoAgent, ({double maxSpeed, double maxForce, double mass, double radius})> _originalAgentParams = {};

  String currentBehavior = defaultBehavior;
  double _lastTimestamp = 0;

  SteeringDemo() {
    canvas = web.document.querySelector('#steeringCanvas') as web.HTMLCanvasElement;
    ctx = canvas.getContext('2d') as web.CanvasRenderingContext2D;
    behaviorSelector = web.document.querySelector('#behaviorSelector') as web.HTMLSelectElement;
    parameterPanel = web.document.querySelector('#parameterPanel') as web.HTMLDivElement;
    controlsPanel = web.document.querySelector('#controls') as web.HTMLDivElement; // Get the main container
    resetButton = web.document.querySelector('#resetButton') as web.HTMLButtonElement;
    paramsToggleButton = web.document.querySelector('#paramsToggleButton') as web.HTMLButtonElement;
    randomizeParamsCheckbox = web.document.querySelector('#randomizeParamsCheckbox') as web.HTMLInputElement;
    agentRandomizationControl = web.document.querySelector('#agentRandomizationControl') as web.HTMLDivElement;

    // Set canvas dimensions explicitly
    // Use JSNumber for width/height
    canvas.width = canvasWidth.toInt(); // Assign int directly
    canvas.height = canvasHeight.toInt(); // Assign int directly

    _setupEventHandlers();
    _selectBehavior(currentBehavior); // Initialize with default behavior
    _startAnimationLoop();
  }

  /// Sets up event listeners for UI elements (dropdown, buttons, canvas clicks).
  void _setupEventHandlers() {
    behaviorSelector.onChange.listen((web.Event _) { // Use web.Event
      _selectBehavior(behaviorSelector.value ?? defaultBehavior);
    });

    resetButton.onClick.listen((web.MouseEvent _) { // Use web.MouseEvent
      // Reset parameters for the current behavior's scenario
      _setupScenario(currentBehavior, resetParams: true);
      _updateParameterControls(); // Rebuild controls with default values
    });

    // Add mouse click listener to update target for relevant behaviors
    canvas.onClick.listen((web.MouseEvent event) { // Use web.MouseEvent
       if (['Seek', 'Flee', 'Arrival', 'Obstacle Avoidance'].contains(currentBehavior)) {
           targetPosition = Vector2(event.offsetX.toDouble(), event.offsetY.toDouble()); // Use offsetX/Y
           // Update mutable target property on relevant behaviors
           if (agents.isNotEmpty) {
               final agent = agents.first; // Assume single agent for these behaviors
               agent.getBehavior<Seek>()?.target = targetPosition!;
               agent.getBehavior<Flee>()?.target = targetPosition!;
               agent.getBehavior<Arrival>()?.target = targetPosition!;
               // Obstacle avoidance often uses seek, update its target indirectly if needed
               agent.getBehavior<Seek>()?.target = targetPosition!; // Re-set seek target if OA is active
           }
       }
    });

    // Add event listener for the parameters toggle button
    paramsToggleButton.onClick.listen((web.MouseEvent _) { // Use web.MouseEvent
        controlsPanel.classList.toggle('visible'); // Use classList
    });

    // Add event listener for the randomization checkbox
    randomizeParamsCheckbox.onChange.listen((web.Event _) { // Use web.Event
        _applyAgentParameterRandomization();
    });
  }

/// Handles the selection of a new behavior from the dropdown.
/// Clears the current scenario, sets up the new one, and updates UI controls.
void _selectBehavior(String behaviorName) {
    currentBehavior = behaviorName;
    behaviorSelector.value = currentBehavior; // Ensure dropdown reflects selection
    _setupScenario(currentBehavior, resetParams: true); // Setup and reset params
    _updateParameterControls();
  }

  /// Clears all agents, obstacles, paths, and targets from the current scenario.
  void _clearScenario() {
    // Clear behaviors from existing agents before clearing the list
    _originalAgentParams.clear(); // Clear stored original params
    for (final agent in agents) {
        agent.clearBehaviors();
    }
    agents.clear();
    obstacles.clear();
    walls.clear();
    currentPath = null;
    targetPosition = null;
    targetAgent = null;
    worldBoundary = null;
    flowField = null; // Clear flow field
    spatialGrid = null; // Clear grid
  }

  /// Sets up the specific agents, obstacles, targets, and behaviors for the selected [behaviorName].
  /// If [resetParams] is true, it also resets behavior parameters to their defaults.
  void _setupScenario(String behaviorName, {bool resetParams = false}) {
    _clearScenario();

    // Default world boundary for most scenarios
    worldBoundary = RectangleBoundary(
        minCorner: Vector2.zero(),
        maxCorner: Vector2(canvasWidth, canvasHeight)
    );

    // --- Scenario Definitions ---
    switch (behaviorName) {
      case 'Seek':
        targetPosition = Vector2(canvasWidth * 0.75, canvasHeight / 2);
        final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth * 0.25, canvasHeight / 2));
        agent.addBehavior(Seek(target: targetPosition!));
        agents.add(agent);
        break;

      case 'Flee':
         targetPosition = Vector2(canvasWidth / 2, canvasHeight / 2);
         final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth * 0.25, canvasHeight / 2));
         agent.addBehavior(Flee(target: targetPosition!));
         // Add inner containment boundary for Flee
         final fleeBoundary = RectangleBoundary(
             minCorner: Vector2(50, 50), // Margin from edges
             maxCorner: Vector2(canvasWidth - 50, canvasHeight - 50)
         );
         agent.addBehavior(CustomContainment(boundary: fleeBoundary), weight: 2.0); // Give containment higher weight
         agents.add(agent);
         break;

      case 'Arrival':
        targetPosition = Vector2(canvasWidth * 0.75, canvasHeight / 2);
        final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth * 0.25, canvasHeight / 2));
        agent.addBehavior(Arrival(
            target: targetPosition!,
            slowingRadius: 100.0 // Needs slowing radius
        ));
        agents.add(agent);
        break;

      case 'Wander':
        final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth / 2, canvasHeight / 2));
        agent.addBehavior(Wander(
            circleDistance: 50.0,
            circleRadius: 25.0,
            angleChangePerSecond: math.pi // Radians per second (180 degrees)
        ));
        // Add containment to keep it roughly on screen
        agent.addBehavior(CustomContainment(boundary: worldBoundary!));
        agents.add(agent);
        break;

       case 'Pursuit':
         targetAgent = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.7, canvasHeight * 0.7),
             maxSpeed: 100.0 // Slower target
         )..color = 'green';
         // Target agent just wanders slowly
         targetAgent!.addBehavior(Wander(
             circleDistance: 40.0,
             circleRadius: 20.0,
             angleChangePerSecond: math.pi / 2
         ));
         targetAgent!.addBehavior(CustomContainment(boundary: worldBoundary!));

         final pursuer = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.3, canvasHeight * 0.3)
         )..color = 'red';
         pursuer.addBehavior(Pursuit(
             targetAgent: targetAgent!,
             // predictionTime is handled internally based on distance and speeds
         ));
         pursuer.addBehavior(CustomContainment(boundary: worldBoundary!));

         agents.add(pursuer);
         agents.add(targetAgent!); // Add target to be updated and drawn
         break;

       case 'Evade':
         targetAgent = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.3, canvasHeight * 0.3),
              maxSpeed: 120.0 // Faster pursuer
         )..color = 'red';
         // Pursuer just seeks the center (or could wander)
         targetAgent!.addBehavior(Seek(target: Vector2(canvasWidth/2, canvasHeight/2)));
         targetAgent!.addBehavior(CustomContainment(boundary: worldBoundary!));


         final evader = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.6, canvasHeight * 0.6)
         )..color = 'blue';
         evader.addBehavior(Evade(
             targetAgent: targetAgent!,
             // predictionTime handled internally
         ));
         evader.addBehavior(CustomContainment(boundary: worldBoundary!));

         agents.add(evader);
         agents.add(targetAgent!); // Add target to be updated and drawn
         break;

       case 'Offset Pursuit':
         targetAgent = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.7, canvasHeight * 0.7),
             maxSpeed: 100.0
         )..color = 'green';
         // Leader wanders
         targetAgent!.addBehavior(Wander(
             circleDistance: 60.0,
             circleRadius: 30.0,
             angleChangePerSecond: math.pi * 0.8
         ));
         targetAgent!.addBehavior(CustomContainment(boundary: worldBoundary!));

         final follower = DemoAgent(
             ctx: ctx,
             position: Vector2(canvasWidth * 0.3, canvasHeight * 0.3)
         )..color = 'purple';
         // Follow slightly behind and to the left
         follower.addBehavior(OffsetPursuit(
             targetAgent: targetAgent!,
             offset: Vector2(-50, 0) // Offset is relative to leader's orientation
         ));
         // Arrival is implicitly handled within OffsetPursuit
         follower.addBehavior(CustomContainment(boundary: worldBoundary!));


         agents.add(follower);
         agents.add(targetAgent!);
         break;

      case 'Obstacle Avoidance':
        // Add some obstacles
        obstacles.add(CircleObstacle(position: Vector2(canvasWidth * 0.4, canvasHeight / 2), radius: 30));
        obstacles.add(CircleObstacle(position: Vector2(canvasWidth * 0.6, canvasHeight * 0.2), radius: 40));
        obstacles.add(CircleObstacle(position: Vector2(canvasWidth * 0.7, canvasHeight * 0.7), radius: 25));

        final agent = DemoAgent(ctx: ctx, position: Vector2(50, canvasHeight / 1.5));
        // Agent seeks a target on the other side
        targetPosition = Vector2(canvasWidth - 50, canvasHeight / 6);
        agent.addBehavior(Seek(target: targetPosition!));
        // Add Obstacle Avoidance
        agent.addBehavior(ObstacleAvoidance(
            obstacles: obstacles,
            detectionBoxLength: 90.0, // Example value
            avoidanceForceMultiplier: 300.0 // Example value
        ), weight: 2.5); // Give ObstacleAvoidance higher weight
        // NOTE: Removed setting initial velocity directly. Let Seek behavior handle it.
        // Explicitly set target on Seek behavior instance after creation (like click handler)
        agent.getBehavior<Seek>()?.target = targetPosition!;
        agents.add(agent);
        break;

      case 'Path Following':
         // Create a simple path
         currentPath = Path(points: [
             Vector2(canvasWidth * 0.1, canvasHeight * 0.2),
             Vector2(canvasWidth * 0.4, canvasHeight * 0.8),
             Vector2(canvasWidth * 0.8, canvasHeight * 0.3),
             Vector2(canvasWidth * 0.9, canvasHeight * 0.9),
         ], loop: false, radius: 20.0); // Path radius

         final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth * 0.1, canvasHeight * 0.1));
         agent.addBehavior(PathFollowing(
             path: currentPath!,
             predictionDistance: 50.0 // How far ahead to look on the path
         ));
         // Give the agent a small initial velocity towards the first path point
         if (currentPath!.points.isNotEmpty) {
             agent.velocity = (currentPath!.points.first - agent.position).normalized() * 1.0;
         }
         agents.add(agent);
         break;

       case 'Wall Following':
         // Create some walls (e.g., a box)
         walls.add(WallSegment(start: Vector2(100, 100), end: Vector2(canvasWidth - 100, 100))); // Top
         walls.add(WallSegment(start: Vector2(canvasWidth - 100, 100), end: Vector2(canvasWidth - 100, canvasHeight - 100))); // Right
         walls.add(WallSegment(start: Vector2(canvasWidth - 100, canvasHeight - 100), end: Vector2(100, canvasHeight - 100))); // Bottom
         walls.add(WallSegment(start: Vector2(100, canvasHeight - 100), end: Vector2(100, 100))); // Left

         final agent = DemoAgent(ctx: ctx, position: Vector2(150, 150));
         agent.addBehavior(WallFollowing(
             walls: walls,
             desiredDistance: 15.0,
             feelerLength: 60.0, // Reverted default feeler length
             wallForceMultiplier: 1000.0 // Updated default wall force
         ));
         // Add a slight wander tendency to prevent getting stuck perfectly parallel
         agent.addBehavior(Wander(
             circleDistance: 10.0,
             circleRadius: 5.0,
             angleChangePerSecond: math.pi * 1.5, // More jittery wander
         ), weight: 0.2); // Lower weight
         agents.add(agent);
         break;

      case 'Containment':
         worldBoundary = RectangleBoundary(minCorner: Vector2(100, 100), maxCorner: Vector2(canvasWidth - 100, canvasHeight - 100)); // Smaller box
         final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth / 2, canvasHeight / 2));
         // Agent just wanders
         agent.addBehavior(Wander(
             circleDistance: 50.0,
             circleRadius: 25.0,
             angleChangePerSecond: math.pi
         ));
         // Add Containment behavior
         agent.addBehavior(CustomContainment(
             boundary: worldBoundary!,
             predictionDistance: 30.0 // How far ahead to look for boundary
         ));
         agents.add(agent);
         break;

       // --- Flocking Behaviors ---
       case 'Separation':
       case 'Cohesion':
       case 'Alignment':
       case 'Flocking':
         _setupFlockingScenario(behaviorName);
         break;

       case 'Leader Following':
         _setupLeaderFollowingScenario();
         break;

      case 'Flow Field Following':
        // --- Generate Flow Field using Dijkstra ---
        // This demonstrates creating a vector field that guides agents towards a target,
        // navigating around obstacles defined in a separate pathfinding grid.
        final fieldColumns = (canvasWidth / 20).ceil(); // Grid cells for pathfinding
        final fieldRows = (canvasHeight / 20).ceil();
        final fieldCellSize = canvasWidth / fieldColumns; // Match flow field cell size

        // 1. Create a Grid for pathfinding (used to calculate costs).
        final grid = Grid(fieldColumns, fieldRows);
        // Add some simple obstacles to the grid for a more interesting field
        for(int i = fieldColumns ~/ 4; i < fieldColumns * 3 ~/ 4; i++) {
            grid.setWalkableAt(i, fieldRows ~/ 2, false);
            if (i % 5 == 0) grid.setWalkableAt(i, fieldRows ~/ 2 -1, false); // Add gaps
        }
         for(int i = fieldRows ~/ 4; i < fieldRows * 3 ~/ 4; i++) {
            grid.setWalkableAt(fieldColumns ~/ 2, i, false);
             if (i % 5 == 0) grid.setWalkableAt(fieldColumns ~/ 2 -1, i, false);
        }

        // 2. Define the target cell for the flow field (where agents should converge).
        final targetCol = fieldColumns - 2; // Avoid edge
        final targetRow = fieldRows - 2;
        if (!grid.isWalkableAt(targetCol, targetRow)) {
            grid.setWalkableAt(targetCol, targetRow, true); // Ensure target is walkable
            // print("Warning: Flow field target cell was unwalkable, made walkable."); // Keep commented out unless debugging
            // print("Warning: Flow field target cell was unwalkable, made walkable.");
        }

        // 3. Run Dijkstra starting FROM the target cell. The 'g' cost calculated by
        //    Dijkstra represents the cost to reach that cell FROM the target.
        //    Lower 'g' cost means closer to the target.
        final dijkstra = DijkstraFinder(allowDiagonal: true); // Allow diagonal for smoother flow
        // We don't need the path, just the side effect of setting g-costs on the grid nodes
        // findPath returns List<Node?>, need to handle potential nulls if used
        dijkstra.findPath(targetCol, targetRow, 0, 0, grid); // Start=target, End=dummy(0,0)

        // 4. Create the FlowField object to store the calculated vectors.
        flowField = FlowField(
          origin: Vector2.zero(),
          cellSize: fieldCellSize,
          columns: fieldColumns,
          rows: fieldRows,
        );

        // 5. Populate the FlowField: For each cell in the flow field grid...
        for (int r = 0; r < fieldRows; r++) {
          for (int c = 0; c < fieldColumns; c++) {
            final currentNode = grid.getNodeAt(c, r); // Returns pf.Node?
            if (currentNode == null || !currentNode.isWalkable) { // Add null check
              flowField!.setFlow(c, r, Vector2.zero()); // No flow in obstacles
              continue;
            }

            pf.Node? bestNeighbor; // Use pf.Node
            // Use double.infinity for initial minCost comparison
            double minCost = double.infinity;

            // Check neighbors (including diagonal) in the pathfinding grid.
            // Ensure type argument is correct for the list
            final neighbors = currentNode == null ? <pf.Node?>[] : grid.getNeighbors(currentNode, allowDiagonal: true, dontCrossCorners: true);
            for (final neighbor in neighbors) {
              // Find the neighbor with the lowest 'g' cost (closest to the target).
              if (neighbor != null && neighbor.isWalkable && neighbor.g >= 0 && neighbor.g < minCost) { // Add null check
                minCost = neighbor.g;
                bestNeighbor = neighbor; // Already pf.Node?
              }
            }

            Vector2 flowDirection;
            if (bestNeighbor != null) {
              // Set the flow vector for the current cell to point towards the
              // center of the best (lowest cost) neighbor cell.
              final currentCellCenter = Vector2((c + 0.5) * fieldCellSize, (r + 0.5) * fieldCellSize);
              final bestNeighborCenter = Vector2((bestNeighbor.x + 0.5) * fieldCellSize, (bestNeighbor.y + 0.5) * fieldCellSize);
              flowDirection = (bestNeighborCenter - currentCellCenter).normalized();
            } else {
                // If no better neighbor (e.g., target cell or unreachable), flow is zero.
                flowDirection = Vector2.zero();
            }
            flowField!.setFlow(c, r, flowDirection);
          }
        }
        // --- End Flow Field Generation ---

        // 6. Add agents to the scenario.
        final numAgents = 20;
        for (int i = 0; i < numAgents; i++) {
            final agent = DemoAgent(
                ctx: ctx,
                position: randomVector2(50, canvasWidth - 50, 50, canvasHeight - 50),
                radius: 6.0,
                maxSpeed: 120.0,
                maxForce: 180.0
            );
            // Ensure agent doesn't start inside an obstacle used for pathfinding
            final agentGridX = (agent.position.x / fieldCellSize).floor();
            final agentGridY = (agent.position.y / fieldCellSize).floor();
            if (!grid.isWalkableAt(agentGridX, agentGridY)) {
                // Simple reposition - might need refinement
                agent.position = randomVector2(50, canvasWidth - 50, 50, canvasHeight - 50);
            }

            agent.addBehavior(FlowFieldFollowing(
                flowField: flowField!,
                predictionDistance: fieldCellSize * 0.6 // Predict slightly ahead
            ));
            agent.addBehavior(CustomContainment(boundary: worldBoundary!));
            agents.add(agent);
        }
        break;


      case 'Unaligned Collision Avoidance':
        // NOTE: True Unaligned Collision Avoidance (like RVO/VO) is complex.
        // This demo uses Separation to prevent overlap while agents wander.
        // print("Warning: Unaligned Collision Avoidance demo uses Separation, not true UCA."); // Keep commented out
        // print("Warning: Unaligned Collision Avoidance demo uses Separation, not true UCA.");
        final numAgents = 15;
        worldBoundary = RectangleBoundary(minCorner: Vector2(50, 50), maxCorner: Vector2(canvasWidth - 50, canvasHeight - 50));
        // Setup spatial grid for Separation
        final separationCellSize = 30.0; // Adjust based on agent radius + desired separation
        spatialGrid = SpatialHashGrid(cellSize: separationCellSize);

        for (int i = 0; i < numAgents; i++) {
            final agent = DemoAgent(
                ctx: ctx,
                position: randomVector2(100, canvasWidth - 100, 100, canvasHeight - 100),
                radius: 8.0,
                maxSpeed: 100.0 + math.Random().nextDouble() * 50, // Slight speed variation
                maxForce: 150.0
            );
            agent.addBehavior(Wander(
                circleDistance: 40.0,
                circleRadius: 20.0,
                angleChangePerSecond: math.pi * 0.5 + math.Random().nextDouble() * math.pi
            ));
            // Add Separation behavior
            agent.addBehavior(Separation(
                spatialGrid: spatialGrid!,
                desiredSeparation: agent.radius * 2 + 5.0 // Keep agents slightly apart
            ), weight: 1.5); // Give separation higher weight
            agent.addBehavior(CustomContainment(boundary: worldBoundary!));
            agents.add(agent);
            spatialGrid!.add(agent); // Add agent to grid
        }
        break;

      default:
        // print('Scenario for $behaviorName not implemented yet.'); // Keep commented out
        // Add a default agent maybe?
        final agent = DemoAgent(ctx: ctx, position: Vector2(canvasWidth / 2, canvasHeight / 2));
        agents.add(agent);
    }

     // Apply default world boundary containment if not handled specifically
     if (behaviorName != 'Containment' && behaviorName != 'Wall Following') {
       for (final agent in agents) {
         // Check if the agent *doesn't* already have containment
         if (agent.getBehavior<CustomContainment>() == null && worldBoundary != null) { // Check for CustomContainment
            // Add containment with low weight if other behaviors exist
            double weight = agent.activeBehaviors.length > 1 ? 0.5 : 1.0;
            agent.addBehavior(CustomContainment(boundary: worldBoundary!), weight: weight); // Add CustomContainment
         }
       }
     }

    // Store original parameters and apply initial randomization if needed
    _storeAndRandomizeAgentParams();
  }

  /// Sets up the scenario for flocking-related behaviors (Separation, Cohesion, Alignment, Flocking).
  /// Creates multiple agents and configures the necessary flocking behaviors and spatial grid.
  void _setupFlockingScenario(String mainBehavior) {
     final random = math.Random();
     final flockSize = 30;
     worldBoundary = RectangleBoundary(
         minCorner: Vector2(50, 50),
         maxCorner: Vector2(canvasWidth - 50, canvasHeight - 50)
     ); // Contain flock
     // Create spatial grid for neighbor lookup optimization.
     // Cell size should be roughly the largest interaction radius used by the behaviors
     // (e.g., cohesion/alignment neighborhoodRadius) for efficiency.
     final cellSize = 100.0;
     // Instantiate the grid - requires only cellSize
     spatialGrid = SpatialHashGrid(cellSize: cellSize);

     for (int i = 0; i < flockSize; i++) {
         final agent = DemoAgent(
             ctx: ctx,
             position: randomVector2(100, canvasWidth - 100, 100, canvasHeight - 100),
             radius: 5.0,
             maxSpeed: 180.0,
             maxForce: 250.0
         );
         // Set initial velocity with random direction and half max speed
         agent.velocity = Vector2(random.nextDouble() * 2 - 1, random.nextDouble() * 2 - 1)
            ..normalize()
            ..scale(agent.maxSpeed * 0.5);

         // Add behaviors based on the selected mode
         if (mainBehavior == 'Separation' || mainBehavior == 'Flocking') {
             agent.addBehavior(Separation(
                 spatialGrid: spatialGrid!, // Provide grid for optimization
                 desiredSeparation: 25.0,
             ), weight: 1.5);
         }
         if (mainBehavior == 'Cohesion' || mainBehavior == 'Flocking') {
             agent.addBehavior(Cohesion(
                 spatialGrid: spatialGrid!, // Provide grid
                 neighborhoodRadius: 100.0,
             ), weight: 1.0);
         }
         if (mainBehavior == 'Alignment' || mainBehavior == 'Flocking') {
             agent.addBehavior(Alignment(
                 spatialGrid: spatialGrid!, // Provide grid
                 neighborhoodRadius: 100.0,
             ), weight: 1.0);
         }

         // Always add containment
         agent.addBehavior(CustomContainment(boundary: worldBoundary!), weight: 1.0);
         agents.add(agent);
     }
  }

 /// Sets up the scenario for the Leader Following behavior.
 /// Creates a leader agent that wanders and several follower agents that use LeaderFollowing.
 void _setupLeaderFollowingScenario() {
     worldBoundary = RectangleBoundary(minCorner: Vector2(50, 50), maxCorner: Vector2(canvasWidth - 50, canvasHeight - 50));
     // Note: A spatialGrid could be added here and passed to LeaderFollowing
     // if separation between followers is also desired.

     // Create Leader
     final leader = DemoAgent(
         ctx: ctx,
         position: Vector2(canvasWidth / 2, canvasHeight / 2),
         radius: 12.0,
         maxSpeed: 120.0
     )..color = 'orange';
     // Leader wanders
     leader.addBehavior(Wander(
         circleDistance: 80.0,
         circleRadius: 40.0,
         angleChangePerSecond: math.pi * 0.7
     ));
     leader.addBehavior(CustomContainment(boundary: worldBoundary!));
     agents.add(leader); // Add leader first
     // spatialGrid?.add(leader); // Add leader to grid if using separation

     // Create Followers
     final followerCount = 15;
     final random = math.Random();
     for (int i = 0; i < followerCount; i++) {
         final follower = DemoAgent(
             ctx: ctx,
             // Start near leader with some randomness
             position: leader.position + Vector2(random.nextDouble() * 60 - 30, random.nextDouble() * 60 - 30),
             radius: 6.0,
             maxSpeed: 190.0, // Can be faster than leader
             maxForce: 280.0
         )..color = 'teal';

         // Leader Following behavior
         follower.addBehavior(LeaderFollowing(
             leader: leader,
             leaderBehindDistance: 50.0, // How far behind the leader to follow
             // Optional separation params (require grid):
             // spatialGrid: spatialGrid,
             // followerSeparation: 20.0,
         ));

         // Containment
         follower.addBehavior(CustomContainment(boundary: worldBoundary!), weight: 0.8);

         agents.add(follower);
         // spatialGrid?.add(follower); // Add follower to grid if using separation
     }
 }


  /// Dynamically generates and updates the HTML controls (sliders) in the parameter panel
  /// based on the currently selected behavior and its parameters.
  void _updateParameterControls() {
    parameterPanel.innerHTML = ''.toJS; // Cast to JSString for innerHTML

    // --- Add Behavior Description and Interaction Info ---
    final info = behaviorInfo[currentBehavior];
    if (info != null) {
        parameterPanel.append(web.HTMLParagraphElement() // Use web element
            ..style.fontWeight = 'bold'
            ..text = 'Description:');
        parameterPanel.append(web.HTMLParagraphElement() // Use web element
            ..style.fontSize = '0.9em'
            ..style.marginTop = '2px'
            ..style.marginBottom = '10px'
            ..text = info.description);

        parameterPanel.append(web.HTMLParagraphElement() // Use web element
            ..style.fontWeight = 'bold'
            ..text = 'Interaction:');
        parameterPanel.append(web.HTMLParagraphElement() // Use web element
            ..style.fontSize = '0.9em'
            ..style.marginTop = '2px'
            ..style.marginBottom = '15px' // More space before params
            ..text = info.interaction);
    } else {
        parameterPanel.append(web.HTMLParagraphElement()..text = 'Info not available for this behavior.'); // Use web element
    }
    parameterPanel.append(web.HTMLHRElement()); // Use web element

    // Show/hide randomization control based on agent count
    final bool isMultiAgent = agents.length > 1 || (agents.length == 1 && targetAgent != null && agents.contains(targetAgent)); // Crude check, refine if needed
    agentRandomizationControl.style.display = isMultiAgent ? 'block' : 'none';

    if (agents.isEmpty && targetAgent == null) {
      // If no agents, but we have info, still show the info panel.
      // If no agents AND no info, show the original message.
      if (info == null) {
          parameterPanel.append(web.HTMLParagraphElement()..text = 'No agent selected or scenario not fully implemented.'); // Use web element
      }
      // Hide randomization control if no agents
      agentRandomizationControl.style.display = 'none';
      return;
    }

    // --- Common Agent Parameters ---
    // Use the first agent for common controls in simple scenarios.
    // For flocking/leader following, apply changes to all relevant agents.
    final controlAgent = agents.isNotEmpty ? agents.first : targetAgent;
    if (controlAgent == null) return;

    parameterPanel.append(web.HTMLHeadingElement.h4()..text = 'Agent Settings'); // Use web element
    _addSliderControl(parameterPanel, 'Max Speed', controlAgent.maxSpeed, 10, 500, 1, (value) {
      for (final agent in agents) { agent.maxSpeed = value; }
       if (targetAgent != null && !agents.contains(targetAgent)) targetAgent!.maxSpeed = value;
    });
     _addSliderControl(parameterPanel, 'Max Force', controlAgent.maxForce, 10, 500, 1, (value) {
       for (final agent in agents) { agent.maxForce = value; }
       if (targetAgent != null && !agents.contains(targetAgent)) targetAgent!.maxForce = value;
     });
     _addSliderControl(parameterPanel, 'Mass', controlAgent.mass, 0.1, 10, 0.1, (value) {
       for (final agent in agents) { agent.mass = value; }
        if (targetAgent != null && !agents.contains(targetAgent)) targetAgent!.mass = value;
     });
     _addSliderControl(parameterPanel, 'Radius', controlAgent.radius, 1, 50, 1, (value) {
       for (final agent in agents) { agent.radius = value; }
        if (targetAgent != null && !agents.contains(targetAgent)) targetAgent!.radius = value;
     });


    // --- Behavior-Specific Parameters ---
     parameterPanel.append(web.HTMLHeadingElement.h4()..text = 'Behavior: $currentBehavior'); // Use web element
     bool behaviorParamsAdded = false;

     // Use the agent's getBehavior method now
     T? getBehavior<T extends SteeringBehavior>(DemoAgent? agent) => agent?.getBehavior<T>();

     // Helper to recreate behavior for a single agent.
     // Since many behavior parameters are final, changing them requires
     // removing the old behavior and adding a new one with the updated parameter.
     void recreateBehavior<T extends SteeringBehavior>(DemoAgent agent, T Function(T oldBehavior) constructor) {
         final oldBehavior = agent.getBehavior<T>();
         if (oldBehavior != null) {
             final weight = agent.getBehaviorWeight<T>();
             agent.removeBehavior<T>();
             agent.addBehavior(constructor(oldBehavior), weight: weight);
         }
     }
     // Helper to recreate behavior for multiple agents (e.g., in flocking).
     void recreateBehaviorForAll<T extends SteeringBehavior>(T Function(T oldBehavior) constructor) {
         for (final agent in agents) {
             // Skip the leader in leader following scenarios if modifying follower-only behaviors
             if (currentBehavior == 'Leader Following' && agent == agents.first) continue;
             recreateBehavior(agent, constructor);
         }
     }


     // Add controls based on currentBehavior
     switch (currentBehavior) {
       case 'Arrival':
         final behavior = getBehavior<Arrival>(controlAgent);
         if (behavior != null) {
           // slowingRadius is mutable
           _addSliderControl(parameterPanel, 'Slowing Radius', behavior.slowingRadius, 5, 200, 1, (v) => behavior.slowingRadius = v);
           behaviorParamsAdded = true;
         }
         break;
       case 'Wander':
         final behavior = getBehavior<Wander>(controlAgent);
         if (behavior != null) {
           // Wander parameters are final, require recreation
           _addSliderControl(parameterPanel, 'Wander Distance', behavior.circleDistance, 10, 200, 1, (v) {
               recreateBehavior<Wander>(controlAgent, (old) => Wander(circleDistance: v, circleRadius: old.circleRadius, angleChangePerSecond: old.angleChangePerSecond));
           });
           _addSliderControl(parameterPanel, 'Wander Radius', behavior.circleRadius, 5, 100, 1, (v) {
                recreateBehavior<Wander>(controlAgent, (old) => Wander(circleDistance: old.circleDistance, circleRadius: v, angleChangePerSecond: old.angleChangePerSecond));
           });
           _addSliderControl(parameterPanel, 'Angle Change/s', behavior.angleChangePerSecond, 0.1, math.pi * 4, 0.1, (v) {
                recreateBehavior<Wander>(controlAgent, (old) => Wander(circleDistance: old.circleDistance, circleRadius: old.circleRadius, angleChangePerSecond: v));
           });
           behaviorParamsAdded = true;
         }
         // Also control CustomContainment if present
         final containment = getBehavior<CustomContainment>(controlAgent); // Get CustomContainment
         if (containment != null) {
             // predictionDistance is final
             _addSliderControl(parameterPanel, 'Contain Predict', containment.predictionDistance, 5, 100, 1, (v) {
                  recreateBehavior<CustomContainment>(controlAgent, (old) => CustomContainment(boundary: old.boundary, predictionDistance: v, forceMultiplierIncrease: old.forceMultiplierIncrease)); // Recreate CustomContainment
             });
             // TODO: Add weight control slider. Requires storing/retrieving weight and using steeringManager.setWeight().
             _addSliderControl(parameterPanel, 'Contain Force Incr', containment.forceMultiplierIncrease, 0.1, 2.0, 0.1, (v) { // Add slider for new param
                  recreateBehavior<CustomContainment>(controlAgent, (old) => CustomContainment(boundary: old.boundary, predictionDistance: old.predictionDistance, forceMultiplierIncrease: v));
             });
             // TODO: Add weight control slider.
             // _addSliderControl(parameterPanel, 'Contain Weight', controlAgent.getBehaviorWeight<CustomContainment>(), 0.1, 5, 0.1, (v) { ... });
             behaviorParamsAdded = true;
         }
         break;
       case 'Pursuit':
       case 'Evade':
         // No direct parameters exposed for basic Pursuit/Evade in this library version
         parameterPanel.append(web.HTMLParagraphElement()..text = 'No specific parameters.'); // Use web element
         behaviorParamsAdded = true; // Mark as handled
         break;
       case 'Offset Pursuit':
          final behavior = getBehavior<OffsetPursuit>(agents.first); // Control the follower
          if (behavior != null) {
              // Offset is mutable Vector2
              _addSliderControl(parameterPanel, 'Offset X', behavior.offset.x, -100, 100, 1, (v) => behavior.offset.x = v);
              _addSliderControl(parameterPanel, 'Offset Y', behavior.offset.y, -100, 100, 1, (v) => behavior.offset.y = v);
              behaviorParamsAdded = true;
          }
          break;
       case 'Obstacle Avoidance':
         final behavior = getBehavior<ObstacleAvoidance>(controlAgent);
         if (behavior != null) {
           // Parameters are final, require recreation
           _addSliderControl(parameterPanel, 'Detection Length', behavior.detectionBoxLength, 10, 200, 1, (v) {
               recreateBehavior<ObstacleAvoidance>(controlAgent, (old) => ObstacleAvoidance(obstacles: old.obstacles, detectionBoxLength: v, avoidanceForceMultiplier: old.avoidanceForceMultiplier));
           });
           _addSliderControl(parameterPanel, 'Avoidance Force', behavior.avoidanceForceMultiplier, 10, 500, 5, (v) {
                recreateBehavior<ObstacleAvoidance>(controlAgent, (old) => ObstacleAvoidance(obstacles: old.obstacles, detectionBoxLength: old.detectionBoxLength, avoidanceForceMultiplier: v));
           });
           // TODO: Add weight control slider.
           behaviorParamsAdded = true;
         }
         break;
       case 'Path Following':
         final behavior = getBehavior<PathFollowing>(controlAgent);
         if (behavior != null && currentPath != null) {
           // Path radius is final on Path object, requires recreating Path AND PathFollowing
           _addSliderControl(parameterPanel, 'Path Radius', currentPath!.radius, 5, 50, 1, (v) {
               currentPath = Path(points: currentPath!.points, loop: currentPath!.loop, radius: v);
               recreateBehavior<PathFollowing>(controlAgent, (old) => PathFollowing(path: currentPath!, predictionDistance: old.predictionDistance));
           });
           // Prediction distance is final
           _addSliderControl(parameterPanel, 'Prediction Distance', behavior.predictionDistance, 10, 150, 1, (v) {
                recreateBehavior<PathFollowing>(controlAgent, (old) => PathFollowing(path: currentPath!, predictionDistance: v));
           });
           behaviorParamsAdded = true;
         } else if (currentPath == null) {
             parameterPanel.append(web.HTMLParagraphElement()..text = 'Path not defined for this scenario.'); // Use web element
             behaviorParamsAdded = true; // Mark as handled
         }
         break;
       case 'Wall Following':
          final behavior = getBehavior<WallFollowing>(controlAgent);
          if (behavior != null) {
              // Parameters are final, require recreation
              _addSliderControl(parameterPanel, 'Desired Distance', behavior.desiredDistance, 1, 50, 1, (v) {
                  recreateBehavior<WallFollowing>(controlAgent, (old) => WallFollowing(walls: old.walls, desiredDistance: v, feelerLength: old.feelerLength, wallForceMultiplier: old.wallForceMultiplier));
              });
              _addSliderControl(parameterPanel, 'Feeler Length', behavior.feelerLength, 10, 150, 1, (v) { // Reverted min, max, step
                   recreateBehavior<WallFollowing>(controlAgent, (old) => WallFollowing(walls: old.walls, desiredDistance: old.desiredDistance, feelerLength: v, wallForceMultiplier: old.wallForceMultiplier));
              });
              _addSliderControl(parameterPanel, 'Wall Force', behavior.wallForceMultiplier, 500, 5000, 10, (v) { // Updated min, max, step
                   recreateBehavior<WallFollowing>(controlAgent, (old) => WallFollowing(walls: old.walls, desiredDistance: old.desiredDistance, feelerLength: old.feelerLength, wallForceMultiplier: v));
              });
              // TODO: Add weight control slider.
              behaviorParamsAdded = true;
          }
          break;
       case 'Containment':
          final behavior = getBehavior<CustomContainment>(controlAgent); // Get CustomContainment
          if (behavior != null) {
              // predictionDistance is final
              _addSliderControl(parameterPanel, 'Prediction Distance', behavior.predictionDistance, 5, 100, 1, (v) {
                   recreateBehavior<CustomContainment>(controlAgent, (old) => CustomContainment(boundary: old.boundary, predictionDistance: v, forceMultiplierIncrease: old.forceMultiplierIncrease)); // Recreate CustomContainment
              });
              _addSliderControl(parameterPanel, 'Force Increase', behavior.forceMultiplierIncrease, 0.1, 2.0, 0.1, (v) { // Add slider for new param
                   recreateBehavior<CustomContainment>(controlAgent, (old) => CustomContainment(boundary: old.boundary, predictionDistance: old.predictionDistance, forceMultiplierIncrease: v));
              });
              // TODO: Add weight control slider.
              behaviorParamsAdded = true;
          }
          break;

       // --- Flocking Controls (Apply to all agents) ---
       case 'Separation':
       case 'Flocking':
          if (agents.isNotEmpty) {
              final firstBehavior = getBehavior<Separation>(agents.first);
              if (firstBehavior != null) {
                  // desiredSeparation is final, requires recreation for all
                  _addSliderControl(parameterPanel, 'Separation Radius', firstBehavior.desiredSeparation, 5, 100, 1, (v) {
                      recreateBehaviorForAll<Separation>((old) => Separation(spatialGrid: spatialGrid!, desiredSeparation: v));
                  });
                  // TODO: Add weight control slider.
                  behaviorParamsAdded = true;
              }
          }
          break;
       case 'Cohesion':
          if (agents.isNotEmpty) {
              final firstBehavior = getBehavior<Cohesion>(agents.first);
              if (firstBehavior != null) {
                  // neighborhoodRadius is final, requires recreation for all
                  _addSliderControl(parameterPanel, 'Cohesion Radius', firstBehavior.neighborhoodRadius, 20, 300, 5, (v) {
                      recreateBehaviorForAll<Cohesion>((old) => Cohesion(spatialGrid: spatialGrid!, neighborhoodRadius: v));
                  });
                  // TODO: Add weight control slider.
                  behaviorParamsAdded = true;
              }
          }
          break;
       case 'Alignment':
          if (agents.isNotEmpty) {
              final firstBehavior = getBehavior<Alignment>(agents.first);
              if (firstBehavior != null) {
                  // neighborhoodRadius is final, requires recreation for all
                  _addSliderControl(parameterPanel, 'Alignment Radius', firstBehavior.neighborhoodRadius, 20, 300, 5, (v) {
                       recreateBehaviorForAll<Alignment>((old) => Alignment(spatialGrid: spatialGrid!, neighborhoodRadius: v));
                  });
                  // Weight needs re-adding logic (TODO)
                  behaviorParamsAdded = true;
              }
          }
          break;
        case 'Leader Following':
            // Control the first follower's behavior (assuming homogeneity)
            if (agents.length > 1) {
                final followerAgent = agents[1]; // First follower
                final behaviorLF = getBehavior<LeaderFollowing>(followerAgent);
                if (behaviorLF != null) {
                    // --- LeaderFollowing specific controls ---
                    // These parameters are final, so changing them requires recreating the behavior for all followers.

                    // Slider for leaderBehindDistance
                    _addSliderControl(parameterPanel, 'Leader Behind Dist', behaviorLF.leaderBehindDistance, 10, 150, 1, (v) {
                        final currentSeparation = _readFollowerSeparationValue(); // Read current separation setting
                        for(final agent in agents.skip(1)) {
                            recreateBehavior<LeaderFollowing>(agent, (old) => LeaderFollowing(
                                leader: old.leader,
                                leaderBehindDistance: v, // Apply new value
                                leaderSightDistance: old.leaderSightDistance,
                                leaderSightRadius: old.leaderSightRadius,
                                spatialGrid: old.spatialGrid,
                                followerSeparation: currentSeparation
                            ));
                        }
                    });

                    // Slider for leaderSightDistance
                     _addSliderControl(parameterPanel, 'Leader Sight Dist', behaviorLF.leaderSightDistance, 5, 100, 1, (v) {
                         final currentSeparation = _readFollowerSeparationValue();
                         for(final agent in agents.skip(1)) {
                            recreateBehavior<LeaderFollowing>(agent, (old) => LeaderFollowing(
                                leader: old.leader,
                                leaderBehindDistance: old.leaderBehindDistance,
                                leaderSightDistance: v, // Apply new value
                                leaderSightRadius: old.leaderSightRadius,
                                spatialGrid: old.spatialGrid,
                                followerSeparation: currentSeparation
                            ));
                        }
                     });

                     // Slider for leaderSightRadius
                     _addSliderControl(parameterPanel, 'Leader Sight Radius', behaviorLF.leaderSightRadius, 1, 50, 1, (v) {
                          final currentSeparation = _readFollowerSeparationValue();
                          for(final agent in agents.skip(1)) {
                            recreateBehavior<LeaderFollowing>(agent, (old) => LeaderFollowing(
                                leader: old.leader,
                                leaderBehindDistance: old.leaderBehindDistance,
                                leaderSightDistance: old.leaderSightDistance,
                                leaderSightRadius: v, // Apply new value
                                spatialGrid: old.spatialGrid,
                                followerSeparation: currentSeparation
                            ));
                        }
                     });

                    // Slider for followerSeparation (only if grid is available)
                    if (behaviorLF.spatialGrid != null) {
                        // Get the current separation value from the *actual* Separation behavior
                        // on the first follower, if it exists.
                        double initialSeparation = 20.0; // Default fallback
                        final sepBehavior = followerAgent.getBehavior<Separation>();
                        if (sepBehavior != null) {
                            initialSeparation = sepBehavior.desiredSeparation;
                        } else {
                            // If no explicit separation, maybe LeaderFollowing has a default?
                            // Check constructor args. For now, use a sensible default.
                            initialSeparation = 20.0; // Default if not found
                        }

                        _addSliderControl(parameterPanel, 'Follower Separation', initialSeparation, 5, 50, 1, (v) {
                            // This also requires recreation
                            for(final agent in agents.skip(1)) {
                                recreateBehavior<LeaderFollowing>(agent, (old) => LeaderFollowing(
                                    leader: old.leader,
                                    leaderBehindDistance: old.leaderBehindDistance,
                                    leaderSightDistance: old.leaderSightDistance,
                                    leaderSightRadius: old.leaderSightRadius,
                                    spatialGrid: old.spatialGrid, // Must pass grid if separation is used
                                    followerSeparation: v // Apply new value
                                ));
                            }
                        }, id: 'followerSeparationSlider'); // Give slider an ID
                    }
                    behaviorParamsAdded = true;
                }
            } else {
                 parameterPanel.append(web.HTMLParagraphElement()..text = 'Requires at least one follower.'); // Use web element
                 behaviorParamsAdded = true; // Mark as handled
            }
            break;

     }

     // Add Flocking sub-behavior controls if Flocking is selected
     if (currentBehavior == 'Flocking') {
         if (agents.isNotEmpty) {
             final firstAgent = agents.first;
             // Cohesion Controls (if behavior exists)
             final behaviorCohesion = getBehavior<Cohesion>(firstAgent);
             if (behaviorCohesion != null) {
                 parameterPanel.append(web.HTMLHRElement()); // Use web element
                 _addSliderControl(parameterPanel, 'Cohesion Radius', behaviorCohesion.neighborhoodRadius, 20, 300, 5, (v) {
                     recreateBehaviorForAll<Cohesion>((old) => Cohesion(spatialGrid: spatialGrid!, neighborhoodRadius: v));
                 });
                 // TODO: Add weight control slider.
                 behaviorParamsAdded = true;
             }
             // Alignment Controls (if behavior exists)
             final behaviorAlignment = getBehavior<Alignment>(firstAgent);
             if (behaviorAlignment != null) {
                 parameterPanel.append(web.HTMLHRElement()); // Use web element
                 _addSliderControl(parameterPanel, 'Alignment Radius', behaviorAlignment.neighborhoodRadius, 20, 300, 5, (v) {
                     recreateBehaviorForAll<Alignment>((old) => Alignment(spatialGrid: spatialGrid!, neighborhoodRadius: v));
                 });
                 // TODO: Add weight control slider.
                 behaviorParamsAdded = true;
             }
         }
     }


    if (!behaviorParamsAdded) {
      parameterPanel.append(web.HTMLParagraphElement()..text = 'No specific parameters for this behavior yet.'); // Use web element
    }

    // TODO: Add controls for behavior weights. This would require iterating through
    // agent.activeBehaviors and providing a way to update weights via steeringManager.setWeight().
  }

  /// Helper function to create and add a labeled slider control to the parameter panel.
  void _addSliderControl(
      web.Element parent, String label, num initialValue, num min, num max, num step, Function(double) onChange, {String? id}) { // Use web.Element
    final container = web.HTMLDivElement()..classList.add('slider-container'); // Use classList
    if (id != null) {
        container.id = id; // Assign ID to container if provided
    }
    final labelElement = web.HTMLLabelElement()..text = '$label: '; // Use web element
    final valueDisplay = web.HTMLSpanElement() // Use web element
        ..text = initialValue.toStringAsFixed(step >= 1 ? 0 : 1) // Show decimal if step is fractional
        ..classList.add('value-display'); // Use classList

    // Create element first, then set properties
    final slider = web.document.createElement('input') as web.HTMLInputElement
      ..type = 'range' // Assign String directly
      ..min = min.toString()
      ..max = max.toString()
      ..step = step.toString()
      ..value = initialValue.toString();

    slider.onInput.listen((_) {
      final value = double.parse(slider.value ?? '0');
      valueDisplay.text = value.toStringAsFixed(step >= 1 ? 0 : 1);
      try {
        onChange(value);
      } catch (e, s) {
          // print("Error applying slider change for $label: $e"); // Keep commented out unless debugging
          // print(s);
          // Optionally disable slider or show error?
      }
    });

    labelElement.append(valueDisplay); // Add value display next to label text
    container.append(labelElement);
    container.append(slider);
    parent.append(container);
  }

  /// Helper function to read the current value of the follower separation slider, if it exists.
  double? _readFollowerSeparationValue() {
      // Find the container div first, then the input inside it
      final container = web.document.querySelector('#followerSeparationSlider'); // Use web.document
      if (container == null) return null;
      final slider = container?.querySelector('input[type="range"]') as web.HTMLInputElement?; // Add null check for container
      if (slider != null) {
          return double.tryParse(slider.value ?? '');
      }
      return null; // Return null if slider doesn't exist
  }


  // --- Agent Parameter Randomization ---

  /// Stores the original parameters (speed, force, mass, radius) of agents in multi-agent scenarios
  /// and applies initial randomization if the corresponding checkbox is checked.
  void _storeAndRandomizeAgentParams() {
      _originalAgentParams.clear();
      if (agents.length <= 1 && !(agents.length == 1 && targetAgent != null && agents.contains(targetAgent))) {
          // Don't store/randomize for single agent scenarios (or pursuit/evade where target is also an agent)
          // This logic might need refinement for specific scenarios like Offset Pursuit
          return;
      }

      for (final agent in agents) {
          // Store original values
          _originalAgentParams[agent] = (
              maxSpeed: agent.maxSpeed,
              maxForce: agent.maxForce,
              mass: agent.mass,
              radius: agent.radius
          );
      }

      // Apply initial randomization if checkbox is checked
      if (randomizeParamsCheckbox.checked ?? false) {
          _applyAgentParameterRandomization();
      }
  }

  /// Applies or removes randomization (+/- 20%) to agent parameters based on the checkbox state.
  void _applyAgentParameterRandomization() {
      final random = math.Random();
      final bool shouldRandomize = randomizeParamsCheckbox.checked ?? false;

      for (final agent in agents) {
          final originalParams = _originalAgentParams[agent];
          if (originalParams == null) continue; // Should not happen if stored correctly

          if (shouldRandomize) {
              // Apply +/- 20% randomization
              final factor = 1.0 + (random.nextDouble() * 0.4 - 0.2); // Range 0.8 to 1.2
              agent.maxSpeed = (originalParams.maxSpeed * factor).clamp(10.0, 1000.0); // Add clamps
              agent.maxForce = (originalParams.maxForce * factor).clamp(10.0, 1000.0);
              agent.mass = (originalParams.mass * factor).clamp(0.1, 20.0);
              agent.radius = (originalParams.radius * factor).clamp(1.0, 100.0);
              // TODO: Consider randomizing behavior-specific parameters if applicable?
              // This would require more complex UI and logic to handle different parameter types.
          } else {
              // Restore original parameters
              agent.maxSpeed = originalParams.maxSpeed;
              agent.maxForce = originalParams.maxForce;
              agent.mass = originalParams.mass;
              agent.radius = originalParams.radius;
          }
      }
      // Note: This randomization doesn't update the UI sliders. The sliders will still
      // show the original/default values. Reflecting randomized per-agent values in the
      // UI would require more complex logic (e.g., disabling sliders or showing ranges).
  }


  /// Starts the main animation loop using `window.animationFrame`.
  void _startAnimationLoop() {
    // Wrap _gameLoop in a closure matching FrameRequestCallback signature
    web.window.requestAnimationFrame((JSNumber timestamp) {
      _gameLoop(timestamp);
    }.toJS);
  }

  /// The main game loop, called recursively via `window.animationFrame`.
  /// Calculates delta time, updates agents and spatial grid, and draws the scene.
  // Callback type for requestAnimationFrame is void Function(DOMHighResTimeStamp time)
  // DOMHighResTimeStamp is num in dart:html, but double in package:web via JSNumber
  // requestAnimationFrame callback takes a double (DOMHighResTimeStamp)
  // Callback type for requestAnimationFrame is void Function(DOMHighResTimeStamp time)
  // DOMHighResTimeStamp is JSNumber in package:web
  void _gameLoop(JSNumber timestamp) {
    // Convert timestamp to double for calculations
    final double currentTimestamp = timestamp.toDartDouble; // Convert JSNumber to double
    // Calculate delta time (in seconds).
    // Handle the first frame or potential pauses where timestamp might reset or be zero.
    final dt = (_lastTimestamp == 0 || currentTimestamp <= _lastTimestamp)
               ? 0.016 // Assume ~60fps for first frame or on reset
               : (currentTimestamp - _lastTimestamp) / 1000.0;
    _lastTimestamp = currentTimestamp;

    // Update spatial grid if used: Clear previous frame's data and re-add agents
    // at their current positions for this frame's neighbor queries.
    spatialGrid?.clear();
    if (spatialGrid != null) {
      // Add agents to the grid for this frame's queries
      for (final agent in agents) {
          spatialGrid!.add(agent); // Use the correct 'add' method
      }
    }


    // --- Update Agents ---
    for (final agent in agents) {
      // Update agent's position within the spatial grid if it's being used.
      spatialGrid?.update(agent);
      // SteeringManager now handles neighbor lookup internally if a SpatialHashGrid is provided
      agent.steeringManager.update(dt); // This calculates force AND calls agent.applySteering
    }

    // --- Draw Scene ---
    // Clear canvas
    ctx.clearRect(0, 0, canvasWidth, canvasHeight);
    ctx.fillStyle = '#f0f0f0'.toJS; // Cast to JSAny
    ctx.fillRect(0, 0, canvasWidth.toDouble(), canvasHeight.toDouble()); // Use doubles

    // Draw world boundary visualization (light grey rectangle).
    if (worldBoundary != null) {
        ctx.strokeStyle = 'lightgrey'.toJS; // Cast to JSAny
        ctx.lineWidth = 1;
        ctx.strokeRect(worldBoundary!.minCorner.x, worldBoundary!.minCorner.y, worldBoundary!.width, worldBoundary!.height);
    }
     // Draw walls (black lines).
     if (walls.isNotEmpty) {
         ctx.strokeStyle = 'black'.toJS; // Cast to JSAny
         ctx.lineWidth = 3;
         ctx.beginPath();
         for (final wall in walls) {
             ctx.moveTo(wall.start.x, wall.start.y);
             ctx.lineTo(wall.end.x, wall.end.y);
         }
         ctx.stroke();
     }

    // Draw Flow Field visualization (light blue vectors).
    if (flowField != null && currentBehavior == 'Flow Field Following') {
        ctx.strokeStyle = 'rgba(0, 0, 200, 0.2)'.toJS; // Cast to JSAny
        ctx.lineWidth = 1;
        final cellSize = flowField!.cellSize;
        for (int y = 0; y < flowField!.height; y++) {
            for (int x = 0; x < flowField!.width; x++) {
                final cellCenter = Vector2(
                    (x + 0.5) * cellSize,
                    (y + 0.5) * cellSize
                );
                // Get the flow vector for the current cell.
                final vector = flowField!.getFlowAt(x, y);
                // Check if the vector is null (might be out of bounds, though unlikely with loop structure)
                if (vector != null) {
                    ctx.beginPath();
                    ctx.moveTo(cellCenter.x, cellCenter.y);
                    // Scale vector for visibility
                    ctx.lineTo(cellCenter.x + vector.x * cellSize * 0.4, cellCenter.y + vector.y * cellSize * 0.4);
                    ctx.stroke();
                } // Closing brace for the if (vector != null) check
            }
        }
    }

    // Draw path visualization (purple line).
    if (currentPath != null) {
      // Draw the path lines
      ctx.strokeStyle = 'purple'.toJS; // Cast to JSAny
      ctx.lineWidth = 1;
      ctx.beginPath();
      if (currentPath!.points.isNotEmpty) {
          ctx.moveTo(currentPath!.points.first.x, currentPath!.points.first.y);
          for (int i = 1; i < currentPath!.points.length; i++) {
              ctx.lineTo(currentPath!.points[i].x, currentPath!.points[i].y);
          }
          // TODO: Optionally draw path radius guides (circles/lines along the path).
          ctx.stroke();
      }
    }

    // Draw obstacles (grey circles).
    for (final obstacle in obstacles) {
      // Assuming only CircleObstacle for now
      ctx.beginPath();
      ctx.arc(obstacle.position.x, obstacle.position.y, obstacle.radius, 0, math.pi * 2);
      ctx.fillStyle = 'grey'.toJS; // Cast to JSAny
      ctx.fill();
      ctx.strokeStyle = 'darkgrey'.toJS; // Cast to JSAny
      ctx.stroke();
    }

    // Draw target position visualization (lime circle) for relevant behaviors.
    if (targetPosition != null && ['Seek', 'Flee', 'Arrival', 'Obstacle Avoidance'].contains(currentBehavior)) {
      ctx.beginPath();
      ctx.arc(targetPosition!.x, targetPosition!.y, 5, 0, math.pi * 2);
      ctx.fillStyle = 'lime'.toJS; // Cast to JSAny
      ctx.fill();
       ctx.strokeStyle = 'darkgreen'.toJS; // Cast to JSAny
       ctx.stroke();
    }

    // Draw all agents.
    for (final agent in agents) {
      agent.draw();
    }

    // Request the next animation frame to continue the loop.
    // Wrap _gameLoop in a closure matching FrameRequestCallback signature
    web.window.requestAnimationFrame((JSNumber timestamp) {
      _gameLoop(timestamp);
    }.toJS);
  }
}

// --- Entry Point (called from main.dart) ---
/// Entry point function called from `main.dart` to initialize the steering demo.
void setupSteeringDemo() {
  // Using requestAnimationFrame ensures canvas is ready and avoids potential
  // issues with DOM loading timing.
  // requestAnimationFrame callback takes a double (DOMHighResTimeStamp)
  // requestAnimationFrame callback takes a JSNumber (DOMHighResTimeStamp)
  // Wrap the anonymous function in .toJS to convert it to a JSFunction
  web.window.requestAnimationFrame((JSNumber _) {
      try {
          // print("Setting up Steering Demo"); // Keep commented out
          SteeringDemo(); // Initialize the demo class
      } catch (e, stacktrace) {
          // print("Error setting up Steering Demo: $e"); // Keep commented out
          // print(stacktrace);
          // Provide feedback to the user in case of failure
          web.window.alert("Failed to initialize Steering Demo. Check console for errors."); // alert takes a String
      }
  }.toJS);
}