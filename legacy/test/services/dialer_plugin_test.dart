import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/dialer_plugin.dart';

void main() {
  group('DialerPlugin', () {
    late DialerPlugin dialerPlugin;
    late List<MethodCall> log;

    setUp(() async {
      dialerPlugin = DialerPlugin();
      log = <MethodCall>[];

      // Setup method channel handler for testing
      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('org.telon/replace_dialer'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('org.telon/replace_dialer'),
        null,
      );
    });

    group('isDefaultDialer', () {
      test('should return true when app is default dialer', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, 'isDefaultDialer');
            return true;
          },
        );

        // act
        final result = await dialerPlugin.isDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('isDefaultDialer'));
      });

      test('should return false when app is not default dialer', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return false;
          },
        );

        // act
        final result = await dialerPlugin.isDefaultDialer();

        // assert
        expect(result, isFalse);
      });

      test('should return false when result is null', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            return null;
          },
        );

        // act
        final result = await dialerPlugin.isDefaultDialer();

        // assert
        expect(result, isFalse);
      });

      test('should throw DialerPluginException on platform error', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Failed to check default dialer',
            );
          },
        );

        // act & assert
        expect(
          () => dialerPlugin.isDefaultDialer(),
          throwsA(isA<DialerPluginException>().having(
            (e) => e.code,
            'code',
            'IS_DEFAULT_DIALER_ERROR',
          )),
        );
      });
    });

    group('setDefaultDialer', () {
      test('should return true when user confirms', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, 'setDefaultDialer');
            return true;
          },
        );

        // act
        final result = await dialerPlugin.setDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('setDefaultDialer'));
      });

      test('should return false when user cancels', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return false;
          },
        );

        // act
        final result = await dialerPlugin.setDefaultDialer();

        // assert
        expect(result, isFalse);
      });

      test('should throw CALL_IN_PROGRESS when another request is in progress', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'CALL_IN_PROGRESS',
              message: 'Another request is already in progress',
            );
          },
        );

        // act & assert
        expect(
          () => dialerPlugin.setDefaultDialer(),
          throwsA(isA<DialerPluginException>().having(
            (e) => e.code,
            'code',
            'CALL_IN_PROGRESS',
          )),
        );
      });

      test('should throw DialerPluginException on platform error', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Failed to set default dialer',
            );
          },
        );

        // act & assert
        expect(
          () => dialerPlugin.setDefaultDialer(),
          throwsA(isA<DialerPluginException>().having(
            (e) => e.code,
            'code',
            'SET_DEFAULT_DIALER_ERROR',
          )),
        );
      });
    });

    group('canSetDefaultDialer', () {
      test('should return true when app can be set as default dialer', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, 'canSetDefaultDialer');
            return true;
          },
        );

        // act
        final result = await dialerPlugin.canSetDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('canSetDefaultDialer'));
      });

      test('should return false when app cannot be set as default dialer', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return false;
          },
        );

        // act
        final result = await dialerPlugin.canSetDefaultDialer();

        // assert
        expect(result, isFalse);
      });

      test('should throw DialerPluginException on platform error', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Failed to check capability',
            );
          },
        );

        // act & assert
        expect(
          () => dialerPlugin.canSetDefaultDialer(),
          throwsA(isA<DialerPluginException>().having(
            (e) => e.code,
            'code',
            'CAN_SET_DEFAULT_DIALER_ERROR',
          )),
        );
      });
    });
  });

  group('TeleDialer (Static Utility)', () {
    late List<MethodCall> log;

    setUp(() async {
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('org.telon/replace_dialer'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('org.telon/replace_dialer'),
        null,
      );
    });

    group('isDefaultDialer', () {
      test('should call underlying plugin method', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return true;
          },
        );

        // act
        final result = await TeleDialer.isDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('isDefaultDialer'));
      });
    });

    group('setDefaultDialer', () {
      test('should call underlying plugin method', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return true;
          },
        );

        // act
        final result = await TeleDialer.setDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('setDefaultDialer'));
      });
    });

    group('canSetDefaultDialer', () {
      test('should call underlying plugin method', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return false;
          },
        );

        // act
        final result = await TeleDialer.canSetDefaultDialer();

        // assert
        expect(result, isFalse);
        expect(log.length, equals(1));
        expect(log.first.method, equals('canSetDefaultDialer'));
      });
    });

    group('requestDefaultDialer', () {
      test('should call underlying plugin method', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('org.telon/replace_dialer'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            return true;
          },
        );

        // act
        final result = await TeleDialer.requestDefaultDialer();

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('setDefaultDialer'));
      });
    });
  });

  group('DialerPluginException', () {
    test('should create exception with code and message', () {
      // arrange & act
      const exception = DialerPluginException(
        'TEST_ERROR',
        'Test error message',
      );

      // assert
      expect(exception.code, equals('TEST_ERROR'));
      expect(exception.message, equals('Test error message'));
      expect(exception.originalException, isNull);
    });

    test('should create exception with original exception', () {
      // arrange
      final originalException = PlatformException(
        code: 'ORIGINAL',
        message: 'Original error',
      );

      // act
      const exception = DialerPluginException(
        'WRAPPED_ERROR',
        'Wrapped error message',
        originalException,
      );

      // assert
      expect(exception.code, equals('WRAPPED_ERROR'));
      expect(exception.message, equals('Wrapped error message'));
      expect(exception.originalException, equals(originalException));
    });

    test('should toString without original exception', () {
      // arrange
      const exception = DialerPluginException(
        'TEST_ERROR',
        'Test error message',
      );

      // assert
      expect(
        exception.toString(),
        equals('DialerPluginException(TEST_ERROR): Test error message'),
      );
    });

    test('should toString with original exception', () {
      // arrange
      final originalException = PlatformException(
        code: 'ORIGINAL',
        message: 'Original error',
      );

      const exception = DialerPluginException(
        'WRAPPED_ERROR',
        'Wrapped error message',
        originalException,
      );

      // assert
      expect(
        exception.toString(),
        equals(
          'DialerPluginException(WRAPPED_ERROR): Wrapped error message (caused by: PlatformException(ORIGINAL, Original error, null))',
        ),
      );
    });
  });
}
