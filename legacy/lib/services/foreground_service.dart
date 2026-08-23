import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Foreground service state
enum ForegroundServiceState {
  /// Service is not running
  stopped,

  /// Service is starting
  starting,

  /// Service is running in foreground
  foreground,

  /// Service is running in background
  background,

  /// Service encountered an error
  error
}

/// Foreground service notification configuration
class ForegroundNotificationConfig {
  final String title;
  final String content;
  final String? channelId;
  final int? priority;
  final bool? showWhen;
  final bool? ongoing;
  final bool? autoCancel;

  const ForegroundNotificationConfig({
    required this.title,
    required this.content,
    this.channelId,
    this.priority,
    this.showWhen,
    this.ongoing,
    this.autoCancel,
  });

  Map<String, dynamic> toMap() => {
    'title': title,
    'content': content,
    'channelId': channelId,
    'priority': priority,
    'showWhen': showWhen,
    'ongoing': ongoing,
    'autoCancel': autoCancel,
  };

  factory ForegroundNotificationConfig.fromMap(Map<String, dynamic> map) =>
      ForegroundNotificationConfig(
        title: map['title'] as String,
        content: map['content'] as String,
        channelId: map['channelId'] as String?,
        priority: map['priority'] as int?,
        showWhen: map['showWhen'] as bool?,
        ongoing: map['ongoing'] as bool?,
        autoCancel: map['autoCancel'] as bool?,
      );
}

/// Foreground Service for Android lifecycle management
///
/// This service manages the Android foreground/background lifecycle,
/// including:
/// - Starting/stopping foreground services
/// - Managing wake locks for screen wake
/// - Handling service state transitions
/// - Notification management for foreground service
///
/// Designed for incoming call scenarios in telecom/VoIP applications.
class ForegroundService {
  static final ForegroundService _instance = ForegroundService._internal();
  factory ForegroundService() => _instance;
  ForegroundService._internal();

  final Logger _logger = Logger();

  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/foreground');

  ForegroundServiceState _state = ForegroundServiceState.stopped;
  ForegroundNotificationConfig? _notificationConfig;
  DateTime? _startTime;
  bool _isWakeLockHeld = false;

  // Stream controllers
  final StreamController<ForegroundServiceState> _stateController =
      StreamController<ForegroundServiceState>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  // Getters
  ForegroundServiceState get state => _state;
  bool get isRunning => _state == ForegroundServiceState.foreground ||
      _state == ForegroundServiceState.background;
  bool get isForeground => _state == ForegroundServiceState.foreground;
  bool get isBackground => _state == ForegroundServiceState.background;
  DateTime? get startTime => _startTime;
  Duration? get uptime =>
      _startTime != null ? DateTime.now().difference(_startTime!) : null;

  // Streams
  Stream<ForegroundServiceState> get stateStream => _stateController.stream;
  Stream<String> get logStream => _logController.stream;

  /// Initialize the foreground service
  ///
  /// Sets up the method channel handler for native communication.
  Future<bool> initialize() async {
    try {
      _log('Initializing Foreground service...');

      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCall);

      _updateState(ForegroundServiceState.stopped);
      _log('Foreground service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize Foreground service: $e');
      return false;
    }
  }

  /// Handle method calls from native Android code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onServiceStateChanged':
        _handleServiceStateChanged(call.arguments);
        break;
      case 'onWakeLockReleased':
        _handleWakeLockReleased();
        break;
      default:
        _log('Unknown method call: ${call.method}');
    }
  }

  /// Handle service state changes from native code
  void _handleServiceStateChanged(dynamic arguments) {
    try {
      if (arguments is Map) {
        final stateString = arguments['state'] as String?;
        ForegroundServiceState newState;

        switch (stateString?.toLowerCase()) {
          case 'foreground':
            newState = ForegroundServiceState.foreground;
            break;
          case 'background':
            newState = ForegroundServiceState.background;
            break;
          case 'starting':
            newState = ForegroundServiceState.starting;
            break;
          case 'error':
            newState = ForegroundServiceState.error;
            break;
          default:
            newState = ForegroundServiceState.stopped;
        }

        _updateState(newState);
        _log('Service state changed to: $newState');
      }
    } catch (e) {
      _log('Error handling service state change: $e');
    }
  }

  /// Handle wake lock released from native code
  void _handleWakeLockReleased() {
    _isWakeLockHeld = false;
    _log('Wake lock released');
  }

  /// Start the foreground service
  ///
  /// [notificationConfig] - Configuration for the foreground notification
  /// [timeout] - Optional timeout in milliseconds (default: 10000ms)
  ///
  /// Returns true if service started successfully.
  Future<bool> start({
    ForegroundNotificationConfig? notificationConfig,
    int timeout = 10000,
  }) async {
    try {
      _log('Starting foreground service...');

      _updateState(ForegroundServiceState.starting);

      // Set notification config
      _notificationConfig = notificationConfig ??
          const ForegroundNotificationConfig(
            title: 'Gateway Service',
            content: 'Running in background',
            ongoing: true,
            showWhen: false,
          );

      // Start native foreground service
      final result = await _channel.invokeMethod('startForeground', {
        'notification': _notificationConfig!.toMap(),
        'timeout': timeout,
      });

      if (result['success'] == true) {
        _updateState(ForegroundServiceState.foreground);
        _startTime = DateTime.now();
        _log('Foreground service started successfully');
        return true;
      } else {
        _log('Failed to start foreground service: ${result['error']}');
        _updateState(ForegroundServiceState.error);
        return false;
      }
    } catch (e) {
      _log('Error starting foreground service: $e');
      _updateState(ForegroundServiceState.error);
      return false;
    }
  }

  /// Stop the foreground service
  ///
  /// Returns true if service stopped successfully.
  Future<bool> stop() async {
    if (!isRunning) {
      _log('Service is not running');
      return true;
    }

    try {
      _log('Stopping foreground service...');

      final result = await _channel.invokeMethod('stopForeground');

      if (result['success'] == true) {
        _updateState(ForegroundServiceState.stopped);
        _startTime = null;
        _log('Foreground service stopped');
        return true;
      } else {
        _log('Failed to stop foreground service: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error stopping foreground service: $e');
      return false;
    }
  }

  /// Move service to foreground (bring app to foreground)
  ///
  /// This is used for incoming call scenarios to wake the device
  /// and bring the app to the foreground.
  ///
  /// [timeout] - Wake lock timeout in milliseconds (default: 10000ms)
  ///
  /// Returns true if successfully moved to foreground.
  Future<bool> toForeground({int timeout = 10000}) async {
    try {
      _log('Moving to foreground (timeout: ${timeout}ms)...');

      final result = await _channel.invokeMethod('toForeground', {
        'timeout': timeout,
      });

      if (result['success'] == true) {
        _updateState(ForegroundServiceState.foreground);
        _isWakeLockHeld = true;
        _log('Moved to foreground successfully');
        return true;
      } else {
        _log('Failed to move to foreground: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error moving to foreground: $e');
      return false;
    }
  }

  /// Move service to background
  ///
  /// Returns true if successfully moved to background.
  Future<bool> toBackground() async {
    try {
      _log('Moving to background...');

      final result = await _channel.invokeMethod('toBackground');

      if (result['success'] == true) {
        _updateState(ForegroundServiceState.background);
        _log('Moved to background successfully');
        return true;
      } else {
        _log('Failed to move to background: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error moving to background: $e');
      return false;
    }
  }

  /// Update the foreground notification
  ///
  /// [notificationConfig] - New notification configuration
  ///
  /// Returns true if notification updated successfully.
  Future<bool> updateNotification(ForegroundNotificationConfig notificationConfig) async {
    if (!isRunning) {
      _log('Service is not running, cannot update notification');
      return false;
    }

    try {
      _log('Updating foreground notification...');

      _notificationConfig = notificationConfig;

      final result = await _channel.invokeMethod('updateNotification', {
        'notification': notificationConfig.toMap(),
      });

      if (result['success'] == true) {
        _log('Notification updated successfully');
        return true;
      } else {
        _log('Failed to update notification: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error updating notification: $e');
      return false;
    }
  }

  /// Update the notification title
  ///
  /// [title] - New notification title
  ///
  /// Returns true if title updated successfully.
  Future<bool> updateNotificationTitle(String title) async {
    if (_notificationConfig == null) {
      _log('No notification config set');
      return false;
    }

    final updatedConfig = ForegroundNotificationConfig(
      title: title,
      content: _notificationConfig!.content,
      channelId: _notificationConfig!.channelId,
      priority: _notificationConfig!.priority,
      showWhen: _notificationConfig!.showWhen,
      ongoing: _notificationConfig!.ongoing,
      autoCancel: _notificationConfig!.autoCancel,
    );

    return updateNotification(updatedConfig);
  }

  /// Update the notification content
  ///
  /// [content] - New notification content
  ///
  /// Returns true if content updated successfully.
  Future<bool> updateNotificationContent(String content) async {
    if (_notificationConfig == null) {
      _log('No notification config set');
      return false;
    }

    final updatedConfig = ForegroundNotificationConfig(
      title: _notificationConfig!.title,
      content: content,
      channelId: _notificationConfig!.channelId,
      priority: _notificationConfig!.priority,
      showWhen: _notificationConfig!.showWhen,
      ongoing: _notificationConfig!.ongoing,
      autoCancel: _notificationConfig!.autoCancel,
    );

    return updateNotification(updatedConfig);
  }

  /// Release wake lock if held
  ///
  /// Returns true if wake lock was released or wasn't held.
  Future<bool> releaseWakeLock() async {
    if (!_isWakeLockHeld) {
      _log('Wake lock not held');
      return true;
    }

    try {
      _log('Releasing wake lock...');

      final result = await _channel.invokeMethod('releaseWakeLock');

      if (result['success'] == true) {
        _isWakeLockHeld = false;
        _log('Wake lock released');
        return true;
      } else {
        _log('Failed to release wake lock: ${result['error']}');
        return false;
      }
    } catch (e) {
      _log('Error releasing wake lock: $e');
      return false;
    }
  }

  /// Check if foreground service is supported on this device
  Future<bool> isSupported() async {
    try {
      final result = await _channel.invokeMethod('isForegroundServiceSupported');
      return result['supported'] == true;
    } catch (e) {
      _log('Error checking foreground service support: $e');
      return false;
    }
  }

  /// Get current service status
  Map<String, dynamic> getStatus() {
    return {
      'state': _state.name,
      'isRunning': isRunning,
      'isForeground': isForeground,
      'isBackground': isBackground,
      'startTime': _startTime?.toIso8601String(),
      'uptime': uptime?.inSeconds,
      'wakeLockHeld': _isWakeLockHeld,
      'notificationConfig': _notificationConfig?.toMap(),
    };
  }

  void _updateState(ForegroundServiceState state) {
    _state = state;
    _stateController.add(state);
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] Foreground: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() async {
    // Stop service if running
    if (isRunning) {
      await stop();
    }

    _stateController.close();
    _logController.close();
  }
}
