/// Exception classes for the GOSTsimbox Gateway
/// Part of centralized error handling

import 'package:equatable/equatable.dart';

/// Base exception class for all application exceptions
abstract class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.originalError,
    this.stackTrace,
  });

  @override
  List<Object?> get props => [message, code, originalError, stackTrace];

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// Network-related exceptions
class NetworkException extends AppException {
  final String? endpoint;
  final int? statusCode;

  const NetworkException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.endpoint,
    this.statusCode,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, endpoint, statusCode];
}

/// Connection-specific network exception
class ConnectionException extends NetworkException {
  const ConnectionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    String? endpoint,
    int? statusCode,
  }) : super(
          message: message,
          code: code ?? 'CONNECTION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
          endpoint: endpoint,
          statusCode: statusCode,
        );
}

/// Timeout-specific network exception
class TimeoutException extends NetworkException {
  final Duration? duration;

  const TimeoutException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    String? endpoint,
    this.duration,
  }) : super(
          message: message,
          code: code ?? 'TIMEOUT_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
          endpoint: endpoint,
        );

  @override
  List<Object?> get props => [...super.props, duration];
}

/// Validation exceptions
class ValidationException extends AppException {
  final String? field;
  final Map<String, String>? fieldErrors;

  const ValidationException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.field,
    this.fieldErrors,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, field, fieldErrors];
}

/// Authentication exceptions
class AuthException extends AppException {
  final bool isTokenExpired;
  final bool isUnauthorized;

  const AuthException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.isTokenExpired = false,
    this.isUnauthorized = false,
  }) : super(
          message: message,
          code: code ?? 'AUTH_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, isTokenExpired, isUnauthorized];
}

/// Permission exceptions
class PermissionException extends AppException {
  final String? permission;
  final bool isPermanentlyDenied;

  const PermissionException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.permission,
    this.isPermanentlyDenied = false,
  }) : super(
          message: message,
          code: code ?? 'PERMISSION_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, permission, isPermanentlyDenied];
}

/// Storage exceptions
class StorageException extends AppException {
  final String? key;
  final bool isNotFound;

  const StorageException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.key,
    this.isNotFound = false,
  }) : super(
          message: message,
          code: code ?? 'STORAGE_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, key, isNotFound];
}

/// SIP-specific exceptions
class SipException extends AppException {
  final int? statusCode;
  final String? reason;

  const SipException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.statusCode,
    this.reason,
  }) : super(
          message: message,
          code: code ?? 'SIP_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, statusCode, reason];
}

/// Telephony-specific exceptions
class TelephonyException extends AppException {
  final String? phoneNumber;
  final String? operation;

  const TelephonyException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.phoneNumber,
    this.operation,
  }) : super(
          message: message,
          code: code ?? 'TELEPHONY_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, phoneNumber, operation];
}

/// Gateway-specific exceptions
class GatewayException extends AppException {
  final String? operation;
  final bool isRecoverable;

  const GatewayException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.operation,
    this.isRecoverable = true,
  }) : super(
          message: message,
          code: code ?? 'GATEWAY_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, operation, isRecoverable];
}

/// Configuration exceptions
class ConfigNotFoundException extends AppException {
  final String? configKey;

  const ConfigNotFoundException({
    String? message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.configKey,
  }) : super(
          message: message ?? 'Configuration not found',
          code: code ?? 'CONFIG_NOT_FOUND',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, configKey];
}

/// Invalid configuration exception
class InvalidConfigException extends AppException {
  final String? configKey;
  final String? expectedType;

  const InvalidConfigException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.configKey,
    this.expectedType,
  }) : super(
          message: message,
          code: code ?? 'INVALID_CONFIG',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, configKey, expectedType];
}

/// Service unavailable exception
class ServiceUnavailableException extends AppException {
  final String? serviceName;

  const ServiceUnavailableException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.serviceName,
  }) : super(
          message: message,
          code: code ?? 'SERVICE_UNAVAILABLE',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, serviceName];
}

/// Cache exception
class CacheException extends AppException {
  final String? key;
  final bool isExpired;

  const CacheException({
    required String message,
    String? code,
    dynamic originalError,
    StackTrace? stackTrace,
    this.key,
    this.isExpired = false,
  }) : super(
          message: message,
          code: code ?? 'CACHE_ERROR',
          originalError: originalError,
          stackTrace: stackTrace,
        );

  @override
  List<Object?> get props => [...super.props, key, isExpired];
}
