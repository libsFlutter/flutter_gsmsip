/// Failure classes for functional error handling with dartz
/// Used with Either<Failure, Success> pattern

import 'package:equatable/equatable.dart';

/// Base failure class for all application failures
abstract class Failure extends Equatable {
  final String message;
  final String? code;
  final dynamic originalError;

  const Failure({
    required this.message,
    this.code,
    this.originalError,
  });

  @override
  List<Object?> get props => [message, code, originalError];

  @override
  String toString() {
    if (code != null) {
      return '$runtimeType [$code]: $message';
    }
    return '$runtimeType: $message';
  }
}

/// Network-related failures
class NetworkFailure extends Failure {
  final String? endpoint;
  final int? statusCode;

  const NetworkFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.endpoint,
    this.statusCode,
  }) : super(
          message: message,
          code: code ?? 'NETWORK_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, endpoint, statusCode];
}

/// Connection failure
class ConnectionFailure extends NetworkFailure {
  const ConnectionFailure({
    required String message,
    String? code,
    dynamic originalError,
    String? endpoint,
    int? statusCode,
  }) : super(
          message: message,
          code: code ?? 'CONNECTION_FAILURE',
          originalError: originalError,
          endpoint: endpoint,
          statusCode: statusCode,
        );
}

/// Timeout failure
class TimeoutFailure extends NetworkFailure {
  final Duration? duration;

  const TimeoutFailure({
    required String message,
    String? code,
    dynamic originalError,
    String? endpoint,
    this.duration,
  }) : super(
          message: message,
          code: code ?? 'TIMEOUT_FAILURE',
          originalError: originalError,
          endpoint: endpoint,
        );

  @override
  List<Object?> get props => [...super.props, duration];
}

/// Validation failure
class ValidationFailure extends Failure {
  final String? field;
  final Map<String, String>? fieldErrors;

  const ValidationFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.field,
    this.fieldErrors,
  }) : super(
          message: message,
          code: code ?? 'VALIDATION_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, field, fieldErrors];
}

/// Authentication failure
class AuthFailure extends Failure {
  final bool isTokenExpired;
  final bool isUnauthorized;

  const AuthFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.isTokenExpired = false,
    this.isUnauthorized = false,
  }) : super(
          message: message,
          code: code ?? 'AUTH_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, isTokenExpired, isUnauthorized];
}

/// Permission failure
class PermissionFailure extends Failure {
  final String? permission;
  final bool isPermanentlyDenied;

  const PermissionFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.permission,
    this.isPermanentlyDenied = false,
  }) : super(
          message: message,
          code: code ?? 'PERMISSION_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, permission, isPermanentlyDenied];
}

/// Storage failure
class StorageFailure extends Failure {
  final String? key;
  final bool isNotFound;

  const StorageFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.key,
    this.isNotFound = false,
  }) : super(
          message: message,
          code: code ?? 'STORAGE_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, key, isNotFound];
}

/// SIP failure
class SipFailure extends Failure {
  final int? statusCode;
  final String? reason;

  const SipFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.statusCode,
    this.reason,
  }) : super(
          message: message,
          code: code ?? 'SIP_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, statusCode, reason];
}

/// Telephony failure
class TelephonyFailure extends Failure {
  final String? phoneNumber;
  final String? operation;

  const TelephonyFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.phoneNumber,
    this.operation,
  }) : super(
          message: message,
          code: code ?? 'TELEPHONY_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, phoneNumber, operation];
}

/// Gateway failure
class GatewayFailure extends Failure {
  final String? operation;
  final bool isRecoverable;

  const GatewayFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.operation,
    this.isRecoverable = true,
  }) : super(
          message: message,
          code: code ?? 'GATEWAY_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, operation, isRecoverable];
}

/// Configuration not found failure
class ConfigNotFoundFailure extends Failure {
  final String? configKey;

  const ConfigNotFoundFailure({
    String? message,
    String? code,
    dynamic originalError,
    this.configKey,
  }) : super(
          message: message ?? 'Configuration not found',
          code: code ?? 'CONFIG_NOT_FOUND_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, configKey];
}

/// Invalid configuration failure
class InvalidConfigFailure extends Failure {
  final String? configKey;
  final String? expectedType;

  const InvalidConfigFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.configKey,
    this.expectedType,
  }) : super(
          message: message,
          code: code ?? 'INVALID_CONFIG_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, configKey, expectedType];
}

/// Service unavailable failure
class ServiceUnavailableFailure extends Failure {
  final String? serviceName;

  const ServiceUnavailableFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.serviceName,
  }) : super(
          message: message,
          code: code ?? 'SERVICE_UNAVAILABLE_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, serviceName];
}

/// Cache failure
class CacheFailure extends Failure {
  final String? key;
  final bool isExpired;

  const CacheFailure({
    required String message,
    String? code,
    dynamic originalError,
    this.key,
    this.isExpired = false,
  }) : super(
          message: message,
          code: code ?? 'CACHE_FAILURE',
          originalError: originalError,
        );

  @override
  List<Object?> get props => [...super.props, key, isExpired];
}

/// Unknown/unexpected failure
class UnknownFailure extends Failure {
  const UnknownFailure({
    String? message,
    dynamic originalError,
  }) : super(
          message: message ?? 'An unexpected error occurred',
          code: 'UNKNOWN_FAILURE',
          originalError: originalError,
        );
}
