import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Сервис для работы с сетью и мониторинга соединения
class NetworkService {
  final http.Client _httpClient;
  final Logger _logger;
  final Connectivity _connectivity;
  
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  bool _isInitialized = false;
  bool _isConnected = false;
  ConnectivityResult _lastConnectivityResult = ConnectivityResult.none;

  NetworkService(this._httpClient) 
    : _logger = Logger(),
      _connectivity = Connectivity();

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.i('Initializing network service...');
      
      // Получаем текущий статус соединения
      _lastConnectivityResult = await _connectivity.checkConnectivity();
      _isConnected = _lastConnectivityResult != ConnectivityResult.none;
      
      // Подписываемся на изменения соединения
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        _onConnectivityChanged,
        onError: (error) {
          _logger.e('Connectivity stream error', error: error);
        },
      );
      
      _isInitialized = true;
      _logger.i('Network service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize network service', error: e);
      rethrow;
    }
  }

  /// Обработка изменений соединения
  void _onConnectivityChanged(ConnectivityResult result) {
    _logger.d('Connectivity changed: $result');
    
    final wasConnected = _isConnected;
    _isConnected = result != ConnectivityResult.none;
    _lastConnectivityResult = result;
    
    // Уведомляем подписчиков об изменении статуса
    _connectionStatusController.add(_isConnected);
    
    if (wasConnected != _isConnected) {
      _logger.i('Connection status changed: ${_isConnected ? 'Connected' : 'Disconnected'}');
    }
  }

  /// Проверка наличия соединения
  bool get isConnected => _isConnected;

  /// Получение текущего типа соединения
  ConnectivityResult get connectionType => _lastConnectivityResult;

  /// Stream для отслеживания статуса соединения
  Stream<bool> get connectionStatusStream => _connectionStatusController.stream;

  /// Проверка доступности интернета
  Future<bool> checkInternetConnectivity() async {
    try {
      _logger.d('Checking internet connectivity...');
      
      // Проверяем несколько надежных серверов
      final urls = [
        'https://www.google.com',
        'https://www.cloudflare.com',
        'https://www.apple.com',
      ];
      
      for (final url in urls) {
        try {
          final response = await _httpClient
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          
          if (response.statusCode == 200) {
            _logger.d('Internet connectivity confirmed via $url');
            return true;
          }
        } catch (e) {
          _logger.d('Failed to reach $url: $e');
          continue;
        }
      }
      
      _logger.w('No internet connectivity detected');
      return false;
    } catch (e) {
      _logger.e('Error checking internet connectivity', error: e);
      return false;
    }
  }

  /// Проверка доступности конкретного сервера
  Future<bool> checkServerAvailability(String url) async {
    try {
      _logger.d('Checking server availability: $url');
      
      final response = await _httpClient
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      
      final isAvailable = response.statusCode >= 200 && response.statusCode < 300;
      _logger.d('Server $url is ${isAvailable ? 'available' : 'unavailable'}');
      
      return isAvailable;
    } catch (e) {
      _logger.e('Error checking server availability: $url', error: e);
      return false;
    }
  }

  /// Получение информации о сети
  Future<Map<String, dynamic>> getNetworkInfo() async {
    try {
      final info = <String, dynamic>{
        'isConnected': _isConnected,
        'connectionType': _lastConnectivityResult.toString(),
        'hasInternet': await checkInternetConnectivity(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      // Дополнительная информация в зависимости от платформы
      if (Platform.isAndroid || Platform.isIOS) {
        try {
          final wifiName = await _connectivity.getWifiName();
          final wifiBSSID = await _connectivity.getWifiBSSID();
          final wifiIPAddress = await _connectivity.getWifiIP();
          
          info['wifiName'] = wifiName;
          info['wifiBSSID'] = wifiBSSID;
          info['wifiIPAddress'] = wifiIPAddress;
        } catch (e) {
          _logger.d('Could not get WiFi info: $e');
        }
      }
      
      _logger.d('Network info: $info');
      return info;
    } catch (e) {
      _logger.e('Error getting network info', error: e);
      return {};
    }
  }

  /// Тест скорости соединения
  Future<Map<String, dynamic>> testConnectionSpeed() async {
    try {
      _logger.i('Starting connection speed test...');
      
      final startTime = DateTime.now();
      final testUrl = 'https://www.google.com';
      
      final response = await _httpClient
          .get(Uri.parse(testUrl))
          .timeout(const Duration(seconds: 30));
      
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      final responseSize = response.bodyBytes.length;
      
      // Расчет скорости в байтах в секунду
      final speedBytesPerSecond = responseSize / (duration.inMilliseconds / 1000);
      final speedKBps = speedBytesPerSecond / 1024;
      final speedMBps = speedKBps / 1024;
      
      final result = {
        'url': testUrl,
        'duration': duration.inMilliseconds,
        'responseSize': responseSize,
        'speedBytesPerSecond': speedBytesPerSecond,
        'speedKBps': speedKBps,
        'speedMBps': speedMBps,
        'statusCode': response.statusCode,
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      _logger.i('Speed test completed: ${result['speedMBps'].toStringAsFixed(2)} MB/s');
      return result;
    } catch (e) {
      _logger.e('Error testing connection speed', error: e);
      return {
        'error': e.toString(),
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Мониторинг качества соединения
  Future<Map<String, dynamic>> monitorConnectionQuality() async {
    try {
      _logger.d('Monitoring connection quality...');
      
      final results = <String, dynamic>{};
      
      // Тест пинга
      results['ping'] = await _testPing();
      
      // Тест скорости
      results['speed'] = await testConnectionSpeed();
      
      // Тест стабильности
      results['stability'] = await _testStability();
      
      // Общая оценка качества
      results['qualityScore'] = _calculateQualityScore(results);
      
      _logger.d('Connection quality monitoring completed');
      return results;
    } catch (e) {
      _logger.e('Error monitoring connection quality', error: e);
      return {'error': e.toString()};
    }
  }

  /// Тест пинга
  Future<Map<String, dynamic>> _testPing() async {
    try {
      final testUrls = [
        'https://www.google.com',
        'https://www.cloudflare.com',
      ];
      
      final pings = <int>[];
      
      for (final url in testUrls) {
        final startTime = DateTime.now();
        
        try {
          await _httpClient
              .get(Uri.parse(url))
              .timeout(const Duration(seconds: 5));
          
          final endTime = DateTime.now();
          final ping = endTime.difference(startTime).inMilliseconds;
          pings.add(ping);
        } catch (e) {
          _logger.d('Ping test failed for $url: $e');
        }
      }
      
      if (pings.isEmpty) {
        return {'error': 'All ping tests failed'};
      }
      
      final avgPing = pings.reduce((a, b) => a + b) / pings.length;
      final minPing = pings.reduce((a, b) => a < b ? a : b);
      final maxPing = pings.reduce((a, b) => a > b ? a : b);
      
      return {
        'average': avgPing,
        'minimum': minPing,
        'maximum': maxPing,
        'count': pings.length,
      };
    } catch (e) {
      _logger.e('Error testing ping', error: e);
      return {'error': e.toString()};
    }
  }

  /// Тест стабильности соединения
  Future<Map<String, dynamic>> _testStability() async {
    try {
      const testUrl = 'https://www.google.com';
      const testCount = 5;
      
      int successCount = 0;
      int totalTime = 0;
      
      for (int i = 0; i < testCount; i++) {
        try {
          final startTime = DateTime.now();
          
          await _httpClient
              .get(Uri.parse(testUrl))
              .timeout(const Duration(seconds: 5));
          
          final endTime = DateTime.now();
          totalTime += endTime.difference(startTime).inMilliseconds;
          successCount++;
          
          // Небольшая пауза между тестами
          await Future.delayed(const Duration(milliseconds: 500));
        } catch (e) {
          _logger.d('Stability test $i failed: $e');
        }
      }
      
      final successRate = successCount / testCount;
      final avgResponseTime = successCount > 0 ? totalTime / successCount : 0;
      
      return {
        'successRate': successRate,
        'successCount': successCount,
        'totalTests': testCount,
        'averageResponseTime': avgResponseTime,
      };
    } catch (e) {
      _logger.e('Error testing stability', error: e);
      return {'error': e.toString()};
    }
  }

  /// Расчет оценки качества соединения
  double _calculateQualityScore(Map<String, dynamic> results) {
    try {
      double score = 0.0;
      
      // Оценка пинга (0-30 баллов)
      if (results['ping'] is Map && !results['ping'].containsKey('error')) {
        final avgPing = results['ping']['average'] as double;
        if (avgPing < 50) {
          score += 30;
        } else if (avgPing < 100) {
          score += 20;
        } else if (avgPing < 200) {
          score += 10;
        }
      }
      
      // Оценка скорости (0-40 баллов)
      if (results['speed'] is Map && !results['speed'].containsKey('error')) {
        final speedMBps = results['speed']['speedMBps'] as double;
        if (speedMBps > 10) {
          score += 40;
        } else if (speedMBps > 5) {
          score += 30;
        } else if (speedMBps > 1) {
          score += 20;
        } else if (speedMBps > 0.1) {
          score += 10;
        }
      }
      
      // Оценка стабильности (0-30 баллов)
      if (results['stability'] is Map && !results['stability'].containsKey('error')) {
        final successRate = results['stability']['successRate'] as double;
        score += successRate * 30;
      }
      
      return score.clamp(0.0, 100.0);
    } catch (e) {
      _logger.e('Error calculating quality score', error: e);
      return 0.0;
    }
  }

  /// Получение HTTP клиента
  http.Client get httpClient => _httpClient;

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      _logger.i('Disposing network service...');
      
      await _connectivitySubscription?.cancel();
      _connectionStatusController.close();
      
      _logger.i('Network service disposed successfully');
    } catch (e) {
      _logger.e('Error disposing network service', error: e);
    }
  }
}
