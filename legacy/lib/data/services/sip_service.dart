/// SIP Service
/// Wrapper around the native Android SIP plugin using MethodChannel and EventChannel

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/sip_account_model.dart';
import '../models/sip_call_model.dart';
import '../models/sip_event_model.dart';
import '../../entities/sip_event.dart';

/// SIP Service for communicating with native Android SIP plugin
///
/// Uses MethodChannel for commands and EventChannel for event streaming.
/// Follows the architecture defined in ADR-001 (service-architecture)
/// and ADR-002 (event-channel).
class SipService {
  /// Method channel for SIP commands
  static const MethodChannel _channel = MethodChannel('gostsimbox/sip');

  /// Event channel for SIP events
  static const EventChannel _eventChannel = EventChannel('gostsimbox/sip_events');

  /// Stream controller for broadcasting events
  final _eventController = StreamController<SipEvent>.broadcast();

  /// Stream controller for account events
  final _accountEventController = StreamController<SipEvent>.broadcast();

  /// Stream controller for call events
  final _callEventController = StreamController<SipEvent>.broadcast();

  /// Stream controller for connectivity events
  final _connectivityController = StreamController<bool>.broadcast();

  /// Whether the service is initialized
  bool _isInitialized = false;

  /// Whether connected to network
  bool _isConnected = false;

  /// Cached accounts
  final Map<String, SipAccountModel> _accounts = {};

  /// Cached calls
  final Map<String, SipCallModel> _calls = {};

  /// Stream of all SIP events
  Stream<SipEvent> get eventStream => _eventController.stream;

  /// Stream of account-related events
  Stream<SipEvent> get accountStream => _accountEventController.stream;

  /// Stream of call-related events
  Stream<SipEvent> get callStream => _callEventController.stream;

  /// Stream of connectivity events
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Whether connected to network
  bool get isConnected => _isConnected;

  /// Get all cached accounts
  Map<String, SipAccountModel> get accounts => Map.unmodifiable(_accounts);

  /// Get all cached calls
  Map<String, SipCallModel> get calls => Map.unmodifiable(_calls);

  /// Get active calls
  List<SipCallModel> get activeCalls {
    return _calls.values
        .where((call) => call.state == 'active' || call.state == 'held' || call.state == 'initiated' || call.state == 'incoming')
        .toList();
  }

  /// Initialize the SIP service
  ///
  /// Sets up event listeners and initializes the native SIP endpoint.
  Future<void> initialize() async {
    if (_isInitialized) {
      return;
    }

    try {
      // Setup event listeners
      _setupEventListeners();

      _isInitialized = true;
    } catch (e) {
      throw SipServiceException('Failed to initialize SIP service: $e');
    }
  }

  /// Setup event listeners from native channel
  void _setupEventListeners() {
    // Listen to event channel
    _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _handleEvent(event);
      },
      onError: (dynamic error) {
        _eventController.addError(SipServiceException('Event channel error: $error'));
      },
      onDone: () {
        // Event channel closed
      },
    );
  }

  /// Handle incoming event from native layer
  void _handleEvent(dynamic event) {
    try {
      SipEventModel model;
      
      if (event is Map) {
        model = SipEventModel.fromJson(Map<String, dynamic>.from(event));
      } else if (event is String) {
        final json = jsonDecode(event) as Map<String, dynamic>;
        model = SipEventModel.fromJson(json);
      } else {
        return;
      }

      final sipEvent = model.toEntity();

      // Broadcast to all subscribers
      _eventController.add(sipEvent);

      // Route to specific streams
      switch (sipEvent.type) {
        case SipEventType.accountChanged:
        case SipEventType.registrationChanged:
          _accountEventController.add(sipEvent);
          _updateAccountCache(sipEvent.data);
          break;

        case SipEventType.callReceived:
        case SipEventType.callChanged:
        case SipEventType.callTerminated:
          _callEventController.add(sipEvent);
          _updateCallCache(sipEvent.data);
          break;

        case SipEventType.connectivityChanged:
          final connected = sipEvent.data['connected'] as bool? ?? false;
          _isConnected = connected;
          _connectivityController.add(connected);
          break;

        default:
          break;
      }
    } catch (e) {
      // Log but don't crash on event parsing errors
    }
  }

  /// Update account cache from event data
  void _updateAccountCache(Map<String, dynamic> data) {
    final accountData = data['account'] as Map?;
    if (accountData != null) {
      final model = SipAccountModel.fromJson(accountData);
      _accounts[model.id] = model;
    }
    
    final accountId = data['accountId'] as String?;
    if (accountId != null && data['state'] != null) {
      // Update registration state only
      final existing = _accounts[accountId];
      if (existing != null) {
        _accounts[accountId] = existing.copyWith(
          registrationState: data['state'] as String,
          registrationStatus: data['status'] as String?,
        );
      }
    }
  }

  /// Update call cache from event data
  void _updateCallCache(Map<String, dynamic> data) {
    final callData = data['call'] as Map?;
    if (callData != null) {
      final model = SipCallModel.fromJson(callData);
      
      if (data['type'] == 'call_terminated' || model.state == 'terminated' || model.state == 'failed') {
        _calls.remove(model.id);
      } else {
        _calls[model.id] = model;
      }
    }
  }

  // ==================== Lifecycle Methods ====================

  /// Initialize SIP endpoint with configuration
  Future<void> initializeEndpoint(Map<String, dynamic> config) async {
    try {
      await _channel.invokeMethod('initialize', {'config': jsonEncode(config)});
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to initialize endpoint: ${e.message}');
    }
  }

  /// Destroy SIP endpoint and cleanup
  Future<void> destroyEndpoint() async {
    try {
      await _channel.invokeMethod('destroy');
      _isInitialized = false;
      _accounts.clear();
      _calls.clear();
      
      // Close streams
      await _eventController.close();
      await _accountEventController.close();
      await _callEventController.close();
      await _connectivityController.close();
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to destroy endpoint: ${e.message}');
    }
  }

  // ==================== Account Methods ====================

  /// Create a new SIP account
  Future<SipAccountModel> createAccount(SipAccountModel account) async {
    try {
      final result = await _channel.invokeMethod('createAccount', {
        'account': jsonEncode(account.toJson()),
      });
      
      if (result is Map) {
        return SipAccountModel.fromJson(Map<String, dynamic>.from(result));
      }
      
      return account;
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to create account: ${e.message}');
    }
  }

  /// Delete a SIP account
  Future<void> deleteAccount(String accountId) async {
    try {
      await _channel.invokeMethod('deleteAccount', {'accountId': accountId});
      _accounts.remove(accountId);
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to delete account: ${e.message}');
    }
  }

  /// Get a SIP account
  Future<SipAccountModel?> getAccount(String accountId) async {
    try {
      final result = await _channel.invokeMethod('getAccount', {'accountId': accountId});
      
      if (result == null) return null;
      
      if (result is Map) {
        return SipAccountModel.fromJson(Map<String, dynamic>.from(result));
      }
      
      return null;
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to get account: ${e.message}');
    }
  }

  /// Get all SIP accounts
  Future<List<SipAccountModel>> getAccounts() async {
    try {
      final result = await _channel.invokeMethod('getAccounts');
      
      if (result is List) {
        return result
            .whereType<Map>()
            .map((e) => SipAccountModel.fromJson(Map<String, dynamic>.from(e)))
            .toList();
      }
      
      return _accounts.values.toList();
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to get accounts: ${e.message}');
    }
  }

  /// Register a SIP account
  Future<void> registerAccount(String accountId, {bool reregister = false}) async {
    try {
      await _channel.invokeMethod('registerAccount', {
        'accountId': accountId,
        'reregister': reregister,
      });
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to register account: ${e.message}');
    }
  }

  /// Unregister a SIP account
  Future<void> unregisterAccount(String accountId) async {
    try {
      await _channel.invokeMethod('unregisterAccount', {'accountId': accountId});
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to unregister account: ${e.message}');
    }
  }

  // ==================== Call Methods ====================

  /// Make an outgoing call
  Future<SipCallModel> makeCall(String accountId, String number) async {
    try {
      final result = await _channel.invokeMethod('makeCall', {
        'accountId': accountId,
        'number': number,
      });
      
      if (result is Map) {
        final call = SipCallModel.fromJson(Map<String, dynamic>.from(result));
        _calls[call.id] = call;
        return call;
      }
      
      // Create optimistic call
      final call = SipCallModel.outgoing(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        accountId: accountId,
        number: number,
      );
      _calls[call.id] = call;
      return call;
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to make call: ${e.message}');
    }
  }

  /// Answer an incoming call
  Future<void> answerCall(String callId) async {
    try {
      await _channel.invokeMethod('answerCall', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(state: 'active');
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to answer call: ${e.message}');
    }
  }

  /// Decline an incoming call
  Future<void> declineCall(String callId) async {
    try {
      await _channel.invokeMethod('declineCall', {'callId': callId});
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to decline call: ${e.message}');
    }
  }

  /// Hangup a call
  Future<void> hangupCall(String callId) async {
    try {
      await _channel.invokeMethod('hangupCall', {'callId': callId});
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to hangup call: ${e.message}');
    }
  }

  /// Hold a call
  Future<void> holdCall(String callId) async {
    try {
      await _channel.invokeMethod('holdCall', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(state: 'held', isOnHold: true);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to hold call: ${e.message}');
    }
  }

  /// Unhold a call
  Future<void> unholdCall(String callId) async {
    try {
      await _channel.invokeMethod('unholdCall', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(state: 'active', isOnHold: false);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to unhold call: ${e.message}');
    }
  }

  /// Mute a call
  Future<void> muteCall(String callId) async {
    try {
      await _channel.invokeMethod('muteCall', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(isMuted: true);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to mute call: ${e.message}');
    }
  }

  /// Unmute a call
  Future<void> unmuteCall(String callId) async {
    try {
      await _channel.invokeMethod('unmuteCall', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(isMuted: false);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to unmute call: ${e.message}');
    }
  }

  /// Use speaker for a call
  Future<void> useSpeaker(String callId) async {
    try {
      await _channel.invokeMethod('useSpeaker', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(isSpeaker: true);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to use speaker: ${e.message}');
    }
  }

  /// Use earpiece for a call
  Future<void> useEarpiece(String callId) async {
    try {
      await _channel.invokeMethod('useEarpiece', {'callId': callId});
      
      final call = _calls[callId];
      if (call != null) {
        _calls[callId] = call.copyWith(isSpeaker: false);
      }
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to use earpiece: ${e.message}');
    }
  }

  /// Send DTMF tone
  Future<void> sendDtmf(String callId, String digit) async {
    try {
      await _channel.invokeMethod('sendDtmf', {
        'callId': callId,
        'digit': digit,
      });
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to send DTMF: ${e.message}');
    }
  }

  /// Transfer a call (blind transfer)
  Future<void> transferCall(String callId, String destination) async {
    try {
      await _channel.invokeMethod('transferCall', {
        'callId': callId,
        'destination': destination,
      });
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to transfer call: ${e.message}');
    }
  }

  /// Attended transfer
  Future<void> attendedTransfer(String callId, String targetCallId) async {
    try {
      await _channel.invokeMethod('attendedTransfer', {
        'callId': callId,
        'targetCallId': targetCallId,
      });
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to attended transfer: ${e.message}');
    }
  }

  /// Redirect a call
  Future<void> redirectCall(String callId, String destination) async {
    try {
      await _channel.invokeMethod('redirectCall', {
        'callId': callId,
        'destination': destination,
      });
    } on PlatformException catch (e) {
      throw SipServiceException('Failed to redirect call: ${e.message}');
    }
  }
}

/// SIP Service exception
class SipServiceException implements Exception {
  final String message;

  SipServiceException(this.message);

  @override
  String toString() => 'SipServiceException: $message';
}

/// Extension for creating outgoing call model
extension SipCallModelExtension on SipCallModel {
  /// Create outgoing call model
  static SipCallModel outgoing({
    required String id,
    required String accountId,
    required String number,
  }) {
    return SipCallModel(
      id: id,
      accountId: accountId,
      number: number,
      direction: 'outgoing',
      state: 'initiated',
      startTime: DateTime.now().toIso8601String(),
    );
  }
}
