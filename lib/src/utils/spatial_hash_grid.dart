import 'dart:collection'; // For HashMap
import 'package:vector_math/vector_math_64.dart';

import '../agent.dart';

/// A spatial hash grid for efficiently querying nearby agents.
/// Divides 2D space into cells for faster neighbor lookups.
class SpatialHashGrid {
  final double cellSize;
  late final double _inverseCellSize;
  final HashMap<int, List<Agent>> _buckets = HashMap();
  final HashMap<Agent, int> _agentBucketCache = HashMap();

  /// Creates a SpatialHashGrid. [cellSize] should generally be related
  /// to the maximum query radius used.
  SpatialHashGrid({required this.cellSize}) : assert(cellSize > 0) {
    _inverseCellSize = 1.0 / cellSize;
  }

  (int, int) _getBucketCoords(Vector2 position) {
    return ((position.x * _inverseCellSize).floor(), (position.y * _inverseCellSize).floor());
  }

  int _getBucketHash(int cx, int cy) {
    const p1 = 73856093; // Large primes for hashing
    const p2 = 19349663;
    return (cx * p1) ^ (cy * p2);
  }

  /// Adds an agent to the grid. Call this when an agent enters the simulation.
  void add(Agent agent) {
    final coords = _getBucketCoords(agent.position);
    final hash = _getBucketHash(coords.$1, coords.$2);
    _buckets.putIfAbsent(hash, () => []).add(agent);
    _agentBucketCache[agent] = hash;
  }

  /// Removes an agent from the grid. Call this when an agent leaves the simulation.
  bool remove(Agent agent) {
    final cachedHash = _agentBucketCache.remove(agent);
    if (cachedHash != null) {
      final bucket = _buckets[cachedHash];
      if (bucket != null) {
        final removed = bucket.remove(agent);
        if (bucket.isEmpty) _buckets.remove(cachedHash);
        return removed;
      }
    }
    return false;
  }

  /// Updates an agent's position if it moved to a new cell.
  /// Call this each frame/update cycle for moving agents.
  void update(Agent agent) {
    final currentCoords = _getBucketCoords(agent.position);
    final currentHash = _getBucketHash(currentCoords.$1, currentCoords.$2);
    final cachedHash = _agentBucketCache[agent];

    if (cachedHash != currentHash) {
      if (cachedHash != null) {
        final oldBucket = _buckets[cachedHash];
        oldBucket?.remove(agent);
        if (oldBucket != null && oldBucket.isEmpty) _buckets.remove(cachedHash);
      }
      // Add to new bucket and update cache
      _buckets.putIfAbsent(currentHash, () => []).add(agent);
      _agentBucketCache[agent] = currentHash;
    }
  }

  /// Finds agents within a specific radius of a position.
  List<Agent> queryRadius(Vector2 position, double radius) {
    // Return empty list immediately if radius is negative
    if (radius < 0) {
      return [];
    }
    final results = <Agent>{}; // Use Set to avoid duplicates
    final radiusSquared = radius * radius;
    final minCx = ((position.x - radius) * _inverseCellSize).floor();
    final maxCx = ((position.x + radius) * _inverseCellSize).floor();
    final minCy = ((position.y - radius) * _inverseCellSize).floor();
    final maxCy = ((position.y + radius) * _inverseCellSize).floor();

    for (int cy = minCy; cy <= maxCy; ++cy) {
      for (int cx = minCx; cx <= maxCx; ++cx) {
        final hash = _getBucketHash(cx, cy);
        final bucket = _buckets[hash];
        if (bucket != null) {
          for (final agent in bucket) {
            // Check actual distance as buckets are square
            if (agent.position.distanceToSquared(position) <= radiusSquared) {
              results.add(agent);
            }
          }
        }
      }
    }
    return results.toList();
  }

  /// Removes all agents from the grid.
  void clear() {
     _buckets.clear();
     _agentBucketCache.clear();
  }
}
