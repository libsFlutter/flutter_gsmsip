import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:logger/logger.dart';
import '../models/connection_stats.dart';

/// Сервис для мониторинга соединений SIP/SMPP в реальном времени
/// Отслеживает качество соединения, задержки, пакеты
class ConnectionMonitorService {
  static final ConnectionMonitorService _instance = ConnectionMonitorService._internal();
  factory ConnectionMonitorService() => _instance;
  ConnectionMonitorService._internal();

  final Logger _logger = Logger();
  final Connectivity _connectivity = Connectivity();
  
  // Stream controllers для real-time обновлений
  final StreamController<ConnectionStats> _sipStatsController = 
      StreamController<ConnectionStats>.broadcast();
  final StreamController<ConnectionStats> _smppStatsController = 
      StreamController<ConnectionStats>.broadcast();
  final StreamController<Map<String, dynamic>> _networkStatusController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Состояние мониторинга
  bool _isMonitoring = false;
  Timer? _monitoringTimer;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  // Статистика соединений
  ConnectionStats _sipStats = ConnectionStats.initial('SIP');
  ConnectionStats _smppStats = ConnectionStats.initial('SMPP');
  Map<String, dynamic> _networkStatus = {};

  // Геттеры для стримов
  Stream<ConnectionStats> get sipStatsStream => _sipStatsController.stream;
  Stream<ConnectionStats> get smppStatsStream => _smppStatsController.stream;
  Stream<Map<String, dynamic>> get networkStatusStream => _networkStatusController.stream;

  // Геттеры для текущих данных
  ConnectionStats get currentSipStats => _sipStats;
  ConnectionStats get currentSmppStats => _smppStats;
  Map<String, dynamic> get currentNetworkStatus => _networkStatus;

  /// Запуск мониторинга соединений
  Future<void> startMonitoring({
    String? sipServer,
    int? sipPort,
    String? smppServer,
    int? smppPort,
  }) async {
    if (_isMonitoring) {
      _logger.w('Connection monitoring already running');
      return;
    }

    _logger.i('Starting connection monitoring...');
    _isMonitoring = true;

    // Подписка на изменения сетевого подключения
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _handleConnectivityChange,
      onError: (error) => _logger.e('Connectivity subscription error: $error'),
    );

    // Запуск периодического мониторинга
    _monitoringTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _performMonitoringCycle(sipServer, sipPort, smppServer, smppPort),
    );

    // Первый цикл мониторинга
    await _performMonitoringCycle(sipServer, sipPort, smppServer, smppPort);
    
    _logger.i('Connection monitoring started');
  }

  /// Остановка мониторинга
  Future<void> stopMonitoring() async {
    if (!_isMonitoring) return;

    _logger.i('Stopping connection monitoring...');
    _isMonitoring = false;

    _monitoringTimer?.cancel();
    await _connectivitySubscription?.cancel();

    _logger.i('Connection monitoring stopped');
  }

  /// Выполнение цикла мониторинга
  Future<void> _performMonitoringCycle(
    String? sipServer,
    int? sipPort,
    String? smppServer,
    int? smppPort,
  ) async {
    try {
      // Проверка общего состояния сети
      await _updateNetworkStatus();

      // Проверка SIP соединения
      if (sipServer != null && sipPort != null) {
        await _checkSipConnection(sipServer, sipPort);
      }

      // Проверка SMPP соединения
      if (smppServer != null && smppPort != null) {
        await _checkSmppConnection(smppServer, smppPort);
      }
    } catch (e) {
      _logger.e('Error in monitoring cycle: $e');
    }
  }

  /// Проверка SIP соединения
  Future<void> _checkSipConnection(String server, int port) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Проверка TCP подключения к SIP серверу
      final socket = await Socket.connect(server, port, timeout: const Duration(seconds: 5));
      stopwatch.stop();
      
      await socket.close();

      _sipStats = _sipStats.copyWith(
        isConnected: true,
        latency: stopwatch.elapsedMilliseconds.toDouble(),
        lastUpdate: DateTime.now(),
        errorMessage: null,
        reconnectAttempts: 0,
      );

      _sipStatsController.add(_sipStats);
      _logger.d('SIP connection check successful: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      stopwatch.stop();
      
      _sipStats = _sipStats.copyWith(
        isConnected: false,
        latency: -1,
        lastUpdate: DateTime.now(),
        errorMessage: e.toString(),
        reconnectAttempts: _sipStats.reconnectAttempts + 1,
      );

      _sipStatsController.add(_sipStats);
      _logger.w('SIP connection check failed: $e');
    }
  }

  /// Проверка SMPP соединения
  Future<void> _checkSmppConnection(String server, int port) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Проверка TCP подключения к SMPP серверу
      final socket = await Socket.connect(server, port, timeout: const Duration(seconds: 5));
      stopwatch.stop();
      
      await socket.close();

      _smppStats = _smppStats.copyWith(
        isConnected: true,
        latency: stopwatch.elapsedMilliseconds.toDouble(),
        lastUpdate: DateTime.now(),
        errorMessage: null,
        reconnectAttempts: 0,
      );

      _smppStatsController.add(_smppStats);
      _logger.d('SMPP connection check successful: ${stopwatch.elapsedMilliseconds}ms');
    } catch (e) {
      stopwatch.stop();
      
      _smppStats = _smppStats.copyWith(
        isConnected: false,
        latency: -1,
        lastUpdate: DateTime.now(),
        errorMessage: e.toString(),
        reconnectAttempts: _smppStats.reconnectAttempts + 1,
      );

      _smppStatsController.add(_smppStats);
      _logger.w('SMPP connection check failed: $e');
    }
  }

  /// Обновление статуса сети
  Future<void> _updateNetworkStatus() async {
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      
      _networkStatus = {
        'connectivity_type': connectivityResult.name,
        'is_connected': connectivityResult != ConnectivityResult.none,
        'last_update': DateTime.now().toIso8601String(),
        'signal_strength': await _getSignalStrength(),
        'network_quality': _calculateNetworkQuality(),
      };

      _networkStatusController.add(_networkStatus);
    } catch (e) {
      _logger.e('Error updating network status: $e');
    }
  }

  /// Обработка изменения сетевого подключения
  void _handleConnectivityChange(ConnectivityResult result) {
    _logger.i('Network connectivity changed: ${result.name}');
    
    _networkStatus = {
      ..._networkStatus,
      'connectivity_type': result.name,
      'is_connected': result != ConnectivityResult.none,
      'last_update': DateTime.now().toIso8601String(),
    };

    _networkStatusController.add(_networkStatus);

    // При изменении сети - сброс статистики соединений
    if (result == ConnectivityResult.none) {
      _sipStats = _sipStats.copyWith(isConnected: false, errorMessage: 'Network disconnected');
      _smppStats = _smppStats.copyWith(isConnected: false, errorMessage: 'Network disconnected');
      
      _sipStatsController.add(_sipStats);
      _smppStatsController.add(_smppStats);
    }
  }

  /// Получение силы сигнала (заглушка для Android)
  Future<int> _getSignalStrength() async {
    // В реальном приложении здесь будет обращение к Android API
    // для получения силы сигнала
    return 75; // Симуляция 75% силы сигнала
  }

  /// Расчет качества сети
  String _calculateNetworkQuality() {
    final sipLatency = _sipStats.latency;
    final smppLatency = _smppStats.latency;
    
    if (sipLatency < 0 || smppLatency < 0) return 'Poor';
    
    final avgLatency = (sipLatency + smppLatency) / 2;
    
    if (avgLatency < 50) return 'Excellent';
    if (avgLatency < 100) return 'Good';
    if (avgLatency < 200) return 'Fair';
    return 'Poor';
  }

  /// Тест скорости соединения
  Future<Map<String, double>> performSpeedTest() async {
    _logger.i('Starting network speed test...');
    
    try {
      // Простой тест скорости загрузки
      final stopwatch = Stopwatch()..start();
      final client = HttpClient();
      
      // Загрузка тестового файла (1KB)
      final request = await client.getUrl(Uri.parse('https://httpbin.org/bytes/1024'));
      final response = await request.close();
      await response.drain();
      
      stopwatch.stop();
      client.close();
      
      final downloadSpeed = (1024 * 8) / (stopwatch.elapsedMilliseconds / 1000); // bits per second
      
      _logger.i('Speed test completed: ${downloadSpeed.toStringAsFixed(2)} bps');
      
      return {
        'download_speed_bps': downloadSpeed,
        'download_speed_kbps': downloadSpeed / 1024,
        'latency_ms': stopwatch.elapsedMilliseconds.toDouble(),
      };
    } catch (e) {
      _logger.e('Speed test failed: $e');
      return {
        'download_speed_bps': 0,
        'download_speed_kbps': 0,
        'latency_ms': -1,
      };
    }
  }

  /// Получение детальной статистики за период
  Map<String, dynamic> getDetailedStats({Duration? period}) {
    final now = DateTime.now();
    final periodStart = period != null ? now.subtract(period) : now.subtract(const Duration(hours: 1));
    
    return {
      'period_start': periodStart.toIso8601String(),
      'period_end': now.toIso8601String(),
      'sip_stats': {
        'average_latency': _sipStats.latency,
        'connection_uptime': _sipStats.isConnected ? '100%' : '0%',
        'reconnect_attempts': _sipStats.reconnectAttempts,
        'last_error': _sipStats.errorMessage,
      },
      'smpp_stats': {
        'average_latency': _smppStats.latency,
        'connection_uptime': _smppStats.isConnected ? '100%' : '0%',
        'reconnect_attempts': _smppStats.reconnectAttempts,
        'last_error': _smppStats.errorMessage,
      },
      'network_quality': _calculateNetworkQuality(),
      'monitoring_active': _isMonitoring,
    };
  }

  /// Очистка ресурсов
  void dispose() {
    stopMonitoring();
    _sipStatsController.close();
    _smppStatsController.close();
    _networkStatusController.close();
  }
}
