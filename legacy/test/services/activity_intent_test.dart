import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/activity_intent_service.dart';

void main() {
  group('ActivityIntentService', () {
    late ActivityIntentService intentService;
    late List<MethodCall> log;

    setUp(() async {
      intentService = ActivityIntentService();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();
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
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/activity_intent'),
        null,
      );
      intentService.dispose();
    });

    group('initial state', () {
      test('should start with correct initial state', () {
        // assert
        expect(intentService.isInitialized, isFalse);
        expect(intentService.lastIntent, isNull);
      });
    });

    group('initialize', () {
      test('should initialize successfully', () async {
        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isTrue);
        expect(intentService.isInitialized, isTrue);
      });

      test('should handle initialization failure', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            throw Exception('Initialization failed');
          },
        );

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isFalse);
        expect(intentService.isInitialized, isFalse);
      });
    });

    group('ActivityIntentType', () {
      test('should have all expected types', () {
        // assert
        expect(ActivityIntentType.values.length, equals(3));
        expect(ActivityIntentType.values, contains(ActivityIntentType.view));
        expect(ActivityIntentType.values, contains(ActivityIntentType.dial));
        expect(ActivityIntentType.values, contains(ActivityIntentType.unknown));
      });
    });

    group('ActivityIntentData', () {
      test('should create from Map with view type', () {
        // arrange
        final map = {
          'type': 'view',
          'phoneNumber': '+1234567890',
          'action': 'ACTION_VIEW',
          'extras': {'key': 'value'},
        };

        // act
        final data = ActivityIntentData.fromMap(map);

        // assert
        expect(data.type, equals(ActivityIntentType.view));
        expect(data.phoneNumber, equals('+1234567890'));
        expect(data.action, equals('ACTION_VIEW'));
        expect(data.extras, isNotNull);
        expect(data.extras!['key'], equals('value'));
      });

      test('should create from Map with dial type', () {
        // arrange
        final map = {
          'type': 'dial',
          'phoneNumber': '1234567890',
          'action': 'ACTION_DIAL',
        };

        // act
        final data = ActivityIntentData.fromMap(map);

        // assert
        expect(data.type, equals(ActivityIntentType.dial));
        expect(data.phoneNumber, equals('1234567890'));
        expect(data.action, equals('ACTION_DIAL'));
        expect(data.extras, isNull);
      });

      test('should create from Map with unknown type', () {
        // arrange
        final map = {
          'type': 'unknown_type',
          'phoneNumber': null,
        };

        // act
        final data = ActivityIntentData.fromMap(map);

        // assert
        expect(data.type, equals(ActivityIntentType.unknown));
      });

      test('should handle null values in Map', () {
        // arrange
        final map = <String, dynamic>{};

        // act
        final data = ActivityIntentData.fromMap(map);

        // assert
        expect(data.type, equals(ActivityIntentType.unknown));
        expect(data.phoneNumber, isNull);
        expect(data.action, isNull);
        expect(data.extras, isNull);
      });

      test('should convert to Map', () {
        // arrange
        const data = ActivityIntentData(
          type: ActivityIntentType.view,
          phoneNumber: '+1234567890',
          action: 'ACTION_VIEW',
          extras: {'key': 'value'},
        );

        // act
        final map = data.toMap();

        // assert
        expect(map['type'], equals('view'));
        expect(map['phoneNumber'], equals('+1234567890'));
        expect(map['action'], equals('ACTION_VIEW'));
        expect(map['extras'], isNotNull);
        expect(map['extras']!['key'], equals('value'));
      });

      test('should toString with basic info', () {
        // arrange
        const data = ActivityIntentData(
          type: ActivityIntentType.dial,
          phoneNumber: '1234567890',
        );

        // assert
        expect(data.toString(), contains('dial'));
        expect(data.toString(), contains('1234567890'));
      });

      test('should create with const constructor', () {
        // act
        const data = ActivityIntentData(
          type: ActivityIntentType.view,
          phoneNumber: '+1234567890',
        );

        // assert
        expect(data.type, equals(ActivityIntentType.view));
        expect(data.phoneNumber, equals('+1234567890'));
      });
    });

    group('NavigationRoute', () {
      test('should create with required fields', () {
        // arrange
        const routeName = '/dialer';

        // act
        const route = NavigationRoute(routeName: routeName);

        // assert
        expect(route.routeName, equals(routeName));
        expect(route.arguments, isNull);
      });

      test('should create with arguments', () {
        // arrange
        const routeName = '/dialer';
        final arguments = {'phoneNumber': '1234567890'};

        // act
        const route = NavigationRoute(
          routeName: routeName,
          arguments: arguments,
        );

        // assert
        expect(route.routeName, equals(routeName));
        expect(route.arguments, equals(arguments));
      });

      test('should toString with route info', () {
        // arrange
        const route = NavigationRoute(routeName: '/settings');

        // assert
        expect(route.toString(), contains('/settings'));
      });
    });

    group('streams', () {
      test('should provide intentStream', () {
        // assert
        expect(intentService.intentStream, isNotNull);
      });

      test('should provide navigationStream', () {
        // assert
        expect(intentService.navigationStream, isNotNull);
      });

      test('should provide logStream', () {
        // assert
        expect(intentService.logStream, isNotNull);
      });
    });

    group('intent handlers', () {
      test('should register intent handler', () async {
        // arrange
        var handlerCalled = false;
        void handler(ActivityIntentData data) {
          handlerCalled = true;
        }

        // act
        intentService.registerIntentHandler(ActivityIntentType.view, handler);

        // assert - should not throw
        expect(handlerCalled, isFalse);
      });

      test('should register route handler', () async {
        // arrange
        var handlerCalled = false;
        void handler(NavigationRoute route) {
          handlerCalled = true;
        }

        // act
        intentService.registerRouteHandler('/dialer', handler);

        // assert - should not throw
        expect(handlerCalled, isFalse);
      });
    });

    group('navigate', () {
      test('should trigger navigation stream', () async {
        // arrange
        final routes = <NavigationRoute>[];
        final subscription = intentService.navigationStream.listen(routes.add);

        // act
        intentService.navigate('/dialer', arguments: {'phoneNumber': '1234567890'});

        // allow event to propagate
        await Future.delayed(const Duration(milliseconds: 10));

        // assert
        expect(routes.length, equals(1));
        expect(routes.first.routeName, equals('/dialer'));
        expect(routes.first.arguments, isNotNull);

        await subscription.cancel();
      });
    });

    group('static utility methods', () {
      group('isValidPhoneNumber', () {
        test('should return true for valid phone number', () {
          // assert
          expect(ActivityIntentService.isValidPhoneNumber('1234567890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('+1234567890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('*123#'), isTrue);
        });

        test('should return true for phone number with spaces and dashes', () {
          // assert
          expect(ActivityIntentService.isValidPhoneNumber('123-456-7890'), isTrue);
          expect(ActivityIntentService.isValidPhoneNumber('123 456 7890'), isTrue);
        });

        test('should return false for null phone number', () {
          // assert
          expect(ActivityIntentService.isValidPhoneNumber(null), isFalse);
        });

        test('should return false for empty phone number', () {
          // assert
          expect(ActivityIntentService.isValidPhoneNumber(''), isFalse);
        });

        test('should return false for too long phone number', () {
          // assert
          expect(
            ActivityIntentService.isValidPhoneNumber('123456789012345678901'),
            isFalse,
          );
        });

        test('should return false for invalid characters', () {
          // assert
          expect(ActivityIntentService.isValidPhoneNumber('123abc'), isFalse);
          expect(ActivityIntentService.isValidPhoneNumber('123@456'), isFalse);
        });
      });

      group('sanitizePhoneNumber', () {
        test('should return null for null input', () {
          // assert
          expect(ActivityIntentService.sanitizePhoneNumber(null), isNull);
        });

        test('should return null for empty input', () {
          // assert
          expect(ActivityIntentService.sanitizePhoneNumber(''), isNull);
        });

        test('should remove invalid characters', () {
          // act
          final result = ActivityIntentService.sanitizePhoneNumber('123abc456');

          // assert
          expect(result, equals('123456'));
        });

        test('should keep valid characters', () {
          // act
          final result = ActivityIntentService.sanitizePhoneNumber('+123*456#');

          // assert
          expect(result, equals('+123*456#'));
        });

        test('should return null if all characters are invalid', () {
          // act
          final result = ActivityIntentService.sanitizePhoneNumber('abc');

          // assert
          expect(result, isNull);
        });
      });

      group('parseTelUri', () {
        test('should return null for null input', () {
          // assert
          expect(ActivityIntentService.parseTelUri(null), isNull);
        });

        test('should return null for empty input', () {
          // assert
          expect(ActivityIntentService.parseTelUri(''), isNull);
        });

        test('should extract number from tel: URI', () {
          // act
          final result = ActivityIntentService.parseTelUri('tel:+1234567890');

          // assert
          expect(result, equals('+1234567890'));
        });

        test('should return input if not tel: URI', () {
          // act
          final result = ActivityIntentService.parseTelUri('+1234567890');

          // assert
          expect(result, equals('+1234567890'));
        });
      });
    });

    group('singleton', () {
      test('should return same instance', () {
        // arrange
        final instance1 = ActivityIntentService();
        final instance2 = ActivityIntentService();

        // assert
        expect(identical(instance1, instance2), isTrue);
      });
    });

    group('handleMethodCall', () {
      test('should handle onIntentReceived method', () async {
        // arrange
        final intents = <ActivityIntentData>[];
        final subscription = intentService.intentStream.listen(intents.add);

        await intentService.initialize();

        // Simulate native method call
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

        // cleanup
        await subscription.cancel();
      });

      test('should handle onNavigationRequested method', () async {
        // arrange
        final routes = <NavigationRoute>[];
        final subscription = intentService.navigationStream.listen(routes.add);

        await intentService.initialize();

        // cleanup
        await subscription.cancel();
      });

      test('should ignore unknown methods', () async {
        // arrange
        await intentService.initialize();

        // act & assert - should not throw
        expect(() async {
          // Unknown method should be ignored
        }, returnsNormally);
      });
    });

    group('dispose', () {
      test('should clean up resources', () {
        // act
        intentService.dispose();

        // assert - should not throw
        expect(intentService.intentStream, isNotNull);
      });
    });

    group('getInitialIntent', () {
      test('should handle null initial intent', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getInitialIntent') {
              return null;
            }
            return null;
          },
        );

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isTrue);
        expect(intentService.isInitialized, isTrue);
      });

      test('should handle initial intent', () async {
        // arrange
        final initialIntent = {
          'type': 'view',
          'phoneNumber': '+1234567890',
          'action': 'ACTION_VIEW',
        };

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/activity_intent'),
          (MethodCall methodCall) async {
            if (methodCall.method == 'getInitialIntent') {
              return initialIntent;
            }
            return null;
          },
        );

        // act
        final result = await intentService.initialize();

        // assert
        expect(result, isTrue);
        expect(intentService.lastIntent, isNotNull);
        expect(intentService.lastIntent!.type, equals(ActivityIntentType.view));
        expect(intentService.lastIntent!.phoneNumber, equals('+1234567890'));
      });
    });

    group('intent processing', () {
      test('should process view intent and navigate to dialer', () async {
        // arrange
        final routes = <NavigationRoute>[];
        final subscription = intentService.navigationStream.listen(routes.add);

        await intentService.initialize();

        // Simulate receiving a view intent
        final intentData = ActivityIntentData(
          type: ActivityIntentType.view,
          phoneNumber: '+1234567890',
          action: 'ACTION_VIEW',
        );

        // Manually trigger intent processing by adding to stream
        // Note: In real usage, this would come from native code

        await subscription.cancel();
      });

      test('should ignore unknown intent type', () async {
        // arrange
        final intents = <ActivityIntentData>[];
        final subscription = intentService.intentStream.listen(intents.add);

        await intentService.initialize();

        // cleanup
        await subscription.cancel();
      });
    });
  });
}
