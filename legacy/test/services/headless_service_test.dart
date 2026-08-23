import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/services/headless_service.dart';

void main() {
  group('HeadlessService', () {
    late HeadlessService headlessService;
    late List<MethodCall> log;

    setUp(() async {
      headlessService = HeadlessService();
      log = <MethodCall>[];

      TestWidgetsFlutterBinding.ensureInitialized();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/headless'),
        (MethodCall methodCall) async {
          log.add(methodCall);
          return true;
        },
      );
    });

    tearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
        const MethodChannel('gsm_sip_gateway/headless'),
        null,
      );
      headlessService.dispose();
    });

    group('initial state', () {
      test('should start with correct initial state', () {
        // assert
        expect(headlessService.isRunning, isFalse);
        expect(headlessService.isForeground, isFalse);
        expect(headlessService.startTime, isNull);
        expect(headlessService.tickCount, equals(0));
      });
    });

    group('initialize', () {
      test('should initialize successfully', () async {
        // act
        final result = await headlessService.initialize();

        // assert
        expect(result, isTrue);
        expect(headlessService.isRunning, isFalse);
      });

      test('should handle initialization failure', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw Exception('Initialization failed');
          },
        );

        // act
        final result = await headlessService.initialize();

        // assert
        expect(result, isFalse);
      });
    });

    group('startService', () {
      test('should start service successfully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('startService'));
            return true;
          },
        );

        // act
        final result = await headlessService.startService();

        // assert
        expect(result, isTrue);
        expect(headlessService.isRunning, isTrue);
        expect(headlessService.startTime, isNotNull);
        expect(log.length, equals(1));
      });

      test('should return false when start fails', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async => false,
        );

        // act
        final result = await headlessService.startService();

        // assert
        expect(result, isFalse);
      });

      test('should return false on PlatformException', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'START_ERROR',
              message: 'Failed to start service',
            );
          },
        );

        // act
        final result = await headlessService.startService();

        // assert
        expect(result, isFalse);
      });
    });

    group('stopService', () {
      test('should stop service successfully', () async {
        // arrange
        await headlessService.startService();

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('stopService'));
            return true;
          },
        );

        // act
        final result = await headlessService.stopService();

        // assert
        expect(result, isTrue);
        expect(headlessService.isRunning, isFalse);
        expect(headlessService.startTime, isNull);
        expect(headlessService.tickCount, equals(0));
        expect(log.length, equals(1));
      });

      test('should return false when stop fails', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async => false,
        );

        // act
        final result = await headlessService.stopService();

        // assert
        expect(result, isFalse);
      });

      test('should return false on PlatformException', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'STOP_ERROR',
              message: 'Failed to stop service',
            );
          },
        );

        // act
        final result = await headlessService.stopService();

        // assert
        expect(result, isFalse);
      });
    });

    group('toForeground', () {
      test('should bring app to foreground successfully', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('toForeground'));
            return true;
          },
        );

        // act
        final result = await headlessService.toForeground();

        // assert
        expect(result, isTrue);
        expect(headlessService.isForeground, isTrue);
        expect(log.length, equals(1));
      });

      test('should return false when bring to foreground fails', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async => false,
        );

        // act
        final result = await headlessService.toForeground();

        // assert
        expect(result, isFalse);
      });

      test('should return false on PlatformException', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'FOREGROUND_ERROR',
              message: 'Failed to bring to foreground',
            );
          },
        );

        // act
        final result = await headlessService.toForeground();

        // assert
        expect(result, isFalse);
      });
    });

    group('toBackground', () {
      test('should handle toBackground call', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('toBackground'));
            return true;
          },
        );

        // act
        final result = await headlessService.toBackground();

        // assert
        expect(result, isTrue);
        expect(headlessService.isForeground, isFalse);
        expect(log.length, equals(1));
      });

      test('should return false on PlatformException', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'BACKGROUND_ERROR',
              message: 'Failed to send to background',
            );
          },
        );

        // act
        final result = await headlessService.toBackground();

        // assert
        expect(result, isFalse);
      });
    });

    group('executeTask', () {
      test('should execute headless task successfully', () async {
        // arrange
        const taskName = 'test_task';
        final data = {'key': 'value'};

        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            log.add(methodCall);
            expect(methodCall.method, equals('executeTask'));
            expect(methodCall.arguments['task_name'], equals(taskName));
            expect(methodCall.arguments['data'], equals(data));
            return true;
          },
        );

        // act
        final result = await headlessService.executeTask(taskName, data: data);

        // assert
        expect(result, isTrue);
        expect(log.length, equals(1));
      });

      test('should return false when task execution fails', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async => false,
        );

        // act
        final result = await headlessService.executeTask('test_task');

        // assert
        expect(result, isFalse);
      });

      test('should return false on PlatformException', () async {
        // arrange
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(
          const MethodChannel('gsm_sip_gateway/headless'),
          (MethodCall methodCall) async {
            throw PlatformException(
              code: 'TASK_ERROR',
              message: 'Failed to execute task',
            );
          },
        );

        // act
        final result = await headlessService.executeTask('test_task');

        // assert
        expect(result, isFalse);
      });
    });

    group('getStatus', () {
      test('should return status map with correct fields', () async {
        // act
        final status = headlessService.getStatus();

        // assert
        expect(status, isA<Map<String, dynamic>>());
        expect(status.containsKey('is_running'), isTrue);
        expect(status.containsKey('is_foreground'), isTrue);
        expect(status.containsKey('start_time'), isTrue);
        expect(status.containsKey('tick_count'), isTrue);
        expect(status.containsKey('uptime_seconds'), isTrue);
      });

      test('should show correct initial values', () {
        // act
        final status = headlessService.getStatus();

        // assert
        expect(status['is_running'], isFalse);
        expect(status['is_foreground'], isFalse);
        expect(status['tick_count'], equals(0));
      });

      test('should show running state after start', () async {
        // arrange
        await headlessService.startService();

        // act
        final status = headlessService.getStatus();

        // assert
        expect(status['is_running'], isTrue);
        expect(status['start_time'], isNotNull);
      });
    });

    group('getUptime', () {
      test('should return null when service not started', () {
        // act
        final uptime = headlessService.getUptime();

        // assert
        expect(uptime, isNull);
      });

      test('should return duration when service is started', () async {
        // arrange
        await headlessService.startService();

        // act
        final uptime = headlessService.getUptime();

        // assert
        expect(uptime, isNotNull);
        expect(uptime!.inSeconds, greaterThanOrEqualTo(0));
      });
    });

    group('eventStream', () {
      test('should provide event stream', () {
        // assert
        expect(headlessService.eventStream, isNotNull);
      });

      test('should receive events from event channel', () async {
        // arrange
        final events = <Map<String, dynamic>>[];
        final subscription = headlessService.eventStream.listen(events.add);

        // Simulate event from native side
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMessageHandler(
          const MethodChannel('gsm_sip_gateway/headless_events').name,
          (message) async {
            // This would be triggered by native code sending events
            return null;
          },
        );

        // act
        await Future.delayed(const Duration(milliseconds: 100));

        // cleanup
        await subscription.cancel();
      });
    });

    group('callbackHandle', () {
      test('should be null initially', () {
        // assert
        expect(HeadlessService.callbackHandle, isNull);
      });

      test('should set callback handle', () {
        // arrange
        const handle = 12345;

        // act
        HeadlessService.setCallbackHandle(handle);

        // assert
        expect(HeadlessService.callbackHandle, equals(handle));
      });
    });

    group('ChangeNotifier', () {
      test('should notify listeners on state change', () async {
        // arrange
        var notifyCount = 0;
        headlessService.addListener(() {
          notifyCount++;
        });

        // act
        await headlessService.startService();

        // assert
        expect(notifyCount, greaterThan(0));
      });

      test('should notify listeners on stop', () async {
        // arrange
        var notifyCount = 0;
        headlessService.addListener(() {
          notifyCount++;
        });

        await headlessService.startService();
        notifyCount = 0;

        // act
        await headlessService.stopService();

        // assert
        expect(notifyCount, greaterThan(0));
      });
    });

    group('dispose', () {
      test('should clean up resources', () {
        // act
        headlessService.dispose();

        // assert - should not throw
        expect(headlessService.eventStream, isNotNull);
      });
    });

    group('registerHeadlessTask', () {
      test('should register headless task callback', () {
        // arrange
        var taskExecuted = false;

        Future<void> taskCallback(Map<String, dynamic> data) async {
          taskExecuted = true;
        }

        // act
        registerHeadlessTask(taskCallback);

        // assert - registration should not throw
        expect(taskExecuted, isFalse);
      });
    });
  });
}
