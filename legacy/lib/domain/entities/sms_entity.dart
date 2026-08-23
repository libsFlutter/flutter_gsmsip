/// Доменная сущность SMS
/// Представляет SMS сообщения в бизнес-логике
import 'package:equatable/equatable.dart';

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

/// SMS сообщение
class SmsMessage extends Equatable {
  final String id;
  final String address;
  final String body;
  final DateTime timestamp;
  final SmsType type;
  final SmsStatus status;
  final bool isRead;
  final String? threadId;
  final String? simSlot;

  const SmsMessage({
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

  @override
  List<Object?> get props => [
        id,
        address,
        body,
        timestamp,
        type,
        status,
        isRead,
        threadId,
        simSlot,
      ];
}
