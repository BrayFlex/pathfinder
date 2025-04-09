/// A Dart library for autonomous agent steering behaviors,
/// inspired by Craig Reynolds' work. Designed for performance, customization,
/// and modularity, compatible with Flame Engine.
library pathfinder;

// Core components
export 'src/agent.dart';
export 'src/steering_behavior.dart';
export 'src/steering_manager.dart';
export 'src/obstacle.dart';
export 'src/path.dart';
export 'src/flow_field.dart';
export 'src/utils/vector_utils.dart';

// Basic Behaviors
export 'src/behaviors/seek.dart';
export 'src/behaviors/flee.dart';
export 'src/behaviors/arrival.dart';
export 'src/behaviors/wander.dart';

// Advanced Behaviors
export 'src/behaviors/pursuit.dart';
export 'src/behaviors/evade.dart';
export 'src/behaviors/offset_pursuit.dart';
export 'src/behaviors/obstacle_avoidance.dart';
export 'src/behaviors/path_following.dart';
export 'src/behaviors/wall_following.dart';
export 'src/behaviors/containment.dart';
export 'src/behaviors/flow_field_following.dart';
export 'src/behaviors/unaligned_collision_avoidance.dart';

// Group Behaviors
export 'src/behaviors/separation.dart';
export 'src/behaviors/cohesion.dart';
export 'src/behaviors/alignment.dart';
export 'src/behaviors/flocking.dart';
export 'src/behaviors/leader_following.dart';

// Pathfinding Core
export 'src/pathfinding/grid.dart';
export 'src/pathfinding/node.dart';
export 'src/pathfinding/pathfinder_base.dart';
export 'src/pathfinding/heuristics.dart';
export 'src/pathfinding/pathfinding_utils.dart';

// Pathfinding Algorithms
export 'src/pathfinding/finders/astar_finder.dart';
export 'src/pathfinding/finders/best_first_finder.dart';
export 'src/pathfinding/finders/bfs_finder.dart';
export 'src/pathfinding/finders/dijkstra_finder.dart';
export 'src/pathfinding/finders/ida_star_finder.dart';
export 'src/pathfinding/finders/jps_finder.dart';
export 'src/pathfinding/finders/orthogonal_jps_finder.dart';
export 'src/pathfinding/finders/bi_astar_finder.dart';
export 'src/pathfinding/finders/bi_best_first_finder.dart';
export 'src/pathfinding/finders/bi_bfs_finder.dart';
export 'src/pathfinding/finders/bi_dijkstra_finder.dart';
