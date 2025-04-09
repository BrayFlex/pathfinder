import 'package:test/test.dart';
import 'package:vector_math/vector_math_64.dart';
import 'package:pathfinder/src/agent.dart';
import 'package:pathfinder/src/flow_field.dart';
import 'package:pathfinder/src/behaviors/flow_field_following.dart';

// --- Mocks & Helpers ---

// MockAgent for testing FlowFieldFollowing
class MockFlowAgent implements Agent {
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

  MockFlowAgent({
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
    if (expected.isNaN || v.isNaN) return false;
    return (v.x - expected.x).abs() < tolerance &&
           (v.y - expected.y).abs() < tolerance;
  }, 'is close to ${expected.toString()} within $tolerance');
}

void main() {
  group('FlowFieldFollowing Behavior', () {
    late MockFlowAgent agent;
    late FlowField flowField;
    late FlowFieldFollowing behavior;
    const maxSpeed = 10.0;
    const predictionDistance = 20.0;

    // Setup a simple 2x1 flow field for testing
    // Origin (0,0), CellSize 10. Width 20, Height 10.
    // Cell (0,0) flows right (1,0)
    // Cell (1,0) flows up (0,1)
    setUp(() {
      agent = MockFlowAgent(
        position: Vector2(5.0, 5.0), // Center of cell (0,0)
        velocity: Vector2(0.0, maxSpeed), // Moving up initially
        maxSpeed: maxSpeed,
      );
      flowField = FlowField(origin: Vector2.zero(), cellSize: 10.0, columns: 2, rows: 1);
      flowField.setFlow(0, 0, Vector2(1.0, 0.0)); // Cell (0,0) -> Right
      flowField.setFlow(1, 0, Vector2(0.0, 1.0)); // Cell (1,0) -> Up

      // Default behavior: sample at current position
      behavior = FlowFieldFollowing(flowField: flowField);
    });

     test('constructor throws assertion error for negative predictionDistance', () {
       expect(() => FlowFieldFollowing(flowField: flowField, predictionDistance: -1.0),
            throwsA(isA<AssertionError>()));
       // Null and zero should be allowed
       expect(() => FlowFieldFollowing(flowField: flowField, predictionDistance: null), returnsNormally);
       expect(() => FlowFieldFollowing(flowField: flowField, predictionDistance: 0.0), returnsNormally);
    });

    test('samples at current position when predictionDistance is null', () {
      // Agent at (5,5) in cell (0,0), flow is (1,0)
      final steering = behavior.calculateSteering(agent);

      // Desired velocity = flow.normalized * maxSpeed = (1,0) * 10 = (10,0)
      final flow = flowField.lookup(agent.position); // Should be (1,0)
      final desiredVelocity = (flow.length2 > 1e-9 ? flow.normalized() : flow) * maxSpeed;
      // Steering = Desired - Current = (10, 0) - (0, 10) = (10, -10)
      final expectedSteering = desiredVelocity - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
    });

     test('samples at current position when predictionDistance is zero', () {
       behavior = FlowFieldFollowing(flowField: flowField, predictionDistance: 0.0);
       // Agent at (5,5) in cell (0,0), flow is (1,0)
       final steering = behavior.calculateSteering(agent);

       final flow = flowField.lookup(agent.position); // Should be (1,0)
       final desiredVelocity = (flow.length2 > 1e-9 ? flow.normalized() : flow) * maxSpeed;
       final expectedSteering = desiredVelocity - agent.velocity;

       expect(steering, vectorCloseTo(expectedSteering, 0.001));
     });

      test('samples at current position when agent velocity is zero', () {
       agent.velocity.setZero();
       behavior = FlowFieldFollowing(flowField: flowField, predictionDistance: predictionDistance); // Use prediction
       // Agent at (5,5) in cell (0,0), flow is (1,0)
       // Prediction cannot happen, samples at current position
       final steering = behavior.calculateSteering(agent);

       final flow = flowField.lookup(agent.position); // Should be (1,0)
       final desiredVelocity = (flow.length2 > 1e-9 ? flow.normalized() : flow) * maxSpeed;
       final expectedSteering = desiredVelocity - agent.velocity; // Vel is zero

       expect(steering, vectorCloseTo(expectedSteering, 0.001));
       expect(steering, vectorCloseTo(desiredVelocity, 0.001)); // Steering == Desired when vel is zero
     });

    test('samples at predicted position when predictionDistance is positive', () {
      behavior = FlowFieldFollowing(flowField: flowField, predictionDistance: predictionDistance);
      // Agent at (5,5), Vel (0, 10), PredDist 20 -> FuturePos (5, 25)
      final samplePos = agent.position + agent.velocity.normalized() * predictionDistance;
      final expectedFlow = flowField.lookup(samplePos); // Get the actual interpolated/clamped flow

      final steering = behavior.calculateSteering(agent);

      // Desired velocity = flow.normalized * maxSpeed
      final desiredVelocity = (expectedFlow.length2 > 1e-9 ? expectedFlow.normalized() : expectedFlow) * maxSpeed;
      // Steering = Desired - Current = desired - (0, 10)
      final expectedSteering = desiredVelocity - agent.velocity;

      expect(steering, vectorCloseTo(expectedSteering, 0.001));
    });

     test('samples at predicted position crossing cell boundary', () {
       behavior = FlowFieldFollowing(flowField: flowField, predictionDistance: predictionDistance);
       agent.position = Vector2(5.0, 5.0); // Cell (0,0)
       agent.velocity = Vector2(maxSpeed, 0.0); // Moving right
       // FuturePos = (5,5) + (1,0)*20 = (25, 5)
       final samplePos = agent.position + agent.velocity.normalized() * predictionDistance;
       final expectedFlow = flowField.lookup(samplePos); // Should interpolate towards (0,1)

       final steering = behavior.calculateSteering(agent);

       // Desired velocity = flow.normalized * maxSpeed
       final desiredVelocity = (expectedFlow.length2 > 1e-9 ? expectedFlow.normalized() : expectedFlow) * maxSpeed;
       // Steering = Desired - Current
       final expectedSteering = desiredVelocity - agent.velocity;

       expect(steering, vectorCloseTo(expectedSteering, 0.001));
     });

      test('returns zero force if flow field lookup returns zero', () {
        // Set flow in the target cell to zero
        flowField.setFlow(0, 0, Vector2.zero());
        behavior = FlowFieldFollowing(flowField: flowField); // Sample current pos
        agent.position = Vector2(5, 5); // Ensure agent is in cell (0,0)

        final steering = behavior.calculateSteering(agent);
        expect(steering, vectorCloseTo(Vector2.zero(), 0.001));

        // Test with prediction leading to zero flow cell
        // Need to ensure the predicted position *after clamping/interpolation* samples the zero flow
        // Let's put agent at (-5, 5) moving right. Prediction is (15, 5).
        agent.position = Vector2(-5, 5);
        agent.velocity = Vector2(maxSpeed, 0);
        behavior = FlowFieldFollowing(flowField: flowField, predictionDistance: predictionDistance);
        // FuturePos = (-5, 5) + (1,0)*20 = (15, 5) -> samples cell (1,0) which is (0,1) flow.
        // Let's set cell (1,0) to zero instead.
        flowField.setFlow(1, 0, Vector2.zero());
        // Now prediction (15,5) samples cell (1,0) which is zero.
        final steeringPred = behavior.calculateSteering(agent);
        expect(steeringPred, vectorCloseTo(Vector2.zero(), 0.001));
      });

  });
}
