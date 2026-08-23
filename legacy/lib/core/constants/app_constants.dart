/// Константы приложения GOSTsimbox Gateway
/// Централизованное хранение всех констант

class AppConstants {
  // Приватный конструктор
  AppConstants._();

  // Название приложения
  static const String appName = 'GOSTsimbox Gateway';
  static const String appVersion = '3.0.0';
  static const String appDescription = 'Bidirectional bridge between GSM telephony and SIP/SMPP protocol';

  // Ключи для SharedPreferences
  static const String configKey = 'gateway_config';
  static const String logsKey = 'gateway_logs';
  static const String languageKey = 'app_language';
  static const String themeModeKey = 'app_theme_mode';
  static const String isFirstRunKey = 'is_first_run';

  // Настройки по умолчанию
  static const String defaultLanguage = 'en';
  static const String defaultThemeMode = 'system';
  static const int defaultMaxLogEntries = 1000;
  static const String defaultLogLevel = 'INFO';

  // SIP настройки по умолчанию
  static const String defaultSipTransport = 'UDP';
  static const int defaultSipPort = 5060;
  static const int defaultRegistrationTimeout = 3600;
  static const bool defaultEnableKeepAlive = true;
  static const int defaultKeepAliveInterval = 30;

  // GSM настройки по умолчанию
  static const bool defaultEnableAutoAnswer = false;
  static const int defaultCallTimeout = 300;
  static const bool defaultEnableCallForwarding = false;
  static const bool defaultEnableCallRecording = false;
  static const String defaultRecordingPath = '/storage/recordings';

  // Номера экстренных служб
  static const List<String> defaultEmergencyNumbers = [
    '112', '911', '999', '110', '119', '120'
  ];

  // Лимиты
  static const int maxLogEntries = 1000;
  static const int maxCallHistory = 100;
  static const int maxSmsMessages = 1000;
  static const int maxRecentCalls = 50;

  // Таймауты
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration callTimeout = Duration(minutes: 5);
  static const Duration registrationTimeout = Duration(hours: 1);
  static const Duration keepAliveInterval = Duration(seconds: 30);

  // Размеры файлов
  static const int maxLogFileSize = 10 * 1024 * 1024; // 10MB
  static const int maxRecordingFileSize = 100 * 1024 * 1024; // 100MB

  // Валидация
  static const int minPhoneNumberLength = 7;
  static const int maxPhoneNumberLength = 15;
  static const int minSmsLength = 1;
  static const int maxSmsLength = 160;
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 50;

  // Регулярные выражения
  static const String phoneNumberRegex = r'^[\+]?[0-9\s\-\(\)]{7,15}$';
  static const String emailRegex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String ipAddressRegex = r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$';

  // Сообщения об ошибках
  static const String errorInvalidPhoneNumber = 'Invalid phone number format';
  static const String errorInvalidEmail = 'Invalid email format';
  static const String errorInvalidIpAddress = 'Invalid IP address format';
  static const String errorEmptyField = 'This field cannot be empty';
  static const String errorConnectionFailed = 'Connection failed';
  static const String errorPermissionDenied = 'Permission denied';
  static const String errorDeviceNotSupported = 'Device not supported';

  // Сообщения об успехе
  static const String successGatewayStarted = 'Gateway started successfully';
  static const String successGatewayStopped = 'Gateway stopped successfully';
  static const String successCallInitiated = 'Call initiated successfully';
  static const String successCallAnswered = 'Call answered successfully';
  static const String successCallEnded = 'Call ended successfully';
  static const String successSmsSent = 'SMS sent successfully';
  static const String successConfigSaved = 'Configuration saved successfully';

  // Статусы
  static const String statusConnecting = 'Connecting...';
  static const String statusConnected = 'Connected';
  static const String statusDisconnected = 'Disconnected';
  static const String statusRegistered = 'Registered';
  static const String statusUnregistered = 'Unregistered';
  static const String statusCalling = 'Calling...';
  static const String statusInCall = 'In call';
  static const String statusIdle = 'Idle';

  // Цвета статусов
  static const int colorSuccess = 0xFF10B981;
  static const int colorWarning = 0xFFF59E0B;
  static const int colorError = 0xFFEF4444;
  static const int colorInfo = 0xFF3B82F6;

  // Размеры UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double defaultBorderRadius = 12.0;
  static const double smallBorderRadius = 8.0;
  static const double largeBorderRadius = 16.0;

  // Анимации
  static const Duration shortAnimation = Duration(milliseconds: 200);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // Поддерживаемые языки
  static const List<Map<String, String>> supportedLanguages = [
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

  // Поддерживаемые темы
  static const List<String> supportedThemeModes = [
    'light',
    'dark',
    'system',
  ];

  // Поддерживаемые транспорты SIP
  static const List<String> supportedSipTransports = [
    'UDP',
    'TCP',
    'TLS',
  ];

  // Поддерживаемые кодеки
  static const List<String> supportedCodecs = [
    'PCMU',
    'PCMA',
    'G729',
    'G722',
    'G723.1',
    'G726',
    'G728',
    'AMR',
    'AMR-WB',
  ];

  // Метрики производительности
  static const int targetStartupTimeMs = 3000;
  static const int targetMemoryUsageMb = 100;
  static const int targetApkSizeMb = 50;
  static const int targetUiResponseTimeMs = 16;
}
