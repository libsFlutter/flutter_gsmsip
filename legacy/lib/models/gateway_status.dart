enum GatewayState {
  stopped,
  starting,
  running,
  error,
  connecting,
  registered,
  callInProgress,
}

enum CallDirection {
  incoming,
  outgoing,
}

enum CallState {
  idle,
  ringing,
  connecting,
  connected,
  disconnected,
  busy,
  error,
}

class CallInfo {
  final String id;
  final String number;
  final CallDirection direction;
  final CallState state;
  final DateTime startTime;
  final DateTime? endTime;
  final String? sipCallId;
  final String? gsmCallId;

  CallInfo({
    required this.id,
    required this.number,
    required this.direction,
    required this.state,
    required this.startTime,
    this.endTime,
    this.sipCallId,
    this.gsmCallId,
  });

  CallInfo copyWith({
    String? id,
    String? number,
    CallDirection? direction,
    CallState? state,
    DateTime? startTime,
    DateTime? endTime,
    String? sipCallId,
    String? gsmCallId,
  }) {
    return CallInfo(
      id: id ?? this.id,
      number: number ?? this.number,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      sipCallId: sipCallId ?? this.sipCallId,
      gsmCallId: gsmCallId ?? this.gsmCallId,
    );
  }

  Duration get duration {
    final end = endTime ?? DateTime.now();
    return end.difference(startTime);
  }
}

class GatewayStatus {
  final GatewayState state;
  final bool isConnected;
  final bool isRegistered;
  final String? errorMessage;
  final CallInfo? currentCall;
  final List<CallInfo> recentCalls;
  final DateTime lastUpdate;
  final Map<String, dynamic> sipStatus;
  final Map<String, dynamic> gsmStatus;

  GatewayStatus({
    required this.state,
    required this.isConnected,
    required this.isRegistered,
    this.errorMessage,
    this.currentCall,
    this.recentCalls = const [],
    required this.lastUpdate,
    this.sipStatus = const {},
    this.gsmStatus = const {},
  });

  GatewayStatus copyWith({
    GatewayState? state,
    bool? isConnected,
    bool? isRegistered,
    String? errorMessage,
    CallInfo? currentCall,
    List<CallInfo>? recentCalls,
    DateTime? lastUpdate,
    Map<String, dynamic>? sipStatus,
    Map<String, dynamic>? gsmStatus,
  }) {
    return GatewayStatus(
      state: state ?? this.state,
      isConnected: isConnected ?? this.isConnected,
      isRegistered: isRegistered ?? this.isRegistered,
      errorMessage: errorMessage ?? this.errorMessage,
      currentCall: currentCall ?? this.currentCall,
      recentCalls: recentCalls ?? this.recentCalls,
      lastUpdate: lastUpdate ?? this.lastUpdate,
      sipStatus: sipStatus ?? this.sipStatus,
      gsmStatus: gsmStatus ?? this.gsmStatus,
    );
  }

  String get statusText {
    switch (state) {
      case GatewayState.stopped:
        return 'Stopped';
      case GatewayState.starting:
        return 'Starting...';
      case GatewayState.running:
        if (isRegistered) {
          return 'Running (Registered)';
        } else if (isConnected) {
          return 'Running (Connecting)';
        } else {
          return 'Running (Disconnected)';
        }
      case GatewayState.error:
        return 'Error: ${errorMessage ?? 'Unknown error'}';
      case GatewayState.connecting:
        return 'Connecting...';
      case GatewayState.registered:
        return 'Registered';
      case GatewayState.callInProgress:
        return 'Call in progress';
    }
  }

  bool get isRunning => state == GatewayState.running || 
                       state == GatewayState.registered || 
                       state == GatewayState.callInProgress;
} 