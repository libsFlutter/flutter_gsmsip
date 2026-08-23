import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/telephony_integration.dart';
import 'package:flutter_gsm_sip_gateway/services/sip_service.dart';
import 'package:flutter_gsm_sip_gateway/services/telephony_service.dart';

void main() {
  group('TelephonyIntegration', () {
    late TelephonyIntegration integration;
    late List<MethodCall> log;

    setUp(() async {
      integration = TelephonyIntegration();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/telephony_integration'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return {'success': true};
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/telephony_integration'),
        null,
      );
      integration.dispose();
    });

    group('initialize', () {
      test('should initialize successfully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/telephony_integration'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return {'success': true};
          },
        );

        // act
        final result = await integration.initialize();

        // assert
        expect(result, isTrue);
        expect(integration.isInitialized, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('registerConnectionService'));
      });

      test('should handle initialization failure', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/telephony_integration'),
          (MethodCall methodCall) async {
            throw Exception('Initialization failed');
          },
        );

        // act
        final result = await integration.initialize();

        // assert
        expect(result, isFalse);
        expect(integration.isInitialized, isFalse);
      });
    });

    group('getStatus', () {
      test('should return status map with correct fields', () async {
        // arrange
        await integration.initialize();

        // act
        final status = integration.getStatus();

        // assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status['isInitialized'], isTrue);
        expect(status.containsKey('isConnectionServiceRegistered'), isTrue);
        expect(status.containsKey('activeCallsCount'), isTrue);
        expect(status.containsKey('gsmCallsCount'), isTrue);
        expect(status.containsKey('sipCallsCount'), isTrue);
        expect(status.containsKey('bridgedCallsCount'), isTrue);
        expect(status.containsKey('activeCalls'), isTrue);
      });

      test('should show zero active calls initially', () async {
        // arrange
        await integration.initialize();

        // act
        final status = integration.getStatus();

        // assert
        expect(status['activeCallsCount'], equals(0));
        expect(status['gsmCallsCount'], equals(0));
        expect(status['sipCallsCount'], equals(0));
        expect(status['bridgedCallsCount'], equals(0));
      });
    });

    group('activeCalls', () {
      test('should return empty list initially', () async {
        // act
        final calls = integration.activeCalls;

        // assert
        expect(calls, isEmpty);
      });
    });

    group('call state streams', () {
      test('should provide callStateStream', () async {
        // assert
        expect(integration.callStateStream, isNotNull);
      });

      test('should provide logStream', () async {
        // assert
        expect(integration.logStream, isNotNull);
      });

      test('should provide syncStateStream', () async {
        // assert
        expect(integration.syncStateStream, isNotNull);
      });
    });

    group('IntegratedCall', () {
      test('should create IntegratedCall with required fields', () {
        // arrange
        final startTime = DateTime.now();

        // act
        final call = IntegratedCall(
          id: 'call1',
          number: '+1234567890',
          direction: IntegrationCallDirection.incoming,
          state: IntegrationCallState.ringing,
          callType: CallType.gsm,
          startTime: startTime,
        );

        // assert
        expect(call.id, equals('call1'));
        expect(call.number, equals('+1234567890'));
        expect(call.direction, equals(IntegrationCallDirection.incoming));
        expect(call.state, equals(IntegrationCallState.ringing));
        expect(call.callType, equals(CallType.gsm));
        expect(call.startTime, equals(startTime));
        expect(call.connectTime, isNull);
        expect(call.duration, isNull);
        expect(call.linkedGsmCallId, isNull);
        expect(call.linkedSipCallId, isNull);
      });

      test('should create IntegratedCall with all fields', () {
        // arrange
        final startTime = DateTime.now();
        final connectTime = DateTime.now().add(const Duration(seconds: 5));
        final duration = const Duration(seconds: 30);

        // act
        final call = IntegratedCall(
          id: 'call1',
          number: '+1234567890',
          direction: IntegrationCallDirection.outgoing,
          state: IntegrationCallState.active,
          callType: CallType.bridged,
          startTime: startTime,
          connectTime: connectTime,
          duration: duration,
          linkedGsmCallId: 'gsm1',
          linkedSipCallId: 'sip1',
        );

        // assert
        expect(call.id, equals('call1'));
        expect(call.number, equals('+1234567890'));
        expect(call.direction, equals(IntegrationCallDirection.outgoing));
        expect(call.state, equals(IntegrationCallState.active));
        expect(call.callType, equals(CallType.bridged));
        expect(call.startTime, equals(startTime));
        expect(call.connectTime, equals(connectTime));
        expect(call.duration, equals(duration));
        expect(call.linkedGsmCallId, equals('gsm1'));
        expect(call.linkedSipCallId, equals('sip1'));
      });

      test('should copyWith updated fields', () {
        // arrange
        final startTime = DateTime.now();
        final call = IntegratedCall(
          id: 'call1',
          number: '+1234567890',
          direction: IntegrationCallDirection.incoming,
          state: IntegrationCallState.ringing,
          callType: CallType.gsm,
          startTime: startTime,
        );

        // act
        final updatedCall = call.copyWith(
          state: IntegrationCallState.active,
          connectTime: DateTime.now(),
        );

        // assert
        expect(updatedCall.id, equals(call.id));
        expect(updatedCall.number, equals(call.number));
        expect(updatedCall.direction, equals(call.direction));
        expect(updatedCall.state, equals(IntegrationCallState.active));
        expect(updatedCall.callType, equals(call.callType));
        expect(updatedCall.connectTime, isNotNull);
      });

      test('should toString with basic info', () {
        // arrange
        final call = IntegratedCall(
          id: 'call1',
          number: '+1234567890',
          direction: IntegrationCallDirection.incoming,
          state: IntegrationCallState.active,
          callType: CallType.gsm,
          startTime: DateTime.now(),
        );

        // act & assert
        expect(
          call.toString(),
          contains('call1'),
        );
        expect(
          call.toString(),
          contains('+1234567890'),
        );
      });
    });

    group('IntegrationCallState', () {
      test('should have all expected states', () {
        // assert
        expect(IntegrationCallState.values.length, equals(8));
        expect(IntegrationCallState.values, contains(IntegrationCallState.idle));
        expect(IntegrationCallState.values, contains(IntegrationCallState.ringing));
        expect(IntegrationCallState.values, contains(IntegrationCallState.dialing));
        expect(IntegrationCallState.values, contains(IntegrationCallState.active));
        expect(IntegrationCallState.values, contains(IntegrationCallState.hold));
        expect(IntegrationCallState.values, contains(IntegrationCallState.disconnecting));
        expect(IntegrationCallState.values, contains(IntegrationCallState.ended));
        expect(IntegrationCallState.values, contains(IntegrationCallState.failed));
      });
    });

    group('IntegrationCallDirection', () {
      test('should have incoming and outgoing', () {
        // assert
        expect(IntegrationCallDirection.values.length, equals(2));
        expect(IntegrationCallDirection.values, contains(IntegrationCallDirection.incoming));
        expect(IntegrationCallDirection.values, contains(IntegrationCallDirection.outgoing));
      });
    });

    group('CallType', () {
      test('should have gsm, sip, and bridged', () {
        // assert
        expect(CallType.values.length, equals(3));
        expect(CallType.values, contains(CallType.gsm));
        expect(CallType.values, contains(CallType.sip));
        expect(CallType.values, contains(CallType.bridged));
      });
    });

    group('IntegratedCallExtension', () {
      test('should convert IntegratedCall to Map', () {
        // arrange
        final startTime = DateTime(2024, 1, 1, 12, 0, 0);
        final connectTime = DateTime(2024, 1, 1, 12, 0, 5);
        final call = IntegratedCall(
          id: 'call1',
          number: '+1234567890',
          direction: IntegrationCallDirection.outgoing,
          state: IntegrationCallState.active,
          callType: CallType.bridged,
          startTime: startTime,
          connectTime: connectTime,
          duration: const Duration(seconds: 30),
          linkedGsmCallId: 'gsm1',
          linkedSipCallId: 'sip1',
        );

        // act
        final map = call.toMap();

        // assert
        expect(map['id'], equals('call1'));
        expect(map['number'], equals('+1234567890'));
        expect(map['direction'], equals('outgoing'));
        expect(map['state'], equals('active'));
        expect(map['callType'], equals('bridged'));
        expect(map['startTime'], equals(startTime.toIso8601String()));
        expect(map['connectTime'], equals(connectTime.toIso8601String()));
        expect(map['duration'], equals(30));
        expect(map['linkedGsmCallId'], equals('gsm1'));
        expect(map['linkedSipCallId'], equals('sip1'));
      });
    });

    group('TelephonyIntegration static methods', () {
      group('mapGsmState', () {
        test('should map GSM idle state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('idle');

          // assert
          expect(state, equals(IntegrationCallState.idle));
        });

        test('should map GSM ringing state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('ringing');

          // assert
          expect(state, equals(IntegrationCallState.ringing));
        });

        test('should map GSM offhook state to active', () {
          // act
          final state = TelephonyIntegration.mapGsmState('offhook');

          // assert
          expect(state, equals(IntegrationCallState.active));
        });

        test('should map GSM active state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('active');

          // assert
          expect(state, equals(IntegrationCallState.active));
        });

        test('should map GSM hold state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('hold');

          // assert
          expect(state, equals(IntegrationCallState.hold));
        });

        test('should map GSM disconnecting state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('disconnecting');

          // assert
          expect(state, equals(IntegrationCallState.disconnecting));
        });

        test('should map GSM ended state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('ended');

          // assert
          expect(state, equals(IntegrationCallState.ended));
        });

        test('should map GSM failed state', () {
          // act
          final state = TelephonyIntegration.mapGsmState('failed');

          // assert
          expect(state, equals(IntegrationCallState.failed));
        });

        test('should map unknown state to idle', () {
          // act
          final state = TelephonyIntegration.mapGsmState('unknown_state');

          // assert
          expect(state, equals(IntegrationCallState.idle));
        });

        test('should handle case-insensitive mapping', () {
          // act
          final state = TelephonyIntegration.mapGsmState('RINGING');

          // assert
          expect(state, equals(IntegrationCallState.ringing));
        });
      });

      group('mapSipState', () {
        test('should map SIP connecting state to dialing', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.connecting);

          // assert
          expect(state, equals(IntegrationCallState.dialing));
        });

        test('should map SIP ringing state', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.ringing);

          // assert
          expect(state, equals(IntegrationCallState.ringing));
        });

        test('should map SIP active state', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.active);

          // assert
          expect(state, equals(IntegrationCallState.active));
        });

        test('should map SIP hold state', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.hold);

          // assert
          expect(state, equals(IntegrationCallState.hold));
        });

        test('should map SIP ended state', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.ended);

          // assert
          expect(state, equals(IntegrationCallState.ended));
        });

        test('should map SIP failed state', () {
          // act
          final state = TelephonyIntegration.mapSipState(SipCallState.failed);

          // assert
          expect(state, equals(IntegrationCallState.failed));
        });
      });
    });

    group('singleton', () {
      test('should return same instance', () {
        // arrange
        final instance1 = TelephonyIntegration();
        final instance2 = TelephonyIntegration();

        // assert
        expect(identical(instance1, instance2), isTrue);
      });
    });
  });
}
