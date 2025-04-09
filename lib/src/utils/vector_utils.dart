import 'dart:math'; // Import for sqrt
import 'package:vector_math/vector_math_64.dart';

/// Provides static utility functions for common operations on [Vector2] objects,
/// particularly those useful in steering behaviors and physics calculations.
class VectorUtils {
  /// Limits the magnitude (length) of a [Vector2] to a maximum value.
  ///
  /// If the current length of the [vector] exceeds [maxLength], the vector is
  /// scaled down proportionally so that its new length is exactly [maxLength].
  /// If the vector's length is already less than or equal to [maxLength], or if
  /// `maxLength` is non-positive, the vector remains unchanged (unless maxLength <= 0).
  ///
  /// This operation modifies the [vector] instance directly (in place).
  ///
  /// This is commonly used to clamp steering forces or velocities to their
  /// maximum allowed magnitudes (e.g., [Agent.maxForce], [Agent.maxSpeed]).
  ///
  /// [vector] The [Vector2] instance to truncate (modified in place).
  /// [maxLength] The maximum allowed magnitude for the vector. Must be non-negative.
  static void truncate(Vector2 vector, double maxLength) {
    // If maxLength is zero or negative, set the vector to zero.
    if (maxLength <= 0) {
      vector.setZero();
      return;
    }

    final lengthSquared = vector.length2;
    final maxLengthSquared = maxLength * maxLength;

    // Check if length exceeds max length (using squared values for efficiency)
    if (lengthSquared > maxLengthSquared) {
       // Since maxLength > 0 and lengthSquared > maxLengthSquared,
       // lengthSquared must be > 0. Therefore, length > 0.
       final length = sqrt(lengthSquared);
       // Scale the vector to the maxLength
       vector.scale(maxLength / length);
    }
    // If lengthSquared <= maxLengthSquared, do nothing.
  }

  // Add other potential vector utility functions here if needed later.
  // e.g., limit, setMagnitude, random direction, etc.
}
