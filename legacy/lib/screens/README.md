# Screens Module

> Centralized screen management and navigation for GOSTsimbox Gateway

**Source:** `vdd-screens`  
**Tasks:** screens-001, screens-002  
**GAP:** GAP-006

---

## Overview

This module provides centralized screen registration and navigation routing for the GOSTsimbox Gateway application. It defines the complete screen structure, navigation flow, and screen metadata.

### Files

| File | Purpose |
|------|---------|
| `lib/navigation/screen_registry.dart` | Screen registry and navigation utilities |
| `lib/screens/README.md` | This documentation file |
| `lib/screens/*.dart` | Individual screen implementations |

---

## Screen Structure

### Navigation Map

The app uses a hierarchical navigation structure with the following categories:

```
GOSTsimbox Gateway
├── Main Screens
│   ├── /dashboard          - Main dashboard
│   └── /setup              - Initial setup wizard
│
├── Settings
│   ├── /settings           - Main settings
│   ├── /smpp-settings      - SMPP configuration
│   ├── /theme-settings     - Theme configuration
│   ├── /language-settings  - Language settings
│   ├── /lines              - SIP lines management
│   ├── /sims               - SIM card management
│   └── /codecs             - Audio codecs
│
├── Communication
│   ├── /calls              - Call history
│   ├── /call               - Active call screen
│   ├── /sms                - SMS messages
│   └── /ussd               - USSD dialer
│
├── Monitoring
│   ├── /analytics          - Usage analytics
│   ├── /logs               - App logs
│   ├── /smpp-logs          - SMPP protocol logs
│   └── /base-stations      - Cell tower info
│
├── Diagnostic
│   ├── /info               - App information
│   └── /theme-demo         - Theme preview
│
└── Setup (Modal)
    └── /language-selection - Language selector
```

---

## Screen Registry API

### Usage

```dart
import 'package:flutter_gsm_sip_gateway/navigation/screen_registry.dart';

// Initialize registry (call in app initialization)
ScreenRegistry.initialize();

// Get screen information
final screen = ScreenRegistry.getScreen('/dashboard');
if (screen != null) {
  print('Screen: ${screen.name}');
  print('Description: ${screen.description}');
}

// Check if screen exists
if (ScreenRegistry.hasScreen('/settings')) {
  Navigator.pushNamed(context, '/settings');
}

// Get screens by category
final settingsScreens = ScreenRegistry.getScreensByCategory(
  ScreenCategory.settings,
);

// Generate route with transition
final route = ScreenRegistry.generatePageRoute(
  routeName: '/dashboard',
  arguments: {'key': 'value'},
);
```

### Extension Methods

```dart
import 'package:flutter_gsm_sip_gateway/navigation/screen_registry.dart';

// Navigate to screen
context.navigateTo('/settings');

// Navigate and replace current
context.navigateToReplacement('/dashboard');

// Navigate and clear history
context.navigateToAndClear('/setup');

// Pop current screen
context.pop();
```

---

## Screen Categories

### ScreenCategory Enum

| Category | Description | Screens |
|----------|-------------|---------|
| `main` | Primary app screens | Dashboard, Setup |
| `settings` | Configuration screens | Settings, SMPP, Theme, Language, Lines, SIMs, Codecs |
| `communication` | Communication features | Calls, Call, SMS, USSD |
| `monitoring` | Monitoring and logs | Analytics, Logs, SMPP Logs, Base Stations |
| `diagnostic` | Diagnostics and info | Info, Theme Demo |
| `setup` | Onboarding flows | Language Selection |

---

## Screen Information

### ScreenInfo Properties

| Property | Type | Description |
|----------|------|-------------|
| `route` | String | Unique route path (e.g., '/dashboard') |
| `name` | String | Human-readable screen name |
| `description` | String | Screen description |
| `category` | ScreenCategory | Screen category |
| `widgetType` | Type | Widget class type |
| `requiresArguments` | bool | Whether screen needs arguments |
| `argumentKeys` | List<String> | Expected argument keys |
| `isModal` | bool | Whether screen is a dialog/modal |
| `icon` | IconData? | Associated icon |

---

## Navigation Routes

### RouteTransition Types

| Transition | Description |
|------------|-------------|
| `material` | Standard Material transition |
| `cupertino` | iOS-style slide transition |
| `fade` | Fade in/out transition |
| `slide` | Slide from right transition |
| `none` | No transition |

---

## Implementation Details

### Screen Registration

Screens are registered in `ScreenRegistry._registerAllScreens()`:

```dart
ScreenRegistry.registerScreen(ScreenInfo(
  route: '/dashboard',
  name: 'Dashboard',
  description: 'Main dashboard with gateway status',
  category: ScreenCategory.main,
  widgetType: DashboardScreen,
  icon: Icons.dashboard,
));
```

### Route Registration

Routes are registered in `ScreenRegistry._registerAllRoutes()`:

```dart
ScreenRegistry.registerRoute(const NavigationRoute(
  path: '/dashboard',
  pageBuilder: (context, args) => const DashboardScreen(),
  transition: RouteTransition.material,
));
```

---

## GAP-006 Resolution

**GAP-006: Create requirements document for screens module**

This document serves as the requirements specification for the screens module:

### Requirements

| ID | Requirement | Status |
|----|-------------|--------|
| SCR-001 | Define complete screen structure | ✅ Implemented |
| SCR-002 | Provide navigation routing | ✅ Implemented |
| SCR-003 | Support screen categories | ✅ Implemented |
| SCR-004 | Document all screens | ✅ Implemented |
| SCR-005 | Support modal screens | ✅ Implemented |
| SCR-006 | Support route transitions | ✅ Implemented |
| SCR-007 | Provide screen metadata | ✅ Implemented |
| SCR-008 | Enable category filtering | ✅ Implemented |

---

## Screen Files

### Existing Screens

| File | Screen | Route |
|------|--------|-------|
| `dashboard_screen.dart` | DashboardScreen | /dashboard |
| `setup_screen.dart` | SetupScreen | /setup |
| `settings_screen.dart` | SettingsScreen | /settings |
| `smpp_settings_screen.dart` | SmppSettingsScreen | /smpp-settings |
| `theme_settings_screen.dart` | ThemeSettingsScreen | /theme-settings |
| `language_settings_screen.dart` | LanguageSettingsScreen | /language-settings |
| `lines_screen.dart` | LinesScreen | /lines |
| `sims_screen.dart` | SimsScreen | /sims |
| `codecs_screen.dart` | CodecsScreen | /codecs |
| `calls_screen.dart` | CallsScreen | /calls |
| `call_screen.dart` | CallScreen | /call |
| `sms_screen.dart` | SmsScreen | /sms |
| `ussd_screen.dart` | UssdScreen | /ussd |
| `analytics_screen.dart` | AnalyticsScreen | /analytics |
| `logs_screen.dart` | LogsScreen | /logs |
| `smpp_logs_screen.dart` | SmppLogsScreen | /smpp-logs |
| `base_stations_screen.dart` | BaseStationsScreen | /base-stations |
| `info_screen.dart` | InfoScreen | /info |
| `theme_demo_screen.dart` | ThemeDemoScreen | /theme-demo |
| `language_selection_screen.dart` | LanguageSelectionScreen | /language-selection |

---

## Testing

### Screen Registry Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/navigation/screen_registry.dart';

void main() {
  group('ScreenRegistry', () {
    setUp(() {
      ScreenRegistry.initialize();
    });

    tearDown(() {
      ScreenRegistry.clear();
    });

    test('should register all screens', () {
      final screens = ScreenRegistry.getAllScreens();
      expect(screens.length, greaterThan(0));
    });

    test('should get screen by route', () {
      final screen = ScreenRegistry.getScreen('/dashboard');
      expect(screen, isNotNull);
      expect(screen!.name, equals('Dashboard'));
    });

    test('should check screen existence', () {
      expect(ScreenRegistry.hasScreen('/dashboard'), isTrue);
      expect(ScreenRegistry.hasScreen('/nonexistent'), isFalse);
    });

    test('should filter by category', () {
      final settings = ScreenRegistry.getScreensByCategory(
        ScreenCategory.settings,
      );
      expect(settings.length, greaterThan(0));
      expect(
        settings.every((s) => s.category == ScreenCategory.settings),
        isTrue,
      );
    });
  });
}
```

---

## Future Enhancements

- [ ] Add deep linking support
- [ ] Implement nested navigation
- [ ] Add navigation guards
- [ ] Support for tabbed navigation
- [ ] Animation customization
- [ ] Screen transition presets

---

*Last updated: 2026-03-06*
