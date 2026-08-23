/// Утилиты для валидации данных
/// Централизованная валидация для всего приложения
import 'dart:core';
import '../constants/app_constants.dart';

/// Класс для валидации различных типов данных
class Validators {
  // Приватный конструктор
  Validators._();

  /// Валидация номера телефона
  static bool isValidPhoneNumber(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return false;
    }

    // Удаляем все пробелы, дефисы и скобки
    final cleanNumber = phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
    
    // Проверяем длину
    if (cleanNumber.length < AppConstants.minPhoneNumberLength || 
        cleanNumber.length > AppConstants.maxPhoneNumberLength) {
      return false;
    }

    // Проверяем, что содержит только цифры и может начинаться с +
    return RegExp(r'^[\+]?[0-9]+$').hasMatch(cleanNumber);
  }

  /// Валидация email адреса
  static bool isValidEmail(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }

    return RegExp(AppConstants.emailRegex).hasMatch(email);
  }

  /// Валидация IP адреса
  static bool isValidIpAddress(String? ipAddress) {
    if (ipAddress == null || ipAddress.isEmpty) {
      return false;
    }

    return RegExp(AppConstants.ipAddressRegex).hasMatch(ipAddress);
  }

  /// Валидация порта
  static bool isValidPort(int? port) {
    if (port == null) {
      return false;
    }

    return port > 0 && port <= 65535;
  }

  /// Валидация длины SMS
  static bool isValidSmsLength(String? message) {
    if (message == null) {
      return false;
    }

    return message.length >= AppConstants.minSmsLength && 
           message.length <= AppConstants.maxSmsLength;
  }

  /// Валидация пароля
  static bool isValidPassword(String? password) {
    if (password == null) {
      return false;
    }

    return password.length >= AppConstants.minPasswordLength && 
           password.length <= AppConstants.maxPasswordLength;
  }

  /// Валидация имени пользователя
  static bool isValidUsername(String? username) {
    if (username == null || username.isEmpty) {
      return false;
    }

    // Имя пользователя должно содержать только буквы, цифры, дефисы и подчеркивания
    return RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(username);
  }

  /// Валидация URL
  static bool isValidUrl(String? url) {
    if (url == null || url.isEmpty) {
      return false;
    }

    try {
      Uri.parse(url);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Валидация имени сервера
  static bool isValidServerName(String? serverName) {
    if (serverName == null || serverName.isEmpty) {
      return false;
    }

    // Проверяем, что это либо IP адрес, либо валидное доменное имя
    if (isValidIpAddress(serverName)) {
      return true;
    }

    // Простая проверка доменного имени
    return RegExp(r'^[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?(\.[a-zA-Z0-9]([a-zA-Z0-9\-]{0,61}[a-zA-Z0-9])?)*$').hasMatch(serverName);
  }

  /// Валидация конфигурации шлюза
  static List<String> validateGatewayConfig(Map<String, dynamic> config) {
    final errors = <String>[];

    // Проверяем обязательные поля
    if (config['name'] == null || config['name'].toString().isEmpty) {
      errors.add('Gateway name is required');
    }

    final sipConfig = config['sipConfig'] as Map<String, dynamic>?;
    if (sipConfig != null) {
      if (sipConfig['server'] == null || sipConfig['server'].toString().isEmpty) {
        errors.add('SIP server is required');
      } else if (!isValidServerName(sipConfig['server'].toString())) {
        errors.add('Invalid SIP server address');
      }

      if (sipConfig['port'] != null && !isValidPort(sipConfig['port'])) {
        errors.add('Invalid SIP port');
      }

      if (sipConfig['username'] == null || sipConfig['username'].toString().isEmpty) {
        errors.add('SIP username is required');
      }

      if (sipConfig['password'] == null || sipConfig['password'].toString().isEmpty) {
        errors.add('SIP password is required');
      }
    }

    return errors;
  }

  /// Очистка номера телефона от форматирования
  static String cleanPhoneNumber(String phoneNumber) {
    return phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
  }

  /// Форматирование номера телефона для отображения
  static String formatPhoneNumber(String phoneNumber) {
    final clean = cleanPhoneNumber(phoneNumber);
    
    if (clean.length == 11 && clean.startsWith('8')) {
      return '+7${clean.substring(1)}';
    }
    
    if (clean.length == 10) {
      return '+7$clean';
    }
    
    return clean;
  }

  /// Проверка, является ли номер экстренным
  static bool isEmergencyNumber(String phoneNumber) {
    final clean = cleanPhoneNumber(phoneNumber);
    return AppConstants.defaultEmergencyNumbers.contains(clean);
  }

  /// Валидация кодека
  static bool isValidCodec(String? codec) {
    if (codec == null || codec.isEmpty) {
      return false;
    }

    return AppConstants.supportedCodecs.contains(codec.toUpperCase());
  }

  /// Валидация транспорта SIP
  static bool isValidSipTransport(String? transport) {
    if (transport == null || transport.isEmpty) {
      return false;
    }

    return AppConstants.supportedSipTransports.contains(transport.toUpperCase());
  }

  /// Валидация режима темы
  static bool isValidThemeMode(String? themeMode) {
    if (themeMode == null || themeMode.isEmpty) {
      return false;
    }

    return AppConstants.supportedThemeModes.contains(themeMode.toLowerCase());
  }

  /// Валидация языка
  static bool isValidLanguage(String? languageCode) {
    if (languageCode == null || languageCode.isEmpty) {
      return false;
    }

    return AppConstants.supportedLanguages.any((lang) => lang['code'] == languageCode);
  }

  /// Получение сообщения об ошибке валидации
  static String getValidationErrorMessage(String field, String error) {
    switch (error) {
      case 'required':
        return '$field is required';
      case 'invalid_format':
        return 'Invalid $field format';
      case 'too_short':
        return '$field is too short';
      case 'too_long':
        return '$field is too long';
      case 'invalid_value':
        return 'Invalid $field value';
      default:
        return 'Invalid $field';
    }
  }
}
