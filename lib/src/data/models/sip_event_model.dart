/// SIP Event model for serialization
/// Data layer model for SIP events from native layer

import 'package:equatable/equatable.dart';
import '../../domain/entities/sip_event.dart';

/// SIP Event model
class SipEventModel extends Equatable {
  final String type;
  final Map<String, dynamic> data;
  final String timestamp;
  final String? eventId;

  const SipEventModel({
    required this.type,
    required this.data,
    required this.timestamp,
    this.eventId,
  });

  /// Create from JSON
  factory SipEventModel.fromJson(Map<String, dynamic> json) {
    return SipEventModel(
      type: json['type'] ?? '',
      data: json['data'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
      eventId: json['eventId'],
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp,
      'eventId': eventId,
    };
  }

  /// Create from entity
  factory SipEventModel.fromEntity(SipEvent entity) {
    return SipEventModel(
      type: entity.type.name,
      data: entity.data,
      timestamp: entity.timestamp.toIso8601String(),
      eventId: entity.eventId,
    );
  }

  /// Convert to entity
  SipEvent toEntity() {
    return SipEvent(
      type: SipEvent.parseType(type),
      data: data,
      timestamp: DateTime.parse(timestamp),
      eventId: eventId,
    );
  }

  @override
  List<Object?> get props => [type, data, timestamp, eventId];

  @override
  String toString() {
    return 'SipEventModel(type: $type, timestamp: $timestamp)';
  }
}

/// Account event model
class AccountEventModel extends Equatable {
  final String type;
  final Map<String, dynamic> account;
  final String timestamp;

  const AccountEventModel({
    required this.type,
    required this.account,
    required this.timestamp,
  });

  factory AccountEventModel.fromJson(Map<String, dynamic> json) {
    return AccountEventModel(
      type: json['type'] ?? '',
      account: json['account'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'account': account,
      'timestamp': timestamp,
    };
  }

  SipEvent toEntity() {
    return SipEvent(
      type: SipEvent.parseType(type),
      data: {'account': account},
      timestamp: DateTime.parse(timestamp),
    );
  }

  @override
  List<Object?> get props => [type, account, timestamp];
}

/// Call event model
class CallEventModel extends Equatable {
  final String type;
  final Map<String, dynamic> call;
  final String timestamp;

  const CallEventModel({
    required this.type,
    required this.call,
    required this.timestamp,
  });

  factory CallEventModel.fromJson(Map<String, dynamic> json) {
    return CallEventModel(
      type: json['type'] ?? '',
      call: json['call'] as Map<String, dynamic>? ?? {},
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'call': call,
      'timestamp': timestamp,
    };
  }

  SipEvent toEntity() {
    return SipEvent(
      type: SipEvent.parseType(type),
      data: {'call': call},
      timestamp: DateTime.parse(timestamp),
    );
  }

  @override
  List<Object?> get props => [type, call, timestamp];
}

/// Connectivity event model
class ConnectivityEventModel extends Equatable {
  final bool connected;
  final String timestamp;

  const ConnectivityEventModel({
    required this.connected,
    required this.timestamp,
  });

  factory ConnectivityEventModel.fromJson(Map<String, dynamic> json) {
    return ConnectivityEventModel(
      connected: json['connected'] ?? false,
      timestamp: json['timestamp'] ?? DateTime.now().toIso8601String(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'connected': connected,
      'timestamp': timestamp,
    };
  }

  SipEvent toEntity() {
    return SipEvent(
      type: SipEventType.connectivityChanged,
      data: {'connected': connected},
      timestamp: DateTime.parse(timestamp),
    );
  }

  @override
  List<Object?> get props => [connected, timestamp];
}
