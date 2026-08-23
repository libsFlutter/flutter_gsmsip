class SmppConfig {
  final String host;
  final int port;
  final String systemId;
  final String password;
  final String systemType;
  final int interfaceVersion;
  final int ton;
  final int npi;
  final String addressRange;
  final bool enableDeliveryReceipts;
  final int requestTimeout;
  final int reconnectInterval;
  final int maxRetries;
  final bool enableLogging;

  SmppConfig({
    required this.host,
    required this.port,
    required this.systemId,
    required this.password,
    this.systemType = '',
    this.interfaceVersion = 0x34, // SMPP 3.4
    this.ton = 0, // Unknown
    this.npi = 0, // Unknown
    this.addressRange = '',
    this.enableDeliveryReceipts = true,
    this.requestTimeout = 30000, // 30 seconds
    this.reconnectInterval = 5000, // 5 seconds
    this.maxRetries = 3,
    this.enableLogging = true,
  });

  SmppConfig copyWith({
    String? host,
    int? port,
    String? systemId,
    String? password,
    String? systemType,
    int? interfaceVersion,
    int? ton,
    int? npi,
    String? addressRange,
    bool? enableDeliveryReceipts,
    int? requestTimeout,
    int? reconnectInterval,
    int? maxRetries,
    bool? enableLogging,
  }) {
    return SmppConfig(
      host: host ?? this.host,
      port: port ?? this.port,
      systemId: systemId ?? this.systemId,
      password: password ?? this.password,
      systemType: systemType ?? this.systemType,
      interfaceVersion: interfaceVersion ?? this.interfaceVersion,
      ton: ton ?? this.ton,
      npi: npi ?? this.npi,
      addressRange: addressRange ?? this.addressRange,
      enableDeliveryReceipts: enableDeliveryReceipts ?? this.enableDeliveryReceipts,
      requestTimeout: requestTimeout ?? this.requestTimeout,
      reconnectInterval: reconnectInterval ?? this.reconnectInterval,
      maxRetries: maxRetries ?? this.maxRetries,
      enableLogging: enableLogging ?? this.enableLogging,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'host': host,
      'port': port,
      'systemId': systemId,
      'password': password,
      'systemType': systemType,
      'interfaceVersion': interfaceVersion,
      'ton': ton,
      'npi': npi,
      'addressRange': addressRange,
      'enableDeliveryReceipts': enableDeliveryReceipts,
      'requestTimeout': requestTimeout,
      'reconnectInterval': reconnectInterval,
      'maxRetries': maxRetries,
      'enableLogging': enableLogging,
    };
  }

  factory SmppConfig.fromJson(Map<String, dynamic> json) {
    return SmppConfig(
      host: json['host'] ?? '',
      port: json['port'] ?? 2775,
      systemId: json['systemId'] ?? '',
      password: json['password'] ?? '',
      systemType: json['systemType'] ?? '',
      interfaceVersion: json['interfaceVersion'] ?? 0x34,
      ton: json['ton'] ?? 0,
      npi: json['npi'] ?? 0,
      addressRange: json['addressRange'] ?? '',
      enableDeliveryReceipts: json['enableDeliveryReceipts'] ?? true,
      requestTimeout: json['requestTimeout'] ?? 30000,
      reconnectInterval: json['reconnectInterval'] ?? 5000,
      maxRetries: json['maxRetries'] ?? 3,
      enableLogging: json['enableLogging'] ?? true,
    );
  }

  @override
  String toString() {
    return 'SmppConfig(host: $host, port: $port, systemId: $systemId, systemType: $systemType)';
  }

  /// Check if the configuration is valid
  bool get isValid => host.isNotEmpty && systemId.isNotEmpty && port > 0;
}

// SmppConnectionState moved to domain/entities/gateway_status.dart to avoid duplication

enum SmppBindType {
  transmitter,
  receiver,
  transceiver,
}

class SmppMessage {
  final String id;
  final String sourceAddress;
  final String destinationAddress;
  final String message;
  final DateTime timestamp;
  final SmppMessageStatus status;
  final int? sequenceNumber;
  final Map<String, dynamic>? parameters;

  SmppMessage({
    required this.id,
    required this.sourceAddress,
    required this.destinationAddress,
    required this.message,
    required this.timestamp,
    this.status = SmppMessageStatus.pending,
    this.sequenceNumber,
    this.parameters,
  });

  SmppMessage copyWith({
    String? id,
    String? sourceAddress,
    String? destinationAddress,
    String? message,
    DateTime? timestamp,
    SmppMessageStatus? status,
    int? sequenceNumber,
    Map<String, dynamic>? parameters,
  }) {
    return SmppMessage(
      id: id ?? this.id,
      sourceAddress: sourceAddress ?? this.sourceAddress,
      destinationAddress: destinationAddress ?? this.destinationAddress,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      status: status ?? this.status,
      sequenceNumber: sequenceNumber ?? this.sequenceNumber,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'sequenceNumber': sequenceNumber,
      'parameters': parameters,
    };
  }

  factory SmppMessage.fromJson(Map<String, dynamic> json) {
    return SmppMessage(
      id: json['id'] ?? '',
      sourceAddress: json['sourceAddress'] ?? '',
      destinationAddress: json['destinationAddress'] ?? '',
      message: json['message'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      status: SmppMessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SmppMessageStatus.pending,
      ),
      sequenceNumber: json['sequenceNumber'],
      parameters: json['parameters'] != null 
          ? Map<String, dynamic>.from(json['parameters'])
          : null,
    );
  }
}

enum SmppMessageStatus {
  pending,
  sent,
  delivered,
  failed,
  expired,
  rejected,
  unknown,
}

class SmppDeliveryReceipt {
  final String messageId;
  final String sourceAddress;
  final String destinationAddress;
  final DateTime submitDate;
  final DateTime doneDate;
  final SmppMessageStatus status;
  final String? errorCode;
  final String? text;

  SmppDeliveryReceipt({
    required this.messageId,
    required this.sourceAddress,
    required this.destinationAddress,
    required this.submitDate,
    required this.doneDate,
    required this.status,
    this.errorCode,
    this.text,
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'sourceAddress': sourceAddress,
      'destinationAddress': destinationAddress,
      'submitDate': submitDate.toIso8601String(),
      'doneDate': doneDate.toIso8601String(),
      'status': status.name,
      'errorCode': errorCode,
      'text': text,
    };
  }

  factory SmppDeliveryReceipt.fromJson(Map<String, dynamic> json) {
    return SmppDeliveryReceipt(
      messageId: json['messageId'] ?? '',
      sourceAddress: json['sourceAddress'] ?? '',
      destinationAddress: json['destinationAddress'] ?? '',
      submitDate: DateTime.parse(json['submitDate'] ?? DateTime.now().toIso8601String()),
      doneDate: DateTime.parse(json['doneDate'] ?? DateTime.now().toIso8601String()),
      status: SmppMessageStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SmppMessageStatus.unknown,
      ),
      errorCode: json['errorCode'],
      text: json['text'],
    );
  }
}
