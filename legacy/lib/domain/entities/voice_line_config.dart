import 'package:equatable/equatable.dart';
import '../models/voice_line_method.dart';

/// Конфигурация системы доступа к голосовой линии
class VoiceLineConfig extends Equatable {
  /// Выбранный метод доступа (null = auto-select)
  final VoiceLineMethod? selectedMethod;

  /// Автоматический выбор метода
  final bool autoSelect;

  /// Путь к TTY порту (для TTY метода)
  final String? ttyPortPath;

  /// Скорость обмена TTY (по умолчанию 115200)
  final int ttyBaudRate;

  /// Инверсия правого канала (для differential signaling)
  final bool enableInversion;

  /// Подавление эха
  final bool enableEchoCancellation;

  /// Подавление шума
  final bool enableNoiseReduction;

  /// Автоматическая регулировка усиления
  final bool enableAutomaticGainControl;

  const VoiceLineConfig({
    this.selectedMethod,
    this.autoSelect = true,
    this.ttyPortPath,
    this.ttyBaudRate = 115200,
    this.enableInversion = true,
    this.enableEchoCancellation = true,
    this.enableNoiseReduction = false,
    this.enableAutomaticGainControl = false,
  });

  VoiceLineConfig copyWith({
    VoiceLineMethod? selectedMethod,
    bool? autoSelect,
    String? ttyPortPath,
    int? ttyBaudRate,
    bool? enableInversion,
    bool? enableEchoCancellation,
    bool? enableNoiseReduction,
    bool? enableAutomaticGainControl,
  }) {
    return VoiceLineConfig(
      selectedMethod: selectedMethod ?? this.selectedMethod,
      autoSelect: autoSelect ?? this.autoSelect,
      ttyPortPath: ttyPortPath ?? this.ttyPortPath,
      ttyBaudRate: ttyBaudRate ?? this.ttyBaudRate,
      enableInversion: enableInversion ?? this.enableInversion,
      enableEchoCancellation:
          enableEchoCancellation ?? this.enableEchoCancellation,
      enableNoiseReduction: enableNoiseReduction ?? this.enableNoiseReduction,
      enableAutomaticGainControl:
          enableAutomaticGainControl ?? this.enableAutomaticGainControl,
    );
  }

  @override
  List<Object?> get props => [
        selectedMethod,
        autoSelect,
        ttyPortPath,
        ttyBaudRate,
        enableInversion,
        enableEchoCancellation,
        enableNoiseReduction,
        enableAutomaticGainControl,
      ];

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'selectedMethod': selectedMethod?.toJson(),
      'autoSelect': autoSelect,
      'ttyPortPath': ttyPortPath,
      'ttyBaudRate': ttyBaudRate,
      'enableInversion': enableInversion,
      'enableEchoCancellation': enableEchoCancellation,
      'enableNoiseReduction': enableNoiseReduction,
      'enableAutomaticGainControl': enableAutomaticGainControl,
    };
  }

  /// Десериализация из JSON
  factory VoiceLineConfig.fromJson(Map<String, dynamic> json) {
    return VoiceLineConfig(
      selectedMethod: VoiceLineMethodExtension.fromJson(
          json['selectedMethod'] as String?),
      autoSelect: json['autoSelect'] ?? true,
      ttyPortPath: json['ttyPortPath'] as String?,
      ttyBaudRate: json['ttyBaudRate'] ?? 115200,
      enableInversion: json['enableInversion'] ?? true,
      enableEchoCancellation: json['enableEchoCancellation'] ?? true,
      enableNoiseReduction: json['enableNoiseReduction'] ?? false,
      enableAutomaticGainControl:
          json['enableAutomaticGainControl'] ?? false,
    );
  }

  /// Конфигурация по умолчанию
  static const defaultConfig = VoiceLineConfig();

  /// Конфигурация для TTY
  static const ttyConfig = VoiceLineConfig(
    selectedMethod: VoiceLineMethod.ttyPort,
    autoSelect: false,
    ttyBaudRate: 115200,
  );

  /// Конфигурация для Dongle
  static const dongleConfig = VoiceLineConfig(
    selectedMethod: VoiceLineMethod.dongle,
    autoSelect: false,
    enableInversion: true,
  );

  /// Конфигурация для Enhanced Mode
  static const enhancedConfig = VoiceLineConfig(
    selectedMethod: VoiceLineMethod.enhancedMode,
    autoSelect: false,
  );
}
