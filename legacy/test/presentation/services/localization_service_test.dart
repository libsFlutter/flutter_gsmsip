import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:gostsimbox_gateway/presentation/services/localization_service.dart';
import 'package:gostsimbox_gateway/presentation/services/storage_service.dart';

import 'localization_service_test.mocks.dart';

@GenerateMocks([StorageService])
void main() {
  group('LocalizationService', () {
    late LocalizationService localizationService;
    late MockStorageService mockStorageService;

    setUp(() {
      mockStorageService = MockStorageService();
      localizationService = LocalizationService(mockStorageService);
    });

    group('initialize', () {
      test('should initialize with saved language', () async {
        // Arrange
        when(mockStorageService.getString('selected_language'))
            .thenReturn('ru');

        // Act
        await localizationService.initialize();

        // Assert
        expect(localizationService.currentLocale, const Locale('ru'));
        expect(localizationService.currentLanguageCode, 'ru');
      });

      test('should initialize with default language when no saved language', () async {
        // Arrange
        when(mockStorageService.getString('selected_language'))
            .thenReturn(null);

        // Act
        await localizationService.initialize();

        // Assert
        expect(localizationService.currentLocale, const Locale('en'));
        expect(localizationService.currentLanguageCode, 'en');
      });

      test('should handle initialization error', () async {
        // Arrange
        when(mockStorageService.getString('selected_language'))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => localizationService.initialize(),
          throwsException,
        );
      });
    });

    group('setLocale', () {
      test('should set locale and save to storage', () async {
        // Arrange
        const newLocale = Locale('es');

        // Act
        await localizationService.setLocale(newLocale);

        // Assert
        expect(localizationService.currentLocale, newLocale);
        verify(mockStorageService.setString('selected_language', 'es')).called(1);
      });

      test('should not update if locale is the same', () async {
        // Arrange
        const sameLocale = Locale('en');
        localizationService = LocalizationService(mockStorageService);
        await localizationService.initialize();

        // Act
        await localizationService.setLocale(sameLocale);

        // Assert
        verifyNever(mockStorageService.setString(any, any));
      });

      test('should handle setLocale error', () async {
        // Arrange
        when(mockStorageService.setString(any, any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => localizationService.setLocale(const Locale('fr')),
          throwsException,
        );
      });
    });

    group('setLanguage', () {
      test('should set language by code', () async {
        // Act
        await localizationService.setLanguage('de');

        // Assert
        expect(localizationService.currentLanguageCode, 'de');
        verify(mockStorageService.setString('selected_language', 'de')).called(1);
      });
    });

    group('getLanguageDisplayName', () {
      test('should return correct display names for supported languages', () {
        expect(localizationService.getLanguageDisplayName('en'), 'English');
        expect(localizationService.getLanguageDisplayName('ru'), 'Русский');
        expect(localizationService.getLanguageDisplayName('es'), 'Español');
        expect(localizationService.getLanguageDisplayName('fr'), 'Français');
        expect(localizationService.getLanguageDisplayName('de'), 'Deutsch');
        expect(localizationService.getLanguageDisplayName('zh'), '中文');
        expect(localizationService.getLanguageDisplayName('ja'), '日本語');
        expect(localizationService.getLanguageDisplayName('ko'), '한국어');
        expect(localizationService.getLanguageDisplayName('ar'), 'العربية');
        expect(localizationService.getLanguageDisplayName('pt'), 'Português');
        expect(localizationService.getLanguageDisplayName('it'), 'Italiano');
        expect(localizationService.getLanguageDisplayName('th'), 'ไทย');
        expect(localizationService.getLanguageDisplayName('tg'), 'Тоҷикӣ');
        expect(localizationService.getLanguageDisplayName('az'), 'Azərbaycan');
        expect(localizationService.getLanguageDisplayName('km'), 'ខ្មែរ');
        expect(localizationService.getLanguageDisplayName('lo'), 'ລາວ');
        expect(localizationService.getLanguageDisplayName('my'), 'မြန်မာ');
        expect(localizationService.getLanguageDisplayName('ms'), 'Bahasa Melayu');
        expect(localizationService.getLanguageDisplayName('sw'), 'Kiswahili');
        expect(localizationService.getLanguageDisplayName('zu'), 'isiZulu');
        expect(localizationService.getLanguageDisplayName('af'), 'Afrikaans');
        expect(localizationService.getLanguageDisplayName('yo'), 'Yorùbá');
        expect(localizationService.getLanguageDisplayName('ig'), 'Igbo');
        expect(localizationService.getLanguageDisplayName('ha'), 'Hausa');
      });

      test('should return uppercase code for unknown language', () {
        expect(localizationService.getLanguageDisplayName('unknown'), 'UNKNOWN');
      });
    });

    group('getLanguageFlag', () {
      test('should return correct flags for supported languages', () {
        expect(localizationService.getLanguageFlag('en'), '🇺🇸');
        expect(localizationService.getLanguageFlag('ru'), '🇷🇺');
        expect(localizationService.getLanguageFlag('es'), '🇪🇸');
        expect(localizationService.getLanguageFlag('fr'), '🇫🇷');
        expect(localizationService.getLanguageFlag('de'), '🇩🇪');
        expect(localizationService.getLanguageFlag('zh'), '🇨🇳');
        expect(localizationService.getLanguageFlag('ja'), '🇯🇵');
        expect(localizationService.getLanguageFlag('ko'), '🇰🇷');
        expect(localizationService.getLanguageFlag('ar'), '🇸🇦');
        expect(localizationService.getLanguageFlag('pt'), '🇵🇹');
        expect(localizationService.getLanguageFlag('it'), '🇮🇹');
        expect(localizationService.getLanguageFlag('th'), '🇹🇭');
        expect(localizationService.getLanguageFlag('tg'), '🇹🇯');
        expect(localizationService.getLanguageFlag('az'), '🇦🇿');
        expect(localizationService.getLanguageFlag('km'), '🇰🇭');
        expect(localizationService.getLanguageFlag('lo'), '🇱🇦');
        expect(localizationService.getLanguageFlag('my'), '🇲🇲');
        expect(localizationService.getLanguageFlag('ms'), '🇲🇾');
        expect(localizationService.getLanguageFlag('sw'), '🇹🇿');
        expect(localizationService.getLanguageFlag('zu'), '🇿🇦');
        expect(localizationService.getLanguageFlag('af'), '🇿🇦');
        expect(localizationService.getLanguageFlag('yo'), '🇳🇬');
        expect(localizationService.getLanguageFlag('ig'), '🇳🇬');
        expect(localizationService.getLanguageFlag('ha'), '🇳🇬');
      });

      test('should return world flag for unknown language', () {
        expect(localizationService.getLanguageFlag('unknown'), '🌐');
      });
    });

    group('getLocalizationInfo', () {
      test('should return correct localization info', () {
        // Act
        final info = localizationService.getLocalizationInfo();

        // Assert
        expect(info['currentLanguage'], 'en');
        expect(info['currentLanguageName'], 'English');
        expect(info['currentLanguageFlag'], '🇺🇸');
        expect(info['isInitialized'], false);
        expect(info['timestamp'], isA<String>());
      });
    });

    group('resetLocalization', () {
      test('should reset to default language', () async {
        // Arrange
        await localizationService.setLanguage('ru');

        // Act
        await localizationService.resetLocalization();

        // Assert
        expect(localizationService.currentLanguageCode, 'en');
        verify(mockStorageService.remove('selected_language')).called(1);
      });

      test('should handle reset error', () async {
        // Arrange
        when(mockStorageService.remove(any))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => localizationService.resetLocalization(),
          throwsException,
        );
      });
    });

    group('isRtlLanguage', () {
      test('should return true for RTL languages', () {
        expect(localizationService.isRtlLanguage('ar'), true);
        expect(localizationService.isRtlLanguage('he'), true);
        expect(localizationService.isRtlLanguage('fa'), true);
        expect(localizationService.isRtlLanguage('ur'), true);
      });

      test('should return false for LTR languages', () {
        expect(localizationService.isRtlLanguage('en'), false);
        expect(localizationService.isRtlLanguage('ru'), false);
        expect(localizationService.isRtlLanguage('es'), false);
        expect(localizationService.isRtlLanguage('fr'), false);
      });
    });

    group('currentTextDirection', () {
      test('should return RTL for RTL language', () {
        localizationService.setLanguage('ar');
        expect(localizationService.currentTextDirection, TextDirection.rtl);
      });

      test('should return LTR for LTR language', () {
        localizationService.setLanguage('en');
        expect(localizationService.currentTextDirection, TextDirection.ltr);
      });
    });

    group('getSupportedLanguages', () {
      test('should return list of supported languages', () {
        // Act
        final languages = localizationService.getSupportedLanguages();

        // Assert
        expect(languages, isA<List<Map<String, String>>>());
        expect(languages.length, 25);

        // Check first language
        expect(languages.first['code'], 'en');
        expect(languages.first['name'], 'English');
        expect(languages.first['flag'], '🇺🇸');

        // Check last language
        expect(languages.last['code'], 'ha');
        expect(languages.last['name'], 'Hausa');
        expect(languages.last['flag'], '🇳🇬');
      });

      test('should contain all required fields for each language', () {
        // Act
        final languages = localizationService.getSupportedLanguages();

        // Assert
        for (final language in languages) {
          expect(language.containsKey('code'), true);
          expect(language.containsKey('name'), true);
          expect(language.containsKey('flag'), true);
          expect(language['code'], isA<String>());
          expect(language['name'], isA<String>());
          expect(language['flag'], isA<String>());
        }
      });
    });

    group('ChangeNotifier functionality', () {
      test('should notify listeners when locale changes', () async {
        // Arrange
        var notificationCount = 0;
        localizationService.addListener(() {
          notificationCount++;
        });

        // Act
        await localizationService.setLanguage('fr');

        // Assert
        expect(notificationCount, 1);
      });

      test('should not notify listeners when locale is the same', () async {
        // Arrange
        var notificationCount = 0;
        localizationService.addListener(() {
          notificationCount++;
        });

        // Act
        await localizationService.setLanguage('en'); // Same as default

        // Assert
        expect(notificationCount, 0);
      });
    });
  });
}
