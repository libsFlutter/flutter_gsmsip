import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// HeadlessService - Flutter/Dart service for headless operation
///
/// This service provides the Dart/Flutter interface for controlling
/// the Android headless background service. It communicates with the
/// native Android code via MethodChannel.
///
/// Features:
/// - Start/stop headless background service
/// - Bring app to foreground from background
/// - Event stream for headless service events
/// - ChangeNotifier for UI integration
class HeadlessService extends ChangeNotifier {
  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/headless');
  static const EventChannel _eventChannel = EventChannel('gsm_sip_gateway/headless_events');

  final Logger _logger = Logger();

  // Service state
  bool _isRunning = false;
  bool _isForeground = false;
  DateTime? _startTime;
  int _tickCount = 0;

  // Stream controllers
  final StreamController<Map<String, dynamic>> _eventController =
      StreamController<Map<String, dynamic>>.broadcast();
  StreamSubscription<dynamic>? _eventStreamSubscription;

  // Callback handle for headless execution
  static int? _callbackHandle;

  /// Get the callback handle for headless execution
  /// This must be called from the main isolate to get a valid handle
  static int? get callbackHandle => _callbackHandle;

  /// Set the callback handle (called during initialization)
  static void setCallbackHandle(int handle) {
    _callbackHandle = handle;
    debugPrint('HeadlessService: Callback handle set to $handle');
  }

  /// Get the current running state of the headless service
  bool get isRunning => _isRunning;

  /// Get whether the app is in foreground
  bool get isForeground => _isForeground;

  /// Get the time when the service was started
  DateTime? get startTime => _startTime;

  /// Get the number of ticks received from the headless service
  int get tickCount => _tickCount;

  /// Stream of events from the headless service
  Stream<Map<String, dynamic>> get eventStream => _eventController.stream;

  /// Initialize the headless service
  ///
  /// This sets up the event listener and restores previous state.
  /// Returns true if initialization was successful.
  Future<bool> initialize() async {
    try {
      _logger.i('Initializing HeadlessService...');

      // Set up event listener
      await _setupEventListener();

      // Restore state (could be extended to load from SharedPreferences)
      _isRunning = false;
      _isForeground = true; // Assume foreground on start

      _logger.i('HeadlessService initialized successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Failed to initialize HeadlessService: $e');
      return false;
    }
  }

  /// Set up the event listener for headless service events
  Future<void> _setupEventListener() async {
    try {
      _eventStreamSubscription?.cancel();
      _eventStreamSubscription = _eventChannel
          .receiveBroadcastStream()
          .listen(
            _handleEvent,
            onError: _handleEventError,
            onDone: _handleEventDone,
          );
      _logger.d('Event listener set up successfully');
    } catch (e) {
      _logger.w('Event channel not available: $e');
      // Event channel is optional - service can work without it
    }
  }

  /// Handle incoming events from the headless service
  void _handleEvent(dynamic event) {
    try {
      if (event is Map) {
        final eventData = Map<String, dynamic>.from(event);
        _logger.d('Headless event received: $eventData');

        // Update state based on event type
        final eventType = eventData['event_type'] as String?;
        switch (eventType) {
          case 'periodic_tick':
            _tickCount++;
            break;
          case 'service_started':
            _isRunning = true;
            _startTime = DateTime.now();
            break;
          case 'service_stopped':
            _isRunning = false;
            _startTime = null;
            _tickCount = 0;
            break;
          case 'brought_to_foreground':
            _isForeground = true;
            break;
        }

        _eventController.add(eventData);
        notifyListeners();
      }
    } catch (e) {
      _logger.e('Error handling event: $e');
    }
  }

  /// Handle event stream errors
  void _handleEventError(dynamic error) {
    _logger.w('Event stream error: $error');
  }

  /// Handle event stream completion
  void _handleEventDone() {
    _logger.d('Event stream closed');
    _eventStreamSubscription = null;
  }

  /// Start the headless background service
  ///
  /// This starts the Android foreground service that will execute
  /// headless tasks at regular intervals.
  ///
  /// Returns true if the service was started successfully.
  Future<bool> startService() async {
    try {
      _logger.i('Starting headless service...');

      final result = await _channel.invokeMethod<bool>('startService');
      
      if (result == true) {
        _isRunning = true;
        _startTime = DateTime.now();
        _logger.i('Headless service started successfully');
        notifyListeners();
        return true;
      } else {
        _logger.w('Headless service start returned false');
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e('Failed to start headless service: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error starting headless service: $e');
      return false;
    }
  }

  /// Stop the headless background service
  ///
  /// This stops the Android foreground service and cleans up resources.
  ///
  /// Returns true if the service was stopped successfully.
  Future<bool> stopService() async {
    try {
      _logger.i('Stopping headless service...');

      final result = await _channel.invokeMethod<bool>('stopService');
      
      if (result == true) {
        _isRunning = false;
        _startTime = null;
        _tickCount = 0;
        _logger.i('Headless service stopped successfully');
        notifyListeners();
        return true;
      } else {
        _logger.w('Headless service stop returned false');
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e('Failed to stop headless service: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error stopping headless service: $e');
      return false;
    }
  }

  /// Bring the app to the foreground
  ///
  /// This launches the MainActivity and brings the app to the
  /// foreground from the background state.
  ///
  /// Returns true if the app was brought to foreground successfully.
  Future<bool> toForeground() async {
    try {
      _logger.i('Bringing app to foreground...');

      final result = await _channel.invokeMethod<bool>('toForeground');
      
      if (result == true) {
        _isForeground = true;
        _logger.i('App brought to foreground');
        notifyListeners();
        return true;
      } else {
        _logger.w('Bring to foreground returned false');
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e('Failed to bring app to foreground: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error bringing app to foreground: $e');
      return false;
    }
  }

  /// Send the app to the background
  ///
  /// Note: This is currently a no-op on Android as there's no direct
  /// API to send an app to the background.
  ///
  /// Returns true (always succeeds as it's a no-op).
  Future<bool> toBackground() async {
    try {
      _logger.d('toBackground called (no-op on Android)');
      await _channel.invokeMethod<bool>('toBackground');
      _isForeground = false;
      notifyListeners();
      return true;
    } on PlatformException catch (e) {
      _logger.w('toBackground not available: ${e.message}');
      return false;
    } catch (e) {
      _logger.w('Error in toBackground: $e');
      return false;
    }
  }

  /// Execute a headless task directly
  ///
  /// This can be used to execute a specific task in the headless
  /// environment. The task must be registered with the headless engine.
  ///
  /// [taskName] - Name of the task to execute
  /// [data] - Optional data to pass to the task
  ///
  /// Returns true if the task was executed successfully.
  Future<bool> executeTask(String taskName, {Map<String, dynamic>? data}) async {
    try {
      _logger.i('Executing headless task: $taskName');

      final result = await _channel.invokeMethod<bool>('executeTask', {
        'task_name': taskName,
        'data': data,
      });

      if (result == true) {
        _logger.i('Headless task completed: $taskName');
        return true;
      } else {
        _logger.w('Headless task failed: $taskName');
        return false;
      }
    } on PlatformException catch (e) {
      _logger.e('Failed to execute headless task: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error executing headless task: $e');
      return false;
    }
  }

  /// Get the current uptime of the headless service
  Duration? getUptime() {
    if (_startTime == null) return null;
    return DateTime.now().difference(_startTime!);
  }

  /// Get service status as a map
  Map<String, dynamic> getStatus() {
    return {
      'is_running': _isRunning,
      'is_foreground': _isForeground,
      'start_time': _startTime?.toIso8601String(),
      'tick_count': _tickCount,
      'uptime_seconds': getUptime()?.inSeconds,
    };
  }

  /// Clean up resources
  @override
  void dispose() {
    _eventStreamSubscription?.cancel();
    _eventController.close();
    _logger.d('HeadlessService disposed');
    super.dispose();
  }
}

/// Headless task callback type
typedef HeadlessTaskCallback = Future<void> Function(Map<String, dynamic> data);

/// Register a headless task callback
///
/// This function should be called in the main() function before
/// runApp() to register the headless task entry point.
///
/// Example:
/// ```dart
/// void main() async {
///   WidgetsFlutterBinding.ensureInitialized();
///   
///   // Register headless task
///   final callback = PluginUtilities.getCallbackHandle(headlessTaskCallback);
///   HeadlessService.setCallbackHandle(callback!.toRawHandle());
///   
///   runApp(MyApp());
/// }
///
/// @pragma('vm:entry-point')
/// Future<void> headlessTaskCallback(Map<String, dynamic> data) async {
///   // Headless task logic here
///   print('Headless task executed with data: $data');
/// }
/// ```
void registerHeadlessTask(HeadlessTaskCallback callback) {
  // This is a placeholder - actual implementation would require
  // platform-specific code to register with the native side
  debugPrint('Headless task registered: ${callback.toString()}');
}
