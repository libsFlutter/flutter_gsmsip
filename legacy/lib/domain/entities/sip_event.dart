/// SIP Event entity
/// Immutable domain model representing a SIP event from the native layer

import 'package:equatable/equatable.dart';

/// SIP event type
enum SipEventType {
  /// Account registration state changed
  registrationChanged,

  /// Account changed (updated)
  accountChanged,

  /// Incoming call received
  callReceived,

  /// Call state changed
  callChanged,

  /// Call terminated
  callTerminated,

  /// Connectivity changed
  connectivityChanged,

  /// Screen locked state changed
  callScreenLocked,

  /// App state changed
  appStateChanged,

  /// Settings changed
  settingsChanged,

  /// Unknown event type
  unknown,
}

/// SIP Event entity
///
/// Represents an event emitted by the SIP service.
/// This is an immutable domain model.
class SipEvent extends Equatable {
  /// Event type
  final SipEventType type;

  /// Event data (type-specific)
  final Map<String, dynamic> data;

  /// Event timestamp
  final DateTime timestamp;

  /// Event ID for tracking
  final String? eventId;

  const SipEvent({
    required this.type,
    required this.data,
    DateTime? timestamp,
    this.eventId,
  })  : timestamp = timestamp ?? DateTime.now();

  /// Get account ID from event data (if applicable)
  String? get accountId => data['accountId'] as String?;

  /// Get call ID from event data (if applicable)
  String? get callId => data['callId'] as String?;

  /// Get account data from event (if applicable)
  Map<String, dynamic>? get accountData =>
      data['account'] as Map<String, dynamic>?;

  /// Get call data from event (if applicable)
  Map<String, dynamic>? get callData =>
      data['call'] as Map<String, dynamic>?;

  /// Get connectivity status from event (if applicable)
  bool? get isConnected => data['connected'] as bool?;

  /// Get screen locked status from event (if applicable)
  bool? get isScreenLocked => data['locked'] as bool?;

  /// Get app state from event (if applicable)
  String? get appState => data['appState'] as String?;

  /// Create copy with updated data
  SipEvent copyWith({
    SipEventType? type,
    Map<String, dynamic>? data,
    DateTime? timestamp,
    String? eventId,
  }) {
    return SipEvent(
      type: type ?? this.type,
      data: data ?? this.data,
      timestamp: timestamp ?? this.timestamp,
      eventId: eventId ?? this.eventId,
    );
  }

  /// Parse event type from string
  static SipEventType parseType(String typeString) {
    switch (typeString.toLowerCase()) {
      case 'registration_changed':
      case 'registrationchanged':
        return SipEventType.registrationChanged;
      case 'account_changed':
      case 'accountchanged':
        return SipEventType.accountChanged;
      case 'call_received':
      case 'callreceived':
        return SipEventType.callReceived;
      case 'call_changed':
      case 'callchanged':
        return SipEventType.callChanged;
      case 'call_terminated':
      case 'callterminated':
        return SipEventType.callTerminated;
      case 'connectivity_changed':
      case 'connectivitychanged':
        return SipEventType.connectivityChanged;
      case 'call_screen_locked':
      case 'callscreenlocked':
        return SipEventType.callScreenLocked;
      case 'app_state_changed':
      case 'appstatechanged':
        return SipEventType.appStateChanged;
      case 'settings_changed':
      case 'settingschanged':
        return SipEventType.settingsChanged;
      default:
        return SipEventType.unknown;
    }
  }

  @override
  List<Object?> get props => [type, data, timestamp, eventId];

  @override
  String toString() {
    return 'SipEvent(type: $type, timestamp: $timestamp, data: $data)';
  }
}

/// Registration event data
class RegistrationEventData extends Equatable {
  final String accountId;
  final String registrationState;
  final String? status;
  final String? server;

  const RegistrationEventData({
    required this.accountId,
    required this.registrationState,
    this.status,
    this.server,
  });

  factory RegistrationEventData.fromMap(Map<String, dynamic> map) {
    return RegistrationEventData(
      accountId: map['accountId'] ?? '',
      registrationState: map['state'] ?? map['registrationState'] ?? '',
      status: map['status'],
      server: map['server'],
    );
  }

  @override
  List<Object?> get props => [accountId, registrationState, status, server];
}

/// Call event data
class CallEventData extends Equatable {
  final String callId;
  final String accountId;
  final String number;
  final String state;
  final String? direction;
  final String? callerName;

  const CallEventData({
    required this.callId,
    required this.accountId,
    required this.number,
    required this.state,
    this.direction,
    this.callerName,
  });

  factory CallEventData.fromMap(Map<String, dynamic> map) {
    return CallEventData(
      callId: map['callId'] ?? map['id'] ?? '',
      accountId: map['accountId'] ?? '',
      number: map['number'] ?? '',
      state: map['state'] ?? '',
      direction: map['direction'],
      callerName: map['callerName'],
    );
  }

  @override
  List<Object?> get props => [callId, accountId, number, state, direction, callerName];
}
