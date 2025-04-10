# 🧭 Pathfinder: Optimized Dart Steering & Pathfinding

[![Pub Version](https://img.shields.io/pub/v/pathfinder)](https://pub.dev/packages/pathfinder)
[![Monthly Downloads](https://img.shields.io/pub/dm/pathfindere)](https://pub.dev/packages/pathfinder)
[![Coverage Status](https://img.shields.io/badge/coverage-100%25-brightgreen)](coverage/lcov.info)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
<a href='https://ko-fi.com/U7U41CZ5QZ' target='_blank'><img height='36' style='border:0px;height:36px;' src='https://storage.ko-fi.com/cdn/kofi2.png?v=6' border='0' alt='Buy Me a Coffee at ko-fi.com' /></a>

> Pathfinder is a Dart library providing optimized 2D grid-based pathfinding algorithms and a comprehensive suite of autonomous agent steering behaviors. It's designed for use in Dart and Flutter applications, particularly games and simulations. 

**Package Focus:**

1.   🚀 **Performance:** Efficient algorithms and data structures (like spatial hashing) for smooth real-time operation.
2.   🔧 **Customization:** Easily configurable parameters for pathfinding and steering behaviors.
3.   🧩 **Modularity:** Decoupled components for flexibility and easy integration.
4.   ✅ **Ease of Adoption:** Clear API and examples to easily integrate into games or simulations.

## ✨ Features

### 🗺️ Pathfinding Algorithms

*   **A\* Finder:** Optimal and widely used heuristic search.
*   **Breadth-First Finder (BFS):** Optimal for unweighted grids.
*   **Dijkstra's Finder:** Optimal for weighted grids.
*   **Jump Point Search (JPS):** Significantly faster optimal search for uniform cost grids.
*   **IDA\* Finder:** Iterative Deepening A\*, memory-efficient optimal search.
*   **Orthogonal Jump Point Search:** JPS variant restricted to orthogonal movement.
*   **Bidirectional Finders:** Variants of A\*, BFS, Dijkstra, Best-First that search from both start and end nodes.
*   **Best-First Finder:** Heuristic search prioritizing nodes closest to the goal (not guaranteed optimal).
*   **Configurable Heuristics:** Manhattan, Euclidean, Chebyshev, Octile distances.
*   **Grid Representation:** Flexible grid system supporting walkable/unwalkable nodes and weights.
*   **Performance Optimizations:** Efficient open list implementation (HeapPriorityQueue), node state reset optimization (Search ID).

### 🤖 Steering Behaviors

*   **Basic Movement:** Seek, Flee, Arrival, Wander.
*   **Prediction:** Pursuit, Evade, Offset Pursuit.
*   **Obstacle Handling:** Obstacle Avoidance, Wall Following, Containment.
*   **Path Following:** Follow a predefined `Path` object (compatible with pathfinding results).
*   **Flow Field Following:** Navigate using a `FlowField`.
*   **Group Behaviors (Flocking):** Separation, Cohesion, Alignment.
*   **Advanced Grouping:** Leader Following.
*   **Collision Avoidance:** Unaligned Collision Avoidance (for dynamic agent-agent avoidance).
*   **Spatial Partitioning:** `SpatialHashGrid` for efficient neighbor queries in group behaviors and collision avoidance.

## 📦 Installation

Add Pathfinder to your `pubspec.yaml` dependencies:

```yaml
dependencies:
  pathfinder: ^latest # Replace with the desired pub.dev version
```

Then run `flutter pub get` or `dart pub get`.

## 🎮 Demos

Explore interactive demos showcasing various pathfinding algorithms and steering behaviors:

- **[View Demos on Github.io](https://brayflex.github.io/pathfinder/)** 
- **[Explore Demo Example Code](https://github.com/brayflex/pathfinder/tree/main/docs/web)** 

## 💡 Usage Examples

- **[All Pathfinding Code Examples](https://github.com/brayflex/pathfinder/tree/main/examples/pathfinding)** 
- **[All Behavior Code Examples](https://github.com/brayflex/pathfinder/tree/main/examples/behavior)** 

### Pathfinding Example

```dart
import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  // 1. Create a grid (e.g., 10x10)
  // Nodes are walkable by default. Mark obstacles as unwalkable.
  Grid grid = Grid(10, 10);
  grid.getNode(5, 5).walkable = false; // Add an obstacle
  grid.getNode(5, 6).walkable = false;
  grid.getNode(5, 7).walkable = false;

  // 2. Instantiate a pathfinder (e.g., AStarFinder)
  // Allow diagonal movement and use Manhattan distance heuristic
  AStarFinder finder = AStarFinder(
    allowDiagonal: true,
    heuristic: Heuristic.manhattan,
  );

  // 3. Find a path from (1, 1) to (8, 8)
  Vector2 start = Vector2(1, 1);
  Vector2 end = Vector2(8, 8);
  PathResult result = finder.findPath(start, end, grid);

  // 4. Process the result
  if (result.status == PathStatus.found) {
    print('Path found!');
    // Path is a list of Vector2 coordinates
    List<Vector2> pathCoordinates = result.path;
    for (Vector2 point in pathCoordinates) {
      print(' - (${point.x}, ${point.y})');
    }
  } else {
    print('Path not found. Status: ${result.status}');
  }

  // Reset the grid node states if you plan to reuse the grid for another search
  grid.resetNodes();
}
```

### Steering Behavior Example

```dart
import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart';

void main() {
  // 1. Create an Agent
  Agent agent = Agent(
    position: Vector2(50, 50),
    maxSpeed: 5.0,
    maxForce: 1.0,
  );

  // 2. Create a Steering Manager for the agent
  SteeringManager steeringManager = SteeringManager(agent: agent);

  // 3. Instantiate and add a behavior (e.g., Wander)
  Wander wanderBehavior = Wander(
    wanderDistance: 10.0,
    wanderRadius: 5.0,
    wanderJitter: 1.0,
  );
  steeringManager.addBehavior(wanderBehavior, weight: 1.0);

  // --- Hypothetical Game Loop ---
  double deltaTime = 1 / 60; // Example delta time (e.g., 60 FPS)
  for (int i = 0; i < 100; i++) { // Simulate 100 frames
    // 4. Update the agent's state
    steeringManager.update(deltaTime);

    print('Frame ${i + 1}: Position=${agent.position.storage.sublist(0, 2)}, Velocity=${agent.velocity.storage.sublist(0, 2)}');

    // In a real game, you'd use agent.position to update your sprite/entity
  }
  // --- End Game Loop ---
}
```

### 🔥 Flame Engine Integration Example (Path Following)

```dart
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:pathfinder/pathfinder.dart';
import 'package:vector_math/vector_math_64.dart' as vm;

// Assume 'grid' and 'finder' are initialized as in the Pathfinding Example
// Assume 'pathCoordinates' holds the result from finder.findPath(...)

class FollowingComponent extends PositionComponent with HasGameRef {
  late Agent agent;
  late SteeringManager steeringManager;
  late PathFollowing pathFollowingBehavior;
  late Path path;

  FollowingComponent(List<vm.Vector2> pathCoordinates) {
    // Convert path coordinates to a Path object
    path = Path(points: pathCoordinates, loop: false, radius: 5.0); // Adjust radius as needed

    agent = Agent(
      position: pathCoordinates.isNotEmpty ? pathCoordinates.first.clone() : vm.Vector2.zero(),
      maxSpeed: 80.0, // Pixels per second
      maxForce: 40.0,
      boundingRadius: 8.0, // For arrival damping
    );

    steeringManager = SteeringManager(agent: agent);

    pathFollowingBehavior = PathFollowing(path: path);
    steeringManager.addBehavior(pathFollowingBehavior, weight: 1.0);

    // Set component position initially
    position = agent.position;
    anchor = Anchor.center;
    // Add visual representation (e.g., CircleComponent) as a child if needed
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Update the steering manager
    steeringManager.update(dt);

    // Update the component's position based on the agent's calculated position
    // The steering manager updates agent.position directly
    position.setFrom(agent.position);

    // Optional: Update rotation based on velocity
    if (agent.velocity.length2 > 0.1) { // Avoid jitter when stopped
       angle = vm.degrees(agent.velocity.screenAngle());
    }

    // Check if path following is complete (optional)
    if (pathFollowingBehavior.isPathComplete) {
       print("Path complete!");
       // Maybe remove the component or switch behavior
       // steeringManager.removeBehavior(pathFollowingBehavior);
    }
  }

  // Add render logic here (e.g., draw the agent or use a SpriteComponent)
}

// --- In your FlameGame ---
// Future<void> onLoad() async {
//   // ... find pathCoordinates using AStarFinder ...
//   List<vm.Vector2> pathCoordinates = ...;
//   if (pathCoordinates.isNotEmpty) {
//     add(FollowingComponent(pathCoordinates));
//   }
// }
```

## 📚 API Documentation

Detailed API documentation is available on pub.dev:

**[View API Documentation](https://pub.dev/documentation/pathfinder/latest/)** 

## 🙏 Contributing

Contributions are welcome! Please feel free to:

*   Report issues or suggest features on the [GitHub Issues](https://github.com/brayflex/pathfinder/issues) page. 
*   Submit pull requests with bug fixes or enhancements, no contribution is too small!
  
Read [CONTRIBUTING](CONTRIBUTING) for more information.

## 📜 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) for details.