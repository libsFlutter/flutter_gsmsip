/// SIP Call model for serialization
/// Data layer model for SIP call

import 'package:equatable/equatable.dart';
import '../../domain/entities/sip_call.dart';

/// SIP Call model
class SipCallModel extends Equatable {
  final String id;
  final String accountId;
  final String number;
  final String direction;
  final String state;
  final String? startTime;
  final String? connectTime;
  final String? endTime;
  final bool isMuted;
  final bool isOnHold;
  final bool isSpeaker;
  final String? transferTarget;
  final String? redirectTarget;
  final String? callerName;

  const SipCallModel({
    required this.id,
    required this.accountId,
    required this.number,
    this.direction = 'outgoing',
    this.state = 'initiated',
    this.startTime,
    this.connectTime,
    this.endTime,
    this.isMuted = false,
    this.isOnHold = false,
    this.isSpeaker = false,
    this.transferTarget,
    this.redirectTarget,
    this.callerName,
  });

  /// Create from JSON
  factory SipCallModel.fromJson(Map<String, dynamic> json) {
    return SipCallModel(
      id: json['id'] ?? '',
      accountId: json['accountId'] ?? '',
      number: json['number'] ?? '',
      direction: json['direction'] ?? 'outgoing',
      state: json['state'] ?? 'initiated',
      startTime: json['startTime'],
      connectTime: json['connectTime'],
      endTime: json['endTime'],
      isMuted: json['isMuted'] ?? false,
      isOnHold: json['isOnHold'] ?? false,
      isSpeaker: json['isSpeaker'] ?? false,
      transferTarget: json['transferTarget'],
      redirectTarget: json['redirectTarget'],
      callerName: json['callerName'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'number': number,
      'direction': direction,
      'state': state,
      'startTime': startTime,
      'connectTime': connectTime,
      'endTime': endTime,
      'isMuted': isMuted,
      'isOnHold': isOnHold,
      'isSpeaker': isSpeaker,
      'transferTarget': transferTarget,
      'redirectTarget': redirectTarget,
      'callerName': callerName,
    };
  }

  /// Create from entity
  factory SipCallModel.fromEntity(SipCall entity) {
    return SipCallModel(
      id: entity.id,
      accountId: entity.accountId,
      number: entity.number,
      direction: entity.direction.name,
      state: entity.state.name,
      startTime: entity.startTime?.toIso8601String(),
      connectTime: entity.connectTime?.toIso8601String(),
      endTime: entity.endTime?.toIso8601String(),
      isMuted: entity.isMuted,
      isOnHold: entity.isOnHold,
      isSpeaker: entity.isSpeaker,
      transferTarget: entity.transferTarget,
      redirectTarget: entity.redirectTarget,
      callerName: entity.callerName,
    );
  }

  /// Convert to entity
  SipCall toEntity() {
    return SipCall(
      id: id,
      accountId: accountId,
      number: number,
      direction: CallDirection.values.firstWhere(
        (e) => e.name == direction,
        orElse: () => CallDirection.outgoing,
      ),
      state: CallState.values.firstWhere(
        (e) => e.name == state,
        orElse: () => CallState.initiated,
      ),
      startTime: startTime != null ? DateTime.parse(startTime!) : null,
      connectTime: connectTime != null ? DateTime.parse(connectTime!) : null,
      endTime: endTime != null ? DateTime.parse(endTime!) : null,
      isMuted: isMuted,
      isOnHold: isOnHold,
      isSpeaker: isSpeaker,
      transferTarget: transferTarget,
      redirectTarget: redirectTarget,
      callerName: callerName,
    );
  }

  @override
  List<Object?> get props => [
        id,
        accountId,
        number,
        direction,
        state,
        startTime,
        connectTime,
        endTime,
        isMuted,
        isOnHold,
        isSpeaker,
        transferTarget,
        redirectTarget,
        callerName,
      ];

  @override
  String toString() {
    return 'SipCallModel(id: $id, number: $number, direction: $direction, state: $state)';
  }
}
