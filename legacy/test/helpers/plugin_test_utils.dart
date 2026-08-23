/// Plugin Test Utilities
///
/// Provides common test utilities and helpers for testing Flutter plugins
/// and platform channel interactions.
///
/// ## Usage
///
/// ```dart
/// import 'package:flutter_test/flutter_test.dart';
/// import 'plugin_test_utils.dart';
///
/// void main() {
///   group('MyPlugin', () {
///     late MockMethodChannel mockChannel;
///
///     setUp(() {
///       mockChannel = setupMockMethodChannel('my/plugin/channel');
///     });
///
///     tearDown(() {
///       cleanupMockChannel('my/plugin/channel');
///     });
///
///     test('should call native method', () async {
///       mockChannel.setHandler((call) async {
///         expect(call.method, equals('myMethod'));
///         return 'result';
///       });
///
///       final result = await myPlugin.myMethod();
///       expect(result, equals('result'));
///     });
///   });
/// }
/// ```
library plugin_test_utils;

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock method channel for testing platform calls.
///
/// Tracks all method calls made to the channel and allows
/// setting custom handlers for testing.
class MockMethodChannel {
  final MethodChannel _channel;
  final List<MethodCall> _calls = [];
  MethodCallHandler? _handler;

  /// Creates a mock method channel wrapping the given [channel].
  MockMethodChannel(this._channel);

  /// Gets the underlying method channel.
  MethodChannel get channel => _channel;

  /// Gets all method calls made to this channel.
  List<MethodCall> get calls => List.unmodifiable(_calls);

  /// Gets the last method call made to this channel.
  MethodCall? get lastCall => _calls.isEmpty ? null : _calls.last;

  /// Gets the number of method calls made.
  int get callCount => _calls.length;

  /// Clears all recorded method calls.
  void clearCalls() {
    _calls.clear();
  }

  /// Sets the handler for method calls.
  void setHandler(MethodCallHandler? handler) {
    _handler = handler;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, _handleCall);
  }

  /// Handles incoming method calls.
  Future<dynamic> _handleCall(MethodCall call) async {
    _calls.add(call);
    if (_handler != null) {
      return await _handler!(call);
    }
    return null;
  }

  /// Resets the mock channel to its initial state.
  void reset() {
    _calls.clear();
    _handler = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
  }
}

/// Mock event channel for testing platform event streams.
///
/// Allows simulating event streams from native code.
class MockEventChannel {
  final EventChannel _channel;
  Stream<dynamic>? _stream;

  /// Creates a mock event channel wrapping the given [channel].
  MockEventChannel(this._channel);

  /// Gets the underlying event channel.
  EventChannel get channel => _channel;

  /// Sets the event stream to be broadcast.
  void setStream(Stream<dynamic> stream) {
    _stream = stream;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _channel.codec == const JSONMethodCodec()
          ? EventChannel(_channel.name, const JSONMethodCodec())
          : _channel,
      _handleCall,
    );
  }

  /// Handles listen/broadcastStream calls.
  Future<dynamic> _handleCall(MethodCall call) async {
    if (call.method == 'listen') {
      if (_stream != null) {
        // Broadcast events to the binary messenger
        await for (final event in _stream!) {
          TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
              .handlePlatformMessage(
            _channel.name,
            _channel.codec.encodeSuccessEnvelope(event),
            (ByteData? data) {
              // Response handled
            },
          );
        }
      }
      return null;
    }
    if (call.method == 'broadcastStream') {
      return null;
    }
    if (call.method == 'cancel') {
      return null;
    }
    return null;
  }

  /// Resets the mock channel to its initial state.
  void reset() {
    _stream = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      _channel.codec == const JSONMethodCodec()
          ? EventChannel(_channel.name, const JSONMethodCodec())
          : _channel,
      null,
    );
  }
}

/// Sets up a mock method channel for testing.
///
/// [channelName] - The name of the method channel to mock.
/// [autoRespond] - Optional auto-response for all method calls.
///
/// Returns a [MockMethodChannel] for tracking calls and setting handlers.
///
/// Example:
/// ```dart
/// late MockMethodChannel mockChannel;
///
/// setUp(() {
///   mockChannel = setupMockMethodChannel('my/plugin/channel');
/// });
///
/// tearDown(() {
///   mockChannel.reset();
/// });
/// ```
MockMethodChannel setupMockMethodChannel(
  String channelName, {
  dynamic Function(MethodCall)? autoRespond,
}) {
  final channel = MethodChannel(channelName);
  final mockChannel = MockMethodChannel(channel);

  if (autoRespond != null) {
    mockChannel.setHandler((call) async => autoRespond(call));
  }

  return mockChannel;
}

/// Sets up a mock event channel for testing.
///
/// [channelName] - The name of the event channel to mock.
///
/// Returns a [MockEventChannel] for simulating event streams.
///
/// Example:
/// ```dart
/// late MockEventChannel mockEventChannel;
///
/// setUp(() {
///   mockEventChannel = setupMockEventChannel('my/plugin/events');
///   mockEventChannel.setStream(Stream.value({'event': 'data'}));
/// });
/// ```
MockEventChannel setupMockEventChannel(String channelName) {
  final channel = EventChannel(channelName);
  return MockEventChannel(channel);
}

/// Cleans up a mock method channel.
///
/// [channelName] - The name of the method channel to cleanup.
///
/// This should be called in tearDown to remove mock handlers.
void cleanupMockChannel(String channelName) {
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(MethodChannel(channelName), null);
}

/// Creates a test method call with the given [method] and [arguments].
MethodCall createMethodCall(String method, {Map<String, dynamic>? arguments}) {
  return MethodCall(method, arguments);
}

/// Asserts that a method was called on the channel.
///
/// [mockChannel] - The mock channel to check.
/// [method] - The expected method name.
/// [arguments] - Optional expected arguments.
///
/// Throws [TestFailure] if the method was not called.
///
/// Example:
/// ```dart
/// assertMethodCalled(mockChannel, 'myMethod');
/// assertMethodCalled(mockChannel, 'myMethod', arguments: {'key': 'value'});
/// ```
void assertMethodCalled(
  MockMethodChannel mockChannel,
  String method, {
  Map<String, dynamic>? arguments,
}) {
  final matchingCalls = mockChannel.calls.where((call) {
    if (call.method != method) return false;
    if (arguments != null) {
      return _mapsEqual(call.arguments as Map?, arguments);
    }
    return true;
  }).toList();

  if (matchingCalls.isEmpty) {
    throw TestFailure(
      'Expected method $method to be called, but it was not. '
      'Actual calls: ${mockChannel.calls.map((c) => c.method).join(', ')}',
    );
  }
}

/// Asserts that a method was called exactly [count] times.
///
/// [mockChannel] - The mock channel to check.
/// [method] - The expected method name.
/// [count] - The expected number of calls.
///
/// Throws [TestFailure] if the call count doesn't match.
void assertMethodCalledCount(
  MockMethodChannel mockChannel,
  String method,
  int count,
) {
  final matchingCalls = mockChannel.calls.where((call) => call.method == method).length;

  if (matchingCalls != count) {
    throw TestFailure(
      'Expected method $method to be called $count times, but was called $matchingCalls times.',
    );
  }
}

/// Asserts that a method was NOT called.
///
/// [mockChannel] - The mock channel to check.
/// [method] - The method name that should not have been called.
///
/// Throws [TestFailure] if the method was called.
void assertMethodNotCalled(MockMethodChannel mockChannel, String method) {
  final matchingCalls = mockChannel.calls.where((call) => call.method == method).length;

  if (matchingCalls > 0) {
    throw TestFailure(
      'Expected method $method to NOT be called, but was called $matchingCalls times.',
    );
  }
}

/// Waits for a method to be called on the mock channel.
///
/// [mockChannel] - The mock channel to watch.
/// [method] - The method to wait for.
/// [timeout] - Maximum time to wait (default: 1 second).
///
/// Returns the method call when received.
/// Throws [TestFailure] if timeout is reached.
Future<MethodCall> waitForMethodCall(
  MockMethodChannel mockChannel,
  String method, {
  Duration timeout = const Duration(seconds: 1),
}) async {
  final stopwatch = Stopwatch()..start();

  while (stopwatch.elapsed < timeout) {
    final matchingCall = mockChannel.calls.lastWhere(
      (call) => call.method == method,
      orElse: () => const MethodCall('', null),
    );

    if (matchingCall.method == method) {
      return matchingCall;
    }

    await Future.delayed(const Duration(milliseconds: 10));
  }

  throw TestFailure('Timeout waiting for method $method to be called.');
}

/// Checks if two maps are equal.
bool _mapsEqual(Map? a, Map? b) {
  if (a == null && b == null) return true;
  if (a == null || b == null) return false;
  if (a.length != b.length) return false;

  for (final key in a.keys) {
    if (!b.containsKey(key)) return false;
    if (a[key] != b[key]) return false;
  }

  return true;
}

/// Matcher for platform exception testing.
///
/// Use with [throwsA] to test platform exception handling.
///
/// Example:
/// ```dart
/// expect(
///   () => plugin.methodThatThrows(),
///   throwsPlatformException(code: 'ERROR_CODE'),
/// );
/// ```
Matcher throwsPlatformException({String? code, String? message}) {
  return isA<PlatformException>().having(
    (e) => code == null || e.code == code,
    'code matches',
    true,
  ).having(
    (e) => message == null || e.message == message,
    'message matches',
    true,
  );
}

/// Test fixture for plugin initialization tests.
///
/// Provides common setup and teardown for testing plugin initialization.
///
/// Example:
/// ```dart
/// late PluginTestFixture fixture;
///
/// setUp(() {
///   fixture = PluginTestFixture();
///   fixture.setup();
/// });
///
/// tearDown(() {
///   fixture.tearDown();
/// });
/// ```
class PluginTestFixture {
  final List<String> _channelNames = [];
  final Map<String, MockMethodChannel> _mockChannels = {};
  bool _isSetup = false;

  /// Gets all mock channels created by this fixture.
  Map<String, MockMethodChannel> get mockChannels => Map.unmodifiable(_mockChannels);

  /// Gets whether the fixture is set up.
  bool get isSetup => _isSetup;

  /// Sets up the test fixture.
  ///
  /// Call this in setUp before each test.
  void setup() {
    TestWidgetsFlutterBinding.ensureInitialized();
    _isSetup = true;
  }

  /// Creates a mock method channel tracked by this fixture.
  ///
  /// [channelName] - The name of the channel to create.
  /// [autoRespond] - Optional auto-response handler.
  ///
  /// Returns the created [MockMethodChannel].
  MockMethodChannel createMockChannel(
    String channelName, {
    dynamic Function(MethodCall)? autoRespond,
  }) {
    if (!_isSetup) {
      throw StateError('Fixture must be set up before creating mock channels');
    }

    _channelNames.add(channelName);
    _mockChannels[channelName] = setupMockMethodChannel(
      channelName,
      autoRespond: autoRespond,
    );

    return _mockChannels[channelName]!;
  }

  /// Creates a mock event channel tracked by this fixture.
  ///
  /// [channelName] - The name of the channel to create.
  ///
  /// Returns the created [MockEventChannel].
  MockEventChannel createMockEventChannel(String channelName) {
    if (!_isSetup) {
      throw StateError('Fixture must be set up before creating mock channels');
    }

    _channelNames.add(channelName);
    return setupMockEventChannel(channelName);
  }

  /// Tears down the test fixture.
  ///
  /// Call this in tearDown after each test.
  void tearDown() {
    for (final channelName in _channelNames) {
      cleanupMockChannel(channelName);
    }
    _channelNames.clear();
    _mockChannels.clear();
    _isSetup = false;
  }
}

/// AAA (Arrange-Act-Assert) test helper for plugin method tests.
///
/// Provides a structured way to write plugin tests following the AAA pattern.
///
/// Example:
/// ```dart
/// test('should return value when called', () async {
///   await aaaTest(
///     arrange: () {
///       mockChannel.setHandler((call) async => 'result');
///     },
///     act: () async {
///       result = await plugin.method();
///     },
///     assert: () {
///       expect(result, equals('result'));
///       assertMethodCalled(mockChannel, 'method');
///     },
///   );
/// });
/// ```
Future<void> aaaTest({
  Future<void> Function()? arrange,
  required Future<void> Function() act,
  required void Function() assert,
}) async {
  if (arrange != null) {
    await arrange();
  }
  await act();
  assert();
}

/// Extension on [MethodCall] for easier testing.
extension MethodCallTestExtension on MethodCall {
  /// Gets the argument value for the given [key].
  dynamic arg(String key) {
    if (arguments is Map) {
      return (arguments as Map)[key];
    }
    throw StateError('Arguments is not a Map');
  }

  /// Gets the argument value as a specific type.
  T argAs<T>(String key) {
    return arg(key) as T;
  }

  /// Checks if the argument exists.
  bool hasArg(String key) {
    if (arguments is Map) {
      return (arguments as Map).containsKey(key);
    }
    return false;
  }
}
