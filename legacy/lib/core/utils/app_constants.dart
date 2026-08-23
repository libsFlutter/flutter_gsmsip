import 'package:flutter/material.dart';

/// Константы приложения
class AppConstants {
  static const String appName = 'GOSTsimbox Gateway';
  static const String appVersion = '3.0.0';
  static const String initialRoute = '/';
  
  // Поддерживаемые локали
  static const List<Locale> supportedLocales = [
    Locale('en'),
    Locale('ru'),
    Locale('es'),
    Locale('fr'),
    Locale('de'),
    Locale('zh'),
    Locale('ja'),
    Locale('ko'),
    Locale('ar'),
    Locale('pt'),
    Locale('it'),
    Locale('th'),
    Locale('tg'),
    Locale('az'),
    Locale('km'),
    Locale('lo'),
    Locale('my'),
    Locale('ms'),
    Locale('sw'),
    Locale('zu'),
    Locale('af'),
    Locale('yo'),
    Locale('ig'),
    Locale('ha'),
  ];
  
  // API константы
  static const String baseApiUrl = 'https://api.gostsimbox.com';
  static const Duration apiTimeout = Duration(seconds: 30);
  static const int maxRetries = 3;
  
  // Настройки кэширования
  static const Duration cacheExpiration = Duration(hours: 1);
  static const int maxCacheSize = 100;
  
  // Настройки логирования
  static const String logFileName = 'gostsimbox_gateway.log';
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10 MB
  static const int maxLogFiles = 5;
  
  // Настройки UI
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration splashScreenDuration = Duration(seconds: 2);
  static const double defaultPadding = 16.0;
  static const double defaultBorderRadius = 8.0;
  
  // Настройки безопасности
  static const int passwordMinLength = 8;
  static const int sessionTimeoutMinutes = 30;
  
  // Настройки уведомлений
  static const String notificationChannelId = 'gostsimbox_gateway';
  static const String notificationChannelName = 'GOSTsimbox Gateway';
  static const String notificationChannelDescription = 'Notifications from GOSTsimbox Gateway';
  
  // Настройки темы
  static const String lightThemeKey = 'light_theme';
  static const String darkThemeKey = 'dark_theme';
  static const String systemThemeKey = 'system_theme';
  
  // Настройки локализации
  static const String defaultLanguage = 'en';
  static const String languageKey = 'selected_language';
  
  // Настройки хранилища
  static const String settingsKey = 'app_settings';
  static const String userPreferencesKey = 'user_preferences';
  static const String cacheKey = 'app_cache';
  
  // Настройки сетевого взаимодействия
  static const Duration connectionTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const int maxConcurrentRequests = 5;
  
  // Настройки мониторинга
  static const Duration healthCheckInterval = Duration(minutes: 5);
  static const Duration performanceMonitorInterval = Duration(seconds: 30);
  
  // Настройки отладки
  static const bool enableDebugMode = true;
  static const bool enablePerformanceLogging = false;
  static const bool enableNetworkLogging = true;
}
