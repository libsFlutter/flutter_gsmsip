/// SIP Account model for serialization
/// Data layer model for SIP account

import 'package:equatable/equatable.dart';
import '../../domain/entities/sip_account.dart';

/// SIP Account model
class SipAccountModel extends Equatable {
  final String id;
  final String username;
  final String password;
  final String domain;
  final int port;
  final String transport;
  final int registrationTimeout;
  final bool enableKeepAlive;
  final int keepAliveInterval;
  final String? contactUriParams;
  final String registrationState;
  final String? registrationStatus;
  final String? displayName;
  final String? proxy;
  final Map<String, String>? registrationHeaders;
  final bool isDefault;
  final bool isActive;

  const SipAccountModel({
    required this.id,
    required this.username,
    required this.password,
    required this.domain,
    this.port = 5060,
    this.transport = 'UDP',
    this.registrationTimeout = 3600,
    this.enableKeepAlive = true,
    this.keepAliveInterval = 30,
    this.contactUriParams,
    this.registrationState = 'unregistered',
    this.registrationStatus,
    this.displayName,
    this.proxy,
    this.registrationHeaders,
    this.isDefault = false,
    this.isActive = true,
  });

  /// Create from JSON
  factory SipAccountModel.fromJson(Map<String, dynamic> json) {
    return SipAccountModel(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      domain: json['domain'] ?? '',
      port: json['port'] ?? 5060,
      transport: json['transport'] ?? 'UDP',
      registrationTimeout: json['registrationTimeout'] ?? 3600,
      enableKeepAlive: json['enableKeepAlive'] ?? true,
      keepAliveInterval: json['keepAliveInterval'] ?? 30,
      contactUriParams: json['contactUriParams'],
      registrationState: json['registrationState'] ?? 'unregistered',
      registrationStatus: json['registrationStatus'],
      displayName: json['displayName'],
      proxy: json['proxy'],
      registrationHeaders: json['registrationHeaders'] != null
          ? Map<String, String>.from(json['registrationHeaders'])
          : null,
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'domain': domain,
      'port': port,
      'transport': transport,
      'registrationTimeout': registrationTimeout,
      'enableKeepAlive': enableKeepAlive,
      'keepAliveInterval': keepAliveInterval,
      'contactUriParams': contactUriParams,
      'registrationState': registrationState,
      'registrationStatus': registrationStatus,
      'displayName': displayName,
      'proxy': proxy,
      'registrationHeaders': registrationHeaders,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  /// Create from entity
  factory SipAccountModel.fromEntity(SipAccount entity) {
    return SipAccountModel(
      id: entity.id,
      username: entity.username,
      password: entity.password,
      domain: entity.domain,
      port: entity.port,
      transport: entity.transport.name.toUpperCase(),
      registrationTimeout: entity.registrationTimeout,
      enableKeepAlive: entity.enableKeepAlive,
      keepAliveInterval: entity.keepAliveInterval,
      contactUriParams: entity.contactUriParams,
      registrationState: entity.registrationState.name,
      registrationStatus: entity.registrationStatus,
      displayName: entity.displayName,
      proxy: entity.proxy,
      registrationHeaders: entity.registrationHeaders,
      isDefault: entity.isDefault,
      isActive: entity.isActive,
    );
  }

  /// Convert to entity
  SipAccount toEntity() {
    return SipAccount(
      id: id,
      username: username,
      password: password,
      domain: domain,
      port: port,
      transport: SipTransport.values.firstWhere(
        (e) => e.name.toUpperCase() == transport.toUpperCase(),
        orElse: () => SipTransport.udp,
      ),
      registrationTimeout: registrationTimeout,
      enableKeepAlive: enableKeepAlive,
      keepAliveInterval: keepAliveInterval,
      contactUriParams: contactUriParams,
      registrationState: SipRegistrationState.values.firstWhere(
        (e) => e.name == registrationState,
        orElse: () => SipRegistrationState.unregistered,
      ),
      registrationStatus: registrationStatus,
      displayName: displayName,
      proxy: proxy,
      registrationHeaders: registrationHeaders,
      isDefault: isDefault,
      isActive: isActive,
    );
  }

  @override
  List<Object?> get props => [
        id,
        username,
        password,
        domain,
        port,
        transport,
        registrationTimeout,
        enableKeepAlive,
        keepAliveInterval,
        contactUriParams,
        registrationState,
        registrationStatus,
        displayName,
        proxy,
        registrationHeaders,
        isDefault,
        isActive,
      ];

  @override
  String toString() {
    return 'SipAccountModel(id: $id, username: $username, domain: $domain, '
        'transport: $transport, registrationState: $registrationState)';
  }

  /// Create a copy with updated fields
  SipAccountModel copyWith({
    String? id,
    String? username,
    String? password,
    String? domain,
    int? port,
    String? transport,
    int? registrationTimeout,
    bool? enableKeepAlive,
    int? keepAliveInterval,
    String? contactUriParams,
    String? registrationState,
    String? registrationStatus,
    String? displayName,
    String? proxy,
    Map<String, String>? registrationHeaders,
    bool? isDefault,
    bool? isActive,
  }) {
    return SipAccountModel(
      id: id ?? this.id,
      username: username ?? this.username,
      password: password ?? this.password,
      domain: domain ?? this.domain,
      port: port ?? this.port,
      transport: transport ?? this.transport,
      registrationTimeout: registrationTimeout ?? this.registrationTimeout,
      enableKeepAlive: enableKeepAlive ?? this.enableKeepAlive,
      keepAliveInterval: keepAliveInterval ?? this.keepAliveInterval,
      contactUriParams: contactUriParams ?? this.contactUriParams,
      registrationState: registrationState ?? this.registrationState,
      registrationStatus: registrationStatus ?? this.registrationStatus,
      displayName: displayName ?? this.displayName,
      proxy: proxy ?? this.proxy,
      registrationHeaders: registrationHeaders ?? this.registrationHeaders,
      isDefault: isDefault ?? this.isDefault,
      isActive: isActive ?? this.isActive,
    );
  }
}
