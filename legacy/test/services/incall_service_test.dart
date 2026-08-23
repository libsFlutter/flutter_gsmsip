import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/android_telecom_service.dart';
import 'package:logger/logger.dart';

void main() {
  group('AndroidTelecomService', () {
    late AndroidTelecomService telecomService;
    late List<MethodCall> log;

    setUp(() async {
      telecomService = AndroidTelecomService();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();

      // Setup method channel handler for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tele'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );

      // Setup event channel handler for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const EventChannel('flutter_tele_events'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'listen') {
            // Simulate event stream
            return null;
          }
          return null;
        },
      );
    });

    tearDown(() {
      telecomService.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_tele'),
        null,
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const EventChannel('flutter_tele_events'),
        null,
      );
    });

    group('Initialization', () {
      // TASK telecom-001: Implement AndroidTelecomService (ConnectionService wrapper)
      test('should initialize successfully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const EventChannel('flutter_tele_events'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'listen') {
              return Stream.value({
                'type': 'service_started',
                'data': {},
              });
            }
            return null;
          },
        );

        // act
        final result = await telecomService.initialize();

        // assert
        expect(result, isTrue);
        expect(telecomService.isInitialized, isTrue);
      });

      test('should return true if already initialized', () async {
        // arrange - initialize first
        await telecomService.initialize();
        log.clear();

        // act
        final result = await telecomService.initialize();

        // assert
        expect(result, isTrue);
        expect(telecomService.isInitialized, isTrue);
        // Should not setup event channel again
        expect(log.length, equals(0));
      });
    });

    group('Service Lifecycle', () {
      test('should start service successfully', () async {
        // arrange
        await telecomService.initialize();
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'start') {
              return {'success': true};
            }
            return null;
          },
        );

        // act
        final result = await telecomService.startService();

        // assert
        expect(result, isTrue);
        expect(telecomService.isServiceStarted, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('start'));
      });

      test('should stop service successfully', () async {
        // arrange - start service first
        await telecomService.initialize();
        await telecomService.startService();
        log.clear();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return null;
          },
        );

        // act
        final result = await telecomService.stopService();

        // assert
        expect(result, isTrue);
        expect(telecomService.isServiceStarted, isFalse);
        expect(log.length, equals(1));
        expect(log.first.method, equals('stop'));
      });

      test('should return true if stopping already stopped service', () async {
        // act
        final result = await telecomService.stopService();

        // assert
        expect(result, isTrue);
      });
    });

    group('Call Management', () {
      // TASK telecom-001: Implement AndroidTelecomService (ConnectionService wrapper)
      test('should make outgoing call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        final callData = {
          'id': 1,
          'destination': '1234567890',
          'sim': 1,
          'state': TelecomCallState.dialing,
          'held': false,
          'muted': false,
          'speaker': false,
          'direction': TelecomCallDirection.outgoing,
          'remoteNumber': '1234567890',
          'remoteName': '',
        };

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('makeCall'));
            expect(methodCall.arguments['destination'], equals('1234567890'));
            return callData;
          },
        );

        // act
        final call = await telecomService.makeCall('1234567890');

        // assert
        expect(call.id, equals(1));
        expect(call.destination, equals('1234567890'));
        expect(call.state, equals(TelecomCallState.dialing));
        expect(call.direction, equals(TelecomCallDirection.outgoing));
        expect(log.length, equals(1));
      });

      test('should answer incoming call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('answerCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.ringing,
          direction: TelecomCallDirection.incoming,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.answerCall(call);

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
      });

      test('should hangup call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('hangupCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.hangupCall(call);

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
      });

      test('should decline incoming call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('declineCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.ringing,
          direction: TelecomCallDirection.incoming,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.declineCall(call);

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
      });
    });

    group('Call Control', () {
      // TASK telecom-002: Implement Connection (call connection handling)
      test('should hold call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('holdCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.holdCall(call);

        // assert
        expect(result, isTrue);
        expect(call.state, equals(TelecomCallState.holding));
        expect(call.held, isTrue);
        expect(log.length, equals(1));
      });

      test('should unhold call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('unholdCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.holding,
          held: true,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.unholdCall(call);

        // assert
        expect(result, isTrue);
        expect(call.state, equals(TelecomCallState.active));
        expect(call.held, isFalse);
        expect(log.length, equals(1));
      });

      test('should mute call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('muteCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.muteCall(call);

        // assert
        expect(result, isTrue);
        expect(call.muted, isTrue);
        expect(log.length, equals(1));
      });

      test('should unmute call successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('unMuteCall'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          muted: true,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.unmuteCall(call);

        // assert
        expect(result, isTrue);
        expect(call.muted, isFalse);
        expect(log.length, equals(1));
      });

      test('should enable speaker successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('useSpeaker'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.useSpeaker(call);

        // assert
        expect(result, isTrue);
        expect(call.speaker, isTrue);
        expect(log.length, equals(1));
      });

      test('should enable earpiece successfully', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_tele'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('useEarpiece'));
            expect(methodCall.arguments['callId'], equals(1));
            return null;
          },
        );

        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          speaker: true,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // act
        final result = await telecomService.useEarpiece(call);

        // assert
        expect(result, isTrue);
        expect(call.speaker, isFalse);
        expect(log.length, equals(1));
      });
    });

    group('Call State Tracking', () {
      test('should track active calls', () async {
        // arrange
        await telecomService.initialize();
        await telecomService.startService();

        final call1 = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        final call2 = TelecomCall(
          id: 2,
          destination: '0987654321',
          state: TelecomCallState.holding,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '0987654321',
        );

        // Manually add calls to internal tracking
        // (In real scenario, this happens via event channel)

        // act & assert - get active calls
        final activeCalls = telecomService.getActiveCalls();
        expect(activeCalls.length, equals(0)); // No calls added yet

        // act & assert - get all calls
        final allCalls = telecomService.getAllCalls();
        expect(allCalls.length, equals(0));

        // act & assert - get call by ID
        final call = telecomService.getCall(1);
        expect(call, isNull);
      });

      test('should handle call event from native', () async {
        // arrange
        await telecomService.initialize();

        final callData = {
          'id': 1,
          'destination': '1234567890',
          'sim': 1,
          'state': TelecomCallState.active,
          'held': false,
          'muted': false,
          'speaker': false,
          'direction': TelecomCallDirection.outgoing,
          'remoteNumber': '1234567890',
          'remoteName': '',
        };

        // Simulate event channel receiving call event
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const EventChannel('flutter_tele_events'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'listen') {
              return Stream.value({
                'type': 'call_received',
                'data': callData,
              });
            }
            return null;
          },
        );

        // Reinitialize to trigger event
        telecomService.dispose();
        telecomService = AndroidTelecomService();
        await telecomService.initialize();

        // Allow time for event processing
        await Future.delayed(const Duration(milliseconds: 100));

        // assert
        final calls = telecomService.getAllCalls();
        expect(calls.length, equals(1));
        expect(calls.first.id, equals(1));
        expect(calls.first.state, equals(TelecomCallState.active));
      });
    });

    group('TelecomCall Model', () {
      test('should create from Map', () {
        // arrange
        final map = {
          'id': 1,
          'destination': '1234567890',
          'sim': 2,
          'state': TelecomCallState.active,
          'held': true,
          'muted': false,
          'speaker': true,
          'direction': TelecomCallDirection.incoming,
          'remoteNumber': '1234567890',
          'remoteName': 'John Doe',
        };

        // act
        final call = TelecomCall.fromMap(map);

        // assert
        expect(call.id, equals(1));
        expect(call.destination, equals('1234567890'));
        expect(call.sim, equals(2));
        expect(call.state, equals(TelecomCallState.active));
        expect(call.held, isTrue);
        expect(call.muted, isFalse);
        expect(call.speaker, isTrue);
        expect(call.direction, equals(TelecomCallDirection.incoming));
        expect(call.remoteNumber, equals('1234567890'));
        expect(call.remoteName, equals('John Doe'));
      });

      test('should convert to Map', () {
        // arrange
        final call = TelecomCall(
          id: 1,
          destination: '1234567890',
          sim: 1,
          state: TelecomCallState.active,
          held: false,
          muted: true,
          speaker: false,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
          remoteName: '',
        );

        // act
        final map = call.toMap();

        // assert
        expect(map['id'], equals(1));
        expect(map['destination'], equals('1234567890'));
        expect(map['sim'], equals(1));
        expect(map['state'], equals(TelecomCallState.active));
        expect(map['held'], isFalse);
        expect(map['muted'], isTrue);
        expect(map['speaker'], isFalse);
        expect(map['direction'], equals(TelecomCallDirection.outgoing));
        expect(map['remoteNumber'], equals('1234567890'));
        expect(map['remoteName'], equals(''));
      });

      test('should handle null values in fromMap', () {
        // arrange
        final map = <String, dynamic>{};

        // act
        final call = TelecomCall.fromMap(map);

        // assert - should use defaults
        expect(call.id, equals(0));
        expect(call.destination, equals(''));
        expect(call.sim, equals(1));
        expect(call.state, equals(TelecomCallState.unknown));
        expect(call.held, isFalse);
        expect(call.muted, isFalse);
        expect(call.speaker, isFalse);
        expect(call.direction, equals(TelecomCallDirection.outgoing));
        expect(call.remoteNumber, equals(''));
        expect(call.remoteName, equals(''));
      });

      test('should check if call is active', () {
        // arrange
        final activeCall = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        final ringingCall = TelecomCall(
          id: 2,
          destination: '1234567890',
          state: TelecomCallState.ringing,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // assert
        expect(activeCall.isActive, isTrue);
        expect(ringingCall.isActive, isFalse);
      });

      test('should check if call is ringing', () {
        // arrange
        final ringingCall = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.ringing,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        final activeCall = TelecomCall(
          id: 2,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // assert
        expect(ringingCall.isRinging, isTrue);
        expect(activeCall.isRinging, isFalse);
      });

      test('should check if call is disconnected', () {
        // arrange
        final disconnectedCall = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.disconnected,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        final activeCall = TelecomCall(
          id: 2,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // assert
        expect(disconnectedCall.isDisconnected, isTrue);
        expect(activeCall.isDisconnected, isFalse);
      });

      test('should check if call is dialing', () {
        // arrange
        final dialingCall = TelecomCall(
          id: 1,
          destination: '1234567890',
          state: TelecomCallState.dialing,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        final activeCall = TelecomCall(
          id: 2,
          destination: '1234567890',
          state: TelecomCallState.active,
          direction: TelecomCallDirection.outgoing,
          remoteNumber: '1234567890',
        );

        // assert
        expect(dialingCall.isDialing, isTrue);
        expect(activeCall.isDialing, isFalse);
      });
    });

    group('TelecomCallSettings', () {
      test('should create with defaults', () {
        // arrange & act
        final settings = TelecomCallSettings();

        // assert
        expect(settings.simSlot, equals(1));
        expect(settings.useSpeaker, isFalse);
        expect(settings.useVideo, isFalse);
      });

      test('should create with custom values', () {
        // arrange & act
        final settings = TelecomCallSettings(
          simSlot: 2,
          useSpeaker: true,
          useVideo: true,
        );

        // assert
        expect(settings.simSlot, equals(2));
        expect(settings.useSpeaker, isTrue);
        expect(settings.useVideo, isTrue);
      });

      test('should convert to Map', () {
        // arrange
        final settings = TelecomCallSettings(
          simSlot: 2,
          useSpeaker: true,
          useVideo: false,
        );

        // act
        final map = settings.toMap();

        // assert
        expect(map['sim'], equals(2));
        expect(map['useSpeaker'], isTrue);
        expect(map['useVideo'], isFalse);
      });
    });

    group('TelecomCallState Constants', () {
      test('should have correct state values', () {
        expect(TelecomCallState.nullState, equals('NULL'));
        expect(TelecomCallState.ringing, equals('RINGING'));
        expect(TelecomCallState.dialing, equals('DIALING'));
        expect(TelecomCallState.connecting, equals('CONNECTING'));
        expect(TelecomCallState.active, equals('ACTIVE'));
        expect(TelecomCallState.holding, equals('HOLDING'));
        expect(TelecomCallState.disconnected, equals('DISCONNECTED'));
        expect(TelecomCallState.unknown, equals('UNKNOWN'));
      });
    });

    group('TelecomCallDirection Constants', () {
      test('should have correct direction values', () {
        expect(TelecomCallDirection.incoming, equals('DIRECTION_INCOMING'));
        expect(TelecomCallDirection.outgoing, equals('DIRECTION_OUTGOING'));
      });
    });
  });
}
