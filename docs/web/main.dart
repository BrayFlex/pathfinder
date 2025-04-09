import 'package:web/web.dart' as web; // Use prefix 'web'

import 'pathfinding_demo.dart';
import 'steering_demo.dart';

/// Main entry point for the Pathfinder web demos.
///
/// Detects which demo page is currently loaded based on unique HTML element IDs
/// and initializes the corresponding Dart logic.
void main() {
  // Check which demo page is loaded and run its setup
  // Check if the pathfinding demo container exists to initialize that demo.
  if (web.document.querySelector('#pathfinding-scenario-container') != null) {
    setupPathfindingDemo();
  // Otherwise, check if the steering demo canvas exists to initialize that demo.
  } else if (web.document.querySelector('#steeringCanvas') != null) {
    setupSteeringDemo();
  } else {
    // If neither specific demo element is found, do nothing further.
  }
}