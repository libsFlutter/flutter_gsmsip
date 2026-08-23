/// SIP Account Entity
///
/// Represents a SIP account configuration with registration tracking.
///
/// Source: sdd-account specification
/// Tasks: account-001, account-003, account-005

import 'account_registration.dart';

class Account {
  /// Unique account identifier
  final int id;
  
  /// SIP URI (e.g., sip:username@domain)
  final String uri;
  
  /// Display name for the account
  final String name;
  
  /// SIP username for authentication
  final String username;
  
  /// SIP domain/server
  final String domain;
  
  /// SIP password for authentication
  final String password;
  
  /// Proxy server (optional)
  final String? proxy;
  
  /// Transport protocol (TCP, UDP, TLS)
  final String? transport;
  
  /// Contact parameters for registration
  final String? contactParams;
  
  /// Contact URI parameters
  final String? contactUriParams;
  
  /// Registration server (if different from domain)
  final String? regServer;
  
  /// Registration timeout in seconds (default: 3600)
  final int? regTimeout;
  
  /// Registration contact parameters
  final String? regContactParams;
  
  /// Custom headers for registration
  final Map<String, dynamic>? regHeaders;
  
  /// Current registration status
  final AccountRegistration registration;

  const Account({
    required this.id,
    required this.uri,
    required this.name,
    required this.username,
    required this.domain,
    required this.password,
    this.proxy,
    this.transport,
    this.contactParams,
    this.contactUriParams,
    this.regServer,
    this.regTimeout,
    this.regContactParams,
    this.regHeaders,
    this.registration = const AccountRegistration(status: false),
  });

  /// Create from JSON map
  factory Account.fromMap(Map<String, dynamic> map) {
    return Account(
      id: map['id'] as int,
      uri: map['uri'] as String? ?? '',
      name: map['name'] as String? ?? '',
      username: map['username'] as String? ?? '',
      domain: map['domain'] as String? ?? '',
      password: map['password'] as String? ?? '',
      proxy: map['proxy'] as String?,
      transport: map['transport'] as String?,
      contactParams: map['contactParams'] as String?,
      contactUriParams: map['contactUriParams'] as String?,
      regServer: map['regServer'] as String?,
      regTimeout: map['regTimeout'] as int?,
      regContactParams: map['regContactParams'] as String?,
      regHeaders: map['regHeaders'] as Map<String, dynamic>?,
      registration: map['registration'] != null
          ? AccountRegistration.fromMap(map['registration'] as Map<String, dynamic>)
          : const AccountRegistration(status: false),
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'uri': uri,
      'name': name,
      'username': username,
      'domain': domain,
      'password': password,
      'proxy': proxy,
      'transport': transport,
      'contactParams': contactParams,
      'contactUriParams': contactUriParams,
      'regServer': regServer,
      'regTimeout': regTimeout,
      'regContactParams': regContactParams,
      'regHeaders': regHeaders,
      'registration': registration.toMap(),
    };
  }

  /// Create a copy with updated registration status
  Account withRegistration(AccountRegistration newRegistration) {
    return Account(
      id: id,
      uri: uri,
      name: name,
      username: username,
      domain: domain,
      password: password,
      proxy: proxy,
      transport: transport,
      contactParams: contactParams,
      contactUriParams: contactUriParams,
      regServer: regServer,
      regTimeout: regTimeout,
      regContactParams: regContactParams,
      regHeaders: regHeaders,
      registration: newRegistration,
    );
  }

  /// Check if account is currently registered
  bool get isRegistered => registration.isActive;

  /// Get the full SIP URI with username and domain
  String get fullUri => 'sip:$username@$domain';

  /// Get the registration server (falls back to domain)
  String get effectiveRegServer => regServer ?? domain;

  /// Get transport protocol (defaults to TCP)
  String get effectiveTransport => transport ?? 'TCP';

  @override
  String toString() => 'Account(id: $id, name: $name, username: $username@$domain)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Account && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
