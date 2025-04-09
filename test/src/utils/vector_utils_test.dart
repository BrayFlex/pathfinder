import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/utils/vector_utils.dart';

// Helper for vector comparison with tolerance
Matcher vectorCloseTo(Vector2 expected, double tolerance) {
  return predicate((v) {
    if (v is! Vector2) return false;
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

void main() {
  group('VectorUtils', () {
    group('truncate', () {
      test('should truncate vector exceeding maxLength', () {
        final vec = Vector2(3.0, 4.0); // Length 5.0
        const maxLength = 3.0;
        VectorUtils.truncate(vec, maxLength);
        expect(vec.length, closeTo(maxLength, 0.001));
        // Check direction is preserved (proportional to original)
        expect(vec.x / vec.y, closeTo(3.0 / 4.0, 0.001));
        expect(vec.x, closeTo(1.8, 0.001)); // 3.0 * (3/5)
        expect(vec.y, closeTo(2.4, 0.001)); // 4.0 * (3/5)
      });

      test('should not change vector below or equal to maxLength', () {
        final vec1 = Vector2(1.0, 1.0); // Length sqrt(2) approx 1.414
        final originalVec1 = vec1.clone();
        VectorUtils.truncate(vec1, 2.0); // maxLength > length
        expect(vec1, vectorCloseTo(originalVec1, 0.001));

        final vec2 = Vector2(3.0, 0.0); // Length 3.0
        final originalVec2 = vec2.clone();
        VectorUtils.truncate(vec2, 3.0); // maxLength == length
        expect(vec2, vectorCloseTo(originalVec2, 0.001));
      });

      test('should set vector to zero when maxLength is zero', () {
        final vec = Vector2(3.0, 4.0);
        VectorUtils.truncate(vec, 0.0);
        expect(vec.x, closeTo(0.0, 0.001));
        expect(vec.y, closeTo(0.0, 0.001));
        expect(vec.length, closeTo(0.0, 0.001));
      });

      test('should set vector to zero when maxLength is negative', () {
        final vec = Vector2(3.0, 4.0);
        VectorUtils.truncate(vec, -5.0);
        expect(vec.x, closeTo(0.0, 0.001));
        expect(vec.y, closeTo(0.0, 0.001));
        expect(vec.length, closeTo(0.0, 0.001));
      });

       test('should handle zero vector correctly', () {
         final vec = Vector2.zero();
         final originalVec = vec.clone();
         VectorUtils.truncate(vec, 5.0); // Truncate zero vector
         expect(vec, vectorCloseTo(originalVec, 0.001)); // Should remain zero

         VectorUtils.truncate(vec, 0.0); // Truncate zero vector with zero max
         expect(vec, vectorCloseTo(originalVec, 0.001)); // Should remain zero
       });

       test('should handle near-zero vectors when truncating', () {
         final vec = Vector2(1e-10, -1e-10); // Very small vector
         final originalLength = vec.length;
         expect(originalLength, greaterThan(0));

         // Truncate to a larger length - should remain unchanged
         final originalVec = vec.clone();
         VectorUtils.truncate(vec, 1.0);
         expect(vec, vectorCloseTo(originalVec, 1e-15));

         // Truncate to a smaller non-zero length - should scale down
         final vec2 = Vector2(1e-10, -1e-10);
         final targetLength = 1e-12;
         VectorUtils.truncate(vec2, targetLength);
         expect(vec2.length, closeTo(targetLength, 1e-15));

         // Truncate to zero length - should become zero
         final vec3 = Vector2(1e-10, -1e-10);
         VectorUtils.truncate(vec3, 0.0);
         expect(vec3.length, closeTo(0.0, 1e-15)); // Corrected expectation
       });

    });
  });
}
