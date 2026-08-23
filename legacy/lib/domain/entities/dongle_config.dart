import 'package:equatable/equatable.dart';
import '../models/dongle_interface_type.dart';
import '../models/dongle_type.dart';

/// Конфигурация донгла (адаптера)
class DongleConfig extends Equatable {
  /// Тип интерфейса
  final DongleInterfaceType interfaceType;

  /// Тип схемы донгла
  final DongleType? dongleType;

  /// Инверсия правого канала (для differential signaling)
  final bool enableInversion;

  /// Уровень выходного сигнала (0-100)
  final int? outputVolume;

  /// Частота дискретизации (Гц)
  final int? sampleRate;

  /// Разрядность (бит)
  final int? bitDepth;

  /// Автоматическое определение типа
  final bool autoDetectType;

  const DongleConfig({
    required this.interfaceType,
    this.dongleType,
    this.enableInversion = true,
    this.outputVolume,
    this.sampleRate,
    this.bitDepth,
    this.autoDetectType = true,
  });

  DongleConfig copyWith({
    DongleInterfaceType? interfaceType,
    DongleType? dongleType,
    bool? enableInversion,
    int? outputVolume,
    int? sampleRate,
    int? bitDepth,
    bool? autoDetectType,
  }) {
    return DongleConfig(
      interfaceType: interfaceType ?? this.interfaceType,
      dongleType: dongleType ?? this.dongleType,
      enableInversion: enableInversion ?? this.enableInversion,
      outputVolume: outputVolume ?? this.outputVolume,
      sampleRate: sampleRate ?? this.sampleRate,
      bitDepth: bitDepth ?? this.bitDepth,
      autoDetectType: autoDetectType ?? this.autoDetectType,
    );
  }

  @override
  List<Object?> get props => [
        interfaceType,
        dongleType,
        enableInversion,
        outputVolume,
        sampleRate,
        bitDepth,
        autoDetectType,
      ];

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'interfaceType': interfaceType.toJson(),
      if (dongleType != null) 'dongleType': dongleType!.toJson(),
      'enableInversion': enableInversion,
      if (outputVolume != null) 'outputVolume': outputVolume,
      if (sampleRate != null) 'sampleRate': sampleRate,
      if (bitDepth != null) 'bitDepth': bitDepth,
      'autoDetectType': autoDetectType,
    };
  }

  /// Десериализация из JSON
  factory DongleConfig.fromJson(Map<String, dynamic> json) {
    return DongleConfig(
      interfaceType: DongleInterfaceTypeExtension.fromJson(
            json['interfaceType'] as String?,
          ) ??
          DongleInterfaceType.none,
      dongleType: DongleTypeExtension.fromJson(
        json['dongleType'] as String?,
      ),
      enableInversion: json['enableInversion'] as bool? ?? true,
      outputVolume: json['outputVolume'] as int?,
      sampleRate: json['sampleRate'] as int?,
      bitDepth: json['bitDepth'] as int?,
      autoDetectType: json['autoDetectType'] as bool? ?? true,
    );
  }

  /// Конфигурация по умолчанию
  static const defaultConfig = DongleConfig(
    interfaceType: DongleInterfaceType.none,
    enableInversion: true,
    autoDetectType: true,
  );

  /// Конфигурация для USB-C with DAC
  static const usbDacConfig = DongleConfig(
    interfaceType: DongleInterfaceType.usbCWithDac,
    enableInversion: true,
    sampleRate: 48000,
    bitDepth: 16,
  );

  /// Конфигурация для USB-C Audio Accessory
  static const usbAccessoryConfig = DongleConfig(
    interfaceType: DongleInterfaceType.usbCAudioAccessory,
    enableInversion: true,
    sampleRate: 48000,
    bitDepth: 16,
  );

  /// Конфигурация для TRRS
  static const trrsConfig = DongleConfig(
    interfaceType: DongleInterfaceType.trrs,
    enableInversion: true,
    autoDetectType: true,
  );
}
