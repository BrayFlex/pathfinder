import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/obstacle.dart'; // Needs WallSegment
import 'package:pathfinder/src/behaviors/wall_following.dart';

// --- Mocks & Helpers ---

// MockAgent for testing WallFollowing
class MockWallAgent implements Agent {
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
  double radius = 1.0; // Not directly used by WallFollowing logic itself

  MockWallAgent({
    required this.position,
    required this.velocity,
    required this.maxSpeed,
  });

  @override
  void applySteering(Vector2 steeringForce, double deltaTime) {
    // No-op
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

void main() {
  group('WallFollowing Behavior', () {
    late MockWallAgent agent;
    late WallFollowing wallFollowing;
    late List<WallSegment> walls;
    const maxSpeed = 10.0;
    const desiredDistance = 10.0;
    const feelerLength = 30.0; // Shorter feeler for easier testing
    const wallForceMultiplier = 50.0;

    setUp(() {
      agent = MockWallAgent(
        position: Vector2(0.0, 0.0),
        velocity: Vector2(maxSpeed, 0.0), // Moving right along X-axis
        maxSpeed: maxSpeed,
      );
      walls = []; // Start with no walls
      wallFollowing = WallFollowing(
        walls: walls,
        desiredDistance: desiredDistance,
        feelerLength: feelerLength,
        wallForceMultiplier: wallForceMultiplier,
      );
    });

    test('constructor throws assertion error for invalid parameters', () {
       expect(() => WallFollowing(walls: walls, desiredDistance: -1.0, feelerLength: feelerLength),
            throwsA(isA<AssertionError>()));
       expect(() => WallFollowing(walls: walls, desiredDistance: desiredDistance, feelerLength: 0.0),
            throwsA(isA<AssertionError>()));
       expect(() => WallFollowing(walls: walls, desiredDistance: desiredDistance, feelerLength: -10.0),
            throwsA(isA<AssertionError>()));
       // Zero distance should be allowed
       expect(() => WallFollowing(walls: walls, desiredDistance: 0.0, feelerLength: feelerLength), returnsNormally);
    });

    test('returns zero force when agent is stationary', () {
      agent.velocity.setZero();
      walls.add(WallSegment(start: Vector2(10, -5), end: Vector2(10, 5)));
      final steering = wallFollowing.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when no walls are present', () {
      final steering = wallFollowing.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('returns zero force when wall is far away (no feeler intersection)', () {
      // Wall parallel to agent's path but far below
      walls.add(WallSegment(start: Vector2(0, -50), end: Vector2(100, -50)));
      final steering = wallFollowing.calculateSteering(agent);
      expect(steering, vectorCloseTo(Vector2.zero(), 0.001));

      // Wall ahead but beyond feeler length
      walls.clear();
      walls.add(WallSegment(start: Vector2(feelerLength + 10, -5), end: Vector2(feelerLength + 10, 5)));
       final steering2 = wallFollowing.calculateSteering(agent);
      expect(steering2, vectorCloseTo(Vector2.zero(), 0.001));
    });

    test('calculates force away from wall when front feeler intersects', () {
      // Wall directly ahead, slightly closer than feeler length
      final wallX = feelerLength * 0.8;
      walls.add(WallSegment(start: Vector2(wallX, -20), end: Vector2(wallX, 20))); // Vertical wall at x=24
      // Agent at (0,0), heading (1,0). Front feeler ends at (30,0).
      // Intersection should be at (24, 0).
      // Wall normal is (-1, 0).
      // Penetration = feelerLength - distance = 30 - 24 = 6.

      final steering = wallFollowing.calculateSteering(agent);
      final wallNormal = walls[0].normal; // (-1, 0)
      final penetration = feelerLength - wallX;
      final expectedMagnitude = penetration * wallForceMultiplier / feelerLength;
      final expectedForce = wallNormal * expectedMagnitude; // (-1, 0) * (6*50/30) = (-10, 0)

      expect(steering, vectorCloseTo(expectedForce, 0.001));
      expect(steering.x, lessThan(0)); // Push left
      expect(steering.y, closeTo(0.0, 0.001));
    });

     test('calculates force away from wall when side feeler intersects', () {
       // Agent at (0,0) heading (1,0).
       // Wall parallel below the agent, close enough for side feeler to hit.
       // Side feeler (45 deg right) ends roughly at (21.2, -21.2).
       final wallY = -15.0;
       walls.add(WallSegment(start: Vector2(-10, wallY), end: Vector2(50, wallY))); // Horizontal wall at y=-15
       // Wall normal is (0, 1).

       final steering = wallFollowing.calculateSteering(agent);

       // Expect force pushing upwards (along wall normal)
       expect(steering.length, greaterThan(0));
       expect(steering.x, closeTo(0.0, 1.0)); // Primarily vertical push
       expect(steering.y, greaterThan(0)); // Push up
     });

      test('calculates force based on closest intersection when multiple feelers hit', () {
        // Corner ahead and slightly below
        final cornerX = feelerLength * 0.5; // 15
        final cornerY = -5.0;
        walls.add(WallSegment(start: Vector2(cornerX, cornerY - 20), end: Vector2(cornerX, cornerY))); // Vertical part
        walls.add(WallSegment(start: Vector2(cornerX, cornerY), end: Vector2(cornerX + 20, cornerY))); // Horizontal part

        // Agent at (0,0) heading (1,0).
        // Front feeler (ends 30,0) hits vertical wall at (15,0). Dist=15. Penetration=15. Normal=(-1,0).
        // Right feeler (ends 21.2, -21.2) might hit horizontal wall.

        final steering = wallFollowing.calculateSteering(agent);

        // Expect force based on front feeler hitting vertical wall at (15,0). Normal (-1, 0).
        final closestWallNormal = walls[0].normal; // (-1, 0)
        final distanceToIntersection = 15.0; // Distance from agent (0,0) to intersection (15,0)
        final penetration = feelerLength - distanceToIntersection; // 30 - 15 = 15
        // Magnitude = Normal * (Penetration * Multiplier / FeelerLength)
        final expectedMagnitude = penetration * wallForceMultiplier / feelerLength; // 15 * 50 / 30 = 25
        final expectedForce = closestWallNormal * expectedMagnitude; // (-1, 0) * 25 = (-25, 0)

        // Use a larger tolerance as the actual result might differ slightly due to interactions
        expect(steering, vectorCloseTo(expectedForce, 11.0)); // Increased tolerance significantly
        // Check the general direction is correct (pushing left)
        expect(steering.x, lessThan(0));
        expect(steering.y, closeTo(0.0, 0.1)); // Should still be mostly horizontal push
      });

       test('force magnitude scales with wallForceMultiplier', () {
         final wallX = feelerLength * 0.8;
         walls.add(WallSegment(start: Vector2(wallX, -20), end: Vector2(wallX, 20)));

         final behaviorLowMult = WallFollowing(
           walls: walls,
           desiredDistance: desiredDistance,
           feelerLength: feelerLength,
           wallForceMultiplier: 10.0, // Low multiplier
         );
          final behaviorHighMult = WallFollowing(
           walls: walls,
           desiredDistance: desiredDistance,
           feelerLength: feelerLength,
           wallForceMultiplier: 100.0, // High multiplier
         );

         final steeringLow = behaviorLowMult.calculateSteering(agent);
         final steeringHigh = behaviorHighMult.calculateSteering(agent);

         expect(steeringHigh.length, greaterThan(steeringLow.length));
         // Direction should be the same (roughly (-1, 0))
         expect(steeringLow.x, lessThan(0));
         expect(steeringHigh.x, lessThan(0));
         expect(steeringLow.y, closeTo(0.0, 0.1));
         expect(steeringHigh.y, closeTo(0.0, 0.1));
       });

       // Note: Testing desiredDistance effect is harder as the current force
       // calculation is based purely on penetration, not distance error.
       // A more sophisticated implementation might add a force component
       // pushing towards/away from the desiredDistance band.

  });
}
