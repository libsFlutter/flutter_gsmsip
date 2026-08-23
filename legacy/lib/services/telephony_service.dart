import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';
import 'package:permission_handler/permission_handler.dart';

/// Call information for Android telephony
class TelephonyCall {
  final String id;
  final String number;
  final TelephonyCallDirection direction;
  final TelephonyCallState state;
  final DateTime startTime;
  final Duration? duration;

  const TelephonyCall({
    required this.id,
    required this.number,
    required this.direction,
    required this.state,
    required this.startTime,
    this.duration,
  });
}

enum TelephonyCallDirection { incoming, outgoing }

enum TelephonyCallState { 
  idle,
  ringing, 
  offhook, 
  active, 
  hold, 
  ended 
}

enum TelephonyPermissionStatus {
  granted,
  denied,
  permanentlyDenied,
  restricted
}

/// Telephony Service for Android GSM integration
class TelephonyService {
  static final TelephonyService _instance = TelephonyService._internal();
  factory TelephonyService() => _instance;
  TelephonyService._internal();

  final Logger _logger = Logger();
  
  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/telephony');
  
  final Map<String, TelephonyCall> _activeCalls = {};
  bool _isInitialized = false;
  
  // Stream controllers
  final StreamController<TelephonyCall> _callStateController = 
      StreamController<TelephonyCall>.broadcast();
  final StreamController<String> _logController = 
      StreamController<String>.broadcast();
  final StreamController<Map<String, dynamic>> _phoneStateController = 
      StreamController<Map<String, dynamic>>.broadcast();

  // Getters
  bool get isInitialized => _isInitialized;
  List<TelephonyCall> get activeCalls => _activeCalls.values.toList();

  // Streams
  Stream<TelephonyCall> get callStateStream => _callStateController.stream;
  Stream<String> get logStream => _logController.stream;
  Stream<Map<String, dynamic>> get phoneStateStream => _phoneStateController.stream;

  /// Initialize telephony service
  Future<bool> initialize() async {
    try {
      _log('Initializing Telephony service...');
      
      // Check and request permissions
      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        _log('Required permissions not granted');
        return false;
      }

      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCall);
      
      // Initialize native telephony
      await _channel.invokeMethod('initialize');
      
      _isInitialized = true;
      _log('Telephony service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize Telephony service: $e');
      return false;
    }
  }

  /// Handle method calls from native Android code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onCallStateChanged':
        _handleCallStateChanged(call.arguments);
        break;
      case 'onPhoneStateChanged':
        _handlePhoneStateChanged(call.arguments);
        break;
      case 'onIncomingCall':
        _handleIncomingCall(call.arguments);
        break;
      default:
        _log('Unknown method call: ${call.method}');
    }
  }

  /// Make an outgoing call via Android telephony
  Future<String?> makeCall(String number) async {
    if (!_isInitialized) {
      _log('Telephony service not initialized');
      return null;
    }

    try {
      _log('Making call to $number via Android telephony');
      
      final result = await _channel.invokeMethod('makeCall', {
        'number': number,
      });
      
      if (result['success'] == true) {
        final callId = result['callId'] as String;
        
        final call = TelephonyCall(
          id: callId,
          number: number,
          direction: TelephonyCallDirection.outgoing,
          state: TelephonyCallState.ringing,
          startTime: DateTime.now(),
        );
        
        _activeCalls[callId] = call;
        _callStateController.add(call);
        
        return callId;
      } else {
        _log('Failed to make call: ${result['error']}');
        return null;
      }
    } catch (e) {
      _log('Error making call: $e');
      return null;
    }
  }

  /// Answer an incoming call
  Future<bool> answerCall() async {
    if (!_isInitialized) {
      _log('Telephony service not initialized');
      return false;
    }

    try {
      _log('Answering incoming call');
      
      final result = await _channel.invokeMethod('answerCall');
      return result['success'] == true;
    } catch (e) {
      _log('Error answering call: $e');
      return false;
    }
  }

  /// End a call
  Future<bool> endCall() async {
    if (!_isInitialized) {
      _log('Telephony service not initialized');
      return false;
    }

    try {
      _log('Ending call');
      
      final result = await _channel.invokeMethod('endCall');
      return result['success'] == true;
    } catch (e) {
      _log('Error ending call: $e');
      return false;
    }
  }

  /// Get phone number
  Future<String?> getPhoneNumber() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getPhoneNumber');
      return result['phoneNumber'] as String?;
    } catch (e) {
      _log('Error getting phone number: $e');
      return null;
    }
  }

  /// Get network operator name
  Future<String?> getNetworkOperatorName() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getNetworkOperatorName');
      return result['operatorName'] as String?;
    } catch (e) {
      _log('Error getting network operator: $e');
      return null;
    }
  }

  /// Get SIM card serial number
  Future<String?> getSimSerialNumber() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getSimSerialNumber');
      return result['simSerial'] as String?;
    } catch (e) {
      _log('Error getting SIM serial: $e');
      return null;
    }
  }

  /// Get signal strength
  Future<int?> getSignalStrength() async {
    if (!_isInitialized) {
      return null;
    }

    try {
      final result = await _channel.invokeMethod('getSignalStrength');
      return result['signalStrength'] as int?;
    } catch (e) {
      _log('Error getting signal strength: $e');
      return null;
    }
  }

  /// Send USSD code
  Future<String?> sendUssd(String ussdCode) async {
    if (!_isInitialized) {
      return null;
    }

    try {
      _log('Sending USSD code: $ussdCode');
      
      final result = await _channel.invokeMethod('sendUssd', {
        'ussdCode': ussdCode,
      });
      
      if (result['success'] == true) {
        return result['response'] as String?;
      } else {
        _log('USSD failed: ${result['error']}');
        return null;
      }
    } catch (e) {
      _log('Error sending USSD: $e');
      return null;
    }
  }

  /// Handle call state changes from native code
  void _handleCallStateChanged(Map<String, dynamic> args) {
    final callId = args['callId'] as String?;
    final state = args['state'] as String;
    final number = args['number'] as String?;
    
    if (callId != null && number != null) {
      final telephonyState = _mapCallState(state);
      
      final call = TelephonyCall(
        id: callId,
        number: number,
        direction: _activeCalls[callId]?.direction ?? TelephonyCallDirection.incoming,
        state: telephonyState,
        startTime: _activeCalls[callId]?.startTime ?? DateTime.now(),
        duration: telephonyState == TelephonyCallState.ended 
            ? DateTime.now().difference(_activeCalls[callId]?.startTime ?? DateTime.now())
            : null,
      );
      
      if (telephonyState == TelephonyCallState.ended) {
        _activeCalls.remove(callId);
      } else {
        _activeCalls[callId] = call;
      }
      
      _callStateController.add(call);
      _log('Call state changed: $callId -> ${telephonyState.name}');
    }
  }

  /// Handle phone state changes
  void _handlePhoneStateChanged(Map<String, dynamic> args) {
    _phoneStateController.add(args);
    _log('Phone state changed: $args');
  }

  /// Handle incoming calls
  void _handleIncomingCall(Map<String, dynamic> args) {
    final callId = args['callId'] as String;
    final number = args['number'] as String;
    
    final call = TelephonyCall(
      id: callId,
      number: number,
      direction: TelephonyCallDirection.incoming,
      state: TelephonyCallState.ringing,
      startTime: DateTime.now(),
    );
    
    _activeCalls[callId] = call;
    _callStateController.add(call);
    _log('Incoming call from $number (ID: $callId)');
  }

  /// Map string state to enum
  TelephonyCallState _mapCallState(String state) {
    switch (state.toLowerCase()) {
      case 'idle':
        return TelephonyCallState.idle;
      case 'ringing':
        return TelephonyCallState.ringing;
      case 'offhook':
        return TelephonyCallState.offhook;
      case 'active':
        return TelephonyCallState.active;
      case 'hold':
        return TelephonyCallState.hold;
      case 'ended':
        return TelephonyCallState.ended;
      default:
        return TelephonyCallState.idle;
    }
  }

  /// Request necessary permissions
  Future<bool> _requestPermissions() async {
    final permissions = [
      Permission.phone,
      Permission.sms,
      Permission.microphone,
      Permission.manageExternalStorage,
    ];

    Map<Permission, PermissionStatus> statuses = await permissions.request();
    
    bool allGranted = true;
    for (final permission in permissions) {
      final status = statuses[permission];
      if (status != PermissionStatus.granted) {
        _log('Permission ${permission.toString()} not granted: $status');
        allGranted = false;
      }
    }

    return allGranted;
  }

  /// Check if permissions are granted
  Future<TelephonyPermissionStatus> checkPermissions() async {
    final phonePermission = await Permission.phone.status;
    final smsPermission = await Permission.sms.status;
    final micPermission = await Permission.microphone.status;

    if (phonePermission.isGranted && smsPermission.isGranted && micPermission.isGranted) {
      return TelephonyPermissionStatus.granted;
    } else if (phonePermission.isPermanentlyDenied || 
               smsPermission.isPermanentlyDenied || 
               micPermission.isPermanentlyDenied) {
      return TelephonyPermissionStatus.permanentlyDenied;
    } else if (phonePermission.isRestricted || 
               smsPermission.isRestricted || 
               micPermission.isRestricted) {
      return TelephonyPermissionStatus.restricted;
    } else {
      return TelephonyPermissionStatus.denied;
    }
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] Telephony: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() {
    _callStateController.close();
    _logController.close();
    _phoneStateController.close();
  }
}
