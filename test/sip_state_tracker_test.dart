import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_nmsip/flutter_nmsip.dart';
import 'package:flutter_nmsip/src/account_registration.dart';
import 'package:flutter_gsmsip/src/services/sip_state_tracker.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const eventChannel = EventChannel('flutter_sip2_events');

  Account testAccount() => Account(
        id: 1,
        uri: 'sip:user@example.com',
        name: 'Test',
        username: 'user',
        domain: 'example.com',
        password: 'pass',
        registration: AccountRegistration(status: false),
      );

  setUp(() {
    // SipStateTracker subscribes to FlutterSip2.eventStream on
    // construction — give it an empty (but valid) stream so tests don't
    // hit a MissingPluginException.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
      eventChannel,
      MockStreamHandler.inline(onListen: (arguments, events) {}),
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(eventChannel, null);
  });

  test('isInitialized becomes true after markInitialized()', () {
    final tracker = SipStateTracker();
    expect(tracker.isInitialized, isFalse);

    tracker.markInitialized();
    expect(tracker.isInitialized, isTrue);

    tracker.dispose();
  });

  test('trackAccountCreated() adds to accounts, isConnected reflects registration', () {
    final tracker = SipStateTracker();

    tracker.trackAccountCreated(testAccount());
    expect(tracker.accounts, hasLength(1));
    expect(tracker.isConnected, isFalse);

    tracker.dispose();
  });

  test('trackAccountDeleted() removes from accounts', () {
    final tracker = SipStateTracker();

    tracker.trackAccountCreated(testAccount());
    expect(tracker.accounts, hasLength(1));

    tracker.trackAccountDeleted(1);
    expect(tracker.accounts, isEmpty);

    tracker.dispose();
  });

  test('account() looks up by id', () {
    final tracker = SipStateTracker();

    tracker.trackAccountCreated(testAccount());

    expect(tracker.account(1)?.username, 'user');
    expect(tracker.account(99), isNull);

    tracker.dispose();
  });
}
