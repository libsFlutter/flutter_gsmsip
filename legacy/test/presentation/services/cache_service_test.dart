import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:gostsimbox_gateway/presentation/services/cache_service.dart';
import 'package:gostsimbox_gateway/presentation/services/storage_service.dart';

import 'cache_service_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  group('CacheService', () {
    late CacheService cacheService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      cacheService = CacheService(mockStorageService);
    });

    group('setCache', () {
      test('should set cache with default expiration', () async {
        // Arrange
        const key = 'test_key';
        const data = 'test_data';

        // Act
        await cacheService.setCache(key, data);

        // Assert
        verify(mockStorageService.setString(any, any)).called(2); // cache + metadata
      });

      test('should set cache with custom expiration', () async {
        // Arrange
        const key = 'test_key';
        const data = 'test_data';
        const expiration = Duration(minutes: 30);

        // Act
        await cacheService.setCache(key, data, expiration: expiration);

        // Assert
        verify(mockStorageService.setString(any, any)).called(2);
      });

      test('should handle setCache error', () async {
        // Arrange
        when(mockStorageService.setString(any, any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => cacheService.setCache('key', 'data'),
          throwsException,
        );
      });
    });

    group('getCache', () {
      test('should return cached data when valid', () async {
        // Arrange
        const key = 'test_key';
        const data = 'test_data';
        final cacheEntry = CacheEntry(
          data: data,
          timestamp: DateTime.now(),
          expiration: DateTime.now().add(const Duration(hours: 1)),
          accessCount: 0,
        );

        when(mockStorageService.getString('cache_$key'))
            .thenReturn(cacheEntry.toJson().toString());

        // Act
        final result = await cacheService.getCache<String>(key);

        // Assert
        expect(result, equals(data));
        verify(mockStorageService.setString(any, any)).called(1); // Update access count
      });

      test('should return null when cache miss', () async {
        // Arrange
        const key = 'test_key';
        when(mockStorageService.getString('cache_$key'))
            .thenReturn(null);

        // Act
        final result = await cacheService.getCache<String>(key);

        // Assert
        expect(result, isNull);
      });

      test('should return null when cache expired', () async {
        // Arrange
        const key = 'test_key';
        final cacheEntry = CacheEntry(
          data: 'test_data',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          expiration: DateTime.now().subtract(const Duration(hours: 1)),
          accessCount: 0,
        );

        when(mockStorageService.getString('cache_$key'))
            .thenReturn(cacheEntry.toJson().toString());

        // Act
        final result = await cacheService.getCache<String>(key);

        // Assert
        expect(result, isNull);
        verify(mockStorageService.remove('cache_$key')).called(1);
      });

      test('should handle getCache error', () async {
        // Arrange
        when(mockStorageService.getString(any))
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await cacheService.getCache<String>('key');

        // Assert
        expect(result, isNull);
      });
    });

    group('removeCache', () {
      test('should remove cache entry', () async {
        // Arrange
        const key = 'test_key';

        // Act
        await cacheService.removeCache(key);

        // Assert
        verify(mockStorageService.remove('cache_$key')).called(1);
      });

      test('should handle removeCache error', () async {
        // Arrange
        when(mockStorageService.remove(any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => cacheService.removeCache('key'),
          throwsException,
        );
      });
    });

    group('clearCache', () {
      test('should clear all cache entries', () async {
        // Arrange
        final metadata = {
          'key1': DateTime.now().add(const Duration(hours: 1)),
          'key2': DateTime.now().add(const Duration(hours: 1)),
        };

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        await cacheService.clearCache();

        // Assert
        verify(mockStorageService.remove('cache_metadata')).called(1);
      });

      test('should handle clearCache error', () async {
        // Arrange
        when(mockStorageService.getString('cache_metadata'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => cacheService.clearCache(),
          throwsException,
        );
      });
    });

    group('clearExpiredCache', () {
      test('should clear expired cache entries', () async {
        // Arrange
        final metadata = {
          'expired_key': DateTime.now().subtract(const Duration(hours: 1)),
          'valid_key': DateTime.now().add(const Duration(hours: 1)),
        };

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        await cacheService.clearExpiredCache();

        // Assert
        verify(mockStorageService.remove('cache_expired_key')).called(1);
        verifyNever(mockStorageService.remove('cache_valid_key'));
      });

      test('should handle clearExpiredCache error', () async {
        // Arrange
        when(mockStorageService.getString('cache_metadata'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => cacheService.clearExpiredCache(),
          throwsException,
        );
      });
    });

    group('hasCache', () {
      test('should return true for valid cache', () async {
        // Arrange
        const key = 'test_key';
        final cacheEntry = CacheEntry(
          data: 'test_data',
          timestamp: DateTime.now(),
          expiration: DateTime.now().add(const Duration(hours: 1)),
          accessCount: 0,
        );

        when(mockStorageService.getString('cache_$key'))
            .thenReturn(cacheEntry.toJson().toString());

        // Act
        final result = await cacheService.hasCache(key);

        // Assert
        expect(result, isTrue);
      });

      test('should return false for expired cache', () async {
        // Arrange
        const key = 'test_key';
        final cacheEntry = CacheEntry(
          data: 'test_data',
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          expiration: DateTime.now().subtract(const Duration(hours: 1)),
          accessCount: 0,
        );

        when(mockStorageService.getString('cache_$key'))
            .thenReturn(cacheEntry.toJson().toString());

        // Act
        final result = await cacheService.hasCache(key);

        // Assert
        expect(result, isFalse);
      });

      test('should return false for cache miss', () async {
        // Arrange
        const key = 'test_key';
        when(mockStorageService.getString('cache_$key'))
            .thenReturn(null);

        // Act
        final result = await cacheService.hasCache(key);

        // Assert
        expect(result, isFalse);
      });
    });

    group('getCacheExpiration', () {
      test('should return expiration time', () async {
        // Arrange
        const key = 'test_key';
        final expiration = DateTime.now().add(const Duration(hours: 1));
        final metadata = {key: expiration};

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        final result = await cacheService.getCacheExpiration(key);

        // Assert
        expect(result, equals(expiration));
      });

      test('should return null for non-existent key', () async {
        // Arrange
        const key = 'test_key';
        final metadata = <String, DateTime>{};

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        final result = await cacheService.getCacheExpiration(key);

        // Assert
        expect(result, isNull);
      });
    });

    group('getCacheStatistics', () {
      test('should return correct statistics', () async {
        // Arrange
        final now = DateTime.now();
        final metadata = {
          'valid1': now.add(const Duration(hours: 1)),
          'valid2': now.add(const Duration(hours: 1)),
          'expired1': now.subtract(const Duration(hours: 1)),
          'expired2': now.subtract(const Duration(hours: 1)),
        };

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());
        when(mockStorageService.getString('last_cache_cleanup'))
            .thenReturn(now.subtract(const Duration(hours: 1)).toIso8601String());

        // Act
        final stats = await cacheService.getCacheStatistics();

        // Assert
        expect(stats.totalEntries, equals(4));
        expect(stats.validEntries, equals(2));
        expect(stats.expiredEntries, equals(2));
        expect(stats.validPercentage, equals(50.0));
        expect(stats.expiredPercentage, equals(50.0));
        expect(stats.needsOptimization, isFalse);
      });

      test('should return empty statistics when no cache', () async {
        // Arrange
        when(mockStorageService.getString('cache_metadata'))
            .thenReturn('{}');

        // Act
        final stats = await cacheService.getCacheStatistics();

        // Assert
        expect(stats.totalEntries, equals(0));
        expect(stats.validEntries, equals(0));
        expect(stats.expiredEntries, equals(0));
        expect(stats.validPercentage, equals(0.0));
        expect(stats.expiredPercentage, equals(0.0));
      });
    });

    group('optimizeCache', () {
      test('should optimize cache when size exceeds limit', () async {
        // Arrange
        final now = DateTime.now();
        final metadata = <String, DateTime>{};
        
        // Create more than 100 entries
        for (int i = 0; i < 120; i++) {
          metadata['key$i'] = now.add(Duration(hours: i));
        }

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        await cacheService.optimizeCache();

        // Assert
        // Should remove oldest entries to get down to 100
        verify(mockStorageService.remove(any)).called(20);
      });

      test('should not optimize cache when size is within limits', () async {
        // Arrange
        final now = DateTime.now();
        final metadata = <String, DateTime>{};
        
        // Create less than 100 entries
        for (int i = 0; i < 50; i++) {
          metadata['key$i'] = now.add(Duration(hours: i));
        }

        when(mockStorageService.getString('cache_metadata'))
            .thenReturn(metadata.toString());

        // Act
        await cacheService.optimizeCache();

        // Assert
        verifyNever(mockStorageService.remove(any));
      });
    });

    group('CacheEntry', () {
      test('should serialize and deserialize correctly', () {
        // Arrange
        final original = CacheEntry(
          data: 'test_data',
          timestamp: DateTime(2023, 1, 1, 12, 0, 0),
          expiration: DateTime(2023, 1, 1, 13, 0, 0),
          accessCount: 5,
        );

        // Act
        final json = original.toJson();
        final restored = CacheEntry.fromJson(json);

        // Assert
        expect(restored.data, equals(original.data));
        expect(restored.timestamp, equals(original.timestamp));
        expect(restored.expiration, equals(original.expiration));
        expect(restored.accessCount, equals(original.accessCount));
      });

      test('should handle missing accessCount in JSON', () {
        // Arrange
        final json = {
          'data': 'test_data',
          'timestamp': DateTime(2023, 1, 1, 12, 0, 0).toIso8601String(),
          'expiration': DateTime(2023, 1, 1, 13, 0, 0).toIso8601String(),
        };

        // Act
        final restored = CacheEntry.fromJson(json);

        // Assert
        expect(restored.accessCount, equals(0));
      });
    });

    group('CacheStatistics', () {
      test('should calculate percentages correctly', () {
        // Arrange
        const stats = CacheStatistics(
          totalEntries: 10,
          validEntries: 7,
          expiredEntries: 3,
          cacheSize: 10,
        );

        // Assert
        expect(stats.validPercentage, equals(70.0));
        expect(stats.expiredPercentage, equals(30.0));
      });

      test('should handle zero total entries', () {
        // Arrange
        const stats = CacheStatistics(
          totalEntries: 0,
          validEntries: 0,
          expiredEntries: 0,
          cacheSize: 0,
        );

        // Assert
        expect(stats.validPercentage, equals(0.0));
        expect(stats.expiredPercentage, equals(0.0));
      });

      test('should identify when optimization is needed', () {
        // Arrange
        const stats = CacheStatistics(
          totalEntries: 150,
          validEntries: 100,
          expiredEntries: 50,
          cacheSize: 150,
        );

        // Assert
        expect(stats.needsOptimization, isTrue);
      });

      test('should serialize to JSON correctly', () {
        // Arrange
        final now = DateTime.now();
        const stats = CacheStatistics(
          totalEntries: 10,
          validEntries: 7,
          expiredEntries: 3,
          cacheSize: 10,
          lastCleanup: null,
        );

        // Act
        final json = stats.toJson();

        // Assert
        expect(json['totalEntries'], equals(10));
        expect(json['validEntries'], equals(7));
        expect(json['expiredEntries'], equals(3));
        expect(json['cacheSize'], equals(10));
        expect(json['validPercentage'], equals(70.0));
        expect(json['expiredPercentage'], equals(30.0));
        expect(json['needsOptimization'], isFalse);
        expect(json['lastCleanup'], isNull);
      });

      test('should create empty statistics', () {
        // Act
        const stats = CacheStatistics.empty();

        // Assert
        expect(stats.totalEntries, equals(0));
        expect(stats.validEntries, equals(0));
        expect(stats.expiredEntries, equals(0));
        expect(stats.cacheSize, equals(0));
        expect(stats.lastCleanup, isNull);
      });
    });
  });
}
