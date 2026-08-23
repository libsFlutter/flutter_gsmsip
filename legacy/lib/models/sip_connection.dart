class SipConnection {
  final String status; // connected/disconnected/connecting
  final String server;
  final int port;
  final String transport; // UDP/TCP/TLS
  final DateTime lastRegistration;
  final DateTime registrationExpiry;
  final double jitter;
  final double latency;
  final double bandwidthIn;
  final double bandwidthOut;
  final double packetLoss;
  final double mos;
  final List<String> supportedCodecs;
  final List<String> activeCodecs;
  final String username;
  final bool isRegistered;

  SipConnection({
    required this.status,
    required this.server,
    required this.port,
    required this.transport,
    required this.lastRegistration,
    required this.registrationExpiry,
    required this.jitter,
    required this.latency,
    required this.bandwidthIn,
    required this.bandwidthOut,
    required this.packetLoss,
    required this.mos,
    required this.supportedCodecs,
    required this.activeCodecs,
    required this.username,
    required this.isRegistered,
  });

  factory SipConnection.fromJson(Map<String, dynamic> json) {
    return SipConnection(
      status: json['status'] ?? 'disconnected',
      server: json['server'] ?? '',
      port: json['port'] ?? 5060,
      transport: json['transport'] ?? 'UDP',
      lastRegistration: DateTime.parse(json['lastRegistration'] ?? DateTime.now().toIso8601String()),
      registrationExpiry: DateTime.parse(json['registrationExpiry'] ?? DateTime.now().toIso8601String()),
      jitter: (json['jitter'] ?? 0.0).toDouble(),
      latency: (json['latency'] ?? 0.0).toDouble(),
      bandwidthIn: (json['bandwidthIn'] ?? 0.0).toDouble(),
      bandwidthOut: (json['bandwidthOut'] ?? 0.0).toDouble(),
      packetLoss: (json['packetLoss'] ?? 0.0).toDouble(),
      mos: (json['mos'] ?? 0.0).toDouble(),
      supportedCodecs: List<String>.from(json['supportedCodecs'] ?? []),
      activeCodecs: List<String>.from(json['activeCodecs'] ?? []),
      username: json['username'] ?? '',
      isRegistered: json['isRegistered'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'server': server,
      'port': port,
      'transport': transport,
      'lastRegistration': lastRegistration.toIso8601String(),
      'registrationExpiry': registrationExpiry.toIso8601String(),
      'jitter': jitter,
      'latency': latency,
      'bandwidthIn': bandwidthIn,
      'bandwidthOut': bandwidthOut,
      'packetLoss': packetLoss,
      'mos': mos,
      'supportedCodecs': supportedCodecs,
      'activeCodecs': activeCodecs,
      'username': username,
      'isRegistered': isRegistered,
    };
  }

  SipConnection copyWith({
    String? status,
    String? server,
    int? port,
    String? transport,
    DateTime? lastRegistration,
    DateTime? registrationExpiry,
    double? jitter,
    double? latency,
    double? bandwidthIn,
    double? bandwidthOut,
    double? packetLoss,
    double? mos,
    List<String>? supportedCodecs,
    List<String>? activeCodecs,
    String? username,
    bool? isRegistered,
  }) {
    return SipConnection(
      status: status ?? this.status,
      server: server ?? this.server,
      port: port ?? this.port,
      transport: transport ?? this.transport,
      lastRegistration: lastRegistration ?? this.lastRegistration,
      registrationExpiry: registrationExpiry ?? this.registrationExpiry,
      jitter: jitter ?? this.jitter,
      latency: latency ?? this.latency,
      bandwidthIn: bandwidthIn ?? this.bandwidthIn,
      bandwidthOut: bandwidthOut ?? this.bandwidthOut,
      packetLoss: packetLoss ?? this.packetLoss,
      mos: mos ?? this.mos,
      supportedCodecs: supportedCodecs ?? this.supportedCodecs,
      activeCodecs: activeCodecs ?? this.activeCodecs,
      username: username ?? this.username,
      isRegistered: isRegistered ?? this.isRegistered,
    );
  }
} 