class GatewayConfig {
  final String sipUsername;
  final String sipPassword;
  final String sipServer;
  final int sipPort;
  final String transport;
  final int registrationTimeout;
  final bool autoStart;
  final bool replaceDialer;
  final bool enablePermissions;
  
  // New fields for enhanced functionality
  final bool autoAnswer;
  final int callTimeout;
  final bool enableSms;
  final bool enableCallLog;
  final String defaultCountryCode;
  final bool enableCallForwarding;
  final String callForwardingNumber;
  final bool enableCallRecording;
  final String recordingPath;
  final bool enableCallStatistics;
  final int maxCallDuration;
  final bool enableEmergencyCalls;
  final List<String> emergencyNumbers;
  final bool enableBlacklist;
  final List<String> blacklistedNumbers;
  final bool enableWhitelist;
  final List<String> whitelistedNumbers;

  GatewayConfig({
    required this.sipUsername,
    required this.sipPassword,
    required this.sipServer,
    this.sipPort = 5060,
    this.transport = 'UDP',
    this.registrationTimeout = 3600,
    this.autoStart = false,
    this.replaceDialer = false,
    this.enablePermissions = false,
    this.autoAnswer = false,
    this.callTimeout = 300,
    this.enableSms = true,
    this.enableCallLog = true,
    this.defaultCountryCode = '+7',
    this.enableCallForwarding = false,
    this.callForwardingNumber = '',
    this.enableCallRecording = false,
    this.recordingPath = '/storage/emulated/0/GSMGateway/recordings',
    this.enableCallStatistics = true,
    this.maxCallDuration = 3600,
    this.enableEmergencyCalls = true,
    this.emergencyNumbers = const ['112', '911', '102', '103', '104'],
    this.enableBlacklist = false,
    this.blacklistedNumbers = const [],
    this.enableWhitelist = false,
    this.whitelistedNumbers = const [],
  });

  GatewayConfig copyWith({
    String? sipUsername,
    String? sipPassword,
    String? sipServer,
    int? sipPort,
    String? transport,
    int? registrationTimeout,
    bool? autoStart,
    bool? replaceDialer,
    bool? enablePermissions,
    bool? autoAnswer,
    int? callTimeout,
    bool? enableSms,
    bool? enableCallLog,
    String? defaultCountryCode,
    bool? enableCallForwarding,
    String? callForwardingNumber,
    bool? enableCallRecording,
    String? recordingPath,
    bool? enableCallStatistics,
    int? maxCallDuration,
    bool? enableEmergencyCalls,
    List<String>? emergencyNumbers,
    bool? enableBlacklist,
    List<String>? blacklistedNumbers,
    bool? enableWhitelist,
    List<String>? whitelistedNumbers,
  }) {
    return GatewayConfig(
      sipUsername: sipUsername ?? this.sipUsername,
      sipPassword: sipPassword ?? this.sipPassword,
      sipServer: sipServer ?? this.sipServer,
      sipPort: sipPort ?? this.sipPort,
      transport: transport ?? this.transport,
      registrationTimeout: registrationTimeout ?? this.registrationTimeout,
      autoStart: autoStart ?? this.autoStart,
      replaceDialer: replaceDialer ?? this.replaceDialer,
      enablePermissions: enablePermissions ?? this.enablePermissions,
      autoAnswer: autoAnswer ?? this.autoAnswer,
      callTimeout: callTimeout ?? this.callTimeout,
      enableSms: enableSms ?? this.enableSms,
      enableCallLog: enableCallLog ?? this.enableCallLog,
      defaultCountryCode: defaultCountryCode ?? this.defaultCountryCode,
      enableCallForwarding: enableCallForwarding ?? this.enableCallForwarding,
      callForwardingNumber: callForwardingNumber ?? this.callForwardingNumber,
      enableCallRecording: enableCallRecording ?? this.enableCallRecording,
      recordingPath: recordingPath ?? this.recordingPath,
      enableCallStatistics: enableCallStatistics ?? this.enableCallStatistics,
      maxCallDuration: maxCallDuration ?? this.maxCallDuration,
      enableEmergencyCalls: enableEmergencyCalls ?? this.enableEmergencyCalls,
      emergencyNumbers: emergencyNumbers ?? this.emergencyNumbers,
      enableBlacklist: enableBlacklist ?? this.enableBlacklist,
      blacklistedNumbers: blacklistedNumbers ?? this.blacklistedNumbers,
      enableWhitelist: enableWhitelist ?? this.enableWhitelist,
      whitelistedNumbers: whitelistedNumbers ?? this.whitelistedNumbers,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sipUsername': sipUsername,
      'sipPassword': sipPassword,
      'sipServer': sipServer,
      'sipPort': sipPort,
      'transport': transport,
      'registrationTimeout': registrationTimeout,
      'autoStart': autoStart,
      'replaceDialer': replaceDialer,
      'enablePermissions': enablePermissions,
      'autoAnswer': autoAnswer,
      'callTimeout': callTimeout,
      'enableSms': enableSms,
      'enableCallLog': enableCallLog,
      'defaultCountryCode': defaultCountryCode,
      'enableCallForwarding': enableCallForwarding,
      'callForwardingNumber': callForwardingNumber,
      'enableCallRecording': enableCallRecording,
      'recordingPath': recordingPath,
      'enableCallStatistics': enableCallStatistics,
      'maxCallDuration': maxCallDuration,
      'enableEmergencyCalls': enableEmergencyCalls,
      'emergencyNumbers': emergencyNumbers,
      'enableBlacklist': enableBlacklist,
      'blacklistedNumbers': blacklistedNumbers,
      'enableWhitelist': enableWhitelist,
      'whitelistedNumbers': whitelistedNumbers,
    };
  }

  factory GatewayConfig.fromJson(Map<String, dynamic> json) {
    return GatewayConfig(
      sipUsername: json['sipUsername'] ?? '',
      sipPassword: json['sipPassword'] ?? '',
      sipServer: json['sipServer'] ?? '',
      sipPort: json['sipPort'] ?? 5060,
      transport: json['transport'] ?? 'UDP',
      registrationTimeout: json['registrationTimeout'] ?? 3600,
      autoStart: json['autoStart'] ?? false,
      replaceDialer: json['replaceDialer'] ?? false,
      enablePermissions: json['enablePermissions'] ?? false,
      autoAnswer: json['autoAnswer'] ?? false,
      callTimeout: json['callTimeout'] ?? 300,
      enableSms: json['enableSms'] ?? true,
      enableCallLog: json['enableCallLog'] ?? true,
      defaultCountryCode: json['defaultCountryCode'] ?? '+7',
      enableCallForwarding: json['enableCallForwarding'] ?? false,
      callForwardingNumber: json['callForwardingNumber'] ?? '',
      enableCallRecording: json['enableCallRecording'] ?? false,
      recordingPath: json['recordingPath'] ?? '/storage/emulated/0/GSMGateway/recordings',
      enableCallStatistics: json['enableCallStatistics'] ?? true,
      maxCallDuration: json['maxCallDuration'] ?? 3600,
      enableEmergencyCalls: json['enableEmergencyCalls'] ?? true,
      emergencyNumbers: List<String>.from(json['emergencyNumbers'] ?? ['112', '911', '102', '103', '104']),
      enableBlacklist: json['enableBlacklist'] ?? false,
      blacklistedNumbers: List<String>.from(json['blacklistedNumbers'] ?? []),
      enableWhitelist: json['enableWhitelist'] ?? false,
      whitelistedNumbers: List<String>.from(json['whitelistedNumbers'] ?? []),
    );
  }

  factory GatewayConfig.defaultConfig() {
    return GatewayConfig(
      sipUsername: '',
      sipPassword: '',
      sipServer: '192.168.88.254',
      sipPort: 5060,
      transport: 'UDP',
      registrationTimeout: 3600,
      autoStart: false,
      replaceDialer: false,
      enablePermissions: false,
      autoAnswer: false,
      callTimeout: 300,
      enableSms: true,
      enableCallLog: true,
      defaultCountryCode: '+7',
      enableCallForwarding: false,
      callForwardingNumber: '',
      enableCallRecording: false,
      recordingPath: '/storage/emulated/0/GSMGateway/recordings',
      enableCallStatistics: true,
      maxCallDuration: 3600,
      enableEmergencyCalls: true,
      emergencyNumbers: ['112', '911', '102', '103', '104'],
      enableBlacklist: false,
      blacklistedNumbers: [],
      enableWhitelist: false,
      whitelistedNumbers: [],
    );
  }
} 