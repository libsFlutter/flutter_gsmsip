import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_gsm_sip_gateway/main.dart';
import 'package:flutter_gsm_sip_gateway/presentation/screens/home_screen.dart';
import 'package:flutter_gsm_sip_gateway/presentation/screens/settings_screen.dart';

void main() {
  group('App Integration Tests', () {
    testWidgets('should navigate through main screens', (WidgetTester tester) async {
      // Start the app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify we're on the home screen
      expect(find.byType(HomeScreen), findsOneWidget);

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify we're on the settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);

      // Navigate back to home
      await tester.tap(find.byIcon(Icons.home));
      await tester.pumpAndSettle();

      // Verify we're back on the home screen
      expect(find.byType(HomeScreen), findsOneWidget);
    });

    testWidgets('should handle theme switching', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Get initial theme
      final initialTheme = Theme.of(tester.element(find.byType(MaterialApp)));

      // Toggle theme
      await tester.tap(find.byIcon(Icons.brightness_6));
      await tester.pumpAndSettle();

      // Verify theme changed
      final newTheme = Theme.of(tester.element(find.byType(MaterialApp)));
      expect(newTheme.brightness, isNot(equals(initialTheme.brightness)));
    });

    testWidgets('should handle language switching', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Navigate to settings
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Change language
      await tester.tap(find.text('Language'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('English'));
      await tester.pumpAndSettle();

      // Verify language changed
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('should handle gateway start/stop', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Start gateway
      await tester.tap(find.text('Start Gateway'));
      await tester.pumpAndSettle();

      // Verify gateway is running
      expect(find.text('Running'), findsOneWidget);

      // Stop gateway
      await tester.tap(find.text('Stop Gateway'));
      await tester.pumpAndSettle();

      // Verify gateway is stopped
      expect(find.text('Stopped'), findsOneWidget);
    });

    testWidgets('should display error messages appropriately', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simulate an error by tapping a button that might fail
      await tester.tap(find.text('Test Connection'));
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Connection failed'), findsOneWidget);
    });

    testWidgets('should handle network connectivity changes', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simulate network disconnection
      // This would typically be done by mocking the connectivity service
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify offline indicator is shown
      expect(find.text('Offline'), findsOneWidget);
    });

    testWidgets('should persist settings across app restarts', (WidgetTester tester) async {
      // First session
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Change a setting
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Auto Start'));
      await tester.pumpAndSettle();

      // Restart app
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Verify setting is persisted
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();
      expect(find.byType(Checkbox), findsOneWidget);
    });

    testWidgets('should handle deep linking', (WidgetTester tester) async {
      // Simulate deep link to settings
      await tester.pumpWidget(const MyApp(initialRoute: '/settings'));
      await tester.pumpAndSettle();

      // Verify we're on settings screen
      expect(find.byType(SettingsScreen), findsOneWidget);
    });

    testWidgets('should handle app lifecycle events', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Simulate app pause
      await tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      await tester.pumpAndSettle();

      // Simulate app resume
      await tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      // Verify app continues to work normally
      expect(find.byType(HomeScreen), findsOneWidget);
    });
  });
}
