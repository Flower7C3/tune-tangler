import 'package:flutter/material.dart';

/// Manager for lazy loading UI components to improve performance
class LazyLoadingManager {
  static final LazyLoadingManager _instance = LazyLoadingManager._internal();
  factory LazyLoadingManager() => _instance;
  LazyLoadingManager._internal();

  // Cache for loaded components
  final Map<String, Widget> _componentCache = {};

  // Loading states
  final Map<String, bool> _loadingStates = {};

  // Maximum cache size
  static const int _maxCacheSize = 50;

  /// Lazy load a widget with caching
  Widget lazyLoadWidget({
    required String key,
    required Widget Function() builder,
    bool enableCache = true,
    Widget? placeholder,
  }) {
    if (enableCache && _componentCache.containsKey(key)) {
      return _componentCache[key]!;
    }

    if (_loadingStates[key] == true) {
      return placeholder ?? _buildLoadingPlaceholder();
    }

    // Mark as loading
    _loadingStates[key] = true;

    // Build component asynchronously
    return FutureBuilder<Widget>(
      future: Future.microtask(() {
        try {
          final component = builder();
          if (enableCache) {
            _cacheComponent(key, component);
          }
          _loadingStates[key] = false;
          return component;
        } catch (e) {
          _loadingStates[key] = false;
          debugPrint('LazyLoadingManager: Error building component: $e');
          return placeholder ?? _buildErrorPlaceholder();
        }
      }),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return placeholder ?? _buildLoadingPlaceholder();
        }

        if (snapshot.hasError) {
          return placeholder ?? _buildErrorPlaceholder();
        }

        return snapshot.data ?? (placeholder ?? _buildErrorPlaceholder());
      },
    );
  }

  /// Build loading placeholder
  Widget _buildLoadingPlaceholder() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  /// Build error placeholder
  Widget _buildErrorPlaceholder() {
    return const SizedBox(
      width: 100,
      height: 100,
      child: Center(
        child: Icon(Icons.error_outline, color: Colors.red, size: 24),
      ),
    );
  }

  /// Cache a component
  void _cacheComponent(String key, Widget component) {
    // Limit cache size
    if (_componentCache.length >= _maxCacheSize) {
      // Remove oldest entry (simple FIFO)
      final String oldestKey = _componentCache.keys.first;
      _componentCache.remove(oldestKey);
    }

    _componentCache[key] = component;
  }

  /// Preload components for better performance
  Future<void> preloadComponents(List<String> keys) async {
    for (String key in keys) {
      if (!_componentCache.containsKey(key)) {
        // Trigger lazy loading
        _loadingStates[key] = true;
      }
    }
  }

  /// Clear component cache
  void clearCache() {
    _componentCache.clear();
    _loadingStates.clear();
    debugPrint('LazyLoadingManager: Cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedComponents': _componentCache.length,
      'loadingComponents': _loadingStates.values
          .where((loading) => loading)
          .length,
      'maxCacheSize': _maxCacheSize,
    };
  }

  /// Dispose the manager
  void dispose() {
    clearCache();
  }
}

/// Mixin for lazy loading capabilities
mixin LazyLoadingMixin {
  final LazyLoadingManager _lazyLoadingManager = LazyLoadingManager();

  /// Lazy load a widget
  Widget lazyLoadWidget({
    required String key,
    required Widget Function() builder,
    bool enableCache = true,
    Widget? placeholder,
  }) {
    return _lazyLoadingManager.lazyLoadWidget(
      key: key,
      builder: builder,
      enableCache: enableCache,
      placeholder: placeholder,
    );
  }

  /// Preload components
  Future<void> preloadComponents(List<String> keys) async {
    await _lazyLoadingManager.preloadComponents(keys);
  }
}
