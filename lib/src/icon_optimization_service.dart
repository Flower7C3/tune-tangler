import 'package:flutter/material.dart';

/// Service for optimizing icons and images to improve rendering performance
class IconOptimizationService {
  static final IconOptimizationService _instance =
      IconOptimizationService._internal();
  factory IconOptimizationService() => _instance;
  IconOptimizationService._internal();

  // Cache for optimized icons
  final Map<String, IconData> _iconCache = {};

  // Cache for icon sizes
  final Map<String, double> _sizeCache = {};

  // Maximum cache size
  static const int _maxCacheSize = 100;

  /// Same numeric [IconData.codePoint] can exist in different icon fonts; cache keys must
  /// include font identity or glyphs resolve to the wrong font and may render blank.
  String _iconDataCacheKey(IconData icon) =>
      '${icon.codePoint}_${icon.fontFamily ?? ''}_${icon.fontPackage ?? ''}';

  /// Get optimized icon with caching
  IconData getOptimizedIcon(IconData icon, {String? key}) {
    final String cacheKey = key ?? _iconDataCacheKey(icon);

    if (_iconCache.containsKey(cacheKey)) {
      return _iconCache[cacheKey]!;
    }

    // Cache the icon
    _cacheIcon(cacheKey, icon);

    return icon;
  }

  /// Get optimized icon size based on context
  double getOptimizedIconSize(BuildContext context, IconSize size) {
    final String cacheKey = '${context.hashCode}_${size.name}';

    if (_sizeCache.containsKey(cacheKey)) {
      return _sizeCache[cacheKey]!;
    }

    final double iconSize = _calculateIconSize(context, size);

    // Cache the size
    _cacheSize(cacheKey, iconSize);

    return iconSize;
  }

  /// Calculate optimal icon size based on screen density and context
  double _calculateIconSize(BuildContext context, IconSize size) {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    final double devicePixelRatio = mediaQuery.devicePixelRatio;
    final double screenWidth = mediaQuery.size.width;

    // Base sizes for different icon types
    const Map<IconSize, double> baseSizes = {
      IconSize.tiny: 12.0,
      IconSize.small: 16.0,
      IconSize.medium: 24.0,
      IconSize.large: 32.0,
      IconSize.xlarge: 48.0,
    };

    double baseSize = baseSizes[size] ?? 24.0;

    // Adjust for screen density
    if (devicePixelRatio > 3.0) {
      baseSize *= 1.2; // High DPI screens
    } else if (devicePixelRatio < 2.0) {
      baseSize *= 0.8; // Low DPI screens
    }

    // Adjust for screen size
    if (screenWidth < 400) {
      baseSize *= 0.9; // Small screens
    } else if (screenWidth > 800) {
      baseSize *= 1.1; // Large screens
    }

    return baseSize;
  }

  /// Cache an icon
  void _cacheIcon(String key, IconData icon) {
    if (_iconCache.length >= _maxCacheSize) {
      // Remove oldest entry (simple FIFO)
      final String oldestKey = _iconCache.keys.first;
      _iconCache.remove(oldestKey);
    }

    _iconCache[key] = icon;
  }

  /// Cache an icon size
  void _cacheSize(String key, double size) {
    if (_sizeCache.length >= _maxCacheSize) {
      // Remove oldest entry (simple FIFO)
      final String oldestKey = _sizeCache.keys.first;
      _sizeCache.remove(oldestKey);
    }

    _sizeCache[key] = size;
  }

  /// Preload common icons for better performance
  void preloadIcons(List<IconData> icons) {
    for (int i = 0; i < icons.length; i++) {
      final String key = 'preload_$i';
      _cacheIcon(key, icons[i]);
    }
  }

  /// Clear icon cache
  void clearIconCache() {
    _iconCache.clear();
    debugPrint('IconOptimizationService: Icon cache cleared');
  }

  /// Clear size cache
  void clearSizeCache() {
    _sizeCache.clear();
    debugPrint('IconOptimizationService: Size cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedIcons': _iconCache.length,
      'cachedSizes': _sizeCache.length,
      'maxCacheSize': _maxCacheSize,
    };
  }

  /// Dispose the service
  void dispose() {
    clearIconCache();
    clearSizeCache();
  }
}

/// Icon size enumeration
enum IconSize { tiny, small, medium, large, xlarge }

/// Extension for IconData to easily get optimized icons
extension IconOptimizationExtension on IconData {
  /// Get optimized icon
  IconData get optimized => IconOptimizationService().getOptimizedIcon(this);

  /// Get optimized icon with custom key
  IconData optimizedWithKey(String key) =>
      IconOptimizationService().getOptimizedIcon(this, key: key);
}

/// Extension for BuildContext to easily get optimized icon sizes
extension IconSizeExtension on BuildContext {
  /// Get optimized icon size
  double getOptimizedIconSize(IconSize size) =>
      IconOptimizationService().getOptimizedIconSize(this, size);
}
