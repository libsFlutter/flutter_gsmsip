import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_gsm_sip_gateway/presentation/services/api_service.dart';
import 'package:flutter_gsm_sip_gateway/presentation/services/network_service.dart';

// Генерируем моки
@GenerateMocks([http.Client, NetworkService, Connectivity])
import 'api_service_test.mocks.dart';

void main() {
  group('ApiService', () {
    late ApiService apiService;
    late MockHttpClient mockHttpClient;
    late MockNetworkService mockNetworkService;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockNetworkService = MockNetworkService();
      mockConnectivity = MockConnectivity();
      
      apiService = ApiService(
        mockHttpClient,
        mockNetworkService,
        null, // Logger будет null в тестах
      );
    });

    group('Initialization', () {
      test('should initialize with default values', () {
        expect(apiService, isNotNull);
      });

      test('should set auth token correctly', () {
        // Arrange
        const token = 'test_token';

        // Act
        apiService.setAuthToken(token);

        // Assert
        // Проверяем, что токен установлен (через выполнение запроса)
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"success": true}', 200));

        // Act
        apiService.get('/test');

        // Assert
        verify(mockHttpClient.get(
          any,
          headers: argThat(contains('Authorization')),
        )).called(1);
      });

      test('should clear auth token correctly', () {
        // Arrange
        const token = 'test_token';
        apiService.setAuthToken(token);

        // Act
        apiService.clearAuthToken();

        // Assert
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('{"success": true}', 200));

        // Act
        apiService.get('/test');

        // Assert
        verify(mockHttpClient.get(
          any,
          headers: argThat(isNot(contains('Authorization'))),
        )).called(1);
      });
    });

    group('GET requests', () {
      test('should make successful GET request', () async {
        // Arrange
        const endpoint = '/test';
        const responseData = {'success': true, 'data': 'test'};
        final response = http.Response('{"success": true, "data": "test"}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.dataAsMap, equals(responseData));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should handle network disconnection', () async {
        // Arrange
        const endpoint = '/test';
        when(mockNetworkService.isConnected).thenReturn(false);

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.statusCode, equals(0));
        expect(result.error, equals('No network connection'));
        verifyNever(mockHttpClient.get(any, headers: anyNamed('headers')));
      });

      test('should handle HTTP error response', () async {
        // Arrange
        const endpoint = '/test';
        final response = http.Response('{"error": "Not found"}', 404);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.statusCode, equals(404));
        expect(result.error, equals('Not found'));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should handle request timeout', () async {
        // Arrange
        const endpoint = '/test';
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Timeout'));

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.statusCode, equals(0));
        expect(result.error, contains('Request failed after'));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(4); // maxRetries + 1
      });
    });

    group('POST requests', () {
      test('should make successful POST request', () async {
        // Arrange
        const endpoint = '/test';
        const requestBody = {'name': 'test', 'value': 123};
        const responseData = {'success': true, 'id': 1};
        final response = http.Response('{"success": true, "id": 1}', 201);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.post(endpoint, body: requestBody);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(201));
        expect(result.dataAsMap, equals(responseData));
        verify(mockHttpClient.post(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });

      test('should handle POST request with query parameters', () async {
        // Arrange
        const endpoint = '/test';
        const queryParams = {'page': 1, 'limit': 10};
        final response = http.Response('{"success": true}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.post(endpoint, queryParameters: queryParams);

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockHttpClient.post(
          argThat(hasQuery('page', '1')),
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('PUT requests', () {
      test('should make successful PUT request', () async {
        // Arrange
        const endpoint = '/test/1';
        const requestBody = {'name': 'updated', 'value': 456};
        final response = http.Response('{"success": true}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.put(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.put(endpoint, body: requestBody);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(200));
        verify(mockHttpClient.put(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('DELETE requests', () {
      test('should make successful DELETE request', () async {
        // Arrange
        const endpoint = '/test/1';
        final response = http.Response('', 204);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.delete(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.delete(endpoint);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(204));
        verify(mockHttpClient.delete(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('PATCH requests', () {
      test('should make successful PATCH request', () async {
        // Arrange
        const endpoint = '/test/1';
        const requestBody = {'status': 'active'};
        final response = http.Response('{"success": true}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.patch(any, headers: anyNamed('headers'), body: anyNamed('body')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.patch(endpoint, body: requestBody);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(200));
        verify(mockHttpClient.patch(
          any,
          headers: anyNamed('headers'),
          body: anyNamed('body'),
        )).called(1);
      });
    });

    group('File operations', () {
      test('should download file successfully', () async {
        // Arrange
        const endpoint = '/files/test.pdf';
        final fileBytes = [1, 2, 3, 4, 5];
        final response = http.Response.bytes(fileBytes, 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.downloadFile(endpoint);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.data, equals(fileBytes));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should handle file download error', () async {
        // Arrange
        const endpoint = '/files/test.pdf';
        final response = http.Response('File not found', 404);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.downloadFile(endpoint);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.statusCode, equals(404));
        expect(result.error, equals('Download failed'));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('Health checks', () {
      test('should check API health successfully', () async {
        // Arrange
        final response = http.Response('{"status": "healthy"}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.isHealthy();

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should return false when health check fails', () async {
        // Arrange
        final response = http.Response('{"error": "Service unavailable"}', 503);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.isHealthy();

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('API Info', () {
      test('should get API info successfully', () async {
        // Arrange
        const apiInfo = {
          'version': '1.0.0',
          'name': 'Test API',
          'description': 'Test API description'
        };
        final response = http.Response('{"version": "1.0.0", "name": "Test API", "description": "Test API description"}', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.getApiInfo();

        // Assert
        expect(result, equals(apiInfo));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should return null when API info request fails', () async {
        // Arrange
        final response = http.Response('{"error": "Not found"}', 404);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.getApiInfo();

        // Assert
        expect(result, isNull);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('Error handling', () {
      test('should handle invalid JSON response', () async {
        // Arrange
        const endpoint = '/test';
        final response = http.Response('invalid json', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isFalse);
        expect(result.statusCode, equals(200));
        expect(result.error, equals('Invalid response format'));
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should handle empty response body', () async {
        // Arrange
        const endpoint = '/test';
        final response = http.Response('', 200);
        
        when(mockNetworkService.isConnected).thenReturn(true);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await apiService.get(endpoint);

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.statusCode, equals(200));
        expect(result.data, isNull);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });
    });

    group('ApiResponse', () {
      test('should create successful response', () {
        // Arrange & Act
        const data = {'success': true};
        const statusCode = 200;
        final response = ApiResponse.success(
          data: data,
          statusCode: statusCode,
        );

        // Assert
        expect(response.isSuccess, isTrue);
        expect(response.data, equals(data));
        expect(response.statusCode, equals(statusCode));
        expect(response.error, isNull);
      });

      test('should create error response', () {
        // Arrange & Act
        const error = 'Something went wrong';
        const statusCode = 500;
        final response = ApiResponse.error(
          error,
          statusCode: statusCode,
        );

        // Assert
        expect(response.isSuccess, isFalse);
        expect(response.error, equals(error));
        expect(response.statusCode, equals(statusCode));
        expect(response.data, isNull);
      });

      test('should get data as Map', () {
        // Arrange
        const data = {'name': 'test', 'value': 123};
        final response = ApiResponse.success(data: data, statusCode: 200);

        // Act
        final result = response.dataAsMap;

        // Assert
        expect(result, equals(data));
      });

      test('should get data as List', () {
        // Arrange
        const data = [1, 2, 3, 4, 5];
        final response = ApiResponse.success(data: data, statusCode: 200);

        // Act
        final result = response.dataAsList;

        // Assert
        expect(result, equals(data));
      });

      test('should get data as String', () {
        // Arrange
        const data = 'test string';
        final response = ApiResponse.success(data: data, statusCode: 200);

        // Act
        final result = response.dataAsString;

        // Assert
        expect(result, equals(data));
      });

      test('should return null for wrong data type', () {
        // Arrange
        const data = {'name': 'test'};
        final response = ApiResponse.success(data: data, statusCode: 200);

        // Act
        final result = response.dataAsList;

        // Assert
        expect(result, isNull);
      });
    });
  });
}

/// Matcher для проверки query параметров в URI
Matcher hasQuery(String key, String value) {
  return predicate<Uri>((uri) {
    return uri.queryParameters[key] == value;
  }, 'URI with query parameter $key=$value');
}
