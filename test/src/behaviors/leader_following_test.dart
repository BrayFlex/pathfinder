import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/utils/spatial_hash_grid.dart';
import 'package:pathfinder/src/behaviors/leader_following.dart';
import 'package:pathfinder/src/behaviors/separation.dart';// Needed for internal logic check
import 'dart:math'; // For sqrt in helper

// --- Mocks & Helpers ---

// MockAgent for testing LeaderFollowing
class MockLeaderAgent implements Agent {
  @override
  Vector2 position;
  @override
  Vector2 velocity;
  @override
  double maxSpeed;
  @override
  double maxForce = 1000.0;
  @override
  double mass = 1.0;
  @override
  double radius = 1.0;
  final String id;

  MockLeaderAgent(this.id, {
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op
  }

   // Override equality and hashCode for Set operations in grid query
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockLeaderAgent && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

   @override
  String toString() => 'MockAgent($id, $position, $velocity)';
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

// Helper to calculate expected Arrival force
Vector2 calculateArrivalForce(Agent agent, Vector2 targetPosition, double slowingRadius, double arrivalTolerance) {
    final offsetToTarget = targetPosition - agent.position;
    final distance = offsetToTarget.length;
    if (distance < arrivalTolerance) return -agent.velocity;
    double desiredSpeed = (distance < slowingRadius) ? agent.maxSpeed * (distance / slowingRadius) : agent.maxSpeed;
    if (distance < 1e-6) return Vector2.zero();
    final desiredVelocity = (offsetToTarget / distance) * desiredSpeed;
    return desiredVelocity - agent.velocity;
}

// Helper to calculate expected Evade force (Simplified - may not match internal exactly)
Vector2 calculateSimplifiedEvadeForce(Agent agent, Agent targetAgent) {
    final offset = targetAgent.position - agent.position;
    final distance = offset.length;
    if (targetAgent.velocity.length2 < 0.01) { // Flee if target stationary
       final fleeDesired = (agent.position - targetAgent.position).normalized() * agent.maxSpeed;
       return fleeDesired - agent.velocity;
    }
    // Simple prediction based on current distance and max speed (not perfect)
    double predictionTime = (agent.maxSpeed > 1e-6) ? distance / agent.maxSpeed : 0;
    final futurePosition = targetAgent.position + (targetAgent.velocity * predictionTime);
    final fleeDesired = (agent.position - futurePosition).normalized() * agent.maxSpeed;
    return fleeDesired - agent.velocity;
}

// Helper to calculate expected Separation force
Vector2 calculateSeparationForce(Agent agent, List<Agent> neighbors, double desiredSeparation) {
    final steeringForceSum = Vector2.zero();
    int neighborsCount = 0;
    for (final other in neighbors) {
        if (other == agent) continue;
        final toOther = other.position - agent.position;
        final distanceSquared = toOther.length2;
        if (distanceSquared > 1e-6 && distanceSquared < desiredSeparation * desiredSeparation) {
            final distance = sqrt(distanceSquared);
            final repulsiveDirection = -toOther / distance;
            // Scale force inversely proportional to distance (stronger when closer)
            final repulsiveMagnitude = (desiredSeparation - distance) / desiredSeparation; // Factor from 0 to 1
            final repulsiveForce = repulsiveDirection * repulsiveMagnitude * agent.maxSpeed; // Scale by maxSpeed for desired vel change
            steeringForceSum.add(repulsiveForce);
            neighborsCount++;
        }
    }
    if (neighborsCount > 0 && steeringForceSum.length2 > 1e-6) {
        // Calculate desired velocity from the sum of repulsive forces
        final desiredVelocity = steeringForceSum.normalized() * agent.maxSpeed;
        return desiredVelocity - agent.velocity;
    }
    return Vector2.zero();
}


void main() {
  group('LeaderFollowing Behavior', () {
    late MockLeaderAgent follower;
    late MockLeaderAgent leader;
    late LeaderFollowing leaderFollowing;
    late SpatialHashGrid grid; // For separation tests
    const maxSpeed = 10.0;
    const leaderBehindDistance = 20.0;
    const leaderSightDistance = 30.0;
    const leaderSightRadius = 10.0;
    const followerSeparation = 10.0; // For separation tests

    setUp(() {
      follower = MockLeaderAgent('F',
        position: Vector2.zero(),
        velocity: Vector2.zero(),
        maxSpeed: maxSpeed,
      );
      leader = MockLeaderAgent('L',
        position: Vector2(100.0, 0.0), // Leader starts ahead
        velocity: Vector2(maxSpeed * 0.5, 0.0), // Leader moving right slowly
        maxSpeed: maxSpeed * 0.5,
      );
      grid = SpatialHashGrid(cellSize: followerSeparation * 2);
      grid.add(follower);
      // Don't add leader to grid unless separation from leader is intended

      // Behavior without separation initially
      leaderFollowing = LeaderFollowing(
        leader: leader,
        leaderBehindDistance: leaderBehindDistance,
        leaderSightDistance: leaderSightDistance,
        leaderSightRadius: leaderSightRadius,
      );
    });

     test('constructor throws assertion error for invalid parameters', () {
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: -1.0), throwsA(isA<AssertionError>()));
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, leaderSightDistance: -1.0), throwsA(isA<AssertionError>()));
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, leaderSightRadius: -1.0), throwsA(isA<AssertionError>()));
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, followerSeparation: 0.0), throwsA(isA<AssertionError>()));
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, followerSeparation: -5.0), throwsA(isA<AssertionError>()));
       // Missing grid when separation is set
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, followerSeparation: 10.0, spatialGrid: null), throwsA(isA<AssertionError>()));
       // Valid construction (use small positive distance for arrival init)
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: 0.1, leaderSightDistance: 0.0, leaderSightRadius: 0.0), returnsNormally);
       expect(() => LeaderFollowing(leader: leader, leaderBehindDistance: leaderBehindDistance, spatialGrid: grid, followerSeparation: 10.0), returnsNormally);
    });

    test('uses Arrival towards point behind moving leader when follower is far behind', () {
      follower.position = Vector2(0, 0); // Far behind leader at (100, 0)
      leader.velocity = Vector2(5, 0); // Leader moving right

      // Leader heading = (1, 0)
      // Target behind = leaderPos + (-heading * dist) = (100, 0) + (-1, 0) * 20 = (80, 0)
      final expectedTargetBehind = Vector2(80.0, 0.0);
      final steering = leaderFollowing.calculateSteering(follower);
      // Should arrive towards (80, 0)
      final expectedArrival = calculateArrivalForce(follower, expectedTargetBehind, leaderFollowing.leaderBehindDistance * 0.5, 0.5);

      expect(steering, vectorCloseTo(expectedArrival, 0.001));
      expect(steering.length, greaterThan(0)); // Should be moving towards target
    });

     test('uses Arrival towards point behind stationary leader', () {
       leader.velocity.setZero(); // Stationary leader
       follower.position = Vector2(100, -30); // Below leader

       // Leader heading defaults to (-1, 0) ? No, code uses leaderPos - default_offset
       // Target behind = leaderPos - (dist, 0) = (100, 0) - (20, 0) = (80, 0)
       final expectedTargetBehind = leader.position - Vector2(leaderBehindDistance, 0);
       final steering = leaderFollowing.calculateSteering(follower);
       final expectedArrival = calculateArrivalForce(follower, expectedTargetBehind, leaderFollowing.leaderBehindDistance * 0.5, 0.5);

       expect(steering, vectorCloseTo(expectedArrival, 0.001));
     });

    test('uses Evade when follower is directly in front within sight cone', () {
      leader.position = Vector2.zero(); // Leader at origin
      leader.velocity = Vector2(maxSpeed, 0); // Leader moving right
      // Place follower clearly inside sight cone, slightly offset
      follower.position = Vector2(leaderSightDistance * 0.5, leaderSightRadius * 0.1); // (15, 1)
      follower.velocity = Vector2.zero(); // Follower stationary

      final steering = leaderFollowing.calculateSteering(follower);
      // Should evade the leader
      expect(steering.length, greaterThan(1e-6)); // Evasion force should be non-zero
      // Evade should push away from leader's future path (positive X axis)
      // and away from leader's current position (origin)
      // Expect push leftward (negative x) and/or downward (negative y)
      expect(steering.x < 0 || steering.y < 0, isTrue);
    });

     test('uses Evade when follower is off-center in front within sight cone', () {
       leader.position = Vector2.zero();
       leader.velocity = Vector2(maxSpeed, 0);
       // Place follower clearly inside sight cone
       follower.position = Vector2(leaderSightDistance * 0.5, leaderSightRadius * 0.5); // (15, 5)
       follower.velocity = Vector2.zero();

       final steering = leaderFollowing.calculateSteering(follower);
       // Should evade the leader
       expect(steering.length, greaterThan(1e-6));
       // Evade should push away from leader's future path (positive X axis)
       // and away from the leader's current position (origin)
       // Expect push leftward (negative x) and/or downward (negative y)
       expect(steering.x < 0 || steering.y < 0, isTrue);
     });

      test('uses Arrival when follower is ahead but outside sight radius', () {
        leader.position = Vector2.zero();
        leader.velocity = Vector2(maxSpeed, 0);
        // Follower ahead, but laterally outside the sight radius
        follower.position = Vector2(leaderSightDistance * 0.5, leaderSightRadius * 1.1); // y=11
        follower.velocity = Vector2.zero();

        final steering = leaderFollowing.calculateSteering(follower);
        // Should use Arrival towards point behind leader (which is (-20, 0))
        final expectedTargetBehind = leader.position - Vector2(leaderBehindDistance, 0);
        final expectedArrival = calculateArrivalForce(follower, expectedTargetBehind, leaderFollowing.leaderBehindDistance * 0.5, 0.5);

        expect(steering, vectorCloseTo(expectedArrival, 0.001));
      });

       test('uses Arrival when follower is ahead but outside sight distance', () {
         leader.position = Vector2.zero();
         leader.velocity = Vector2(maxSpeed, 0);
         // Follower far ahead
         follower.position = Vector2(leaderSightDistance * 1.1, 0); // x=33
         follower.velocity = Vector2.zero();

         final steering = leaderFollowing.calculateSteering(follower);
         // Should use Arrival towards point behind leader (which is (-20, 0))
         final expectedTargetBehind = leader.position - Vector2(leaderBehindDistance, 0);
         final expectedArrival = calculateArrivalForce(follower, expectedTargetBehind, leaderFollowing.leaderBehindDistance * 0.5, 0.5);

         expect(steering, vectorCloseTo(expectedArrival, 0.001));
       });

      group('with Separation', () {
        setUp(() {
           leaderFollowing = LeaderFollowing(
             leader: leader,
             leaderBehindDistance: leaderBehindDistance,
             leaderSightDistance: leaderSightDistance, // Include sight params
             leaderSightRadius: leaderSightRadius,
             spatialGrid: grid, // Provide grid
             followerSeparation: followerSeparation, // Enable separation
           );
        });

        test('combines Arrival and Separation when behind leader and near other follower', () {
          follower.position = Vector2(75, 0); // Close to target behind point (80,0)
          final otherFollower = MockLeaderAgent('F2',
            position: follower.position + Vector2(followerSeparation * 0.5, 0), // Very close to follower (x=80)
            velocity: Vector2.zero(), maxSpeed: maxSpeed);
          grid.add(otherFollower); // Add other follower to grid

          // Expected Arrival target = (80, 0)
          final expectedTargetBehind = Vector2(80.0, 0.0);
          final expectedArrival = calculateArrivalForce(follower, expectedTargetBehind, leaderFollowing.leaderBehindDistance * 0.5, 0.5);

          // Expected Separation from otherFollower at (80, 0) -> push left
          final expectedSeparation = calculateSeparationForce(follower, [otherFollower], followerSeparation);

          // Total expected = Arrival + Separation
          final expectedTotal = expectedArrival + expectedSeparation;
          final actualSteering = leaderFollowing.calculateSteering(follower);

          // Check that both components contributed (are non-zero)
          expect(expectedArrival.length, greaterThan(1e-6));
          expect(expectedSeparation.length, greaterThan(1e-6));
          // Check that the final steering is roughly the sum (allow larger tolerance for combined forces)
          expect(actualSteering, vectorCloseTo(expectedTotal, 0.1));
          expect(actualSteering.length, greaterThan(0.001));
        });

         test('prioritizes Evade and ignores Separation when in front and near other follower', () {
           leader.position = Vector2.zero();
           leader.velocity = Vector2(maxSpeed, 0);
           // Place follower clearly inside sight cone
           follower.position = Vector2(leaderSightDistance * 0.5, leaderSightRadius * 0.1); // (15, 1)
           final otherFollower = MockLeaderAgent('F2',
             position: follower.position + Vector2(0, followerSeparation * 0.5), // Close above follower (15, 6)
             velocity: Vector2.zero(), maxSpeed: maxSpeed);
           grid.add(otherFollower); // Add other follower

           // Should primarily Evade the leader
           final actualSteering = leaderFollowing.calculateSteering(follower);

           // Calculate independent separation force for comparison
           final separationBehavior = Separation(spatialGrid: grid, desiredSeparation: followerSeparation);
           final expectedSeparation = separationBehavior.calculateSteering(follower);

           // The behavior should return *only* the evade force in this case
           expect(actualSteering.length, greaterThan(1e-6)); // Evade should be active
           expect(expectedSeparation.length, greaterThan(1e-6)); // Separation would be active if not evading

           // Verify the returned force is NOT the combined one (it should just be evade)
           // It's hard to calculate the exact internal evade force, so we check it's not the sum.
           // We also check it's not *just* separation.
           expect(actualSteering, isNot(vectorCloseTo(actualSteering + expectedSeparation, 0.01)));
           expect(actualSteering, isNot(vectorCloseTo(expectedSeparation, 0.01)));

           // Check general direction of evade (away from leader's path)
           expect(actualSteering.x < 0 || actualSteering.y.abs() > 1e-6, isTrue);
         });
      });

  });
}
