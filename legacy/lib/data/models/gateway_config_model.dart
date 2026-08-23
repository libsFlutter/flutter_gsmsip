/// Gateway Configuration Model
/// Used for JSON serialization/deserialization
import 'dart:convert';
import '../../domain/entities/gateway_config.dart';
import '../../domain/entities/sip_account.dart';
import '../../models/smpp_config.dart';

/// Gateway configuration model
class GatewayConfigModel {
  final String id;
  final String name;
  final String sipUsername;
  final String sipPassword;
  final String sipDomain;
  final int? sipPort;
  final String? smppSystemId;
  final String? smppPassword;
  final String? smppHost;
  final int? smppPort;
  final bool autoAnswer;
  final bool enableLogging;
  final bool routeSipToGsm;
  final bool routeGsmToSip;
  final bool routeSmsToSmpp;
  final bool routeSmppToSms;
  final int maxConcurrentCalls;

  GatewayConfigModel({
    required this.id,
    required this.name,
    required this.sipUsername,
    required this.sipPassword,
    required this.sipDomain,
    this.sipPort,
    this.smppSystemId,
    this.smppPassword,
    this.smppHost,
    this.smppPort,
    this.autoAnswer = false,
    this.enableLogging = true,
    this.routeSipToGsm = true,
    this.routeGsmToSip = true,
    this.routeSmsToSmpp = false,
    this.routeSmppToSms = false,
    this.maxConcurrentCalls = 5,
  });

  factory GatewayConfigModel.fromJson(Map<String, dynamic> json) {
    return GatewayConfigModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      sipUsername: json['sipUsername'] ?? '',
      sipPassword: json['sipPassword'] ?? '',
      sipDomain: json['sipDomain'] ?? '',
      sipPort: json['sipPort'],
      smppSystemId: json['smppSystemId'],
      smppPassword: json['smppPassword'],
      smppHost: json['smppHost'],
      smppPort: json['smppPort'],
      autoAnswer: json['autoAnswer'] ?? false,
      enableLogging: json['enableLogging'] ?? true,
      routeSipToGsm: json['routeSipToGsm'] ?? true,
      routeGsmToSip: json['routeGsmToSip'] ?? true,
      routeSmsToSmpp: json['routeSmsToSmpp'] ?? false,
      routeSmppToSms: json['routeSmppToSms'] ?? false,
      maxConcurrentCalls: json['maxConcurrentCalls'] ?? 5,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'sipUsername': sipUsername,
      'sipPassword': sipPassword,
      'sipDomain': sipDomain,
      if (sipPort != null) 'sipPort': sipPort,
      if (smppSystemId != null) 'smppSystemId': smppSystemId,
      if (smppPassword != null) 'smppPassword': smppPassword,
      if (smppHost != null) 'smppHost': smppHost,
      if (smppPort != null) 'smppPort': smppPort,
      'autoAnswer': autoAnswer,
      'enableLogging': enableLogging,
      'routeSipToGsm': routeSipToGsm,
      'routeGsmToSip': routeGsmToSip,
      'routeSmsToSmpp': routeSmsToSmpp,
      'routeSmppToSms': routeSmppToSms,
      'maxConcurrentCalls': maxConcurrentCalls,
    };
  }

  factory GatewayConfigModel.fromEntity(GatewayConfig entity) {
    return GatewayConfigModel(
      id: entity.sipAccount.id,
      name: entity.sipAccount.username,
      sipUsername: entity.sipAccount.username,
      sipPassword: entity.sipAccount.password,
      sipDomain: entity.sipAccount.domain,
      sipPort: entity.sipAccount.port,
      smppSystemId: entity.smppConfig?.systemId,
      smppPassword: entity.smppConfig?.password,
      smppHost: entity.smppConfig?.host,
      smppPort: entity.smppConfig?.port,
      autoAnswer: entity.autoAnswer,
      enableLogging: entity.enableLogging,
      routeSipToGsm: entity.routeSipToGsm,
      routeGsmToSip: entity.routeGsmToSip,
      routeSmsToSmpp: entity.routeSmsToSmpp,
      routeSmppToSms: entity.routeSmppToSms,
      maxConcurrentCalls: entity.maxConcurrentCalls,
    );
  }

  GatewayConfig toEntity() {
    return GatewayConfig(
      sipAccount: SipAccount(
        id: id,
        username: sipUsername,
        password: sipPassword,
        domain: sipDomain,
        port: sipPort ?? 5060,
      ),
      smppConfig: smppSystemId != null
          ? SmppConfig(
              systemId: smppSystemId!,
              password: smppPassword ?? '',
              host: smppHost ?? '',
              port: smppPort ?? 2775,
            )
          : null,
      autoAnswer: autoAnswer,
      enableLogging: enableLogging,
      routeSipToGsm: routeSipToGsm,
      routeGsmToSip: routeGsmToSip,
      routeSmsToSmpp: routeSmsToSmpp,
      routeSmppToSms: routeSmppToSms,
      maxConcurrentCalls: maxConcurrentCalls,
    );
  }

  String toJsonString() {
    return jsonEncode(toJson());
  }

  factory GatewayConfigModel.fromJsonString(String jsonString) {
    final json = jsonDecode(jsonString) as Map<String, dynamic>;
    return GatewayConfigModel.fromJson(json);
  }
}
