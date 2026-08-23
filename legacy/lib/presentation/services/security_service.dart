import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с безопасностью приложения
class SecurityService {
  final Logger _logger;
  
  static const String _saltKey = 'security_salt';
  static const String _encryptionKey = 'encryption_key';
  static const int _saltLength = 32;
  static const int _keyLength = 256;
  
  SecurityService() : _logger = Logger();

  /// Генерация случайной соли
  String generateSalt([int length = _saltLength]) {
    try {
      final random = Random.secure();
      final bytes = Uint8List(length);
      for (int i = 0; i < length; i++) {
        bytes[i] = random.nextInt(256);
      }
      return base64Url.encode(bytes);
    } catch (e) {
      _logger.e('Failed to generate salt', error: e);
      rethrow;
    }
  }

  /// Хеширование пароля с солью
  String hashPassword(String password, String salt) {
    try {
      final bytes = utf8.encode(password + salt);
      final digest = sha256.convert(bytes);
      return digest.toString();
    } catch (e) {
      _logger.e('Failed to hash password', error: e);
      rethrow;
    }
  }

  /// Проверка пароля
  bool verifyPassword(String password, String hashedPassword, String salt) {
    try {
      final hashedInput = hashPassword(password, salt);
      return hashedInput == hashedPassword;
    } catch (e) {
      _logger.e('Failed to verify password', error: e);
      return false;
    }
  }

  /// Генерация токена доступа
  String generateAccessToken([int length = 64]) {
    try {
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random.secure();
      return String.fromCharCodes(
        Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
      );
    } catch (e) {
      _logger.e('Failed to generate access token', error: e);
      rethrow;
    }
  }

  /// Генерация PIN-кода
  String generatePin([int length = 6]) {
    try {
      final random = Random.secure();
      return String.fromCharCodes(
        Iterable.generate(length, (_) => 48 + random.nextInt(10))
      );
    } catch (e) {
      _logger.e('Failed to generate PIN', error: e);
      rethrow;
    }
  }

  /// Проверка сложности пароля
  PasswordStrength checkPasswordStrength(String password) {
    try {
      int score = 0;
      final issues = <String>[];

      // Длина пароля
      if (password.length >= 8) {
        score += 1;
      } else {
        issues.add('Password must be at least 8 characters long');
      }

      // Наличие цифр
      if (RegExp(r'\d').hasMatch(password)) {
        score += 1;
      } else {
        issues.add('Password must contain at least one digit');
      }

      // Наличие строчных букв
      if (RegExp(r'[a-z]').hasMatch(password)) {
        score += 1;
      } else {
        issues.add('Password must contain at least one lowercase letter');
      }

      // Наличие заглавных букв
      if (RegExp(r'[A-Z]').hasMatch(password)) {
        score += 1;
      } else {
        issues.add('Password must contain at least one uppercase letter');
      }

      // Наличие специальных символов
      if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
        score += 1;
      } else {
        issues.add('Password must contain at least one special character');
      }

      // Определение силы пароля
      PasswordStrengthLevel level;
      if (score <= 2) {
        level = PasswordStrengthLevel.weak;
      } else if (score <= 3) {
        level = PasswordStrengthLevel.fair;
      } else if (score <= 4) {
        level = PasswordStrengthLevel.good;
      } else {
        level = PasswordStrengthLevel.strong;
      }

      return PasswordStrength(
        level: level,
        score: score,
        maxScore: 5,
        issues: issues,
      );
    } catch (e) {
      _logger.e('Failed to check password strength', error: e);
      return PasswordStrength(
        level: PasswordStrengthLevel.weak,
        score: 0,
        maxScore: 5,
        issues: ['Failed to analyze password'],
      );
    }
  }

  /// Валидация email
  bool isValidEmail(String email) {
    try {
      final emailRegex = RegExp(
        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+',
      );
      return emailRegex.hasMatch(email);
    } catch (e) {
      _logger.e('Failed to validate email', error: e);
      return false;
    }
  }

  /// Валидация номера телефона
  bool isValidPhoneNumber(String phoneNumber) {
    try {
      // Удаляем все нецифровые символы
      final digits = phoneNumber.replaceAll(RegExp(r'\D'), '');
      
      // Проверяем длину (от 10 до 15 цифр)
      if (digits.length < 10 || digits.length > 15) {
        return false;
      }
      
      // Проверяем, что номер начинается с допустимого кода страны
      final validCountryCodes = [
        '1', '7', '33', '44', '49', '81', '86', '91', '52', '55', '61', '34', '39', '46', '47', '48'
      ];
      
      return validCountryCodes.any((code) => digits.startsWith(code));
    } catch (e) {
      _logger.e('Failed to validate phone number', error: e);
      return false;
    }
  }

  /// Маскирование чувствительных данных
  String maskSensitiveData(String data, {int visibleChars = 4}) {
    try {
      if (data.length <= visibleChars) {
        return '*' * data.length;
      }
      
      final visible = data.substring(data.length - visibleChars);
      final masked = '*' * (data.length - visibleChars);
      return masked + visible;
    } catch (e) {
      _logger.e('Failed to mask sensitive data', error: e);
      return '*' * data.length;
    }
  }

  /// Генерация безопасного имени файла
  String generateSecureFileName(String originalName) {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random.secure();
      final randomSuffix = random.nextInt(10000);
      
      // Получаем расширение файла
      final extension = originalName.contains('.') 
          ? '.${originalName.split('.').last}'
          : '';
      
      // Создаем безопасное имя
      final safeName = 'file_${timestamp}_$randomSuffix$extension';
      
      return safeName;
    } catch (e) {
      _logger.e('Failed to generate secure file name', error: e);
      return 'file_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Проверка безопасности URL
  bool isSecureUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.scheme == 'https';
    } catch (e) {
      _logger.e('Failed to check URL security', error: e);
      return false;
    }
  }

  /// Создание безопасного ключа для API
  String generateApiKey([int length = 32]) {
    try {
      const chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
      final random = Random.secure();
      final key = String.fromCharCodes(
        Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length)))
      );
      
      // Добавляем префикс для идентификации
      return 'gost_$key';
    } catch (e) {
      _logger.e('Failed to generate API key', error: e);
      rethrow;
    }
  }

  /// Проверка срока действия токена
  bool isTokenExpired(DateTime tokenExpiry) {
    try {
      return DateTime.now().isAfter(tokenExpiry);
    } catch (e) {
      _logger.e('Failed to check token expiry', error: e);
      return true; // Считаем токен истекшим в случае ошибки
    }
  }

  /// Получение информации о безопасности
  Map<String, dynamic> getSecurityInfo() {
    return {
      'saltLength': _saltLength,
      'keyLength': _keyLength,
      'timestamp': DateTime.now().toIso8601String(),
      'version': '1.0.0',
    };
  }
}

/// Уровни силы пароля
enum PasswordStrengthLevel {
  weak,
  fair,
  good,
  strong,
}

/// Информация о силе пароля
class PasswordStrength {
  final PasswordStrengthLevel level;
  final int score;
  final int maxScore;
  final List<String> issues;

  const PasswordStrength({
    required this.level,
    required this.score,
    required this.maxScore,
    required this.issues,
  });

  /// Получение цвета для отображения силы пароля
  String getColorHex() {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return '#FF4444';
      case PasswordStrengthLevel.fair:
        return '#FF8800';
      case PasswordStrengthLevel.good:
        return '#FFCC00';
      case PasswordStrengthLevel.strong:
        return '#00CC00';
    }
  }

  /// Получение текстового описания силы пароля
  String getDescription() {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return 'Weak password';
      case PasswordStrengthLevel.fair:
        return 'Fair password';
      case PasswordStrengthLevel.good:
        return 'Good password';
      case PasswordStrengthLevel.strong:
        return 'Strong password';
    }
  }

  /// Проверка, является ли пароль достаточно сильным
  bool get isStrongEnough => level == PasswordStrengthLevel.good || level == PasswordStrengthLevel.strong;
}
