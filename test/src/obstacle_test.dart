import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/obstacle.dart';

void main() {
  group('Obstacles', () {
    group('CircleObstacle', () {
      final center = Vector2(10.0, 20.0);
      const radius = 5.0;

      test('constructor initializes properties correctly', () {
        final obstacle = CircleObstacle(position: center, radius: radius);
        expect(obstacle.position, equals(center));
        expect(obstacle.radius, equals(radius));
      });

      test('constructor throws assertion error for non-positive radius', () {
        expect(() => CircleObstacle(position: center, radius: 0.0),
            throwsA(isA<AssertionError>()));
        expect(() => CircleObstacle(position: center, radius: -1.0),
            throwsA(isA<AssertionError>()));
      });
    });

    group('WallSegment', () {
      final start = Vector2(10.0, 10.0);
      final end = Vector2(20.0, 10.0); // Horizontal wall

      test('constructor initializes properties correctly', () {
        final wall = WallSegment(start: start, end: end);
        expect(wall.start, equals(start));
        expect(wall.end, equals(end));
      });

      test('position getter calculates midpoint correctly', () {
        final wall = WallSegment(start: start, end: end);
        final expectedMidpoint = Vector2(15.0, 10.0);
        expect(wall.position.x, closeTo(expectedMidpoint.x, 0.001));
        expect(wall.position.y, closeTo(expectedMidpoint.y, 0.001));

        final wallVertical = WallSegment(start: Vector2(5, 5), end: Vector2(5, 15));
        final expectedMidpointVertical = Vector2(5.0, 10.0);
         expect(wallVertical.position.x, closeTo(expectedMidpointVertical.x, 0.001));
        expect(wallVertical.position.y, closeTo(expectedMidpointVertical.y, 0.001));
      });

      test('normal getter calculates correctly for horizontal wall', () {
        // Horizontal wall from (10,10) to (20,10) -> direction (10, 0)
        // Normal should point "left" relative to direction -> (0, 1)
        final wall = WallSegment(start: start, end: end);
        final normal = wall.normal;
        expect(normal.x, closeTo(0.0, 0.001));
        expect(normal.y, closeTo(1.0, 0.001));
        expect(normal.length, closeTo(1.0, 0.001)); // Should be normalized
      });

       test('normal getter calculates correctly for vertical wall', () {
        // Vertical wall from (5,5) to (5,15) -> direction (0, 10)
        // Normal should point "left" relative to direction -> (-1, 0)
        final wall = WallSegment(start: Vector2(5, 5), end: Vector2(5, 15));
        final normal = wall.normal;
        expect(normal.x, closeTo(-1.0, 0.001));
        expect(normal.y, closeTo(0.0, 0.001));
        expect(normal.length, closeTo(1.0, 0.001)); // Should be normalized
      });

       test('normal getter calculates correctly for diagonal wall', () {
        // Diagonal wall from (0,0) to (10,10) -> direction (10, 10)
        // Normal should point "left" relative to direction -> (-10, 10) -> normalized (-1/sqrt(2), 1/sqrt(2))
        final wall = WallSegment(start: Vector2.zero(), end: Vector2(10.0, 10.0));
        final normal = wall.normal;
        final invSqrt2 = 1.0 / 1.41421356; // sqrt(2)
        expect(normal.x, closeTo(-invSqrt2, 0.001));
        expect(normal.y, closeTo(invSqrt2, 0.001));
        expect(normal.length, closeTo(1.0, 0.001)); // Should be normalized
      });
    });

    group('RectangleBoundary', () {
      final min = Vector2(10.0, 20.0);
      final max = Vector2(30.0, 50.0);

      test('constructor initializes properties correctly', () {
        final boundary = RectangleBoundary(minCorner: min, maxCorner: max);
        expect(boundary.minCorner, equals(min));
        expect(boundary.maxCorner, equals(max));
      });

       test('constructor throws assertion error for invalid corners (min >= max)', () {
         // min.x == max.x
        expect(() => RectangleBoundary(minCorner: Vector2(30, 20), maxCorner: max),
            throwsA(isA<AssertionError>()));
         // min.y == max.y
         expect(() => RectangleBoundary(minCorner: Vector2(10, 50), maxCorner: max),
            throwsA(isA<AssertionError>()));
         // min.x > max.x
         expect(() => RectangleBoundary(minCorner: Vector2(31, 20), maxCorner: max),
            throwsA(isA<AssertionError>()));
         // min.y > max.y
         expect(() => RectangleBoundary(minCorner: Vector2(10, 51), maxCorner: max),
            throwsA(isA<AssertionError>()));
      });

      test('position getter calculates center correctly', () {
        final boundary = RectangleBoundary(minCorner: min, maxCorner: max);
        final expectedCenter = Vector2(20.0, 35.0);
        expect(boundary.position.x, closeTo(expectedCenter.x, 0.001));
        expect(boundary.position.y, closeTo(expectedCenter.y, 0.001));
      });

      test('width getter calculates correctly', () {
         final boundary = RectangleBoundary(minCorner: min, maxCorner: max);
         expect(boundary.width, closeTo(20.0, 0.001)); // 30 - 10
      });

       test('height getter calculates correctly', () {
         final boundary = RectangleBoundary(minCorner: min, maxCorner: max);
         expect(boundary.height, closeTo(30.0, 0.001)); // 50 - 20
      });

      test('containsPoint works correctly', () {
        final boundary = RectangleBoundary(minCorner: min, maxCorner: max);
        // Inside
        expect(boundary.containsPoint(Vector2(15.0, 30.0)), isTrue);
        expect(boundary.containsPoint(Vector2(29.9, 49.9)), isTrue);
        // On edges
        expect(boundary.containsPoint(Vector2(10.0, 30.0)), isTrue); // Left edge
        expect(boundary.containsPoint(Vector2(30.0, 30.0)), isTrue); // Right edge
        expect(boundary.containsPoint(Vector2(15.0, 20.0)), isTrue); // Top edge
        expect(boundary.containsPoint(Vector2(15.0, 50.0)), isTrue); // Bottom edge
        // On corners
        expect(boundary.containsPoint(min), isTrue);
        expect(boundary.containsPoint(max), isTrue);
        expect(boundary.containsPoint(Vector2(min.x, max.y)), isTrue);
        expect(boundary.containsPoint(Vector2(max.x, min.y)), isTrue);
        // Outside
        expect(boundary.containsPoint(Vector2(9.9, 30.0)), isFalse); // Left
        expect(boundary.containsPoint(Vector2(30.1, 30.0)), isFalse); // Right
        expect(boundary.containsPoint(Vector2(15.0, 19.9)), isFalse); // Above
        expect(boundary.containsPoint(Vector2(15.0, 50.1)), isFalse); // Below
        expect(boundary.containsPoint(Vector2.zero()), isFalse);
      });
    });
  });
}
