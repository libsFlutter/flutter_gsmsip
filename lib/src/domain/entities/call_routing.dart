/// Call Routing entity
/// Immutable domain model representing a bidirectional call routing

import 'package:equatable/equatable.dart';

/// Call routing direction
enum CallRoutingDirection {
  /// SIP incoming, GSM outgoing
  sipToGsm,

  /// GSM incoming, SIP outgoing
  gsmToSip,
}

/// Call routing state
enum CallRoutingState {
  /// Setting up both legs
  connecting,

  /// Both legs established
  active,

  /// Normal termination
  ended,

  /// Setup or runtime failure
  failed,
}

/// Call Routing entity
///
/// Represents an active or historical bidirectional call routing
/// between SIP and GSM protocols.
class CallRouting extends Equatable {
  /// Unique routing identifier
  final String id;

  /// SIP call ID
  final String sipCallId;

  /// Telephony/GSM call ID (null if not yet established)
  final String? telephonyCallId;

  /// Phone number being routed
  final String number;

  /// Routing direction
  final CallRoutingDirection direction;

  /// Current routing state
  final CallRoutingState state;

  /// Routing start time
  late final DateTime startTime;

  /// Routing end time (null if active)
  final DateTime? endTime;

  /// Error message (if failed)
  final String? errorMessage;

  CallRouting({
    required this.id,
    required this.sipCallId,
    this.telephonyCallId,
    required this.number,
    required this.direction,
    this.state = CallRoutingState.connecting,
    DateTime? startTime,
    this.endTime,
    this.errorMessage,
  }) : startTime = startTime ?? DateTime.now();

  /// Create a copy with updated fields
  CallRouting copyWith({
    String? id,
    String? sipCallId,
    String? telephonyCallId,
    String? number,
    CallRoutingDirection? direction,
    CallRoutingState? state,
    DateTime? startTime,
    DateTime? endTime,
    String? errorMessage,
  }) {
    return CallRouting(
      id: id ?? this.id,
      sipCallId: sipCallId ?? this.sipCallId,
      telephonyCallId: telephonyCallId ?? this.telephonyCallId,
      number: number ?? this.number,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get total duration in seconds
  int get durationSeconds {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime).inSeconds;
  }

  /// Get formatted duration (MM:SS)
  String get formattedDuration {
    final seconds = durationSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Check if routing is active
  bool get isActive => state == CallRoutingState.active || state == CallRoutingState.connecting;

  /// Check if routing is completed (ended or failed)
  bool get isCompleted => state == CallRoutingState.ended || state == CallRoutingState.failed;

  /// Check if routing has both legs established
  bool get isFullyEstablished =>
      state == CallRoutingState.active && telephonyCallId != null;

  /// Validate state transition
  bool canTransitionTo(CallRoutingState newState) {
    switch (state) {
      case CallRoutingState.connecting:
        return newState == CallRoutingState.active ||
            newState == CallRoutingState.failed;
      case CallRoutingState.active:
        return newState == CallRoutingState.ended ||
            newState == CallRoutingState.failed;
      case CallRoutingState.ended:
      case CallRoutingState.failed:
        return false; // Terminal states
    }
  }

  /// Create SIP→GSM routing
  factory CallRouting.sipToGsm({
    required String id,
    required String sipCallId,
    required String number,
  }) {
    return CallRouting(
      id: id,
      sipCallId: sipCallId,
      number: number,
      direction: CallRoutingDirection.sipToGsm,
      state: CallRoutingState.connecting,
    );
  }

  /// Create GSM→SIP routing
  factory CallRouting.gsmToSip({
    required String id,
    required String telephonyCallId,
    required String number,
  }) {
    return CallRouting(
      id: id,
      sipCallId: '', // Will be set when SIP call is created
      telephonyCallId: telephonyCallId,
      number: number,
      direction: CallRoutingDirection.gsmToSip,
      state: CallRoutingState.connecting,
    );
  }

  @override
  List<Object?> get props => [
        id,
        sipCallId,
        telephonyCallId,
        number,
        direction,
        state,
        startTime,
        endTime,
        errorMessage,
      ];

  @override
  String toString() {
    return 'CallRouting(id: $id, number: $number, direction: $direction, '
        'state: $state, duration: $formattedDuration)';
  }
}
