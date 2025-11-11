import 'package:flutter/foundation.dart';

/// Memory pool for audio buffers to reduce GC and memory leaks
class AudioMemoryPool {
  static final AudioMemoryPool _instance = AudioMemoryPool._internal();
  factory AudioMemoryPool() => _instance;
  AudioMemoryPool._internal();

  // Pool of reusable audio buffers
  final Map<int, List<Uint8List>> _bufferPools = {};

  // Maximum number of buffers to keep in each pool
  static const int _maxPoolSize = 10;

  // Buffer sizes to pool (common audio buffer sizes)
  static const List<int> _pooledSizes = [
    1024, // 1KB
    2048, // 2KB
    4096, // 4KB
    8192, // 8KB
    16384, // 16KB
    32768, // 32KB
    65536, // 64KB
  ];

  /// Get a buffer from the pool or create a new one
  Uint8List getBuffer(int size) {
    // Find the closest pooled size
    final int poolSize = _getClosestPooledSize(size);

    if (_bufferPools.containsKey(poolSize) &&
        _bufferPools[poolSize]!.isNotEmpty) {
      // Return buffer from pool
      return _bufferPools[poolSize]!.removeLast();
    }

    // Create new buffer if pool is empty
    return Uint8List(poolSize);
  }

  /// Return a buffer to the pool for reuse
  void returnBuffer(Uint8List buffer) {
    final int size = buffer.length;

    // Only pool buffers of supported sizes
    if (!_pooledSizes.contains(size)) {
      return;
    }

    if (!_bufferPools.containsKey(size)) {
      _bufferPools[size] = [];
    }

    // Limit pool size to prevent memory bloat
    if (_bufferPools[size]!.length < _maxPoolSize) {
      // Clear buffer content before returning to pool
      buffer.fillRange(0, buffer.length, 0);
      _bufferPools[size]!.add(buffer);
    }
  }

  /// Get the closest supported buffer size
  int _getClosestPooledSize(int requestedSize) {
    int closest = _pooledSizes.first;
    int minDiff = (requestedSize - closest).abs();

    for (int size in _pooledSizes) {
      int diff = (requestedSize - size).abs();
      if (diff < minDiff) {
        minDiff = diff;
        closest = size;
      }
    }

    return closest;
  }

  /// Clear all pools to free memory
  void clearPools() {
    _bufferPools.clear();
    debugPrint('AudioMemoryPool: All pools cleared');
  }

  /// Get pool statistics for debugging
  Map<String, dynamic> getPoolStats() {
    final Map<String, dynamic> stats = {};

    for (int size in _pooledSizes) {
      if (_bufferPools.containsKey(size)) {
        stats['${size}B'] = _bufferPools[size]!.length;
      } else {
        stats['${size}B'] = 0;
      }
    }

    return stats;
  }

  /// Dispose the memory pool
  void dispose() {
    clearPools();
  }
}

/// Extension for Uint8List to easily return buffers to pool
extension AudioBufferExtension on Uint8List {
  /// Return this buffer to the memory pool
  void returnToPool() {
    AudioMemoryPool().returnBuffer(this);
  }
}
