import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_nmsip/flutter_nmsip.dart';
import 'package:flutter_nmsip/src/account_registration.dart';

/// Tracks SIP account/call state locally by demuxing
/// `FlutterSip2.eventStream`, since `flutter_nmsip` itself exposes no
/// state-query API (`isConnected`/`isInitialized`/`accounts`/
/// `activeCalls`) — only commands + one raw event stream. See
/// flows/sdd-flutter_gsm/02-specifications.md §3.1's capability-gap
/// table for the full comparison against `flutter_gsmsip`'s old embedded
/// `sip_service.dart`.
///
/// Real event shape, confirmed by reading `flutter_nmsip`'s native
/// Android source (`PjSipBroadcastReceiver.java`), not assumed: each
/// event is `{'event': <name>, 'data': <payload>}` — NOT `{'type': ...}`
/// as earlier specifications guessed. Event names:
/// `pjSipRegistrationChanged`, `pjSipMessageReceived`,
/// `pjSipCallReceived`, `pjSipCallChanged`, `pjSipCallTerminated`.
///
/// `attendedTransfer` — corrected finding: the native plugin DOES support
/// this (`ACTION_XFER_REPLACES_CALL` / `"call_xfer_replace"` in
/// `PjActions.java`), it's just not exposed on `flutter_nmsip`'s public
/// Dart `FlutterSip2` class yet (only plain `xferCall` is). This is a
/// missing Dart binding upstream, not a missing capability — flag as an
/// addendum to `flutter_nmsip`, don't work around it here.
class SipStateTracker extends ChangeNotifier {
  StreamSubscription<Map<String, dynamic>>? _eventSub;

  final Map<int, Account> _accounts = {};
  final Map<int, Call> _activeCalls = {};

  bool _initialized = false;

  SipStateTracker() {
    _eventSub = FlutterSip2.eventStream.listen(_onEvent, onError: (_) {});
  }

  /// Whether `start()` has completed (or an event has arrived) at least
  /// once. `flutter_nmsip` has no explicit init-state query.
  bool get isInitialized => _initialized;

  /// Whether at least one tracked account is currently registered.
  bool get isConnected => _accounts.values.any((a) => a.registration.status);

  List<Account> get accounts => List.unmodifiable(_accounts.values);

  List<Call> get activeCalls => List.unmodifiable(_activeCalls.values);

  Account? account(int id) => _accounts[id];

  /// Call after a successful `FlutterSip2.start()` — the tracker has no
  /// other way to know initialization happened, since `start()` doesn't
  /// itself emit a distinguishable event.
  void markInitialized() {
    _initialized = true;
    notifyListeners();
  }

  /// Call after a successful `FlutterSip2.createAccount()` — account
  /// creation isn't covered by `pjSipRegistrationChanged` (that only
  /// fires on registration state changes, not creation), so the caller
  /// must tell the tracker directly.
  void trackAccountCreated(Account account) {
    _accounts[account.id] = account;
    notifyListeners();
  }

  /// Call after a successful `FlutterSip2.deleteAccount()`.
  void trackAccountDeleted(int accountId) {
    _accounts.remove(accountId);
    notifyListeners();
  }

  void _onEvent(Map<String, dynamic> event) {
    final name = event['event'] as String?;
    final data = event['data'];
    if (name == null) return;

    try {
      switch (name) {
        case 'pjSipRegistrationChanged':
          _onRegistrationChanged(data);
        case 'pjSipCallReceived':
        case 'pjSipCallChanged':
          _onCallUpserted(data);
        case 'pjSipCallTerminated':
          _onCallTerminated(data);
        case 'pjSipMessageReceived':
          // No local state to update; callers observing raw SIP
          // messages should subscribe to FlutterSip2.eventStream
          // directly for this one.
          break;
      }
    } catch (_) {
      // Malformed/unexpected payload shape — drop it rather than crash
      // the stream. flutter_nmsip's native source does no schema
      // validation on its side either.
    }
    _initialized = true;
    notifyListeners();
  }

  void _onRegistrationChanged(dynamic data) {
    if (data is! Map) return;
    final map = Map<String, dynamic>.from(data);

    // Defensive: accountId may be top-level alongside a nested
    // 'registration' map, or the payload may just be the registration
    // itself with the id under a different key. Try both shapes rather
    // than assume one — not verifiable without a running device.
    final accountId = map['accountId'] as int? ?? map['id'] as int?;
    if (accountId == null) return;

    final existing = _accounts[accountId];
    if (existing == null) return; // unknown account — nothing to update

    final registrationMap = (map['registration'] as Map?) ?? map;
    final registration = AccountRegistration.fromMap(
      Map<String, dynamic>.from(registrationMap),
    );

    _accounts[accountId] = Account(
      id: existing.id,
      uri: existing.uri,
      name: existing.name,
      username: existing.username,
      domain: existing.domain,
      password: existing.password,
      proxy: existing.proxy,
      transport: existing.transport,
      contactParams: existing.contactParams,
      contactUriParams: existing.contactUriParams,
      regServer: existing.regServer,
      regTimeout: existing.regTimeout,
      regContactParams: existing.regContactParams,
      regHeaders: existing.regHeaders,
      registration: registration,
    );
  }

  void _onCallUpserted(dynamic data) {
    if (data is! Map) return;
    final call = Call.fromMap(Map<String, dynamic>.from(data));
    _activeCalls[call.id] = call;
  }

  void _onCallTerminated(dynamic data) {
    if (data is! Map) return;
    final call = Call.fromMap(Map<String, dynamic>.from(data));
    _activeCalls.remove(call.id);
  }

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }
}
