import 'package:flutter/foundation.dart';
import '../../domain/models/dongle_interface_type.dart';
import '../../domain/models/dongle_type.dart';

/// Исключения Dongle
class DongleException implements Exception {
  final String message;
  final DongleInterfaceType? interfaceType;

  const DongleException(this.message, {this.interfaceType});

  @override
  String toString() => 'DongleException: $message';
}

/// Донгл не найден
class DongleNotFoundException extends DongleException {
  const DongleNotFoundException()
      : super('No dongle detected. Connect USB-C or TRRS adapter.');
}

/// Ошибка измерения сопротивлений
class ResistanceMeasurementException extends DongleException {
  final String reason;

  const ResistanceMeasurementException(this.reason)
      : super('Cannot measure resistance: $reason');
}

/// Ошибка определения типа
class TypeDetectionException extends DongleException {
  const TypeDetectionException()
      : super('Cannot detect dongle type. Unknown resistance signature.');
}

/// Ошибка конфигурации
class DongleConfigException extends DongleException {
  const DongleConfigException(String message) : super(message);
}

/// Ошибка USB подключения
class UsbConnectionException extends DongleException {
  final String reason;

  const UsbConnectionException(this.reason)
      : super('USB connection error: $reason', interfaceType: DongleInterfaceType.usbCWithDac);
}

/// Ошибка TRRS подключения
class TrrsConnectionException extends DongleException {
  const TrrsConnectionException()
      : super('TRRS jack not inserted', interfaceType: DongleInterfaceType.trrs);
}

/// Сервис для обработки ошибок Dongle
class DongleErrorHandler {
  /// Обработать ошибку
  static void handleError(Object error, {Function(DongleException)? onDongle}) {
    if (error is DongleException) {
      debugPrint('Dongle Error: $error');
      onDongle?.call(error);
    } else {
      debugPrint('Unknown Error: $error');
    }
  }

  /// Получить сообщение для пользователя
  static String getUserMessage(DongleException exception) {
    if (exception is DongleNotFoundException) {
      return 'No dongle detected. Please connect a USB-C or TRRS adapter.';
    } else if (exception is ResistanceMeasurementException) {
      return 'Cannot measure resistance: ${exception.reason}\n\nThis may be normal for USB-C with DAC (digital interface).';
    } else if (exception is TypeDetectionException) {
      return 'Cannot detect dongle type. The resistance signature does not match known types.\n\nYou can select the type manually.';
    } else if (exception is UsbConnectionException) {
      return 'USB connection error: ${exception.reason}\n\nCheck the USB connection and try again.';
    } else if (exception is TrrsConnectionException) {
      return 'TRRS jack not inserted. Please connect the 3.5mm adapter.';
    }
    return exception.message;
  }

  /// Предложить действие
  static String getSuggestedAction(DongleException exception) {
    if (exception is DongleNotFoundException) {
      return 'Connect dongle or use alternative method';
    } else if (exception is ResistanceMeasurementException) {
      return 'Select type manually';
    } else if (exception is TypeDetectionException) {
      return 'Select type from list';
    } else if (exception is UsbConnectionException) {
      return 'Reconnect USB device';
    } else if (exception is TrrsConnectionException) {
      return 'Insert TRRS jack';
    }
    return 'Retry operation';
  }
}

/// Сервис уведомлений Dongle
class DongleNotificationService {
  /// Показать уведомление о подключении донгла
  static void showDongleConnected(DongleInterfaceType type) {
    debugPrint('📢 Dongle connected: ${type.displayName}');
    // В реальной реализации - показать Snackbar или Notification
  }

  /// Показать уведомление об отключении донгла
  static void showDongleDisconnected() {
    debugPrint('📢 Dongle disconnected');
    // В реальной реализации - показать Warning Banner
  }

  /// Показать уведомление об ошибке
  static void showError(DongleException exception) {
    final message = DongleErrorHandler.getUserMessage(exception);
    debugPrint('❌ Dongle Error: $message');
    // В реальной реализации - показать Error Banner
  }

  /// Показать уведомление об успешном определении типа
  static void showTypeDetected(DongleType type, double confidence) {
    debugPrint('✅ Dongle type detected: ${type.displayName} (${(confidence * 100).toStringAsFixed(0)}% confidence)');
    // В реальной реализации - показать Success Snackbar
  }

  /// Показать уведомление о проблемах с качеством
  static void showQualityWarning(String interfaceType, String quality) {
    debugPrint('⚠️ Dongle quality warning: $interfaceType - $quality');
    // В реальной реализации - показать Warning Banner
  }
}

/// Extension для удобной обработки ошибок
extension DongleFutureExtension<T> on Future<T> {
  /// Обработать ошибку Dongle
  Future<T> handleDongleErrors({
    Function(DongleException)? onError,
    Function(T)? onSuccess,
  }) async {
    try {
      final result = await this;
      onSuccess?.call(result);
      return result;
    } on DongleException catch (e) {
      DongleErrorHandler.handleError(e, onDongle: onError);
      rethrow;
    }
  }
}
