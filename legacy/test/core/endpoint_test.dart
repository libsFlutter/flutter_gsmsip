import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/core/event_streaming/endpoint2.dart';
import 'package:flutter_gsm_sip_gateway/core/event_streaming/tele_endpoint.dart' as legacy;

void main() {
  group('Endpoint2', () {
    late Endpoint2 endpoint;
    late List<MethodCall> log;

    setUp(() async {
      endpoint = Endpoint2();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_pjsip'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('flutter_pjsip'),
        null,
      );
    });

    group('initial state', () {
      test('should start in idle state', () {
        // assert
        expect(endpoint.state, equals(Endpoint2State.idle));
        expect(endpoint.isInitialized, isFalse);
        expect(endpoint.isStarted, isFalse);
        expect(endpoint.isRunning, isFalse);
        expect(endpoint.isReconnecting, isFalse);
        expect(endpoint.configuration, isNull);
      });
    });

    group('initialize', () {
      test('should initialize successfully', () async {
        // act
        final result = await endpoint.initialize();

        // assert
        expect(result.isSuccess, isTrue);
        expect(endpoint.isInitialized, isTrue);
        expect(endpoint.state, equals(Endpoint2State.initialized));
      });

      test('should return success if already initialized', () async {
        // arrange
        await endpoint.initialize();

        // act
        final result = await endpoint.initialize();

        // assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle initialization failure', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('flutter_pjsip'),
          (MethodCall methodCall) async {
            throw Exception('Initialization failed');
          },
        );

        // act
        final result = await endpoint.initialize();

        // assert
        expect(result.isFailure, isTrue);
        expect(endpoint.state, equals(Endpoint2State.stopped));
      });
    });

    group('Result', () {
      test('should create successful result', () {
        // arrange
        const value = 'test';

        // act
        final result = Result.success(value);

        // assert
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
        expect(result.value, equals('test'));
      });

      test('should create failed result', () {
        // arrange
        const error = 'test error';

        // act
        final result = Result.failure(error);

        // assert
        expect(result.isFailure, isTrue);
        expect(result.isSuccess, isFalse);
        expect(result.error, equals('test error'));
      });

      test('should getOrElse with default on failure', () {
        // arrange
        final result = Result<String>.failure('error');

        // act
        final value = result.getOrElse('default');

        // assert
        expect(value, equals('default'));
      });

      test('should getOrElse with value on success', () {
        // arrange
        final result = Result.success('actual');

        // act
        final value = result.getOrElse('default');

        // assert
        expect(value, equals('actual'));
      });

      test('should map successful result', () {
        // arrange
        final result = Result.success(5);

        // act
        final mapped = result.map((v) => v * 2);

        // assert
        expect(mapped.isSuccess, isTrue);
        expect(mapped.value, equals(10));
      });

      test('should map failed result', () {
        // arrange
        final result = Result<int>.failure('error');

        // act
        final mapped = result.map((v) => v * 2);

        // assert
        expect(mapped.isFailure, isTrue);
        expect(mapped.error, equals('error'));
      });

      test('should throw on getting value from failed result', () {
        // arrange
        final result = Result<String>.failure('error');

        // assert
        expect(() => result.value, throwsStateError);
      });

      test('should throw on getting error from successful result', () {
        // arrange
        final result = Result.success('value');

        // assert
        expect(() => result.error, throwsStateError);
      });

      test('should toString for success', () {
        // arrange
        final result = Result.success('test');

        // assert
        expect(result.toString(), contains('Result.success'));
        expect(result.toString(), contains('test'));
      });

      test('should toString for failure', () {
        // arrange
        final result = Result.failure('error');

        // assert
        expect(result.toString(), contains('Result.failure'));
        expect(result.toString(), contains('error'));
      });
    });

    group('Endpoint2Configuration', () {
      test('should create with builder', () {
        // act
        final config = Endpoint2Configuration.builder()
            .userAgent('TestApp/1.0')
            .port(5060)
            .stunServers(['stun.example.com'])
            .enableVideo(true)
            .autoReconnect(false)
            .maxReconnectAttempts(5)
            .reconnectDelay(const Duration(seconds: 10))
            .build();

        // assert
        expect(config.userAgent, equals('TestApp/1.0'));
        expect(config.port, equals(5060));
        expect(config.stunServers, equals(['stun.example.com']));
        expect(config.useVideo, isTrue);
        expect(config.autoReconnect, isFalse);
        expect(config.maxReconnectAttempts, equals(5));
        expect(config.reconnectDelay, equals(const Duration(seconds: 10)));
      });

      test('should create with default values', () {
        // act
        final config = Endpoint2Configuration.builder().build();

        // assert
        expect(config.autoReconnect, isTrue);
        expect(config.maxReconnectAttempts, equals(3));
        expect(config.reconnectDelay, equals(const Duration(seconds: 5)));
      });

      test('should create from legacy configuration', () {
        // arrange
        final legacyConfig = legacy.EndpointConfiguration(
          userAgent: 'Legacy/1.0',
          port: 5070,
          stunServers: ['stun.legacy.com'],
          useVideo: false,
        );

        // act
        final config = Endpoint2Configuration.fromLegacy(legacyConfig);

        // assert
        expect(config.userAgent, equals('Legacy/1.0'));
        expect(config.port, equals(5070));
        expect(config.stunServers, equals(['stun.legacy.com']));
        expect(config.useVideo, isFalse);
      });

      test('should convert to legacy configuration', () {
        // arrange
        final config = Endpoint2Configuration.builder()
            .userAgent('Test/1.0')
            .port(5060)
            .build();

        // act
        final legacyConfig = config.toLegacy();

        // assert
        expect(legacyConfig.userAgent, equals('Test/1.0'));
        expect(legacyConfig.port, equals(5060));
      });

      test('should convert to Map', () {
        // arrange
        final config = Endpoint2Configuration.builder()
            .userAgent('Test/1.0')
            .port(5060)
            .build();

        // act
        final map = config.toMap();

        // assert
        expect(map, isA<Map<String, dynamic>>());
        expect(map['userAgent'], equals('Test/1.0'));
        expect(map['port'], equals(5060));
      });
    });

    group('Endpoint2Events', () {
      test('should provide registrationChanged stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.registrationChanged, isNotNull);
        events.dispose();
      });

      test('should provide callReceived stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.callReceived, isNotNull);
        events.dispose();
      });

      test('should provide callChanged stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.callChanged, isNotNull);
        events.dispose();
      });

      test('should provide callTerminated stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.callTerminated, isNotNull);
        events.dispose();
      });

      test('should provide messageReceived stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.messageReceived, isNotNull);
        events.dispose();
      });

      test('should provide connectivityChanged stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.connectivityChanged, isNotNull);
        events.dispose();
      });

      test('should provide error stream', () {
        // arrange
        final events = Endpoint2Events();

        // assert
        expect(events.error, isNotNull);
        events.dispose();
      });
    });

    group('Endpoint2Error', () {
      test('should create with required fields', () {
        // arrange
        const code = 'TEST_ERROR';
        const message = 'Test error message';

        // act
        final error = Endpoint2Error(code: code, message: message);

        // assert
        expect(error.code, equals(code));
        expect(error.message, equals(message));
        expect(error.details, isNull);
        expect(error.timestamp, isNotNull);
      });

      test('should create with optional details', () {
        // arrange
        const error = Endpoint2Error(
          code: 'TEST_ERROR',
          message: 'Test error',
          details: 'Additional details',
        );

        // assert
        expect(error.code, equals('TEST_ERROR'));
        expect(error.message, equals('Test error'));
        expect(error.details, equals('Additional details'));
      });

      test('should create from PlatformException', () {
        // arrange
        final platformException = PlatformException(
          code: 'NATIVE_ERROR',
          message: 'Native error occurred',
          details: {'key': 'value'},
        );

        // act
        final error = Endpoint2Error.fromPlatformException(platformException);

        // assert
        expect(error.code, equals('NATIVE_ERROR'));
        expect(error.message, equals('Native error occurred'));
        expect(error.details, isNotNull);
      });

      test('should handle null code and message from PlatformException', () {
        // arrange
        final platformException = PlatformException(
          code: null,
          message: null,
        );

        // act
        final error = Endpoint2Error.fromPlatformException(platformException);

        // assert
        expect(error.code, equals('UNKNOWN'));
        expect(error.message, equals('Unknown platform error'));
      });

      test('should toString', () {
        // arrange
        const error = Endpoint2Error(
          code: 'TEST_ERROR',
          message: 'Test message',
        );

        // assert
        expect(error.toString(), equals('Endpoint2Error(TEST_ERROR): Test message'));
      });
    });

    group('Endpoint2State', () {
      test('should have all expected states', () {
        // assert
        expect(Endpoint2State.values.length, equals(5));
        expect(Endpoint2State.values, contains(Endpoint2State.idle));
        expect(Endpoint2State.values, contains(Endpoint2State.initialized));
        expect(Endpoint2State.values, contains(Endpoint2State.running));
        expect(Endpoint2State.values, contains(Endpoint2State.reconnecting));
        expect(Endpoint2State.values, contains(Endpoint2State.stopped));
      });
    });

    group('Endpoint2CallOperations', () {
      group('make', () {
        test('should return Result.success on successful call', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              expect(methodCall.method, equals('makeCall'));
              return {'id': 'call1', 'accountId': 'acc1'};
            },
          );

          // act
          final result = await endpoint.calls.make(
            account: account,
            destination: '1234567890',
          );

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.length, equals(1));
          expect(log.first.method, equals('makeCall'));
        });

        test('should return Result.failure on null response', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async => null,
          );

          // act
          final result = await endpoint.calls.make(
            account: account,
            destination: '1234567890',
          );

          // assert
          expect(result.isFailure, isTrue);
          expect(result.error, contains('Null response'));
        });

        test('should return Result.failure on PlatformException', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              throw PlatformException(
                code: 'CALL_ERROR',
                message: 'Failed to make call',
              );
            },
          );

          // act
          final result = await endpoint.calls.make(
            account: account,
            destination: '1234567890',
          );

          // assert
          expect(result.isFailure, isTrue);
          expect(result.error, contains('Failed to make call'));
        });
      });

      group('answer', () {
        test('should return Result.success on successful answer', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              expect(methodCall.method, equals('answerCall'));
              return null;
            },
          );

          // act
          final result = await endpoint.calls.answer(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('answerCall'));
        });

        test('should return Result.failure on error', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              throw PlatformException(
                code: 'ANSWER_ERROR',
                message: 'Failed to answer',
              );
            },
          );

          // act
          final result = await endpoint.calls.answer(call);

          // assert
          expect(result.isFailure, isTrue);
        });
      });

      group('hangup', () {
        test('should return Result.success on successful hangup', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.calls.hangup(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('hangupCall'));
        });
      });

      group('hold', () {
        test('should return Result.success on successful hold', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.calls.hold(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('holdCall'));
        });
      });

      group('unhold', () {
        test('should return Result.success on successful unhold', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.calls.unhold(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('unholdCall'));
        });
      });

      group('mute', () {
        test('should return Result.success on successful mute', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.calls.mute(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('muteCall'));
        });
      });

      group('unmute', () {
        test('should return Result.success on successful unmute', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.calls.unmute(call);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('unmuteCall'));
        });
      });

      group('transfer', () {
        test('should return Result.success on successful transfer', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              expect(methodCall.arguments['target'], equals('1234567890'));
              return null;
            },
          );

          // act
          final result = await endpoint.calls.transfer(call, '1234567890');

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('xferCall'));
        });
      });

      group('dtmf', () {
        test('should return Result.success on successful DTMF', () async {
          // arrange
          await endpoint.initialize();
          final call = legacy.Call({'id': 'call1'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              expect(methodCall.arguments['digits'], equals('123#'));
              return null;
            },
          );

          // act
          final result = await endpoint.calls.dtmf(call, '123#');

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('dtmfCall'));
        });
      });
    });

    group('Endpoint2AccountOperations', () {
      group('create', () {
        test('should return Result.success on successful create', () async {
          // arrange
          await endpoint.initialize();
          final config = legacy.AccountConfiguration(
            username: 'testuser',
            password: 'testpass',
            domain: 'sip.example.com',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              expect(methodCall.method, equals('createAccount'));
              return {'id': 'acc1', 'username': 'testuser'};
            },
          );

          // act
          final result = await endpoint.accounts.create(config);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('createAccount'));
        });

        test('should return Result.failure on null response', () async {
          // arrange
          await endpoint.initialize();
          final config = legacy.AccountConfiguration(
            username: 'testuser',
            password: 'testpass',
            domain: 'sip.example.com',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async => null,
          );

          // act
          final result = await endpoint.accounts.create(config);

          // assert
          expect(result.isFailure, isTrue);
          expect(result.error, contains('Null response'));
        });
      });

      group('register', () {
        test('should return Result.success on successful register', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.accounts.register(account);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('registerAccount'));
        });
      });

      group('unregister', () {
        test('should return Result.success on successful unregister', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.accounts.unregister(account);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('unregisterAccount'));
        });
      });

      group('delete', () {
        test('should return Result.success on successful delete', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return null;
            },
          );

          // act
          final result = await endpoint.accounts.delete(account);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('deleteAccount'));
        });
      });

      group('replace', () {
        test('should return Result.success on successful replace', () async {
          // arrange
          await endpoint.initialize();
          final account = legacy.Account({'id': 'acc1', 'username': 'test'});
          final config = legacy.AccountConfiguration(
            username: 'newuser',
            password: 'newpass',
            domain: 'sip.example.com',
          );

          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .setMockMethodCallHandler(
            const MethodChannel('flutter_pjsip'),
            (MethodCall methodCall) async {
              log.add(methodCall);
              return {'id': 'acc1', 'username': 'newuser'};
            },
          );

          // act
          final result = await endpoint.accounts.replace(account, config);

          // assert
          expect(result.isSuccess, isTrue);
          expect(log.first.method, equals('replaceAccount'));
        });
      });
    });
  });
}
