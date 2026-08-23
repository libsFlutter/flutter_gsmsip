import 'package:flutter/foundation.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/test_method_result.dart';
import '../../domain/repositories/voice_line_repository.dart';

/// Исключения VoiceLine
class VoiceLineException implements Exception {
  final String message;
  final VoiceLineMethod? method;

  const VoiceLineException(this.message, {this.method});

  @override
  String toString() => 'VoiceLineException: $message';
}

/// Метод недоступен
class MethodUnavailableException extends VoiceLineException {
  final VoiceLineMethod method;
  final String reason;

  const MethodUnavailableException(this.method, this.reason)
      : super('Method $method is unavailable: $reason', method: method);
}

/// Ошибка тестирования
class TestFailedException extends VoiceLineException {
  final TestMethodResult result;

  const TestFailedException(this.result)
      : super('Test failed: ${result.error}', method: result.success ? null : null);
}

/// Ошибка конфигурации
class ConfigException extends VoiceLineException {
  const ConfigException(String message) : super(message);
}

/// Сервис для обработки ошибок VoiceLine
class VoiceLineErrorHandler {
  /// Обработать ошибку
  static void handleError(Object error, {Function(VoiceLineException)? onVoiceLine}) {
    if (error is VoiceLineException) {
      debugPrint('VoiceLine Error: $error');
      onVoiceLine?.call(error);
    } else {
      debugPrint('Unknown Error: $error');
    }
  }

  /// Получить сообщение для пользователя
  static String getUserMessage(VoiceLineException exception) {
    if (exception is MethodUnavailableException) {
      return _getMethodUnavailableMessage(exception.method, exception.reason);
    } else if (exception is TestFailedException) {
      return 'Test failed: ${exception.result.error}';
    } else if (exception is ConfigException) {
      return 'Configuration error: ${exception.message}';
    }
    return exception.message;
  }

  static String _getMethodUnavailableMessage(
    VoiceLineMethod method,
    String reason,
  ) {
    switch (method) {
      case VoiceLineMethod.ttyPort:
        return 'TTY Port not available: $reason\n\nTry configuring the port manually in settings.';
      case VoiceLineMethod.enhancedMode:
        return 'Enhanced Mode not available: $reason\n\nThis feature requires special setup. Contact support for assistance.';
      case VoiceLineMethod.dongle:
        return 'Dongle not detected: $reason\n\nPlease connect a compatible USB-C or TRRS adapter.';
      case VoiceLineMethod.telecomApi:
        return 'Telecom API error: $reason\n\nThis should work on all Android devices.';
      case VoiceLineMethod.acoustic:
        return 'Acoustic mode error: $reason';
    }
  }

  /// Предложить действие
  static String getSuggestedAction(VoiceLineException exception) {
    if (exception is MethodUnavailableException) {
      switch (exception.method) {
        case VoiceLineMethod.ttyPort:
          return 'Configure TTY Port manually';
        case VoiceLineMethod.enhancedMode:
          return 'Use alternative method';
        case VoiceLineMethod.dongle:
          return 'Connect dongle or use alternative';
        case VoiceLineMethod.telecomApi:
          return 'Retry or use fallback';
        case VoiceLineMethod.acoustic:
          return 'Check audio permissions';
      }
    }
    return 'Retry operation';
  }
}

/// Сервис уведомлений VoiceLine
class VoiceLineNotificationService {
  /// Показать уведомление о смене метода
  static void showMethodChanged(VoiceLineMethod method) {
    debugPrint('📢 Voice Line method changed to: ${method.displayName}');
    // В реальной реализации - показать Snackbar или Notification
  }

  /// Показать уведомление об ошибке
  static void showError(VoiceLineException exception) {
    final message = VoiceLineErrorHandler.getUserMessage(exception);
    debugPrint('❌ Voice Line Error: $message');
    // В реальной реализации - показать Error Banner
  }

  /// Показать уведомление о успешном тесте
  static void showTestSuccess(TestMethodResult result) {
    debugPrint('✅ Voice Line test passed: ${result.quality.description}');
    // В реальной реализации - показать Success Snackbar
  }

  /// Показать уведомление о проблемах с качеством
  static void showQualityWarning(String method, String quality) {
    debugPrint('⚠️ Voice Line quality warning: $method - $quality');
    // В реальной реализации - показать Warning Banner
  }
}

/// Extension для удобной обработки ошибок
extension VoiceLineFutureExtension<T> on Future<T> {
  /// Обработать ошибку VoiceLine
  Future<T> handleVoiceLineErrors({
    Function(VoiceLineException)? onError,
    Function(T)? onSuccess,
  }) async {
    try {
      final result = await this;
      onSuccess?.call(result);
      return result;
    } on VoiceLineException catch (e) {
      VoiceLineErrorHandler.handleError(e, onVoiceLine: onError);
      rethrow;
    }
  }
}
