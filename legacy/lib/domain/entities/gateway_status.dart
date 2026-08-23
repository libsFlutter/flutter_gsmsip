/// Gateway Status entity
/// Immutable domain model for gateway service status snapshot

import 'package:equatable/equatable.dart';
import 'call_routing.dart';

/// SIP connection state
enum SipConnectionState {
  /// Not connected
  disconnected,

  /// Connecting
  connecting,

  /// Connected and registered
  connected,

  /// Error state
  error,
}

/// SMPP connection state
enum SmppConnectionState {
  /// Not connected
  disconnected,

  /// Connecting
  connecting,

  /// Connected and bound
  connected,

  /// Error state
  error,
}

/// Telephony permission status
enum TelephonyPermissionStatus {
  /// Permissions not requested
  notRequested,

  /// Permissions granted
  granted,

  /// Permissions denied
  denied,

  /// Permissions denied permanently
  deniedPermanently,
}

/// Gateway Status entity
///
/// Represents a snapshot of the Gateway Service status.
/// This is an immutable domain model.
class GatewayStatus extends Equatable {
  /// Whether gateway is running
  final bool isRunning;

  /// SIP connection state
  final SipConnectionState sipState;

  /// SMPP connection state (null if not configured)
  final SmppConnectionState? smppState;

  /// Telephony permission status
  final TelephonyPermissionStatus telephonyPermissions;

  /// Number of active calls
  final int activeCalls;

  /// Total calls handled (lifetime)
  final int totalCallsHandled;

  /// Total messages handled (lifetime)
  final int totalMessagesHandled;

  /// Gateway start time
  final DateTime? startTime;

  /// Current uptime
  final Duration? uptime;

  /// Last error message
  final String? errorMessage;

  /// Number of active routings
  final int activeRoutings;

  const GatewayStatus({
    this.isRunning = false,
    this.sipState = SipConnectionState.disconnected,
    this.smppState,
    this.telephonyPermissions = TelephonyPermissionStatus.notRequested,
    this.activeCalls = 0,
    this.totalCallsHandled = 0,
    this.totalMessagesHandled = 0,
    this.startTime,
    this.uptime,
    this.errorMessage,
    this.activeRoutings = 0,
  });

  /// Create a copy with updated fields
  GatewayStatus copyWith({
    bool? isRunning,
    SipConnectionState? sipState,
    SmppConnectionState? smppState,
    TelephonyPermissionStatus? telephonyPermissions,
    int? activeCalls,
    int? totalCallsHandled,
    int? totalMessagesHandled,
    DateTime? startTime,
    Duration? uptime,
    String? errorMessage,
    int? activeRoutings,
  }) {
    return GatewayStatus(
      isRunning: isRunning ?? this.isRunning,
      sipState: sipState ?? this.sipState,
      smppState: smppState ?? this.smppState,
      telephonyPermissions:
          telephonyPermissions ?? this.telephonyPermissions,
      activeCalls: activeCalls ?? this.activeCalls,
      totalCallsHandled: totalCallsHandled ?? this.totalCallsHandled,
      totalMessagesHandled: totalMessagesHandled ?? this.totalMessagesHandled,
      startTime: startTime ?? this.startTime,
      uptime: uptime ?? this.uptime,
      errorMessage: errorMessage ?? this.errorMessage,
      activeRoutings: activeRoutings ?? this.activeRoutings,
    );
  }

  /// Calculate uptime from start time
  Duration? calculateUptime() {
    if (startTime == null) return null;
    return DateTime.now().difference(startTime!);
  }

  /// Check if gateway is fully operational
  bool get isOperational =>
      isRunning &&
      sipState == SipConnectionState.connected &&
      telephonyPermissions == TelephonyPermissionStatus.granted;

  /// Check if gateway has any errors
  bool get hasError =>
      sipState == SipConnectionState.error ||
      smppState == SmppConnectionState.error ||
      errorMessage != null;

  /// Get status summary
  String get statusSummary {
    if (!isRunning) return 'Stopped';
    if (hasError) return 'Error';
    if (!isOperational) return 'Starting...';
    return 'Running';
  }

  /// Get status color (for UI)
  String get statusColor {
    if (!isRunning) return 'grey';
    if (hasError) return 'red';
    if (!isOperational) return 'orange';
    return 'green';
  }

  /// Create initial status
  factory GatewayStatus.initial() {
    return const GatewayStatus();
  }

  /// Create running status
  factory GatewayStatus.running({
    SipConnectionState sipState = SipConnectionState.connected,
    SmppConnectionState? smppState,
    int activeCalls = 0,
    int totalCallsHandled = 0,
    int totalMessagesHandled = 0,
    DateTime? startTime,
    int activeRoutings = 0,
  }) {
    return GatewayStatus(
      isRunning: true,
      sipState: sipState,
      smppState: smppState,
      telephonyPermissions: TelephonyPermissionStatus.granted,
      activeCalls: activeCalls,
      totalCallsHandled: totalCallsHandled,
      totalMessagesHandled: totalMessagesHandled,
      startTime: startTime ?? DateTime.now(),
      activeRoutings: activeRoutings,
    );
  }

  @override
  List<Object?> get props => [
        isRunning,
        sipState,
        smppState,
        telephonyPermissions,
        activeCalls,
        totalCallsHandled,
        totalMessagesHandled,
        startTime,
        uptime,
        errorMessage,
        activeRoutings,
      ];

  @override
  String toString() {
    return 'GatewayStatus(status: $statusSummary, '
        'sip: ${sipState.name}, '
        'activeCalls: $activeCalls, '
        'totalCalls: $totalCallsHandled, '
        'routings: $activeRoutings)';
  }
}
