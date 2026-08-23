/// Исключения доменного слоя
/// Определяет типы ошибок для бизнес-логики

/// Базовое исключение для шлюза
class GatewayException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  GatewayException(this.message, {this.code, this.originalError});

  @override
  String toString() => 'GatewayException: $message';
}

/// Исключение для конфигурации
class ConfigurationException extends GatewayException {
  ConfigurationException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'ConfigurationException: $message';
}

/// Исключение для подключения
class ConnectionException extends GatewayException {
  ConnectionException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'ConnectionException: $message';
}

/// Исключение для звонков
class CallException extends GatewayException {
  CallException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'CallException: $message';
}

/// Исключение для SMS
class SmsException extends GatewayException {
  SmsException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'SmsException: $message';
}

/// Исключение для разрешений
class PermissionException extends GatewayException {
  PermissionException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'PermissionException: $message';
}

/// Исключение для валидации
class ValidationException extends GatewayException {
  final List<String> errors;

  ValidationException(String message, {required this.errors, String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'ValidationException: $message\nErrors: ${errors.join(', ')}';
}

/// Исключение для сетевых ошибок
class NetworkException extends GatewayException {
  NetworkException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'NetworkException: $message';
}

/// Исключение для устройств
class DeviceException extends GatewayException {
  DeviceException(String message, {String? code, dynamic originalError})
      : super(message, code: code, originalError: originalError);

  @override
  String toString() => 'DeviceException: $message';
}
