import 'package:logger/logger.dart';
import '../../../presentation/services/storage_service.dart';

/// Локальный источник данных
class LocalDataSource {
  final StorageService _storageService;
  final Logger _logger;

  LocalDataSource(this._storageService) : _logger = Logger();

  /// Сохранение данных
  Future<bool> saveData(String key, dynamic data) async {
    try {
      _logger.d('Saving data with key: $key');
      return await _storageService.setObject(key, {'data': data, 'timestamp': DateTime.now().toIso8601String()});
    } catch (e) {
      _logger.e('Failed to save data with key: $key', error: e);
      return false;
    }
  }

  /// Получение данных
  Map<String, dynamic>? getData(String key) {
    try {
      _logger.d('Getting data with key: $key');
      return _storageService.getObject(key);
    } catch (e) {
      _logger.e('Failed to get data with key: $key', error: e);
      return null;
    }
  }

  /// Удаление данных
  Future<bool> deleteData(String key) async {
    try {
      _logger.d('Deleting data with key: $key');
      return await _storageService.remove(key);
    } catch (e) {
      _logger.e('Failed to delete data with key: $key', error: e);
      return false;
    }
  }

  /// Очистка всех данных
  Future<bool> clearAllData() async {
    try {
      _logger.d('Clearing all data');
      return await _storageService.clear();
    } catch (e) {
      _logger.e('Failed to clear all data', error: e);
      return false;
    }
  }
}
