import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/behaviors/offset_pursuit.dart';

// --- Mocks & Helpers ---

// MockAgent for testing OffsetPursuit (can be follower or leader)
class MockOffsetAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0; // Set high, behavior doesn't use it directly
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;

  MockOffsetAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op for behavior tests
  }
}

// Helper for vector comparison with tolerance
Matcher vectorCloseTo(Vector2 expected, double tolerance) {
  return predicate((v) {
    if (v is! Vector2) return false;
    if (expected.isNaN || v.isNaN) return false; // Handle NaN comparison
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

// Helper to calculate expected arrival force (used internally by OffsetPursuit)
// Note: This is for verification, the actual behavior uses its internal Arrival instance.
Vector2 calculateArrivalForce(Agent agent, Vector2 targetPosition, double slowingRadius, double arrivalTolerance) {
    final offsetToTarget = targetPosition - agent.position;
    final distance = offsetToTarget.length;

    if (distance < arrivalTolerance) {
      // Inside tolerance, apply braking force proportional to current velocity
      return -agent.velocity;
    }

    double desiredSpeed;
    if (distance < slowingRadius) {
      // Inside slowing radius, ramp down speed
      desiredSpeed = agent.maxSpeed * (distance / slowingRadius);
    } else {
      // Outside slowing radius, seek at max speed
      desiredSpeed = agent.maxSpeed;
    }

    // Avoid division by zero if distance is extremely small but not within tolerance
    if (distance < 1e-6) return Vector2.zero();

    final desiredVelocity = (offsetToTarget / distance) * desiredSpeed;
    final steeringForce = desiredVelocity - agent.velocity;
    return steeringForce;
}


void main() {
  group('OffsetPursuit Behavior', () {
    late MockOffsetAgent follower;
    late MockOffsetAgent leader;
    late OffsetPursuit offsetPursuit;
    const followerMaxSpeed = 10.0;
    const leaderSpeed = 5.0;
    const defaultSlowingRadius = 15.0;
    const defaultArrivalTolerance = 1.0;

    // Common offsets to test
    final offsetBehind = Vector2(-10.0, 0.0); // 10 units behind leader
    final offsetBeside = Vector2(0.0, 10.0);  // 10 units to leader's left
    final offsetDiag = Vector2(-5.0, 5.0);   // 5 behind, 5 left

    setUp(() {
      follower = MockOffsetAgent(
        position: Vector2.zero(),
        velocity: Vector2.zero(),
        maxSpeed: followerMaxSpeed,
      );
      leader = MockOffsetAgent(
        position: Vector2(100.0, 0.0), // Leader starts 100 units right
        velocity: Vector2(leaderSpeed, 0.0), // Leader moving right
        maxSpeed: leaderSpeed,
      );
      // Default setup: follow 10 units behind
      offsetPursuit = OffsetPursuit(
        targetAgent: leader,
        offset: offsetBehind.clone(),
        slowingRadius: defaultSlowingRadius,
        arrivalTolerance: defaultArrivalTolerance,
        // maxPredictionTime defaults to 1.0
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => OffsetPursuit(targetAgent: leader, offset: offsetBehind, slowingRadius: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => OffsetPursuit(targetAgent: leader, offset: offsetBehind, slowingRadius: -10.0),
            throwsA(isA<AssertionError>()));
       expect(() => OffsetPursuit(targetAgent: leader, offset: offsetBehind, arrivalTolerance: -0.1),
            throwsA(isA<AssertionError>()));
       expect(() => OffsetPursuit(targetAgent: leader, offset: offsetBehind, maxPredictionTime: -1.0),
            throwsA(isA<AssertionError>()));
       // Valid construction
       expect(() => OffsetPursuit(targetAgent: leader, offset: offsetBehind, slowingRadius: 1.0, arrivalTolerance: 0.0, maxPredictionTime: 0.0), returnsNormally);
    });

    test('calculates target point correctly when leader is stationary', () {
      leader.velocity.setZero(); // Stationary leader
      offsetPursuit = OffsetPursuit(targetAgent: leader, offset: offsetBeside); // Offset left

      // Expected target point = leaderPos + localOffset (since no rotation)
      final expectedTargetPoint = leader.position + offsetBeside; // (100, 0) + (0, 10) = (100, 10)

      final steering = offsetPursuit.calculateSteering(follower);
      // Should arrive towards (100, 10)
      final expectedArrival = calculateArrivalForce(follower, expectedTargetPoint, offsetPursuit.slowingRadius, offsetPursuit.arrivalTolerance);

      expect(steering, vectorCloseTo(expectedArrival, 0.001));
    });

    test('calculates target point correctly (offset behind, leader moving right)', () {
      // Leader at (100,0), Vel (5,0) -> Forward (1,0), Side (0,1)
      // Offset (-10, 0) -> WorldOffset = Fwd*(-10) + Side*0 = (-10, 0)
      // Prediction T = dist/speed = 100 / 10 = 10 (clamped by default maxPredictionTime=1.0)
      // final predictionTime = defaultMaxPrediction;
      // FuturePos = (100,0) + (5,0)*1 = (105, 0)
      // final futurePosition = leader.position + leader.velocity * predictionTime;
      // WorldOffsetPoint = FuturePos + WorldOffset = (105, 0) + (-10, 0) = (95, 0)
      final expectedTargetPoint = Vector2(95.0, 0.0);

      final steering = offsetPursuit.calculateSteering(follower);
      final expectedArrival = calculateArrivalForce(follower, expectedTargetPoint, offsetPursuit.slowingRadius, offsetPursuit.arrivalTolerance);

      expect(steering, vectorCloseTo(expectedArrival, 0.001));
    });

     test('calculates target point correctly (offset left, leader moving right)', () {
       offsetPursuit = OffsetPursuit(targetAgent: leader, offset: offsetBeside); // Offset (0, 10)
       // Leader at (100,0), Vel (5,0) -> Forward (1,0), Side (0,1)
       // Offset (0, 10) -> WorldOffset = Fwd*0 + Side*10 = (0, 10)
       // Prediction T = 1.0 (default clamp)
      //  final predictionTime = defaultMaxPrediction;
       // FuturePos = (105, 0)
      //  final futurePosition = leader.position + leader.velocity * predictionTime;
       // WorldOffsetPoint = FuturePos + WorldOffset = (105, 0) + (0, 10) = (105, 10)
       final expectedTargetPoint = Vector2(105.0, 10.0);

       final steering = offsetPursuit.calculateSteering(follower);
       final expectedArrival = calculateArrivalForce(follower, expectedTargetPoint, offsetPursuit.slowingRadius, offsetPursuit.arrivalTolerance);

       // Increase tolerance slightly due to potential floating point differences in internal vs helper calc
       expect(steering, vectorCloseTo(expectedArrival, 0.01));
     });

      test('calculates target point correctly (offset diag, leader moving up)', () {
       leader.position.setValues(0, 100); // Leader starts 100 units up
       leader.velocity.setValues(0, leaderSpeed); // Leader moving up -> Fwd(0,1), Side(-1,0)
       offsetPursuit = OffsetPursuit(targetAgent: leader, offset: offsetDiag); // Offset (-5, 5)

       // Prediction T = 100 / 10 = 10 (clamped to 1.0)
      //  final predictionTime = defaultMaxPrediction;
       // FuturePos = (0, 100) + (0, 5)*1 = (0, 105)
      //  final futurePosition = leader.position + leader.velocity * predictionTime;
       // WorldOffset = Fwd*(-5) + Side*5 = (0,-5) + (-5,0) = (-5, -5)
       // WorldOffsetPoint = FuturePos + WorldOffset = (0, 105) + (-5, -5) = (-5, 100)
       final expectedTargetPoint = Vector2(-5.0, 100.0);

       final steering = offsetPursuit.calculateSteering(follower);
       final expectedArrival = calculateArrivalForce(follower, expectedTargetPoint, offsetPursuit.slowingRadius, offsetPursuit.arrivalTolerance);

       // Increase tolerance slightly
       expect(steering, vectorCloseTo(expectedArrival, 0.01));
     });

     test('uses arrival logic (far from offset point)', () {
       // Setup: Follower far from calculated offset point (95, 0)
       follower.position = Vector2.zero(); // At origin
       final expectedTargetPoint = Vector2(95.0, 0.0); // Calculated in previous test

       final steering = offsetPursuit.calculateSteering(follower);
       // Should behave like seek (max speed towards target) as it's outside slowing radius
       final distance = follower.position.distanceTo(expectedTargetPoint);
       expect(distance, greaterThan(offsetPursuit.slowingRadius));

       final desired = (expectedTargetPoint - follower.position).normalized() * followerMaxSpeed;
       final expectedSteering = desired - follower.velocity; // follower.velocity is zero

       expect(steering, vectorCloseTo(expectedSteering, 0.001));
       expect(steering.length, closeTo(followerMaxSpeed, 0.001));
     });

      test('uses arrival logic (inside slowing radius)', () {
       // Setup: Follower close to calculated offset point (95, 0), inside slowing radius
       final expectedTargetPoint = Vector2(95.0, 0.0);
       final distanceToTarget = defaultSlowingRadius * 0.5; // 7.5
       follower.position = expectedTargetPoint + Vector2(-distanceToTarget, 0); // (87.5, 0)
       follower.velocity = Vector2.zero();

       final steering = offsetPursuit.calculateSteering(follower);
       // Should have ramped down speed.
       final expectedSpeed = followerMaxSpeed * (distanceToTarget / defaultSlowingRadius); // 10 * (7.5 / 15) = 5.0
       final desiredVelocity = (expectedTargetPoint - follower.position).normalized() * expectedSpeed; // (1,0) * 5.0 = (5,0)
       final expectedSteering = desiredVelocity - follower.velocity; // (5,0) - (0,0) = (5,0)

       // Increase tolerance slightly
       expect(steering, vectorCloseTo(expectedSteering, 0.01));
       expect(steering.length, closeTo(expectedSpeed, 0.01)); // Check magnitude
     });

      test('uses arrival logic (inside arrival tolerance)', () {
       // Setup: Follower very close to calculated offset point (95, 0)
       final expectedTargetPoint = Vector2(95.0, 0.0);
       final distanceToTarget = defaultArrivalTolerance * 0.5; // 0.5
       follower.position = expectedTargetPoint + Vector2(-distanceToTarget, 0); // (94.5, 0)
       follower.velocity = Vector2(1.0, 0.0); // Give it some velocity

       final steering = offsetPursuit.calculateSteering(follower);
       // Should apply braking force (-current velocity)
       final expectedBraking = -follower.velocity;
       // Increase tolerance slightly
       expect(steering, vectorCloseTo(expectedBraking, 0.01));
     });

      test('clamps prediction time with maxPredictionTime', () {
        // Leader at (100,0), Vel (5,0) -> Forward (1,0), Side (0,1)
        // Offset (-10, 0)
        // Follower at (0,0), Speed 10 -> Estimated T = 100/10 = 10
        final maxPrediction = 5.0; // Clamp T to 5
        offsetPursuit = OffsetPursuit(targetAgent: leader, offset: offsetBehind, maxPredictionTime: maxPrediction);

        // FuturePos = (100,0) + (5,0)*5 = (125, 0)
        // final futurePosition = leader.position + leader.velocity * maxPrediction;
        // WorldOffset = (-10, 0)
        // WorldOffsetPoint = (125, 0) + (-10, 0) = (115, 0)
        final expectedTargetPoint = Vector2(115.0, 0.0);

        final steering = offsetPursuit.calculateSteering(follower);
        final expectedArrival = calculateArrivalForce(follower, expectedTargetPoint, offsetPursuit.slowingRadius, offsetPursuit.arrivalTolerance);

        expect(steering, vectorCloseTo(expectedArrival, 0.001));
      });

  });
}
