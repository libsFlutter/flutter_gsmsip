import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Сервис для управления темой приложения GOSTsimbox Gateway
/// Позволяет переключаться между светлой и темной темой
class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'gost_simbox_theme';
  
  ThemeMode _themeMode = ThemeMode.dark; // По умолчанию темная тема для технического приложения
  
  /// Текущий режим темы
  ThemeMode get themeMode => _themeMode;
  
  /// Является ли тема темной
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  /// Является ли тема светлой
  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }
  
  /// Инициализация сервиса
  Future<void> initialize() async {
    await _loadThemeMode();
  }
  
  /// Загрузка сохраненного режима темы
  Future<void> _loadThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final themeIndex = prefs.getInt(_themeKey) ?? 2; // По умолчанию темная тема (индекс 2)
      _themeMode = ThemeMode.values[themeIndex];
      notifyListeners();
    } catch (e) {
      // В случае ошибки используем темную тему по умолчанию
      _themeMode = ThemeMode.dark;
    }
  }
  
  /// Сохранение режима темы
  Future<void> _saveThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
    } catch (e) {
      // Игнорируем ошибки сохранения
    }
  }
  
  /// Установка светлой темы
  Future<void> setLightTheme() async {
    if (_themeMode != ThemeMode.light) {
      _themeMode = ThemeMode.light;
      await _saveThemeMode();
      notifyListeners();
    }
  }
  
  /// Установка темной темы
  Future<void> setDarkTheme() async {
    if (_themeMode != ThemeMode.dark) {
      _themeMode = ThemeMode.dark;
      await _saveThemeMode();
      notifyListeners();
    }
  }
  
  /// Установка системной темы
  Future<void> setSystemTheme() async {
    if (_themeMode != ThemeMode.system) {
      _themeMode = ThemeMode.system;
      await _saveThemeMode();
      notifyListeners();
    }
  }
  
  /// Переключение темы
  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.light) {
      await setDarkTheme();
    } else if (_themeMode == ThemeMode.dark) {
      await setSystemTheme();
    } else {
      await setLightTheme();
    }
  }
  
  /// Получить название текущей темы
  String getThemeName() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }
  
  /// Получить описание текущей темы
  String getThemeDescription() {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light theme for daytime use';
      case ThemeMode.dark:
        return 'Dark theme for technical monitoring';
      case ThemeMode.system:
        return 'Automatic switching based on system settings';
    }
  }
  
  /// Получить иконку текущей темы
  IconData getThemeIcon() {
    switch (_themeMode) {
      case ThemeMode.light:
        return Icons.wb_sunny;
      case ThemeMode.dark:
        return Icons.nightlight_round;
      case ThemeMode.system:
        return Icons.settings_system_daydream;
    }
  }
  
  /// Получить список доступных тем
  List<ThemeOption> getAvailableThemes() {
    return [
      ThemeOption(
        mode: ThemeMode.light,
        name: 'Light',
        description: 'Light theme for daytime use',
        icon: Icons.wb_sunny,
      ),
      ThemeOption(
        mode: ThemeMode.dark,
        name: 'Dark',
        description: 'Dark theme for technical monitoring',
        icon: Icons.nightlight_round,
      ),
      ThemeOption(
        mode: ThemeMode.system,
        name: 'System',
        description: 'Automatic switching based on system settings',
        icon: Icons.settings_system_daydream,
      ),
    ];
  }

  /// Получить цвет статуса подключения
  Color getConnectionStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
      case 'online':
        return const Color(0xFF10B981); // Зеленый
      case 'connecting':
      case 'connecting...':
        return const Color(0xFFF59E0B); // Желтый
      case 'disconnected':
      case 'offline':
        return const Color(0xFFEF4444); // Красный
      default:
        return const Color(0xFF6B7280); // Серый
    }
  }

  /// Получить цвет уровня сигнала
  Color getSignalLevelColor(int level) {
    if (level >= 80) {
      return const Color(0xFF10B981); // Отличный сигнал
    } else if (level >= 60) {
      return const Color(0xFF34D399); // Хороший сигнал
    } else if (level >= 40) {
      return const Color(0xFFF59E0B); // Средний сигнал
    } else if (level >= 20) {
      return const Color(0xFFF97316); // Слабый сигнал
    } else {
      return const Color(0xFFEF4444); // Очень слабый сигнал
    }
  }

  /// Получить цвет статуса вызова
  Color getCallStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'incoming':
      case 'outgoing':
        return const Color(0xFF10B981); // Зеленый
      case 'ended':
      case 'missed':
        return const Color(0xFFEF4444); // Красный
      case 'idle':
      case 'waiting':
        return const Color(0xFFF59E0B); // Желтый
      default:
        return const Color(0xFF6B7280); // Серый
    }
  }
}

/// Опция темы для выбора
class ThemeOption {
  final ThemeMode mode;
  final String name;
  final String description;
  final IconData icon;
  
  const ThemeOption({
    required this.mode,
    required this.name,
    required this.description,
    required this.icon,
  });
} 