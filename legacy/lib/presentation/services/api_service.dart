import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import '../../core/utils/app_constants.dart';

/// Сервис для работы с API
class ApiService {
  final http.Client _httpClient;
  final NetworkService _networkService;
  final Logger _logger;
  
  final String _baseUrl;
  final Duration _timeout;
  final int _maxRetries;
  
  Map<String, String> _defaultHeaders = {};
  String? _authToken;

  ApiService(
    this._httpClient,
    this._networkService,
    this._logger, {
    String? baseUrl,
    Duration? timeout,
    int? maxRetries,
  }) : _baseUrl = baseUrl ?? AppConstants.baseApiUrl,
       _timeout = timeout ?? AppConstants.apiTimeout,
       _maxRetries = maxRetries ?? AppConstants.maxRetries {
    _initializeDefaultHeaders();
  }

  /// Инициализация заголовков по умолчанию
  void _initializeDefaultHeaders() {
    _defaultHeaders = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'User-Agent': 'GOSTsimbox-Gateway/${AppConstants.appVersion}',
    };
  }

  /// Установка токена авторизации
  void setAuthToken(String token) {
    _authToken = token;
    _defaultHeaders['Authorization'] = 'Bearer $token';
    _logger.d('Auth token set');
  }

  /// Очистка токена авторизации
  void clearAuthToken() {
    _authToken = null;
    _defaultHeaders.remove('Authorization');
    _logger.d('Auth token cleared');
  }

  /// Получение заголовков для запроса
  Map<String, String> _getHeaders([Map<String, String>? additionalHeaders]) {
    final headers = Map<String, String>.from(_defaultHeaders);
    if (additionalHeaders != null) {
      headers.addAll(additionalHeaders);
    }
    return headers;
  }

  /// Выполнение GET запроса
  Future<ApiResponse> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      'GET',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Выполнение POST запроса
  Future<ApiResponse> post(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(
      'POST',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Выполнение PUT запроса
  Future<ApiResponse> put(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(
      'PUT',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Выполнение DELETE запроса
  Future<ApiResponse> delete(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    return _executeRequest(
      'DELETE',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
    );
  }

  /// Выполнение PATCH запроса
  Future<ApiResponse> patch(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    return _executeRequest(
      'PATCH',
      endpoint,
      headers: headers,
      queryParameters: queryParameters,
      body: body,
    );
  }

  /// Выполнение запроса с повторными попытками
  Future<ApiResponse> _executeRequest(
    String method,
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
    Map<String, dynamic>? body,
  }) async {
    final url = _buildUrl(endpoint, queryParameters);
    final requestHeaders = _getHeaders(headers);
    
    _logger.d('$method $url');
    
    // Проверка сетевого соединения
    if (!_networkService.isConnected) {
      return ApiResponse.error(
        'No network connection',
        statusCode: 0,
        error: 'NetworkError',
      );
    }

    int retryCount = 0;
    Exception? lastException;

    while (retryCount <= _maxRetries) {
      try {
        final response = await _makeRequest(
          method,
          url,
          requestHeaders,
          body,
        );

        return _processResponse(response);
      } catch (e) {
        lastException = e as Exception;
        retryCount++;
        
        _logger.w('Request failed (attempt $retryCount/$_maxRetries): $e');
        
        if (retryCount <= _maxRetries) {
          // Экспоненциальная задержка перед повторной попыткой
          final delay = Duration(milliseconds: 1000 * retryCount);
          await Future.delayed(delay);
        }
      }
    }

    return ApiResponse.error(
      'Request failed after $_maxRetries attempts',
      statusCode: 0,
      error: lastException?.toString() ?? 'UnknownError',
    );
  }

  /// Выполнение HTTP запроса
  Future<http.Response> _makeRequest(
    String method,
    Uri url,
    Map<String, String> headers,
    Map<String, dynamic>? body,
  ) async {
    final requestBody = body != null ? jsonEncode(body) : null;
    
    switch (method.toUpperCase()) {
      case 'GET':
        return await _httpClient
            .get(url, headers: headers)
            .timeout(_timeout);
      
      case 'POST':
        return await _httpClient
            .post(url, headers: headers, body: requestBody)
            .timeout(_timeout);
      
      case 'PUT':
        return await _httpClient
            .put(url, headers: headers, body: requestBody)
            .timeout(_timeout);
      
      case 'DELETE':
        return await _httpClient
            .delete(url, headers: headers)
            .timeout(_timeout);
      
      case 'PATCH':
        return await _httpClient
            .patch(url, headers: headers, body: requestBody)
            .timeout(_timeout);
      
      default:
        throw ArgumentError('Unsupported HTTP method: $method');
    }
  }

  /// Обработка HTTP ответа
  ApiResponse _processResponse(http.Response response) {
    _logger.d('Response: ${response.statusCode} ${response.reasonPhrase}');
    
    try {
      final responseBody = response.body.isNotEmpty 
          ? jsonDecode(response.body) 
          : null;

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return ApiResponse.success(
          data: responseBody,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else {
        return ApiResponse.error(
          _getErrorMessage(responseBody),
          statusCode: response.statusCode,
          error: _getErrorType(response.statusCode),
          data: responseBody,
          headers: response.headers,
        );
      }
    } catch (e) {
      _logger.e('Error parsing response body', error: e);
      return ApiResponse.error(
        'Invalid response format',
        statusCode: response.statusCode,
        error: 'ParseError',
        headers: response.headers,
      );
    }
  }

  /// Построение URL с параметрами запроса
  Uri _buildUrl(String endpoint, Map<String, dynamic>? queryParameters) {
    final uri = Uri.parse('$_baseUrl$endpoint');
    
    if (queryParameters != null) {
      final queryParams = <String, String>{};
      
      for (final entry in queryParameters.entries) {
        if (entry.value != null) {
          queryParams[entry.key] = entry.value.toString();
        }
      }
      
      return uri.replace(queryParameters: queryParams);
    }
    
    return uri;
  }

  /// Получение сообщения об ошибке
  String _getErrorMessage(dynamic responseBody) {
    if (responseBody is Map) {
      return responseBody['message'] ?? 
             responseBody['error'] ?? 
             responseBody['detail'] ?? 
             'Unknown error';
    }
    return 'Unknown error';
  }

  /// Получение типа ошибки
  String _getErrorType(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'BadRequest';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'NotFound';
      case 409:
        return 'Conflict';
      case 422:
        return 'ValidationError';
      case 429:
        return 'RateLimitExceeded';
      case 500:
        return 'InternalServerError';
      case 502:
        return 'BadGateway';
      case 503:
        return 'ServiceUnavailable';
      case 504:
        return 'GatewayTimeout';
      default:
        return 'HttpError';
    }
  }

  /// Проверка здоровья API
  Future<bool> isHealthy() async {
    try {
      final response = await get('/health');
      return response.isSuccess;
    } catch (e) {
      _logger.e('Health check failed', error: e);
      return false;
    }
  }

  /// Получение информации о версии API
  Future<Map<String, dynamic>?> getApiInfo() async {
    try {
      final response = await get('/api/info');
      if (response.isSuccess) {
        return response.data as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      _logger.e('Failed to get API info', error: e);
      return null;
    }
  }

  /// Загрузка файла
  Future<ApiResponse> downloadFile(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, dynamic>? queryParameters,
  }) async {
    final url = _buildUrl(endpoint, queryParameters);
    final requestHeaders = _getHeaders(headers);
    
    _logger.d('Downloading file from: $url');
    
    try {
      final response = await _httpClient
          .get(url, headers: requestHeaders)
          .timeout(_timeout);
      
      if (response.statusCode == 200) {
        return ApiResponse.success(
          data: response.bodyBytes,
          statusCode: response.statusCode,
          headers: response.headers,
        );
      } else {
        return ApiResponse.error(
          'Download failed',
          statusCode: response.statusCode,
          error: _getErrorType(response.statusCode),
          headers: response.headers,
        );
      }
    } catch (e) {
      _logger.e('Download failed', error: e);
      return ApiResponse.error(
        'Download failed: ${e.toString()}',
        statusCode: 0,
        error: 'DownloadError',
      );
    }
  }

  /// Загрузка файла на сервер
  Future<ApiResponse> uploadFile(
    String endpoint,
    List<int> fileBytes,
    String fileName, {
    Map<String, String>? headers,
    Map<String, String>? fields,
  }) async {
    final url = _buildUrl(endpoint, null);
    final requestHeaders = _getHeaders(headers);
    
    _logger.d('Uploading file: $fileName to $url');
    
    try {
      final request = http.MultipartRequest('POST', url);
      
      // Добавляем заголовки
      request.headers.addAll(requestHeaders);
      
      // Добавляем файл
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          fileBytes,
          filename: fileName,
        ),
      );
      
      // Добавляем дополнительные поля
      if (fields != null) {
        request.fields.addAll(fields);
      }
      
      final streamedResponse = await request.send().timeout(_timeout);
      final response = await http.Response.fromStream(streamedResponse);
      
      return _processResponse(response);
    } catch (e) {
      _logger.e('Upload failed', error: e);
      return ApiResponse.error(
        'Upload failed: ${e.toString()}',
        statusCode: 0,
        error: 'UploadError',
      );
    }
  }

  /// Получение статистики API
  Future<Map<String, dynamic>> getApiStats() async {
    try {
      final response = await get('/api/stats');
      if (response.isSuccess) {
        return response.data as Map<String, dynamic>;
      }
      return {};
    } catch (e) {
      _logger.e('Failed to get API stats', error: e);
      return {};
    }
  }
}

/// Класс для представления API ответа
class ApiResponse {
  final bool isSuccess;
  final dynamic data;
  final int statusCode;
  final String? error;
  final Map<String, String>? headers;

  ApiResponse._({
    required this.isSuccess,
    this.data,
    required this.statusCode,
    this.error,
    this.headers,
  });

  /// Создание успешного ответа
  factory ApiResponse.success({
    dynamic data,
    required int statusCode,
    Map<String, String>? headers,
  }) {
    return ApiResponse._(
      isSuccess: true,
      data: data,
      statusCode: statusCode,
      headers: headers,
    );
  }

  /// Создание ответа с ошибкой
  factory ApiResponse.error(
    String error, {
    required int statusCode,
    String? errorType,
    dynamic data,
    Map<String, String>? headers,
  }) {
    return ApiResponse._(
      isSuccess: false,
      data: data,
      statusCode: statusCode,
      error: error,
      headers: headers,
    );
  }

  /// Получение данных как Map
  Map<String, dynamic>? get dataAsMap {
    if (data is Map<String, dynamic>) {
      return data as Map<String, dynamic>;
    }
    return null;
  }

  /// Получение данных как List
  List<dynamic>? get dataAsList {
    if (data is List) {
      return data as List<dynamic>;
    }
    return null;
  }

  /// Получение данных как String
  String? get dataAsString {
    if (data is String) {
      return data as String;
    }
    return data?.toString();
  }

  @override
  String toString() {
    return 'ApiResponse{isSuccess: $isSuccess, statusCode: $statusCode, error: $error, data: $data}';
  }
}
