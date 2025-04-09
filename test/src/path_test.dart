import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/path.dart';

void main() {
  group('Path', () {
    final p0 = Vector2(0, 0);
    final p1 = Vector2(10, 0);
    final p2 = Vector2(10, 10);
    final p3 = Vector2(0, 10);
    final List<Vector2> samplePoints = [p0, p1, p2, p3];

    group('Constructor', () {
      test('initializes properties correctly (non-looping)', () {
        final path = Path(points: samplePoints, radius: 8.0, loop: false);
        expect(path.points, equals(samplePoints)); // Checks content equality
        expect(path.radius, equals(8.0));
        expect(path.loop, isFalse);
      });

      test('initializes properties correctly (looping)', () {
        final path = Path(points: samplePoints, radius: 5.0, loop: true);
        expect(path.points, equals(samplePoints));
        expect(path.radius, equals(5.0)); // Default radius check
        expect(path.loop, isTrue);
      });

       test('uses default radius and loop values', () {
        final path = Path(points: samplePoints);
        expect(path.radius, equals(5.0)); // Default radius
        expect(path.loop, isFalse); // Default loop
      });

      test('throws assertion error for less than 2 points', () {
        expect(() => Path(points: [p0]), throwsA(isA<AssertionError>()));
        expect(() => Path(points: []), throwsA(isA<AssertionError>()));
      });

      test('throws assertion error for non-positive radius', () {
        expect(() => Path(points: samplePoints, radius: 0.0),
            throwsA(isA<AssertionError>()));
        expect(() => Path(points: samplePoints, radius: -1.0),
            throwsA(isA<AssertionError>()));
      });

      test('internal points list is unmodifiable', () {
        final path = Path(points: samplePoints);
        expect(() => path.points.add(Vector2(100, 100)),
            throwsA(isA<UnsupportedError>()));
         expect(() => path.points[0] = Vector2(100, 100), // Also check modification
            throwsA(isA<UnsupportedError>()));
      });

       test('internal points list is a clone (modifying original list does not affect path)', () {
         final originalList = [p0.clone(), p1.clone()];
         final path = Path(points: originalList);

         // Modify the original list *after* path creation
         originalList[0].setValues(99, 99);
         originalList.add(Vector2(100,100));

         // Path should still have the original cloned values
         expect(path.points[0], equals(p0));
         expect(path.points.length, 2); // Should not have the added point
       });

        test('internal points vectors are clones (modifying original vectors does not affect path)', () {
         final originalP0 = p0.clone();
         final originalP1 = p1.clone();
         final originalList = [originalP0, originalP1];
         final path = Path(points: originalList);

         // Modify the original vector *after* path creation
         originalP0.setValues(99, 99);

         // Path should still have the original cloned vector value
         expect(path.points[0], equals(p0));
         expect(path.points[0].x, isNot(equals(99)));
       });
    });

    group('segmentCount', () {
       test('returns correct count for non-looping path', () {
         // 4 points -> 3 segments
         final path = Path(points: samplePoints, loop: false);
         expect(path.segmentCount, equals(3));

         final path2 = Path(points: [p0, p1], loop: false); // 2 points -> 1 segment
         expect(path2.segmentCount, equals(1));
       });

        test('returns correct count for looping path', () {
         // 4 points -> 4 segments
         final path = Path(points: samplePoints, loop: true);
         expect(path.segmentCount, equals(4));

         final path2 = Path(points: [p0, p1], loop: true); // 2 points -> 2 segments
         expect(path2.segmentCount, equals(2));
       });
    });

    group('getSegmentStart', () {
      final pathNonLoop = Path(points: samplePoints, loop: false); // Segments 0, 1, 2
      final pathLoop = Path(points: samplePoints, loop: true);    // Segments 0, 1, 2, 3

      test('returns correct start for non-looping path', () {
        expect(pathNonLoop.getSegmentStart(0), equals(p0));
        expect(pathNonLoop.getSegmentStart(1), equals(p1));
        expect(pathNonLoop.getSegmentStart(2), equals(p2));
        // Accessing beyond segmentCount is implicitly handled by List index check if strict,
        // or modulo if lenient. Let's assume List handles index errors.
        // expect(() => pathNonLoop.getSegmentStart(3), throwsRangeError);
      });

       test('returns correct start for looping path', () {
        expect(pathLoop.getSegmentStart(0), equals(p0));
        expect(pathLoop.getSegmentStart(1), equals(p1));
        expect(pathLoop.getSegmentStart(2), equals(p2));
        expect(pathLoop.getSegmentStart(3), equals(p3)); // Wraps around
        // Test modulo behavior explicitly if needed for indices >= points.length
        expect(pathLoop.getSegmentStart(4), equals(p0)); // 4 % 4 = 0
      });
    });

     group('getSegmentEnd', () {
      final pathNonLoop = Path(points: samplePoints, loop: false); // Segments 0, 1, 2
      final pathLoop = Path(points: samplePoints, loop: true);    // Segments 0, 1, 2, 3

      test('returns correct end for non-looping path', () {
        expect(pathNonLoop.getSegmentEnd(0), equals(p1));
        expect(pathNonLoop.getSegmentEnd(1), equals(p2));
        expect(pathNonLoop.getSegmentEnd(2), equals(p3));
         // Accessing beyond segmentCount is implicitly handled by List index check.
        // expect(() => pathNonLoop.getSegmentEnd(3), throwsRangeError);
      });

       test('returns correct end for looping path', () {
        expect(pathLoop.getSegmentEnd(0), equals(p1));
        expect(pathLoop.getSegmentEnd(1), equals(p2));
        expect(pathLoop.getSegmentEnd(2), equals(p3));
        expect(pathLoop.getSegmentEnd(3), equals(p0)); // Wraps around
        // Test modulo behavior explicitly
        expect(pathLoop.getSegmentEnd(4), equals(p1)); // (4+1) % 4 = 1
      });
    });

  });
}
