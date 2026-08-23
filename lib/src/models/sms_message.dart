// flutter_smsussd package removed - SMS handled via native Android telephony

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

  /// Convert SMS type from string
  static SmsType fromString(String typeStr) {
    switch (typeStr.toLowerCase()) {
      case 'inbox':
        return SmsType.inbox;
      case 'sent':
        return SmsType.sent;
      case 'draft':
        return SmsType.draft;
      case 'outbox':
        return SmsType.outbox;
      case 'failed':
        return SmsType.failed;
      case 'queued':
        return SmsType.queued;
      default:
        return SmsType.inbox;
    }
  }

  /// Get status from SMS type
  static SmsStatus getStatusFromType(SmsType type) {
    switch (type) {
      case SmsType.inbox:
        return SmsStatus.delivered;
      case SmsType.sent:
        return SmsStatus.sent;
      case SmsType.draft:
      case SmsType.outbox:
      case SmsType.queued:
        return SmsStatus.pending;
      case SmsType.failed:
        return SmsStatus.failed;
    }
  }
} 