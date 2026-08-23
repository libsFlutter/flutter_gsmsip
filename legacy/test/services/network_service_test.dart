import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'package:flutter_gsm_sip_gateway/presentation/services/network_service.dart';

// Генерируем моки
@GenerateMocks([http.Client, Connectivity])
import 'network_service_test.mocks.dart';

void main() {
  group('NetworkService', () {
    late NetworkService networkService;
    late MockHttpClient mockHttpClient;
    late MockConnectivity mockConnectivity;

    setUp(() {
      mockHttpClient = MockHttpClient();
      mockConnectivity = MockConnectivity();
      
      networkService = NetworkService(mockHttpClient);
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        // Act
        await networkService.initialize();

        // Assert
        expect(networkService.isConnected, isTrue);
        expect(networkService.connectionType, equals(ConnectivityResult.wifi));
        verify(mockConnectivity.checkConnectivity()).called(1);
      });

      test('should handle initialization error', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenThrow(Exception('Connectivity error'));

        // Act & Assert
        expect(
          () => networkService.initialize(),
          throwsException,
        );
      });

      test('should not initialize twice', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        // Act
        await networkService.initialize();
        await networkService.initialize(); // Второй вызов

        // Assert
        verify(mockConnectivity.checkConnectivity()).called(1); // Только один раз
      });
    });

    group('Connection status', () {
      test('should return correct connection status', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.mobile);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.mobile));

        await networkService.initialize();

        // Act & Assert
        expect(networkService.isConnected, isTrue);
        expect(networkService.connectionType, equals(ConnectivityResult.mobile));
      });

      test('should return disconnected status', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.none);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.none));

        await networkService.initialize();

        // Act & Assert
        expect(networkService.isConnected, isFalse);
        expect(networkService.connectionType, equals(ConnectivityResult.none));
      });

      test('should emit connection status changes', () async {
        // Arrange
        final connectivityStream = StreamController<ConnectivityResult>();
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream.stream);

        await networkService.initialize();

        // Act
        connectivityStream.add(ConnectivityResult.none);
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        expect(networkService.isConnected, isFalse);
        expect(networkService.connectionType, equals(ConnectivityResult.none));
      });
    });

    group('Internet connectivity', () {
      test('should check internet connectivity successfully', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        final response = http.Response('OK', 200);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        await networkService.initialize();

        // Act
        final result = await networkService.checkInternetConnectivity();

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(1);
      });

      test('should return false when no internet connectivity', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'));

        await networkService.initialize();

        // Act
        final result = await networkService.checkInternetConnectivity();

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(3); // Все 3 URL
      });

      test('should try multiple URLs for connectivity check', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        // Первые два URL недоступны, третий доступен
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Network error'))
            .thenThrow(Exception('Network error'))
            .thenAnswer((_) async => http.Response('OK', 200));

        await networkService.initialize();

        // Act
        final result = await networkService.checkInternetConnectivity();

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.get(any, headers: anyNamed('headers'))).called(3);
      });
    });

    group('Server availability', () {
      test('should check server availability successfully', () async {
        // Arrange
        const url = 'https://api.example.com';
        final response = http.Response('OK', 200);
        when(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.checkServerAvailability(url);

        // Assert
        expect(result, isTrue);
        verify(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers'))).called(1);
      });

      test('should return false for unavailable server', () async {
        // Arrange
        const url = 'https://api.example.com';
        final response = http.Response('Not Found', 404);
        when(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.checkServerAvailability(url);

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers'))).called(1);
      });

      test('should handle server check error', () async {
        // Arrange
        const url = 'https://api.example.com';
        when(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers')))
            .thenThrow(Exception('Connection error'));

        // Act
        final result = await networkService.checkServerAvailability(url);

        // Assert
        expect(result, isFalse);
        verify(mockHttpClient.get(Uri.parse(url), headers: anyNamed('headers'))).called(1);
      });
    });

    group('Network info', () {
      test('should get network info successfully', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        final response = http.Response('OK', 200);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        await networkService.initialize();

        // Act
        final result = await networkService.getNetworkInfo();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['isConnected'], isTrue);
        expect(result['connectionType'], contains('wifi'));
        expect(result['hasInternet'], isTrue);
        expect(result['timestamp'], isA<String>());
      });

      test('should handle WiFi info error gracefully', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        when(mockConnectivity.getWifiName())
            .thenThrow(Exception('WiFi name error'));
        when(mockConnectivity.getWifiBSSID())
            .thenThrow(Exception('WiFi BSSID error'));
        when(mockConnectivity.getWifiIP())
            .thenThrow(Exception('WiFi IP error'));

        final response = http.Response('OK', 200);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        await networkService.initialize();

        // Act
        final result = await networkService.getNetworkInfo();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['isConnected'], isTrue);
        expect(result['hasInternet'], isTrue);
        // WiFi info должно отсутствовать из-за ошибок
        expect(result.containsKey('wifiName'), isFalse);
        expect(result.containsKey('wifiBSSID'), isFalse);
        expect(result.containsKey('wifiIPAddress'), isFalse);
      });
    });

    group('Connection speed test', () {
      test('should test connection speed successfully', () async {
        // Arrange
        const testUrl = 'https://www.google.com';
        final responseBody = 'A' * 1000; // 1000 байт
        final response = http.Response(responseBody, 200);
        when(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.testConnectionSpeed();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['url'], equals(testUrl));
        expect(result['statusCode'], equals(200));
        expect(result['responseSize'], equals(1000));
        expect(result['speedBytesPerSecond'], isA<double>());
        expect(result['speedKBps'], isA<double>());
        expect(result['speedMBps'], isA<double>());
        expect(result['timestamp'], isA<String>());
        verify(mockHttpClient.get(Uri.parse(testUrl), headers: anyNamed('headers'))).called(1);
      });

      test('should handle speed test error', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Speed test error'));

        // Act
        final result = await networkService.testConnectionSpeed();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['error'], contains('Speed test error'));
        expect(result['timestamp'], isA<String>());
      });
    });

    group('Connection quality monitoring', () {
      test('should monitor connection quality successfully', () async {
        // Arrange
        final pingResponse = http.Response('OK', 200);
        final speedResponse = http.Response('A' * 1000, 200);
        
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => pingResponse)
            .thenAnswer((_) async => speedResponse)
            .thenAnswer((_) async => pingResponse);

        // Act
        final result = await networkService.monitorConnectionQuality();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['ping'], isA<Map<String, dynamic>>());
        expect(result['speed'], isA<Map<String, dynamic>>());
        expect(result['stability'], isA<Map<String, dynamic>>());
        expect(result['qualityScore'], isA<double>());
        expect(result['qualityScore'], greaterThanOrEqualTo(0.0));
        expect(result['qualityScore'], lessThanOrEqualTo(100.0));
      });

      test('should handle quality monitoring error', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Quality test error'));

        // Act
        final result = await networkService.monitorConnectionQuality();

        // Assert
        expect(result, isA<Map<String, dynamic>>());
        expect(result['error'], contains('Quality test error'));
      });
    });

    group('Ping test', () {
      test('should test ping successfully', () async {
        // Arrange
        final response = http.Response('OK', 200);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.monitorConnectionQuality();
        final ping = result['ping'] as Map<String, dynamic>;

        // Assert
        expect(ping, isA<Map<String, dynamic>>());
        expect(ping['average'], isA<double>());
        expect(ping['minimum'], isA<int>());
        expect(ping['maximum'], isA<int>());
        expect(ping['count'], equals(2)); // 2 URL для пинга
        expect(ping['average'], greaterThan(0));
        expect(ping['minimum'], greaterThan(0));
        expect(ping['maximum'], greaterThan(0));
      });

      test('should handle ping test failure', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenThrow(Exception('Ping error'));

        // Act
        final result = await networkService.monitorConnectionQuality();
        final ping = result['ping'] as Map<String, dynamic>;

        // Assert
        expect(ping['error'], equals('All ping tests failed'));
      });
    });

    group('Stability test', () {
      test('should test stability successfully', () async {
        // Arrange
        final response = http.Response('OK', 200);
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.monitorConnectionQuality();
        final stability = result['stability'] as Map<String, dynamic>;

        // Assert
        expect(stability, isA<Map<String, dynamic>>());
        expect(stability['successRate'], equals(1.0));
        expect(stability['successCount'], equals(5));
        expect(stability['totalTests'], equals(5));
        expect(stability['averageResponseTime'], isA<int>());
        expect(stability['averageResponseTime'], greaterThan(0));
      });

      test('should handle partial stability test failure', () async {
        // Arrange
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => http.Response('OK', 200))
            .thenThrow(Exception('Test error'))
            .thenAnswer((_) async => http.Response('OK', 200))
            .thenAnswer((_) async => http.Response('OK', 200))
            .thenAnswer((_) async => http.Response('OK', 200));

        // Act
        final result = await networkService.monitorConnectionQuality();
        final stability = result['stability'] as Map<String, dynamic>;

        // Assert
        expect(stability['successRate'], equals(0.8)); // 4 из 5 успешных
        expect(stability['successCount'], equals(4));
        expect(stability['totalTests'], equals(5));
      });
    });

    group('Quality score calculation', () {
      test('should calculate high quality score', () async {
        // Arrange
        final response = http.Response('A' * 10000, 200); // Большой ответ для высокой скорости
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.monitorConnectionQuality();
        final qualityScore = result['qualityScore'] as double;

        // Assert
        expect(qualityScore, greaterThan(50.0)); // Должен быть высокий балл
        expect(qualityScore, lessThanOrEqualTo(100.0));
      });

      test('should calculate low quality score for poor connection', () async {
        // Arrange
        final response = http.Response('A', 200); // Очень маленький ответ
        when(mockHttpClient.get(any, headers: anyNamed('headers')))
            .thenAnswer((_) async => response);

        // Act
        final result = await networkService.monitorConnectionQuality();
        final qualityScore = result['qualityScore'] as double;

        // Assert
        expect(qualityScore, lessThan(50.0)); // Должен быть низкий балл
        expect(qualityScore, greaterThanOrEqualTo(0.0));
      });
    });

    group('Disposal', () {
      test('should dispose resources correctly', () async {
        // Arrange
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => Stream.value(ConnectivityResult.wifi));

        await networkService.initialize();

        // Act
        await networkService.dispose();

        // Assert
        // Проверяем, что dispose не вызывает ошибок
        expect(() => networkService.dispose(), returnsNormally);
      });
    });

    group('Error handling', () {
      test('should handle connectivity stream error', () async {
        // Arrange
        final connectivityStream = StreamController<ConnectivityResult>();
        when(mockConnectivity.checkConnectivity())
            .thenAnswer((_) async => ConnectivityResult.wifi);
        when(mockConnectivity.onConnectivityChanged)
            .thenAnswer((_) => connectivityStream.stream);

        await networkService.initialize();

        // Act
        connectivityStream.addError(Exception('Stream error'));
        await Future.delayed(const Duration(milliseconds: 100));

        // Assert
        // Сервис должен продолжать работать после ошибки стрима
        expect(networkService.isConnected, isTrue);
      });
    });
  });
}
