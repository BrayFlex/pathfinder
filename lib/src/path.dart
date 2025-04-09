import 'package:vector_math/vector_math_64.dart';

import 'behaviors/path_following.dart'; // For doc links

/// Represents a predefined path for agents to follow using [PathFollowing].
///
/// A path is defined by an ordered sequence of waypoints ([points]) connected
/// by straight line segments. It also has a [radius] defining the width of the
/// path corridor and a flag indicating whether the path [loop]s back to the start.
///
/// The [PathFollowing] behavior uses this object to guide an agent along the
/// defined route. Paths are immutable after creation; the list of points is
/// cloned and stored internally as an unmodifiable list.
///
/// ```dart
/// // Create a simple non-looping path
/// var waypoints = [ Vector2(0, 0), Vector2(100, 0), Vector2(100, 100) ];
/// var path = Path(points: waypoints, radius: 10.0);
///
/// // Create a looping path (e.g., a circuit)
/// var circuitPoints = [ Vector2(0,0), Vector2(50, 50), Vector2(0, 100), Vector2(-50, 50) ];
/// var loopingPath = Path(points: circuitPoints, radius: 5.0, loop: true);
///
/// // Use with PathFollowing behavior
/// var agent = MyAgent();
/// var pathFollow = PathFollowing(path: path, predictionDistance: 20.0);
/// agent.steeringManager.add(pathFollow);
/// ```
///
/// @seealso [PathFollowing]
class Path {
  /// The ordered sequence of [Vector2] waypoints defining the path segments.
  /// The path consists of line segments connecting `points[i]` to `points[i+1]`.
  /// If [loop] is true, an additional segment connects `points[last]` to `points[0]`.
  /// This list is unmodifiable after the Path object is created.
  final List<Vector2> points;

  /// The radius around the path's central spine (defined by the segments).
  /// The [PathFollowing] behavior attempts to keep the agent within this distance
  /// from the closest point on the path spine. Must be a positive value.
  final double radius;

  /// Indicates whether the path should loop back to the start after reaching the end.
  /// If `true`, a segment connects the last point in the [points] list back to
  /// the first point, forming a closed loop.
  /// If `false`, the path terminates at the last point.
  final bool loop;

  /// Creates a path defined by a sequence of waypoints.
  ///
  /// Throws an [AssertionError] if [points] contains fewer than 2 points,
  /// or if [radius] is not positive.
  ///
  /// [points] A list of [Vector2] points defining the path segments. The list
  ///   must contain at least two points. The provided list is cloned, and the
  ///   internal storage becomes unmodifiable.
  /// [radius] The width/radius of the path corridor around the segments.
  ///   Must be greater than 0. Defaults to `5.0`.
  /// [loop] If `true`, the path connects the last point back to the first,
  ///   forming a closed loop. Defaults to `false`.
  Path({
    required List<Vector2> points,
    this.radius = 5.0,
    this.loop = false,
  })  : assert(points.length >= 2, 'Path must have at least two points.'),
        assert(radius > 0, 'Path radius must be positive.'),
        // Clone the list and points to ensure immutability and prevent
        // external modification of the path's structure after creation.
        points = List<Vector2>.unmodifiable(points.map((p) => p.clone()));

  /// Gets the total number of line segments that make up the path.
  ///
  /// For a non-looping path with N points, there are `N - 1` segments.
  /// For a looping path with N points, there are `N` segments (as the last
  /// point connects back to the first).
  int get segmentCount => loop ? points.length : points.length - 1;

  /// Gets the starting waypoint ([Vector2]) of a specific path segment.
  ///
  /// [segmentIndex] The index of the desired segment (0-based). Must be less
  ///   than [segmentCount]. Handles wrapping for looping paths.
  /// Returns the [Vector2] point where the specified segment begins.
  Vector2 getSegmentStart(int segmentIndex) {
    // Use modulo to handle wrapping for looping paths correctly.
    // For non-looping paths, segmentIndex should be < points.length - 1 anyway.
    return points[segmentIndex % points.length];
  }

  /// Gets the ending waypoint ([Vector2]) of a specific path segment.
  ///
  /// [segmentIndex] The index of the desired segment (0-based). Must be less
  ///   than [segmentCount]. Handles wrapping for looping paths.
  /// Returns the [Vector2] point where the specified segment ends.
  Vector2 getSegmentEnd(int segmentIndex) {
    // Calculate the index of the next point, handling wrapping for loops.
    final endIndex = (segmentIndex + 1) % points.length;
    return points[endIndex];
  }
}
