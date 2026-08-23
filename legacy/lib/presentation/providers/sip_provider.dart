/// SIP Provider
/// State management for SIP operations using Provider pattern

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/sip_account.dart';
import '../../domain/entities/sip_call.dart';
import '../../domain/entities/sip_event.dart';
import '../../domain/repositories/sip_repository.dart';
import 'sip_event_handlers.dart';

/// SIP connection state
enum SipConnectionState {
  /// Not connected
  disconnected,

  /// Connecting
  connecting,

  /// Connected
  connected,

  /// Error
  error,
}

/// SIP State
///
/// Immutable state object for SIP provider
class SipState {
  /// SIP accounts keyed by ID
  final Map<String, SipAccount> accounts;

  /// Active calls keyed by ID
  final Map<String, SipCall> calls;

  /// Connection state
  final SipConnectionState connectionState;

  /// Registration state
  final SipRegistrationState registrationState;

  /// Error message (if any)
  final String? errorMessage;

  /// Whether SIP is initialized
  final bool isInitialized;

  /// Whether connected to network
  final bool isConnected;

  const SipState({
    this.accounts = const {},
    this.calls = const {},
    this.connectionState = SipConnectionState.disconnected,
    this.registrationState = SipRegistrationState.unregistered,
    this.errorMessage,
    this.isInitialized = false,
    this.isConnected = false,
  });

  /// Create a copy with updated fields
  SipState copyWith({
    Map<String, SipAccount>? accounts,
    Map<String, SipCall>? calls,
    SipConnectionState? connectionState,
    SipRegistrationState? registrationState,
    String? errorMessage,
    bool? isInitialized,
    bool? isConnected,
  }) {
    return SipState(
      accounts: accounts ?? this.accounts,
      calls: calls ?? this.calls,
      connectionState: connectionState ?? this.connectionState,
      registrationState: registrationState ?? this.registrationState,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitialized: isInitialized ?? this.isInitialized,
      isConnected: isConnected ?? this.isConnected,
    );
  }

  /// Get account by ID
  SipAccount? getAccount(String id) => accounts[id];

  /// Get call by ID
  SipCall? getCall(String id) => calls[id];

  /// Get active calls
  List<SipCall> get activeCalls =>
      calls.values.where((c) => c.isActive).toList();

  /// Get registered accounts
  List<SipAccount> get registeredAccounts =>
      accounts.values.where((a) => a.isRegistered).toList();

  /// Check if has active calls
  bool get hasActiveCalls => activeCalls.isNotEmpty;

  /// Check if has registered accounts
  bool get hasRegisteredAccounts => registeredAccounts.isNotEmpty;

  @override
  String toString() {
    return 'SipState(accounts: ${accounts.length}, calls: ${calls.length}, '
        'connection: $connectionState, registration: $registrationState)';
  }
}

/// SIP Provider
///
/// Manages SIP state and operations using Provider pattern.
/// Listens to SIP events and updates state accordingly.
class SipProvider extends ChangeNotifier {
  final SipRepository _repository;
  final Logger _logger;
  final SipEventHandlers _eventHandlers;

  SipState _state = const SipState();
  StreamSubscription? _eventSubscription;

  SipProvider(this._repository, this._logger)
      : _eventHandlers = SipEventHandlers() {
    _setupEventListeners();
  }

  /// Current SIP state
  SipState get state => _state;

  /// Get all accounts
  Map<String, SipAccount> get accounts => _state.accounts;

  /// Get all calls
  Map<String, SipCall> get calls => _state.calls;

  /// Get active calls
  List<SipCall> get activeCalls => _state.activeCalls;

  /// Get connection state
  SipConnectionState get connectionState => _state.connectionState;

  /// Get registration state
  SipRegistrationState get registrationState => _state.registrationState;

  /// Check if initialized
  bool get isInitialized => _state.isInitialized;

  /// Check if connected
  bool get isConnected => _state.isConnected;

  /// Check if has active calls
  bool get hasActiveCalls => _state.hasActiveCalls;

  /// Get error message
  String? get errorMessage => _state.errorMessage;

  /// Setup event listeners
  void _setupEventListeners() {
    _eventSubscription = _repository.eventStream.listen(
      _handleEvent,
      onError: _handleError,
    );
  }

  /// Handle SIP event
  void _handleEvent(SipEvent event) {
    _eventHandlers.handleEvent(event, _state, _updateState);
    notifyListeners();
  }

  /// Handle error
  void _handleError(dynamic error) {
    _logger.e('SIP event stream error', error: error);
    _updateState((state) => state.copyWith(
          connectionState: SipConnectionState.error,
          errorMessage: error.toString(),
        ));
    notifyListeners();
  }

  /// Update state
  void _updateState(SipState Function(SipState) update) {
    _state = update(_state);
  }

  // ==================== Lifecycle ====================

  /// Initialize SIP
  Future<bool> initialize(Map<String, dynamic> config) async {
    try {
      _updateState((state) => state.copyWith(
            connectionState: SipConnectionState.connecting,
          ));
      notifyListeners();

      final result = await _repository.initialize(config);

      return result.fold(
        (failure) {
          _logger.e('Failed to initialize SIP', error: failure);
          _updateState((state) => state.copyWith(
                connectionState: SipConnectionState.error,
                errorMessage: failure.message,
              ));
          notifyListeners();
          return false;
        },
        (_) {
          _updateState((state) => state.copyWith(
                isInitialized: true,
                connectionState: SipConnectionState.connected,
              ));
          notifyListeners();
          _logger.i('SIP initialized successfully');
          return true;
        },
      );
    } catch (e) {
      _logger.e('SIP initialization error', error: e);
      _updateState((state) => state.copyWith(
            connectionState: SipConnectionState.error,
            errorMessage: e.toString(),
          ));
      notifyListeners();
      return false;
    }
  }

  /// Destroy SIP
  Future<void> destroy() async {
    try {
      await _eventSubscription?.cancel();
      final result = await _repository.destroy();

      result.fold(
        (failure) => _logger.e('Failed to destroy SIP', error: failure),
        (_) => _logger.i('SIP destroyed successfully'),
      );

      _updateState((state) => const SipState());
      notifyListeners();
    } catch (e) {
      _logger.e('SIP destroy error', error: e);
    }
  }

  // ==================== Account Operations ====================

  /// Create account
  Future<SipAccount?> createAccount(SipAccount account) async {
    final result = await _repository.createAccount(account);
    return result.fold(
      (failure) {
        _logger.e('Failed to create account', error: failure);
        return null;
      },
      (created) {
        _updateState((state) => state.copyWith(
              accounts: {...state.accounts, created.id: created},
            ));
        notifyListeners();
        _logger.i('Account created: ${created.id}');
        return created;
      },
    );
  }

  /// Delete account
  Future<bool> deleteAccount(String accountId) async {
    final result = await _repository.deleteAccount(accountId);
    return result.fold(
      (failure) {
        _logger.e('Failed to delete account', error: failure);
        return false;
      },
      (_) {
        _updateState((state) {
          final accounts = {...state.accounts};
          accounts.remove(accountId);
          return state.copyWith(accounts: accounts);
        });
        notifyListeners();
        _logger.i('Account deleted: $accountId');
        return true;
      },
    );
  }

  /// Get accounts
  Future<void> loadAccounts() async {
    final result = await _repository.getAccounts();
    result.fold(
      (failure) => _logger.e('Failed to load accounts', error: failure),
      (accounts) {
        _updateState((state) => state.copyWith(
              accounts: {for (var a in accounts) a.id: a},
            ));
        notifyListeners();
      },
    );
  }

  /// Register account
  Future<bool> registerAccount(String accountId) async {
    final result = await _repository.registerAccount(accountId);
    return result.fold(
      (failure) {
        _logger.e('Failed to register account', error: failure);
        return false;
      },
      (_) {
        _logger.i('Account registered: $accountId');
        return true;
      },
    );
  }

  // ==================== Call Operations ====================

  /// Make call
  Future<SipCall?> makeCall(String accountId, String number) async {
    final result = await _repository.makeCall(accountId, number);
    return result.fold(
      (failure) {
        _logger.e('Failed to make call', error: failure);
        return null;
      },
      (call) {
        _updateState((state) => state.copyWith(
              calls: {...state.calls, call.id: call},
            ));
        notifyListeners();
        _logger.i('Call made: ${call.id} to $number');
        return call;
      },
    );
  }

  /// Answer call
  Future<bool> answerCall(String callId) async {
    final result = await _repository.answerCall(callId);
    return result.fold(
      (failure) {
        _logger.e('Failed to answer call', error: failure);
        return false;
      },
      (_) {
        _logger.i('Call answered: $callId');
        return true;
      },
    );
  }

  /// Hangup call
  Future<bool> hangupCall(String callId) async {
    final result = await _repository.hangupCall(callId);
    return result.fold(
      (failure) {
        _logger.e('Failed to hangup call', error: failure);
        return false;
      },
      (_) {
        _updateState((state) {
          final calls = {...state.calls};
          calls.remove(callId);
          return state.copyWith(calls: calls);
        });
        notifyListeners();
        _logger.i('Call hung up: $callId');
        return true;
      },
    );
  }

  /// Hold call
  Future<bool> holdCall(String callId) async {
    final result = await _repository.holdCall(callId);
    return result.fold(
      (failure) {
        _logger.e('Failed to hold call', error: failure);
        return false;
      },
      (_) {
        _logger.i('Call held: $callId');
        return true;
      },
    );
  }

  /// Mute call
  Future<bool> muteCall(String callId) async {
    final result = await _repository.muteCall(callId);
    return result.fold(
      (failure) {
        _logger.e('Failed to mute call', error: failure);
        return false;
      },
      (_) {
        _logger.i('Call muted: $callId');
        return true;
      },
    );
  }

  /// Use speaker
  Future<bool> useSpeaker(String callId) async {
    final result = await _repository.useSpeaker(callId);
    return result.fold(
      (failure) {
        _logger.e('Failed to use speaker', error: failure);
        return false;
      },
      (_) {
        _logger.i('Using speaker: $callId');
        return true;
      },
    );
  }

  /// Send DTMF
  Future<bool> sendDtmf(String callId, String digit) async {
    final result = await _repository.sendDtmf(callId, digit);
    return result.fold(
      (failure) {
        _logger.e('Failed to send DTMF', error: failure);
        return false;
      },
      (_) {
        _logger.d('DTMF sent: $digit');
        return true;
      },
    );
  }

  @override
  void dispose() {
    _eventSubscription?.cancel();
    super.dispose();
  }
}
