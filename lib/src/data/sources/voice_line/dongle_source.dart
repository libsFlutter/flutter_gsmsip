import 'package:flutter/foundation.dart';
import '../../../domain/models/voice_line_method.dart';
import '../../../domain/models/quality_level.dart';
import '../../../domain/models/voice_line_method_status.dart';

/// Тип интерфейса донгла
enum DongleInterfaceType {
  /// USB-C с внешним DAC (цифровой)
  usbCWithDac,

  /// USB-C Audio Accessory (аналоговый через SBU)
  usbCAudioAccessory,

  /// TRRS 3.5mm (аналоговый)
  trrs,

  /// Нет донгла
  none,
}

/// Тип схемы донгла
enum DongleType {
  /// Differential (4R+1C)
  differential,

  /// Mono Loopback
  monoLoopback,

  /// Stereo Loopback
  stereoLoopback,

  /// Earphone-to-Mic (акустическое сопряжение)
  earphoneToMic,
}

/// Статус донгла
class DongleStatus {
  /// Подключён ли донгл
  final bool connected;

  /// Тип интерфейса
  final DongleInterfaceType interfaceType;

  /// Тип схемы (определяется по сопротивлению)
  final DongleType? dongleType;

  /// Измеренное сопротивление GND→MIC (омы)
  final int? measuredResistanceMic;

  /// Измеренное сопротивление L→GND (омы)
  final int? measuredResistanceLeft;

  /// Измеренное сопротивление R→GND (омы)
  final int? measuredResistanceRight;

  const DongleStatus({
    required this.connected,
    required this.interfaceType,
    this.dongleType,
    this.measuredResistanceMic,
    this.measuredResistanceLeft,
    this.measuredResistanceRight,
  });

  DongleStatus copyWith({
    bool? connected,
    DongleInterfaceType? interfaceType,
    DongleType? dongleType,
    int? measuredResistanceMic,
    int? measuredResistanceLeft,
    int? measuredResistanceRight,
  }) {
    return DongleStatus(
      connected: connected ?? this.connected,
      interfaceType: interfaceType ?? this.interfaceType,
      dongleType: dongleType ?? this.dongleType,
      measuredResistanceMic: measuredResistanceMic ?? this.measuredResistanceMic,
      measuredResistanceLeft:
          measuredResistanceLeft ?? this.measuredResistanceLeft,
      measuredResistanceRight:
          measuredResistanceRight ?? this.measuredResistanceRight,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'connected': connected,
      'interfaceType': interfaceType.name,
      if (dongleType != null) 'dongleType': dongleType!.name,
      if (measuredResistanceMic != null)
        'measuredResistanceMic': measuredResistanceMic,
      if (measuredResistanceLeft != null)
        'measuredResistanceLeft': measuredResistanceLeft,
      if (measuredResistanceRight != null)
        'measuredResistanceRight': measuredResistanceRight,
    };
  }

  /// Десериализация из JSON
  factory DongleStatus.fromJson(Map<String, dynamic> json) {
    return DongleStatus(
      connected: json['connected'] as bool? ?? false,
      interfaceType: DongleInterfaceType.values.firstWhere(
        (e) => e.name == json['interfaceType'],
        orElse: () => DongleInterfaceType.none,
      ),
      dongleType: json['dongleType'] != null
          ? DongleType.values.firstWhere((e) => e.name == json['dongleType'])
          : null,
      measuredResistanceMic: json['measuredResistanceMic'] as int?,
      measuredResistanceLeft: json['measuredResistanceLeft'] as int?,
      measuredResistanceRight: json['measuredResistanceRight'] as int?,
    );
  }

  /// Получить качество на основе типа интерфейса
  QualityLevel get quality {
    if (!connected) return QualityLevel.poor;

    switch (interfaceType) {
      case DongleInterfaceType.usbCWithDac:
        return QualityLevel.great; // ★★★★☆
      case DongleInterfaceType.usbCAudioAccessory:
        return QualityLevel.great; // ★★★★☆
      case DongleInterfaceType.trrs:
        return QualityLevel.good; // ★★★☆☆
      case DongleInterfaceType.none:
        return QualityLevel.poor;
    }
  }

  @override
  String toString() {
    return 'DongleStatus(connected: $connected, interface: $interfaceType, '
        'type: $dongleType)';
  }
}

/// Источник для получения статуса донгла
/// Интегрируется с vdd-dongles flow
abstract class IDongleSource {
  /// Получить статус донгла
  Future<DongleStatus> getStatus();

  /// Проверить подключение донгла
  Future<bool> isConnected();

  /// Определить тип донгла по сопротивлению
  Future<DongleType?> detectDongleType();
}

/// Реализация источника Dongle
class DongleSource implements IDongleSource {
  @override
  Future<DongleStatus> getStatus() async {
    try {
      // В реальной реализации - интеграция с vdd-dongles detector
      // Для现在 возвращаем заглушку
      return await _getDongleStatus();
    } catch (e) {
      debugPrint('DongleSource.getStatus error: $e');
      return const DongleStatus(
        connected: false,
        interfaceType: DongleInterfaceType.none,
      );
    }
  }

  @override
  Future<bool> isConnected() async {
    final status = await getStatus();
    return status.connected;
  }

  @override
  Future<DongleType?> detectDongleType() async {
    final status = await getStatus();
    return status.dongleType;
  }

  /// Получить статус метода для VoiceLineRepository
  Future<VoiceLineMethodStatus> getVoiceLineMethodStatus() async {
    final dongleStatus = await getStatus();

    return VoiceLineMethodStatus(
      method: VoiceLineMethod.dongle,
      available: dongleStatus.connected,
      quality: dongleStatus.quality,
      reasonUnavailable: dongleStatus.connected ? null : 'No dongle detected',
      details: dongleStatus.toJson(),
    );
  }

  // Заглушка для получения статуса
  Future<DongleStatus> _getDongleStatus() async {
    // В реальной реализации - integration с vdd-dongles
    // Проверка USB Host mode, Headset state, и т.д.
    debugPrint('DongleSource: checking dongle status...');
    return const DongleStatus(
      connected: false,
      interfaceType: DongleInterfaceType.none,
    );
  }
}
