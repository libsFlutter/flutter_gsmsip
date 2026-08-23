/// Gateway Configuration entity
/// Immutable domain model for gateway service configuration

import 'package:equatable/equatable.dart';
import 'sip_account.dart';
import '../../../services/sms_service.dart';

/// Gateway Configuration entity
///
/// Contains all configuration options for the Gateway Service.
/// This is an immutable domain model.
class GatewayConfig extends Equatable {
  /// SIP account (required)
  final SipAccount sipAccount;

  /// SMPP configuration (optional)
  final SmppConfig? smppConfig;

  /// Auto-answer incoming GSM calls
  final bool autoAnswer;

  /// Enable log streaming
  final bool enableLogging;

  /// Enable SIP→GSM routing
  final bool routeSipToGsm;

  /// Enable GSM→SIP routing
  final bool routeGsmToSip;

  /// Enable SMS→SMPP routing
  final bool routeSmsToSmpp;

  /// Enable SMPP→SMS routing
  final bool routeSmppToSms;

  /// Maximum concurrent calls
  final int maxConcurrentCalls;

  const GatewayConfig({
    required this.sipAccount,
    this.smppConfig,
    this.autoAnswer = false,
    this.enableLogging = true,
    this.routeSipToGsm = true,
    this.routeGsmToSip = true,
    this.routeSmsToSmpp = false,
    this.routeSmppToSms = false,
    this.maxConcurrentCalls = 5,
  });

  /// Create a copy with updated fields
  GatewayConfig copyWith({
    SipAccount? sipAccount,
    SmppConfig? smppConfig,
    bool? autoAnswer,
    bool? enableLogging,
    bool? routeSipToGsm,
    bool? routeGsmToSip,
    bool? routeSmsToSmpp,
    bool? routeSmppToSms,
    int? maxConcurrentCalls,
  }) {
    return GatewayConfig(
      sipAccount: sipAccount ?? this.sipAccount,
      smppConfig: smppConfig ?? this.smppConfig,
      autoAnswer: autoAnswer ?? this.autoAnswer,
      enableLogging: enableLogging ?? this.enableLogging,
      routeSipToGsm: routeSipToGsm ?? this.routeSipToGsm,
      routeGsmToSip: routeGsmToSip ?? this.routeGsmToSip,
      routeSmsToSmpp: routeSmsToSmpp ?? this.routeSmsToSmpp,
      routeSmppToSms: routeSmppToSms ?? this.routeSmppToSms,
      maxConcurrentCalls: maxConcurrentCalls ?? this.maxConcurrentCalls,
    );
  }

  /// Validate configuration
  List<String> get validationErrors {
    final errors = <String>[];

    // SIP account is required
    final sipErrors = sipAccount.validationErrors;
    if (sipErrors.isNotEmpty) {
      errors.addAll(sipErrors.map((e) => 'SIP: $e'));
    }

    // SMPP validation (if configured)
    if (smppConfig != null && !smppConfig!.isValid) {
      errors.add('SMPP: Invalid SMPP configuration');
    }

    // Max concurrent calls validation
    if (maxConcurrentCalls <= 0) {
      errors.add('Max concurrent calls must be greater than 0');
    }

    if (maxConcurrentCalls > 20) {
      errors.add('Max concurrent calls should not exceed 20');
    }

    return errors;
  }

  /// Check if configuration is valid
  bool get isValid => validationErrors.isEmpty;

  /// Check if SMPP is configured
  bool get isSmppConfigured => smppConfig != null && smppConfig!.isValid;

  /// Check if SMS routing is enabled
  bool get isSmsRoutingEnabled => routeSmsToSmpp || routeSmppToSms;

  /// Create default configuration
  factory GatewayConfig.defaultConfig() {
    return GatewayConfig(
      sipAccount: SipAccount.defaultAccount(),
    );
  }

  /// Create from JSON
  factory GatewayConfig.fromJson(Map<String, dynamic> json) {
    return GatewayConfig(
      sipAccount: SipAccount.fromJson(json['sipAccount'] ?? {}),
      smppConfig: json['smppConfig'] != null
          ? SmppConfig.fromJson(json['smppConfig'])
          : null,
      autoAnswer: json['autoAnswer'] ?? false,
      enableLogging: json['enableLogging'] ?? true,
      routeSipToGsm: json['routeSipToGsm'] ?? true,
      routeGsmToSip: json['routeGsmToSip'] ?? true,
      routeSmsToSmpp: json['routeSmsToSmpp'] ?? false,
      routeSmppToSms: json['routeSmppToSms'] ?? false,
      maxConcurrentCalls: json['maxConcurrentCalls'] ?? 5,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'sipAccount': sipAccount.toJson(),
      'smppConfig': smppConfig?.toJson(),
      'autoAnswer': autoAnswer,
      'enableLogging': enableLogging,
      'routeSipToGsm': routeSipToGsm,
      'routeGsmToSip': routeGsmToSip,
      'routeSmsToSmpp': routeSmsToSmpp,
      'routeSmppToSms': routeSmppToSms,
      'maxConcurrentCalls': maxConcurrentCalls,
    };
  }

  @override
  List<Object?> get props => [
        sipAccount,
        smppConfig,
        autoAnswer,
        enableLogging,
        routeSipToGsm,
        routeGsmToSip,
        routeSmsToSmpp,
        routeSmppToSms,
        maxConcurrentCalls,
      ];

  @override
  String toString() {
    return 'GatewayConfig(sipAccount: ${sipAccount.username}, '
        'smppConfigured: ${isSmppConfigured}, '
        'routeSipToGsm: $routeSipToGsm, routeGsmToSip: $routeGsmToSip, '
        'maxConcurrentCalls: $maxConcurrentCalls)';
  }
}
