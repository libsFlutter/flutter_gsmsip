/// Gateway Service
/// Core orchestration service for bidirectional SIP↔GSM routing

import 'dart:async';
import 'package:logger/logger.dart';
import '../entities/gateway_config.dart';
import '../entities/gateway_status.dart';
import '../entities/call_routing.dart';
import 'sip_service.dart';
import '../../../services/telephony_service.dart';
import '../../../services/smpp_service.dart';
import '../../../services/sms_service.dart';

/// Gateway Service Singleton
///
/// Orchestrates bidirectional routing between SIP and GSM telephony.
/// Manages call routings, state synchronization, and statistics.
class GatewayService {
  static final GatewayService _instance = GatewayService._internal();
  factory GatewayService() => _instance;
  GatewayService._internal();

  final Logger _logger = Logger();

  // Sub-services
  final SipService _sipService = SipService();
  final TelephonyService _telephonyService = TelephonyService();
  final SmppService _smppService = SmppService();

  // Configuration
  GatewayConfig? _config;
  bool _isRunning = false;
  DateTime? _startTime;

  // Statistics
  int _totalCallsHandled = 0;
  int _totalMessagesHandled = 0;

  // Active routings
  final Map<String, CallRouting> _activeRoutings = {};
  int _routingCounter = 0;

  // Stream controllers
  final _statusController = StreamController<GatewayStatus>.broadcast();
  final _routingController = StreamController<CallRouting>.broadcast();
  final _logController = StreamController<String>.broadcast();

  // Event subscriptions
  StreamSubscription? _sipEventSubscription;
  StreamSubscription? _telephonyEventSubscription;
  StreamSubscription? _smppEventSubscription;

  /// Get current configuration
  GatewayConfig? get config => _config;

  /// Check if gateway is running
  bool get isRunning => _isRunning;

  /// Get start time
  DateTime? get startTime => _startTime;

  /// Get total calls handled
  int get totalCallsHandled => _totalCallsHandled;

  /// Get total messages handled
  int get totalMessagesHandled => _totalMessagesHandled;

  /// Get active routings
  Map<String, CallRouting> get activeRoutings =>
      Map.unmodifiable(_activeRoutings);

  /// Get active routing count
  int get activeRoutingCount => _activeRoutings.length;

  /// Get active call count
  int get activeCallCount =>
      _activeRoutings.values.where((r) => r.isActive).length;

  /// Stream of gateway status updates
  Stream<GatewayStatus> get statusStream => _statusController.stream;

  /// Stream of call routing updates
  Stream<CallRouting> get routingStream => _routingController.stream;

  /// Stream of log messages
  Stream<String> get logStream => _logController.stream;

  /// Initialize gateway with configuration
  Future<bool> initialize(GatewayConfig config) async {
    try {
      _log('Initializing gateway...');

      // Validate configuration
      if (!config.isValid) {
        _log('Invalid configuration: ${config.validationErrors.join(', ')}');
        return false;
      }

      _config = config;

      // Initialize Telephony service first (foundation)
      _log('Initializing Telephony service...');
      final telephonyInitialized = await _telephonyService.initialize();
      if (!telephonyInitialized) {
        _log('Failed to initialize Telephony service');
        return false;
      }

      // Initialize SIP service
      _log('Initializing SIP service...');
      await _sipService.initialize();

      // Initialize SMPP service if configured
      if (config.isSmppConfigured) {
        _log('Initializing SMPP service...');
        await _smppService.initialize(config.smppConfig!);
      }

      // Setup event listeners
      _setupEventListeners();

      _log('Gateway initialized successfully');
      _broadcastStatus();
      return true;
    } catch (e) {
      _log('Failed to initialize gateway: $e');
      _broadcastStatus();
      return false;
    }
  }

  /// Start gateway routing
  Future<bool> start() async {
    try {
      if (_config == null) {
        _log('Cannot start: configuration not loaded');
        return false;
      }

      if (_isRunning) {
        _log('Gateway already running');
        return true;
      }

      _log('Starting gateway...');

      // Register SIP account
      final sipAccount = _config!.sipAccount;
      await _sipService.createAccount(sipAccount);
      await _sipService.registerAccount(sipAccount.id);

      // Connect SMPP if configured
      if (_config!.isSmppConfigured) {
        await _smppService.connect();
      }

      _isRunning = true;
      _startTime = DateTime.now();

      _log('Gateway started successfully');
      _broadcastStatus();
      return true;
    } catch (e) {
      _log('Failed to start gateway: $e');
      _isRunning = false;
      _broadcastStatus();
      return false;
    }
  }

  /// Stop gateway routing
  Future<void> stop() async {
    try {
      if (!_isRunning) return;

      _log('Stopping gateway...');

      // End all active routings
      await _endAllRoutings();

      // Unregister SIP account
      if (_config?.sipAccount != null) {
        await _sipService.unregisterAccount(_config!.sipAccount.id);
      }

      // Disconnect SMPP
      if (_config!.isSmppConfigured) {
        await _smppService.disconnect();
      }

      _isRunning = false;
      _startTime = null;

      _log('Gateway stopped');
      _broadcastStatus();
    } catch (e) {
      _log('Error stopping gateway: $e');
    }
  }

  /// Dispose gateway resources
  Future<void> dispose() async {
    try {
      await stop();

      // Close stream controllers
      await _statusController.close();
      await _routingController.close();
      await _logController.close();

      // Cancel subscriptions
      await _sipEventSubscription?.cancel();
      await _telephonyEventSubscription?.cancel();
      await _smppEventSubscription?.cancel();

      _log('Gateway disposed');
    } catch (e) {
      _log('Error disposing gateway: $e');
    }
  }

  /// Setup all event listeners
  void _setupEventListeners() {
    // SIP events
    _sipEventSubscription = _sipService.eventStream.listen(
      _handleSipEvent,
      onError: (e) => _log('SIP event error: $e'),
    );

    // Telephony events
    _telephonyEventSubscription = _telephonyService.callStateStream.listen(
      _handleTelephonyCall,
      onError: (e) => _log('Telephony event error: $e'),
    );

    // SMPP events
    if (_config!.isSmppConfigured) {
      _smppEventSubscription = _smppService.incomingMessageStream.listen(
        _handleSmppMessage,
        onError: (e) => _log('SMPP event error: $e'),
      );
    }
  }

  /// Handle SIP event
  void _handleSipEvent(dynamic event) {
    _log('SIP event received: $event');
    // SIP events are handled via routing synchronization
  }

  /// Handle Telephony call event
  void _handleTelephonyCall(TelephonyCall call) {
    _log('Telephony call event: ${call.state} for ${call.number}');

    // Handle incoming GSM calls for GSM→SIP routing
    if (call.direction == TelephonyCallDirection.incoming &&
        call.state == TelephonyCallState.ringing &&
        _config!.routeGsmToSip) {
      _handleIncomingGsmCall(call);
    }

    // Update routing state for existing routings
    _updateRoutingFromTelephony(call);
  }

  /// Handle incoming GSM call (GSM→SIP routing)
  void _handleIncomingGsmCall(TelephonyCall call) async {
    _log('Handling incoming GSM call from ${call.number}');

    // Check if auto-answer is enabled
    if (_config!.autoAnswer) {
      _log('Auto-answering GSM call');
      await _telephonyService.answerCall();
    }

    // Create GSM→SIP routing
    final routingId = _generateRoutingId();
    final routing = CallRouting.gsmToSip(
      id: routingId,
      telephonyCallId: call.id,
      number: call.number,
    );

    _activeRoutings[routingId] = routing;
    _routingController.add(routing);

    _log('Created GSM→SIP routing $routingId for call ${call.id}');

    // Make SIP call to bridge (would be implemented based on requirements)
    // For now, the routing is tracked and can be managed manually
  }

  /// Handle SMPP message
  void _handleSmppMessage(SmppMessage message) {
    _log('SMPP message received from ${message.sourceAddress}');
    _totalMessagesHandled++;
    _broadcastStatus();
  }

  /// Update routing from telephony call state
  void _updateRoutingFromTelephony(TelephonyCall call) {
    // Find routing by telephony call ID
    final routingEntry = _activeRoutings.entries.firstWhere(
      (e) => e.value.telephonyCallId == call.id,
      orElse: () => MapEntry('', null),
    );

    if (routingEntry.value == null) return;

    final routing = routingEntry.value!;
    CallRoutingState? newState;

    switch (call.state) {
      case TelephonyCallState.active:
        if (routing.state == CallRoutingState.connecting) {
          newState = CallRoutingState.active;
        }
        break;
      case TelephonyCallState.ended:
        newState = CallRoutingState.ended;
        break;
      default:
        break;
    }

    if (newState != null && routing.canTransitionTo(newState)) {
      final updatedRouting = routing.copyWith(
        state: newState,
        endTime: newState == CallRoutingState.ended ? DateTime.now() : null,
      );
      _activeRoutings[routingEntry.key] = updatedRouting;
      _routingController.add(updatedRouting);

      if (newState == CallRoutingState.ended) {
        _totalCallsHandled++;
        Future.delayed(const Duration(seconds: 5), () {
          _activeRoutings.remove(routingEntry.key);
        });
      }

      _broadcastStatus();
    }
  }

  /// Make call via SIP (SIP→GSM routing)
  Future<String?> makeCallViaSip(String number) async {
    try {
      if (!_isRunning) {
        _log('Cannot make call: gateway not running');
        return null;
      }

      if (!_config!.routeSipToGsm) {
        _log('SIP→GSM routing is disabled');
        return null;
      }

      // Check max concurrent calls
      if (activeCallCount >= _config!.maxConcurrentCalls) {
        _log('Max concurrent calls reached: ${_config!.maxConcurrentCalls}');
        return null;
      }

      _log('Making call via SIP to $number');

      // Get default account
      final account = _config!.sipAccount;

      // Make SIP call first
      final sipCall = await _sipService.makeCall(account.id, number);
      final sipCallId = sipCall.id;

      _log('SIP call created: $sipCallId');

      // Create routing
      final routingId = _generateRoutingId();
      final routing = CallRouting.sipToGsm(
        id: routingId,
        sipCallId: sipCallId,
        number: number,
      );

      _activeRoutings[routingId] = routing;
      _routingController.add(routing);

      _log('Created SIP→GSM routing $routingId');

      // Make GSM call to bridge the SIP call
      final telephonyCallId = await _telephonyService.makeCall(number);

      if (telephonyCallId != null) {
        final updatedRouting = routing.copyWith(
          telephonyCallId: telephonyCallId,
          state: CallRoutingState.active,
        );
        _activeRoutings[routingId] = updatedRouting;
        _routingController.add(updatedRouting);
        _log('GSM call bridged: $telephonyCallId');
      }

      return routingId;
    } catch (e) {
      _log('Error making call via SIP: $e');
      return null;
    }
  }

  /// Make call via GSM (GSM→SIP routing)
  Future<String?> makeCallViaGsm(String number) async {
    try {
      if (!_isRunning) {
        _log('Cannot make call: gateway not running');
        return null;
      }

      if (!_config!.routeGsmToSip) {
        _log('GSM→SIP routing is disabled');
        return null;
      }

      _log('Making call via GSM to $number');

      // Make GSM call first
      final telephonyCallId = await _telephonyService.makeCall(number);

      if (telephonyCallId == null) {
        _log('Failed to make GSM call');
        return null;
      }

      // Create routing
      final routingId = _generateRoutingId();
      final routing = CallRouting.gsmToSip(
        id: routingId,
        telephonyCallId: telephonyCallId,
        number: number,
      );

      _activeRoutings[routingId] = routing;
      _routingController.add(routing);

      _log('Created GSM→SIP routing $routingId for GSM call $telephonyCallId');

      return routingId;
    } catch (e) {
      _log('Error making call via GSM: $e');
      return null;
    }
  }

  /// Send SMS
  Future<String?> sendSms(String recipient, String content, {bool useSmpp = false}) async {
    try {
      if (!_isRunning) {
        _log('Cannot send SMS: gateway not running');
        return null;
      }

      _log('Sending SMS to $recipient (useSmpp: $useSmpp)');

      String? messageId;

      // If useSmpp and SMPP configured, use SMPP
      if (useSmpp && _config!.isSmppConfigured) {
        _log('Sending SMS via SMPP');
        final success = await _smppService.sendSms(recipient, content);
        if (success) {
          messageId = 'smpp_${DateTime.now().millisecondsSinceEpoch}';
          _log('SMS sent via SMPP: $messageId');
        }
      } else {
        _log('Sending SMS via local GSM telephony');
        // Use local SMS service
        final smsService = SmsService();
        final success = await smsService.sendSms(recipient, content);
        if (success) {
          messageId = 'sms_${DateTime.now().millisecondsSinceEpoch}';
          _log('SMS sent via GSM: $messageId');
        }
      }

      if (messageId != null) {
        _totalMessagesHandled++;
        _broadcastStatus();
        return messageId;
      }

      return null;
    } catch (e) {
      _log('Error sending SMS: $e');
      return null;
    }
  }

  /// Get routing by ID
  CallRouting? getRouting(String routingId) {
    return _activeRoutings[routingId];
  }

  /// Get all active routings
  List<CallRouting> getActiveRoutings() {
    return _activeRoutings.values.toList();
  }

  /// End specific routing
  Future<void> endRouting(String routingId) async {
    try {
      final routing = _activeRoutings[routingId];
      if (routing == null) {
        _log('Routing not found: $routingId');
        return;
      }

      _log('Ending routing $routingId');

      // End SIP call if exists
      if (routing.sipCallId.isNotEmpty) {
        try {
          await _sipService.hangupCall(routing.sipCallId);
          _log('SIP call ended: ${routing.sipCallId}');
        } catch (e) {
          _log('Error ending SIP call: $e');
        }
      }

      // End telephony call if exists
      if (routing.telephonyCallId != null) {
        try {
          await _telephonyService.endCall();
          _log('Telephony call ended: ${routing.telephonyCallId}');
        } catch (e) {
          _log('Error ending telephony call: $e');
        }
      }

      // Update routing state
      final updatedRouting = routing.copyWith(
        state: CallRoutingState.ended,
        endTime: DateTime.now(),
      );
      _activeRoutings[routingId] = updatedRouting;
      _routingController.add(updatedRouting);

      // Remove from active routings after delay
      Future.delayed(const Duration(seconds: 5), () {
        _activeRoutings.remove(routingId);
      });

      _totalCallsHandled++;
      _broadcastStatus();

      _log('Routing $routingId ended');
    } catch (e) {
      _log('Error ending routing: $e');
    }
  }

  /// End all active routings
  Future<void> _endAllRoutings() async {
    final routingIds = _activeRoutings.keys.toList();
    for (final id in routingIds) {
      await endRouting(id);
    }
  }

  /// Get current status
  GatewayStatus getStatus() {
    return GatewayStatus(
      isRunning: _isRunning,
      sipState: _sipService.isInitialized
          ? SipConnectionState.connected
          : SipConnectionState.disconnected,
      smppState: _config!.isSmppConfigured && _smppService.isConnected
          ? SmppConnectionState.connected
          : SmppConnectionState.disconnected,
      telephonyPermissions: _telephonyService.isInitialized
          ? TelephonyPermissionStatus.granted
          : TelephonyPermissionStatus.notRequested,
      activeCalls: activeCallCount,
      totalCallsHandled: _totalCallsHandled,
      totalMessagesHandled: _totalMessagesHandled,
      startTime: _startTime,
      uptime: _startTime != null ? DateTime.now().difference(_startTime!) : null,
      activeRoutings: _activeRoutings.length,
    );
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'isRunning': _isRunning,
      'startTime': _startTime?.toIso8601String(),
      'uptime': _startTime != null ? DateTime.now().difference(_startTime!).inSeconds : 0,
      'totalCallsHandled': _totalCallsHandled,
      'totalMessagesHandled': _totalMessagesHandled,
      'activeCalls': activeCallCount,
      'activeRoutings': _activeRoutings.length,
      'sipConnected': _sipService.isInitialized,
      'telephonyConnected': _telephonyService.isInitialized,
      'smppConnected': _smppService.isConnected,
    };
  }

  /// Reset statistics
  void resetStatistics() {
    _totalCallsHandled = 0;
    _totalMessagesHandled = 0;
    _log('Statistics reset');
    _broadcastStatus();
  }

  /// Generate unique routing ID
  String _generateRoutingId() {
    _routingCounter++;
    return 'routing_${DateTime.now().millisecondsSinceEpoch}_$_routingCounter';
  }

  /// Broadcast status update
  void _broadcastStatus() {
    final status = getStatus();
    _statusController.add(status);
  }

  /// Log message
  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] $message';
    _logger.i(logMessage);
    if (_config?.enableLogging ?? true) {
      _logController.add(logMessage);
    }
  }
}
