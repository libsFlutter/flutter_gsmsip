import 'dart:async';
import 'dart:io';
import 'package:logger/logger.dart';

/// SIP Account configuration
class SipAccount {
  final String username;
  final String password;
  final String domain;
  final String? proxy;
  final int port;
  final bool useSecure;

  const SipAccount({
    required this.username,
    required this.password,
    required this.domain,
    this.proxy,
    this.port = 5060,
    this.useSecure = false,
  });

  Map<String, dynamic> toJson() => {
    'username': username,
    'password': password,
    'domain': domain,
    'proxy': proxy,
    'port': port,
    'useSecure': useSecure,
  };

  factory SipAccount.fromJson(Map<String, dynamic> json) => SipAccount(
    username: json['username'],
    password: json['password'],
    domain: json['domain'],
    proxy: json['proxy'],
    port: json['port'] ?? 5060,
    useSecure: json['useSecure'] ?? false,
  );
}

/// SIP Call information
class SipCall {
  final String id;
  final String remoteNumber;
  final SipCallDirection direction;
  final SipCallState state;
  final DateTime startTime;
  final Duration? duration;

  const SipCall({
    required this.id,
    required this.remoteNumber,
    required this.direction,
    required this.state,
    required this.startTime,
    this.duration,
  });
}

enum SipCallDirection { incoming, outgoing }

enum SipCallState { 
  connecting, 
  ringing, 
  active, 
  hold, 
  ended, 
  failed 
}

enum SipConnectionState { 
  disconnected, 
  connecting, 
  connected, 
  error 
}

/// SIP Service for handling VoIP calls
class SipService {
  static final SipService _instance = SipService._internal();
  factory SipService() => _instance;
  SipService._internal();

  final Logger _logger = Logger();
  
  SipAccount? _account;
  SipConnectionState _connectionState = SipConnectionState.disconnected;
  final Map<String, SipCall> _activeCalls = {};
  
  // Stream controllers
  final StreamController<SipConnectionState> _connectionStateController = 
      StreamController<SipConnectionState>.broadcast();
  final StreamController<SipCall> _callStateController = 
      StreamController<SipCall>.broadcast();
  final StreamController<String> _logController = 
      StreamController<String>.broadcast();

  // Getters
  SipConnectionState get connectionState => _connectionState;
  SipAccount? get account => _account;
  List<SipCall> get activeCalls => _activeCalls.values.toList();

  // Streams
  Stream<SipConnectionState> get connectionStateStream => 
      _connectionStateController.stream;
  Stream<SipCall> get callStateStream => _callStateController.stream;
  Stream<String> get logStream => _logController.stream;

  /// Initialize SIP service with account configuration
  Future<bool> initialize(SipAccount account) async {
    try {
      _account = account;
      _log('Initializing SIP service with account: ${account.username}@${account.domain}');
      
      // Simulate SIP initialization
      _updateConnectionState(SipConnectionState.connecting);
      await Future.delayed(const Duration(seconds: 2));
      
      _updateConnectionState(SipConnectionState.connected);
      _log('SIP service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize SIP service: $e');
      _updateConnectionState(SipConnectionState.error);
      return false;
    }
  }

  /// Register with SIP server
  Future<bool> register() async {
    if (_account == null) {
      _log('No SIP account configured');
      return false;
    }

    try {
      _log('Registering with SIP server...');
      _updateConnectionState(SipConnectionState.connecting);
      
      // Simulate registration process
      await Future.delayed(const Duration(seconds: 1));
      
      _updateConnectionState(SipConnectionState.connected);
      _log('Successfully registered with SIP server');
      return true;
    } catch (e) {
      _log('Registration failed: $e');
      _updateConnectionState(SipConnectionState.error);
      return false;
    }
  }

  /// Unregister from SIP server
  Future<void> unregister() async {
    try {
      _log('Unregistering from SIP server...');
      
      // End all active calls first
      for (final call in _activeCalls.values) {
        await endCall(call.id);
      }
      
      _updateConnectionState(SipConnectionState.disconnected);
      _log('Unregistered from SIP server');
    } catch (e) {
      _log('Unregistration failed: $e');
    }
  }

  /// Make an outgoing call
  Future<String?> makeCall(String number) async {
    if (_connectionState != SipConnectionState.connected) {
      _log('Cannot make call: SIP not connected');
      return null;
    }

    try {
      final callId = 'call_${DateTime.now().millisecondsSinceEpoch}';
      _log('Making call to $number (ID: $callId)');
      
      final call = SipCall(
        id: callId,
        remoteNumber: number,
        direction: SipCallDirection.outgoing,
        state: SipCallState.connecting,
        startTime: DateTime.now(),
      );
      
      _activeCalls[callId] = call;
      _callStateController.add(call);
      
      // Simulate call progression
      _simulateCallProgression(callId, number);
      
      return callId;
    } catch (e) {
      _log('Failed to make call: $e');
      return null;
    }
  }

  /// Answer an incoming call
  Future<bool> answerCall(String callId) async {
    final call = _activeCalls[callId];
    if (call == null) {
      _log('Call not found: $callId');
      return false;
    }

    try {
      _log('Answering call $callId');
      
      final updatedCall = SipCall(
        id: call.id,
        remoteNumber: call.remoteNumber,
        direction: call.direction,
        state: SipCallState.active,
        startTime: call.startTime,
      );
      
      _activeCalls[callId] = updatedCall;
      _callStateController.add(updatedCall);
      
      return true;
    } catch (e) {
      _log('Failed to answer call: $e');
      return false;
    }
  }

  /// End a call
  Future<bool> endCall(String callId) async {
    final call = _activeCalls[callId];
    if (call == null) {
      _log('Call not found: $callId');
      return false;
    }

    try {
      _log('Ending call $callId');
      
      final duration = DateTime.now().difference(call.startTime);
      final updatedCall = SipCall(
        id: call.id,
        remoteNumber: call.remoteNumber,
        direction: call.direction,
        state: SipCallState.ended,
        startTime: call.startTime,
        duration: duration,
      );
      
      _activeCalls.remove(callId);
      _callStateController.add(updatedCall);
      
      return true;
    } catch (e) {
      _log('Failed to end call: $e');
      return false;
    }
  }

  /// Hold a call
  Future<bool> holdCall(String callId) async {
    final call = _activeCalls[callId];
    if (call == null || call.state != SipCallState.active) {
      return false;
    }

    try {
      final updatedCall = SipCall(
        id: call.id,
        remoteNumber: call.remoteNumber,
        direction: call.direction,
        state: SipCallState.hold,
        startTime: call.startTime,
        duration: call.duration,
      );
      
      _activeCalls[callId] = updatedCall;
      _callStateController.add(updatedCall);
      
      return true;
    } catch (e) {
      _log('Failed to hold call: $e');
      return false;
    }
  }

  /// Resume a held call
  Future<bool> resumeCall(String callId) async {
    final call = _activeCalls[callId];
    if (call == null || call.state != SipCallState.hold) {
      return false;
    }

    try {
      final updatedCall = SipCall(
        id: call.id,
        remoteNumber: call.remoteNumber,
        direction: call.direction,
        state: SipCallState.active,
        startTime: call.startTime,
        duration: call.duration,
      );
      
      _activeCalls[callId] = updatedCall;
      _callStateController.add(updatedCall);
      
      return true;
    } catch (e) {
      _log('Failed to resume call: $e');
      return false;
    }
  }

  /// Simulate incoming call (for testing)
  void simulateIncomingCall(String fromNumber) {
    if (_connectionState != SipConnectionState.connected) {
      return;
    }

    final callId = 'incoming_${DateTime.now().millisecondsSinceEpoch}';
    _log('Simulating incoming call from $fromNumber (ID: $callId)');
    
    final call = SipCall(
      id: callId,
      remoteNumber: fromNumber,
      direction: SipCallDirection.incoming,
      state: SipCallState.ringing,
      startTime: DateTime.now(),
    );
    
    _activeCalls[callId] = call;
    _callStateController.add(call);
  }

  /// Simulate call progression for outgoing calls
  void _simulateCallProgression(String callId, String number) {
    Timer(const Duration(seconds: 1), () {
      final call = _activeCalls[callId];
      if (call != null && call.state == SipCallState.connecting) {
        final ringingCall = SipCall(
          id: call.id,
          remoteNumber: call.remoteNumber,
          direction: call.direction,
          state: SipCallState.ringing,
          startTime: call.startTime,
        );
        _activeCalls[callId] = ringingCall;
        _callStateController.add(ringingCall);
        
        // Simulate answer after 3 seconds
        Timer(const Duration(seconds: 3), () {
          final currentCall = _activeCalls[callId];
          if (currentCall != null && currentCall.state == SipCallState.ringing) {
            final activeCall = SipCall(
              id: currentCall.id,
              remoteNumber: currentCall.remoteNumber,
              direction: currentCall.direction,
              state: SipCallState.active,
              startTime: currentCall.startTime,
            );
            _activeCalls[callId] = activeCall;
            _callStateController.add(activeCall);
          }
        });
      }
    });
  }

  void _updateConnectionState(SipConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] SIP: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() {
    _connectionStateController.close();
    _callStateController.close();
    _logController.close();
  }
}
