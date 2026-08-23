/// Endpoint2 - Next-Generation SIP Endpoint
///
/// Enhanced alternative to TeleEndpoint with improved API design,
/// better error handling, and modern Dart patterns.
///
/// Source: sdd-endpoint-2
/// Task: endpoint2-001 - Implement Endpoint2 (next-gen endpoint with improved API)
///
/// Key Improvements over TeleEndpoint:
/// - Strongly-typed event streams with generics
/// - Result-based error handling (Result<T, E> pattern)
/// - Builder pattern for configuration
/// - Automatic reconnection with configurable retry
/// - Better state management and lifecycle hooks
/// - Improved documentation and type safety
///
/// Usage:
/// ```dart
/// final endpoint = Endpoint2();
///
/// // Configure with builder
/// final config = Endpoint2Configuration.builder()
///   .userAgent('MyApp/1.0')
///   .port(5060)
///   .enableVideo(true)
///   .build();
///
/// // Initialize and start
/// await endpoint.initialize();
/// final result = await endpoint.start(config);
///
/// // Listen for typed events
/// endpoint.events.callReceived.listen((call) {
///   print('Incoming call from: ${call.remoteNumber}');
/// });
///
/// // Make a call with builder
/// final call = await endpoint.calls.make(
///   account: account,
///   destination: '1234567890',
///   settings: CallSettings.builder().audio().build(),
/// );
/// ```

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

// Import existing types from tele_endpoint.dart
import 'tele_endpoint.dart' as legacy;

/// Result type for error handling
class Result<T> {
  final T? _value;
  final String? _error;
  final bool _isSuccess;

  Result._success(this._value)
      : _error = null,
        _isSuccess = true;

  Result._failure(this._error)
      : _value = null,
        _isSuccess = false;

  /// Create a successful result
  factory Result.success(T value) => Result._success(value);

  /// Create a failed result
  factory Result.failure(String error) => Result._failure(error);

  /// Check if result is successful
  bool get isSuccess => _isSuccess;

  /// Check if result is a failure
  bool get isFailure => !_isSuccess;

  /// Get the value (throws if failure)
  T get value {
    if (!_isSuccess) throw StateError('Cannot get value from failed result: $_error');
    return _value as T;
  }

  /// Get the error (throws if success)
  String get error {
    if (_isSuccess) throw StateError('Cannot get error from successful result');
    return _error!;
  }

  /// Get value or default
  T getOrElse(T defaultValue) => _isSuccess ? (_value as T) : defaultValue;

  /// Map the success value
  Result<R> map<R>(R Function(T) mapper) {
    if (_isSuccess) {
      return Result.success(mapper(_value as T));
    }
    return Result.failure(_error!);
  }

  /// Chain async operations
  Future<Result<R>> then<F extends Result<R>>(Future<F> Function(T) mapper) async {
    if (_isSuccess) {
      return mapper(_value as T);
    }
    return Result.failure(_error!);
  }

  @override
  String toString() => _isSuccess
      ? 'Result.success($_value)'
      : 'Result.failure($_error)';
}

/// Endpoint2 configuration with builder pattern
class Endpoint2Configuration {
  final String? userAgent;
  final int? port;
  final List<String>? stunServers;
  final Map<String, dynamic>? codecSettings;
  final bool? useVideo;
  final bool autoReconnect;
  final int maxReconnectAttempts;
  final Duration reconnectDelay;

  Endpoint2Configuration._({
    this.userAgent,
    this.port,
    this.stunServers,
    this.codecSettings,
    this.useVideo,
    this.autoReconnect = true,
    this.maxReconnectAttempts = 3,
    this.reconnectDelay = const Duration(seconds: 5),
  });

  /// Create configuration using builder
  factory Endpoint2Configuration.builder([void Function(Endpoint2ConfigurationBuilder)? configure]) {
    final builder = Endpoint2ConfigurationBuilder();
    configure?.call(builder);
    return builder.build();
  }

  /// Create from legacy configuration
  factory Endpoint2Configuration.fromLegacy(legacy.EndpointConfiguration config) {
    return Endpoint2Configuration._(
      userAgent: config.userAgent,
      port: config.port,
      stunServers: config.stunServers,
      codecSettings: config.codecSettings,
      useVideo: config.useVideo,
    );
  }

  /// Convert to legacy configuration
  legacy.EndpointConfiguration toLegacy() {
    return legacy.EndpointConfiguration(
      userAgent: userAgent,
      port: port,
      stunServers: stunServers,
      codecSettings: codecSettings,
      useVideo: useVideo,
    );
  }

  Map<String, dynamic> toMap() => toLegacy().toMap();
}

/// Builder for Endpoint2Configuration
class Endpoint2ConfigurationBuilder {
  String? _userAgent;
  int? _port;
  List<String>? _stunServers;
  Map<String, dynamic>? _codecSettings;
  bool? _useVideo;
  bool _autoReconnect = true;
  int _maxReconnectAttempts = 3;
  Duration _reconnectDelay = const Duration(seconds: 5);

  Endpoint2ConfigurationBuilder userAgent(String value) {
    _userAgent = value;
    return this;
  }

  Endpoint2ConfigurationBuilder port(int value) {
    _port = value;
    return this;
  }

  Endpoint2ConfigurationBuilder stunServers(List<String> value) {
    _stunServers = value;
    return this;
  }

  Endpoint2ConfigurationBuilder codecSettings(Map<String, dynamic> value) {
    _codecSettings = value;
    return this;
  }

  Endpoint2ConfigurationBuilder enableVideo(bool value) {
    _useVideo = value;
    return this;
  }

  Endpoint2ConfigurationBuilder autoReconnect(bool value) {
    _autoReconnect = value;
    return this;
  }

  Endpoint2ConfigurationBuilder maxReconnectAttempts(int value) {
    _maxReconnectAttempts = value;
    return this;
  }

  Endpoint2ConfigurationBuilder reconnectDelay(Duration value) {
    _reconnectDelay = value;
    return this;
  }

  Endpoint2Configuration build() {
    return Endpoint2Configuration._(
      userAgent: _userAgent,
      port: _port,
      stunServers: _stunServers,
      codecSettings: _codecSettings,
      useVideo: _useVideo,
      autoReconnect: _autoReconnect,
      maxReconnectAttempts: _maxReconnectAttempts,
      reconnectDelay: _reconnectDelay,
    );
  }
}

/// Typed event streams for Endpoint2
class Endpoint2Events {
  final StreamController<legacy.Account> _registrationChangedController =
      StreamController<legacy.Account>.broadcast();
  final StreamController<legacy.Call> _callReceivedController =
      StreamController<legacy.Call>.broadcast();
  final StreamController<legacy.Call> _callChangedController =
      StreamController<legacy.Call>.broadcast();
  final StreamController<legacy.Call> _callTerminatedController =
      StreamController<legacy.Call>.broadcast();
  final StreamController<legacy.Message> _messageReceivedController =
      StreamController<legacy.Message>.broadcast();
  final StreamController<bool> _connectivityChangedController =
      StreamController<bool>.broadcast();
  final StreamController<Endpoint2Error> _errorController =
      StreamController<Endpoint2Error>.broadcast();

  /// Registration status changed events
  Stream<legacy.Account> get registrationChanged => _registrationChangedController.stream;

  /// Incoming call events
  Stream<legacy.Call> get callReceived => _callReceivedController.stream;

  /// Call state changed events
  Stream<legacy.Call> get callChanged => _callChangedController.stream;

  /// Call terminated events
  Stream<legacy.Call> get callTerminated => _callTerminatedController.stream;

  /// Incoming message events
  Stream<legacy.Message> get messageReceived => _messageReceivedController.stream;

  /// Connectivity changed events
  Stream<bool> get connectivityChanged => _connectivityChangedController.stream;

  /// Error events
  Stream<Endpoint2Error> get error => _errorController.stream;

  /// Internal method to add registration changed event
  void _addRegistrationChanged(legacy.Account account) {
    if (!_registrationChangedController.isClosed) {
      _registrationChangedController.add(account);
    }
  }

  /// Internal method to add call received event
  void _addCallReceived(legacy.Call call) {
    if (!_callReceivedController.isClosed) {
      _callReceivedController.add(call);
    }
  }

  /// Internal method to add call changed event
  void _addCallChanged(legacy.Call call) {
    if (!_callChangedController.isClosed) {
      _callChangedController.add(call);
    }
  }

  /// Internal method to add call terminated event
  void _addCallTerminated(legacy.Call call) {
    if (!_callTerminatedController.isClosed) {
      _callTerminatedController.add(call);
    }
  }

  /// Internal method to add message received event
  void _addMessageReceived(legacy.Message message) {
    if (!_messageReceivedController.isClosed) {
      _messageReceivedController.add(message);
    }
  }

  /// Internal method to add connectivity changed event
  void _addConnectivityChanged(bool connected) {
    if (!_connectivityChangedController.isClosed) {
      _connectivityChangedController.add(connected);
    }
  }

  /// Internal method to add error event
  void _addError(Endpoint2Error error) {
    if (!_errorController.isClosed) {
      _errorController.add(error);
    }
  }

  /// Close all controllers
  void dispose() {
    _registrationChangedController.close();
    _callReceivedController.close();
    _callChangedController.close();
    _callTerminatedController.close();
    _messageReceivedController.close();
    _connectivityChangedController.close();
    _errorController.close();
  }
}

/// Endpoint2 error type
class Endpoint2Error {
  final String code;
  final String message;
  final String? details;
  final DateTime timestamp;

  Endpoint2Error({
    required this.code,
    required this.message,
    this.details,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();

  factory Endpoint2Error.fromPlatformException(PlatformException e) {
    return Endpoint2Error(
      code: e.code ?? 'UNKNOWN',
      message: e.message ?? 'Unknown platform error',
      details: e.details?.toString(),
    );
  }

  @override
  String toString() => 'Endpoint2Error($code): $message';
}

/// Call operations namespace
class Endpoint2CallOperations {
  final Endpoint2 _endpoint;
  final Logger _logger = Logger();

  Endpoint2CallOperations(this._endpoint);

  /// Make an outgoing call with builder pattern
  Future<Result<legacy.Call>> make({
    required legacy.Account account,
    required String destination,
    legacy.CallSettingsDTO? settings,
    Map<String, dynamic>? msgData,
  }) async {
    try {
      _logger.i('Endpoint2: Making call to $destination');

      final call = await _endpoint._methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'makeCall',
        {
          'accountId': account.id,
          'destination': destination,
          if (settings != null) 'callSettings': settings.toMap(),
          if (msgData != null) 'msgData': msgData,
        },
      );

      if (call == null) {
        return Result.failure('Null response from makeCall');
      }

      return Result.success(legacy.Call(call));
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to make call', error: e);
      return Result.failure('Failed to make call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error making call', error: e, stackTrace: stackTrace);
      return Result.failure('Error making call: $e');
    }
  }

  /// Answer an incoming call
  Future<Result<void>> answer(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Answering call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'answerCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to answer call', error: e);
      return Result.failure('Failed to answer call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error answering call', error: e, stackTrace: stackTrace);
      return Result.failure('Error answering call: $e');
    }
  }

  /// Hangup/end a call
  Future<Result<void>> hangup(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Hanging up call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'hangupCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to hangup call', error: e);
      return Result.failure('Failed to hangup call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error hanging up call', error: e, stackTrace: stackTrace);
      return Result.failure('Error hanging up call: $e');
    }
  }

  /// Hold a call
  Future<Result<void>> hold(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Holding call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'holdCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to hold call', error: e);
      return Result.failure('Failed to hold call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error holding call', error: e, stackTrace: stackTrace);
      return Result.failure('Error holding call: $e');
    }
  }

  /// Unhold a call
  Future<Result<void>> unhold(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Unholding call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'unholdCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to unhold call', error: e);
      return Result.failure('Failed to unhold call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error unholding call', error: e, stackTrace: stackTrace);
      return Result.failure('Error unholding call: $e');
    }
  }

  /// Mute a call
  Future<Result<void>> mute(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Muting call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'muteCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to mute call', error: e);
      return Result.failure('Failed to mute call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error muting call', error: e, stackTrace: stackTrace);
      return Result.failure('Error muting call: $e');
    }
  }

  /// Unmute a call
  Future<Result<void>> unmute(legacy.Call call) async {
    try {
      _logger.i('Endpoint2: Unmuting call ${call.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'unmuteCall',
        {'callId': call.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to unmute call', error: e);
      return Result.failure('Failed to unmute call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error unmuting call', error: e, stackTrace: stackTrace);
      return Result.failure('Error unmuting call: $e');
    }
  }

  /// Transfer a call
  Future<Result<void>> transfer(legacy.Call call, String target) async {
    try {
      _logger.i('Endpoint2: Transferring call ${call.id} to $target');

      await _endpoint._methodChannel.invokeMethod<void>(
        'xferCall',
        {
          'callId': call.id,
          'target': target,
        },
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to transfer call', error: e);
      return Result.failure('Failed to transfer call: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error transferring call', error: e, stackTrace: stackTrace);
      return Result.failure('Error transferring call: $e');
    }
  }

  /// Send DTMF tone
  Future<Result<void>> dtmf(legacy.Call call, String digits) async {
    try {
      _logger.i('Endpoint2: Sending DTMF to call ${call.id}: $digits');

      await _endpoint._methodChannel.invokeMethod<void>(
        'dtmfCall',
        {
          'callId': call.id,
          'digits': digits,
        },
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to send DTMF', error: e);
      return Result.failure('Failed to send DTMF: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error sending DTMF', error: e, stackTrace: stackTrace);
      return Result.failure('Error sending DTMF: $e');
    }
  }
}

/// Account operations namespace
class Endpoint2AccountOperations {
  final Endpoint2 _endpoint;
  final Logger _logger = Logger();

  Endpoint2AccountOperations(this._endpoint);

  /// Create a new SIP account
  Future<Result<legacy.Account>> create(legacy.AccountConfiguration config) async {
    try {
      _logger.i('Endpoint2: Creating account for ${config.username}@${config.domain}');

      final result = await _endpoint._methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'createAccount',
        config.toMap(),
      );

      if (result == null) {
        return Result.failure('Null response from createAccount');
      }

      return Result.success(legacy.Account(result));
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to create account', error: e);
      return Result.failure('Failed to create account: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error creating account', error: e, stackTrace: stackTrace);
      return Result.failure('Error creating account: $e');
    }
  }

  /// Register an account
  Future<Result<void>> register(legacy.Account account, {bool renew = true}) async {
    try {
      _logger.i('Endpoint2: Registering account ${account.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'registerAccount',
        {
          'accountId': account.id,
          'renew': renew,
        },
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to register account', error: e);
      return Result.failure('Failed to register account: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error registering account', error: e, stackTrace: stackTrace);
      return Result.failure('Error registering account: $e');
    }
  }

  /// Unregister an account
  Future<Result<void>> unregister(legacy.Account account) async {
    try {
      _logger.i('Endpoint2: Unregistering account ${account.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'unregisterAccount',
        {'accountId': account.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to unregister account', error: e);
      return Result.failure('Failed to unregister account: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error unregistering account', error: e, stackTrace: stackTrace);
      return Result.failure('Error unregistering account: $e');
    }
  }

  /// Delete an account
  Future<Result<void>> delete(legacy.Account account) async {
    try {
      _logger.i('Endpoint2: Deleting account ${account.id}');

      await _endpoint._methodChannel.invokeMethod<void>(
        'deleteAccount',
        {'accountId': account.id},
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to delete account', error: e);
      return Result.failure('Failed to delete account: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error deleting account', error: e, stackTrace: stackTrace);
      return Result.failure('Error deleting account: $e');
    }
  }

  /// Replace/update an account configuration
  Future<Result<legacy.Account>> replace(
    legacy.Account account,
    legacy.AccountConfiguration config,
  ) async {
    try {
      _logger.i('Endpoint2: Replacing account ${account.id} configuration');

      final result = await _endpoint._methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'replaceAccount',
        {
          'accountId': account.id,
          'configuration': config.toMap(),
        },
      );

      if (result == null) {
        return Result.failure('Null response from replaceAccount');
      }

      return Result.success(legacy.Account(result));
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to replace account', error: e);
      return Result.failure('Failed to replace account: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error replacing account', error: e, stackTrace: stackTrace);
      return Result.failure('Error replacing account: $e');
    }
  }
}

/// Endpoint2 state
enum Endpoint2State {
  /// Endpoint not yet initialized
  idle,

  /// Endpoint initialized but not started
  initialized,

  /// Endpoint started and operational
  running,

  /// Endpoint reconnecting
  reconnecting,

  /// Endpoint stopped or error occurred
  stopped,
}

/// Next-Generation SIP Endpoint with improved API
///
/// Endpoint2 provides the same functionality as TeleEndpoint but with:
/// - Result-based error handling instead of exceptions
/// - Typed event streams instead of dynamic streams
/// - Builder pattern for configuration
/// - Namespaced operations (calls, accounts, messages)
/// - Better state management
/// - Automatic reconnection support
///
/// See also:
/// - [TeleEndpoint] for the legacy endpoint implementation
/// - [Endpoint2Configuration] for configuration options
/// - [Endpoint2Events] for typed event streams
class Endpoint2 {
  static const MethodChannel _methodChannel = MethodChannel('flutter_pjsip');
  static const EventChannel _eventChannel = EventChannel('flutter_pjsip_events');

  final Logger _logger = Logger();

  // State
  Endpoint2State _state = Endpoint2State.idle;
  bool _isInitialized = false;
  bool _isStarted = false;
  Endpoint2Configuration? _configuration;
  int _reconnectAttempts = 0;

  // Event handling
  StreamSubscription<dynamic>? _eventSubscription;
  final Endpoint2Events _events = Endpoint2Events();

  // Operations namespaces
  late final Endpoint2CallOperations calls;
  late final Endpoint2AccountOperations accounts;

  // Getters
  Endpoint2State get state => _state;
  bool get isInitialized => _isInitialized;
  bool get isStarted => _isStarted;
  bool get isRunning => _state == Endpoint2State.running;
  bool get isReconnecting => _state == Endpoint2State.reconnecting;
  Endpoint2Configuration? get configuration => _configuration;
  Endpoint2Events get events => _events;

  /// Create Endpoint2 instance
  Endpoint2() {
    calls = Endpoint2CallOperations(this);
    accounts = Endpoint2AccountOperations(this);
  }

  /// Initialize the endpoint
  ///
  /// Sets up event channel and prepares the endpoint for use.
  /// Call [start] after initialization to begin SIP operations.
  Future<Result<void>> initialize() async {
    if (_isInitialized) {
      _logger.w('Endpoint2 already initialized');
      return Result.success(null);
    }

    try {
      _logger.i('Endpoint2: Initializing...');
      await _setupEventChannel();
      _isInitialized = true;
      _state = Endpoint2State.initialized;
      _logger.i('Endpoint2: Initialized successfully');
      return Result.success(null);
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Failed to initialize', error: e, stackTrace: stackTrace);
      _state = Endpoint2State.stopped;
      return Result.failure('Failed to initialize: $e');
    }
  }

  /// Setup EventChannel listener
  Future<void> _setupEventChannel() async {
    _logger.d('Endpoint2: Setting up event channel');

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _handleEvent(event);
      },
      onError: (dynamic error) {
        _logger.e('Endpoint2: EventChannel error', error: error);
        _events._addError(Endpoint2Error(
          code: 'CHANNEL_ERROR',
          message: error.toString(),
        ));
      },
      onDone: () {
        _logger.w('Endpoint2: EventChannel stream closed');
        if (_configuration?.autoReconnect == true && _isStarted) {
          _handleReconnection();
        }
      },
      cancelOnError: false,
    );
  }

  /// Handle incoming event from native code
  void _handleEvent(dynamic event) {
    try {
      if (event is Map) {
        final eventMap = event.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );

        final eventType = eventMap['type'] as String?;
        final eventData = eventMap['data'];

        if (eventType == null || eventData == null) {
          return;
        }

        _routeEvent(eventType, eventData);
      }
    } catch (error, stackTrace) {
      _logger.e('Endpoint2: Error handling event', error: error, stackTrace: stackTrace);
    }
  }

  /// Route event to appropriate handler
  void _routeEvent(String eventType, dynamic eventData) {
    try {
      if (eventData is Map) {
        final dataMap = eventData.map<String, dynamic>(
          (key, value) => MapEntry(key.toString(), value),
        );

        switch (eventType) {
          case 'registration_changed':
            _events._addRegistrationChanged(legacy.Account(dataMap));
            break;
          case 'call_received':
            _events._addCallReceived(legacy.Call(dataMap));
            break;
          case 'call_changed':
            _events._addCallChanged(legacy.Call(dataMap));
            break;
          case 'call_terminated':
            _events._addCallTerminated(legacy.Call(dataMap));
            break;
          case 'message_received':
            _events._addMessageReceived(legacy.Message(dataMap));
            break;
          case 'connectivity_changed':
            _events._addConnectivityChanged(eventData as bool? ?? false);
            break;
          default:
            _logger.d('Endpoint2: Unknown event type: $eventType');
        }
      }
    } catch (error, stackTrace) {
      _logger.e('Endpoint2: Error routing event', error: error, stackTrace: stackTrace);
    }
  }

  /// Handle reconnection logic
  Future<void> _handleReconnection() async {
    if (_reconnectAttempts >= (_configuration?.maxReconnectAttempts ?? 3)) {
      _logger.e('Endpoint2: Max reconnection attempts reached');
      _events._addError(Endpoint2Error(
        code: 'MAX_RECONNECT_ATTEMPTS',
        message: 'Failed to reconnect after ${_reconnectAttempts} attempts',
      ));
      _state = Endpoint2State.stopped;
      return;
    }

    _state = Endpoint2State.reconnecting;
    _reconnectAttempts++;

    _logger.i('Endpoint2: Reconnecting (attempt $_reconnectAttempts)...');

    await Future.delayed(_configuration?.reconnectDelay ?? const Duration(seconds: 5));

    try {
      await _setupEventChannel();
      _reconnectAttempts = 0;
      _state = Endpoint2State.running;
      _logger.i('Endpoint2: Reconnected successfully');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Reconnection failed', error: e, stackTrace: stackTrace);
      _handleReconnection();
    }
  }

  /// Start the endpoint with configuration
  ///
  /// Initializes the PjSIP stack and returns existing accounts and calls.
  Future<Result<legacy.StartResult>> start([Endpoint2Configuration? config]) async {
    if (!_isInitialized) {
      return Result.failure('Endpoint not initialized. Call initialize() first.');
    }

    try {
      _configuration = config;
      _logger.i('Endpoint2: Starting endpoint...');

      final legacyConfig = config?.toLegacy() ?? legacy.EndpointConfiguration();
      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'start',
        legacyConfig.toMap(),
      );

      if (result == null) {
        return Result.failure('Null response from start');
      }

      final startResult = legacy.StartResult.fromMap(result);
      _isStarted = true;
      _state = Endpoint2State.running;
      _reconnectAttempts = 0;

      _logger.i('Endpoint2: Started with ${startResult.accounts.length} accounts, ${startResult.calls.length} calls');

      return Result.success(startResult);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to start', error: e);
      return Result.failure('Failed to start: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error starting', error: e, stackTrace: stackTrace);
      return Result.failure('Error starting: $e');
    }
  }

  /// Stop the endpoint
  Future<Result<void>> stop() async {
    try {
      _logger.i('Endpoint2: Stopping endpoint...');

      await _methodChannel.invokeMethod<void>('stop', {});

      _isStarted = false;
      _state = Endpoint2State.stopped;
      _reconnectAttempts = 0;

      _logger.i('Endpoint2: Stopped successfully');
      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to stop', error: e);
      return Result.failure('Failed to stop: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error stopping', error: e, stackTrace: stackTrace);
      return Result.failure('Error stopping: $e');
    }
  }

  /// Send a SIP message
  Future<Result<void>> sendMessage({
    required legacy.Account account,
    required String recipient,
    required String body,
    String? contentType,
  }) async {
    try {
      _logger.i('Endpoint2: Sending message to $recipient');

      await _methodChannel.invokeMethod<void>(
        'sendMessage',
        {
          'accountId': account.id,
          'recipient': recipient,
          'body': body,
          if (contentType != null) 'contentType': contentType,
        },
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to send message', error: e);
      return Result.failure('Failed to send message: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error sending message', error: e, stackTrace: stackTrace);
      return Result.failure('Error sending message: $e');
    }
  }

  /// Send typing indicator
  Future<Result<void>> sendTyping({
    required legacy.Account account,
    required String recipient,
    required bool isTyping,
  }) async {
    try {
      _logger.i('Endpoint2: Sending typing indicator to $recipient: $isTyping');

      await _methodChannel.invokeMethod<void>(
        'sendTyping',
        {
          'accountId': account.id,
          'recipient': recipient,
          'isTyping': isTyping,
        },
      );

      return Result.success(null);
    } on PlatformException catch (e) {
      _logger.e('Endpoint2: Failed to send typing indicator', error: e);
      return Result.failure('Failed to send typing: ${e.message}');
    } catch (e, stackTrace) {
      _logger.e('Endpoint2: Error sending typing', error: e, stackTrace: stackTrace);
      return Result.failure('Error sending typing: $e');
    }
  }

  /// Clean up resources
  void dispose() {
    _logger.i('Endpoint2: Disposing...');

    _eventSubscription?.cancel();
    _events.dispose();
    _isInitialized = false;
    _isStarted = false;
    _state = Endpoint2State.stopped;
  }
}
