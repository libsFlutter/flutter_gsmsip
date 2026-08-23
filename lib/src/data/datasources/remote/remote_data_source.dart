import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Удаленный источник данных
/// Direct HTTP access without presentation layer dependencies
class RemoteDataSource {
  final http.Client _client;
  final Logger _logger;
  final String baseUrl;

  RemoteDataSource({
    http.Client? client,
    this.baseUrl = '',
  })  : _client = client ?? http.Client(),
        _logger = Logger();

  /// Выполнение GET запроса
  Future<Map<String, dynamic>?> getData(String endpoint) async {
    try {
      _logger.d('Getting data from endpoint: $endpoint');
      final response = await _client.get(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _logger.w('Failed to get data from endpoint: $endpoint - ${response.statusCode}');
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
      final response = await _client.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _logger.w('Failed to post data to endpoint: $endpoint - ${response.statusCode}');
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
      final response = await _client.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      } else {
        _logger.w('Failed to put data to endpoint: $endpoint - ${response.statusCode}');
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
      final response = await _client.delete(Uri.parse('$baseUrl$endpoint'));

      if (response.statusCode == 200 || response.statusCode == 204) {
        return true;
      } else {
        _logger.w('Failed to delete data from endpoint: $endpoint - ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('Failed to delete data from endpoint: $endpoint', error: e);
      return false;
    }
  }

  /// Проверка доступности сети (упрощенная)
  bool get isNetworkAvailable => true; // Should be implemented with connectivity_plus

  /// Освобождение ресурсов
  void dispose() {
    _client.close();
  }
}
