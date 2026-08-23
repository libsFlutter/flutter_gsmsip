/// Endpoint Module - Primary PjSIP Interface
/// Provides EventEmitter-based SIP endpoint with account/call management
///
/// Source: sdd-endpoint specification
/// Tasks: endpoint-001 through endpoint-008

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Account registration status
class AccountRegistration {
  final String? status;
  final String? statusText;
  final bool isActive;
  final String? reason;

  const AccountRegistration({
    this.status,
    this.statusText,
    this.isActive = false,
    this.reason,
  });

  factory AccountRegistration.fromMap(Map<dynamic, dynamic> map) {
    return AccountRegistration(
      status: map['status'] as String?,
      statusText: map['statusText'] as String?,
      isActive: map['isActive'] as bool? ?? false,
      reason: map['reason'] as String?,
    );
  }
}

/// SIP Account representation
class Account {
  final Map<dynamic, dynamic> _data;

  Account(this._data);

  int get id => _data['id'] as int? ?? 0;
  String get uri => _data['uri'] as String? ?? '';
  String get name => _data['name'] as String? ?? '';
  String get username => _data['username'] as String? ?? '';
  String? get domain => _data['domain'] as String?;
  String get password => _data['password'] as String? ?? '';
  String get proxy => _data['proxy'] as String? ?? '';
  String get transport => _data['transport'] as String? ?? '';
  String get contactParams => _data['contactParams'] as String? ?? '';
  String get contactUriParams => _data['contactUriParams'] as String? ?? '';
  String get regServer => _data['regServer'] as String? ?? '';
  String get regTimeout => _data['regTimeout'] as String? ?? '';
  String get regContactParams => _data['regContactParams'] as String? ?? '';
  Map<dynamic, dynamic> get regHeaders => _data['regHeaders'] as Map<dynamic, dynamic>? ?? {};

  AccountRegistration getRegistration() {
    final regData = _data['registration'] as Map<dynamic, dynamic>?;
    if (regData != null) {
      return AccountRegistration.fromMap(regData);
    }
    return const AccountRegistration(isActive: false);
  }

  Map<dynamic, dynamic> toMap() => _data;
}

/// Call states matching PJSIP constants
class CallState {
  static const String nullState = 'PJSIP_INV_STATE_NULL';
  static const String calling = 'PJSIP_INV_STATE_CALLING';
  static const String incoming = 'PJSIP_INV_STATE_INCOMING';
  static const String early = 'PJSIP_INV_STATE_EARLY';
  static const String connecting = 'PJSIP_INV_STATE_CONNECTING';
  static const String confirmed = 'PJSIP_INV_STATE_CONFIRMED';
  static const String disconnected = 'PJSIP_INV_STATE_DISCONNECTED';
}

/// SIP Call representation
class Call {
  final Map<dynamic, dynamic> _data;

  Call(this._data);

  int get id => _data['id'] as int? ?? 0;
  int get accountId => _data['accountId'] as int? ?? 0;
  String get callId => _data['callId'] as String? ?? '';
  String get localContact => _data['localContact'] as String? ?? '';
  String get localUri => _data['localUri'] as String? ?? '';
  String get remoteContact => _data['remoteContact'] as String? ?? '';
  String get remoteUri => _data['remoteUri'] as String? ?? '';
  String? get remoteName => _data['remoteName'] as String?;
  String? get remoteNumber => _data['remoteNumber'] as String?;
  String get remoteFormattedNumber => _data['remoteFormattedNumber'] as String? ?? '';
  String get state => _data['state'] as String? ?? CallState.nullState;
  String get stateText => _data['stateText'] as String? ?? '';
  bool get isHeld => _data['held'] as bool? ?? false;
  bool get isMuted => _data['muted'] as bool? ?? false;
  bool get isSpeaker => _data['speaker'] as bool? ?? false;
  bool get isTerminated => _data['terminated'] as bool? ?? false;
  bool get remoteOfferer => _data['remoteOfferer'] as bool? ?? false;
  int get remoteAudioCount => _data['remoteAudioCount'] as int? ?? 0;
  int get remoteVideoCount => _data['remoteVideoCount'] as int? ?? 0;
  int get audioCount => _data['audioCount'] as int? ?? 0;
  int get videoCount => _data['videoCount'] as int? ?? 0;
  String get lastStatusCode => _data['lastStatusCode'] as String? ?? '';
  String get lastReason => _data['lastReason'] as String? ?? '';
  Map<dynamic, dynamic> get media => _data['media'] as Map<dynamic, dynamic>? ?? {};
  Map<dynamic, dynamic> get provisionalMedia => _data['provisionalMedia'] as Map<dynamic, dynamic>? ?? {};

  /// Calculate total duration from call start
  int getTotalDuration() {
    final startTime = _data['startTime'] as int?;
    if (startTime == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - startTime;
  }

  /// Calculate connect duration (when call was answered)
  int getConnectDuration() {
    final connectTime = _data['connectTime'] as int?;
    if (connectTime == null) return 0;
    return DateTime.now().millisecondsSinceEpoch - connectTime;
  }

  /// Format duration as MM:SS
  String getFormattedTotalDuration() {
    return _formatTime(getTotalDuration());
  }

  /// Format connect duration as MM:SS
  String getFormattedConnectDuration() {
    return _formatTime(getConnectDuration());
  }

  String _formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).round();
    final mins = (seconds ~/ 60) % 60;
    final secs = seconds % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Map<dynamic, dynamic> toMap() => _data;
}

/// Message representation for SIP messaging
class Message {
  final Map<dynamic, dynamic> _data;

  Message(this._data);

  int get accountId => _data['accountId'] as int? ?? 0;
  String get contactUri => _data['contactUri'] as String? ?? '';
  String get fromUri => _data['fromUri'] as String? ?? '';
  String? get fromName => _data['fromName'] as String?;
  String? get fromNumber => _data['fromNumber'] as String?;
  String get toUri => _data['toUri'] as String? ?? '';
  String? get body => _data['body'] as String?;
  String? get contentType => _data['contentType'] as String?;

  Map<dynamic, dynamic> toMap() => _data;
}

/// Call settings for making calls
class CallSettingsDTO {
  final int flag;
  final int reqKeyframeMethod;
  final int audCnt;
  final int vidCnt;

  const CallSettingsDTO({
    this.flag = 0,
    this.reqKeyframeMethod = 0,
    this.audCnt = 1,
    this.vidCnt = 0,
  });

  Map<String, dynamic> toMap() => {
    'flag': flag,
    'req_keyframe_method': reqKeyframeMethod,
    'aud_cnt': audCnt,
    'vid_cnt': vidCnt,
  };

  factory CallSettingsDTO.fromMap(Map<String, dynamic> map) {
    return CallSettingsDTO(
      flag: map['flag'] as int? ?? 0,
      reqKeyframeMethod: map['req_keyframe_method'] as int? ?? 0,
      audCnt: map['aud_cnt'] as int? ?? 1,
      vidCnt: map['vid_cnt'] as int? ?? 0,
    );
  }
}

/// Account configuration for creating accounts
class AccountConfiguration {
  final String name;
  final String username;
  final String domain;
  final String password;
  final String? proxy;
  final String? transport;
  final String? regServer;
  final int? regTimeout;
  final String? contactParams;
  final String? contactUriParams;
  final String? regContactParams;
  final Map<String, dynamic> regHeaders;

  AccountConfiguration({
    required this.name,
    required this.username,
    required this.domain,
    required this.password,
    this.proxy,
    this.transport,
    this.regServer,
    this.regTimeout,
    this.contactParams,
    this.contactUriParams,
    this.regContactParams,
    this.regHeaders = const {},
  });

  Map<String, dynamic> toMap() => {
    'name': name,
    'username': username,
    'domain': domain,
    'password': password,
    if (proxy != null) 'proxy': proxy,
    if (transport != null) 'transport': transport,
    if (regServer != null) 'regServer': regServer,
    if (regTimeout != null) 'regTimeout': regTimeout,
    if (contactParams != null) 'contactParams': contactParams,
    if (contactUriParams != null) 'contactUriParams': contactUriParams,
    if (regContactParams != null) 'regContactParams': regContactParams,
    'regHeaders': regHeaders,
  };
}

/// Endpoint configuration for start()
class EndpointConfiguration {
  final String? userAgent;
  final int? port;
  final List<String>? stunServers;
  final Map<String, dynamic>? codecSettings;
  final bool? useVideo;

  const EndpointConfiguration({
    this.userAgent,
    this.port,
    this.stunServers,
    this.codecSettings,
    this.useVideo,
  });

  Map<String, dynamic> toMap() => {
    if (userAgent != null) 'userAgent': userAgent,
    if (port != null) 'port': port,
    if (stunServers != null) 'stunServers': stunServers,
    if (codecSettings != null) 'codecSettings': codecSettings,
    if (useVideo != null) 'useVideo': useVideo,
  };
}

/// Event types for endpoint
class EndpointEventType {
  static const String registrationChanged = 'registration_changed';
  static const String callReceived = 'call_received';
  static const String callChanged = 'call_changed';
  static const String callTerminated = 'call_terminated';
  static const String callScreenLocked = 'call_screen_locked';
  static const String messageReceived = 'message_received';
  static const String connectivityChanged = 'connectivity_changed';
}

/// Start result from endpoint initialization
class StartResult {
  final List<Account> accounts;
  final List<Call> calls;
  final Map<String, dynamic> extra;

  const StartResult({
    required this.accounts,
    required this.calls,
    this.extra = const {},
  });

  factory StartResult.fromMap(Map<dynamic, dynamic> data) {
    final accountsData = data['accounts'] as List<dynamic>?;
    final callsData = data['calls'] as List<dynamic>?;

    final accounts = accountsData
        ?.map((d) => Account(d as Map<dynamic, dynamic>))
        .toList() ?? [];

    final calls = callsData
        ?.map((d) => Call(d as Map<dynamic, dynamic>))
        .toList() ?? [];

    final extra = Map<String, dynamic>.fromEntries(
      data.entries
          .where((e) => e.key != 'accounts' && e.key != 'calls')
          .map((e) => MapEntry(e.key.toString(), e.value)),
    );

    return StartResult(accounts: accounts, calls: calls, extra: extra);
  }
}

/// TeleEndpoint - Primary PjSIP interface with EventEmitter pattern
///
/// Provides full SIP endpoint functionality including:
/// - Account management (create, register, delete, replace)
/// - Call management (make, answer, hangup, hold, mute, transfer, redirect, dtmf)
/// - Messaging (send message, typing indicator)
/// - Event streaming (registration, call, message, connectivity events)
///
/// Usage:
/// ```dart
/// final endpoint = TeleEndpoint();
/// await endpoint.initialize();
///
/// // Listen for events
/// endpoint.on(EndpointEventType.callReceived).listen((call) {
///   print('Incoming call: ${call.remoteNumber}');
/// });
///
/// // Start endpoint
/// final result = await endpoint.start(EndpointConfiguration());
///
/// // Create account
/// final account = await endpoint.createAccount(AccountConfiguration(
///   name: 'Main Account',
///   username: '1001',
///   domain: 'sip.example.com',
///   password: 'secret',
/// ));
/// ```
class TeleEndpoint {
  static const MethodChannel _methodChannel = MethodChannel('flutter_pjsip');
  static const EventChannel _eventChannel = EventChannel('flutter_pjsip_events');

  final Logger _logger = Logger();

  StreamSubscription<dynamic>? _eventSubscription;
  final Map<String, StreamController<dynamic>> _eventControllers = {};

  bool _isInitialized = false;
  bool _isStarted = false;

  /// Initialize the endpoint and set up event listeners
  Future<void> initialize() async {
    if (_isInitialized) {
      _logger.w('TeleEndpoint already initialized');
      return;
    }

    try {
      _logger.i('TeleEndpoint: Setting up event channel');
      await _setupEventChannel();
      _isInitialized = true;
      _logger.i('TeleEndpoint: Event channel initialized successfully');
    } catch (error, stackTrace) {
      _logger.e('TeleEndpoint: Failed to initialize event channel',
                error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Setup EventChannel listener for native events
  Future<void> _setupEventChannel() async {
    _logger.d('TeleEndpoint: Subscribing to event channel');

    _eventSubscription = _eventChannel.receiveBroadcastStream().listen(
      (dynamic event) {
        _logger.d('TeleEndpoint: Received event from native: $event');
        _handleEvent(event);
      },
      onError: (dynamic error) {
        _logger.e('TeleEndpoint: EventChannel error', error: error);
        _handleError('channel_error', error.toString());
      },
      onDone: () {
        _logger.w('TeleEndpoint: EventChannel stream closed');
        _isInitialized = false;
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
        final eventData = eventMap['data'] as dynamic;

        _logger.d('TeleEndpoint: Event type: $eventType, data: $eventData');

        if (eventType == null) {
          _logger.w('TeleEndpoint: Event missing type field');
          return;
        }

        _routeEvent(eventType, eventData);
      } else {
        _logger.w('TeleEndpoint: Event is not a Map: ${event.runtimeType}');
      }
    } catch (error, stackTrace) {
      _logger.e('TeleEndpoint: Error handling event', error: error, stackTrace: stackTrace);
    }
  }

  /// Route event to the appropriate stream controller
  void _routeEvent(String eventType, dynamic eventData) {
    if (!_eventControllers.containsKey(eventType)) {
      _logger.d('TeleEndpoint: Creating controller for event type: $eventType');
      _eventControllers[eventType] = StreamController<dynamic>.broadcast(
        onCancel: () {
          _logger.d('TeleEndpoint: All listeners unsubscribed from $eventType');
        },
      );
    }

    final controller = _eventControllers[eventType];
    if (controller != null && !controller.isClosed) {
      controller.add(eventData);
      _logger.d('TeleEndpoint: Event routed to $eventType controller');
    } else {
      _logger.w('TeleEndpoint: Controller for $eventType is closed');
    }
  }

  /// Handle error events
  void _handleError(String errorType, String errorMessage) {
    final errorData = {
      'type': errorType,
      'message': errorMessage,
      'timestamp': DateTime.now().toIso8601String(),
    };

    if (_eventControllers.containsKey(EndpointEventType.callError)) {
      _eventControllers[EndpointEventType.callError]!.add(errorData);
    }

    _logger.e('TeleEndpoint: Error event', error: errorData);
  }

  // ============================================================================
  // TASK endpoint-002: Implement start() method
  // ============================================================================

  /// Start the endpoint with configuration
  ///
  /// Initializes the PjSIP stack and returns existing accounts and calls
  Future<StartResult> start(EndpointConfiguration configuration) async {
    try {
      _logger.i('TeleEndpoint: Starting endpoint with configuration: $configuration');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'start',
        configuration.toMap(),
      );

      if (result == null) {
        throw Exception('Failed to start endpoint - null response');
      }

      final startResult = StartResult.fromMap(result);
      _isStarted = true;
      _logger.i('TeleEndpoint: Endpoint started successfully with ${startResult.accounts.length} accounts and ${startResult.calls.length} calls');

      return startResult;
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to start endpoint', error: e);
      throw Exception('Failed to start endpoint: ${e.message}');
    }
  }

  // ============================================================================
  // TASK endpoint-003: Implement account methods
  // ============================================================================

  /// Create a new SIP account
  ///
  /// [configuration] - Account configuration with credentials and settings
  /// Returns the created Account instance
  Future<Account> createAccount(AccountConfiguration configuration) async {
    try {
      _logger.i('TeleEndpoint: Creating account for ${configuration.username}@${configuration.domain}');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'createAccount',
        configuration.toMap(),
      );

      if (result == null) {
        throw Exception('Failed to create account - null response');
      }

      final account = Account(result);
      _logger.i('TeleEndpoint: Account created with ID: ${account.id}');

      return account;
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to create account', error: e);
      throw Exception('Failed to create account: ${e.message}');
    }
  }

  /// Register an account with the SIP server
  ///
  /// [account] - The account to register
  /// [renew] - If true, renews existing registration (default: true)
  Future<void> registerAccount(Account account, {bool renew = true}) async {
    try {
      _logger.i('TeleEndpoint: Registering account ${account.id}, renew: $renew');

      await _methodChannel.invokeMethod<void>(
        'registerAccount',
        {
          'accountId': account.id,
          'renew': renew,
        },
      );

      _logger.i('TeleEndpoint: Account registered successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to register account', error: e);
      throw Exception('Failed to register account: ${e.message}');
    }
  }

  /// Delete an account
  ///
  /// [account] - The account to delete
  Future<void> deleteAccount(Account account) async {
    try {
      _logger.i('TeleEndpoint: Deleting account ${account.id}');

      await _methodChannel.invokeMethod<void>(
        'deleteAccount',
        {'accountId': account.id},
      );

      _logger.i('TeleEndpoint: Account deleted successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to delete account', error: e);
      throw Exception('Failed to delete account: ${e.message}');
    }
  }

  // ============================================================================
  // TASK endpoint-008: Implement replaceAccount() method
  // ============================================================================

  /// Replace an account's configuration
  ///
  /// [account] - The account to update
  /// [configuration] - New account configuration
  /// Returns the updated Account instance
  Future<Account> replaceAccount(Account account, AccountConfiguration configuration) async {
    try {
      _logger.i('TeleEndpoint: Replacing account ${account.id} configuration');

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'replaceAccount',
        {
          'accountId': account.id,
          'configuration': configuration.toMap(),
        },
      );

      if (result == null) {
        throw Exception('Failed to replace account - null response');
      }

      final updatedAccount = Account(result);
      _logger.i('TeleEndpoint: Account replaced successfully');

      return updatedAccount;
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to replace account', error: e);
      throw Exception('Failed to replace account: ${e.message}');
    }
  }

  // ============================================================================
  // TASK endpoint-004: Implement call methods
  // ============================================================================

  /// Normalize destination to SIP URI
  String _normalize(Account account, String destination) {
    if (!destination.startsWith('sip:')) {
      String realm = account.regServer.isNotEmpty ? account.regServer : account.domain ?? '';
      int s = realm.indexOf(':');
      if (s > 0) {
        realm = realm.substring(0, s + 1);
      }
      destination = 'sip:$destination@$realm';
    }
    return destination;
  }

  /// Make an outgoing call
  ///
  /// [account] - Account to use for the call
  /// [destination] - Destination number or SIP URI
  /// [callSettings] - Optional call settings (audio/video streams)
  /// [msgData] - Optional message data for INVITE body
  Future<Call> makeCall(
    Account account,
    String destination, {
    CallSettingsDTO? callSettings,
    Map<String, dynamic>? msgData,
  }) async {
    try {
      final normalizedDestination = _normalize(account, destination);
      _logger.i('TeleEndpoint: Making call to $normalizedDestination');

      final args = <String, dynamic>{
        'accountId': account.id,
        'destination': normalizedDestination,
        if (callSettings != null) 'callSettings': callSettings.toMap(),
        if (msgData != null) 'msgData': msgData,
      };

      final result = await _methodChannel.invokeMethod<Map<dynamic, dynamic>>(
        'makeCall',
        args,
      );

      if (result == null) {
        throw Exception('Failed to make call - null response');
      }

      final call = Call(result);
      _logger.i('TeleEndpoint: Call created with ID: ${call.id}');

      return call;
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to make call', error: e);
      throw Exception('Failed to make call: ${e.message}');
    }
  }

  /// Answer an incoming call
  Future<void> answerCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Answering call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'answerCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call answered successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to answer call', error: e);
      throw Exception('Failed to answer call: ${e.message}');
    }
  }

  /// Hangup/end a call
  Future<void> hangupCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Hanging up call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'hangupCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call hung up successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to hangup call', error: e);
      throw Exception('Failed to hangup call: ${e.message}');
    }
  }

  /// Decline an incoming call with 603 Decline response
  ///
  /// [call] - The incoming call to decline
  Future<void> declineCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Declining call ${call.id} with 603 Decline');

      await _methodChannel.invokeMethod<void>(
        'declineCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call declined successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to decline call', error: e);
      throw Exception('Failed to decline call: ${e.message}');
    }
  }

  /// Hold a call
  Future<void> holdCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Holding call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'holdCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call held successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to hold call', error: e);
      throw Exception('Failed to hold call: ${e.message}');
    }
  }

  /// Unhold/resume a call
  Future<void> unholdCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Unholding call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'unholdCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call unheld successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to unhold call', error: e);
      throw Exception('Failed to unhold call: ${e.message}');
    }
  }

  /// Mute a call
  Future<void> muteCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Muting call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'muteCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call muted successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to mute call', error: e);
      throw Exception('Failed to mute call: ${e.message}');
    }
  }

  /// Unmute a call
  Future<void> unmuteCall(Call call) async {
    try {
      _logger.i('TeleEndpoint: Unmuting call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'unmuteCall',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Call unmuted successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to unmute call', error: e);
      throw Exception('Failed to unmute call: ${e.message}');
    }
  }

  /// Use speaker for call audio
  Future<void> useSpeaker(Call call) async {
    try {
      _logger.i('TeleEndpoint: Using speaker for call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'useSpeaker',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Speaker enabled successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to use speaker', error: e);
      throw Exception('Failed to use speaker: ${e.message}');
    }
  }

  /// Use earpiece for call audio
  Future<void> useEarpiece(Call call) async {
    try {
      _logger.i('TeleEndpoint: Using earpiece for call ${call.id}');

      await _methodChannel.invokeMethod<void>(
        'useEarpiece',
        {'callId': call.id},
      );

      _logger.i('TeleEndpoint: Earpiece enabled successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to use earpiece', error: e);
      throw Exception('Failed to use earpiece: ${e.message}');
    }
  }

  /// Transfer a call (blind transfer)
  ///
  /// [account] - Account to use for transfer
  /// [call] - Call to transfer
  /// [destination] - Destination to transfer to
  Future<void> transferCall(Account account, Call call, String destination) async {
    try {
      final normalizedDestination = _normalize(account, destination);
      _logger.i('TeleEndpoint: Transferring call ${call.id} to $normalizedDestination');

      await _methodChannel.invokeMethod<void>(
        'transferCall',
        {
          'accountId': account.id,
          'callId': call.id,
          'destination': normalizedDestination,
        },
      );

      _logger.i('TeleEndpoint: Call transferred successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to transfer call', error: e);
      throw Exception('Failed to transfer call: ${e.message}');
    }
  }

  /// Transfer a call with replacement (attended transfer)
  ///
  /// Transfers [call] to replace [destCall] - used for attended transfers
  /// where you have two calls and want to connect the parties and drop out.
  ///
  /// [call] - Call to transfer
  /// [destCall] - Destination call to replace
  Future<void> xferReplacesCall(Call call, Call destCall) async {
    try {
      _logger.i('TeleEndpoint: Transferring call ${call.id} to replace ${destCall.id}');

      await _methodChannel.invokeMethod<void>(
        'xferReplacesCall',
        {
          'callId': call.id,
          'destCallId': destCall.id,
        },
      );

      _logger.i('TeleEndpoint: Call transferred with replacement successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to transfer call with replacement', error: e);
      throw Exception('Failed to transfer call with replacement: ${e.message}');
    }
  }

  /// Redirect/forward an incoming call
  ///
  /// [account] - Account receiving the call
  /// [call] - Call to redirect
  /// [destination] - Destination to forward to
  Future<void> redirectCall(Account account, Call call, String destination) async {
    try {
      final normalizedDestination = _normalize(account, destination);
      _logger.i('TeleEndpoint: Redirecting call ${call.id} to $normalizedDestination');

      await _methodChannel.invokeMethod<void>(
        'redirectCall',
        {
          'accountId': account.id,
          'callId': call.id,
          'destination': normalizedDestination,
        },
      );

      _logger.i('TeleEndpoint: Call redirected successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to redirect call', error: e);
      throw Exception('Failed to redirect call: ${e.message}');
    }
  }

  /// Send DTMF digits during a call
  ///
  /// [call] - Active call
  /// [digits] - DTMF digits to send (RFC 2833 compliant)
  Future<void> dtmfCall(Call call, String digits) async {
    try {
      _logger.i('TeleEndpoint: Sending DTMF digits to call ${call.id}: $digits');

      await _methodChannel.invokeMethod<void>(
        'dtmfCall',
        {
          'callId': call.id,
          'digits': digits,
        },
      );

      _logger.i('TeleEndpoint: DTMF digits sent successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to send DTMF', error: e);
      throw Exception('Failed to send DTMF: ${e.message}');
    }
  }

  // ============================================================================
  // TASK endpoint-005: Implement messaging
  // ============================================================================

  /// Send a SIP MESSAGE
  ///
  /// [account] - Account to send from
  /// [destination] - Destination number or SIP URI
  /// [message] - Message body
  Future<void> sendMessage(Account account, String destination, String message) async {
    try {
      final normalizedDestination = _normalize(account, destination);
      _logger.i('TeleEndpoint: Sending message to $normalizedDestination');

      await _methodChannel.invokeMethod<void>(
        'sendMessage',
        {
          'accountId': account.id,
          'destination': normalizedDestination,
          'message': message,
        },
      );

      _logger.i('TeleEndpoint: Message sent successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to send message', error: e);
      throw Exception('Failed to send message: ${e.message}');
    }
  }

  /// Send typing indicator for IM
  ///
  /// [account] - Account to send from
  /// [destination] - Destination
  /// [isTyping] - Whether user is typing
  Future<void> imTyping(Account account, String destination, bool isTyping) async {
    try {
      final normalizedDestination = _normalize(account, destination);
      _logger.i('TeleEndpoint: Sending typing indicator to $normalizedDestination: $isTyping');

      await _methodChannel.invokeMethod<void>(
        'imTyping',
        {
          'accountId': account.id,
          'destination': normalizedDestination,
          'isTyping': isTyping,
        },
      );

      _logger.i('TeleEndpoint: Typing indicator sent successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to send typing indicator', error: e);
      throw Exception('Failed to send typing indicator: ${e.message}');
    }
  }

  // ============================================================================
  // Additional endpoint methods from specification
  // ============================================================================

  /// Change video orientation
  ///
  /// [orientation] - One of: PJMEDIA_ORIENT_UNKNOWN, PJMEDIA_ORIENT_ROTATE_90DEG,
  ///                 PJMEDIA_ORIENT_ROTATE_270DEG, PJMEDIA_ORIENT_ROTATE_180DEG, PJMEDIA_ORIENT_NATURAL
  void changeOrientation(String orientation) {
    const validOrientations = [
      'PJMEDIA_ORIENT_UNKNOWN',
      'PJMEDIA_ORIENT_ROTATE_90DEG',
      'PJMEDIA_ORIENT_ROTATE_270DEG',
      'PJMEDIA_ORIENT_ROTATE_180DEG',
      'PJMEDIA_ORIENT_NATURAL',
    ];

    if (!validOrientations.contains(orientation)) {
      throw ArgumentError('Invalid orientation: $orientation. Must be one of: $validOrientations');
    }

    _logger.i('TeleEndpoint: Changing orientation to $orientation');
    _methodChannel.invokeMethod<void>('changeOrientation', {'orientation': orientation});
  }

  /// Change codec settings
  Future<void> changeCodecSettings(Map<String, dynamic> codecSettings) async {
    try {
      _logger.i('TeleEndpoint: Changing codec settings');

      await _methodChannel.invokeMethod<void>(
        'changeCodecSettings',
        {'codecSettings': codecSettings},
      );

      _logger.i('TeleEndpoint: Codec settings changed successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to change codec settings', error: e);
      throw Exception('Failed to change codec settings: ${e.message}');
    }
  }

  /// Update STUN servers for an account
  Future<void> updateStunServers(int accountId, List<String> stunServerList) async {
    try {
      _logger.i('TeleEndpoint: Updating STUN servers for account $accountId');

      await _methodChannel.invokeMethod<void>(
        'updateStunServers',
        {
          'accountId': accountId,
          'stunServerList': stunServerList,
        },
      );

      _logger.i('TeleEndpoint: STUN servers updated successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to update STUN servers', error: e);
      throw Exception('Failed to update STUN servers: ${e.message}');
    }
  }

  /// Activate audio session (iOS only)
  Future<void> activateAudioSession() async {
    try {
      _logger.i('TeleEndpoint: Activating audio session');

      await _methodChannel.invokeMethod<void>('activateAudioSession');

      _logger.i('TeleEndpoint: Audio session activated successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to activate audio session', error: e);
      throw Exception('Failed to activate audio session: ${e.message}');
    }
  }

  /// Deactivate audio session (iOS only)
  Future<void> deactivateAudioSession() async {
    try {
      _logger.i('TeleEndpoint: Deactivating audio session');

      await _methodChannel.invokeMethod<void>('deactivateAudioSession');

      _logger.i('TeleEndpoint: Audio session deactivated successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to deactivate audio session', error: e);
      throw Exception('Failed to deactivate audio session: ${e.message}');
    }
  }

  /// Change network configuration
  Future<void> changeNetworkConfiguration(Map<String, dynamic> configuration) async {
    try {
      _logger.i('TeleEndpoint: Changing network configuration');

      await _methodChannel.invokeMethod<void>(
        'changeNetworkConfiguration',
        {'configuration': configuration},
      );

      _logger.i('TeleEndpoint: Network configuration changed successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to change network configuration', error: e);
      throw Exception('Failed to change network configuration: ${e.message}');
    }
  }

  /// Change service configuration
  Future<void> changeServiceConfiguration(Map<String, dynamic> configuration) async {
    try {
      _logger.i('TeleEndpoint: Changing service configuration');

      await _methodChannel.invokeMethod<void>(
        'changeServiceConfiguration',
        {'configuration': configuration},
      );

      _logger.i('TeleEndpoint: Service configuration changed successfully');
    } on PlatformException catch (e) {
      _logger.e('TeleEndpoint: Failed to change service configuration', error: e);
      throw Exception('Failed to change service configuration: ${e.message}');
    }
  }

  // ============================================================================
  // TASK endpoint-006: Event subscription
  // ============================================================================

  /// Subscribe to events of a specific type
  ///
  /// Returns a broadcast stream that multiple listeners can subscribe to
  ///
  /// Example:
  /// ```dart
  /// endpoint.on(EndpointEventType.callReceived).listen((callData) {
  ///   final call = Call(callData as Map<dynamic, dynamic>);
  ///   print('Incoming call from: ${call.remoteNumber}');
  /// });
  /// ```
  Stream<dynamic> on(String eventType) {
    _logger.d('TeleEndpoint: Creating event stream for type: $eventType');

    if (!_eventControllers.containsKey(eventType)) {
      _logger.d('TeleEndpoint: Creating new controller for event type: $eventType');
      _eventControllers[eventType] = StreamController<dynamic>.broadcast(
        onCancel: () {
          _logger.d('TeleEndpoint: All listeners unsubscribed from $eventType');
        },
      );
    }

    return _eventControllers[eventType]!.stream;
  }

  /// Check if endpoint is initialized
  bool get isInitialized => _isInitialized;

  /// Check if endpoint is started
  bool get isStarted => _isStarted;

  /// Get count of active event controllers
  int get controllerCount => _eventControllers.length;

  // ============================================================================
  // TASK endpoint-007: Cleanup/destructor (already verified as existing)
  // ============================================================================

  /// Dispose resources and close all streams
  ///
  /// Prevents memory leaks by cleaning up event subscriptions
  Future<void> dispose() async {
    _logger.i('TeleEndpoint: Disposing endpoint');

    // Cancel event subscription
    _eventSubscription?.cancel();
    _eventSubscription = null;

    // Close all event controllers
    for (final entry in _eventControllers.entries) {
      if (!entry.value.isClosed) {
        entry.value.close();
        _logger.d('TeleEndpoint: Closed controller for ${entry.key}');
      }
    }
    _eventControllers.clear();

    // Notify native module to release resources
    try {
      await _methodChannel.invokeMethod<void>('dispose');
      _logger.i('TeleEndpoint: Native module disposed successfully');
    } catch (e) {
      _logger.w('TeleEndpoint: Failed to dispose native module: $e');
    }

    _isInitialized = false;
    _isStarted = false;
    _logger.i('TeleEndpoint: Disposed successfully');
  }
}

/// Extension for convenient event listening
extension TeleEndpointExtension on TeleEndpoint {
  /// Subscribe to registration changed events
  Stream<dynamic> get registrationChanged => on(EndpointEventType.registrationChanged);

  /// Subscribe to call received events
  Stream<dynamic> get callReceived => on(EndpointEventType.callReceived);

  /// Subscribe to call changed events
  Stream<dynamic> get callChanged => on(EndpointEventType.callChanged);

  /// Subscribe to call terminated events
  Stream<dynamic> get callTerminated => on(EndpointEventType.callTerminated);

  /// Subscribe to call screen locked events
  Stream<dynamic> get callScreenLocked => on(EndpointEventType.callScreenLocked);

  /// Subscribe to message received events
  Stream<dynamic> get messageReceived => on(EndpointEventType.messageReceived);

  /// Subscribe to connectivity changed events
  Stream<dynamic> get connectivityChanged => on(EndpointEventType.connectivityChanged);
}
