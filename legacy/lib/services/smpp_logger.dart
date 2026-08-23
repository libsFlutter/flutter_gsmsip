import 'package:flutter/foundation.dart';

enum SmppLogLevel {
  debug,
  info,
  warning,
  error,
}

class SmppLogger {
  static final SmppLogger _instance = SmppLogger._internal();
  factory SmppLogger() => _instance;
  SmppLogger._internal();

  SmppLogLevel _minLevel = SmppLogLevel.info;
  final List<String> _logBuffer = [];
  static const int _maxBufferSize = 1000;

  void setLogLevel(SmppLogLevel level) {
    _minLevel = level;
  }

  void debug(String message) => _log(message, SmppLogLevel.debug);
  void info(String message) => _log(message, SmppLogLevel.info);
  void warning(String message) => _log(message, SmppLogLevel.warning);
  void error(String message) => _log(message, SmppLogLevel.error);

  void _log(String message, SmppLogLevel level) {
    if (level.index >= _minLevel.index) {
      final timestamp = DateTime.now().toIso8601String();
      final logMessage = '[$timestamp] SMPP [${level.name.toUpperCase()}]: $message';
      
      // Add to buffer
      _logBuffer.add(logMessage);
      if (_logBuffer.length > _maxBufferSize) {
        _logBuffer.removeAt(0);
      }

      // Output based on level
      switch (level) {
        case SmppLogLevel.debug:
          if (kDebugMode) {
            debugPrint(logMessage);
          }
          break;
        case SmppLogLevel.info:
          debugPrint(logMessage);
          break;
        case SmppLogLevel.warning:
          debugPrint('⚠️ $logMessage');
          break;
        case SmppLogLevel.error:
          debugPrint('❌ $logMessage');
          break;
      }
    }
  }

  List<String> getLogs() => List.unmodifiable(_logBuffer);

  void clearLogs() {
    _logBuffer.clear();
  }

  String getLogLevelName() => _minLevel.name.toUpperCase();
}
