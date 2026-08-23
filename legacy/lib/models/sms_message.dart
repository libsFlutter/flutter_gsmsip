import 'package:flutter_smsussd/flutter_smsussd.dart' as smsussd;

enum SmsType {
  inbox,
  sent,
  draft,
  outbox,
  failed,
  queued,
}

enum SmsStatus {
  pending,
  sent,
  delivered,
  failed,
}

class SmsMessage {
  final String id;
  final String address;
  final String body;
  final DateTime timestamp;
  final SmsType type;
  final SmsStatus status;
  final bool isRead;
  final String? threadId;
  final String? simSlot;

  SmsMessage({
    required this.id,
    required this.address,
    required this.body,
    required this.timestamp,
    required this.type,
    this.status = SmsStatus.pending,
    this.isRead = false,
    this.threadId,
    this.simSlot,
  });

  SmsMessage copyWith({
    String? id,
    String? address,
    String? body,
    DateTime? timestamp,
    SmsType? type,
    SmsStatus? status,
    bool? isRead,
    String? threadId,
    String? simSlot,
  }) {
    return SmsMessage(
      id: id ?? this.id,
      address: address ?? this.address,
      body: body ?? this.body,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      status: status ?? this.status,
      isRead: isRead ?? this.isRead,
      threadId: threadId ?? this.threadId,
      simSlot: simSlot ?? this.simSlot,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'address': address,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type.name,
      'status': status.name,
      'isRead': isRead,
      'threadId': threadId,
      'simSlot': simSlot,
    };
  }

  factory SmsMessage.fromJson(Map<String, dynamic> json) {
    return SmsMessage(
      id: json['id'] ?? '',
      address: json['address'] ?? '',
      body: json['body'] ?? '',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      type: SmsType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => SmsType.inbox,
      ),
      status: SmsStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => SmsStatus.pending,
      ),
      isRead: json['isRead'] ?? false,
      threadId: json['threadId'],
      simSlot: json['simSlot'],
    );
  }

  /// Convert from flutter_smsussd SmsMessage
  factory SmsMessage.fromSmsussd(smsussd.SmsMessage smsussdMessage) {
    return SmsMessage(
      id: smsussdMessage.id,
      address: smsussdMessage.address,
      body: smsussdMessage.body,
      timestamp: smsussdMessage.date,
      type: _convertSmsussdType(smsussdMessage.type),
      status: _getStatusFromType(smsussdMessage.type),
      isRead: true, // SMS from system are considered read
    );
  }

  /// Convert to flutter_smsussd SmsMessage
  smsussd.SmsMessage toSmsussd() {
    return smsussd.SmsMessage(
      id: id,
      address: address,
      body: body,
      date: timestamp,
      type: _convertToSmsussdType(type),
    );
  }

  /// Convert SMS type from flutter_smsussd to local enum
  static SmsType _convertSmsussdType(smsussd.SmsType smsussdType) {
    switch (smsussdType) {
      case smsussd.SmsType.inbox:
        return SmsType.inbox;
      case smsussd.SmsType.sent:
        return SmsType.sent;
      case smsussd.SmsType.draft:
        return SmsType.draft;
      case smsussd.SmsType.outbox:
        return SmsType.outbox;
      case smsussd.SmsType.failed:
        return SmsType.failed;
      case smsussd.SmsType.queued:
        return SmsType.queued;
    }
  }

  /// Convert local SMS type to flutter_smsussd enum
  static smsussd.SmsType _convertToSmsussdType(SmsType type) {
    switch (type) {
      case SmsType.inbox:
        return smsussd.SmsType.inbox;
      case SmsType.sent:
        return smsussd.SmsType.sent;
      case SmsType.draft:
        return smsussd.SmsType.draft;
      case SmsType.outbox:
        return smsussd.SmsType.outbox;
      case SmsType.failed:
        return smsussd.SmsType.failed;
      case SmsType.queued:
        return smsussd.SmsType.queued;
    }
  }

  /// Get status from SMS type
  static SmsStatus _getStatusFromType(smsussd.SmsType type) {
    switch (type) {
      case smsussd.SmsType.inbox:
        return SmsStatus.delivered;
      case smsussd.SmsType.sent:
        return SmsStatus.sent;
      case smsussd.SmsType.draft:
        return SmsStatus.pending;
      case smsussd.SmsType.outbox:
        return SmsStatus.pending;
      case smsussd.SmsType.failed:
        return SmsStatus.failed;
      case smsussd.SmsType.queued:
        return SmsStatus.pending;
    }
  }
} 