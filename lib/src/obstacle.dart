import 'package:vector_math/vector_math_64.dart';

import 'behaviors/obstacle_avoidance.dart'; // For doc links
import 'behaviors/wall_following.dart'; // For doc links
import 'behaviors/containment.dart'; // For doc links

/// Base interface for representing static obstacles in the simulation environment.
///
/// Steering behaviors like [ObstacleAvoidance], [WallFollowing], and [Containment]
/// interact with objects implementing this interface (or its specific subclasses)
/// to determine how agents should react to them.
///
/// Concrete implementations define the shape (e.g., circle, rectangle, line segment)
/// and relevant properties of different obstacle types.
abstract interface class Obstacle {
  /// A representative position for the obstacle, often its center point.
  /// The exact meaning might vary depending on the obstacle type.
  Vector2 get position;
}

/// Represents a circular obstacle defined by a center position and a radius.
///
/// Used primarily by the [ObstacleAvoidance] behavior.
class CircleObstacle implements Obstacle {
  /// The center position of the circular obstacle in world space.
  @override
  final Vector2 position;

  /// The radius of the circular obstacle. Must be positive.
  final double radius;

  /// Creates a circular obstacle.
  ///
  /// [position] The center position of the circle.
  /// [radius] The radius of the circle (> 0).
  CircleObstacle({required this.position, required this.radius})
      : assert(radius > 0, 'Obstacle radius must be positive.');
}

/// Represents a straight wall segment defined by two endpoints.
///
/// Used primarily by the [WallFollowing] behavior.
class WallSegment implements Obstacle {
  /// The starting point ([Vector2]) of the wall segment in world space.
  final Vector2 start;

  /// The ending point ([Vector2]) of the wall segment in world space.
  final Vector2 end;

  /// Creates a wall segment obstacle.
  ///
  /// [start] The starting point of the wall.
  /// [end] The ending point of the wall.
  WallSegment({required this.start, required this.end});

  /// The center position (midpoint) of the wall segment.
  /// While fulfilling the [Obstacle] interface, the `start`, `end`, and `normal`
  /// properties are usually more relevant for wall-following logic.
  @override
  Vector2 get position => (start + end) * 0.5;

  /// Calculates the normalized normal vector of the wall segment.
  ///
  /// The normal vector points perpendicular to the wall segment. This implementation
  /// assumes a counter-clockwise winding order when defining the wall (from `start`
  /// to `end`), meaning the calculated normal points "outwards" or to the left
  /// relative to the direction of the wall segment.
  ///
  /// Returns a normalized [Vector2] representing the wall normal.
  Vector2 get normal {
    // Vector representing the direction of the wall segment
    final direction = end - start;
    // Rotate direction 90 degrees counter-clockwise to get the normal
    // (x, y) -> (-y, x)
    // Normalize the resulting vector.
    return Vector2(-direction.y, direction.x).normalized();
  }
}

/// Represents an axis-aligned rectangular boundary area.
///
/// Used primarily by the [Containment] behavior to keep agents within its bounds.
/// Defined by its minimum (e.g., top-left) and maximum (e.g., bottom-right) corners.
class RectangleBoundary implements Obstacle {
  /// The minimum corner of the rectangle (smallest x and y coordinates).
  final Vector2 minCorner;

  /// The maximum corner of the rectangle (largest x and y coordinates).
  final Vector2 maxCorner;

  /// Creates an axis-aligned rectangular boundary.
  ///
  /// Throws an [AssertionError] if `minCorner.x >= maxCorner.x` or
  /// `minCorner.y >= maxCorner.y`.
  ///
  /// [minCorner] The minimum x, y coordinates (e.g., top-left).
  /// [maxCorner] The maximum x, y coordinates (e.g., bottom-right).
  RectangleBoundary({required this.minCorner, required this.maxCorner})
      : assert(minCorner.x < maxCorner.x && minCorner.y < maxCorner.y,
            'minCorner coordinates must be strictly less than maxCorner coordinates.');

  /// The center position of the rectangular boundary.
  @override
  Vector2 get position => (minCorner + maxCorner) * 0.5;

  /// Checks if a given world-space [point] lies within or on the edges of
  /// this rectangular boundary.
  ///
  /// [point] The [Vector2] point to check.
  /// Returns `true` if the point is inside or on the boundary, `false` otherwise.
  bool containsPoint(Vector2 point) {
    return point.x >= minCorner.x &&
        point.x <= maxCorner.x &&
        point.y >= minCorner.y &&
        point.y <= maxCorner.y;
  }

  /// Calculates the width of the boundary rectangle.
  double get width => maxCorner.x - minCorner.x;

  /// Calculates the height of the boundary rectangle.
  double get height => maxCorner.y - minCorner.y;
}


// Potential future obstacle types:
// - PolygonObstacle (defined by a list of vertices)
// - OrientedBoundingBoxObstacle (rectangle with rotation)
