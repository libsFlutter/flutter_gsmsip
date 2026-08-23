import 'package:flutter_test/flutter_test.dart';

import 'package:gostsimbox_gateway/presentation/services/security_service.dart';

void main() {
  group('SecurityService', () {
    late SecurityService securityService;

    setUp(() {
      securityService = SecurityService();
    });

    group('generateSalt', () {
      test('should generate salt with default length', () {
        // Act
        final salt = securityService.generateSalt();

        // Assert
        expect(salt, isA<String>());
        expect(salt.length, greaterThan(0));
      });

      test('should generate salt with custom length', () {
        // Act
        final salt = securityService.generateSalt(16);

        // Assert
        expect(salt, isA<String>());
        expect(salt.length, greaterThan(0));
      });

      test('should generate different salts', () {
        // Act
        final salt1 = securityService.generateSalt();
        final salt2 = securityService.generateSalt();

        // Assert
        expect(salt1, isNot(equals(salt2)));
      });
    });

    group('hashPassword', () {
      test('should hash password with salt', () {
        // Arrange
        const password = 'testPassword123';
        const salt = 'testSalt';

        // Act
        final hash = securityService.hashPassword(password, salt);

        // Assert
        expect(hash, isA<String>());
        expect(hash.length, greaterThan(0));
        expect(hash, isNot(equals(password)));
      });

      test('should generate same hash for same password and salt', () {
        // Arrange
        const password = 'testPassword123';
        const salt = 'testSalt';

        // Act
        final hash1 = securityService.hashPassword(password, salt);
        final hash2 = securityService.hashPassword(password, salt);

        // Assert
        expect(hash1, equals(hash2));
      });

      test('should generate different hashes for different salts', () {
        // Arrange
        const password = 'testPassword123';
        const salt1 = 'salt1';
        const salt2 = 'salt2';

        // Act
        final hash1 = securityService.hashPassword(password, salt1);
        final hash2 = securityService.hashPassword(password, salt2);

        // Assert
        expect(hash1, isNot(equals(hash2)));
      });
    });

    group('verifyPassword', () {
      test('should verify correct password', () {
        // Arrange
        const password = 'testPassword123';
        const salt = 'testSalt';
        final hash = securityService.hashPassword(password, salt);

        // Act
        final isValid = securityService.verifyPassword(password, hash, salt);

        // Assert
        expect(isValid, isTrue);
      });

      test('should reject incorrect password', () {
        // Arrange
        const correctPassword = 'testPassword123';
        const wrongPassword = 'wrongPassword';
        const salt = 'testSalt';
        final hash = securityService.hashPassword(correctPassword, salt);

        // Act
        final isValid = securityService.verifyPassword(wrongPassword, hash, salt);

        // Assert
        expect(isValid, isFalse);
      });

      test('should handle verification error gracefully', () {
        // Act
        final isValid = securityService.verifyPassword('', '', '');

        // Assert
        expect(isValid, isFalse);
      });
    });

    group('generateAccessToken', () {
      test('should generate access token with default length', () {
        // Act
        final token = securityService.generateAccessToken();

        // Assert
        expect(token, isA<String>());
        expect(token.length, equals(64));
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(token), isTrue);
      });

      test('should generate access token with custom length', () {
        // Act
        final token = securityService.generateAccessToken(32);

        // Assert
        expect(token, isA<String>());
        expect(token.length, equals(32));
        expect(RegExp(r'^[a-zA-Z0-9]+$').hasMatch(token), isTrue);
      });

      test('should generate different tokens', () {
        // Act
        final token1 = securityService.generateAccessToken();
        final token2 = securityService.generateAccessToken();

        // Assert
        expect(token1, isNot(equals(token2)));
      });
    });

    group('generatePin', () {
      test('should generate PIN with default length', () {
        // Act
        final pin = securityService.generatePin();

        // Assert
        expect(pin, isA<String>());
        expect(pin.length, equals(6));
        expect(RegExp(r'^[0-9]+$').hasMatch(pin), isTrue);
      });

      test('should generate PIN with custom length', () {
        // Act
        final pin = securityService.generatePin(4);

        // Assert
        expect(pin, isA<String>());
        expect(pin.length, equals(4));
        expect(RegExp(r'^[0-9]+$').hasMatch(pin), isTrue);
      });

      test('should generate different PINs', () {
        // Act
        final pin1 = securityService.generatePin();
        final pin2 = securityService.generatePin();

        // Assert
        expect(pin1, isNot(equals(pin2)));
      });
    });

    group('checkPasswordStrength', () {
      test('should identify weak password', () {
        // Act
        final strength = securityService.checkPasswordStrength('weak');

        // Assert
        expect(strength.level, equals(PasswordStrengthLevel.weak));
        expect(strength.score, lessThan(3));
        expect(strength.issues.length, greaterThan(0));
      });

      test('should identify strong password', () {
        // Act
        final strength = securityService.checkPasswordStrength('StrongPass123!');

        // Assert
        expect(strength.level, equals(PasswordStrengthLevel.strong));
        expect(strength.score, equals(5));
        expect(strength.issues.length, equals(0));
      });

      test('should identify fair password', () {
        // Act
        final strength = securityService.checkPasswordStrength('Password123');

        // Assert
        expect(strength.level, equals(PasswordStrengthLevel.good));
        expect(strength.score, greaterThanOrEqualTo(4));
      });

      test('should handle empty password', () {
        // Act
        final strength = securityService.checkPasswordStrength('');

        // Assert
        expect(strength.level, equals(PasswordStrengthLevel.weak));
        expect(strength.score, equals(0));
        expect(strength.issues.length, greaterThan(0));
      });

      test('should provide correct issues for weak password', () {
        // Act
        final strength = securityService.checkPasswordStrength('weak');

        // Assert
        expect(strength.issues, contains('Password must be at least 8 characters long'));
        expect(strength.issues, contains('Password must contain at least one digit'));
        expect(strength.issues, contains('Password must contain at least one uppercase letter'));
        expect(strength.issues, contains('Password must contain at least one special character'));
      });
    });

    group('isValidEmail', () {
      test('should validate correct email addresses', () {
        expect(securityService.isValidEmail('test@example.com'), isTrue);
        expect(securityService.isValidEmail('user.name@domain.co.uk'), isTrue);
        expect(securityService.isValidEmail('test123@test.org'), isTrue);
      });

      test('should reject invalid email addresses', () {
        expect(securityService.isValidEmail('invalid-email'), isFalse);
        expect(securityService.isValidEmail('test@'), isFalse);
        expect(securityService.isValidEmail('@domain.com'), isFalse);
        expect(securityService.isValidEmail('test@domain'), isFalse);
        expect(securityService.isValidEmail(''), isFalse);
      });
    });

    group('isValidPhoneNumber', () {
      test('should validate correct phone numbers', () {
        expect(securityService.isValidPhoneNumber('+1234567890'), isTrue);
        expect(securityService.isValidPhoneNumber('+79123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+33123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+44123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+49123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+81123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+86123456789'), isTrue);
        expect(securityService.isValidPhoneNumber('+91123456789'), isTrue);
      });

      test('should reject invalid phone numbers', () {
        expect(securityService.isValidPhoneNumber('123'), isFalse);
        expect(securityService.isValidPhoneNumber('1234567890123456'), isFalse);
        expect(securityService.isValidPhoneNumber('+999123456789'), isFalse);
        expect(securityService.isValidPhoneNumber(''), isFalse);
        expect(securityService.isValidPhoneNumber('abc'), isFalse);
      });

      test('should handle phone numbers with spaces and dashes', () {
        expect(securityService.isValidPhoneNumber('+1 234 567 890'), isTrue);
        expect(securityService.isValidPhoneNumber('+7-912-345-67-89'), isTrue);
        expect(securityService.isValidPhoneNumber('+33 1 23 45 67 89'), isTrue);
      });
    });

    group('maskSensitiveData', () {
      test('should mask data with default visible characters', () {
        expect(securityService.maskSensitiveData('1234567890'), '******7890');
        expect(securityService.maskSensitiveData('abcdefgh'), '****efgh');
      });

      test('should mask data with custom visible characters', () {
        expect(securityService.maskSensitiveData('1234567890', visibleChars: 2), '********90');
        expect(securityService.maskSensitiveData('abcdefgh', visibleChars: 1), '*******h');
      });

      test('should handle short data', () {
        expect(securityService.maskSensitiveData('123'), '***');
        expect(securityService.maskSensitiveData('a'), '*');
      });

      test('should handle empty data', () {
        expect(securityService.maskSensitiveData(''), '');
      });
    });

    group('generateSecureFileName', () {
      test('should generate secure file name', () {
        // Act
        final fileName = securityService.generateSecureFileName('test.txt');

        // Assert
        expect(fileName, isA<String>());
        expect(fileName.startsWith('file_'), isTrue);
        expect(fileName.endsWith('.txt'), isTrue);
        expect(fileName.contains('_'), isTrue);
      });

      test('should handle file without extension', () {
        // Act
        final fileName = securityService.generateSecureFileName('testfile');

        // Assert
        expect(fileName, isA<String>());
        expect(fileName.startsWith('file_'), isTrue);
        expect(fileName.endsWith('.txt'), isFalse);
      });

      test('should generate different names for same file', () {
        // Act
        final fileName1 = securityService.generateSecureFileName('test.txt');
        final fileName2 = securityService.generateSecureFileName('test.txt');

        // Assert
        expect(fileName1, isNot(equals(fileName2)));
      });
    });

    group('isSecureUrl', () {
      test('should identify secure URLs', () {
        expect(securityService.isSecureUrl('https://example.com'), isTrue);
        expect(securityService.isSecureUrl('https://api.example.com/path'), isTrue);
        expect(securityService.isSecureUrl('https://example.com:443'), isTrue);
      });

      test('should reject insecure URLs', () {
        expect(securityService.isSecureUrl('http://example.com'), isFalse);
        expect(securityService.isSecureUrl('ftp://example.com'), isFalse);
        expect(securityService.isSecureUrl('example.com'), isFalse);
      });

      test('should handle invalid URLs', () {
        expect(securityService.isSecureUrl(''), isFalse);
        expect(securityService.isSecureUrl('not-a-url'), isFalse);
      });
    });

    group('generateApiKey', () {
      test('should generate API key with default length', () {
        // Act
        final apiKey = securityService.generateApiKey();

        // Assert
        expect(apiKey, isA<String>());
        expect(apiKey.startsWith('gost_'), isTrue);
        expect(apiKey.length, equals(36)); // 5 (prefix) + 32 (key)
        expect(RegExp(r'^gost_[a-zA-Z0-9]+$').hasMatch(apiKey), isTrue);
      });

      test('should generate API key with custom length', () {
        // Act
        final apiKey = securityService.generateApiKey(16);

        // Assert
        expect(apiKey, isA<String>());
        expect(apiKey.startsWith('gost_'), isTrue);
        expect(apiKey.length, equals(21)); // 5 (prefix) + 16 (key)
      });

      test('should generate different API keys', () {
        // Act
        final apiKey1 = securityService.generateApiKey();
        final apiKey2 = securityService.generateApiKey();

        // Assert
        expect(apiKey1, isNot(equals(apiKey2)));
      });
    });

    group('isTokenExpired', () {
      test('should identify expired token', () {
        // Arrange
        final expiredTime = DateTime.now().subtract(const Duration(hours: 1));

        // Act
        final isExpired = securityService.isTokenExpired(expiredTime);

        // Assert
        expect(isExpired, isTrue);
      });

      test('should identify valid token', () {
        // Arrange
        final validTime = DateTime.now().add(const Duration(hours: 1));

        // Act
        final isExpired = securityService.isTokenExpired(validTime);

        // Assert
        expect(isExpired, isFalse);
      });
    });

    group('getSecurityInfo', () {
      test('should return security information', () {
        // Act
        final info = securityService.getSecurityInfo();

        // Assert
        expect(info['saltLength'], equals(32));
        expect(info['keyLength'], equals(256));
        expect(info['version'], equals('1.0.0'));
        expect(info['timestamp'], isA<String>());
      });
    });

    group('PasswordStrength', () {
      test('should provide correct color hex codes', () {
        expect(PasswordStrength(level: PasswordStrengthLevel.weak, score: 1, maxScore: 5, issues: []).getColorHex(), equals('#FF4444'));
        expect(PasswordStrength(level: PasswordStrengthLevel.fair, score: 2, maxScore: 5, issues: []).getColorHex(), equals('#FF8800'));
        expect(PasswordStrength(level: PasswordStrengthLevel.good, score: 4, maxScore: 5, issues: []).getColorHex(), equals('#FFCC00'));
        expect(PasswordStrength(level: PasswordStrengthLevel.strong, score: 5, maxScore: 5, issues: []).getColorHex(), equals('#00CC00'));
      });

      test('should provide correct descriptions', () {
        expect(PasswordStrength(level: PasswordStrengthLevel.weak, score: 1, maxScore: 5, issues: []).getDescription(), equals('Weak password'));
        expect(PasswordStrength(level: PasswordStrengthLevel.fair, score: 2, maxScore: 5, issues: []).getDescription(), equals('Fair password'));
        expect(PasswordStrength(level: PasswordStrengthLevel.good, score: 4, maxScore: 5, issues: []).getDescription(), equals('Good password'));
        expect(PasswordStrength(level: PasswordStrengthLevel.strong, score: 5, maxScore: 5, issues: []).getDescription(), equals('Strong password'));
      });

      test('should correctly identify strong enough passwords', () {
        expect(PasswordStrength(level: PasswordStrengthLevel.weak, score: 1, maxScore: 5, issues: []).isStrongEnough, isFalse);
        expect(PasswordStrength(level: PasswordStrengthLevel.fair, score: 2, maxScore: 5, issues: []).isStrongEnough, isFalse);
        expect(PasswordStrength(level: PasswordStrengthLevel.good, score: 4, maxScore: 5, issues: []).isStrongEnough, isTrue);
        expect(PasswordStrength(level: PasswordStrengthLevel.strong, score: 5, maxScore: 5, issues: []).isStrongEnough, isTrue);
      });

      test('should calculate percentages correctly', () {
        final strength = PasswordStrength(level: PasswordStrengthLevel.good, score: 4, maxScore: 5, issues: []);
        expect(strength.validPercentage, equals(80.0));
        expect(strength.expiredPercentage, equals(20.0));
      });
    });
  });
}
