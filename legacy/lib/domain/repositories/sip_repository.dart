/// SIP Repository interface
/// Defines the contract for SIP operations

import 'package:dartz/dartz.dart';
import '../entities/sip_account.dart';
import '../entities/sip_call.dart';
import '../entities/sip_event.dart';
import '../../core/error/failures.dart';

/// Result type alias for SIP operations
typedef SipResult<T> = Either<Failure, T>;

/// Async Result type alias for SIP operations
typedef AsyncSipResult<T> = Future<Either<Failure, T>>;

/// Stream Result type alias for SIP operations
typedef StreamSipResult<T> = Stream<Either<Failure, T>>;

/// SIP Repository interface
///
/// Defines all SIP operations that can be performed.
/// Implementations should use the Result pattern for error handling.
abstract class SipRepository {
  /// Initialize SIP endpoint
  ///
  /// Must be called before any other SIP operations.
  /// [config] - SIP configuration (transport, network settings)
  AsyncSipResult<void> initialize(Map<String, dynamic> config);

  /// Destroy SIP endpoint
  ///
  /// Cleans up all resources and removes all accounts.
  AsyncSipResult<void> destroy();

  // ==================== Account Operations ====================

  /// Create a new SIP account
  ///
  /// [account] - Account configuration
  /// Returns the created account with assigned ID
  AsyncSipResult<SipAccount> createAccount(SipAccount account);

  /// Delete a SIP account
  ///
  /// [accountId] - ID of account to delete
  AsyncSipResult<void> deleteAccount(String accountId);

  /// Get a SIP account by ID
  ///
  /// [accountId] - ID of account to get
  AsyncSipResult<SipAccount?> getAccount(String accountId);

  /// Get all SIP accounts
  AsyncSipResult<List<SipAccount>> getAccounts();

  /// Get the default SIP account
  AsyncSipResult<SipAccount?> getDefaultAccount();

  /// Set default account
  ///
  /// [accountId] - ID of account to set as default
  AsyncSipResult<void> setDefaultAccount(String accountId);

  /// Register an account
  ///
  /// [accountId] - ID of account to register
  /// [reregister] - Whether this is a re-registration
  AsyncSipResult<void> registerAccount(String accountId, {bool reregister = false});

  /// Unregister an account
  ///
  /// [accountId] - ID of account to unregister
  AsyncSipResult<void> unregisterAccount(String accountId);

  // ==================== Call Operations ====================

  /// Make an outgoing call
  ///
  /// [accountId] - ID of account to use
  /// [number] - Destination number or SIP URI
  AsyncSipResult<SipCall> makeCall(String accountId, String number);

  /// Answer an incoming call
  ///
  /// [callId] - ID of call to answer
  AsyncSipResult<void> answerCall(String callId);

  /// Decline an incoming call
  ///
  /// [callId] - ID of call to decline
  AsyncSipResult<void> declineCall(String callId);

  /// Hangup/terminate a call
  ///
  /// [callId] - ID of call to hangup
  AsyncSipResult<void> hangupCall(String callId);

  /// Hold a call
  ///
  /// [callId] - ID of call to hold
  AsyncSipResult<void> holdCall(String callId);

  /// Unhold/resume a call
  ///
  /// [callId] - ID of call to resume
  AsyncSipResult<void> unholdCall(String callId);

  /// Mute a call
  ///
  /// [callId] - ID of call to mute
  AsyncSipResult<void> muteCall(String callId);

  /// Unmute a call
  ///
  /// [callId] - ID of call to unmute
  AsyncSipResult<void> unmuteCall(String callId);

  /// Use speaker for a call
  ///
  /// [callId] - ID of call to use speaker
  AsyncSipResult<void> useSpeaker(String callId);

  /// Use earpiece for a call
  ///
  /// [callId] - ID of call to use earpiece
  AsyncSipResult<void> useEarpiece(String callId);

  /// Send DTMF tone
  ///
  /// [callId] - ID of call
  /// [digit] - DTMF digit (0-9, *, #, A-D)
  AsyncSipResult<void> sendDtmf(String callId, String digit);

  /// Blind transfer a call
  ///
  /// [callId] - ID of call to transfer
  /// [destination] - Transfer destination number
  AsyncSipResult<void> transferCall(String callId, String destination);

  /// Attended transfer a call
  ///
  /// [callId] - ID of call to transfer
  /// [targetCallId] - ID of call to transfer to
  AsyncSipResult<void> attendedTransfer(String callId, String targetCallId);

  /// Redirect a call
  ///
  /// [callId] - ID of call to redirect
  /// [destination] - Redirect destination number
  AsyncSipResult<void> redirectCall(String callId, String destination);

  // ==================== Event Streams ====================

  /// Stream of all SIP events
  Stream<SipEvent> get eventStream;

  /// Stream of account-related events
  Stream<SipEvent> get accountStream;

  /// Stream of call-related events
  Stream<SipEvent> get callStream;

  /// Stream of connectivity events
  Stream<bool> get connectivityStream;

  // ==================== State Queries ====================

  /// Check if SIP is initialized
  bool get isInitialized;

  /// Check if connected to network
  bool get isConnected;

  /// Get current account count
  int get accountCount;

  /// Get current active call count
  int get activeCallCount;

  /// Get all active calls
  List<SipCall> get activeCalls;
}
