/// Тип схемы донгла (определяется по сопротивлению)
enum DongleType {
  /// Differential (4R+1C) - дифференциальный выход
  differential,

  /// Mono Loopback - монофонический loopback
  monoLoopback,

  /// Stereo Loopback - стерео loopback
  stereoLoopback,

  /// Earphone-to-Mic - акустическое сопряжение
  earphoneToMic,
}

extension DongleTypeExtension on DongleType {
  /// Отображаемое имя
  String get displayName {
    switch (this) {
      case DongleType.differential:
        return 'Differential (4R+1C)';
      case DongleType.monoLoopback:
        return 'Mono Loopback';
      case DongleType.stereoLoopback:
        return 'Stereo Loopback';
      case DongleType.earphoneToMic:
        return 'Earphone-to-Mic';
    }
  }

  /// Краткое описание
  String get description {
    switch (this) {
      case DongleType.differential:
        return 'Differential signaling for phone line';
      case DongleType.monoLoopback:
        return 'L+R mixed to mono';
      case DongleType.stereoLoopback:
        return 'L and R separate channels';
      case DongleType.earphoneToMic:
        return 'Acoustic coupling (speaker→mic)';
    }
  }

  /// Сигнатура сопротивлений
  String get resistanceSignature {
    switch (this) {
      case DongleType.differential:
        return 'GND→MIC ~10k, L→GND ~15k';
      case DongleType.monoLoopback:
        return 'GND→MIC ~1.8k, L→GND ~100k';
      case DongleType.stereoLoopback:
        return 'GND→MIC ~1.8k, L→GND ∞';
      case DongleType.earphoneToMic:
        return 'GND→MIC ~10k, L→GND ∞';
    }
  }

  /// Сериализация в JSON
  String toJson() => name;

  /// Десериализация из JSON
  static DongleType? fromJson(String? value) {
    if (value == null) return null;
    try {
      return DongleType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}

/// Детектор типа донгла по сопротивлениям
class DongleTypeDetector {
  /// Допуск измерений (±20%)
  static const double tolerance = 0.2;

  /// Определить тип донгла по измерениям сопротивлений
  static DongleType? detect({
    required int? gndToMic,
    required int? leftToGnd,
    required int? rightToGnd,
    int? leftToMic,
  }) {
    if (gndToMic == null || leftToGnd == null) {
      return null;
    }

    // Проверка на Differential (4R+1C)
    if (_isInRange(gndToMic, 10000, tolerance) &&
        leftToGnd != null &&
        _isInRange(leftToGnd, 15000, tolerance)) {
      return DongleType.differential;
    }

    // Проверка на Mono Loopback
    if (_isInRange(gndToMic, 1800, tolerance) &&
        leftToGnd != null &&
        _isInRange(leftToGnd, 100000, tolerance)) {
      return DongleType.monoLoopback;
    }

    // Проверка на Stereo Loopback
    if (_isInRange(gndToMic, 1800, tolerance) &&
        (leftToGnd == null || leftToGnd > 1000000)) {
      return DongleType.stereoLoopback;
    }

    // Проверка на Earphone-to-Mic
    if (_isInRange(gndToMic, 10000, tolerance) &&
        (leftToGnd == null || leftToGnd > 1000000)) {
      return DongleType.earphoneToMic;
    }

    // Неизвестный тип
    return null;
  }

  /// Проверка значения на попадание в диапазон с допуском
  static bool _isInRange(int value, int target, double tolerance) {
    final min = target * (1 - tolerance);
    final max = target * (1 + tolerance);
    return value >= min && value <= max;
  }

  /// Получить уверенность определения (0.0 - 1.0)
  static double getConfidence({
    required int? gndToMic,
    required int? leftToGnd,
    required DongleType type,
  }) {
    if (gndToMic == null) return 0.0;

    int expectedMic;
    int expectedLeft;

    switch (type) {
      case DongleType.differential:
        expectedMic = 10000;
        expectedLeft = 15000;
        break;
      case DongleType.monoLoopback:
        expectedMic = 1800;
        expectedLeft = 100000;
        break;
      case DongleType.stereoLoopback:
        expectedMic = 1800;
        expectedLeft = -1; // ∞
        break;
      case DongleType.earphoneToMic:
        expectedMic = 10000;
        expectedLeft = -1; // ∞
        break;
    }

    double micConfidence = 1.0 - ((gndToMic - expectedMic).abs() / expectedMic);
    micConfidence = micConfidence.clamp(0.0, 1.0);

    if (expectedLeft == -1) {
      // Проверка на ∞
      if (leftToGnd == null || leftToGnd > 1000000) {
        return micConfidence;
      } else {
        return 0.0;
      }
    }

    if (leftToGnd == null) return micConfidence * 0.5;

    double leftConfidence = 1.0 - ((leftToGnd - expectedLeft).abs() / expectedLeft);
    leftConfidence = leftConfidence.clamp(0.0, 1.0);

    return (micConfidence + leftConfidence) / 2;
  }
}
