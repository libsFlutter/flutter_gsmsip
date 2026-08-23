import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Локальный источник данных
/// Direct access to SharedPreferences without presentation layer dependencies
class LocalDataSource {
  final SharedPreferences _prefs;
  final Logger _logger;

  LocalDataSource(this._prefs) : _logger = Logger();

  /// Сохранение данных
  Future<bool> saveData(String key, dynamic data) async {
    try {
      _logger.d('Saving data with key: $key');
      final jsonData = jsonEncode(data);
      return await _prefs.setString(key, jsonData);
    } catch (e) {
      _logger.e('Failed to save data with key: $key', error: e);
      return false;
    }
  }

  /// Получение данных
  Map<String, dynamic>? getData(String key) {
    try {
      _logger.d('Getting data with key: $key');
      final jsonString = _prefs.getString(key);
      if (jsonString == null) return null;
      return jsonDecode(jsonString) as Map<String, dynamic>;
    } catch (e) {
      _logger.e('Failed to get data with key: $key', error: e);
      return null;
    }
  }

  /// Удаление данных
  Future<bool> deleteData(String key) async {
    try {
      _logger.d('Deleting data with key: $key');
      return await _prefs.remove(key);
    } catch (e) {
      _logger.e('Failed to delete data with key: $key', error: e);
      return false;
    }
  }

  /// Очистка всех данных
  Future<bool> clearAllData() async {
    try {
      _logger.d('Clearing all data');
      return await _prefs.clear();
    } catch (e) {
      _logger.e('Failed to clear all data', error: e);
      return false;
    }
  }

  /// Проверка существования ключа
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }

  /// Получение всех ключей
  List<String> getKeys() {
    return _prefs.getKeys().toList();
  }
}
