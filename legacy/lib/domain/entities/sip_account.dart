/// SIP Account entity
/// Immutable domain model representing a SIP account

import 'package:equatable/equatable.dart';

/// SIP registration state
enum SipRegistrationState {
  /// Not registered
  unregistered,

  /// Registration in progress
  registering,

  /// Successfully registered
  registered,

  /// Registration failed
  registrationFailed,

  /// Re-registering
  reregistering,
}

/// SIP transport protocol
enum SipTransport {
  /// UDP transport
  udp,

  /// TCP transport
  tcp,

  /// TLS transport
  tls,
}

/// SIP Account entity
///
/// Represents a SIP account with all configuration needed for registration
/// and call operations. This is an immutable domain model.
class SipAccount extends Equatable {
  /// Unique account identifier
  final String id;

  /// SIP username for authentication
  final String username;

  /// SIP password for authentication
  final String password;

  /// SIP domain/server address
  final String domain;

  /// SIP server port (default: 5060)
  final int port;

  /// Transport protocol (default: UDP)
  final SipTransport transport;

  /// Registration timeout in seconds (default: 3600)
  final int registrationTimeout;

  /// Enable keep-alive (default: true)
  final bool enableKeepAlive;

  /// Keep-alive interval in seconds (default: 30)
  final int keepAliveInterval;

  /// Contact URI params for push notifications
  final String? contactUriParams;

  /// Current registration state
  final SipRegistrationState registrationState;

  /// Registration status message
  final String? registrationStatus;

  /// Display name for caller ID
  final String? displayName;

  /// Proxy server (optional)
  final String? proxy;

  /// Registration headers
  final Map<String, String>? registrationHeaders;

  /// Whether this is the default account
  final bool isDefault;

  /// Whether the account is active
  final bool isActive;

  const SipAccount({
    required this.id,
    required this.username,
    required this.password,
    required this.domain,
    this.port = 5060,
    this.transport = SipTransport.udp,
    this.registrationTimeout = 3600,
    this.enableKeepAlive = true,
    this.keepAliveInterval = 30,
    this.contactUriParams,
    this.registrationState = SipRegistrationState.unregistered,
    this.registrationStatus,
    this.displayName,
    this.proxy,
    this.registrationHeaders,
    this.isDefault = false,
    this.isActive = true,
  });

  /// Create a copy with updated fields
  SipAccount copyWith({
    String? id,
    String? username,
    String? password,
    String? domain,
    int? port,
    SipTransport? transport,
    int? registrationTimeout,
    bool? enableKeepAlive,
    int? keepAliveInterval,
    String? contactUriParams,
    SipRegistrationState? registrationState,
    String? registrationStatus,
    String? displayName,
    String? proxy,
    Map<String, String>? registrationHeaders,
    bool? isDefault,
    bool? isActive,
  }) {
    return SipAccount(
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

  /// Check if account is registered
  bool get isRegistered => registrationState == SipRegistrationState.registered;

  /// Check if account is registering
  bool get isRegistering =>
      registrationState == SipRegistrationState.registering ||
      registrationState == SipRegistrationState.reregistering;

  /// Check if account registration failed
  bool get registrationFailed =>
      registrationState == SipRegistrationState.registrationFailed;

  /// Get SIP URI for this account
  String get sipUri {
    final userPart = displayName != null && displayName!.isNotEmpty
        ? '"$displayName" <$username>'
        : username;
    return '$userPart@$domain';
  }

  /// Get full SIP URI with port
  String get fullSipUri {
    final uri = sipUri;
    return port != 5060 ? '$uri:$port' : uri;
  }

  /// Validate account configuration
  List<String> get validationErrors {
    final errors = <String>[];

    if (username.isEmpty) {
      errors.add('SIP username is required');
    }

    if (password.isEmpty) {
      errors.add('SIP password is required');
    }

    if (domain.isEmpty) {
      errors.add('SIP domain/server is required');
    }

    if (port <= 0 || port > 65535) {
      errors.add('SIP port must be between 1 and 65535');
    }

    if (registrationTimeout <= 0) {
      errors.add('Registration timeout must be greater than 0');
    }

    if (enableKeepAlive && keepAliveInterval <= 0) {
      errors.add('Keep-alive interval must be greater than 0');
    }

    return errors;
  }

  /// Check if account configuration is valid
  bool get isValid => validationErrors.isEmpty;

  /// Create default account
  factory SipAccount.defaultAccount() {
    return const SipAccount(
      id: 'default',
      username: '',
      password: '',
      domain: '',
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
    return 'SipAccount(id: $id, username: $username, domain: $domain, '
        'port: $port, transport: $transport, '
        'registrationState: $registrationState, isActive: $isActive)';
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'password': password,
      'domain': domain,
      'port': port,
      'transport': transport.name.toUpperCase(),
      'registrationTimeout': registrationTimeout,
      'enableKeepAlive': enableKeepAlive,
      'keepAliveInterval': keepAliveInterval,
      'displayName': displayName,
      'isDefault': isDefault,
      'isActive': isActive,
    };
  }

  /// Create from JSON
  factory SipAccount.fromJson(Map<String, dynamic> json) {
    return SipAccount(
      id: json['id'] ?? '',
      username: json['username'] ?? '',
      password: json['password'] ?? '',
      domain: json['domain'] ?? '',
      port: json['port'] ?? 5060,
      transport: SipTransport.values.firstWhere(
        (e) => e.name.toUpperCase() == (json['transport'] ?? 'UDP'),
        orElse: () => SipTransport.udp,
      ),
      registrationTimeout: json['registrationTimeout'] ?? 3600,
      enableKeepAlive: json['enableKeepAlive'] ?? true,
      keepAliveInterval: json['keepAliveInterval'] ?? 30,
      displayName: json['displayName'],
      isDefault: json['isDefault'] ?? false,
      isActive: json['isActive'] ?? true,
    );
  }
}
