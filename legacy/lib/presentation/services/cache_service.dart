import 'dart:convert';
import 'package:logger/logger.dart';

/// Сервис для работы с кэшированием данных
class CacheService {
  final StorageService _storageService;
  final Logger _logger;
  
  static const String _cachePrefix = 'cache_';
  static const String _cacheMetadataKey = 'cache_metadata';
  static const Duration _defaultExpiration = Duration(hours: 1);
  static const int _maxCacheSize = 100;
  
  CacheService(this._storageService) : _logger = Logger();

  /// Сохранение данных в кэш
  Future<void> setCache(String key, dynamic data, {Duration? expiration}) async {
    try {
      final cacheKey = _getCacheKey(key);
      final expiry = DateTime.now().add(expiration ?? _defaultExpiration);
      
      final cacheEntry = CacheEntry(
        data: data,
        timestamp: DateTime.now(),
        expiration: expiry,
        accessCount: 0,
      );
      
      // Сохраняем данные
      await _storageService.setString(cacheKey, jsonEncode(cacheEntry.toJson()));
      
      // Обновляем метаданные кэша
      await _updateCacheMetadata(key, expiry);
      
      _logger.d('Cache set: $key (expires: $expiry)');
    } catch (e) {
      _logger.e('Failed to set cache', error: e);
      rethrow;
    }
  }

  /// Получение данных из кэша
  Future<T?> getCache<T>(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      final cachedData = _storageService.getString(cacheKey);
      
      if (cachedData == null) {
        _logger.d('Cache miss: $key');
        return null;
      }
      
      final cacheEntry = CacheEntry.fromJson(jsonDecode(cachedData));
      
      // Проверяем срок действия
      if (DateTime.now().isAfter(cacheEntry.expiration)) {
        await removeCache(key);
        _logger.d('Cache expired: $key');
        return null;
      }
      
      // Обновляем счетчик обращений
      cacheEntry.accessCount++;
      await _storageService.setString(cacheKey, jsonEncode(cacheEntry.toJson()));
      
      _logger.d('Cache hit: $key (access count: ${cacheEntry.accessCount})');
      return cacheEntry.data as T;
    } catch (e) {
      _logger.e('Failed to get cache', error: e);
      return null;
    }
  }

  /// Удаление данных из кэша
  Future<void> removeCache(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      await _storageService.remove(cacheKey);
      
      // Удаляем из метаданных
      await _removeFromCacheMetadata(key);
      
      _logger.d('Cache removed: $key');
    } catch (e) {
      _logger.e('Failed to remove cache', error: e);
      rethrow;
    }
  }

  /// Очистка всего кэша
  Future<void> clearCache() async {
    try {
      final metadata = await _getCacheMetadata();
      
      // Удаляем все записи кэша
      for (final entry in metadata.entries) {
        await removeCache(entry.key);
      }
      
      // Очищаем метаданные
      await _storageService.remove(_cacheMetadataKey);
      
      _logger.i('Cache cleared successfully');
    } catch (e) {
      _logger.e('Failed to clear cache', error: e);
      rethrow;
    }
  }

  /// Очистка устаревших записей кэша
  Future<void> clearExpiredCache() async {
    try {
      final metadata = await _getCacheMetadata();
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      // Находим устаревшие записи
      for (final entry in metadata.entries) {
        if (now.isAfter(entry.value)) {
          expiredKeys.add(entry.key);
        }
      }
      
      // Удаляем устаревшие записи
      for (final key in expiredKeys) {
        await removeCache(key);
      }
      
      _logger.i('Cleared ${expiredKeys.length} expired cache entries');
    } catch (e) {
      _logger.e('Failed to clear expired cache', error: e);
      rethrow;
    }
  }

  /// Проверка существования записи в кэше
  Future<bool> hasCache(String key) async {
    try {
      final cacheKey = _getCacheKey(key);
      final cachedData = _storageService.getString(cacheKey);
      
      if (cachedData == null) {
        return false;
      }
      
      final cacheEntry = CacheEntry.fromJson(jsonDecode(cachedData));
      return !DateTime.now().isAfter(cacheEntry.expiration);
    } catch (e) {
      _logger.e('Failed to check cache existence', error: e);
      return false;
    }
  }

  /// Получение времени истечения кэша
  Future<DateTime?> getCacheExpiration(String key) async {
    try {
      final metadata = await _getCacheMetadata();
      return metadata[key];
    } catch (e) {
      _logger.e('Failed to get cache expiration', error: e);
      return null;
    }
  }

  /// Получение статистики кэша
  Future<CacheStatistics> getCacheStatistics() async {
    try {
      final metadata = await _getCacheMetadata();
      final now = DateTime.now();
      
      int totalEntries = metadata.length;
      int expiredEntries = 0;
      int validEntries = 0;
      
      for (final entry in metadata.entries) {
        if (now.isAfter(entry.value)) {
          expiredEntries++;
        } else {
          validEntries++;
        }
      }
      
      return CacheStatistics(
        totalEntries: totalEntries,
        validEntries: validEntries,
        expiredEntries: expiredEntries,
        cacheSize: await _getCacheSize(),
        lastCleanup: await _getLastCleanupTime(),
      );
    } catch (e) {
      _logger.e('Failed to get cache statistics', error: e);
      return CacheStatistics.empty();
    }
  }

  /// Оптимизация кэша (удаление старых записей)
  Future<void> optimizeCache() async {
    try {
      final metadata = await _getCacheMetadata();
      
      if (metadata.length <= _maxCacheSize) {
        _logger.d('Cache size is within limits, no optimization needed');
        return;
      }
      
      // Сортируем записи по времени истечения
      final sortedEntries = metadata.entries.toList()
        ..sort((a, b) => a.value.compareTo(b.value));
      
      // Удаляем старые записи
      final entriesToRemove = sortedEntries.take(metadata.length - _maxCacheSize);
      
      for (final entry in entriesToRemove) {
        await removeCache(entry.key);
      }
      
      _logger.i('Cache optimized: removed ${entriesToRemove.length} old entries');
    } catch (e) {
      _logger.e('Failed to optimize cache', error: e);
      rethrow;
    }
  }

  /// Получение ключа кэша
  String _getCacheKey(String key) {
    return '$_cachePrefix$key';
  }

  /// Обновление метаданных кэша
  Future<void> _updateCacheMetadata(String key, DateTime expiration) async {
    try {
      final metadata = await _getCacheMetadata();
      metadata[key] = expiration;
      await _storageService.setString(_cacheMetadataKey, jsonEncode(metadata));
    } catch (e) {
      _logger.e('Failed to update cache metadata', error: e);
    }
  }

  /// Удаление из метаданных кэша
  Future<void> _removeFromCacheMetadata(String key) async {
    try {
      final metadata = await _getCacheMetadata();
      metadata.remove(key);
      await _storageService.setString(_cacheMetadataKey, jsonEncode(metadata));
    } catch (e) {
      _logger.e('Failed to remove from cache metadata', error: e);
    }
  }

  /// Получение метаданных кэша
  Future<Map<String, DateTime>> _getCacheMetadata() async {
    try {
      final metadataJson = _storageService.getString(_cacheMetadataKey);
      if (metadataJson == null) {
        return {};
      }
      
      final metadata = jsonDecode(metadataJson) as Map<String, dynamic>;
      return metadata.map((key, value) => MapEntry(key, DateTime.parse(value as String)));
    } catch (e) {
      _logger.e('Failed to get cache metadata', error: e);
      return {};
    }
  }

  /// Получение размера кэша
  Future<int> _getCacheSize() async {
    try {
      final metadata = await _getCacheMetadata();
      return metadata.length;
    } catch (e) {
      _logger.e('Failed to get cache size', error: e);
      return 0;
    }
  }

  /// Получение времени последней очистки
  Future<DateTime?> _getLastCleanupTime() async {
    try {
      final lastCleanup = _storageService.getString('last_cache_cleanup');
      return lastCleanup != null ? DateTime.parse(lastCleanup) : null;
    } catch (e) {
      _logger.e('Failed to get last cleanup time', error: e);
      return null;
    }
  }

  /// Установка времени последней очистки
  Future<void> _setLastCleanupTime() async {
    try {
      await _storageService.setString('last_cache_cleanup', DateTime.now().toIso8601String());
    } catch (e) {
      _logger.e('Failed to set last cleanup time', error: e);
    }
  }
}

/// Запись кэша
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final DateTime expiration;
  int accessCount;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.expiration,
    this.accessCount = 0,
  });

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      'expiration': expiration.toIso8601String(),
      'accessCount': accessCount,
    };
  }

  factory CacheEntry.fromJson(Map<String, dynamic> json) {
    return CacheEntry(
      data: json['data'],
      timestamp: DateTime.parse(json['timestamp'] as String),
      expiration: DateTime.parse(json['expiration'] as String),
      accessCount: json['accessCount'] as int? ?? 0,
    );
  }
}

/// Статистика кэша
class CacheStatistics {
  final int totalEntries;
  final int validEntries;
  final int expiredEntries;
  final int cacheSize;
  final DateTime? lastCleanup;

  const CacheStatistics({
    required this.totalEntries,
    required this.validEntries,
    required this.expiredEntries,
    required this.cacheSize,
    this.lastCleanup,
  });

  factory CacheStatistics.empty() {
    return const CacheStatistics(
      totalEntries: 0,
      validEntries: 0,
      expiredEntries: 0,
      cacheSize: 0,
    );
  }

  /// Получение процента валидных записей
  double get validPercentage {
    if (totalEntries == 0) return 0.0;
    return (validEntries / totalEntries) * 100;
  }

  /// Получение процента устаревших записей
  double get expiredPercentage {
    if (totalEntries == 0) return 0.0;
    return (expiredEntries / totalEntries) * 100;
  }

  /// Проверка, нужна ли оптимизация кэша
  bool get needsOptimization => cacheSize > 100;

  Map<String, dynamic> toJson() {
    return {
      'totalEntries': totalEntries,
      'validEntries': validEntries,
      'expiredEntries': expiredEntries,
      'cacheSize': cacheSize,
      'validPercentage': validPercentage,
      'expiredPercentage': expiredPercentage,
      'needsOptimization': needsOptimization,
      'lastCleanup': lastCleanup?.toIso8601String(),
    };
  }
}
