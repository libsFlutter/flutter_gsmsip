/// Тип интерфейса донгла (адаптера)
enum DongleInterfaceType {
  /// USB-C с внешним DAC (цифровой интерфейс)
  usbCWithDac,

  /// USB-C Audio Accessory (аналоговый через SBU pins)
  usbCAudioAccessory,

  /// TRRS 3.5mm (аналоговый headset jack)
  trrs,

  /// Нет донгла
  none,
}

extension DongleInterfaceTypeExtension on DongleInterfaceType {
  /// Отображаемое имя
  String get displayName {
    switch (this) {
      case DongleInterfaceType.usbCWithDac:
        return 'USB-C with DAC';
      case DongleInterfaceType.usbCAudioAccessory:
        return 'USB-C Audio Accessory';
      case DongleInterfaceType.trrs:
        return 'TRRS 3.5mm';
      case DongleInterfaceType.none:
        return 'None';
    }
  }

  /// Описание типа сигнала
  String get signalType {
    switch (this) {
      case DongleInterfaceType.usbCWithDac:
        return 'Digital (UAC)';
      case DongleInterfaceType.usbCAudioAccessory:
        return 'Analog (SBU)';
      case DongleInterfaceType.trrs:
        return 'Analog';
      case DongleInterfaceType.none:
        return 'N/A';
    }
  }

  /// Краткое описание
  String get description {
    switch (this) {
      case DongleInterfaceType.usbCWithDac:
        return 'External DAC chip in adapter';
      case DongleInterfaceType.usbCAudioAccessory:
        return 'Uses device DAC via SBU pins';
      case DongleInterfaceType.trrs:
        return 'Headset jack connection';
      case DongleInterfaceType.none:
        return 'No dongle detected';
    }
  }

  /// Сериализация в JSON
  String toJson() => name;

  /// Десериализация из JSON
  static DongleInterfaceType? fromJson(String? value) {
    if (value == null) return null;
    try {
      return DongleInterfaceType.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }
}
