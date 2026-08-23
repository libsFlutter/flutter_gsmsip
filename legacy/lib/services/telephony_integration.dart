import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

import 'sip_service.dart';
import 'telephony_service.dart';

/// Call state for telephony integration
/// Maps between GSM and SIP call states
enum IntegrationCallState {
  /// Call is idle/none
  idle,

  /// Call is ringing (incoming)
  ringing,

  /// Call is being dialed (outgoing)
  dialing,

  /// Call is active (connected)
  active,

  /// Call is on hold
  hold,

  /// Call is ending
  disconnecting,

  /// Call has ended
  ended,

  /// Call failed
  failed
}

/// Call direction for integration
enum IntegrationCallDirection {
  /// Incoming call (from GSM or SIP)
  incoming,

  /// Outgoing call (to GSM or SIP)
  outgoing
}

/// Call type indicating the source/destination
enum CallType {
  /// GSM/Cellular call
  gsm,

  /// SIP/VoIP call
  sip,

  /// Bridged call (GSM <-> SIP)
  bridged
}

/// Integrated call information
/// Represents a call that may be bridged between GSM and SIP
class IntegratedCall {
  final String id;
  final String number;
  final IntegrationCallDirection direction;
  final IntegrationCallState state;
  final CallType callType;
  final DateTime startTime;
  final DateTime? connectTime;
  final Duration? duration;

  // Linked call IDs for bridged calls
  final String? linkedGsmCallId;
  final String? linkedSipCallId;

  const IntegratedCall({
    required this.id,
    required this.number,
    required this.direction,
    required this.state,
    required this.callType,
    required this.startTime,
    this.connectTime,
    this.duration,
    this.linkedGsmCallId,
    this.linkedSipCallId,
  });

  /// Create a copy with updated fields
  IntegratedCall copyWith({
    String? id,
    String? number,
    IntegrationCallDirection? direction,
    IntegrationCallState? state,
    CallType? callType,
    DateTime? startTime,
    DateTime? connectTime,
    Duration? duration,
    String? linkedGsmCallId,
    String? linkedSipCallId,
  }) {
    return IntegratedCall(
      id: id ?? this.id,
      number: number ?? this.number,
      direction: direction ?? this.direction,
      state: state ?? this.state,
      callType: callType ?? this.callType,
      startTime: startTime ?? this.startTime,
      connectTime: connectTime ?? this.connectTime,
      duration: duration ?? this.duration,
      linkedGsmCallId: linkedGsmCallId ?? this.linkedGsmCallId,
      linkedSipCallId: linkedSipCallId ?? this.linkedSipCallId,
    );
  }

  @override
  String toString() {
    return 'IntegratedCall(id: $id, number: $number, state: $state, type: $callType)';
  }
}

/// Telephony Integration Service
///
/// This service integrates Android Telecom API with SIP telephony,
/// providing:
/// - Call state synchronization between GSM and SIP
/// - ConnectionService integration for system dialer
/// - Call bridging between GSM and SIP networks
/// - Unified call state management
///
/// Designed for GSM-SIP gateway applications.
class TelephonyIntegration {
  static final TelephonyIntegration _instance = TelephonyIntegration._internal();
  factory TelephonyIntegration() => _instance;
  TelephonyIntegration._internal();

  final Logger _logger = Logger();

  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/telephony_integration');

  // Service references
  final SipService _sipService = SipService();
  final TelephonyService _telephonyService = TelephonyService();

  // State
  bool _isInitialized = false;
  bool _isConnectionServiceRegistered = false;
  final Map<String, IntegratedCall> _activeCalls = {};

  // Call state mapping (GSM state -> Integration state)
  static const Map<String, IntegrationCallState> _gsmStateMap = {
    'idle': IntegrationCallState.idle,
    'ringing': IntegrationCallState.ringing,
    'offhook': IntegrationCallState.active,
    'active': IntegrationCallState.active,
    'hold': IntegrationCallState.hold,
    'disconnecting': IntegrationCallState.disconnecting,
    'ended': IntegrationCallState.ended,
    'failed': IntegrationCallState.failed,
  };

  // Call state mapping (SIP state -> Integration state)
  static const Map<SipCallState, IntegrationCallState> _sipStateMap = {
    SipCallState.connecting: IntegrationCallState.dialing,
    SipCallState.ringing: IntegrationCallState.ringing,
    SipCallState.active: IntegrationCallState.active,
    SipCallState.hold: IntegrationCallState.hold,
    SipCallState.ended: IntegrationCallState.ended,
    SipCallState.failed: IntegrationCallState.failed,
  };

  // Stream controllers
  final StreamController<IntegratedCall> _callStateController =
      StreamController<IntegratedCall>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _syncStateController =
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isConnectionServiceRegistered => _isConnectionServiceRegistered;
  List<IntegratedCall> get activeCalls => _activeCalls.values.toList();
  Stream<IntegratedCall> get callStateStream => _callStateController.stream;
  Stream<String> get logStream => _logController.stream;
  Stream<Map<String, dynamic>> get syncStateStream => _syncStateController.stream;

  /// Initialize the telephony integration service
  ///
  /// Sets up ConnectionService integration and call state synchronization.
  Future<bool> initialize() async {
    try {
      _log('Initializing Telephony Integration service...');

      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCall);

      // Register ConnectionService if not already registered
      await _registerConnectionService();

      // Set up call state listeners
      _setupCallStateListeners();

      _isInitialized = true;
      _log('Telephony Integration service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize Telephony Integration service: $e');
      return false;
    }
  }

  /// Handle method calls from native Android code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onConnectionServiceRegistered':
        _handleConnectionServiceRegistered(call.arguments);
        break;
      case 'onConnectionServiceUnregistered':
        _handleConnectionServiceUnregistered();
        break;
      case 'onCallStateChanged':
        _handleNativeCallStateChanged(call.arguments);
        break;
      case 'onSyncCallStates':
        _handleSyncCallStates(call.arguments);
        break;
      default:
        _log('Unknown method call: ${call.method}');
    }
  }

  /// Register ConnectionService with Android Telecom
  Future<bool> _registerConnectionService() async {
    try {
      _log('Registering ConnectionService...');

      final result = await _channel.invokeMethod('registerConnectionService');

      if (result['success'] == true) {
        _isConnectionServiceRegistered = true;
        _log('ConnectionService registered successfully');
        return true;
      } else {
        _log('Failed to register ConnectionService: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error registering ConnectionService: $e');
      return false;
    }
  }

  /// Unregister ConnectionService from Android Telecom
  Future<bool> _unregisterConnectionService() async {
    if (!_isConnectionServiceRegistered) {
      return true;
    }

    try {
      _log('Unregistering ConnectionService...');

      final result = await _channel.invokeMethod('unregisterConnectionService');

      if (result['success'] == true) {
        _isConnectionServiceRegistered = false;
        _log('ConnectionService unregistered successfully');
        return true;
      } else {
        _log('Failed to unregister ConnectionService: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error unregistering ConnectionService: $e');
      return false;
    }
  }

  /// Handle ConnectionService registration confirmation
  void _handleConnectionServiceRegistered(dynamic arguments) {
    _isConnectionServiceRegistered = true;
    _log('ConnectionService registration confirmed');
  }

  /// Handle ConnectionService unregistration
  void _handleConnectionServiceUnregistered() {
    _isConnectionServiceRegistered = false;
    _log('ConnectionService unregistered');
  }

  /// Handle call state changes from native ConnectionService
  void _handleNativeCallStateChanged(dynamic arguments) {
    try {
      if (arguments is Map) {
        final callId = arguments['callId'] as String?;
        final state = arguments['state'] as String?;
        final number = arguments['number'] as String?;
        final direction = arguments['direction'] as String?;

        if (callId != null && state != null) {
          final integrationState = _mapGsmStateToIntegrationState(state);
          _updateCallState(callId, integrationState);
          _log('Native call state changed: $callId -> $integrationState');
        }
      }
    } catch (e) {
      _log('Error handling native call state change: $e');
    }
  }

  /// Handle call state synchronization request
  void _handleSyncCallStates(dynamic arguments) {
    try {
      if (arguments is Map) {
        final gsmCalls = arguments['gsmCalls'] as List<dynamic>?;
        final sipCalls = arguments['sipCalls'] as List<dynamic>?;

        _log('Syncing call states: ${gsmCalls?.length ?? 0} GSM, ${sipCalls?.length ?? 0} SIP');

        // Process GSM calls
        if (gsmCalls != null) {
          for (final gsmCall in gsmCalls) {
            if (gsmCall is Map) {
              _syncGsmCallState(gsmCall);
            }
          }
        }

        // Process SIP calls
        if (sipCalls != null) {
          for (final sipCall in sipCalls) {
            if (sipCall is Map) {
              _syncSipCallState(sipCall);
            }
          }
        }

        _syncStateController.add({
          'gsmCalls': gsmCalls,
          'sipCalls': sipCalls,
          'timestamp': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      _log('Error syncing call states: $e');
    }
  }

  /// Sync GSM call state with integration
  void _syncGsmCallState(Map<String, dynamic> gsmCall) {
    final callId = gsmCall['id'] as String;
    final number = gsmCall['number'] as String;
    final state = gsmCall['state'] as String;
    final direction = gsmCall['direction'] as String;

    final integrationState = _mapGsmStateToIntegrationState(state);
    final integrationDirection = direction.toLowerCase() == 'outgoing'
        ? IntegrationCallDirection.outgoing
        : IntegrationCallDirection.incoming;

    final call = IntegratedCall(
      id: callId,
      number: number,
      direction: integrationDirection,
      state: integrationState,
      callType: CallType.gsm,
      startTime: DateTime.now(),
      linkedGsmCallId: callId,
    );

    _activeCalls[callId] = call;
    _callStateController.add(call);
    _log('Synced GSM call: $call');
  }

  /// Sync SIP call state with integration
  void _syncSipCallState(Map<String, dynamic> sipCall) {
    final callId = sipCall['id'] as String;
    final number = sipCall['remoteNumber'] as String;
    final stateString = sipCall['state'] as String;
    final direction = sipCall['direction'] as String;

    // Map SIP state string to enum
    SipCallState sipState;
    switch (stateString.toLowerCase()) {
      case 'connecting':
        sipState = SipCallState.connecting;
        break;
      case 'ringing':
        sipState = SipCallState.ringing;
        break;
      case 'active':
        sipState = SipCallState.active;
        break;
      case 'hold':
        sipState = SipCallState.hold;
        break;
      case 'ended':
        sipState = SipCallState.ended;
        break;
      case 'failed':
        sipState = SipCallState.failed;
        break;
      default:
        sipState = SipCallState.connecting;
    }

    final integrationState = _sipStateMap[sipState] ?? IntegrationCallState.idle;
    final integrationDirection = direction.toLowerCase() == 'outgoing'
        ? IntegrationCallDirection.outgoing
        : IntegrationCallDirection.incoming;

    final call = IntegratedCall(
      id: callId,
      number: number,
      direction: integrationDirection,
      state: integrationState,
      callType: CallType.sip,
      startTime: DateTime.now(),
      linkedSipCallId: callId,
    );

    _activeCalls[callId] = call;
    _callStateController.add(call);
    _log('Synced SIP call: $call');
  }

  /// Set up call state listeners for SIP and GSM services
  void _setupCallStateListeners() {
    // Listen to SIP call state changes
    _sipService.callStateStream.listen((sipCall) {
      _handleSipCallStateChanged(sipCall);
    });

    // Listen to GSM call state changes
    _telephonyService.callStateStream.listen((gsmCall) {
      _handleGsmCallStateChanged(gsmCall);
    });
  }

  /// Handle SIP call state changes
  void _handleSipCallStateChanged(SipCall sipCall) {
    final integrationState = _sipStateMap[sipCall.state] ?? IntegrationCallState.idle;
    final integrationDirection = sipCall.direction == SipCallDirection.outgoing
        ? IntegrationCallDirection.outgoing
        : IntegrationCallDirection.incoming;

    final existingCall = _activeCalls[sipCall.id];

    final call = IntegratedCall(
      id: sipCall.id,
      number: sipCall.remoteNumber,
      direction: integrationDirection,
      state: integrationState,
      callType: CallType.sip,
      startTime: existingCall?.startTime ?? DateTime.now(),
      connectTime: integrationState == IntegrationCallState.active
          ? (existingCall?.connectTime ?? DateTime.now())
          : null,
      duration: integrationState == IntegrationCallState.ended
          ? DateTime.now().difference(existingCall?.startTime ?? DateTime.now())
          : null,
      linkedSipCallId: sipCall.id,
    );

    if (integrationState == IntegrationCallState.ended ||
        integrationState == IntegrationCallState.failed) {
      _activeCalls.remove(sipCall.id);
    } else {
      _activeCalls[sipCall.id] = call;
    }

    _callStateController.add(call);
    _log('SIP call state changed: ${sipCall.id} -> $integrationState');

    // Sync state with native ConnectionService
    _syncCallStateToNative(call);
  }

  /// Handle GSM call state changes
  void _handleGsmCallStateChanged(TelephonyCall gsmCall) {
    final integrationState = _mapGsmStateToIntegrationState(gsmCall.state.name);
    final integrationDirection = gsmCall.direction == TelephonyCallDirection.outgoing
        ? IntegrationCallDirection.outgoing
        : IntegrationCallDirection.incoming;

    final existingCall = _activeCalls[gsmCall.id];

    final call = IntegratedCall(
      id: gsmCall.id,
      number: gsmCall.number,
      direction: integrationDirection,
      state: integrationState,
      callType: CallType.gsm,
      startTime: existingCall?.startTime ?? DateTime.now(),
      connectTime: integrationState == IntegrationCallState.active
          ? (existingCall?.connectTime ?? DateTime.now())
          : null,
      duration: integrationState == IntegrationCallState.ended
          ? gsmCall.duration ?? DateTime.now().difference(existingCall?.startTime ?? DateTime.now())
          : null,
      linkedGsmCallId: gsmCall.id,
    );

    if (integrationState == IntegrationCallState.ended) {
      _activeCalls.remove(gsmCall.id);
    } else {
      _activeCalls[gsmCall.id] = call;
    }

    _callStateController.add(call);
    _log('GSM call state changed: ${gsmCall.id} -> $integrationState');

    // Sync state with native ConnectionService
    _syncCallStateToNative(call);
  }

  /// Map GSM call state name to integration state
  IntegrationCallState _mapGsmStateToIntegrationState(String state) {
    return _gsmStateMap[state.toLowerCase()] ?? IntegrationCallState.idle;
  }

  /// Sync call state to native ConnectionService
  void _syncCallStateToNative(IntegratedCall call) {
    try {
      _channel.invokeMethod('syncCallState', {
        'callId': call.id,
        'state': call.state.name,
        'number': call.number,
        'direction': call.direction.name,
        'callType': call.callType.name,
        'connectTime': call.connectTime?.toIso8601String(),
      });
    } catch (e) {
      _log('Error syncing call state to native: $e');
    }
  }

  /// Update call state in active calls map
  void _updateCallState(String callId, IntegrationCallState newState) {
    final existingCall = _activeCalls[callId];
    if (existingCall == null) return;

    final updatedCall = existingCall.copyWith(
      state: newState,
      duration: newState == IntegrationCallState.ended ||
              newState == IntegrationCallState.failed
          ? DateTime.now().difference(existingCall.startTime)
          : null,
    );

    if (newState == IntegrationCallState.ended ||
        newState == IntegrationCallState.failed) {
      _activeCalls.remove(callId);
    } else {
      _activeCalls[callId] = updatedCall;
    }

    _callStateController.add(updatedCall);
  }

  /// Create a bridged call linking GSM and SIP calls
  String? createBridgedCall(String gsmCallId, String sipCallId) {
    final gsmCall = _activeCalls[gsmCallId];
    final sipCall = _activeCalls[sipCallId];

    if (gsmCall == null || sipCall == null) {
      _log('Cannot create bridged call: one or both calls not found');
      return null;
    }

    final bridgedId = 'bridged_${DateTime.now().millisecondsSinceEpoch}';

    // Update GSM call with SIP link
    final updatedGsmCall = gsmCall.copyWith(
      linkedSipCallId: sipCallId,
      callType: CallType.bridged,
    );
    _activeCalls[gsmCallId] = updatedGsmCall;

    // Update SIP call with GSM link
    final updatedSipCall = sipCall.copyWith(
      linkedGsmCallId: gsmCallId,
      callType: CallType.bridged,
    );
    _activeCalls[sipCallId] = updatedSipCall;

    _callStateController.add(updatedGsmCall);
    _callStateController.add(updatedSipCall);

    _log('Created bridged call: $bridgedId (GSM: $gsmCallId, SIP: $sipCallId)');
    return bridgedId;
  }

  /// Get call by ID
  IntegratedCall? getCall(String callId) {
    return _activeCalls[callId];
  }

  /// Get all active calls of a specific type
  List<IntegratedCall> getCallsByType(CallType type) {
    return _activeCalls.values.where((call) => call.callType == type).toList();
  }

  /// Get bridged calls
  List<IntegratedCall> getBridgedCalls() {
    return _activeCalls.values.where((call) => call.callType == CallType.bridged).toList();
  }

  /// Get call state mapping for GSM
  static IntegrationCallState mapGsmState(String gsmState) {
    return _gsmStateMap[gsmState.toLowerCase()] ?? IntegrationCallState.idle;
  }

  /// Get call state mapping for SIP
  static IntegrationCallState mapSipState(SipCallState sipState) {
    return _sipStateMap[sipState] ?? IntegrationCallState.idle;
  }

  /// Get current integration status
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': _isInitialized,
      'isConnectionServiceRegistered': _isConnectionServiceRegistered,
      'activeCallsCount': _activeCalls.length,
      'gsmCallsCount': getCallsByType(CallType.gsm).length,
      'sipCallsCount': getCallsByType(CallType.sip).length,
      'bridgedCallsCount': getBridgedCalls().length,
      'activeCalls': _activeCalls.values.map((c) => c.toMap()).toList(),
    };
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] TelephonyIntegration: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() async {
    // Unregister ConnectionService
    await _unregisterConnectionService();

    _callStateController.close();
    _logController.close();
    _syncStateController.close();
    _activeCalls.clear();
  }
}

/// Extension to convert IntegratedCall to Map
extension IntegratedCallExtension on IntegratedCall {
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'number': number,
      'direction': direction.name,
      'state': state.name,
      'callType': callType.name,
      'startTime': startTime.toIso8601String(),
      'connectTime': connectTime?.toIso8601String(),
      'duration': duration?.inSeconds,
      'linkedGsmCallId': linkedGsmCallId,
      'linkedSipCallId': linkedSipCallId,
    };
  }
}
