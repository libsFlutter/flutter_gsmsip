import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с темой приложения
class ThemeService extends ChangeNotifier {
  final StorageService _storageService;
  final Logger _logger;
  
  static const String _themeKey = 'app_theme';
  static const String _themeModeKey = 'theme_mode';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isInitialized = false;

  ThemeService(this._storageService) : _logger = Logger();

  /// Инициализация сервиса
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      _logger.i('Initializing theme service...');
      
      // Загружаем сохраненную тему
      final savedThemeMode = _storageService.getString(_themeModeKey);
      if (savedThemeMode != null) {
        _themeMode = _parseThemeMode(savedThemeMode);
        _logger.d('Loaded saved theme mode: $_themeMode');
      }
      
      _isInitialized = true;
      _logger.i('Theme service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize theme service', error: e);
      rethrow;
    }
  }

  /// Получение текущего режима темы
  ThemeMode get themeMode => _themeMode;

  /// Установка режима темы
  Future<void> setThemeMode(ThemeMode mode) async {
    try {
      _logger.d('Setting theme mode: $mode');
      
      if (_themeMode != mode) {
        _themeMode = mode;
        
        // Сохраняем в хранилище
        final themeModeString = _themeModeToString(mode);
        await _storageService.setString(_themeModeKey, themeModeString);
        
        // Уведомляем слушателей
        notifyListeners();
        
        _logger.d('Theme mode set successfully: $mode');
      }
    } catch (e) {
      _logger.e('Failed to set theme mode', error: e);
      rethrow;
    }
  }

  /// Переключение на светлую тему
  Future<void> setLightTheme() async {
    await setThemeMode(ThemeMode.light);
  }

  /// Переключение на темную тему
  Future<void> setDarkTheme() async {
    await setThemeMode(ThemeMode.dark);
  }

  /// Переключение на системную тему
  Future<void> setSystemTheme() async {
    await setThemeMode(ThemeMode.system);
  }

  /// Переключение на следующую тему
  Future<void> toggleTheme() async {
    switch (_themeMode) {
      case ThemeMode.light:
        await setDarkTheme();
        break;
      case ThemeMode.dark:
        await setSystemTheme();
        break;
      case ThemeMode.system:
        await setLightTheme();
        break;
    }
  }

  /// Проверка, является ли тема темной
  bool get isDarkMode {
    switch (_themeMode) {
      case ThemeMode.light:
        return false;
      case ThemeMode.dark:
        return true;
      case ThemeMode.system:
        // Определяем системную тему через MediaQuery
        // Это будет работать только в контексте виджета
        return false; // По умолчанию светлая
    }
  }

  /// Получение информации о теме
  Map<String, dynamic> getThemeInfo() {
    return {
      'themeMode': _themeModeToString(_themeMode),
      'isDarkMode': isDarkMode,
      'isInitialized': _isInitialized,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Сброс настроек темы
  Future<void> resetTheme() async {
    try {
      _logger.d('Resetting theme settings...');
      
      await _storageService.remove(_themeModeKey);
      await _storageService.remove(_themeKey);
      
      _themeMode = ThemeMode.system;
      notifyListeners();
      
      _logger.d('Theme settings reset successfully');
    } catch (e) {
      _logger.e('Failed to reset theme settings', error: e);
      rethrow;
    }
  }

  /// Парсинг строки в ThemeMode
  ThemeMode _parseThemeMode(String themeModeString) {
    switch (themeModeString.toLowerCase()) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  /// Преобразование ThemeMode в строку
  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  /// Получение названия темы для отображения
  String getThemeDisplayName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  /// Получение иконки темы
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }
}
