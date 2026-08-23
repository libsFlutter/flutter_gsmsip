import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с локальным хранилищем
class StorageService {
  final SharedPreferences _prefs;
  final Logger _logger;

  StorageService(this._prefs) : _logger = Logger();

  /// Сохранение строкового значения
  Future<bool> setString(String key, String value) async {
    try {
      final result = await _prefs.setString(key, value);
      _logger.d('Saved string: $key = $value');
      return result;
    } catch (e) {
      _logger.e('Failed to save string: $key', error: e);
      return false;
    }
  }

  /// Получение строкового значения
  String? getString(String key) {
    try {
      final value = _prefs.getString(key);
      _logger.d('Retrieved string: $key = $value');
      return value;
    } catch (e) {
      _logger.e('Failed to get string: $key', error: e);
      return null;
    }
  }

  /// Сохранение целочисленного значения
  Future<bool> setInt(String key, int value) async {
    try {
      final result = await _prefs.setInt(key, value);
      _logger.d('Saved int: $key = $value');
      return result;
    } catch (e) {
      _logger.e('Failed to save int: $key', error: e);
      return false;
    }
  }

  /// Получение целочисленного значения
  int? getInt(String key) {
    try {
      final value = _prefs.getInt(key);
      _logger.d('Retrieved int: $key = $value');
      return value;
    } catch (e) {
      _logger.e('Failed to get int: $key', error: e);
      return null;
    }
  }

  /// Сохранение булевого значения
  Future<bool> setBool(String key, bool value) async {
    try {
      final result = await _prefs.setBool(key, value);
      _logger.d('Saved bool: $key = $value');
      return result;
    } catch (e) {
      _logger.e('Failed to save bool: $key', error: e);
      return false;
    }
  }

  /// Получение булевого значения
  bool? getBool(String key) {
    try {
      final value = _prefs.getBool(key);
      _logger.d('Retrieved bool: $key = $value');
      return value;
    } catch (e) {
      _logger.e('Failed to get bool: $key', error: e);
      return null;
    }
  }

  /// Сохранение списка строк
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      final result = await _prefs.setStringList(key, value);
      _logger.d('Saved string list: $key = ${value.length} items');
      return result;
    } catch (e) {
      _logger.e('Failed to save string list: $key', error: e);
      return false;
    }
  }

  /// Получение списка строк
  List<String>? getStringList(String key) {
    try {
      final value = _prefs.getStringList(key);
      _logger.d('Retrieved string list: $key = ${value?.length ?? 0} items');
      return value;
    } catch (e) {
      _logger.e('Failed to get string list: $key', error: e);
      return null;
    }
  }

  /// Сохранение объекта как JSON
  Future<bool> setObject(String key, Map<String, dynamic> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      _logger.d('Saved object: $key');
      return result;
    } catch (e) {
      _logger.e('Failed to save object: $key', error: e);
      return false;
    }
  }

  /// Получение объекта из JSON
  Map<String, dynamic>? getObject(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      
      final object = jsonDecode(jsonString) as Map<String, dynamic>;
      _logger.d('Retrieved object: $key');
      return object;
    } catch (e) {
      _logger.e('Failed to get object: $key', error: e);
      return null;
    }
  }

  /// Сохранение списка объектов как JSON
  Future<bool> setObjectList(String key, List<Map<String, dynamic>> value) async {
    try {
      final jsonString = jsonEncode(value);
      final result = await _prefs.setString(key, jsonString);
      _logger.d('Saved object list: $key = ${value.length} items');
      return result;
    } catch (e) {
      _logger.e('Failed to save object list: $key', error: e);
      return false;
    }
  }

  /// Получение списка объектов из JSON
  List<Map<String, dynamic>>? getObjectList(String key) {
    try {
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      
      final list = jsonDecode(jsonString) as List;
      final objectList = list.cast<Map<String, dynamic>>();
      _logger.d('Retrieved object list: $key = ${objectList.length} items');
      return objectList;
    } catch (e) {
      _logger.e('Failed to get object list: $key', error: e);
      return null;
    }
  }

  /// Удаление значения по ключу
  Future<bool> remove(String key) async {
    try {
      final result = await _prefs.remove(key);
      _logger.d('Removed: $key');
      return result;
    } catch (e) {
      _logger.e('Failed to remove: $key', error: e);
      return false;
    }
  }

  /// Проверка существования ключа
  bool containsKey(String key) {
    try {
      final exists = _prefs.containsKey(key);
      _logger.d('Key exists: $key = $exists');
      return exists;
    } catch (e) {
      _logger.e('Failed to check key: $key', error: e);
      return false;
    }
  }

  /// Получение всех ключей
  Set<String> getKeys() {
    try {
      final keys = _prefs.getKeys();
      _logger.d('Retrieved keys: ${keys.length} items');
      return keys;
    } catch (e) {
      _logger.e('Failed to get keys', error: e);
      return {};
    }
  }

  /// Очистка всех данных
  Future<bool> clear() async {
    try {
      final result = await _prefs.clear();
      _logger.i('Cleared all storage data');
      return result;
    } catch (e) {
      _logger.e('Failed to clear storage', error: e);
      return false;
    }
  }

  /// Получение размера хранилища
  Future<int> getSize() async {
    try {
      final keys = _prefs.getKeys();
      int totalSize = 0;
      
      for (final key in keys) {
        final value = _prefs.get(key);
        if (value != null) {
          totalSize += value.toString().length;
        }
      }
      
      _logger.d('Storage size: $totalSize bytes');
      return totalSize;
    } catch (e) {
      _logger.e('Failed to get storage size', error: e);
      return 0;
    }
  }

  /// Проверка доступности хранилища
  Future<bool> isAvailable() async {
    try {
      // Пробуем записать и прочитать тестовое значение
      const testKey = '_storage_test';
      const testValue = 'test';
      
      final writeResult = await _prefs.setString(testKey, testValue);
      if (!writeResult) return false;
      
      final readValue = _prefs.getString(testKey);
      if (readValue != testValue) return false;
      
      await _prefs.remove(testKey);
      
      _logger.d('Storage is available');
      return true;
    } catch (e) {
      _logger.e('Storage is not available', error: e);
      return false;
    }
  }

  /// Получение статистики хранилища
  Future<Map<String, dynamic>> getStatistics() async {
    try {
      final keys = _prefs.getKeys();
      final size = await getSize();
      final available = await isAvailable();
      
      final statistics = {
        'totalKeys': keys.length,
        'totalSize': size,
        'isAvailable': available,
        'keyTypes': <String, int>{},
      };
      
      // Подсчет типов ключей
      for (final key in keys) {
        final value = _prefs.get(key);
        final type = value.runtimeType.toString();
        statistics['keyTypes'][type] = (statistics['keyTypes'][type] ?? 0) + 1;
      }
      
      _logger.d('Storage statistics: $statistics');
      return statistics;
    } catch (e) {
      _logger.e('Failed to get storage statistics', error: e);
      return {};
    }
  }

  /// Создание резервной копии
  Future<Map<String, dynamic>> createBackup() async {
    try {
      final keys = _prefs.getKeys();
      final backup = <String, dynamic>{};
      
      for (final key in keys) {
        final value = _prefs.get(key);
        backup[key] = value;
      }
      
      _logger.i('Created backup with ${backup.length} items');
      return backup;
    } catch (e) {
      _logger.e('Failed to create backup', error: e);
      return {};
    }
  }

  /// Восстановление из резервной копии
  Future<bool> restoreFromBackup(Map<String, dynamic> backup) async {
    try {
      // Очищаем текущие данные
      await _prefs.clear();
      
      // Восстанавливаем данные из резервной копии
      for (final entry in backup.entries) {
        final key = entry.key;
        final value = entry.value;
        
        if (value is String) {
          await _prefs.setString(key, value);
        } else if (value is int) {
          await _prefs.setInt(key, value);
        } else if (value is bool) {
          await _prefs.setBool(key, value);
        } else if (value is List<String>) {
          await _prefs.setStringList(key, value);
        }
      }
      
      _logger.i('Restored backup with ${backup.length} items');
      return true;
    } catch (e) {
      _logger.e('Failed to restore backup', error: e);
      return false;
    }
  }
}
