/// Screen Registry and Navigation Map
///
/// Centralized screen registration and navigation routing for the GOSTsimbox Gateway app.
///
/// ## Usage
///
/// ```dart
/// // Get route settings
/// final route = ScreenRegistry.getRoute('/dashboard');
///
/// // Check if screen exists
/// if (ScreenRegistry.hasScreen('/settings')) {
///   Navigator.pushNamed(context, '/settings');
/// }
///
/// // Get all screens by category
/// final settingsScreens = ScreenRegistry.getScreensByCategory(ScreenCategory.settings);
/// ```
library screen_registry;

import 'package:flutter/material.dart';

/// Screen category for organization
enum ScreenCategory {
  /// Main app screens
  main,

  /// Settings and configuration screens
  settings,

  /// Communication screens (calls, SMS, USSD)
  communication,

  /// Monitoring and analytics screens
  monitoring,

  /// Diagnostic and information screens
  diagnostic,

  /// Setup and onboarding screens
  setup,
}

/// Screen metadata for documentation and routing
class ScreenInfo {
  /// Unique route path (e.g., '/dashboard', '/settings')
  final String route;

  /// Human-readable screen name
  final String name;

  /// Screen description
  final String description;

  /// Screen category
  final ScreenCategory category;

  /// The widget class that renders this screen
  final Type widgetType;

  /// Whether this screen requires arguments
  final bool requiresArguments;

  /// Expected argument keys (if any)
  final List<String> argumentKeys;

  /// Whether this screen is a dialog/modal
  final bool isModal;

  /// Icon associated with this screen
  final IconData? icon;

  /// Creates screen information
  const ScreenInfo({
    required this.route,
    required this.name,
    required this.description,
    required this.category,
    required this.widgetType,
    this.requiresArguments = false,
    this.argumentKeys = const [],
    this.isModal = false,
    this.icon,
  });

  @override
  String toString() {
    return 'ScreenInfo(route: $route, name: $name, category: ${category.name})';
  }
}

/// Navigation route configuration
class NavigationRoute {
  /// Route path pattern
  final String path;

  /// Page builder function
  final Widget Function(BuildContext, Object? arguments) pageBuilder;

  /// Optional transition type
  final RouteTransition transition;

  /// Creates a navigation route
  const NavigationRoute({
    required this.path,
    required this.pageBuilder,
    this.transition = RouteTransition.material,
  });
}

/// Route transition types
enum RouteTransition {
  /// Standard Material transition
  material,

  /// Cupertino (iOS-style) transition
  cupertino,

  /// Fade transition
  fade,

  /// Slide transition
  slide,

  /// No transition
  none,
}

/// Screen Registry - Centralized screen management
///
/// Provides:
/// - Screen registration and lookup
/// - Navigation route generation
/// - Screen metadata access
/// - Category-based filtering
///
/// ## GAP-006 Resolution
///
/// This registry defines the complete screen structure for the app,
/// providing a single source of truth for all navigation routes.
class ScreenRegistry {
  /// Registered screens
  static final Map<String, ScreenInfo> _screens = {};

  /// Registered routes
  static final Map<String, NavigationRoute> _routes = {};

  /// Initialize the screen registry
  ///
  /// Call this in app initialization to register all screens.
  static void initialize() {
    _registerAllScreens();
    _registerAllRoutes();
  }

  /// Register all application screens
  static void _registerAllScreens() {
    // Main Screens
    registerScreen(ScreenInfo(
      route: '/dashboard',
      name: 'Dashboard',
      description: 'Main dashboard with gateway status and quick actions',
      category: ScreenCategory.main,
      widgetType: _getWidgetType('DashboardScreen'),
      icon: Icons.dashboard,
    ));

    registerScreen(ScreenInfo(
      route: '/setup',
      name: 'Setup',
      description: 'Initial app setup and configuration wizard',
      category: ScreenCategory.setup,
      widgetType: _getWidgetType('SetupScreen'),
      icon: Icons.setup,
    ));

    // Settings Screens
    registerScreen(ScreenInfo(
      route: '/settings',
      name: 'Settings',
      description: 'Application settings and configuration',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('SettingsScreen'),
      icon: Icons.settings,
    ));

    registerScreen(ScreenInfo(
      route: '/smpp-settings',
      name: 'SMPP Settings',
      description: 'SMPP protocol configuration',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('SmppSettingsScreen'),
      icon: Icons.message,
    ));

    registerScreen(ScreenInfo(
      route: '/theme-settings',
      name: 'Theme Settings',
      description: 'App theme and appearance configuration',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('ThemeSettingsScreen'),
      icon: Icons.palette,
    ));

    registerScreen(ScreenInfo(
      route: '/language-settings',
      name: 'Language Settings',
      description: 'Language and localization settings',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('LanguageSettingsScreen'),
      icon: Icons.language,
    ));

    registerScreen(ScreenInfo(
      route: '/lines',
      name: 'Lines Configuration',
      description: 'SIP lines and accounts management',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('LinesScreen'),
      icon: Icons.phone_in_talk,
    ));

    registerScreen(ScreenInfo(
      route: '/sims',
      name: 'SIM Cards',
      description: 'SIM card information and management',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('SimsScreen'),
      icon: Icons.sim_card,
    ));

    registerScreen(ScreenInfo(
      route: '/codecs',
      name: 'Codecs',
      description: 'Audio codec configuration',
      category: ScreenCategory.settings,
      widgetType: _getWidgetType('CodecsScreen'),
      icon: Icons.audio_file,
    ));

    // Communication Screens
    registerScreen(ScreenInfo(
      route: '/calls',
      name: 'Calls',
      description: 'Call history and active calls',
      category: ScreenCategory.communication,
      widgetType: _getWidgetType('CallsScreen'),
      icon: Icons.call,
    ));

    registerScreen(ScreenInfo(
      route: '/call',
      name: 'Active Call',
      description: 'Active call screen with controls',
      category: ScreenCategory.communication,
      widgetType: _getWidgetType('CallScreen'),
      icon: Icons.phone_in_talk,
      requiresArguments: true,
      argumentKeys: ['callId'],
    ));

    registerScreen(ScreenInfo(
      route: '/sms',
      name: 'SMS',
      description: 'SMS messages and composition',
      category: ScreenCategory.communication,
      widgetType: _getWidgetType('SmsScreen'),
      icon: Icons.sms,
    ));

    registerScreen(ScreenInfo(
      route: '/ussd',
      name: 'USSD',
      description: 'USSD code dialer and responses',
      category: ScreenCategory.communication,
      widgetType: _getWidgetType('UssdScreen'),
      icon: Icons.dialpad,
    ));

    // Monitoring Screens
    registerScreen(ScreenInfo(
      route: '/analytics',
      name: 'Analytics',
      description: 'Usage analytics and statistics',
      category: ScreenCategory.monitoring,
      widgetType: _getWidgetType('AnalyticsScreen'),
      icon: Icons.analytics,
    ));

    registerScreen(ScreenInfo(
      route: '/logs',
      name: 'Logs',
      description: 'Application and system logs',
      category: ScreenCategory.monitoring,
      widgetType: _getWidgetType('LogsScreen'),
      icon: Icons.bug_report,
    ));

    registerScreen(ScreenInfo(
      route: '/smpp-logs',
      name: 'SMPP Logs',
      description: 'SMPP protocol message logs',
      category: ScreenCategory.monitoring,
      widgetType: _getWidgetType('SmppLogsScreen'),
      icon: Icons.receipt_long,
    ));

    registerScreen(ScreenInfo(
      route: '/base-stations',
      name: 'Base Stations',
      description: 'Cell tower and base station information',
      category: ScreenCategory.monitoring,
      widgetType: _getWidgetType('BaseStationsScreen'),
      icon: Icons.cell_tower,
    ));

    // Diagnostic Screens
    registerScreen(ScreenInfo(
      route: '/info',
      name: 'App Info',
      description: 'Application information and diagnostics',
      category: ScreenCategory.diagnostic,
      widgetType: _getWidgetType('InfoScreen'),
      icon: Icons.info,
    ));

    registerScreen(ScreenInfo(
      route: '/theme-demo',
      name: 'Theme Demo',
      description: 'Theme preview and demonstration',
      category: ScreenCategory.diagnostic,
      widgetType: _getWidgetType('ThemeDemoScreen'),
      icon: Icons.color_lens,
    ));

    // Modal Screens
    registerScreen(ScreenInfo(
      route: '/language-selection',
      name: 'Select Language',
      description: 'Language selection dialog',
      category: ScreenCategory.setup,
      widgetType: _getWidgetType('LanguageSelectionScreen'),
      icon: Icons.language,
      isModal: true,
    ));
  }

  /// Register all navigation routes
  static void _registerAllRoutes() {
    // Main routes
    registerRoute(const NavigationRoute(
      path: '/dashboard',
      pageBuilder: (context, args) => _placeholder('Dashboard'),
    ));

    registerRoute(const NavigationRoute(
      path: '/setup',
      pageBuilder: (context, args) => _placeholder('Setup'),
    ));

    // Settings routes
    registerRoute(const NavigationRoute(
      path: '/settings',
      pageBuilder: (context, args) => _placeholder('Settings'),
    ));

    registerRoute(const NavigationRoute(
      path: '/smpp-settings',
      pageBuilder: (context, args) => _placeholder('SMPP Settings'),
    ));

    registerRoute(const NavigationRoute(
      path: '/theme-settings',
      pageBuilder: (context, args) => _placeholder('Theme Settings'),
    ));

    registerRoute(const NavigationRoute(
      path: '/language-settings',
      pageBuilder: (context, args) => _placeholder('Language Settings'),
    ));

    registerRoute(const NavigationRoute(
      path: '/lines',
      pageBuilder: (context, args) => _placeholder('Lines'),
    ));

    registerRoute(const NavigationRoute(
      path: '/sims',
      pageBuilder: (context, args) => _placeholder('SIMs'),
    ));

    registerRoute(const NavigationRoute(
      path: '/codecs',
      pageBuilder: (context, args) => _placeholder('Codecs'),
    ));

    // Communication routes
    registerRoute(const NavigationRoute(
      path: '/calls',
      pageBuilder: (context, args) => _placeholder('Calls'),
    ));

    registerRoute(const NavigationRoute(
      path: '/call',
      pageBuilder: (context, args) => _placeholder('Active Call'),
    ));

    registerRoute(const NavigationRoute(
      path: '/sms',
      pageBuilder: (context, args) => _placeholder('SMS'),
    ));

    registerRoute(const NavigationRoute(
      path: '/ussd',
      pageBuilder: (context, args) => _placeholder('USSD'),
    ));

    // Monitoring routes
    registerRoute(const NavigationRoute(
      path: '/analytics',
      pageBuilder: (context, args) => _placeholder('Analytics'),
    ));

    registerRoute(const NavigationRoute(
      path: '/logs',
      pageBuilder: (context, args) => _placeholder('Logs'),
    ));

    registerRoute(const NavigationRoute(
      path: '/smpp-logs',
      pageBuilder: (context, args) => _placeholder('SMPP Logs'),
    ));

    registerRoute(const NavigationRoute(
      path: '/base-stations',
      pageBuilder: (context, args) => _placeholder('Base Stations'),
    ));

    // Diagnostic routes
    registerRoute(const NavigationRoute(
      path: '/info',
      pageBuilder: (context, args) => _placeholder('Info'),
    ));

    registerRoute(const NavigationRoute(
      path: '/theme-demo',
      pageBuilder: (context, args) => _placeholder('Theme Demo'),
    ));

    // Modal routes
    registerRoute(const NavigationRoute(
      path: '/language-selection',
      pageBuilder: (context, args) => _placeholder('Language Selection'),
      transition: RouteTransition.fade,
    ));
  }

  /// Register a screen
  static void registerScreen(ScreenInfo screen) {
    _screens[screen.route] = screen;
  }

  /// Register a navigation route
  static void registerRoute(NavigationRoute route) {
    _routes[route.path] = route;
  }

  /// Get screen information by route
  static ScreenInfo? getScreen(String route) {
    return _screens[route];
  }

  /// Check if a screen exists
  static bool hasScreen(String route) {
    return _screens.containsKey(route);
  }

  /// Get all screens
  static List<ScreenInfo> getAllScreens() {
    return _screens.values.toList();
  }

  /// Get screens by category
  static List<ScreenInfo> getScreensByCategory(ScreenCategory category) {
    return _screens.values.where((s) => s.category == category).toList();
  }

  /// Get route by path
  static NavigationRoute? getRoute(String path) {
    return _routes[path];
  }

  /// Get all routes
  static Map<String, NavigationRoute> getAllRoutes() {
    return Map.unmodifiable(_routes);
  }

  /// Generate Material route settings
  static RouteSettings generateRouteSettings(String routeName, {Object? arguments}) {
    final screen = getScreen(routeName);
    return RouteSettings(
      name: routeName,
      arguments: arguments,
    );
  }

  /// Generate page route with transition
  static PageRouteBuilder<dynamic> generatePageRoute({
    required String routeName,
    Object? arguments,
  }) {
    final route = getRoute(routeName);
    if (route == null) {
      throw Exception('Route not found: $routeName');
    }

    return PageRouteBuilder(
      settings: generateRouteSettings(routeName, arguments: arguments),
      pageBuilder: (context, animation, secondaryAnimation) {
        return route.pageBuilder(context, arguments);
      },
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        switch (route.transition) {
          case RouteTransition.fade:
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          case RouteTransition.slide:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.cupertino:
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            );
          case RouteTransition.none:
            return child;
          case RouteTransition.material:
          default:
            return child;
        }
      },
    );
  }

  /// Get navigation map as Markdown documentation
  static String toMarkdown() {
    final buffer = StringBuffer();
    buffer.writeln('# Navigation Map\n');
    buffer.writeln('Generated by ScreenRegistry\n');
    buffer.writeln('Last updated: ${DateTime.now().toIso8601String()}\n');

    for (final category in ScreenCategory.values) {
      final screens = getScreensByCategory(category);
      if (screens.isEmpty) continue;

      buffer.writeln('## ${_categoryName(category)}\n');
      buffer.writeln('| Route | Name | Description | Modal |');
      buffer.writeln('|-------|------|-------------|-------|');

      for (final screen in screens) {
        buffer.writeln(
          '| `${screen.route}` | ${screen.name} | ${screen.description} | ${screen.isModal ? 'Yes' : 'No'} |',
        );
      }
      buffer.writeln();
    }

    return buffer.toString();
  }

  /// Get category display name
  static String _categoryName(ScreenCategory category) {
    switch (category) {
      case ScreenCategory.main:
        return 'Main Screens';
      case ScreenCategory.settings:
        return 'Settings';
      case ScreenCategory.communication:
        return 'Communication';
      case ScreenCategory.monitoring:
        return 'Monitoring';
      case ScreenCategory.diagnostic:
        return 'Diagnostic';
      case ScreenCategory.setup:
        return 'Setup';
    }
  }

  /// Get widget type by name (placeholder for reflection)
  static Type _getWidgetType(String name) {
    // In a real implementation, this would use reflection or a type registry
    // For now, return a placeholder
    return Object;
  }

  /// Placeholder widget for route registration
  static Widget _placeholder(String name) {
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: Center(child: Text('Placeholder: $name')),
    );
  }

  /// Clear all registrations (for testing)
  static void clear() {
    _screens.clear();
    _routes.clear();
  }
}

/// Navigation helper extensions
extension NavigationExtension on BuildContext {
  /// Navigate to a named route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  /// Navigate to a named route and replace current
  Future<T?> navigateToReplacement<T>(String routeName, {Object? arguments}) {
    return Navigator.pushReplacementNamed(this, routeName, arguments: arguments);
  }

  /// Navigate to a named route and remove all previous routes
  Future<T?> navigateToAndClear<T>(String routeName, {Object? arguments}) {
    return Navigator.pushNamedAndRemoveUntil(
      this,
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current route
  void pop<T>([T? result]) {
    Navigator.pop(this, result);
  }
}
