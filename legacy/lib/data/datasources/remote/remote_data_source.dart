import 'package:logger/logger.dart';
import '../../../presentation/services/api_service.dart';
import '../../../presentation/services/network_service.dart';

/// Удаленный источник данных
class RemoteDataSource {
  final ApiService _apiService;
  final NetworkService _networkService;
  final Logger _logger;

  RemoteDataSource(
    this._apiService,
    this._networkService,
    this._logger,
  );

  /// Выполнение GET запроса
  Future<Map<String, dynamic>?> getData(String endpoint) async {
    try {
      _logger.d('Getting data from endpoint: $endpoint');
      final response = await _apiService.get(endpoint);
      
      if (response.isSuccess) {
        return response.dataAsMap;
      } else {
        _logger.w('Failed to get data from endpoint: $endpoint - ${response.error}');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to get data from endpoint: $endpoint', error: e);
      return null;
    }
  }

  /// Выполнение POST запроса
  Future<Map<String, dynamic>?> postData(String endpoint, Map<String, dynamic> data) async {
    try {
      _logger.d('Posting data to endpoint: $endpoint');
      final response = await _apiService.post(endpoint, body: data);
      
      if (response.isSuccess) {
        return response.dataAsMap;
      } else {
        _logger.w('Failed to post data to endpoint: $endpoint - ${response.error}');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to post data to endpoint: $endpoint', error: e);
      return null;
    }
  }

  /// Выполнение PUT запроса
  Future<Map<String, dynamic>?> putData(String endpoint, Map<String, dynamic> data) async {
    try {
      _logger.d('Putting data to endpoint: $endpoint');
      final response = await _apiService.put(endpoint, body: data);
      
      if (response.isSuccess) {
        return response.dataAsMap;
      } else {
        _logger.w('Failed to put data to endpoint: $endpoint - ${response.error}');
        return null;
      }
    } catch (e) {
      _logger.e('Failed to put data to endpoint: $endpoint', error: e);
      return null;
    }
  }

  /// Выполнение DELETE запроса
  Future<bool> deleteData(String endpoint) async {
    try {
      _logger.d('Deleting data from endpoint: $endpoint');
      final response = await _apiService.delete(endpoint);
      
      if (response.isSuccess) {
        return true;
      } else {
        _logger.w('Failed to delete data from endpoint: $endpoint - ${response.error}');
        return false;
      }
    } catch (e) {
      _logger.e('Failed to delete data from endpoint: $endpoint', error: e);
      return false;
    }
  }

  /// Проверка доступности сети
  bool get isNetworkAvailable => _networkService.isConnected;

  /// Получение информации о сети
  Future<Map<String, dynamic>> getNetworkInfo() async {
    return await _networkService.getNetworkInfo();
  }
}
