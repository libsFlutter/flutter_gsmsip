import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/usecases/analytics_usecases.dart';
// DI removed - should be in example app, not library

/// Глобальный обработчик ошибок
class ErrorHandler {
  static final Logger _logger = Logger();
  static const String _errorLogKey = 'error_logs';
  static const int _maxErrorLogs = 100;
  static BuildContext? _globalContext;

  /// Обработка ошибок приложения
  static void handleError(dynamic error, StackTrace? stackTrace) {
    _logger.e('Application error occurred', error: error, stackTrace: stackTrace);
    
    // Сохранение ошибки в лог
    _saveErrorToLog(error, stackTrace);
    
    // Отправка ошибки в аналитику (если доступно)
    _sendErrorToAnalytics(error, stackTrace);
    
    // Показ пользователю (если необходимо)
    _showUserFriendlyError(error);
  }

  /// Обработка сетевых ошибок
  static void handleNetworkError(dynamic error, String endpoint) {
    _logger.w('Network error for endpoint: $endpoint', error: error);
    
    final errorMessage = _getNetworkErrorMessage(error);
    _showSnackBar(errorMessage);
  }

  /// Обработка ошибок валидации
  static void handleValidationError(String field, String message) {
    _logger.w('Validation error for field: $field - $message');
    
    final errorMessage = 'Invalid $field: $message';
    _showSnackBar(errorMessage);
  }

  /// Обработка ошибок аутентификации
  static void handleAuthError(dynamic error) {
    _logger.w('Authentication error', error: error);
    
    // Перенаправление на экран входа
    _navigateToLogin();
  }

  /// Обработка ошибок разрешений
  static void handlePermissionError(String permission) {
    _logger.w('Permission denied: $permission');
    
    final errorMessage = 'Permission required: $permission';
    _showSnackBar(errorMessage);
  }

  /// Сохранение ошибки в локальный лог
  static Future<void> _saveErrorToLog(dynamic error, StackTrace? stackTrace) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final errorLogs = prefs.getStringList(_errorLogKey) ?? [];
      
      final errorEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'error': error.toString(),
        'stackTrace': stackTrace?.toString() ?? '',
      };
      
      errorLogs.add(errorEntry.toString());
      
      // Ограничение размера лога
      if (errorLogs.length > _maxErrorLogs) {
        errorLogs.removeRange(0, errorLogs.length - _maxErrorLogs);
      }
      
      await prefs.setStringList(_errorLogKey, errorLogs);
    } catch (e) {
      _logger.e('Failed to save error log', error: e);
    }
  }

  /// Отправка ошибки в аналитику
  static void _sendErrorToAnalytics(dynamic error, StackTrace? stackTrace) {
    // Analytics integration removed - should be implemented in example app
    // This is a library-level error handler, analytics is app-specific
  }

  /// Получение экземпляра AnalyticsUseCases
  /// Removed - analytics should be handled in example app
  static AnalyticsUseCases? _getAnalyticsUseCases() => null;

  /// Показ пользовательской ошибки
  static void _showUserFriendlyError(dynamic error) {
    final message = _getUserFriendlyMessage(error);
    _showSnackBar(message);
  }

  /// Получение пользовательского сообщения об ошибке
  static String _getUserFriendlyMessage(dynamic error) {
    if (error.toString().contains('network')) {
      return 'Network connection error. Please check your internet connection.';
    } else if (error.toString().contains('timeout')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('permission')) {
      return 'Permission denied. Please grant required permissions.';
    } else if (error.toString().contains('validation')) {
      return 'Invalid data provided. Please check your input.';
    } else {
      return 'An unexpected error occurred. Please try again.';
    }
  }

  /// Получение сообщения о сетевой ошибке
  static String _getNetworkErrorMessage(dynamic error) {
    if (error.toString().contains('SocketException')) {
      return 'No internet connection. Please check your network.';
    } else if (error.toString().contains('TimeoutException')) {
      return 'Request timeout. Please try again.';
    } else if (error.toString().contains('HttpException')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Network error. Please check your connection.';
    }
  }

  /// Показ SnackBar с сообщением
  static void _showSnackBar(String message) {
    // Получение контекста через глобальный ключ
    final context = _getGlobalContext();
    if (context != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: 'Dismiss',
            textColor: Colors.white,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        ),
      );
    }
  }

  /// Перенаправление на экран входа
  static void _navigateToLogin() {
    final context = _getGlobalContext();
    if (context != null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }
  }

  /// Получение глобального контекста
  static BuildContext? _getGlobalContext() {
    return _globalContext;
  }

  /// Установка глобального контекста
  static void setGlobalContext(BuildContext context) {
    _globalContext = context;
  }

  /// Очистка глобального контекста
  static void clearGlobalContext() {
    _globalContext = null;
  }

  /// Получение логов ошибок
  static Future<List<String>> getErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getStringList(_errorLogKey) ?? [];
    } catch (e) {
      _logger.e('Failed to get error logs', error: e);
      return [];
    }
  }

  /// Очистка логов ошибок
  static Future<void> clearErrorLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_errorLogKey);
      _logger.i('Error logs cleared');
    } catch (e) {
      _logger.e('Failed to clear error logs', error: e);
    }
  }

  /// Проверка наличия критических ошибок
  static Future<bool> hasCriticalErrors() async {
    try {
      final logs = await getErrorLogs();
      final recentLogs = logs.where((log) {
        final timestamp = DateTime.tryParse(log.split('timestamp: ')[1].split(',')[0]);
        if (timestamp == null) return false;
        return DateTime.now().difference(timestamp).inHours < 24;
      }).toList();
      
      return recentLogs.length > 10; // Более 10 ошибок за 24 часа
    } catch (e) {
      _logger.e('Failed to check critical errors', error: e);
      return false;
    }
  }
}

/// Класс для обработки ошибок в виджетах
class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final Widget Function(dynamic error)? errorBuilder;

  const ErrorBoundary({
    Key? key,
    required this.child,
    this.errorBuilder,
  }) : super(key: key);

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  dynamic _error;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error) ?? _defaultErrorWidget();
    }
    return widget.child;
  }

  Widget _defaultErrorWidget() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 48,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          const Text(
            'Something went wrong',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            _error.toString(),
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _error = null;
              });
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _setupErrorHandling();
  }

  void _setupErrorHandling() {
    // Обработка ошибок Flutter
    FlutterError.onError = (FlutterErrorDetails details) {
      setState(() {
        _error = details.exception;
      });
      ErrorHandler.handleError(details.exception, details.stack);
    };
  }
}
