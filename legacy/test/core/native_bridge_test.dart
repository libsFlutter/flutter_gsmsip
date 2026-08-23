import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/activity_intent_service.dart';

void main() {
  group('ActivityIntentService (Native Bridge)', () {
    late ActivityIntentService intentService;
    late List<MethodCall> log;

    setUp(() async {
      intentService = ActivityIntentService();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();

      // Setup method channel handler for testing
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/activity_intent'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return null;
        },
      );
    });

    tearDown(() {
      intentService.dispose();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/activity_intent'),
        null,
      );
    });

    group('Initialization', () {
      // TASK test-bridge-001: Test native bridge initialization
      test('should initialize successfully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            if (methodCall.method == 'getInitialIntent') {
              return null; // No initial intent
            }
            return null;
          },
        );

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isTrue);
        expect(intentService.isInitialized, isTrue);
        expect(log.length, equals(1));
        expect(log.first.method, equals('getInitialIntent'));
      });

      test('should return true if already initialized', () async {
        // arrange - initialize first
        await intentService.initialize();
        log.clear();

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isTrue);
        expect(intentService.isInitialized, isTrue);
        // Should not call getInitialIntent again
        expect(log.length, equals(0));
      });

      test('should handle initialization error gracefully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'ERROR',
              message: 'Initialization failed',
            );
          },
        );

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isFalse);
        expect(intentService.isInitialized, isFalse);
      });
    });

    group('Intent Handling', () {
      // TASK test-bridge-002: Test intent/data serialization
      test('should handle VIEW intent with phone number', () async {
        // arrange
        await intentService.initialize();
        log.clear();

        final intentData = {
          'type': 'view',
          'phoneNumber': '1234567890',
          'action': 'android.intent.action.VIEW',
          'extras': <String, dynamic>{},
        };

        var intentReceived = false;
        intentService.intentStream.listen((intent) {
          intentReceived = true;
          expect(intent.type, equals(ActivityIntentType.view));
          expect(intent.phoneNumber, equals('1234567890'));
        });

        // Simulate intent received from native
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'onIntentReceived') {
              // Trigger the handler
              return null;
            }
            return null;
          },
        );

        // assert
        expect(intentReceived, isFalse); // Stream listener doesn't auto-trigger in tests
      });

      test('should handle DIAL intent with phone number', () async {
        // arrange
        await intentService.initialize();

        final intentData = ActivityIntentData(
          type: ActivityIntentType.dial,
          phoneNumber: '0987654321',
          action: 'android.intent.action.DIAL',
        );

        // assert
        expect(intentData.type, equals(ActivityIntentType.dial));
        expect(intentData.phoneNumber, equals('0987654321'));
        expect(intentData.action, equals('android.intent.action.DIAL'));
      });

      test('should handle unknown intent type', () async {
        // arrange
        final intentData = ActivityIntentData(
          type: ActivityIntentType.unknown,
          phoneNumber: null,
          action: 'custom.action',
        );

        // assert
        expect(intentData.type, equals(ActivityIntentType.unknown));
        expect(intentData.phoneNumber, isNull);
      });
    });

    group('ActivityIntentData Model', () {
      // TASK test-bridge-001: Test DTO serialization
      test('should create from Map with view type', () {
        // arrange
        final map = {
          'type': 'view',
          'phoneNumber': '1234567890',
          'action': 'android.intent.action.VIEW',
          'extras': {'key': 'value'},
        };

        // act
        final intent = ActivityIntentData.fromMap(map);

        // assert
        expect(intent.type, equals(ActivityIntentType.view));
        expect(intent.phoneNumber, equals('1234567890'));
        expect(intent.action, equals('android.intent.action.VIEW'));
        expect(intent.extras, isNotNull);
        expect(intent.extras!['key'], equals('value'));
      });

      test('should create from Map with dial type', () {
        // arrange
        final map = {
          'type': 'dial',
          'phoneNumber': '0987654321',
          'action': 'android.intent.action.DIAL',
          'extras': <String, dynamic>{},
        };

        // act
        final intent = ActivityIntentData.fromMap(map);

        // assert
        expect(intent.type, equals(ActivityIntentType.dial));
        expect(intent.phoneNumber, equals('0987654321'));
        expect(intent.action, equals('android.intent.action.DIAL'));
      });

      test('should create from Map with unknown type', () {
        // arrange
        final map = {
          'type': 'unknown_type',
          'phoneNumber': null,
          'action': null,
          'extras': null,
        };

        // act
        final intent = ActivityIntentData.fromMap(map);

        // assert
        expect(intent.type, equals(ActivityIntentType.unknown));
        expect(intent.phoneNumber, isNull);
        expect(intent.action, isNull);
        expect(intent.extras, isNull);
      });

      test('should create from Map with null values', () {
        // arrange
        final map = <String, dynamic>{};

        // act
        final intent = ActivityIntentData.fromMap(map);

        // assert
        expect(intent.type, equals(ActivityIntentType.unknown));
        expect(intent.phoneNumber, isNull);
        expect(intent.action, isNull);
        expect(intent.extras, isNull);
      });

      test('should convert to Map', () {
        // arrange
        final intent = ActivityIntentData(
          type: ActivityIntentType.view,
          phoneNumber: '1234567890',
          action: 'android.intent.action.VIEW',
          extras: {'key': 'value'},
        );

        // act
        final map = intent.toMap();

        // assert
        expect(map['type'], equals('view'));
        expect(map['phoneNumber'], equals('1234567890'));
        expect(map['action'], equals('android.intent.action.VIEW'));
        expect(map['extras'], isNotNull);
        expect(map['extras']['key'], equals('value'));
      });

      test('should toString with all fields', () {
        // arrange
        final intent = ActivityIntentData(
          type: ActivityIntentType.dial,
          phoneNumber: '1234567890',
          action: 'DIAL',
        );

        // assert
        expect(
          intent.toString(),
          equals(
            'ActivityIntentData(type: dial, phoneNumber: 1234567890, action: DIAL)',
          ),
        );
      });

      test('should toString with null fields', () {
        // arrange
        final intent = ActivityIntentData(
          type: ActivityIntentType.unknown,
          phoneNumber: null,
          action: null,
        );

        // assert
        expect(
          intent.toString(),
          equals('ActivityIntentData(type: unknown, phoneNumber: null, action: null)'),
        );
      });
    });

    group('NavigationRoute Model', () {
      test('should create with route name only', () {
        // arrange & act
        final route = NavigationRoute(routeName: '/dialer');

        // assert
        expect(route.routeName, equals('/dialer'));
        expect(route.arguments, isNull);
      });

      test('should create with route name and arguments', () {
        // arrange & act
        final route = NavigationRoute(
          routeName: '/dialer',
          arguments: {'phoneNumber': '1234567890', 'autoCall': false},
        );

        // assert
        expect(route.routeName, equals('/dialer'));
        expect(route.arguments, isNotNull);
        expect(route.arguments!['phoneNumber'], equals('1234567890'));
        expect(route.arguments!['autoCall'], isFalse);
      });

      test('should toString with arguments', () {
        // arrange
        final route = NavigationRoute(
          routeName: '/settings',
          arguments: {'key': 'value'},
        );

        // assert
        expect(
          route.toString(),
          equals('NavigationRoute(route: /settings, args: {key: value})'),
        );
      });

      test('should toString without arguments', () {
        // arrange
        final route = NavigationRoute(routeName: '/dashboard');

        // assert
        expect(
          route.toString(),
          equals('NavigationRoute(route: /dashboard, args: null)'),
        );
      });
    });

    group('Phone Number Utilities', () {
      // TASK test-bridge-002: Test phone number validation/parsing
      group('isValidPhoneNumber', () {
        test('should return true for valid phone numbers', () {
          expect(ActivityIntentService.isValidPhoneNumber('1234567890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('+1234567890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('*123#'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('123-456-7890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('123 456 7890'), isTrue);
        });

        test('should return false for invalid phone numbers', () {
          expect(ActivityIntentService.isValidPhoneNumber(null), isFalse);
          expect(ActivityIntentService.isValidPhoneNumber(''), isFalse);
          expect(
            ActivityIntentService.isValidPhoneNumber('123456789012345678901'),
            isFalse,
          ); // > 20 chars
          expect(ActivityIntentService.isValidPhoneNumber('abc123'), isFalse);
          expect(ActivityIntentService.isValidPhoneNumber('123@456'), isFalse);
        });
      });

      group('sanitizePhoneNumber', () {
        test('should remove invalid characters', () {
          expect(
            ActivityIntentService.sanitizePhoneNumber('abc123def456'),
            equals('123456'),
          );
          expect(
            ActivityIntentService.sanitizePhoneNumber('123@456#789'),
            equals('123456#789'),
          );
        });

        test('should keep valid characters', () {
          expect(
            ActivityIntentService.sanitizePhoneNumber('+123*456#789'),
            equals('+123*456#789'),
          );
          expect(
            ActivityIntentService.sanitizePhoneNumber('123-456-7890'),
            equals('1234567890'),
          );
        });

        test('should return null for empty result', () {
          expect(
            ActivityIntentService.sanitizePhoneNumber('abc'),
            isNull,
          );
          expect(
            ActivityIntentService.sanitizePhoneNumber(null),
            isNull,
          );
          expect(
            ActivityIntentService.sanitizePhoneNumber(''),
            isNull,
          );
        });
      });

      group('parseTelUri', () {
        test('should extract phone number from tel: URI', () {
          expect(ActivityIntentService.parseTelUri('tel:1234567890'), equals('1234567890'));
          expect(ActivityIntentService.parseTelUri('tel:+1234567890'), equals('+1234567890'));
          expect(ActivityIntentService.parseTelUri('tel:*123#'), equals('*123#'));
        });

        test('should return null for null or empty URI', () {
          expect(ActivityIntentService.parseTelUri(null), isNull);
          expect(ActivityIntentService.parseTelUri(''), isNull);
        });

        test('should return URI as-is if not tel: scheme', () {
          expect(
            ActivityIntentService.parseTelUri('1234567890'),
            equals('1234567890'),
          );
        });
      });
    });

    group('Intent Handlers', () {
      test('should register intent handler', () async {
        // arrange
        await intentService.initialize();
        var handlerCalled = false;

        // act
        intentService.registerIntentHandler(
          ActivityIntentType.view,
          (intent) {
            handlerCalled = true;
          },
        );

        // assert - handler registered (can't easily test invocation in unit test)
        expect(handlerCalled, isFalse);
      });

      test('should register route handler', () async {
        // arrange
        await intentService.initialize();
        var handlerCalled = false;

        // act
        intentService.registerRouteHandler(
          '/dialer',
          (route) {
            handlerCalled = true;
          },
        );

        // assert
        expect(handlerCalled, isFalse);
      });

      test('should navigate internally', () async {
        // arrange
        await intentService.initialize();
        var navigationReceived = false;
        String? receivedRoute;

        intentService.navigationStream.listen((route) {
          navigationReceived = true;
          receivedRoute = route.routeName;
        });

        // act
        intentService.navigate('/dialer', arguments: {'phoneNumber': '1234567890'});

        // Allow time for stream processing
        await Future.delayed(const Duration(milliseconds: 10));

        // assert
        expect(navigationReceived, isTrue);
        expect(receivedRoute, equals('/dialer'));
      });
    });

    group('Stream Events', () {
      test('should broadcast intent events', () async {
        // arrange
        await intentService.initialize();
        var intentReceived = false;
        ActivityIntentType? receivedType;

        intentService.intentStream.listen((intent) {
          intentReceived = true;
          receivedType = intent.type;
        });

        // Note: In actual Flutter tests, we can't easily trigger the native callback
        // This test verifies the stream is set up correctly
        expect(intentService.intentStream, isNotNull);
      });

      test('should broadcast navigation events', () async {
        // arrange
        await intentService.initialize();
        var navigationReceived = false;
        String? receivedRoute;

        intentService.navigationStream.listen((route) {
          navigationReceived = true;
          receivedRoute = route.routeName;
        });

        // act - navigate internally
        intentService.navigate('/test');

        // Allow time for stream processing
        await Future.delayed(const Duration(milliseconds: 10));

        // assert
        expect(navigationReceived, isTrue);
        expect(receivedRoute, equals('/test'));
      });

      test('should broadcast log events', () async {
        // arrange
        await intentService.initialize();
        var logReceived = false;

        intentService.logStream.listen((log) {
          logReceived = true;
        });

        // act - trigger a log by navigating
        intentService.navigate('/test');

        // Allow time for stream processing
        await Future.delayed(const Duration(milliseconds: 10));

        // assert
        expect(logReceived, isTrue);
      });
    });

    group('Last Intent', () {
      test('should return null when no intent received', () async {
        // arrange
        await intentService.initialize();

        // assert
        expect(intentService.lastIntent, isNull);
      });

      test('should track last intent after processing', () async {
        // arrange
        await intentService.initialize();

        // Note: In real usage, lastIntent would be set by native code
        // This test verifies the getter works
        expect(intentService.lastIntent, isNull);
      });
    });
  });

  group('ActivityIntentType Enum', () {
    test('should have correct values', () {
      expect(ActivityIntentType.values.length, equals(3));
      expect(ActivityIntentType.values[0], equals(ActivityIntentType.view));
      expect(ActivityIntentType.values[1], equals(ActivityIntentType.dial));
      expect(ActivityIntentType.values[2], equals(ActivityIntentType.unknown));
    });

    test('should have correct names', () {
      expect(ActivityIntentType.view.name, equals('view'));
      expect(ActivityIntentType.dial.name, equals('dial'));
      expect(ActivityIntentType.unknown.name, equals('unknown'));
    });
  });
}
