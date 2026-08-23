import '../domain/models/voice_line_method.dart';
import '../domain/models/dongle_status.dart';

class LineInfo {
  final String id;
  final String phoneNumber;
  final String imei;
  final String operator;
  final String technology; // 2G/3G/4G/5G
  final String status; // active/inactive/calling
  final int signalLevel; // 0-100
  final String lac;
  final String cellId;
  final double balance;
  final String currency;
  final DateTime lastBalanceUpdate;
  final bool isPhysical; // true for physical SIM, false for eSIM
  final int slotNumber; // -1 for eSIM
  final bool supportsDataDuringCall;
  final bool supportsDataFromCallNumber;
  final bool canChangeImei;
  final bool canRecordVoiceToRadio;
  final bool canGetVoiceFromRadio;
  final bool canWriteToVoiceCommunication;
  
  /// Текущий метод доступа к голосовой линии
  final VoiceLineMethod? currentVoiceLineMethod;

  /// Доступные методы доступа
  final List<VoiceLineMethod> availableVoiceLineMethods;

  /// Статус донгла (если подключён)
  final DongleStatus? dongleStatus;

  LineInfo({
    required this.id,
    required this.phoneNumber,
    required this.imei,
    required this.operator,
    required this.technology,
    required this.status,
    required this.signalLevel,
    required this.lac,
    required this.cellId,
    required this.balance,
    required this.currency,
    required this.lastBalanceUpdate,
    required this.isPhysical,
    required this.slotNumber,
    required this.supportsDataDuringCall,
    required this.supportsDataFromCallNumber,
    required this.canChangeImei,
    required this.canRecordVoiceToRadio,
    required this.canGetVoiceFromRadio,
    required this.canWriteToVoiceCommunication,
    this.currentVoiceLineMethod,
    this.availableVoiceLineMethods = const [],
    this.dongleStatus,
  });

  factory LineInfo.fromJson(Map<String, dynamic> json) {
    return LineInfo(
      id: json['id'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      imei: json['imei'] ?? '',
      operator: json['operator'] ?? '',
      technology: json['technology'] ?? '2G',
      status: json['status'] ?? 'inactive',
      signalLevel: json['signalLevel'] ?? 0,
      lac: json['lac'] ?? '',
      cellId: json['cellId'] ?? '',
      balance: (json['balance'] ?? 0.0).toDouble(),
      currency: json['currency'] ?? 'USD',
      lastBalanceUpdate: DateTime.parse(json['lastBalanceUpdate'] ?? DateTime.now().toIso8601String()),
      isPhysical: json['isPhysical'] ?? true,
      slotNumber: json['slotNumber'] ?? 0,
      supportsDataDuringCall: json['supportsDataDuringCall'] ?? false,
      supportsDataFromCallNumber: json['supportsDataFromCallNumber'] ?? false,
      canChangeImei: json['canChangeImei'] ?? false,
      canRecordVoiceToRadio: json['canRecordVoiceToRadio'] ?? false,
      canGetVoiceFromRadio: json['canGetVoiceFromRadio'] ?? false,
      canWriteToVoiceCommunication: json['canWriteToVoiceCommunication'] ?? false,
      currentVoiceLineMethod: VoiceLineMethodExtension.fromJson(
          json['currentVoiceLineMethod'] as String?),
      availableVoiceLineMethods: (json['availableVoiceLineMethods'] as List?)
              ?.map((e) => VoiceLineMethodExtension.fromJson(e as String) ??
                  VoiceLineMethod.acoustic)
              .toList() ??
          [],
      dongleStatus: json['dongleStatus'] != null
          ? DongleStatus.fromJson(json['dongleStatus'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'phoneNumber': phoneNumber,
      'imei': imei,
      'operator': operator,
      'technology': technology,
      'status': status,
      'signalLevel': signalLevel,
      'lac': lac,
      'cellId': cellId,
      'balance': balance,
      'currency': currency,
      'lastBalanceUpdate': lastBalanceUpdate.toIso8601String(),
      'isPhysical': isPhysical,
      'slotNumber': slotNumber,
      'supportsDataDuringCall': supportsDataDuringCall,
      'supportsDataFromCallNumber': supportsDataFromCallNumber,
      'canChangeImei': canChangeImei,
      'canRecordVoiceToRadio': canRecordVoiceToRadio,
      'canGetVoiceFromRadio': canGetVoiceFromRadio,
      'canWriteToVoiceCommunication': canWriteToVoiceCommunication,
      'currentVoiceLineMethod': currentVoiceLineMethod?.toJson(),
      'availableVoiceLineMethods':
          availableVoiceLineMethods.map((e) => e.toJson()).toList(),
      if (dongleStatus != null) 'dongleStatus': dongleStatus!.toJson(),
    };
  }

  LineInfo copyWith({
    String? id,
    String? phoneNumber,
    String? imei,
    String? operator,
    String? technology,
    String? status,
    int? signalLevel,
    String? lac,
    String? cellId,
    double? balance,
    String? currency,
    DateTime? lastBalanceUpdate,
    bool? isPhysical,
    int? slotNumber,
    bool? supportsDataDuringCall,
    bool? supportsDataFromCallNumber,
    bool? canChangeImei,
    bool? canRecordVoiceToRadio,
    bool? canGetVoiceFromRadio,
    bool? canWriteToVoiceCommunication,
    VoiceLineMethod? currentVoiceLineMethod,
    List<VoiceLineMethod>? availableVoiceLineMethods,
    DongleStatus? dongleStatus,
  }) {
    return LineInfo(
      id: id ?? this.id,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      imei: imei ?? this.imei,
      operator: operator ?? this.operator,
      technology: technology ?? this.technology,
      status: status ?? this.status,
      signalLevel: signalLevel ?? this.signalLevel,
      lac: lac ?? this.lac,
      cellId: cellId ?? this.cellId,
      balance: balance ?? this.balance,
      currency: currency ?? this.currency,
      lastBalanceUpdate: lastBalanceUpdate ?? this.lastBalanceUpdate,
      isPhysical: isPhysical ?? this.isPhysical,
      slotNumber: slotNumber ?? this.slotNumber,
      supportsDataDuringCall: supportsDataDuringCall ?? this.supportsDataDuringCall,
      supportsDataFromCallNumber: supportsDataFromCallNumber ?? this.supportsDataFromCallNumber,
      canChangeImei: canChangeImei ?? this.canChangeImei,
      canRecordVoiceToRadio: canRecordVoiceToRadio ?? this.canRecordVoiceToRadio,
      canGetVoiceFromRadio: canGetVoiceFromRadio ?? this.canGetVoiceFromRadio,
      canWriteToVoiceCommunication: canWriteToVoiceCommunication ?? this.canWriteToVoiceCommunication,
      currentVoiceLineMethod: currentVoiceLineMethod ?? this.currentVoiceLineMethod,
      availableVoiceLineMethods: availableVoiceLineMethods ?? this.availableVoiceLineMethods,
      dongleStatus: dongleStatus ?? this.dongleStatus,
    );
  }
} 