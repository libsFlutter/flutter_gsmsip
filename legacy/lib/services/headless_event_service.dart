import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// HeadlessEventService - Event handling for headless mode
///
/// This service manages event broadcasting and handling when running
/// in headless mode. It provides a mechanism for the headless service
/// to communicate with the main application and vice versa.
///
/// Features:
/// - Event broadcasting to headless service
/// - Event reception from headless service
/// - Event queue for pending events
/// - Event filtering by type
class HeadlessEventService extends ChangeNotifier {
  static const EventChannel _eventChannel = EventChannel('gsm_sip_gateway/headless_events');
  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/headless');

  final Logger _logger = Logger();

  // Event types
  static const String eventTypePeriodicTick = 'periodic_tick';
  static const String eventTypeServiceStarted = 'service_started';
  static const String eventTypeServiceStopped = 'service_stopped';
  static const String eventTypeBootCompleted = 'boot_completed';
  static const String eventTypeDataSync = 'data_sync';
  static const String eventTypeCustom = 'custom';

  // Event queue
  final List<HeadlessEvent> _eventQueue = [];
  static const int maxQueueSize = 100;

  // Event listeners
  final Map<String, List<Function(HeadlessEvent)>> _eventListeners = {};

  // Stream controller for all events
  final StreamController<HeadlessEvent> _eventStreamController =
      StreamController<HeadlessEvent>.broadcast();

  // Service state
  bool _isInitialized = false;
  bool _isHeadlessMode = false;
  StreamSubscription<dynamic>? _eventStreamSubscription;

  /// Get whether the service is initialized
  bool get isInitialized => _isInitialized;

  /// Get whether running in headless mode
  bool get isHeadlessMode => _isHeadlessMode;

  /// Get the event queue
  List<HeadlessEvent> get eventQueue => List.unmodifiable(_eventQueue);

  /// Get the stream of all events
  Stream<HeadlessEvent> get eventStream => _eventStreamController.stream;

  /// Initialize the event service
  ///
  /// [isHeadless] - Whether running in headless mode
  Future<bool> initialize({bool isHeadless = false}) async {
    try {
      _logger.i('Initializing HeadlessEventService (headless: $isHeadless)...');
      
      _isHeadlessMode = isHeadless;

      if (!isHeadless) {
        // Set up event listener for headless events (only in main app)
        await _setupEventListener();
      }

      _isInitialized = true;
      _logger.i('HeadlessEventService initialized successfully');
      notifyListeners();
      return true;
    } catch (e) {
      _logger.e('Failed to initialize HeadlessEventService: $e');
      return false;
    }
  }

  /// Set up the event listener for native events
  Future<void> _setupEventListener() async {
    try {
      _eventStreamSubscription?.cancel();
      _eventStreamSubscription = _eventChannel
          .receiveBroadcastStream()
          .listen(
            _handleNativeEvent,
            onError: _handleEventError,
            onDone: _handleEventDone,
          );
      _logger.d('Native event listener set up');
    } catch (e) {
      _logger.w('Event channel not available: $e');
      // Event channel is optional
    }
  }

  /// Handle events from native code
  void _handleNativeEvent(dynamic event) {
    try {
      if (event is Map) {
        final eventData = Map<String, dynamic>.from(event);
        final headlessEvent = HeadlessEvent.fromMap(eventData);
        _logger.d('Native event received: ${headlessEvent.type}');
        
        _processEvent(headlessEvent);
      } else if (event is String) {
        // Handle string events
        final headlessEvent = HeadlessEvent(
          type: eventTypeCustom,
          data: {'message': event},
          timestamp: DateTime.now(),
        );
        _processEvent(headlessEvent);
      }
    } catch (e) {
      _logger.e('Error handling native event: $e');
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

  /// Process an incoming event
  void _processEvent(HeadlessEvent event) {
    // Add to queue
    _addToQueue(event);

    // Broadcast to stream
    _eventStreamController.add(event);

    // Notify specific listeners
    _notifyListeners(event);

    // Notify ChangeNotifier listeners
    notifyListeners();

    _logger.d('Event processed: ${event.type}');
  }

  /// Add event to queue with size limit
  void _addToQueue(HeadlessEvent event) {
    if (_eventQueue.length >= maxQueueSize) {
      // Remove oldest event
      _eventQueue.removeAt(0);
    }
    _eventQueue.add(event);
  }

  /// Notify registered listeners for specific event type
  void _notifyListeners(HeadlessEvent event) {
    // Notify type-specific listeners
    final listeners = _eventListeners[event.type] ?? [];
    for (final listener in listeners) {
      try {
        listener(event);
      } catch (e) {
        _logger.e('Error in event listener: $e');
      }
    }

    // Notify wildcard listeners
    final wildcardListeners = _eventListeners['*'] ?? [];
    for (final listener in wildcardListeners) {
      try {
        listener(event);
      } catch (e) {
        _logger.e('Error in wildcard event listener: $e');
      }
    }
  }

  /// Register an event listener for a specific event type
  ///
  /// [eventType] - Type of event to listen for (use '*' for all events)
  /// [listener] - Callback function to invoke when event is received
  ///
  /// Returns a function to unsubscribe the listener
  Function unsubscribe onEvent(String eventType, Function(HeadlessEvent) listener) {
    if (!_eventListeners.containsKey(eventType)) {
      _eventListeners[eventType] = [];
    }
    _eventListeners[eventType]!.add(listener);

    _logger.d('Event listener registered for: $eventType');

    // Return unsubscribe function
    return () {
      _eventListeners[eventType]?.remove(listener);
      _logger.d('Event listener unregistered for: $eventType');
    };
  }

  /// Broadcast an event to the headless service
  ///
  /// [event] - Event to broadcast
  ///
  /// Returns true if the event was broadcast successfully
  Future<bool> broadcastEvent(HeadlessEvent event) async {
    try {
      _logger.i('Broadcasting event: ${event.type}');

      // Send to native channel
      await _channel.invokeMethod('broadcastEvent', event.toMap());

      // Also process locally
      _processEvent(event);

      return true;
    } on PlatformException catch (e) {
      _logger.e('Failed to broadcast event: ${e.message}');
      return false;
    } catch (e) {
      _logger.e('Unexpected error broadcasting event: $e');
      return false;
    }
  }

  /// Broadcast a custom event with data
  ///
  /// [type] - Event type
  /// [data] - Event data
  ///
  /// Returns true if the event was broadcast successfully
  Future<bool> broadcastCustomEvent(String type, Map<String, dynamic> data) async {
    final event = HeadlessEvent(
      type: type,
      data: data,
      timestamp: DateTime.now(),
    );
    return broadcastEvent(event);
  }

  /// Broadcast a periodic tick event
  Future<bool> broadcastTick({int? tickCount}) async {
    final event = HeadlessEvent(
      type: eventTypePeriodicTick,
      data: {'tick_count': tickCount},
      timestamp: DateTime.now(),
    );
    return broadcastEvent(event);
  }

  /// Broadcast a data sync request
  Future<bool> requestDataSync({String? reason}) async {
    final event = HeadlessEvent(
      type: eventTypeDataSync,
      data: {'reason': reason ?? 'requested'},
      timestamp: DateTime.now(),
    );
    return broadcastEvent(event);
  }

  /// Get events from the queue by type
  List<HeadlessEvent> getEventsByType(String type) {
    return _eventQueue.where((e) => e.type == type).toList();
  }

  /// Get the last N events
  List<HeadlessEvent> getLastEvents(int count) {
    if (count >= _eventQueue.length) {
      return List.from(_eventQueue);
    }
    return _eventQueue.sublist(_eventQueue.length - count);
  }

  /// Clear the event queue
  void clearQueue() {
    _eventQueue.clear();
    _logger.d('Event queue cleared');
    notifyListeners();
  }

  /// Execute a task in response to an event
  ///
  /// This is useful for headless mode where you want to process
  /// events and perform actions based on them.
  Future<void> executeTaskForEvent(
    HeadlessEvent event,
    Future<void> Function(HeadlessEvent) task,
  ) async {
    try {
      _logger.d('Executing task for event: ${event.type}');
      await task(event);
      _logger.d('Task completed for event: ${event.type}');
    } catch (e) {
      _logger.e('Task failed for event ${event.type}: $e');
      rethrow;
    }
  }

  /// Clean up resources
  @override
  void dispose() {
    _eventStreamSubscription?.cancel();
    _eventStreamController.close();
    _eventListeners.clear();
    _eventQueue.clear();
    _logger.d('HeadlessEventService disposed');
    super.dispose();
  }
}

/// Represents an event in the headless service
class HeadlessEvent {
  final String type;
  final Map<String, dynamic> data;
  final DateTime timestamp;
  final String? id;

  const HeadlessEvent({
    required this.type,
    required this.data,
    required this.timestamp,
    this.id,
  });

  /// Create an event from a map
  factory HeadlessEvent.fromMap(Map<String, dynamic> map) {
    return HeadlessEvent(
      type: map['type'] as String? ?? 'unknown',
      data: map['data'] as Map<String, dynamic>? ?? {},
      timestamp: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'] as String)
          : DateTime.now(),
      id: map['id'] as String?,
    );
  }

  /// Convert the event to a map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      'data': data,
      'timestamp': timestamp.toIso8601String(),
      if (id != null) 'id': id,
    };
  }

  /// Convert the event to JSON
  String toJson() => jsonEncode(toMap());

  /// Create an event from JSON
  factory HeadlessEvent.fromJson(String json) {
    return HeadlessEvent.fromMap(jsonDecode(json) as Map<String, dynamic>);
  }

  /// Get a specific data field
  T? getData<T>(String key, {T? defaultValue}) {
    return data[key] as T? ?? defaultValue;
  }

  @override
  String toString() {
    return 'HeadlessEvent(type: $type, timestamp: $timestamp, data: $data)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HeadlessEvent &&
        other.type == type &&
        other.timestamp == timestamp &&
        other.id == id;
  }

  @override
  int get hashCode => type.hashCode ^ timestamp.hashCode ^ (id?.hashCode ?? 0);
}
