import 'package:test/test.dart';
import 'package:pathfinder/src/pathfinding/node.dart';

void main() {
  group('Node', () {
    const x = 5;
    const y = 10;

    group('Constructor', () {
      test('initializes with coordinates and default properties', () {
        final node = Node(x, y);
        expect(node.x, equals(x));
        expect(node.y, equals(y));
        expect(node.isWalkable, isTrue);
        expect(node.weight, equals(1.0));
      });

      test('initializes with custom walkable and weight properties', () {
        final node = Node(x, y, isWalkable: false, weight: 3.5);
        expect(node.isWalkable, isFalse);
        expect(node.weight, equals(3.5));
      });

       test('throws assertion error for weight less than 1.0', () {
        expect(() => Node(x, y, weight: 0.9), throwsA(isA<AssertionError>()));
        expect(() => Node(x, y, weight: 0.0), throwsA(isA<AssertionError>()));
        expect(() => Node(x, y, weight: -1.0), throwsA(isA<AssertionError>()));
        // Weight 1.0 should be allowed
        expect(() => Node(x, y, weight: 1.0), returnsNormally);
      });

      test('initializes pathfinding state to default values', () {
         final node = Node(x, y);
         expect(node.g, equals(0));
         expect(node.h, equals(0));
         expect(node.f, equals(0)); // g + h
         expect(node.parent, isNull);
         expect(node.opened, isFalse);
         expect(node.closed, isFalse);
         // Internal state _lastResetSearchId is not directly testable without helpers/reflection
      });
    });

     group('f getter', () {
       test('calculates f = g + h correctly', () {
         final node = Node(x, y);
         node.g = 10.5;
         node.h = 5.2;
         expect(node.f, closeTo(15.7, 0.001));

         node.g = 0;
         node.h = 0;
         expect(node.f, equals(0));
       });
     });

    group('Reset Logic', () {
      late Node node;
      late Node parentNode;

      setUp(() {
        node = Node(x, y, isWalkable: false, weight: 2.0);
        parentNode = Node(x - 1, y);
        // Set some non-default pathfinding state
        node.g = 10.0;
        node.h = 5.0;
        node.parent = parentNode;
        node.opened = true;
        node.closed = true;
        // Simulate it being reset for searchId 0 initially
        node.reset(0);
         // Re-set state after initial reset
        node.g = 10.0;
        node.h = 5.0;
        node.parent = parentNode;
        node.opened = true;
        node.closed = true;
      });

      test('resetIfNeeded resets state for a new searchId', () {
        const newSearchId = 1;
        final wasReset = node.resetIfNeeded(newSearchId);

        expect(wasReset, isTrue);
        // Check state is reset
        expect(node.g, equals(0));
        expect(node.h, equals(0));
        expect(node.f, equals(0));
        expect(node.parent, isNull);
        expect(node.opened, isFalse);
        expect(node.closed, isFalse);
        // Structural properties should remain unchanged
        expect(node.isWalkable, isFalse);
        expect(node.weight, equals(2.0));
      });

       test('resetIfNeeded does not reset state for the same searchId', () {
         const currentSearchId = 0; // Same as the initial reset in setUp
         final wasReset = node.resetIfNeeded(currentSearchId);

         expect(wasReset, isFalse);
         // Check state remains unchanged from setUp
         expect(node.g, equals(10.0));
         expect(node.h, equals(5.0));
         expect(node.f, equals(15.0));
         expect(node.parent, equals(parentNode));
         expect(node.opened, isTrue);
         expect(node.closed, isTrue);
       });

        test('resetIfNeeded resets state correctly on subsequent different searchIds', () {
          // Reset for search 1
          node.resetIfNeeded(1);
          // Set state again for search 1
          node.g = 20; node.h = 10; node.parent = parentNode; node.opened = true;

          // Reset for search 2
          final wasReset = node.resetIfNeeded(2);
          expect(wasReset, isTrue);
          expect(node.g, equals(0));
          expect(node.h, equals(0));
          expect(node.parent, isNull);
          expect(node.opened, isFalse);
          expect(node.closed, isFalse);

          // Calling again for search 2 should do nothing
           final wasResetAgain = node.resetIfNeeded(2);
           expect(wasResetAgain, isFalse);
           expect(node.g, equals(0)); // Still reset state
       });

       test('reset method forces reset regardless of searchId', () {
          const currentSearchId = 0; // Same ID as initial reset
          node.reset(currentSearchId); // Force reset

          // Check state is reset
          expect(node.g, equals(0));
          expect(node.h, equals(0));
          expect(node.f, equals(0));
          expect(node.parent, isNull);
          expect(node.opened, isFalse);
          expect(node.closed, isFalse);
       });
    });

    group('Equality and HashCode', () {
      test('nodes with same coordinates are equal', () {
        final node1 = Node(x, y);
        final node2 = Node(x, y, isWalkable: false, weight: 5.0); // Different properties
        expect(node1 == node2, isTrue);
      });

      test('nodes with different x coordinates are not equal', () {
         final node1 = Node(x, y);
         final node2 = Node(x + 1, y);
         expect(node1 == node2, isFalse);
      });

       test('nodes with different y coordinates are not equal', () {
         final node1 = Node(x, y);
         final node2 = Node(x, y + 1);
         expect(node1 == node2, isFalse);
      });

       test('hashCode is consistent for equal nodes', () {
         final node1 = Node(x, y);
         final node2 = Node(x, y, isWalkable: false);
         expect(node1.hashCode, equals(node2.hashCode));
       });

        test('hashCode is different for unequal nodes', () {
         final node1 = Node(x, y);
         final node2 = Node(x + 1, y);
         final node3 = Node(x, y + 1);
         expect(node1.hashCode, isNot(equals(node2.hashCode)));
         expect(node1.hashCode, isNot(equals(node3.hashCode)));
         // Note: Hash collisions are possible but unlikely for simple coordinates.
       });
    });

     group('toString', () {
       test('provides a reasonable string representation', () {
         final node = Node(3, 7, isWalkable: false, weight: 2.0);
         expect(node.toString(), equals('Node(3, 7, walkable: false, weight: 2.0)'));

         final defaultNode = Node(1, 2);
          expect(defaultNode.toString(), equals('Node(1, 2, walkable: true, weight: 1.0)'));
       });
     });
  });
}
