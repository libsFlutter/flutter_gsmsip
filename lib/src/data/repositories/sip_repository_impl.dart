/// SIP Repository Implementation
///
/// Implements [SipRepository] directly against `flutter_nmsip`'s
/// `FlutterSip2` (commands) + [SipStateTracker] (state queries/streams),
/// replacing the old embedded PJSIP-glue `SipService`. See
/// flows/sdd-flutter_gsm/02-specifications.md §3.1 for the capability-gap
/// analysis this rewrite is based on.
library;

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:flutter_nmsip/flutter_nmsip.dart';

import '../../domain/entities/sip_account.dart';
import '../../domain/entities/sip_call.dart';
import '../../domain/entities/sip_event.dart';
import '../../domain/repositories/sip_repository.dart';
import '../../core/error/failures.dart';
import '../../services/sip_state_tracker.dart';

class SipRepositoryImpl implements SipRepository {
  final SipStateTracker _tracker;
  final Logger _logger;

  /// `flutter_nmsip` has no "default account" concept — tracked locally.
  String? _defaultAccountId;

  SipRepositoryImpl(this._tracker, this._logger);

  @override
  AsyncSipResult<void> initialize(Map<String, dynamic> config) async {
    try {
      await FlutterSip2.start(config);
      _tracker.markInitialized();
      _logger.i('SIP endpoint initialized');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to initialize SIP', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to initialize SIP: $e',
        serviceName: 'flutter_nmsip',
      ));
    }
  }

  @override
  AsyncSipResult<void> destroy() async {
    // flutter_nmsip exposes no endpoint-teardown method (confirmed: no
    // "stop"/"destroy" action in its native PjActions.java) — this is a
    // known gap, not an oversight. Clear local tracking so subsequent
    // state queries reflect "nothing running" even though the native
    // PJSIP endpoint itself isn't explicitly torn down.
    for (final account in List.of(_tracker.accounts)) {
      _tracker.trackAccountDeleted(account.id);
    }
    _defaultAccountId = null;
    _logger.w('destroy(): flutter_nmsip has no endpoint-teardown method — '
        'cleared local tracking only, file as an addendum if a real '
        'teardown is needed');
    return const Right(null);
  }

  // ==================== Account Operations ====================

  @override
  AsyncSipResult<SipAccount> createAccount(SipAccount account) async {
    try {
      final created = await FlutterSip2.createAccount(_accountConfig(account));
      _tracker.trackAccountCreated(created);
      final isFirst = _defaultAccountId == null;
      if (isFirst) _defaultAccountId = created.id.toString();
      _logger.i('SIP account created: ${created.id}');
      return Right(_toSipAccount(created, isDefault: isFirst));
    } catch (e) {
      _logger.e('Failed to create SIP account', error: e);
      return Left(SipFailure(message: 'Failed to create account: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> deleteAccount(String accountId) async {
    try {
      final account = _requireTrackedAccount(accountId);
      await FlutterSip2.deleteAccount(account);
      _tracker.trackAccountDeleted(account.id);
      if (_defaultAccountId == accountId) _defaultAccountId = null;
      _logger.i('SIP account deleted: $accountId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete SIP account', error: e);
      return Left(SipFailure(message: 'Failed to delete account: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<SipAccount?> getAccount(String accountId) async {
    try {
      final id = int.tryParse(accountId);
      final account = id == null ? null : _tracker.account(id);
      return Right(account == null
          ? null
          : _toSipAccount(account, isDefault: accountId == _defaultAccountId));
    } catch (e) {
      _logger.e('Failed to get SIP account', error: e);
      return Left(SipFailure(message: 'Failed to get account: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<List<SipAccount>> getAccounts() async {
    try {
      final accounts = _tracker.accounts
          .map((a) => _toSipAccount(a, isDefault: a.id.toString() == _defaultAccountId))
          .toList();
      return Right(accounts);
    } catch (e) {
      _logger.e('Failed to get SIP accounts', error: e);
      return Left(SipFailure(message: 'Failed to get accounts: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<SipAccount?> getDefaultAccount() async {
    if (_defaultAccountId == null) return const Right(null);
    return getAccount(_defaultAccountId!);
  }

  @override
  AsyncSipResult<void> setDefaultAccount(String accountId) async {
    if (_tracker.account(int.tryParse(accountId) ?? -1) == null) {
      return Left(SipFailure(message: 'Unknown account: $accountId'));
    }
    _defaultAccountId = accountId;
    return const Right(null);
  }

  @override
  AsyncSipResult<void> registerAccount(String accountId, {bool reregister = false}) async {
    try {
      final account = _requireTrackedAccount(accountId);
      await FlutterSip2.registerAccount(account, renew: reregister);
      _logger.i('SIP account registered: $accountId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to register SIP account', error: e);
      return Left(SipFailure(message: 'Failed to register account: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> unregisterAccount(String accountId) async {
    // Known gap: flutter_nmsip has no unregister (REGISTER Expires=0)
    // distinct from delete — see 02-specifications.md §3.1. Not the same
    // as deleteAccount (which removes the account object entirely and
    // can't be re-registered without recreating it), so not implemented
    // as a workaround here — file as an addendum to flutter_nmsip instead
    // of silently approximating incorrect behavior.
    _logger.w('unregisterAccount($accountId): not supported by flutter_nmsip '
        '(no REGISTER Expires=0 equivalent) — file as an addendum upstream');
    return Left(SipFailure(
      message: 'unregisterAccount is not supported by the underlying SIP '
          'library (flutter_nmsip has no unregister-without-delete method)',
      code: 'UNREGISTER_NOT_SUPPORTED',
    ));
  }

  // ==================== Call Operations ====================

  @override
  AsyncSipResult<SipCall> makeCall(String accountId, String number) async {
    try {
      final account = _requireTrackedAccount(accountId);
      final call = await FlutterSip2.makeCall(account, number);
      _logger.i('SIP call made: ${call.id} to $number');
      return Right(_toSipCall(call, accountId));
    } catch (e) {
      _logger.e('Failed to make SIP call', error: e);
      return Left(SipFailure(message: 'Failed to make call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> answerCall(String callId) async {
    try {
      await FlutterSip2.answerCall(_requireTrackedCall(callId));
      _logger.i('SIP call answered: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to answer SIP call', error: e);
      return Left(SipFailure(message: 'Failed to answer call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> declineCall(String callId) async {
    try {
      await FlutterSip2.declineCall(_requireTrackedCall(callId));
      _logger.i('SIP call declined: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to decline SIP call', error: e);
      return Left(SipFailure(message: 'Failed to decline call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> hangupCall(String callId) async {
    try {
      await FlutterSip2.hangupCall(_requireTrackedCall(callId));
      _logger.i('SIP call hung up: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to hangup SIP call', error: e);
      return Left(SipFailure(message: 'Failed to hangup call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> holdCall(String callId) async {
    try {
      await FlutterSip2.holdCall(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to hold call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> unholdCall(String callId) async {
    try {
      await FlutterSip2.unholdCall(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to unhold call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> muteCall(String callId) async {
    try {
      await FlutterSip2.muteCall(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to mute call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> unmuteCall(String callId) async {
    try {
      await FlutterSip2.unmuteCall(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to unmute call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> useSpeaker(String callId) async {
    try {
      await FlutterSip2.useSpeaker(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to use speaker: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> useEarpiece(String callId) async {
    try {
      await FlutterSip2.useEarpiece(_requireTrackedCall(callId));
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to use earpiece: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> sendDtmf(String callId, String digit) async {
    try {
      await FlutterSip2.dtmfCall(_requireTrackedCall(callId), digit);
      return const Right(null);
    } catch (e) {
      return Left(SipFailure(message: 'Failed to send DTMF: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> transferCall(String callId, String destination) async {
    try {
      await FlutterSip2.xferCall(_requireTrackedCall(callId), destination);
      _logger.i('SIP call transferred: $callId to $destination');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to transfer SIP call', error: e);
      return Left(SipFailure(message: 'Failed to transfer call: $e', originalError: e));
    }
  }

  @override
  AsyncSipResult<void> attendedTransfer(String callId, String targetCallId) async {
    // Corrected finding vs. earlier specifications: the native plugin
    // DOES support this (ACTION_XFER_REPLACES_CALL / "call_xfer_replace"
    // in flutter_nmsip's PjActions.java) — it's a missing Dart binding on
    // FlutterSip2 (only xferCall/blind-transfer is exposed), not a
    // missing capability. File as an addendum to flutter_nmsip to add a
    // xferReplacesCall()/attendedTransfer() method, rather than working
    // around it here.
    _logger.w('attendedTransfer($callId, $targetCallId): flutter_nmsip '
        'supports this natively (call_xfer_replace) but does not expose '
        'it on FlutterSip2 yet — file as an addendum upstream');
    return Left(SipFailure(
      message: 'attendedTransfer requires a flutter_nmsip Dart-API addition '
          '(native support exists: ACTION_XFER_REPLACES_CALL)',
      code: 'ATTENDED_TRANSFER_NOT_BOUND',
    ));
  }

  @override
  AsyncSipResult<void> redirectCall(String callId, String destination) async {
    try {
      await FlutterSip2.redirectCall(_requireTrackedCall(callId), destination);
      _logger.i('SIP call redirected: $callId to $destination');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to redirect SIP call', error: e);
      return Left(SipFailure(message: 'Failed to redirect call: $e', originalError: e));
    }
  }

  // ==================== Event Streams ====================
  //
  // flutter_nmsip exposes one raw eventStream, not separate typed
  // streams — filter/map it into the four shapes SipRepository's
  // interface expects.

  @override
  Stream<SipEvent> get eventStream => FlutterSip2.eventStream
      .map(_toSipEventOrNull)
      .where((e) => e != null)
      .cast<SipEvent>();

  @override
  Stream<SipEvent> get accountStream => eventStream.where(
        (e) => e.type == SipEventType.registrationChanged || e.type == SipEventType.accountChanged,
      );

  @override
  Stream<SipEvent> get callStream => eventStream.where(
        (e) =>
            e.type == SipEventType.callReceived ||
            e.type == SipEventType.callChanged ||
            e.type == SipEventType.callTerminated,
      );

  @override
  Stream<bool> get connectivityStream =>
      eventStream.where((e) => e.type == SipEventType.connectivityChanged).map((e) => e.isConnected ?? false);

  // ==================== State Queries ====================

  @override
  bool get isInitialized => _tracker.isInitialized;

  @override
  bool get isConnected => _tracker.isConnected;

  @override
  int get accountCount => _tracker.accounts.length;

  @override
  int get activeCallCount => _tracker.activeCalls.length;

  @override
  List<SipCall> get activeCalls => _tracker.activeCalls
      .map((c) => _toSipCall(c, c.accountId.toString()))
      .toList();

  // ==================== Mapping helpers ====================

  Account _requireTrackedAccount(String accountId) {
    final id = int.tryParse(accountId);
    final account = id == null ? null : _tracker.account(id);
    if (account == null) {
      throw StateError('No tracked SIP account with id $accountId');
    }
    return account;
  }

  Call _requireTrackedCall(String callId) {
    final id = int.tryParse(callId);
    if (id == null) throw StateError('Invalid call id: $callId');
    for (final call in _tracker.activeCalls) {
      if (call.id == id) return call;
    }
    throw StateError('No tracked SIP call with id $callId');
  }

  /// Keys confirmed against flutter_nmsip's native
  /// `AccountConfigurationDTO.kt` (not guessed): `name`, `username`,
  /// `domain`, `password`, `proxy`, `transport`, `regServer`,
  /// `regTimeout`, `regHeaders`, `regContactParams`. No `uri` key — the
  /// native side derives it from username+domain.
  Map<String, dynamic> _accountConfig(SipAccount account) {
    return {
      'name': account.displayName ?? account.username,
      'username': account.username,
      'domain': account.domain,
      'password': account.password,
      'proxy': account.proxy,
      'transport': account.transport.name,
      'regTimeout': account.registrationTimeout,
      'regHeaders': account.registrationHeaders,
    };
  }

  SipAccount _toSipAccount(Account account, {required bool isDefault}) {
    return SipAccount(
      id: account.id.toString(),
      username: account.username,
      password: account.password,
      domain: account.domain,
      transport: SipTransport.values.firstWhere(
        (t) => t.name == account.transport,
        orElse: () => SipTransport.udp,
      ),
      registrationTimeout: account.regTimeout ?? 3600,
      contactUriParams: account.contactUriParams,
      registrationState: account.registration.status
          ? SipRegistrationState.registered
          : SipRegistrationState.unregistered,
      registrationStatus: account.registration.reason,
      displayName: account.name,
      proxy: account.proxy,
      isDefault: isDefault,
    );
  }

  SipCall _toSipCall(Call call, String accountId) {
    return SipCall(
      id: call.id.toString(),
      accountId: accountId,
      number: call.remoteNumber ?? call.remoteUri ?? '',
      direction: CallDirection.outgoing, // flutter_nmsip's Call has no direction field
      state: _pjSipCallStateToCallState(call.state),
      isMuted: call.muted,
      isOnHold: call.held,
      isSpeaker: call.speaker,
      callerName: call.remoteName,
    );
  }

  CallState _pjSipCallStateToCallState(String state) {
    switch (state) {
      case 'PJSIP_INV_STATE_CALLING':
        return CallState.initiated;
      case 'PJSIP_INV_STATE_INCOMING':
        return CallState.incoming;
      case 'PJSIP_INV_STATE_EARLY':
      case 'PJSIP_INV_STATE_CONNECTING':
      case 'PJSIP_INV_STATE_CONFIRMED':
        return CallState.active;
      case 'PJSIP_INV_STATE_DISCONNECTED':
        return CallState.terminated;
      default:
        return CallState.initiated;
    }
  }

  /// Real event shape confirmed by reading flutter_nmsip's native source
  /// (PjSipBroadcastReceiver.java): `{'event': <name>, 'data': <payload>}`
  /// with names `pjSipRegistrationChanged`/`pjSipMessageReceived`/
  /// `pjSipCallReceived`/`pjSipCallChanged`/`pjSipCallTerminated` — not
  /// the snake_case names `SipEvent.parseType` expects, so mapped
  /// directly here rather than reusing that helper.
  SipEvent? _toSipEventOrNull(Map<String, dynamic> raw) {
    final name = raw['event'] as String?;
    final data = raw['data'];
    if (name == null) return null;

    final SipEventType type;
    switch (name) {
      case 'pjSipRegistrationChanged':
        type = SipEventType.registrationChanged;
      case 'pjSipMessageReceived':
        type = SipEventType.unknown;
      case 'pjSipCallReceived':
        type = SipEventType.callReceived;
      case 'pjSipCallChanged':
        type = SipEventType.callChanged;
      case 'pjSipCallTerminated':
        type = SipEventType.callTerminated;
      default:
        type = SipEventType.unknown;
    }

    return SipEvent(
      type: type,
      data: data is Map ? Map<String, dynamic>.from(data) : <String, dynamic>{},
    );
  }
}
