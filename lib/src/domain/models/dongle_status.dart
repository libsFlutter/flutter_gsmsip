import 'dongle_interface_type.dart';
import 'dongle_type.dart';
import 'quality_level.dart';

/// Статус донгла (адаптера)
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

  /// Уровень качества
  final QualityLevel quality;

  /// Сообщение об ошибке или статусе
  final String? statusMessage;

  const DongleStatus({
    required this.connected,
    required this.interfaceType,
    this.dongleType,
    this.measuredResistanceMic,
    this.measuredResistanceLeft,
    this.measuredResistanceRight,
    this.quality = QualityLevel.poor,
    this.statusMessage,
  });

  DongleStatus copyWith({
    bool? connected,
    DongleInterfaceType? interfaceType,
    DongleType? dongleType,
    int? measuredResistanceMic,
    int? measuredResistanceLeft,
    int? measuredResistanceRight,
    QualityLevel? quality,
    String? statusMessage,
  }) {
    return DongleStatus(
      connected: connected ?? this.connected,
      interfaceType: interfaceType ?? this.interfaceType,
      dongleType: dongleType ?? this.dongleType,
      measuredResistanceMic: measuredResistanceMic ?? this.measuredResistanceMic,
      measuredResistanceLeft: measuredResistanceLeft ?? this.measuredResistanceLeft,
      measuredResistanceRight: measuredResistanceRight ?? this.measuredResistanceRight,
      quality: quality ?? this.quality,
      statusMessage: statusMessage ?? this.statusMessage,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'connected': connected,
      'interfaceType': interfaceType.toJson(),
      if (dongleType != null) 'dongleType': dongleType!.toJson(),
      if (measuredResistanceMic != null)
        'measuredResistanceMic': measuredResistanceMic,
      if (measuredResistanceLeft != null)
        'measuredResistanceLeft': measuredResistanceLeft,
      if (measuredResistanceRight != null)
        'measuredResistanceRight': measuredResistanceRight,
      'quality': quality.toJson(),
      if (statusMessage != null) 'statusMessage': statusMessage,
    };
  }

  /// Десериализация из JSON
  factory DongleStatus.fromJson(Map<String, dynamic> json) {
    return DongleStatus(
      connected: json['connected'] as bool? ?? false,
      interfaceType: DongleInterfaceTypeExtension.fromJson(
            json['interfaceType'] as String?,
          ) ??
          DongleInterfaceType.none,
      dongleType: DongleTypeExtension.fromJson(
        json['dongleType'] as String?,
      ),
      measuredResistanceMic: json['measuredResistanceMic'] as int?,
      measuredResistanceLeft: json['measuredResistanceLeft'] as int?,
      measuredResistanceRight: json['measuredResistanceRight'] as int?,
      quality: QualityLevelExtension.fromJson(json['quality'] as String?) ??
          QualityLevel.poor,
      statusMessage: json['statusMessage'] as String?,
    );
  }

  /// Получить качество на основе типа интерфейса и типа донгла
  static QualityLevel calculateQuality({
    required DongleInterfaceType interfaceType,
    DongleType? dongleType,
  }) {
    if (interfaceType == DongleInterfaceType.none) {
      return QualityLevel.poor;
    }

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
        'type: $dongleType, quality: ${quality.stars})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DongleStatus &&
        other.connected == connected &&
        other.interfaceType == interfaceType &&
        other.dongleType == dongleType;
  }

  @override
  int get hashCode => Object.hash(connected, interfaceType, dongleType);
}
