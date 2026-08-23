import 'package:equatable/equatable.dart';

/// Модель для статистики соединения (SIP/SMPP)
class ConnectionStats extends Equatable {
  /// Тип соединения (SIP, SMPP, GSM)
  final String connectionType;
  
  /// Статус подключения
  final bool isConnected;
  
  /// Задержка в миллисекундах
  final double latency;
  
  /// Потеря пакетов в процентах
  final double packetLoss;
  
  /// Пропускная способность входящая (kbps)
  final double bandwidthIn;
  
  /// Пропускная способность исходящая (kbps)
  final double bandwidthOut;
  
  /// Jitter в миллисекундах
  final double jitter;
  
  /// MOS (Mean Opinion Score) для качества голоса
  final double mos;
  
  /// Количество попыток переподключения
  final int reconnectAttempts;
  
  /// Время последнего обновления
  final DateTime lastUpdate;
  
  /// Сообщение об ошибке (если есть)
  final String? errorMessage;
  
  /// Время установки соединения
  final DateTime? connectedAt;
  
  /// Время последнего разрыва соединения
  final DateTime? disconnectedAt;
  
  /// Общее время работы соединения
  final Duration uptime;
  
  /// Статистика за последний час
  final Map<String, dynamic> hourlyStats;

  const ConnectionStats({
    required this.connectionType,
    required this.isConnected,
    required this.latency,
    required this.packetLoss,
    required this.bandwidthIn,
    required this.bandwidthOut,
    required this.jitter,
    required this.mos,
    required this.reconnectAttempts,
    required this.lastUpdate,
    this.errorMessage,
    this.connectedAt,
    this.disconnectedAt,
    required this.uptime,
    required this.hourlyStats,
  });

  /// Создание начального состояния для типа соединения
  factory ConnectionStats.initial(String connectionType) {
    return ConnectionStats(
      connectionType: connectionType,
      isConnected: false,
      latency: 0.0,
      packetLoss: 0.0,
      bandwidthIn: 0.0,
      bandwidthOut: 0.0,
      jitter: 0.0,
      mos: 0.0,
      reconnectAttempts: 0,
      lastUpdate: DateTime.now(),
      uptime: Duration.zero,
      hourlyStats: {},
    );
  }

  /// Создание копии с измененными параметрами
  ConnectionStats copyWith({
    String? connectionType,
    bool? isConnected,
    double? latency,
    double? packetLoss,
    double? bandwidthIn,
    double? bandwidthOut,
    double? jitter,
    double? mos,
    int? reconnectAttempts,
    DateTime? lastUpdate,
    String? errorMessage,
    DateTime? connectedAt,
    DateTime? disconnectedAt,
    Duration? uptime,
    Map<String, dynamic>? hourlyStats,
  }) {
    return ConnectionStats(
      connectionType: connectionType ?? this.connectionType,
      isConnected: isConnected ?? this.isConnected,
      latency: latency ?? this.latency,
      packetLoss: packetLoss ?? this.packetLoss,
      bandwidthIn: bandwidthIn ?? this.bandwidthIn,
      bandwidthOut: bandwidthOut ?? this.bandwidthOut,
      jitter: jitter ?? this.jitter,
      mos: mos ?? this.mos,
      reconnectAttempts: reconnectAttempts ?? this.reconnectAttempts,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      errorMessage: errorMessage,
      connectedAt: connectedAt ?? this.connectedAt,
      disconnectedAt: disconnectedAt ?? this.disconnectedAt,
      uptime: uptime ?? this.uptime,
      hourlyStats: hourlyStats ?? this.hourlyStats,
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'connection_type': connectionType,
      'is_connected': isConnected,
      'latency': latency,
      'packet_loss': packetLoss,
      'bandwidth_in': bandwidthIn,
      'bandwidth_out': bandwidthOut,
      'jitter': jitter,
      'mos': mos,
      'reconnect_attempts': reconnectAttempts,
      'last_update': lastUpdate.toIso8601String(),
      'error_message': errorMessage,
      'connected_at': connectedAt?.toIso8601String(),
      'disconnected_at': disconnectedAt?.toIso8601String(),
      'uptime_seconds': uptime.inSeconds,
      'hourly_stats': hourlyStats,
    };
  }

  /// Создание из JSON
  factory ConnectionStats.fromJson(Map<String, dynamic> json) {
    return ConnectionStats(
      connectionType: json['connection_type'] as String,
      isConnected: json['is_connected'] as bool,
      latency: (json['latency'] as num).toDouble(),
      packetLoss: (json['packet_loss'] as num).toDouble(),
      bandwidthIn: (json['bandwidth_in'] as num).toDouble(),
      bandwidthOut: (json['bandwidth_out'] as num).toDouble(),
      jitter: (json['jitter'] as num).toDouble(),
      mos: (json['mos'] as num).toDouble(),
      reconnectAttempts: json['reconnect_attempts'] as int,
      lastUpdate: DateTime.parse(json['last_update'] as String),
      errorMessage: json['error_message'] as String?,
      connectedAt: json['connected_at'] != null 
          ? DateTime.parse(json['connected_at'] as String) 
          : null,
      disconnectedAt: json['disconnected_at'] != null 
          ? DateTime.parse(json['disconnected_at'] as String) 
          : null,
      uptime: Duration(seconds: json['uptime_seconds'] as int),
      hourlyStats: Map<String, dynamic>.from(json['hourly_stats'] as Map? ?? {}),
    );
  }

  /// Получение качества соединения как строки
  String get qualityDescription {
    if (!isConnected) return 'Disconnected';
    
    if (latency < 50 && packetLoss < 1) return 'Excellent';
    if (latency < 100 && packetLoss < 3) return 'Good';
    if (latency < 200 && packetLoss < 5) return 'Fair';
    return 'Poor';
  }

  /// Получение цвета для качества соединения
  String get qualityColor {
    if (!isConnected) return 'red';
    
    switch (qualityDescription) {
      case 'Excellent':
        return 'green';
      case 'Good':
        return 'lightgreen';
      case 'Fair':
        return 'orange';
      default:
        return 'red';
    }
  }

  /// Проверка, стабильно ли соединение
  bool get isStable {
    return isConnected && 
           latency < 150 && 
           packetLoss < 2 && 
           reconnectAttempts < 3;
  }

  /// Получение процента аптайма за последний час
  double get uptimePercentage {
    if (connectedAt == null) return 0.0;
    
    final now = DateTime.now();
    final hourAgo = now.subtract(const Duration(hours: 1));
    final relevantStart = connectedAt!.isAfter(hourAgo) ? connectedAt! : hourAgo;
    
    final totalTime = now.difference(relevantStart);
    final connectedTime = disconnectedAt != null && disconnectedAt!.isAfter(relevantStart)
        ? disconnectedAt!.difference(relevantStart)
        : totalTime;
    
    return totalTime.inSeconds > 0 
        ? (connectedTime.inSeconds / totalTime.inSeconds) * 100 
        : 0.0;
  }

  @override
  List<Object?> get props => [
        connectionType,
        isConnected,
        latency,
        packetLoss,
        bandwidthIn,
        bandwidthOut,
        jitter,
        mos,
        reconnectAttempts,
        lastUpdate,
        errorMessage,
        connectedAt,
        disconnectedAt,
        uptime,
        hourlyStats,
      ];

  @override
  String toString() {
    return 'ConnectionStats('
        'type: $connectionType, '
        'connected: $isConnected, '
        'latency: ${latency.toStringAsFixed(1)}ms, '
        'quality: $qualityDescription'
        ')';
  }
}