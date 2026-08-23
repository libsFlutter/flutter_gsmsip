/// SIP Call entity
/// Immutable domain model representing a SIP call

import 'package:equatable/equatable.dart';

/// Call direction
enum CallDirection {
  /// Outgoing call
  outgoing,

  /// Incoming call
  incoming,
}

/// Call state
enum CallState {
  /// Call initiated (outgoing)
  initiated,

  /// Incoming call (ringing)
  incoming,

  /// Call active (connected)
  active,

  /// Call on hold
  held,

  /// Call terminated (ended normally)
  terminated,

  /// Call failed
  failed,
}

/// SIP Call entity
///
/// Represents an active or historical SIP call with all state information.
/// This is an immutable domain model.
class SipCall extends Equatable {
  /// Unique call identifier
  final String id;

  /// Account ID this call belongs to
  final String accountId;

  /// Phone number or SIP URI
  final String number;

  /// Call direction
  final CallDirection direction;

  /// Current call state
  final CallState state;

  /// Call start time (when initiated/received)
  final DateTime? startTime;

  /// Call connect time (when answered)
  final DateTime? connectTime;

  /// Call end time (when terminated)
  final DateTime? endTime;

  /// Whether microphone is muted
  final bool isMuted;

  /// Whether call is on hold
  final bool isOnHold;

  /// Whether speaker is enabled
  final bool isSpeaker;

  /// Transfer target number (if transferring)
  final String? transferTarget;

  /// Redirect target number (if redirected)
  final String? redirectTarget;

  /// Caller display name (for incoming calls)
  final String? callerName;

  /// Call duration in seconds (calculated)
  int get durationSeconds {
    if (startTime == null) return 0;

    final end = endTime ?? DateTime.now();
    final start = connectTime ?? startTime!;
    return end.difference(start).inSeconds;
  }

  /// Whether call is active (not terminated or failed)
  bool get isActive =>
      state == CallState.active ||
      state == CallState.held ||
      state == CallState.initiated ||
      state == CallState.incoming;

  /// Whether call is connected
  bool get isConnected => state == CallState.active || state == CallState.held;

  const SipCall({
    required this.id,
    required this.accountId,
    required this.number,
    required this.direction,
    this.state = CallState.initiated,
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

  /// Create a copy with updated fields
  SipCall copyWith({
    String? id,
    String? accountId,
    String? number,
    CallDirection? direction,
    CallState? state,
    DateTime? startTime,
    DateTime? connectTime,
    DateTime? endTime,
    bool? isMuted,
    bool? isOnHold,
    bool? isSpeaker,
    String? transferTarget,
    String? redirectTarget,
    String? callerName,
  }) {
    return SipCall(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      number: number ?? this.number,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      connectTime: connectTime ?? this.connectTime,
      endTime: endTime ?? this.endTime,
      isMuted: isMuted ?? this.isMuted,
      isOnHold: isOnHold ?? this.isOnHold,
      isSpeaker: isSpeaker ?? this.isSpeaker,
      transferTarget: transferTarget ?? this.transferTarget,
      redirectTarget: redirectTarget ?? this.redirectTarget,
      callerName: callerName ?? this.callerName,
    );
  }

  /// Format duration as MM:SS
  String get formattedDuration {
    final seconds = durationSeconds;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  /// Get state display name
  String get stateDisplayName {
    switch (state) {
      case CallState.initiated:
        return 'Calling...';
      case CallState.incoming:
        return 'Incoming...';
      case CallState.active:
        return 'Connected';
      case CallState.held:
        return 'On Hold';
      case CallState.terminated:
        return 'Ended';
      case CallState.failed:
        return 'Failed';
    }
  }

  /// Validate call state transition
  bool canTransitionTo(CallState newState) {
    switch (state) {
      case CallState.initiated:
        return newState == CallState.active ||
            newState == CallState.failed ||
            newState == CallState.terminated;
      case CallState.incoming:
        return newState == CallState.active ||
            newState == CallState.terminated ||
            newState == CallState.failed;
      case CallState.active:
        return newState == CallState.held ||
            newState == CallState.terminated ||
            newState == CallState.failed;
      case CallState.held:
        return newState == CallState.active ||
            newState == CallState.terminated ||
            newState == CallState.failed;
      case CallState.terminated:
      case CallState.failed:
        return false; // Terminal states
    }
  }

  /// Create outgoing call
  factory SipCall.outgoing({
    required String id,
    required String accountId,
    required String number,
  }) {
    return SipCall(
      id: id,
      accountId: accountId,
      number: number,
      direction: CallDirection.outgoing,
      state: CallState.initiated,
      startTime: DateTime.now(),
    );
  }

  /// Create incoming call
  factory SipCall.incoming({
    required String id,
    required String accountId,
    required String number,
    String? callerName,
  }) {
    return SipCall(
      id: id,
      accountId: accountId,
      number: number,
      direction: CallDirection.incoming,
      state: CallState.incoming,
      startTime: DateTime.now(),
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
    return 'SipCall(id: $id, number: $number, direction: $direction, '
        'state: $state, duration: $formattedDuration)';
  }
}
