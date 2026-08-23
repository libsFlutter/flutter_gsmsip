import 'dart:async';
import 'dart:convert';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// GSM leg: flutter_gsm's Modem-layer types, imported directly from `src/`
// (not the package barrel) because the barrel also re-exports a leftover
// copy of Sip*/Gateway* domain types (from when flutter_gsm was copied
// wholesale off flutter_gsmsip) that would collide by name with this
// package's own Sip*/Gateway* types below. See
// flows/sdd-flutter_gsm/04-implementation-log.md Task 11.
import 'package:flutter_gsm/src/domain/entities/modem_call.dart' as gsm;
import 'package:flutter_gsm/src/domain/entities/call_state.dart' as gsm;
import 'package:flutter_gsm/src/domain/models/modem_event.dart' as gsm;
import 'package:flutter_gsm/src/domain/repositories/modem_repository.dart'
    as gsm;
import 'package:flutter_gsm/src/data/repositories/modem_repository_impl.dart'
    as gsm;
import 'package:flutter_gsm/src/domain/exceptions/modem_exceptions.dart'
    as gsm;

import 'sip_state_tracker.dart';
import 'sms_service.dart';
import '../data/repositories/sip_repository_impl.dart';
import '../domain/entities/gateway_status.dart';
import '../domain/entities/gateway_config.dart';
import '../domain/entities/call_routing.dart';
import '../domain/entities/sip_call.dart';

/// Main Gateway Service that coordinates SIP, SMS, and GSM (modem) legs
///
/// GSM leg is sourced from `flutter_gsm`'s [gsm.ModemRepository] (was
/// `TelephonyService`, an Android-only Dart-side invention superseded by
/// the cross-platform modem abstraction). SIP leg is sourced from
/// [SipRepositoryImpl] (was the embedded PJSIP-glue `SipService`).
/// Init order is Modem → SIP → SMPP.
class GatewayService {
  static final GatewayService _instance = GatewayService._internal();
  factory GatewayService() => _instance;
  GatewayService._internal();

  final Logger _logger = Logger();

  // Service instances
  final gsm.ModemRepository _modemRepo = gsm.ModemRepositoryImpl();
  final SipStateTracker _sipTracker = SipStateTracker();
  late final SipRepositoryImpl _sipRepo =
      SipRepositoryImpl(_sipTracker, _logger);
  final SmsService _smsService = SmsService();

  StreamSubscription<gsm.ModemEvent>? _modemEventSub;
  StreamSubscription<dynamic>? _sipCallEventSub;

  // Configuration and state
  GatewayConfig? _config;
  bool _isRunning = false;
  DateTime? _startTime;
  int _totalCallsHandled = 0;
  int _totalMessagesHandled = 0;

  /// First modem discovered during [initialize]; null if none available
  /// (e.g. on a platform without a modem driver yet).
  String? _defaultModemId;

  /// Id assigned by `flutter_nmsip` to the account created from
  /// `config.sipAccount` during [initialize] — distinct from whatever id
  /// `config.sipAccount.id` carried in, since the native side assigns its
  /// own.
  String? _activeAccountId;

  // Call routing
  final Map<String, CallRouting> _activeRoutings = {};
  int _routingCounter = 0;

  /// SIP call id -> routing id, for calls placed via [makeCallViaSip] that
  /// are still waiting to become active before the GSM leg is dialed.
  final Map<String, String> _pendingSipActivation = {};

  // Stream controllers
  final StreamController<GatewayStatus> _statusController =
      StreamController<GatewayStatus>.broadcast();
  final StreamController<CallRouting> _routingController =
      StreamController<CallRouting>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  // Getters
  bool get isRunning => _isRunning;
  GatewayConfig? get config => _config;
  List<CallRouting> get activeRoutings => _activeRoutings.values.toList();

  // Streams
  Stream<GatewayStatus> get statusStream => _statusController.stream;
  Stream<CallRouting> get routingStream => _routingController.stream;
  Stream<String> get logStream => _logController.stream;

  /// Initialize the gateway with configuration
  Future<bool> initialize(GatewayConfig config) async {
    try {
      _config = config;
      _log('Initializing Gateway service...');

      // Discover modems first. Non-fatal: on platforms without a real
      // modem driver yet (desktop, ahead of sdd-asterisk-chan-simbox), the
      // GSM leg simply stays unavailable rather than blocking the gateway.
      try {
        final modems = await _modemRepo.listModems();
        _defaultModemId = modems.isEmpty ? null : modems.first.id;
        if (_defaultModemId == null) {
          _log('No modems found — GSM leg unavailable');
        }
      } on gsm.ModemException catch (e) {
        _defaultModemId = null;
        _log('Modem discovery unavailable: $e');
      }

      // Initialize SIP endpoint, then create the account from config.
      final sipInit = await _sipRepo.initialize(const {});
      final sipInitFailed = sipInit.isLeft();
      if (sipInitFailed) {
        _log('Failed to initialize SIP service');
        return false;
      }

      final createResult = await _sipRepo.createAccount(config.sipAccount);
      final accountId = createResult.fold((failure) {
        _log('Failed to create SIP account: ${failure.message}');
        return null;
      }, (account) => account.id);
      if (accountId == null) {
        return false;
      }
      _activeAccountId = accountId;

      // Initialize SMPP if configured
      if (config.smppConfig != null) {
        final smppInitialized =
            await _smsService.initializeSmpp(config.smppConfig!);
        if (!smppInitialized) {
          _log('Warning: Failed to initialize SMPP service');
        }
      }

      // Set up event listeners
      _setupEventListeners();

      // Save configuration
      await _saveConfiguration();

      _log('Gateway service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize Gateway service: $e');
      return false;
    }
  }

  /// Start the gateway service
  Future<bool> start() async {
    if (_config == null || _activeAccountId == null) {
      _log('Gateway not configured');
      return false;
    }

    try {
      _log('Starting Gateway service...');

      final registerResult = await _sipRepo.registerAccount(
        _activeAccountId!,
      );
      if (registerResult.isLeft()) {
        _log('Failed to register SIP');
        return false;
      }

      // Connect SMPP if configured
      if (_config!.smppConfig != null) {
        final smppConnected = await _smsService.connectSmpp();
        if (!smppConnected) {
          _log('Warning: Failed to connect SMPP');
        }
      }

      _isRunning = true;
      _startTime = DateTime.now();
      _log('Gateway service started successfully');
      _updateStatus();

      return true;
    } catch (e) {
      _log('Failed to start Gateway service: $e');
      return false;
    }
  }

  /// Stop the gateway service
  Future<void> stop() async {
    try {
      _log('Stopping Gateway service...');

      // End all active routings
      await endAllRoutings();

      // Unregister SIP (best-effort: flutter_nmsip has no true unregister,
      // see SipRepositoryImpl.unregisterAccount — logged, not fatal)
      if (_activeAccountId != null) {
        final result = await _sipRepo.unregisterAccount(_activeAccountId!);
        result.fold(
          (failure) => _log('SIP unregister: ${failure.message}'),
          (_) {},
        );
      }

      // Disconnect SMPP
      await _smsService.disconnectSmpp();

      _isRunning = false;
      _startTime = null;
      _log('Gateway service stopped');
      _updateStatus();
    } catch (e) {
      _log('Error stopping Gateway service: $e');
    }
  }

  /// End all active routings
  Future<void> endAllRoutings() async {
    for (final routing in List.of(_activeRoutings.values)) {
      await _endRouting(routing.id);
    }
    _log('All routings ended');
  }

  /// Make a call via SIP that will be routed to GSM
  Future<String?> makeCallViaSip(String number) async {
    if (!_isRunning || !_config!.routeSipToGsm || _activeAccountId == null) {
      return null;
    }

    try {
      _log('Making call via SIP to be routed to GSM: $number');

      final result = await _sipRepo.makeCall(_activeAccountId!, number);
      return result.fold((failure) {
        _log('Error making call via SIP: ${failure.message}');
        return null;
      }, (sipCall) {
        final routingId =
            'routing_${++_routingCounter}_${DateTime.now().millisecondsSinceEpoch}';
        final routing = CallRouting(
          id: routingId,
          sipCallId: sipCall.id,
          number: number,
          direction: CallRoutingDirection.sipToGsm,
          state: CallRoutingState.connecting,
          startTime: DateTime.now(),
        );

        _activeRoutings[routingId] = routing;
        _routingController.add(routing);
        _pendingSipActivation[sipCall.id] = routingId;

        return routingId;
      });
    } catch (e) {
      _log('Error making call via SIP: $e');
      return null;
    }
  }

  /// Called whenever a SIP call event fires — checks pending SIP→GSM
  /// routings for calls that have just become active, and dials the GSM
  /// leg for each.
  void _checkPendingSipActivations() {
    if (_pendingSipActivation.isEmpty) return;

    final activeCalls = _sipRepo.activeCalls;
    for (final entry in List.of(_pendingSipActivation.entries)) {
      final call = activeCalls
          .where((c) => c.id == entry.key)
          .cast<SipCall?>()
          .firstOrNull;
      if (call != null && call.state == CallState.active) {
        _pendingSipActivation.remove(entry.key);
        _makeGsmCallForRouting(entry.value, call.number);
      }
    }
  }

  /// Handle incoming GSM call and route to SIP
  Future<void> _handleIncomingGsmCall(gsm.ModemCall modemCall) async {
    if (_config == null || !_config!.routeGsmToSip || _activeAccountId == null) {
      return;
    }

    try {
      _log('Routing incoming GSM call to SIP: ${modemCall.number}');

      final result = await _sipRepo.makeCall(
        _activeAccountId!,
        modemCall.number,
      );
      final sipCallId = result.fold((failure) {
        _log('Error routing GSM call to SIP: ${failure.message}');
        return null;
      }, (sipCall) => sipCall.id);
      if (sipCallId == null) return;

      final routingId =
          'routing_${++_routingCounter}_${DateTime.now().millisecondsSinceEpoch}';
      final routing = CallRouting(
        id: routingId,
        sipCallId: sipCallId,
        telephonyCallId: modemCall.id,
        number: modemCall.number,
        direction: CallRoutingDirection.gsmToSip,
        state: CallRoutingState.connecting,
        startTime: DateTime.now(),
      );

      _activeRoutings[routingId] = routing;
      _routingController.add(routing);

      // Auto-answer GSM call if configured
      if (_config!.autoAnswer) {
        try {
          await _modemRepo.answerCall(modemCall.id);
        } on gsm.ModemException catch (e) {
          _log('Failed to auto-answer GSM call: $e');
        }
      }

      _totalCallsHandled++;
    } catch (e) {
      _log('Error routing GSM call to SIP: $e');
    }
  }

  /// Make GSM call for SIP routing
  Future<void> _makeGsmCallForRouting(String routingId, String number) async {
    if (_defaultModemId == null) {
      _log('No modem available to route call for $routingId');
      await _endRouting(routingId);
      return;
    }

    try {
      final modemCall = await _modemRepo.dial(_defaultModemId!, number);

      final routing = _activeRoutings[routingId];
      if (routing != null) {
        final updatedRouting = routing.copyWith(
          telephonyCallId: modemCall.id,
          state: CallRoutingState.active,
        );

        _activeRoutings[routingId] = updatedRouting;
        _routingController.add(updatedRouting);
      }

      _totalCallsHandled++;
    } on gsm.ModemException catch (e) {
      _log('Error making GSM call for routing: $e');
      await _endRouting(routingId);
    } catch (e) {
      _log('Error making GSM call for routing: $e');
      await _endRouting(routingId);
    }
  }

  /// End a call routing
  Future<void> _endRouting(String routingId) async {
    final routing = _activeRoutings[routingId];
    if (routing == null) return;

    try {
      // End SIP call
      final hangupResult = await _sipRepo.hangupCall(routing.sipCallId);
      hangupResult.fold(
        (failure) => _log('Error ending SIP leg: ${failure.message}'),
        (_) {},
      );

      // End GSM call if exists
      if (routing.telephonyCallId != null) {
        try {
          await _modemRepo.hangupCall(routing.telephonyCallId!);
        } on gsm.ModemException catch (e) {
          _log('Error ending GSM leg: $e');
        }
      }

      final endedRouting = routing.copyWith(state: CallRoutingState.ended);

      _activeRoutings.remove(routingId);
      _routingController.add(endedRouting);
    } catch (e) {
      _log('Error ending routing: $e');
    }
  }

  /// Send SMS via appropriate service
  Future<String?> sendSms(
    String recipient,
    String content, {
    bool useSmpp = false,
  }) async {
    try {
      if (useSmpp && _config?.smppConfig != null) {
        return await _smsService.sendSmsViaSmpp(recipient, content);
      } else {
        return await _smsService.sendSmsLocal(recipient, content);
      }
    } catch (e) {
      _log('Error sending SMS: $e');
      return null;
    }
  }

  /// Get gateway status
  GatewayStatus getStatus() {
    final telephonyPermissions = _defaultModemId != null
        ? TelephonyPermissionStatus.granted
        : TelephonyPermissionStatus.notRequested;

    return GatewayStatus(
      isRunning: _isRunning,
      sipState: _sipTracker.isConnected
          ? SipConnectionState.connected
          : (_sipTracker.isInitialized
              ? SipConnectionState.connecting
              : SipConnectionState.disconnected),
      smppState: _smsService.connectionState,
      telephonyPermissions: telephonyPermissions,
      activeCalls: _activeRoutings.length,
      totalCallsHandled: _totalCallsHandled,
      totalMessagesHandled: _totalMessagesHandled,
      startTime: _startTime,
      uptime: _startTime != null
          ? DateTime.now().difference(_startTime!)
          : null,
      activeRoutings: _activeRoutings.length,
    );
  }

  /// Set up event listeners for all services
  void _setupEventListeners() {
    // SIP call events — react generically, then re-check pending
    // activations and refresh status (state itself lives in the SIP
    // repository/tracker, not in the event payload).
    _sipCallEventSub = _sipRepo.callStream.listen((_) {
      _checkPendingSipActivations();
      _updateStatus();
    });

    // SMS event listeners
    _smsService.messageStream.listen(_handleSmsMessage);
    _smsService.logStream.listen(_handleServiceLog);

    // Modem (GSM) event listeners
    _modemEventSub = _modemRepo.modemEvents.listen(_handleModemEvent);
  }

  void _handleModemEvent(gsm.ModemEvent event) {
    if (event is gsm.ModemCallStateChanged) {
      final call = event.call;
      _log('Modem call state changed: ${call.id} -> ${call.state.name}');

      if (call.direction == gsm.CallDirection.incoming &&
          call.state == gsm.CallState.incoming) {
        _handleIncomingGsmCall(call);
      }

      _updateStatus();
    }
  }

  /// Handle SMS messages
  void _handleSmsMessage(SmsMessage message) {
    _log('SMS message: ${message.type.name} ${message.id}');
    _totalMessagesHandled++;
    _updateStatus();
  }

  /// Handle service logs
  void _handleServiceLog(String log) {
    if (_config?.enableLogging == true) {
      _logController.add(log);
    }
  }

  /// Update gateway status
  void _updateStatus() {
    _statusController.add(getStatus());
  }

  /// Save configuration to persistent storage
  Future<void> _saveConfiguration() async {
    if (_config == null) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(_config!.toJson());
      await prefs.setString('gateway_config', configJson);
    } catch (e) {
      _log('Error saving configuration: $e');
    }
  }

  /// Load configuration from persistent storage
  Future<GatewayConfig?> loadConfiguration() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = prefs.getString('gateway_config');
      if (configJson != null) {
        final configMap = jsonDecode(configJson) as Map<String, dynamic>;
        return GatewayConfig.fromJson(configMap);
      }
    } catch (e) {
      _log('Error loading configuration: $e');
    }
    return null;
  }

  /// Make a call via GSM
  Future<String?> makeCallViaGsm(String number) async {
    if (!_isRunning || _defaultModemId == null) {
      return null;
    }
    try {
      _log('Making call via GSM: $number');
      final call = await _modemRepo.dial(_defaultModemId!, number);
      return call.id;
    } on gsm.ModemException catch (e) {
      _log('Failed to make GSM call: $e');
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

  /// End a specific routing
  Future<void> endRouting(String routingId) async {
    await _endRouting(routingId);
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalCallsHandled': _totalCallsHandled,
      'totalMessagesHandled': _totalMessagesHandled,
      'activeRoutings': _activeRoutings.length,
      'uptime': _startTime != null
          ? DateTime.now().difference(_startTime!)
          : Duration.zero,
    };
  }

  /// Reset statistics
  void resetStatistics() {
    _totalCallsHandled = 0;
    _totalMessagesHandled = 0;
    _log('Statistics reset');
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] Gateway: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() {
    _statusController.close();
    _routingController.close();
    _logController.close();

    _modemEventSub?.cancel();
    _sipCallEventSub?.cancel();
    _sipTracker.dispose();
    _smsService.dispose();
  }
}
