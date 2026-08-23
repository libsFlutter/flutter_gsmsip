import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Activity Intent types for navigation routing
enum ActivityIntentType {
  /// View a tel: URL (from browser, email, etc.)
  view,

  /// Dial a phone number (from voice assistant, system dialer)
  dial,

  /// Unknown or unsupported intent type
  unknown
}

/// Activity Intent data structure
class ActivityIntentData {
  final ActivityIntentType type;
  final String? phoneNumber;
  final String? action;
  final Map<String, dynamic>? extras;

  const ActivityIntentData({
    required this.type,
    this.phoneNumber,
    this.action,
    this.extras,
  });

  factory ActivityIntentData.fromMap(Map<String, dynamic> map) {
    final typeString = map['type'] as String?;
    final ActivityIntentType type;

    switch (typeString?.toLowerCase()) {
      case 'view':
        type = ActivityIntentType.view;
        break;
      case 'dial':
        type = ActivityIntentType.dial;
        break;
      default:
        type = ActivityIntentType.unknown;
    }

    return ActivityIntentData(
      type: type,
      phoneNumber: map['phoneNumber'] as String?,
      action: map['action'] as String?,
      extras: map['extras'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap() => {
    'type': type.name,
    'phoneNumber': phoneNumber,
    'action': action,
    'extras': extras,
  };

  @override
  String toString() {
    return 'ActivityIntentData(type: $type, phoneNumber: $phoneNumber, action: $action)';
  }
}

/// Navigation route information
class NavigationRoute {
  final String routeName;
  final Map<String, dynamic>? arguments;

  const NavigationRoute({
    required this.routeName,
    this.arguments,
  });

  @override
  String toString() {
    return 'NavigationRoute(route: $routeName, args: $arguments)';
  }
}

/// Activity Intent Service for handling Android intent-based navigation
///
/// This service handles incoming intents from external sources such as:
/// - Browser tel: links
/// - Other apps sending intents
/// - Voice assistant commands
/// - QR scanner results
///
/// It provides navigation routing for deep links and internal navigation.
class ActivityIntentService {
  static final ActivityIntentService _instance = ActivityIntentService._internal();
  factory ActivityIntentService() => _instance;
  ActivityIntentService._internal();

  final Logger _logger = Logger();

  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/activity_intent');

  ActivityIntentData? _lastIntent;
  bool _isInitialized = false;

  // Stream controllers
  final StreamController<ActivityIntentData> _intentController =
      StreamController<ActivityIntentData>.broadcast();
  final StreamController<NavigationRoute> _navigationController =
      StreamController<NavigationRoute>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  // Navigation handlers
  final Map<ActivityIntentType, Function(ActivityIntentData)> _intentHandlers = {};
  final Map<String, Function(NavigationRoute)> _routeHandlers = {};

  // Getters
  ActivityIntentData? get lastIntent => _lastIntent;
  bool get isInitialized => _isInitialized;
  Stream<ActivityIntentData> get intentStream => _intentController.stream;
  Stream<NavigationRoute> get navigationStream => _navigationController.stream;
  Stream<String> get logStream => _logController.stream;

  /// Initialize the activity intent service
  ///
  /// Sets up the method channel handler for receiving intents from Android native code.
  Future<bool> initialize() async {
    try {
      _log('Initializing Activity Intent service...');

      // Set up method call handler
      _channel.setMethodCallHandler(_handleMethodCall);

      // Try to get initial intent (if app was launched with one)
      await _getInitialIntent();

      _isInitialized = true;
      _log('Activity Intent service initialized successfully');
      return true;
    } catch (e) {
      _log('Failed to initialize Activity Intent service: $e');
      return false;
    }
  }

  /// Handle method calls from native Android code
  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onIntentReceived':
        _handleIntentReceived(call.arguments);
        break;
      case 'onNavigationRequested':
        _handleNavigationRequested(call.arguments);
        break;
      default:
        _log('Unknown method call: ${call.method}');
    }
  }

  /// Get the initial intent that launched the app
  Future<void> _getInitialIntent() async {
    try {
      final result = await _channel.invokeMethod('getInitialIntent');

      if (result != null && result is Map) {
        final intentData = ActivityIntentData.fromMap(result as Map<String, dynamic>);
        _lastIntent = intentData;
        _log('Initial intent received: $intentData');

        // Process the initial intent
        _processIntent(intentData);
      }
    } catch (e) {
      _log('No initial intent or error getting it: $e');
    }
  }

  /// Handle intent received from native code
  void _handleIntentReceived(dynamic arguments) {
    try {
      if (arguments is Map) {
        final intentData = ActivityIntentData.fromMap(arguments as Map<String, dynamic>);
        _lastIntent = intentData;
        _intentController.add(intentData);
        _log('Intent received: $intentData');

        // Process the intent
        _processIntent(intentData);
      }
    } catch (e) {
      _log('Error handling intent received: $e');
    }
  }

  /// Handle navigation request from native code
  void _handleNavigationRequested(dynamic arguments) {
    try {
      if (arguments is Map) {
        final route = NavigationRoute(
          routeName: arguments['routeName'] as String,
          arguments: arguments['arguments'] as Map<String, dynamic>?,
        );
        _navigationController.add(route);
        _log('Navigation requested: $route');
      }
    } catch (e) {
      _log('Error handling navigation request: $e');
    }
  }

  /// Process an intent and route it to appropriate handler
  void _processIntent(ActivityIntentData intent) {
    // Call custom handler if registered
    final handler = _intentHandlers[intent.type];
    if (handler != null) {
      handler(intent);
    }

    // Route based on intent type
    switch (intent.type) {
      case ActivityIntentType.view:
        _handleViewIntent(intent);
        break;
      case ActivityIntentType.dial:
        _handleDialIntent(intent);
        break;
      case ActivityIntentType.unknown:
        _log('Unknown intent type, ignoring');
        break;
    }
  }

  /// Handle VIEW intent (tel: URL from browser, email, etc.)
  void _handleViewIntent(ActivityIntentData intent) {
    _log('Handling VIEW intent with phone number: ${intent.phoneNumber}');

    // Navigate to dialer screen with pre-filled number
    if (intent.phoneNumber != null && intent.phoneNumber!.isNotEmpty) {
      final route = NavigationRoute(
        routeName: '/dialer',
        arguments: {'phoneNumber': intent.phoneNumber, 'autoCall': false},
      );
      _navigationController.add(route);
    }
  }

  /// Handle DIAL intent (from voice assistant, system dialer)
  void _handleDialIntent(ActivityIntentData intent) {
    _log('Handling DIAL intent with phone number: ${intent.phoneNumber}');

    // Navigate to dialer screen with pre-filled number
    if (intent.phoneNumber != null && intent.phoneNumber!.isNotEmpty) {
      final route = NavigationRoute(
        routeName: '/dialer',
        arguments: {'phoneNumber': intent.phoneNumber, 'autoCall': false},
      );
      _navigationController.add(route);
    }
  }

  /// Register a handler for a specific intent type
  void registerIntentHandler(
    ActivityIntentType type,
    Function(ActivityIntentData) handler,
  ) {
    _intentHandlers[type] = handler;
    _log('Registered handler for intent type: $type');
  }

  /// Register a handler for a specific route
  void registerRouteHandler(String routeName, Function(NavigationRoute) handler) {
    _routeHandlers[routeName] = handler;
    _log('Registered handler for route: $routeName');
  }

  /// Navigate to a route internally
  void navigate(String routeName, {Map<String, dynamic>? arguments}) {
    final route = NavigationRoute(
      routeName: routeName,
      arguments: arguments,
    );
    _navigationController.add(route);
    _log('Internal navigation: $route');
  }

  /// Validate a phone number extracted from intent
  static bool isValidPhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return false;
    }

    // Allow: digits, +, *, #, -, spaces
    // Maximum length: 20 characters
    if (phone.length > 20) {
      return false;
    }

    final validPattern = RegExp(r'^[0-9+*#\- ]+$');
    return validPattern.hasMatch(phone);
  }

  /// Sanitize a phone number (remove invalid characters)
  static String? sanitizePhoneNumber(String? phone) {
    if (phone == null || phone.isEmpty) {
      return null;
    }

    // Keep only valid characters
    final sanitized = phone.replaceAll(RegExp(r'[^0-9+*#]'), '');
    return sanitized.isEmpty ? null : sanitized;
  }

  /// Parse a tel: URI and extract phone number
  static String? parseTelUri(String? uri) {
    if (uri == null || uri.isEmpty) {
      return null;
    }

    // Handle tel: scheme
    if (uri.startsWith('tel:')) {
      return uri.substring(4);
    }

    return uri;
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] ActivityIntent: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() {
    _intentController.close();
    _navigationController.close();
    _logController.close();
    _intentHandlers.clear();
    _routeHandlers.clear();
  }
}
