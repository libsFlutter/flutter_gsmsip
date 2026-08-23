import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления локализацией приложения GOSTsimbox Gateway
/// Позволяет переключаться между различными языками
class LocalizationService extends ChangeNotifier {
  static const String _localeKey = 'gost_simbox_locale';
  
  Locale _currentLocale = const Locale('en'); // По умолчанию английский
  
  /// Текущая локаль
  Locale get currentLocale => _currentLocale;
  
  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadLocale();
  }
  
  /// Загрузка сохраненной локали
  Future<void> _loadLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'en';
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // В случае ошибки используем английский
      _currentLocale = const Locale('en');
    }
  }
  
  /// Сохранение локали
  Future<void> _saveLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, _currentLocale.languageCode);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }
  
  /// Установка локали
  Future<void> setLocale(Locale locale) async {
    if (_currentLocale != locale) {
      _currentLocale = locale;
      await _saveLocale();
      notifyListeners();
    }
  }
  
  /// Получить название текущего языка
  String getLanguageName() {
    switch (_currentLocale.languageCode) {
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
        return 'English';
    }
  }
  
  /// Получить описание текущего языка
  String getLanguageDescription() {
    switch (_currentLocale.languageCode) {
      case 'en':
        return 'English language';
      case 'ru':
        return 'Русский язык';
      case 'es':
        return 'Idioma español';
      case 'fr':
        return 'Langue française';
      case 'de':
        return 'Deutsche Sprache';
      case 'zh':
        return '中文语言';
      case 'ja':
        return '日本語';
      case 'ko':
        return '한국어';
      case 'ar':
        return 'اللغة العربية';
      case 'pt':
        return 'Língua portuguesa';
      case 'it':
        return 'Lingua italiana';
      case 'th':
        return 'ภาษาไทย';
      case 'tg':
        return 'Забони тоҷикӣ';
      case 'az':
        return 'Azərbaycan dili';
      case 'km':
        return 'ភាសាខ្មែរ';
      case 'lo':
        return 'ພາສາລາວ';
      case 'my':
        return 'မြန်မာဘာသာ';
      case 'ms':
        return 'Bahasa Melayu';
      case 'sw':
        return 'Lugha ya Kiswahili';
      case 'zu':
        return 'Ulimi lwesiZulu';
      case 'af':
        return 'Afrikaanse taal';
      case 'yo':
        return 'Èdè Yorùbá';
      case 'ig':
        return 'Asụsụ Igbo';
      case 'ha':
        return 'Harshen Hausa';
      default:
        return 'English language';
    }
  }
  
  /// Получить флаг текущего языка
  String getLanguageFlag() {
    switch (_currentLocale.languageCode) {
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
        return '🇺🇸';
    }
  }
  
  /// Получить список доступных языков
  List<LanguageOption> getAvailableLanguages() {
    return [
      LanguageOption(
        locale: const Locale('en'),
        name: 'English',
        description: 'English language',
        flag: '🇺🇸',
      ),
      LanguageOption(
        locale: const Locale('ru'),
        name: 'Русский',
        description: 'Русский язык',
        flag: '🇷🇺',
      ),
      LanguageOption(
        locale: const Locale('es'),
        name: 'Español',
        description: 'Idioma español',
        flag: '🇪🇸',
      ),
      LanguageOption(
        locale: const Locale('fr'),
        name: 'Français',
        description: 'Langue française',
        flag: '🇫🇷',
      ),
      LanguageOption(
        locale: const Locale('de'),
        name: 'Deutsch',
        description: 'Deutsche Sprache',
        flag: '🇩🇪',
      ),
      LanguageOption(
        locale: const Locale('zh'),
        name: '中文',
        description: '中文语言',
        flag: '🇨🇳',
      ),
      LanguageOption(
        locale: const Locale('ja'),
        name: '日本語',
        description: '日本語',
        flag: '🇯🇵',
      ),
      LanguageOption(
        locale: const Locale('ko'),
        name: '한국어',
        description: '한국어',
        flag: '🇰🇷',
      ),
      LanguageOption(
        locale: const Locale('ar'),
        name: 'العربية',
        description: 'اللغة العربية',
        flag: '🇸🇦',
      ),
      LanguageOption(
        locale: const Locale('pt'),
        name: 'Português',
        description: 'Língua portuguesa',
        flag: '🇵🇹',
      ),
      LanguageOption(
        locale: const Locale('it'),
        name: 'Italiano',
        description: 'Lingua italiana',
        flag: '🇮🇹',
      ),
      LanguageOption(
        locale: const Locale('th'),
        name: 'ไทย',
        description: 'ภาษาไทย',
        flag: '🇹🇭',
      ),
      LanguageOption(
        locale: const Locale('tg'),
        name: 'Тоҷикӣ',
        description: 'Забони тоҷикӣ',
        flag: '🇹🇯',
      ),
      LanguageOption(
        locale: const Locale('az'),
        name: 'Azərbaycan',
        description: 'Azərbaycan dili',
        flag: '🇦🇿',
      ),
      LanguageOption(
        locale: const Locale('km'),
        name: 'ខ្មែរ',
        description: 'ភាសាខ្មែរ',
        flag: '🇰🇭',
      ),
      LanguageOption(
        locale: const Locale('lo'),
        name: 'ລາວ',
        description: 'ພາສາລາວ',
        flag: '🇱🇦',
      ),
      LanguageOption(
        locale: const Locale('my'),
        name: 'မြန်မာ',
        description: 'မြန်မာဘာသာ',
        flag: '🇲🇲',
      ),
      LanguageOption(
        locale: const Locale('ms'),
        name: 'Bahasa Melayu',
        description: 'Bahasa Melayu',
        flag: '🇲🇾',
      ),
      LanguageOption(
        locale: const Locale('sw'),
        name: 'Kiswahili',
        description: 'Lugha ya Kiswahili',
        flag: '🇹🇿',
      ),
      LanguageOption(
        locale: const Locale('zu'),
        name: 'isiZulu',
        description: 'Ulimi lwesiZulu',
        flag: '🇿🇦',
      ),
      LanguageOption(
        locale: const Locale('af'),
        name: 'Afrikaans',
        description: 'Afrikaanse taal',
        flag: '🇿🇦',
      ),
      LanguageOption(
        locale: const Locale('yo'),
        name: 'Yorùbá',
        description: 'Èdè Yorùbá',
        flag: '🇳🇬',
      ),
      LanguageOption(
        locale: const Locale('ig'),
        name: 'Igbo',
        description: 'Asụsụ Igbo',
        flag: '🇳🇬',
      ),
      LanguageOption(
        locale: const Locale('ha'),
        name: 'Hausa',
        description: 'Harshen Hausa',
        flag: '🇳🇬',
      ),
    ];
  }
}

/// Опция языка для выбора
class LanguageOption {
  final Locale locale;
  final String name;
  final String description;
  final String flag;
  
  const LanguageOption({
    required this.locale,
    required this.name,
    required this.description,
    required this.flag,
  });
} 