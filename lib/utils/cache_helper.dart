// lib/utils/cache_manager.dart
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class CacheManager {
  static CacheManager? _instance;
  static CacheManager get instance => _instance ??= CacheManager._();

  CacheManager._();

  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static final Map<String, int> _cacheHitCount = {};

  static const int DEFAULT_CACHE_HOURS = 24;
  static const int GEOCODING_CACHE_HOURS = 72;
  static const int COMPANY_DATA_CACHE_HOURS = 168;
  static const int ATTENDANCE_CACHE_HOURS = 2;
  static const int MAX_MEMORY_CACHE_SIZE = 100;
  static const int MAX_FILE_CACHE_SIZE_MB = 50;

  static const String MEMORY_CACHE_KEY = 'app_memory_cache';
  static const String CACHE_TIMESTAMPS_KEY = 'app_cache_timestamps';
  static const String CACHE_HIT_COUNT_KEY = 'app_cache_hit_count';

  Future<void> initialize() async {
    await _loadMemoryCacheFromStorage();
    await _scheduleCleanup();
  }

  Future<void> _loadMemoryCacheFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final cacheData = prefs.getString(MEMORY_CACHE_KEY);
      final timestampData = prefs.getString(CACHE_TIMESTAMPS_KEY);
      final hitCountData = prefs.getString(CACHE_HIT_COUNT_KEY);

      if (cacheData != null) {
        final cache = jsonDecode(cacheData) as Map<String, dynamic>;
        _memoryCache.addAll(cache);
      }

      if (timestampData != null) {
        final timestamps = jsonDecode(timestampData) as Map<String, dynamic>;
        timestamps.forEach((key, value) {
          _cacheTimestamps[key] = DateTime.parse(value);
        });
      }

      if (hitCountData != null) {
        final hitCounts = jsonDecode(hitCountData) as Map<String, dynamic>;
        hitCounts.forEach((key, value) {
          _cacheHitCount[key] = value as int;
        });
      }

      print('Cache loaded: ${_memoryCache.length} memory items');
    } catch (e) {
      print('Error loading cache: $e');
    }
  }

  /// Save cache from memory to persistent storage
  Future<void> _saveMemoryCacheToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Convert timestamps to strings
      final timestampStrings = <String, String>{};
      _cacheTimestamps.forEach((key, value) {
        timestampStrings[key] = value.toIso8601String();
      });

      await prefs.setString(MEMORY_CACHE_KEY, jsonEncode(_memoryCache));
      await prefs.setString(CACHE_TIMESTAMPS_KEY, jsonEncode(timestampStrings));
      await prefs.setString(CACHE_HIT_COUNT_KEY, jsonEncode(_cacheHitCount));
    } catch (e) {
      print('Error saving cache: $e');
    }
  }

  /// Get cached data with type safety
  T? get<T>(String key, {int? maxAgeHours}) {
    maxAgeHours ??= DEFAULT_CACHE_HOURS;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return null;

    final age = DateTime.now().difference(timestamp);
    if (age.inHours > maxAgeHours) {
      _removeFromCache(key);
      return null;
    }

    // Update hit count
    _cacheHitCount[key] = (_cacheHitCount[key] ?? 0) + 1;

    return _memoryCache[key] as T?;
  }

  /// Set cached data
  Future<void> set<T>(String key, T data, {int? maxAgeHours}) async {
    _memoryCache[key] = data;
    _cacheTimestamps[key] = DateTime.now();
    _cacheHitCount[key] = 0;

    // Check memory cache size and cleanup if needed
    if (_memoryCache.length > MAX_MEMORY_CACHE_SIZE) {
      await _cleanupLRU();
    }

    await _saveMemoryCacheToStorage();
  }

  /// Remove specific key from cache
  void _removeFromCache(String key) {
    _memoryCache.remove(key);
    _cacheTimestamps.remove(key);
    _cacheHitCount.remove(key);
  }

  /// Remove data from cache
  Future<void> remove(String key) async {
    _removeFromCache(key);
    await _saveMemoryCacheToStorage();
  }

  /// Check if key exists in cache and is valid
  bool has(String key, {int? maxAgeHours}) {
    maxAgeHours ??= DEFAULT_CACHE_HOURS;

    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;

    final age = DateTime.now().difference(timestamp);
    return age.inHours <= maxAgeHours;
  }

  /// Clean expired cache items
  Future<int> cleanupExpired() async {
    final now = DateTime.now();
    final expiredKeys = <String>[];

    _cacheTimestamps.forEach((key, timestamp) {
      if (now.difference(timestamp).inHours > DEFAULT_CACHE_HOURS) {
        expiredKeys.add(key);
      }
    });

    for (final key in expiredKeys) {
      _removeFromCache(key);
    }

    if (expiredKeys.isNotEmpty) {
      await _saveMemoryCacheToStorage();
    }

    return expiredKeys.length;
  }

  /// Clean cache using LRU (Least Recently Used) strategy
  Future<void> _cleanupLRU() async {
    final sortedByHits = _cacheHitCount.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));

    // Remove 20% of least used items
    final removeCount = (_memoryCache.length * 0.2).ceil();

    for (int i = 0; i < removeCount && i < sortedByHits.length; i++) {
      final key = sortedByHits[i].key;
      _removeFromCache(key);
    }
  }

  /// Clear all cache
  Future<void> clearAll() async {
    _memoryCache.clear();
    _cacheTimestamps.clear();
    _cacheHitCount.clear();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(MEMORY_CACHE_KEY);
    await prefs.remove(CACHE_TIMESTAMPS_KEY);
    await prefs.remove(CACHE_HIT_COUNT_KEY);

    // Also clear file cache
    await clearFileCache();
  }

  /// Clear file cache (images, temp files)
  Future<void> clearFileCache() async {
    try {
      final tempDir = await getTemporaryDirectory();
      final cacheDir = Directory('${tempDir.path}/cache');

      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
      }
    } catch (e) {
      print('Error clearing file cache: $e');
    }
  }

  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final totalSize = _memoryCache.length;
    final totalHits = _cacheHitCount.values.fold(0, (sum, hits) => sum + hits);

    final now = DateTime.now();
    final ageStats = <String, int>{};

    _cacheTimestamps.forEach((key, timestamp) {
      final ageHours = now.difference(timestamp).inHours;
      String ageGroup;

      if (ageHours < 1) {
        ageGroup = '< 1 hour';
      } else if (ageHours < 24) {
        ageGroup = '< 24 hours';
      } else if (ageHours < 168) {
        ageGroup = '< 1 week';
      } else {
        ageGroup = '> 1 week';
      }

      ageStats[ageGroup] = (ageStats[ageGroup] ?? 0) + 1;
    });

    return {
      'total_items': totalSize,
      'total_hits': totalHits,
      'age_distribution': ageStats,
      'memory_usage_mb': _estimateMemoryUsage(),
    };
  }

  /// Estimate memory usage in MB
  double _estimateMemoryUsage() {
    try {
      final jsonString = jsonEncode(_memoryCache);
      return jsonString.length / (1024 * 1024); // Convert to MB
    } catch (e) {
      return 0.0;
    }
  }

  /// Schedule automatic cleanup
  Future<void> _scheduleCleanup() async {
    // Clean expired items immediately
    await cleanupExpired();

    // Note: Timer.periodic tidak digunakan di sini karena akan dibuat di controller
    // yang menggunakan CacheManager
  }

  /// Cache with automatic retry mechanism
  Future<T> cacheWithRetry<T>(
    String key,
    Future<T> Function() fetchFunction, {
    int maxAgeHours = DEFAULT_CACHE_HOURS,
    int retryCount = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    // Try to get from cache first
    final cached = get<T>(key, maxAgeHours: maxAgeHours);
    if (cached != null) {
      return cached;
    }

    // Try to fetch with retry
    Exception? lastException;

    for (int i = 0; i < retryCount; i++) {
      try {
        final result = await fetchFunction();
        await set(key, result, maxAgeHours: maxAgeHours);
        return result;
      } catch (e) {
        lastException = e is Exception ? e : Exception(e.toString());
        if (i < retryCount - 1) {
          await Future.delayed(retryDelay);
        }
      }
    }

    // If all retries failed, check for stale cache
    final staleCache = get<T>(key, maxAgeHours: maxAgeHours * 2);
    if (staleCache != null) {
      print('Using stale cache for key: $key');
      return staleCache;
    }

    throw lastException ?? Exception('Failed to fetch data');
  }

  /// Preload cache with data
  Future<void> preloadCache(
      String key, Future<dynamic> Function() fetchFunction) async {
    try {
      if (!has(key)) {
        final data = await fetchFunction();
        await set(key, data);
      }
    } catch (e) {
      print('Preload failed for key $key: $e');
    }
  }

  /// Export cache data for debugging
  Map<String, dynamic> exportCacheData() {
    return {
      'cache_data': _memoryCache,
      'timestamps': _cacheTimestamps
          .map((key, value) => MapEntry(key, value.toIso8601String())),
      'hit_counts': _cacheHitCount,
      'stats': getStats(),
    };
  }

  /// Import cache data (for testing or migration)
  Future<void> importCacheData(Map<String, dynamic> data) async {
    try {
      _memoryCache.clear();
      _cacheTimestamps.clear();
      _cacheHitCount.clear();

      if (data['cache_data'] != null) {
        _memoryCache.addAll(data['cache_data']);
      }

      if (data['timestamps'] != null) {
        (data['timestamps'] as Map<String, dynamic>).forEach((key, value) {
          _cacheTimestamps[key] = DateTime.parse(value);
        });
      }

      if (data['hit_counts'] != null) {
        _cacheHitCount.addAll(Map<String, int>.from(data['hit_counts']));
      }

      await _saveMemoryCacheToStorage();
    } catch (e) {
      print('Error importing cache data: $e');
    }
  }
}
