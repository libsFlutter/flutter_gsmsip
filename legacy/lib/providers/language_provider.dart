import 'package:flutter/material.dart';
import '../services/storage_service.dart';

class LanguageProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  Locale _currentLocale = const Locale('en');

  Locale get currentLocale => _currentLocale;

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final language = await _storage.getLanguage();
      _currentLocale = Locale(language);
      notifyListeners();
    } catch (e) {
      // Default to English if loading fails
      _currentLocale = const Locale('en');
    }
  }

  Future<void> setLanguage(String languageCode) async {
    try {
      await _storage.setLanguage(languageCode);
      _currentLocale = Locale(languageCode);
      notifyListeners();
    } catch (e) {
      // Handle error
      debugPrint('Error setting language: $e');
    }
  }

  String getLanguageName(String languageCode) {
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

  List<Map<String, String>> get supportedLanguages => [
    {'code': 'en', 'name': 'English'},
    {'code': 'ru', 'name': 'Русский'},
    {'code': 'es', 'name': 'Español'},
    {'code': 'fr', 'name': 'Français'},
    {'code': 'de', 'name': 'Deutsch'},
    {'code': 'zh', 'name': '中文'},
    {'code': 'ja', 'name': '日本語'},
    {'code': 'ko', 'name': '한국어'},
    {'code': 'ar', 'name': 'العربية'},
    {'code': 'pt', 'name': 'Português'},
    {'code': 'it', 'name': 'Italiano'},
    {'code': 'th', 'name': 'ไทย'},
    {'code': 'tg', 'name': 'Тоҷикӣ'},
    {'code': 'az', 'name': 'Azərbaycan'},
    {'code': 'km', 'name': 'ខ្មែរ'},
    {'code': 'lo', 'name': 'ລາວ'},
    {'code': 'my', 'name': 'မြန်မာ'},
    {'code': 'ms', 'name': 'Bahasa Melayu'},
    {'code': 'sw', 'name': 'Kiswahili'},
    {'code': 'zu', 'name': 'isiZulu'},
    {'code': 'af', 'name': 'Afrikaans'},
    {'code': 'yo', 'name': 'Yorùbá'},
    {'code': 'ig', 'name': 'Igbo'},
    {'code': 'ha', 'name': 'Hausa'},
  ];
} 