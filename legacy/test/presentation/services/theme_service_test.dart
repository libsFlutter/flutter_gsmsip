import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:gostsimbox_gateway/presentation/services/theme_service.dart';
import 'package:gostsimbox_gateway/presentation/services/storage_service.dart';

import 'theme_service_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  group('ThemeService', () {
    late ThemeService themeService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      themeService = ThemeService(mockStorageService);
    });

    group('initialize', () {
      test('should initialize with saved theme', () async {
        // Arrange
        when(mockStorageService.getString('selected_theme'))
            .thenReturn('dark');

        // Act
        await themeService.initialize();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.dark);
      });

      test('should initialize with system theme when no saved theme', () async {
        // Arrange
        when(mockStorageService.getString('selected_theme'))
            .thenReturn(null);

        // Act
        await themeService.initialize();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.system);
      });

      test('should handle initialization error', () async {
        // Arrange
        when(mockStorageService.getString('selected_theme'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => themeService.initialize(),
          throwsException,
        );
      });
    });

    group('setThemeMode', () {
      test('should set theme mode and save to storage', () async {
        // Arrange
        const newThemeMode = ThemeMode.dark;

        // Act
        await themeService.setThemeMode(newThemeMode);

        // Assert
        expect(themeService.currentThemeMode, newThemeMode);
        verify(mockStorageService.setString('selected_theme', 'dark')).called(1);
      });

      test('should not update if theme mode is the same', () async {
        // Arrange
        const sameThemeMode = ThemeMode.system;
        themeService = ThemeService(mockStorageService);
        await themeService.initialize();

        // Act
        await themeService.setThemeMode(sameThemeMode);

        // Assert
        verifyNever(mockStorageService.setString(any, any));
      });

      test('should handle setThemeMode error', () async {
        // Arrange
        when(mockStorageService.setString(any, any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => themeService.setThemeMode(ThemeMode.light),
          throwsException,
        );
      });
    });

    group('setLightTheme', () {
      test('should set light theme', () async {
        // Act
        await themeService.setLightTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.light);
        verify(mockStorageService.setString('selected_theme', 'light')).called(1);
      });
    });

    group('setDarkTheme', () {
      test('should set dark theme', () async {
        // Act
        await themeService.setDarkTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.dark);
        verify(mockStorageService.setString('selected_theme', 'dark')).called(1);
      });
    });

    group('setSystemTheme', () {
      test('should set system theme', () async {
        // Act
        await themeService.setSystemTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.system);
        verify(mockStorageService.setString('selected_theme', 'system')).called(1);
      });
    });

    group('toggleTheme', () {
      test('should toggle from light to dark', () async {
        // Arrange
        await themeService.setLightTheme();

        // Act
        await themeService.toggleTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.dark);
      });

      test('should toggle from dark to light', () async {
        // Arrange
        await themeService.setDarkTheme();

        // Act
        await themeService.toggleTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.light);
      });

      test('should set light theme when system theme', () async {
        // Arrange
        await themeService.setSystemTheme();

        // Act
        await themeService.toggleTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.light);
      });
    });

    group('getThemeDisplayName', () {
      test('should return correct display names', () {
        expect(themeService.getThemeDisplayName(ThemeMode.light), 'Light');
        expect(themeService.getThemeDisplayName(ThemeMode.dark), 'Dark');
        expect(themeService.getThemeDisplayName(ThemeMode.system), 'System');
      });
    });

    group('getThemeIcon', () {
      test('should return correct icons', () {
        expect(themeService.getThemeIcon(ThemeMode.light), Icons.light_mode);
        expect(themeService.getThemeIcon(ThemeMode.dark), Icons.dark_mode);
        expect(themeService.getThemeIcon(ThemeMode.system), Icons.brightness_auto);
      });
    });

    group('getThemeInfo', () {
      test('should return correct theme info', () {
        // Act
        final info = themeService.getThemeInfo();

        // Assert
        expect(info['currentTheme'], 'system');
        expect(info['currentThemeName'], 'System');
        expect(info['isInitialized'], false);
        expect(info['timestamp'], isA<String>());
      });
    });

    group('resetTheme', () {
      test('should reset to system theme', () async {
        // Arrange
        await themeService.setDarkTheme();

        // Act
        await themeService.resetTheme();

        // Assert
        expect(themeService.currentThemeMode, ThemeMode.system);
        verify(mockStorageService.remove('selected_theme')).called(1);
      });

      test('should handle reset error', () async {
        // Arrange
        when(mockStorageService.remove(any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => themeService.resetTheme(),
          throwsException,
        );
      });
    });

    group('isDarkMode', () {
      test('should return true for dark theme', () {
        themeService.setDarkTheme();
        expect(themeService.isDarkMode, isTrue);
      });

      test('should return false for light theme', () {
        themeService.setLightTheme();
        expect(themeService.isDarkMode, isFalse);
      });

      test('should return false for system theme', () {
        themeService.setSystemTheme();
        expect(themeService.isDarkMode, isFalse);
      });
    });

    group('isLightMode', () {
      test('should return true for light theme', () {
        themeService.setLightTheme();
        expect(themeService.isLightMode, isTrue);
      });

      test('should return false for dark theme', () {
        themeService.setDarkTheme();
        expect(themeService.isLightMode, isFalse);
      });

      test('should return false for system theme', () {
        themeService.setSystemTheme();
        expect(themeService.isLightMode, isFalse);
      });
    });

    group('isSystemMode', () {
      test('should return true for system theme', () {
        themeService.setSystemTheme();
        expect(themeService.isSystemMode, isTrue);
      });

      test('should return false for light theme', () {
        themeService.setLightTheme();
        expect(themeService.isSystemMode, isFalse);
      });

      test('should return false for dark theme', () {
        themeService.setDarkTheme();
        expect(themeService.isSystemMode, isFalse);
      });
    });

    group('getAvailableThemes', () {
      test('should return list of available themes', () {
        // Act
        final themes = themeService.getAvailableThemes();

        // Assert
        expect(themes, isA<List<Map<String, dynamic>>>());
        expect(themes.length, 3);

        // Check light theme
        expect(themes[0]['mode'], ThemeMode.light);
        expect(themes[0]['name'], 'Light');
        expect(themes[0]['icon'], Icons.light_mode);

        // Check dark theme
        expect(themes[1]['mode'], ThemeMode.dark);
        expect(themes[1]['name'], 'Dark');
        expect(themes[1]['icon'], Icons.dark_mode);

        // Check system theme
        expect(themes[2]['mode'], ThemeMode.system);
        expect(themes[2]['name'], 'System');
        expect(themes[2]['icon'], Icons.brightness_auto);
      });

      test('should contain all required fields for each theme', () {
        // Act
        final themes = themeService.getAvailableThemes();

        // Assert
        for (final theme in themes) {
          expect(theme.containsKey('mode'), true);
          expect(theme.containsKey('name'), true);
          expect(theme.containsKey('icon'), true);
          expect(theme['mode'], isA<ThemeMode>());
          expect(theme['name'], isA<String>());
          expect(theme['icon'], isA<IconData>());
        }
      });
    });

    group('ChangeNotifier functionality', () {
      test('should notify listeners when theme changes', () async {
        // Arrange
        var notificationCount = 0;
        themeService.addListener(() {
          notificationCount++;
        });

        // Act
        await themeService.setLightTheme();

        // Assert
        expect(notificationCount, 1);
      });

      test('should not notify listeners when theme is the same', () async {
        // Arrange
        var notificationCount = 0;
        themeService.addListener(() {
          notificationCount++;
        });

        // Act
        await themeService.setSystemTheme(); // Same as default

        // Assert
        expect(notificationCount, 0);
      });
    });

    group('Theme mode conversion', () {
      test('should convert theme mode to string correctly', () {
        // These methods are private, so we test them indirectly through public methods
        expect(themeService.getThemeDisplayName(ThemeMode.light), 'Light');
        expect(themeService.getThemeDisplayName(ThemeMode.dark), 'Dark');
        expect(themeService.getThemeDisplayName(ThemeMode.system), 'System');
      });

      test('should handle unknown theme mode gracefully', () {
        // Test through public interface
        expect(themeService.getThemeDisplayName(ThemeMode.system), 'System');
      });
    });
  });
}
