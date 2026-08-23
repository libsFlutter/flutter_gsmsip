import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_gsm_sip_gateway/presentation/services/storage_service.dart';

// Генерируем моки
@GenerateMocks([SharedPreferences])
import 'storage_service_test.mocks.dart';

void main() {
  group('StorageService', () {
    late StorageService storageService;
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
      storageService = StorageService(mockPrefs);
    });

    group('String operations', () {
      test('should save string successfully', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockPrefs.setString(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setString(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString(key, value)).called(1);
      });

      test('should get string successfully', () {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockPrefs.getString(key)).thenReturn(value);

        // Act
        final result = storageService.getString(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getString(key)).called(1);
      });

      test('should return null when string not found', () {
        // Arrange
        const key = 'non_existent_key';
        when(mockPrefs.getString(key)).thenReturn(null);

        // Act
        final result = storageService.getString(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getString(key)).called(1);
      });

      test('should handle string save error', () async {
        // Arrange
        const key = 'test_key';
        const value = 'test_value';
        when(mockPrefs.setString(key, value)).thenThrow(Exception('Save error'));

        // Act
        final result = await storageService.setString(key, value);

        // Assert
        expect(result, isFalse);
        verify(mockPrefs.setString(key, value)).called(1);
      });
    });

    group('Integer operations', () {
      test('should save int successfully', () async {
        // Arrange
        const key = 'test_int_key';
        const value = 42;
        when(mockPrefs.setInt(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setInt(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setInt(key, value)).called(1);
      });

      test('should get int successfully', () {
        // Arrange
        const key = 'test_int_key';
        const value = 42;
        when(mockPrefs.getInt(key)).thenReturn(value);

        // Act
        final result = storageService.getInt(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getInt(key)).called(1);
      });

      test('should return null when int not found', () {
        // Arrange
        const key = 'non_existent_int_key';
        when(mockPrefs.getInt(key)).thenReturn(null);

        // Act
        final result = storageService.getInt(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getInt(key)).called(1);
      });
    });

    group('Boolean operations', () {
      test('should save bool successfully', () async {
        // Arrange
        const key = 'test_bool_key';
        const value = true;
        when(mockPrefs.setBool(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setBool(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setBool(key, value)).called(1);
      });

      test('should get bool successfully', () {
        // Arrange
        const key = 'test_bool_key';
        const value = true;
        when(mockPrefs.getBool(key)).thenReturn(value);

        // Act
        final result = storageService.getBool(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getBool(key)).called(1);
      });
    });

    group('String list operations', () {
      test('should save string list successfully', () async {
        // Arrange
        const key = 'test_list_key';
        const value = ['item1', 'item2', 'item3'];
        when(mockPrefs.setStringList(key, value)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setStringList(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setStringList(key, value)).called(1);
      });

      test('should get string list successfully', () {
        // Arrange
        const key = 'test_list_key';
        const value = ['item1', 'item2', 'item3'];
        when(mockPrefs.getStringList(key)).thenReturn(value);

        // Act
        final result = storageService.getStringList(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getStringList(key)).called(1);
      });
    });

    group('Object operations', () {
      test('should save object successfully', () async {
        // Arrange
        const key = 'test_object_key';
        final value = {'name': 'test', 'age': 25};
        when(mockPrefs.setString(key, any)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setObject(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString(key, any)).called(1);
      });

      test('should get object successfully', () {
        // Arrange
        const key = 'test_object_key';
        final value = {'name': 'test', 'age': 25};
        final jsonString = '{"name":"test","age":25}';
        when(mockPrefs.getString(key)).thenReturn(jsonString);

        // Act
        final result = storageService.getObject(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getString(key)).called(1);
      });

      test('should return null when object not found', () {
        // Arrange
        const key = 'non_existent_object_key';
        when(mockPrefs.getString(key)).thenReturn(null);

        // Act
        final result = storageService.getObject(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getString(key)).called(1);
      });
    });

    group('Object list operations', () {
      test('should save object list successfully', () async {
        // Arrange
        const key = 'test_object_list_key';
        final value = [
          {'name': 'item1', 'id': 1},
          {'name': 'item2', 'id': 2},
        ];
        when(mockPrefs.setString(key, any)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.setObjectList(key, value);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString(key, any)).called(1);
      });

      test('should get object list successfully', () {
        // Arrange
        const key = 'test_object_list_key';
        final value = [
          {'name': 'item1', 'id': 1},
          {'name': 'item2', 'id': 2},
        ];
        final jsonString = '[{"name":"item1","id":1},{"name":"item2","id":2}]';
        when(mockPrefs.getString(key)).thenReturn(jsonString);

        // Act
        final result = storageService.getObjectList(key);

        // Assert
        expect(result, equals(value));
        verify(mockPrefs.getString(key)).called(1);
      });
    });

    group('Utility operations', () {
      test('should remove key successfully', () async {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.remove(key)).thenAnswer((_) async => true);

        // Act
        final result = await storageService.remove(key);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.remove(key)).called(1);
      });

      test('should check if key exists', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.containsKey(key)).thenReturn(true);

        // Act
        final result = storageService.containsKey(key);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.containsKey(key)).called(1);
      });

      test('should get all keys', () {
        // Arrange
        final keys = {'key1', 'key2', 'key3'};
        when(mockPrefs.getKeys()).thenReturn(keys);

        // Act
        final result = storageService.getKeys();

        // Assert
        expect(result, equals(keys));
        verify(mockPrefs.getKeys()).called(1);
      });

      test('should clear all data', () async {
        // Arrange
        when(mockPrefs.clear()).thenAnswer((_) async => true);

        // Act
        final result = await storageService.clear();

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.clear()).called(1);
      });
    });

    group('Advanced operations', () {
      test('should check storage availability', () async {
        // Arrange
        when(mockPrefs.setString('_storage_test', 'test')).thenAnswer((_) async => true);
        when(mockPrefs.getString('_storage_test')).thenReturn('test');
        when(mockPrefs.remove('_storage_test')).thenAnswer((_) async => true);

        // Act
        final result = await storageService.isAvailable();

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.setString('_storage_test', 'test')).called(1);
        verify(mockPrefs.getString('_storage_test')).called(1);
        verify(mockPrefs.remove('_storage_test')).called(1);
      });

      test('should create backup successfully', () async {
        // Arrange
        final keys = {'key1', 'key2'};
        when(mockPrefs.getKeys()).thenReturn(keys);
        when(mockPrefs.get('key1')).thenReturn('value1');
        when(mockPrefs.get('key2')).thenReturn(42);

        // Act
        final result = await storageService.createBackup();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result.length, equals(2));
        expect(result['key1'], equals('value1'));
        expect(result['key2'], equals(42));
        verify(mockPrefs.getKeys()).called(1);
        verify(mockPrefs.get('key1')).called(1);
        verify(mockPrefs.get('key2')).called(1);
      });

      test('should restore from backup successfully', () async {
        // Arrange
        final backup = {
          'key1': 'value1',
          'key2': 42,
          'key3': true,
          'key4': ['item1', 'item2'],
        };
        when(mockPrefs.clear()).thenAnswer((_) async => true);
        when(mockPrefs.setString('key1', 'value1')).thenAnswer((_) async => true);
        when(mockPrefs.setInt('key2', 42)).thenAnswer((_) async => true);
        when(mockPrefs.setBool('key3', true)).thenAnswer((_) async => true);
        when(mockPrefs.setStringList('key4', ['item1', 'item2'])).thenAnswer((_) async => true);

        // Act
        final result = await storageService.restoreFromBackup(backup);

        // Assert
        expect(result, isTrue);
        verify(mockPrefs.clear()).called(1);
        verify(mockPrefs.setString('key1', 'value1')).called(1);
        verify(mockPrefs.setInt('key2', 42)).called(1);
        verify(mockPrefs.setBool('key3', true)).called(1);
        verify(mockPrefs.setStringList('key4', ['item1', 'item2'])).called(1);
      });

      test('should get storage statistics', () async {
        // Arrange
        final keys = {'key1', 'key2', 'key3'};
        when(mockPrefs.getKeys()).thenReturn(keys);
        when(mockPrefs.get('key1')).thenReturn('value1');
        when(mockPrefs.get('key2')).thenReturn(42);
        when(mockPrefs.get('key3')).thenReturn(true);

        // Act
        final result = await storageService.getStatistics();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['totalKeys'], equals(3));
        expect(result['isAvailable'], isA<bool>());
        expect(result['keyTypes'], isA<Map<String, int>>());
        verify(mockPrefs.getKeys()).called(1);
      });
    });

    group('Error handling', () {
      test('should handle getString error', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getString(key)).thenThrow(Exception('Get error'));

        // Act
        final result = storageService.getString(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getString(key)).called(1);
      });

      test('should handle getInt error', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getInt(key)).thenThrow(Exception('Get error'));

        // Act
        final result = storageService.getInt(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getInt(key)).called(1);
      });

      test('should handle getBool error', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getBool(key)).thenThrow(Exception('Get error'));

        // Act
        final result = storageService.getBool(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getBool(key)).called(1);
      });

      test('should handle getStringList error', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getStringList(key)).thenThrow(Exception('Get error'));

        // Act
        final result = storageService.getStringList(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getStringList(key)).called(1);
      });

      test('should handle getObject error with invalid JSON', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getString(key)).thenReturn('invalid json');

        // Act
        final result = storageService.getObject(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getString(key)).called(1);
      });

      test('should handle getObjectList error with invalid JSON', () {
        // Arrange
        const key = 'test_key';
        when(mockPrefs.getString(key)).thenReturn('invalid json');

        // Act
        final result = storageService.getObjectList(key);

        // Assert
        expect(result, isNull);
        verify(mockPrefs.getString(key)).called(1);
      });
    });
  });
}
