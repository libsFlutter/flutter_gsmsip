import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gsm_sip_gateway/services/theme_service.dart';
import 'package:flutter_gsm_sip_gateway/services/storage_service.dart';
import 'package:flutter_gsm_sip_gateway/widgets/status_indicator.dart';
import 'package:flutter_gsm_sip_gateway/theme/app_theme.dart';

void main() {
  group('Theme + Service Integration Tests', () {
    setUp(() async {
      SharedPreferences.setMockInitialValues({});
    });

    group('ThemeService + StorageService Integration', () {
      testWidgets('should persist and restore theme across app restarts', (WidgetTester tester) async {
        // First session - create and configure theme service
        SharedPreferences.setMockInitialValues({});
        
        final themeService1 = ThemeService();
        await themeService1.initialize();
        
        // Verify default theme
        expect(themeService1.themeMode, ThemeMode.dark);
        
        // Change theme to light
        await themeService1.setLightTheme();
        expect(themeService1.themeMode, ThemeMode.light);
        
        // Dispose first service
        themeService1.dispose();
        
        // Second session - create new theme service
        final themeService2 = ThemeService();
        await themeService2.initialize();
        
        // Verify theme was persisted
        expect(themeService2.themeMode, ThemeMode.light);
        expect(themeService2.getThemeName(), 'Light');
        
        // Cleanup
        themeService2.dispose();
      });

      testWidgets('should handle theme toggle with persistence', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        // Toggle through all themes
        await themeService.toggleTheme(); // Dark -> System
        expect(themeService.themeMode, ThemeMode.system);
        
        await themeService.toggleTheme(); // System -> Light
        expect(themeService.themeMode, ThemeMode.light);
        
        await themeService.toggleTheme(); // Light -> Dark
        expect(themeService.themeMode, ThemeMode.dark);
        
        // Create new instance and verify
        final newService = ThemeService();
        await newService.initialize();
        expect(newService.themeMode, ThemeMode.dark);
        
        // Cleanup
        themeService.dispose();
        newService.dispose();
      });
    });

    group('ThemeService + Widget Integration', () {
      Widget createThemedApp(ThemeService themeService) {
        return MaterialApp(
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeService.themeMode,
          home: ChangeNotifierProvider<ThemeService>.value(
            value: themeService,
            child: const Scaffold(
              body: Column(
                children: [
                  StatusIndicator(status: 'connected'),
                  StatusIndicator(status: 'connecting'),
                  StatusIndicator(status: 'disconnected'),
                ],
              ),
            ),
          ),
        );
      }

      testWidgets('should update widget colors when theme changes', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        await tester.pumpWidget(createThemedApp(themeService));
        
        // Verify initial status indicators are displayed
        expect(find.text('Connection Status'), findsNWidgets(3));
        expect(find.text('connected'), findsOneWidget);
        expect(find.text('connecting'), findsOneWidget);
        expect(find.text('disconnected'), findsOneWidget);
        
        // Change theme
        await themeService.setLightTheme();
        await tester.pump();
        
        // Verify widgets still display correctly after theme change
        expect(find.text('Connection Status'), findsNWidgets(3));
      });

      testWidgets('should display correct status colors in dark theme', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        await themeService.setDarkTheme();
        
        await tester.pumpWidget(createThemedApp(themeService));
        
        // Verify status indicators are displayed
        expect(find.text('connected'), findsOneWidget);
        expect(find.text('connecting'), findsOneWidget);
        expect(find.text('disconnected'), findsOneWidget);
        
        // Verify color method returns expected values
        expect(themeService.getConnectionStatusColor('connected'), const Color(0xFF10B981));
        expect(themeService.getConnectionStatusColor('connecting'), const Color(0xFFF59E0B));
        expect(themeService.getConnectionStatusColor('disconnected'), const Color(0xFFEF4444));
      });
    });

    group('ThemeService + Signal Level Integration', () {
      testWidgets('should return correct signal colors for all levels', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        // Test all signal levels
        expect(themeService.getSignalLevelColor(100), const Color(0xFF10B981)); // Excellent
        expect(themeService.getSignalLevelColor(80), const Color(0xFF10B981));  // Excellent
        expect(themeService.getSignalLevelColor(70), const Color(0xFF34D399));  // Good
        expect(themeService.getSignalLevelColor(60), const Color(0xFF34D399));  // Good
        expect(themeService.getSignalLevelColor(50), const Color(0xFFF59E0B));  // Fair
        expect(themeService.getSignalLevelColor(40), const Color(0xFFF59E0B));  // Fair
        expect(themeService.getSignalLevelColor(30), const Color(0xFFF97316));  // Poor
        expect(themeService.getSignalLevelColor(20), const Color(0xFFF97316));  // Poor
        expect(themeService.getSignalLevelColor(10), const Color(0xFFEF4444));  // Critical
        expect(themeService.getSignalLevelColor(0), const Color(0xFFEF4444));   // Critical
      });
    });

    group('ThemeService + Call Status Integration', () {
      testWidgets('should return correct call status colors', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        // Test active call colors
        expect(themeService.getCallStatusColor('active'), const Color(0xFF10B981));
        expect(themeService.getCallStatusColor('incoming'), const Color(0xFF10B981));
        expect(themeService.getCallStatusColor('outgoing'), const Color(0xFF10B981));
        
        // Test ended call colors
        expect(themeService.getCallStatusColor('ended'), const Color(0xFFEF4444));
        expect(themeService.getCallStatusColor('missed'), const Color(0xFFEF4444));
        
        // Test idle/waiting colors
        expect(themeService.getCallStatusColor('idle'), const Color(0xFFF59E0B));
        expect(themeService.getCallStatusColor('waiting'), const Color(0xFFF59E0B));
      });
    });

    group('Full App Theme Integration', () {
      testWidgets('should apply theme to MaterialApp', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        late ThemeData capturedTheme;
        late ThemeData capturedDarkTheme;
        
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: Builder(
              builder: (context) {
                capturedTheme = Theme.of(context);
                return const Scaffold();
              },
            ),
          ),
        );
        
        // Verify dark theme is applied (default)
        expect(capturedTheme.brightness, Brightness.dark);
        
        // Change to light theme
        await themeService.setLightTheme();
        await tester.pumpWidget(
          MaterialApp(
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeService.themeMode,
            home: Builder(
              builder: (context) {
                capturedTheme = Theme.of(context);
                return const Scaffold();
              },
            ),
          ),
        );
        
        // Verify light theme is applied
        expect(capturedTheme.brightness, Brightness.light);
        
        themeService.dispose();
      });

      testWidgets('should handle system theme mode', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        await themeService.setSystemTheme();
        
        expect(themeService.themeMode, ThemeMode.system);
        
        // System theme should follow platform brightness
        // In test environment, we can't change platform brightness,
        // but we can verify the mode is set correctly
        expect(themeService.getThemeName(), 'System');
        expect(themeService.getThemeIcon(), Icons.settings_system_daydream);
        
        themeService.dispose();
      });
    });

    group('Error Handling Integration', () {
      testWidgets('should handle SharedPreferences errors gracefully', (WidgetTester tester) async {
        // Set up with invalid data
        SharedPreferences.setMockInitialValues({
          'gost_simbox_theme': 'invalid', // Should be int, not string
        });
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        // Should fallback to dark theme on error
        expect(themeService.themeMode, ThemeMode.dark);
        
        themeService.dispose();
      });

      testWidgets('should handle multiple rapid theme changes', (WidgetTester tester) async {
        SharedPreferences.setMockInitialValues({});
        
        final themeService = ThemeService();
        await themeService.initialize();
        
        // Rapidly toggle themes
        await themeService.toggleTheme();
        await themeService.toggleTheme();
        await themeService.toggleTheme();
        await themeService.setLightTheme();
        await themeService.setDarkTheme();
        await themeService.setSystemTheme();
        
        expect(themeService.themeMode, ThemeMode.system);
        
        // Verify persistence still works
        final newService = ThemeService();
        await newService.initialize();
        expect(newService.themeMode, ThemeMode.system);
        
        themeService.dispose();
        newService.dispose();
      });
    });
  });
}
