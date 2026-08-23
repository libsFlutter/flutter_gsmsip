import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gsm_sip_gateway/services/theme_service.dart';

void main() {
  group('ThemeService', () {
    late ThemeService themeService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      themeService = ThemeService();
      await themeService.initialize();
    });

    tearDown(() {
      themeService.dispose();
    });

    group('Initialization', () {
      testWidgets('should initialize with dark theme by default', (WidgetTester tester) async {
        // arrange
        SharedPreferences.setMockInitialValues({});

        // act
        final service = ThemeService();
        await service.initialize();

        // assert
        expect(service.themeMode, ThemeMode.dark);
        expect(service.isDarkMode, isTrue);
        expect(service.isLightMode, isFalse);
      });

      testWidgets('should load saved theme from preferences', (WidgetTester tester) async {
        // arrange - save light theme (index 0)
        SharedPreferences.setMockInitialValues({'gost_simbox_theme': 0});

        // act
        final service = ThemeService();
        await service.initialize();

        // assert
        expect(service.themeMode, ThemeMode.light);
        expect(service.isLightMode, isTrue);
      });

      testWidgets('should default to dark theme on load error', (WidgetTester tester) async {
        // arrange - invalid theme index
        SharedPreferences.setMockInitialValues({'gost_simbox_theme': 999});

        // act
        final service = ThemeService();
        await service.initialize();

        // assert - should fallback to dark theme
        expect(service.themeMode, ThemeMode.dark);
      });
    });

    group('Theme Setting', () {
      testWidgets('should set light theme', (WidgetTester tester) async {
        // act
        await themeService.setLightTheme();

        // assert
        expect(themeService.themeMode, ThemeMode.light);
        expect(themeService.isLightMode, isTrue);
        expect(themeService.isDarkMode, isFalse);
      });

      testWidgets('should set dark theme', (WidgetTester tester) async {
        // arrange
        await themeService.setLightTheme();

        // act
        await themeService.setDarkTheme();

        // assert
        expect(themeService.themeMode, ThemeMode.dark);
        expect(themeService.isDarkMode, isTrue);
        expect(themeService.isLightMode, isFalse);
      });

      testWidgets('should set system theme', (WidgetTester tester) async {
        // act
        await themeService.setSystemTheme();

        // assert
        expect(themeService.themeMode, ThemeMode.system);
      });

      testWidgets('should not notify listeners when theme is already set', (WidgetTester tester) async {
        // arrange
        var notifyCount = 0;
        themeService.addListener(() => notifyCount++);

        // act - set dark theme when already dark
        await themeService.setDarkTheme();

        // assert - should not notify since theme didn't change
        expect(notifyCount, 0);
      });
    });

    group('Toggle Theme', () {
      testWidgets('should toggle through all themes', (WidgetTester tester) async {
        // arrange - start with dark (default)
        expect(themeService.themeMode, ThemeMode.dark);

        // act & assert - toggle to system
        await themeService.toggleTheme();
        expect(themeService.themeMode, ThemeMode.system);

        // act & assert - toggle to light
        await themeService.toggleTheme();
        expect(themeService.themeMode, ThemeMode.light);

        // act & assert - toggle back to dark
        await themeService.toggleTheme();
        expect(themeService.themeMode, ThemeMode.dark);
      });
    });

    group('Theme Information', () {
      testWidgets('should return correct theme name', (WidgetTester tester) async {
        // assert dark theme
        expect(themeService.getThemeName(), 'Dark');

        // act & assert light theme
        await themeService.setLightTheme();
        expect(themeService.getThemeName(), 'Light');

        // act & assert system theme
        await themeService.setSystemTheme();
        expect(themeService.getThemeName(), 'System');
      });

      testWidgets('should return correct theme description', (WidgetTester tester) async {
        // assert dark theme
        expect(
          themeService.getThemeDescription(),
          'Dark theme for technical monitoring',
        );

        // act & assert light theme
        await themeService.setLightTheme();
        expect(
          themeService.getThemeDescription(),
          'Light theme for daytime use',
        );

        // act & assert system theme
        await themeService.setSystemTheme();
        expect(
          themeService.getThemeDescription(),
          'Automatic switching based on system settings',
        );
      });

      testWidgets('should return correct theme icon', (WidgetTester tester) async {
        // assert dark theme
        expect(themeService.getThemeIcon(), Icons.nightlight_round);

        // act & assert light theme
        await themeService.setLightTheme();
        expect(themeService.getThemeIcon(), Icons.wb_sunny);

        // act & assert system theme
        await themeService.setSystemTheme();
        expect(themeService.getThemeIcon(), Icons.settings_system_daydream);
      });

      testWidgets('should return list of available themes', (WidgetTester tester) async {
        // act
        final themes = themeService.getAvailableThemes();

        // assert
        expect(themes.length, 3);
        expect(themes[0].mode, ThemeMode.light);
        expect(themes[0].name, 'Light');
        expect(themes[1].mode, ThemeMode.dark);
        expect(themes[1].name, 'Dark');
        expect(themes[2].mode, ThemeMode.system);
        expect(themes[2].name, 'System');
      });
    });

    group('Connection Status Colors', () {
      testWidgets('should return green for connected status', (WidgetTester tester) async {
        expect(
          themeService.getConnectionStatusColor('connected'),
          const Color(0xFF10B981),
        );
        expect(
          themeService.getConnectionStatusColor('online'),
          const Color(0xFF10B981),
        );
      });

      testWidgets('should return yellow for connecting status', (WidgetTester tester) async {
        expect(
          themeService.getConnectionStatusColor('connecting'),
          const Color(0xFFF59E0B),
        );
        expect(
          themeService.getConnectionStatusColor('connecting...'),
          const Color(0xFFF59E0B),
        );
      });

      testWidgets('should return red for disconnected status', (WidgetTester tester) async {
        expect(
          themeService.getConnectionStatusColor('disconnected'),
          const Color(0xFFEF4444),
        );
        expect(
          themeService.getConnectionStatusColor('offline'),
          const Color(0xFFEF4444),
        );
      });

      testWidgets('should return gray for unknown status', (WidgetTester tester) async {
        expect(
          themeService.getConnectionStatusColor('unknown'),
          const Color(0xFF6B7280),
        );
      });
    });

    group('Signal Level Colors', () {
      testWidgets('should return green for excellent signal', (WidgetTester tester) async {
        expect(themeService.getSignalLevelColor(100), const Color(0xFF10B981));
        expect(themeService.getSignalLevelColor(80), const Color(0xFF10B981));
      });

      testWidgets('should return light green for good signal', (WidgetTester tester) async {
        expect(themeService.getSignalLevelColor(75), const Color(0xFF34D399));
        expect(themeService.getSignalLevelColor(60), const Color(0xFF34D399));
      });

      testWidgets('should return yellow for fair signal', (WidgetTester tester) async {
        expect(themeService.getSignalLevelColor(50), const Color(0xFFF59E0B));
        expect(themeService.getSignalLevelColor(40), const Color(0xFFF59E0B));
      });

      testWidgets('should return orange for poor signal', (WidgetTester tester) async {
        expect(themeService.getSignalLevelColor(30), const Color(0xFFF97316));
        expect(themeService.getSignalLevelColor(20), const Color(0xFFF97316));
      });

      testWidgets('should return red for critical signal', (WidgetTester tester) async {
        expect(themeService.getSignalLevelColor(10), const Color(0xFFEF4444));
        expect(themeService.getSignalLevelColor(0), const Color(0xFFEF4444));
      });
    });

    group('Call Status Colors', () {
      testWidgets('should return green for active calls', (WidgetTester tester) async {
        expect(
          themeService.getCallStatusColor('active'),
          const Color(0xFF10B981),
        );
        expect(
          themeService.getCallStatusColor('incoming'),
          const Color(0xFF10B981),
        );
        expect(
          themeService.getCallStatusColor('outgoing'),
          const Color(0xFF10B981),
        );
      });

      testWidgets('should return red for ended calls', (WidgetTester tester) async {
        expect(
          themeService.getCallStatusColor('ended'),
          const Color(0xFFEF4444),
        );
        expect(
          themeService.getCallStatusColor('missed'),
          const Color(0xFFEF4444),
        );
      });

      testWidgets('should return yellow for idle/waiting calls', (WidgetTester tester) async {
        expect(
          themeService.getCallStatusColor('idle'),
          const Color(0xFFF59E0B),
        );
        expect(
          themeService.getCallStatusColor('waiting'),
          const Color(0xFFF59E0B),
        );
      });

      testWidgets('should return gray for unknown call status', (WidgetTester tester) async {
        expect(
          themeService.getCallStatusColor('unknown'),
          const Color(0xFF6B7280),
        );
      });
    });

    group('Theme Persistence', () {
      testWidgets('should persist theme selection', (WidgetTester tester) async {
        // act - set light theme
        await themeService.setLightTheme();

        // create new instance and initialize
        final service2 = ThemeService();
        await service2.initialize();

        // assert - theme should be persisted
        expect(service2.themeMode, ThemeMode.light);
        expect(service2.getThemeName(), 'Light');
      });

      testWidgets('should persist dark theme selection', (WidgetTester tester) async {
        // act - set system theme first, then dark
        await themeService.setSystemTheme();
        await themeService.setDarkTheme();

        // create new instance and initialize
        final service2 = ThemeService();
        await service2.initialize();

        // assert
        expect(service2.themeMode, ThemeMode.dark);
      });
    });
  });
}
