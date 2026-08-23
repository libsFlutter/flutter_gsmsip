import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с локализацией приложения
class LocalizationService extends ChangeNotifier {
  final StorageService _storageService;
  final Logger _logger;
  
  static const String _languageKey = 'selected_language';
  static const String _defaultLanguage = 'en';
  
  Locale _currentLocale = const Locale('en');
  bool _isInitialized = false;

  LocalizationService(this._storageService) : _logger = Logger();

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.i('Initializing localization service...');
      
      // Загружаем сохраненный язык
      final savedLanguage = _storageService.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLocale = Locale(savedLanguage);
        _logger.d('Loaded saved language: $savedLanguage');
      } else {
        _currentLocale = const Locale(_defaultLanguage);
        _logger.d('Using default language: $_defaultLanguage');
      }
      
      _isInitialized = true;
      _logger.i('Localization service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize localization service', error: e);
      rethrow;
    }
  }

  /// Получение текущей локали
  Locale get currentLocale => _currentLocale;

  /// Установка локали
  Future<void> setLocale(Locale locale) async {
    try {
      _logger.d('Setting locale: ${locale.languageCode}');
      
      if (_currentLocale != locale) {
        _currentLocale = locale;
        
        // Сохраняем в хранилище
        await _storageService.setString(_languageKey, locale.languageCode);
        
        // Уведомляем слушателей
        notifyListeners();
        
        _logger.d('Locale set successfully: ${locale.languageCode}');
      }
    } catch (e) {
      _logger.e('Failed to set locale', error: e);
      rethrow;
    }
  }

  /// Установка языка по коду
  Future<void> setLanguage(String languageCode) async {
    await setLocale(Locale(languageCode));
  }

  /// Получение кода текущего языка
  String get currentLanguageCode => _currentLocale.languageCode;

  /// Получение названия языка для отображения
  String getLanguageDisplayName(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English';
      case 'ru':
        return 'Русский';
      case 'es':
        return 'Español';
      case 'fr':
        return 'Français';
      case 'de':
        return 'Deutsch';
      case 'zh':
        return '中文';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'العربية';
      case 'pt':
        return 'Português';
      case 'it':
        return 'Italiano';
      case 'th':
        return 'ไทย';
      case 'tg':
        return 'Тоҷикӣ';
      case 'az':
        return 'Azərbaycan';
      case 'km':
        return 'ខ្មែរ';
      case 'lo':
        return 'ລາວ';
      case 'my':
        return 'မြန်မာ';
      case 'ms':
        return 'Bahasa Melayu';
      case 'sw':
        return 'Kiswahili';
      case 'zu':
        return 'isiZulu';
      case 'af':
        return 'Afrikaans';
      case 'yo':
        return 'Yorùbá';
      case 'ig':
        return 'Igbo';
      case 'ha':
        return 'Hausa';
      default:
        return languageCode.toUpperCase();
    }
  }

  /// Получение флага языка (эмодзи)
  String getLanguageFlag(String languageCode) {
    switch (languageCode) {
      case 'en':
        return '🇺🇸';
      case 'ru':
        return '🇷🇺';
      case 'es':
        return '🇪🇸';
      case 'fr':
        return '🇫🇷';
      case 'de':
        return '🇩🇪';
      case 'zh':
        return '🇨🇳';
      case 'ja':
        return '🇯🇵';
      case 'ko':
        return '🇰🇷';
      case 'ar':
        return '🇸🇦';
      case 'pt':
        return '🇵🇹';
      case 'it':
        return '🇮🇹';
      case 'th':
        return '🇹🇭';
      case 'tg':
        return '🇹🇯';
      case 'az':
        return '🇦🇿';
      case 'km':
        return '🇰🇭';
      case 'lo':
        return '🇱🇦';
      case 'my':
        return '🇲🇲';
      case 'ms':
        return '🇲🇾';
      case 'sw':
        return '🇹🇿';
      case 'zu':
        return '🇿🇦';
      case 'af':
        return '🇿🇦';
      case 'yo':
        return '🇳🇬';
      case 'ig':
        return '🇳🇬';
      case 'ha':
        return '🇳🇬';
      default:
        return '🌐';
    }
  }

  /// Получение информации о локализации
  Map<String, dynamic> getLocalizationInfo() {
    return {
      'currentLanguage': currentLanguageCode,
      'currentLanguageName': getLanguageDisplayName(currentLanguageCode),
      'currentLanguageFlag': getLanguageFlag(currentLanguageCode),
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Сброс настроек локализации
  Future<void> resetLocalization() async {
    try {
      _logger.d('Resetting localization settings...');
      
      await _storageService.remove(_languageKey);
      
      _currentLocale = const Locale(_defaultLanguage);
      notifyListeners();
      
      _logger.d('Localization settings reset successfully');
    } catch (e) {
      _logger.e('Failed to reset localization settings', error: e);
      rethrow;
    }
  }

  /// Проверка, является ли язык RTL (справа налево)
  bool isRtlLanguage(String languageCode) {
    return ['ar', 'he', 'fa', 'ur'].contains(languageCode);
  }

  /// Проверка, является ли текущий язык RTL
  bool get isCurrentLanguageRtl => isRtlLanguage(currentLanguageCode);

  /// Получение направления текста для текущего языка
  TextDirection get currentTextDirection {
    return isCurrentLanguageRtl ? TextDirection.rtl : TextDirection.ltr;
  }

  /// Получение списка поддерживаемых языков
  List<Map<String, String>> getSupportedLanguages() {
    return [
      {'code': 'en', 'name': 'English', 'flag': '🇺🇸'},
      {'code': 'ru', 'name': 'Русский', 'flag': '🇷🇺'},
      {'code': 'es', 'name': 'Español', 'flag': '🇪🇸'},
      {'code': 'fr', 'name': 'Français', 'flag': '🇫🇷'},
      {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪'},
      {'code': 'zh', 'name': '中文', 'flag': '🇨🇳'},
      {'code': 'ja', 'name': '日本語', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': '한국어', 'flag': '🇰🇷'},
      {'code': 'ar', 'name': 'العربية', 'flag': '🇸🇦'},
      {'code': 'pt', 'name': 'Português', 'flag': '🇵🇹'},
      {'code': 'it', 'name': 'Italiano', 'flag': '🇮🇹'},
      {'code': 'th', 'name': 'ไทย', 'flag': '🇹🇭'},
      {'code': 'tg', 'name': 'Тоҷикӣ', 'flag': '🇹🇯'},
      {'code': 'az', 'name': 'Azərbaycan', 'flag': '🇦🇿'},
      {'code': 'km', 'name': 'ខ្មែរ', 'flag': '🇰🇭'},
      {'code': 'lo', 'name': 'ລາວ', 'flag': '🇱🇦'},
      {'code': 'my', 'name': 'မြန်မာ', 'flag': '🇲🇲'},
      {'code': 'ms', 'name': 'Bahasa Melayu', 'flag': '🇲🇾'},
      {'code': 'sw', 'name': 'Kiswahili', 'flag': '🇹🇿'},
      {'code': 'zu', 'name': 'isiZulu', 'flag': '🇿🇦'},
      {'code': 'af', 'name': 'Afrikaans', 'flag': '🇿🇦'},
      {'code': 'yo', 'name': 'Yorùbá', 'flag': '🇳🇬'},
      {'code': 'ig', 'name': 'Igbo', 'flag': '🇳🇬'},
      {'code': 'ha', 'name': 'Hausa', 'flag': '��🇬'},
    ];
  }
}
