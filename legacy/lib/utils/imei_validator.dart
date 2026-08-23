/// IMEI Validator using Luhn Algorithm
///
/// Provides validation and parsing of IMEI (International Mobile Equipment Identity) numbers.
///
/// ## IMEI Structure
///
/// ```
/// IMEI: 861234567890123
///       │││││││││││││││
///       │││││││││││││└─ Check digit (Luhn)
///       │││││││││││└─── Serial number (6 digits)
///       │││││││└──────── Model identifier (6 digits)
///       │││└──────────── Origin code (2 digits)
///       └──────────────── Reporting body identifier (2 digits)
/// ```
///
/// ## Usage
///
/// ```dart
/// // Validate IMEI
/// if (IMEIValidator.isValid('861234567890123')) {
///   print('Valid IMEI');
/// }
///
/// // Calculate check digit
/// final checkDigit = IMEIValidator.calculateCheckDigit('86123456789012');
///
/// // Parse IMEI structure
/// final structure = IMEIValidator.parse('861234567890123');
/// print(structure.reportingBodyIdentifier); // '86'
/// ```
library imei_validator;

/// IMEI validation results
enum IMEIValidationResult {
  /// IMEI is valid
  valid,

  /// IMEI has wrong length
  invalidLength,

  /// IMEI contains non-numeric characters
  invalidCharacters,

  /// IMEI fails Luhn checksum validation
  invalidChecksum,

  /// IMEI format is correct but structure is invalid
  invalidStructure,
}

/// IMEI structure representation
class IMEIStructure {
  /// Reporting Body Identifier (first 2 digits)
  /// Identifies the GSMA-approved organization that allocated the TAC
  final String reportingBodyIdentifier;

  /// Type Allocation Code (digits 3-8)
  /// Identifies the device model
  final String typeAllocationCode;

  /// Serial Number (digits 9-14)
  /// Unique identifier for the device
  final String serialNumber;

  /// Check Digit (digit 15)
  /// Calculated using Luhn algorithm
  final String checkDigit;

  /// IMEI without check digit (14 digits)
  String get imeiWithoutCheck =>
      reportingBodyIdentifier + typeAllocationCode + serialNumber;

  /// Full IMEI with check digit (15 digits)
  String get fullIMEI => imeiWithoutCheck + checkDigit;

  /// IMEISV (IMEI Software Version) - 16 digits without check digit
  String get imeiSV => imeiWithoutCheck + '0';

  const IMEIStructure({
    required this.reportingBodyIdentifier,
    required this.typeAllocationCode,
    required this.serialNumber,
    required this.checkDigit,
  });

  /// Create from full IMEI string
  factory IMEIStructure.parse(String imei) {
    if (imei.length != 15) {
      throw ArgumentError('IMEI must be 15 digits');
    }

    return IMEIStructure(
      reportingBodyIdentifier: imei.substring(0, 2),
      typeAllocationCode: imei.substring(2, 8),
      serialNumber: imei.substring(8, 14),
      checkDigit: imei.substring(14),
    );
  }

  @override
  String toString() => fullIMEI;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IMEIStructure && runtimeType == other.runtimeType && fullIMEI == other.fullIMEI;

  @override
  int get hashCode => fullIMEI.hashCode;
}

/// IMEI Validator using Luhn Algorithm
class IMEIValidator {
  /// Valid IMEI length (with check digit)
  static const int validLength = 15;

  /// Valid IMEI length without check digit
  static const int lengthWithoutCheck = 14;

  /// Validate IMEI format and checksum
  ///
  /// Returns true if IMEI is valid:
  /// - Exactly 15 digits
  /// - Passes Luhn checksum validation
  ///
  /// Example:
  /// ```dart
  /// IMEIValidator.isValid('861234567890123'); // true
  /// IMEIValidator.isValid('861234567890124'); // false (wrong checksum)
  /// IMEIValidator.isValid('12345');           // false (too short)
  /// ```
  static bool isValid(String imei) {
    return validate(imei) == IMEIValidationResult.valid;
  }

  /// Validate IMEI and return detailed result
  ///
  /// Returns specific validation failure reason if invalid
  static IMEIValidationResult validate(String imei) {
    // Check for null or empty
    if (imei.isEmpty) {
      return IMEIValidationResult.invalidLength;
    }

    // Check length
    if (imei.length != validLength) {
      return IMEIValidationResult.invalidLength;
    }

    // Check for non-numeric characters
    if (!RegExp(r'^\d+$').hasMatch(imei)) {
      return IMEIValidationResult.invalidCharacters;
    }

    // Check Luhn checksum
    if (!verifyLuhn(imei)) {
      return IMEIValidationResult.invalidChecksum;
    }

    // Check structure (basic TAC validation)
    final structure = IMEIStructure.parse(imei);
    if (!_isValidStructure(structure)) {
      return IMEIValidationResult.invalidStructure;
    }

    return IMEIValidationResult.valid;
  }

  /// Calculate Luhn check digit for 14-digit IMEI
  ///
  /// Example:
  /// ```dart
  /// IMEIValidator.calculateCheckDigit('86123456789012'); // '3'
  /// ```
  static String calculateCheckDigit(String imeiWithoutCheck) {
    if (imeiWithoutCheck.length != lengthWithoutCheck) {
      throw ArgumentError('IMEI without check digit must be 14 digits');
    }

    if (!RegExp(r'^\d+$').hasMatch(imeiWithoutCheck)) {
      throw ArgumentError('IMEI must contain only digits');
    }

    int sum = 0;
    bool isEven = true; // Start with even position (right-to-left, 0-indexed)

    // Process digits from right to left
    for (int i = imeiWithoutCheck.length - 1; i >= 0; i--) {
      int digit = int.parse(imeiWithoutCheck[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    // Calculate check digit
    int checkDigit = (10 - (sum % 10)) % 10;
    return checkDigit.toString();
  }

  /// Verify Luhn checksum for 15-digit IMEI
  ///
  /// The Luhn algorithm:
  /// 1. Starting from the rightmost digit, double every second digit
  /// 2. If doubling results in a number > 9, subtract 9
  /// 3. Sum all digits
  /// 4. If sum % 10 == 0, the number is valid
  ///
  /// Example:
  /// ```dart
  /// IMEIValidator.verifyLuhn('861234567890123'); // true
  /// IMEIValidator.verifyLuhn('861234567890124'); // false
  /// ```
  static bool verifyLuhn(String imei) {
    if (imei.length != validLength) {
      return false;
    }

    if (!RegExp(r'^\d+$').hasMatch(imei)) {
      return false;
    }

    int sum = 0;
    bool isEven = false; // Start from rightmost digit (check digit position)

    // Process digits from right to left
    for (int i = imei.length - 1; i >= 0; i--) {
      int digit = int.parse(imei[i]);

      if (isEven) {
        digit *= 2;
        if (digit > 9) {
          digit -= 9;
        }
      }

      sum += digit;
      isEven = !isEven;
    }

    return sum % 10 == 0;
  }

  /// Parse IMEI into structured components
  ///
  /// Example:
  /// ```dart
  /// final structure = IMEIValidator.parse('861234567890123');
  /// print(structure.reportingBodyIdentifier); // '86' (China)
  /// print(structure.typeAllocationCode);      // '123456'
  /// print(structure.serialNumber);            // '789012'
  /// print(structure.checkDigit);              // '3'
  /// ```
  static IMEIStructure parse(String imei) {
    return IMEIStructure.parse(imei);
  }

  /// Format IMEI with dashes for readability
  ///
  /// Example:
  /// ```dart
  /// IMEIValidator.formatWithDashes('861234567890123');
  /// // Returns: '86-123456-789012-3'
  /// ```
  static String formatWithDashes(String imei) {
    if (imei.length != validLength) {
      return imei;
    }

    final structure = parse(imei);
    return '${structure.reportingBodyIdentifier}-${structure.typeAllocationCode}-${structure.serialNumber}-${structure.checkDigit}';
  }

  /// Format IMEI with spaces for readability
  ///
  /// Example:
  /// ```dart
  /// IMEIValidator.formatWithSpaces('861234567890123');
  /// // Returns: '86 123456 789012 3'
  /// ```
  static String formatWithSpaces(String imei) {
    if (imei.length != validLength) {
      return imei;
    }

    final structure = parse(imei);
    return '${structure.reportingBodyIdentifier} ${structure.typeAllocationCode} ${structure.serialNumber} ${structure.checkDigit}';
  }

  /// Get reporting body name from identifier
  ///
  /// Common RBIs:
  /// - 86: China
  /// - 35: North America
  /// - 44: Europe
  /// - 49: Japan
  static String? getReportingBodyName(String rbi) {
    const reportingBodies = {
      '86': 'China (TAF)',
      '35': 'North America (PTCRB)',
      '44': 'Europe (ETSI)',
      '49': 'Japan (ARIB)',
      '53': 'Asia/Pacific',
      '80': 'Middle East',
      '91': 'Latin America',
      '98': 'Global (GSMA)',
    };

    return reportingBodies[rbi];
  }

  /// Check if IMEI structure is valid
  static bool _isValidStructure(IMEIStructure structure) {
    // Basic validation:
    // - RBI should be a known value or at least non-zero
    // - TAC should not be all zeros
    // - Serial should not be all zeros

    if (structure.reportingBodyIdentifier == '00') {
      return false;
    }

    if (structure.typeAllocationCode == '000000') {
      return false;
    }

    // Serial number can be any value except all zeros for test devices
    if (structure.serialNumber == '000000') {
      return false;
    }

    return true;
  }

  /// Generate a valid test IMEI (for testing purposes only)
  ///
  /// WARNING: Do not use real IMEIs for testing.
  /// This generates IMEIs with valid Luhn checksums but invalid structure.
  static String generateTestIMEI() {
    // Use test TAC (Type Allocation Code) reserved for testing
    // TAC 000000 is reserved but we use a non-zero one for better testing
    const testRBI = '00'; // Test RBI
    const testTAC = '000000'; // Test TAC

    // Generate random serial
    final serial = List.generate(6, (_) => (DateTime.now().millisecondsSinceEpoch % 10).toString()).join();

    // Calculate check digit
    final imeiWithoutCheck = testRBI + testTAC + serial;
    final checkDigit = calculateCheckDigit(imeiWithoutCheck);

    return imeiWithoutCheck + checkDigit;
  }
}

/// Extension for IMEI string validation
extension IMEIStringExtension on String {
  /// Check if string is a valid IMEI
  bool get isValidIMEI => IMEIValidator.isValid(this);

  /// Validate IMEI and return result
  IMEIValidationResult validateIMEI() => IMEIValidator.validate(this);

  /// Parse IMEI into structure
  IMEIStructure parseIMEI() => IMEIValidator.parse(this);

  /// Format IMEI with dashes
  String formatIMEIWithDashes() => IMEIValidator.formatWithDashes(this);

  /// Format IMEI with spaces
  String formatIMEIWithSpaces() => IMEIValidator.formatWithSpaces(this);
}
