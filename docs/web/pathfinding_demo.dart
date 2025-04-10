/// Logic for the interactive pathfinding algorithms demo page.
///
/// Sets up different grid scenarios (simple, maze, random), allows users
/// to select various pathfinding algorithms from the `pathfinder` package,
/// runs the selected algorithm, and visualizes the grid, obstacles, start/end points,
/// and the calculated path on HTML canvases.

import 'dart:js_interop'; // Needed for JSString casting
import 'package:web/web.dart';
import 'dart:math';

import 'package:pathfinder/src/pathfinding/grid.dart'; // Use the package's Grid
import 'package:pathfinder/src/pathfinding/node.dart' as pf; // Use prefix 'pf'
import 'package:pathfinder/src/pathfinding/pathfinder_base.dart';
import 'package:pathfinder/src/pathfinding/finders/astar_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/best_first_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/bfs_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/dijkstra_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/ida_star_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/jps_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/orthogonal_jps_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_astar_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_best_first_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_bfs_finder.dart';
import 'package:pathfinder/src/pathfinding/finders/bi_dijkstra_finder.dart';
import 'package:pathfinder/src/pathfinding/heuristics.dart'; // For default heuristic if needed

// --- Constants ---

const double cellSize = 10.0; // Adjust as needed for canvas drawing

// --- Data Structures ---

// --- Scenario Generation ---

/// Holds the generated grid and the start/end points for a pathfinding scenario.
class ScenarioDefinition {
  /// The grid representing the map with walkable and non-walkable areas.
  final Grid grid;
  final Point<int> start;
  final Point<int> end;

  ScenarioDefinition(this.grid, this.start, this.end);
}

/// Creates a simple, small grid scenario with a few predefined obstacles.
ScenarioDefinition createSimpleScenario() {
  // Example: 18x18 grid (Increased by 20% from 15x15)
  final width = 18;
  final height = 18;
  final grid = Grid(width, height); // Use package Grid
  final start = Point(1, 1);
  final end = Point(width - 2, height - 2); // Adjust end point for new size

  // Add a few obstacles using setWalkableAt
  grid.setWalkableAt(3, 3, false);
  grid.setWalkableAt(3, 4, false);
  grid.setWalkableAt(3, 5, false);
  grid.setWalkableAt(4, 5, false);
  grid.setWalkableAt(5, 5, false);
  grid.setWalkableAt(6, 5, false);
  grid.setWalkableAt(6, 4, false);
  grid.setWalkableAt(6, 3, false);

  // Ensure start/end are walkable (Grid constructor makes all walkable initially)
  // No need to mark start/end within the grid data itself

  return ScenarioDefinition(grid, start, end);
}
/// Creates a moderately sized maze using a recursive backtracking algorithm.
ScenarioDefinition createMazeScenario() {
  final width = 35;
  final height = 35;
  final grid = Grid(width, height); // Use package Grid
  final start = Point(1, 1);
  final end = Point(width - 2, height - 2);

  final random = Random();

  // Initialize all internal cells as walls (not walkable)
  for (var x = 1; x < width - 1; x++) {
    for (var y = 1; y < height - 1; y++) {
      grid.setWalkableAt(x, y, false);
    }
  }

  // Start from a random odd cell
  final startX = 1 + 2 * random.nextInt((width - 2) ~/ 2);
  final startY = 1 + 2 * random.nextInt((height - 2) ~/ 2);

  // Carve out the initial position
  grid.setWalkableAt(startX, startY, true);

  // Directions: up, right, down, left
  const directions = [
    {'dx': 0, 'dy': -2}, // up
    {'dx': 2, 'dy': 0},  // right
    {'dx': 0, 'dy': 2},  // down
    {'dx': -2, 'dy': 0}  // left
  ];

  // Recursive backtracking function
  void carve(int x, int y) {
    // Shuffle directions
    final shuffled = List.of(directions)..shuffle(random);

    for (final dir in shuffled) {
      final nx = x + dir['dx']!;
      final ny = y + dir['dy']!;

      // Check if the new position is within bounds and a wall
      if (nx > 0 && nx < width - 1 && ny > 0 && ny < height - 1 && !grid.isWalkableAt(nx, ny)) {
        // Carve out the path between current cell and new cell
        grid.setWalkableAt(nx, ny, true);
        grid.setWalkableAt(x + dir['dx']! ~/ 2, y + dir['dy']! ~/ 2, true);

        // Recursively carve from the new position
        carve(nx, ny);
      }
    }
  }

  // Start carving
  carve(startX, startY);

  // Add some random openings to make it less perfect
  for (var i = 0; i < 100; i++) {
    int x, y;
    x = 1 + random.nextInt(width - 2);
    y = 1 + random.nextInt(height - 2);
    grid.setWalkableAt(x, y, true);
  }

  // Maze Walls
  for (int i = 0; i < width; i++) {
    grid.setWalkableAt(i, 0, false); // Top wall
    grid.setWalkableAt(i, height - 1, false); // Bottom wall
  }
   for (int i = 1; i < height - 1; i++) {
       grid.setWalkableAt(0, i, false); // Left wall
       grid.setWalkableAt(width - 1, i, false); // Right wall
   }

  return ScenarioDefinition(grid, start, end);
}
/// Creates a grid scenario with randomly placed obstacles.
ScenarioDefinition createRandomScenario() {
  final width = 30;
  final height = 30;
  final grid = Grid(width, height); // Use package Grid
  final random = Random();
  final obstaclePercentage = 0.33; // 33% obstacles

  // Place random obstacles
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      if (random.nextDouble() < obstaclePercentage) {
        grid.setWalkableAt(x, y, false);
      }
    }
  }

  Point<int> start, end;

  // Define random start and end points, ensuring they are walkable
  do {
    start = Point(random.nextInt(width), random.nextInt(height));
  } while (!grid.isWalkableAt(start.x, start.y));

  do {
    end = Point(random.nextInt(width), random.nextInt(height));
  } while (!grid.isWalkableAt(end.x, end.y) || end == start);

  // Ensure start/end remain walkable if obstacles were placed there
  grid.setWalkableAt(start.x, start.y, true);
  grid.setWalkableAt(end.x, end.y, true);

  return ScenarioDefinition(grid, start, end);
}

// --- Pathfinding Execution ---

/// Stores the results of a pathfinding operation.
class PathResult {
  /// The calculated path as a list of points, empty if no path found.
  final List<Point<int>> path;
  /// The time taken to execute the pathfinding algorithm.
  final Duration duration;
  /// The name of the algorithm used.
  final String algorithmName;
  /// Whether a path was successfully found.
  final bool pathFound;
  /// The number of nodes visited by the algorithm (Note: Currently not implemented in the core package).
  final int nodesVisitedCount;

  // Constructor with named required parameters
  PathResult({
    required this.path,
    required this.duration,
    required this.algorithmName,
    required this.pathFound,
    required this.nodesVisitedCount,
  });
}
/// Executes the specified pathfinding algorithm on the given scenario.
///
/// Takes a [ScenarioDefinition] and the [algorithmName] (string matching
/// the keys in the HTML select dropdown) as input.
/// Returns a [PathResult] containing the path, duration, and other metrics.
PathResult findPath(ScenarioDefinition scenario, String algorithmName) {
  final stopwatch = Stopwatch()..start();
  PathFinder finder; // Use the package's base class
  final grid = scenario.grid; // Use the package's Grid
  final start = scenario.start;
  final end = scenario.end;

  // Default options (can be customized per algorithm if needed)
  bool allowDiagonal = true; // Most algorithms benefit from this
  bool dontCrossCorners = true; // Safer option

  // Select the algorithm based on the name
  switch (algorithmName) {
    case 'AStarFinder':
      finder = AStarFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'BreadthFirstFinder':
      finder = BreadthFirstFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'DijkstraFinder':
      finder = DijkstraFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'JumpPointFinder':
      // JPS handles diagonal/corner rules internally. Only heuristic/weight are configurable.
      finder = JumpPointFinder(heuristic: Heuristics.octile); // Use a suitable heuristic like octile
      break;
    case 'IDAStarFinder':
        // Note: IDA* might require specific setup or tuning for optimal performance.
       finder = IDAStarFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'OrthogonalJumpPointFinder':
      finder = OrthogonalJumpPointFinder(); // Only orthogonal moves
      allowDiagonal = false; // Override for this finder
      break;
    case 'BiBreadthFirstFinder':
      finder = BiBreadthFirstFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'BiDijkstraFinder':
      finder = BiDijkstraFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'BestFirstFinder':
      finder = BestFirstFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'BiAStarFinder':
       finder = BiAStarFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    case 'BiBestFirstFinder':
       finder = BiBestFirstFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      break;
    default:
      // Unknown algorithm, default to A*
      finder = AStarFinder(allowDiagonal: allowDiagonal, dontCrossCorners: dontCrossCorners);
      algorithmName = 'AStarFinder (Defaulted)';
  }

  List<pf.Node?> nodePath = []; // Use pf.Node? to allow for potential nulls if API changes
  int visitedCount = 0; // Placeholder

  try {
      // Execute the pathfinding using the package's Grid
      nodePath = finder.findPath(start.x, start.y, end.x, end.y, grid);

      // Note: Extracting the actual visited node count would require modifications
      // to the core PathFinder package interface. It's currently reported as 0.

  } catch (e) {
      // Path remains empty, indicating failure
  }

  stopwatch.stop();

  // Convert List<Node> to List<Point<int>>
  // Add null assertions assuming nodes in the path are never null
  // Add null checks as nodePath can contain nulls
  final pointPath = nodePath
      .where((node) => node != null) // Filter out potential nulls
      .map((node) => Point(node!.x, node.y))
      .toList();

  return PathResult( // Call the constructor
    path: pointPath,
    duration: stopwatch.elapsed,
    algorithmName: algorithmName,
    pathFound: pointPath.isNotEmpty,
    nodesVisitedCount: visitedCount, // Pass the count
  );
}


// --- Canvas Rendering ---

/// Renders the pathfinding grid, obstacles, start/end points, and paths onto a canvas.
///
/// - [ctx]: The 2D rendering context of the target canvas.
/// - [scenario]: The [ScenarioDefinition] containing the grid and points.
/// - [currentResult]: The [PathResult] of the most recent pathfinding run (optional).
/// - [previousResult]: The [PathResult] of the run before the current one (optional), drawn fainter.
void renderGrid(CanvasRenderingContext2D ctx, ScenarioDefinition scenario, PathResult? currentResult, PathResult? previousResult) {
  final grid = scenario.grid; // Use package Grid
  final start = scenario.start;
  final end = scenario.end;
  final width = grid.width;
  final height = grid.height;
  // Use JS properties directly
  final canvasWidth = ctx.canvas.width;
  final canvasHeight = ctx.canvas.height;
  final cellWidth = canvasWidth / width;
  final cellHeight = canvasHeight / height;

  // Clear canvas
  ctx.clearRect(0, 0, canvasWidth, canvasHeight);

  // Draw grid cells
  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {
      final point = Point(x, y);
      if (point == start) {
         ctx.fillStyle = '#0f0'.toJS; // Cast to JSString
      } else if (point == end) {
         ctx.fillStyle = '#f00'.toJS; // Cast to JSString
      } else if (!grid.isWalkableAt(x, y)) {
        ctx.fillStyle = '#555'.toJS; // Cast to JSString
      } else {
        ctx.fillStyle = '#fff'.toJS; // Cast to JSString
      }

      ctx.fillRect(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
      ctx.strokeStyle = '#eee'.toJS; // Cast to JSString
      ctx.strokeRect(x * cellWidth, y * cellHeight, cellWidth, cellHeight);
    }
  }


  // Draw previous path (if found and different from current) - Uses List<Point<int>>
  if (previousResult != null && previousResult.pathFound && previousResult.path != currentResult?.path) {
    ctx.strokeStyle = '#888'.toJS; // Cast to JSString
    ctx.lineWidth = max(1.0, cellWidth / 5); // Slightly thinner
    ctx.beginPath();
    for (int i = 0; i < previousResult.path.length; i++) {
      final point = previousResult.path[i];
      final screenX = (point.x + 0.5) * cellWidth;
      final screenY = (point.y + 0.5) * cellHeight;
      if (i == 0) {
        ctx.moveTo(screenX, screenY);
      } else {
        ctx.lineTo(screenX, screenY);
      }
    }
    ctx.stroke();
  }

  // Draw current path (if found) - Uses List<Point<int>>
  if (currentResult != null && currentResult.pathFound) {
    ctx.strokeStyle = '#00f'.toJS; // Cast to JSString
    ctx.lineWidth = max(1.0, cellWidth / 4); // Adjust line width based on cell size
    ctx.beginPath();
    for (int i = 0; i < currentResult.path.length; i++) {
      final point = currentResult.path[i]; // Already a Point<int>
      final screenX = (point.x + 0.5) * cellWidth;
      final screenY = (point.y + 0.5) * cellHeight;
      if (i == 0) {
        ctx.moveTo(screenX, screenY);
      } else {
        ctx.lineTo(screenX, screenY);
      }
    }
    ctx.stroke();
    ctx.lineWidth = 1; // Reset line width
  }
}

// --- UI Interaction Setup ---

// Store current state and previous results for each scenario using maps
final Map<String, ScenarioDefinition> scenarioDefs = {};
final Map<String, PathResult?> previousResults = {};

/// Sets up a single pathfinding scenario panel (Simple, Maze, or Random).
///
/// Connects the canvas, algorithm selector, results display, and reload button (if applicable).

void setupScenario(String scenarioId, ScenarioDefinition Function() scenarioFactory, {bool isRandom = false}) {
  final canvas = document.querySelector('#${scenarioId}Canvas') as HTMLCanvasElement?;
  final algoSelect = document.querySelector('#${scenarioId}-algo-select') as HTMLSelectElement?;
  final resultsDiv = document.querySelector('#${scenarioId}-results pre') as HTMLPreElement?;
  final reloadMazeButton = document.querySelector('#reload-maze-scenario') as HTMLButtonElement?; // maze
  final reloadRandomButton = document.querySelector('#reload-random-scenario') as HTMLButtonElement?; // random
  final previousAlgoDiv = document.querySelector('#${scenarioId}-previous-algo') as HTMLDivElement?;

  if (canvas == null || algoSelect == null || resultsDiv == null || previousAlgoDiv == null) {
    // Silently fail if elements are missing, as main.dart handles page detection
    return;
  }

  // Get context using JS method
  final ctx = canvas.getContext('2d') as CanvasRenderingContext2D?;
  ScenarioDefinition currentScenario = scenarioFactory();

  // Store scenario definition globally
  scenarioDefs[scenarioId] = currentScenario;
  previousResults[scenarioId] = null; // Initialize previous result

  PathResult? currentResult; // Store current result within setupScenario scope

  void runAndRender() {
    // Store the previous result before calculating the new one
    final previousResult = previousResults[scenarioId];

    final selectedAlgorithm = algoSelect.value;
    currentResult = findPath(currentScenario, selectedAlgorithm); // Assign to outer scope variable

    // Update global previous result storage
    previousResults[scenarioId] = currentResult;

    // Update results text
    resultsDiv.textContent = '''
Algorithm: ${currentResult!.algorithmName}
Path Found: ${currentResult!.pathFound ? 'Yes' : 'No'}
Path Length: ${currentResult!.pathFound ? currentResult!.path.length : 'N/A'}
Nodes Visited: ${currentResult!.nodesVisitedCount} (Note: Count might be 0 if unavailable)
Time Taken: ${currentResult!.duration.inMicroseconds / 1000} ms
''';

    // Update previous algorithm text
    if (previousResult != null) {
        previousAlgoDiv.textContent = '(Previous: ${previousResult.algorithmName})';
    } else {
        previousAlgoDiv.textContent = ''; // Clear if no previous run
    }
    // Render the grid and path (pass both current and previous)
    if (ctx != null) { // Add null check for ctx
      renderGrid(ctx, currentScenario, currentResult, previousResult);
    }
  }

  // Event listener for algorithm selection
  algoSelect.onChange.listen((Event _) { // Add null check and specify Event type
    runAndRender();
  });

  // Generic reload logic for Maze and Random scenarios
  void handleReload() {
      currentScenario = scenarioFactory(); // Regenerate scenario
      scenarioDefs[scenarioId] = currentScenario; // Update global reference
      previousResults[scenarioId] = null; // Clear previous result on randomize
      previousAlgoDiv.textContent = ''; // Clear previous algo text
      runAndRender(); // Run default or selected algorithm on new grid
  }

  // Attach reload listener if applicable
  if (isRandom) {
    final button = (scenarioId == 'maze') ? reloadMazeButton : reloadRandomButton;
    button?.onClick.listen((Event _) => handleReload()); // Specify Event type
  }

  // Initial run
  runAndRender();
}

// Main setup function to be called from main.dart
void setupPathfindingDemo() {
setupScenario('simple', createSimpleScenario);
setupScenario('maze', createMazeScenario, isRandom: true);
setupScenario('random', createRandomScenario, isRandom: true);
}