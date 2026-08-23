/// Метод доступа к голосовой линии
enum VoiceLineMethod {
  /// TTY Port (последовательный порт)
  ttyPort,

  /// Enhanced Mode (системный уровень, Magisk)
  enhancedMode,

  /// Dongle (внешний адаптер USB-C/TRRS)
  dongle,

  /// Telecom API (стандартный Android API)
  telecomApi,

  /// Acoustic Coupling (акустическое сопряжение, fallback)
  acoustic,
}

extension VoiceLineMethodExtension on VoiceLineMethod {
  /// Отображаемое имя метода
  String get displayName {
    switch (this) {
      case VoiceLineMethod.ttyPort:
        return 'TTY Port';
      case VoiceLineMethod.enhancedMode:
        return 'Enhanced Mode';
      case VoiceLineMethod.dongle:
        return 'Dongle';
      case VoiceLineMethod.telecomApi:
        return 'Telecom API';
      case VoiceLineMethod.acoustic:
        return 'Acoustic Coupling';
    }
  }

  /// Описание метода
  String get description {
    switch (this) {
      case VoiceLineMethod.ttyPort:
        return 'Direct access via serial port';
      case VoiceLineMethod.enhancedMode:
        return 'System-level audio access';
      case VoiceLineMethod.dongle:
        return 'External hardware adapter';
      case VoiceLineMethod.telecomApi:
        return 'Standard Android telephony API';
      case VoiceLineMethod.acoustic:
        return 'Earphone to microphone coupling';
    }
  }

  /// Приоритет метода (меньше = лучше)
  int get priority {
    switch (this) {
      case VoiceLineMethod.ttyPort:
        return 1;
      case VoiceLineMethod.enhancedMode:
        return 2;
      case VoiceLineMethod.dongle:
        return 3;
      case VoiceLineMethod.telecomApi:
        return 4;
      case VoiceLineMethod.acoustic:
        return 5;
    }
  }

  /// Сериализация в JSON
  String toJson() => name;

  /// Десериализация из JSON
  static VoiceLineMethod? fromJson(String? value) {
    if (value == null) return null;
    try {
      return VoiceLineMethod.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}
