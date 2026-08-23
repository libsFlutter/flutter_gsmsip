/// Модель информации об устройстве
class DeviceInfo {
  final String? deviceId;
  final String? deviceModel;
  final String osVersion;
  final String platform;
  final bool isPhysicalDevice;
  final Map<String, dynamic> additionalInfo;

  DeviceInfo({
    this.deviceId,
    this.deviceModel,
    required this.osVersion,
    required this.platform,
    required this.isPhysicalDevice,
    this.additionalInfo = const {},
  });

  /// Создание из JSON
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      deviceId: json['deviceId'] as String?,
      deviceModel: json['deviceModel'] as String?,
      osVersion: json['osVersion'] as String,
      platform: json['platform'] as String,
      isPhysicalDevice: json['isPhysicalDevice'] as bool,
      additionalInfo: json['additionalInfo'] as Map<String, dynamic>? ?? {},
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'deviceId': deviceId,
      'deviceModel': deviceModel,
      'osVersion': osVersion,
      'platform': platform,
      'isPhysicalDevice': isPhysicalDevice,
      'additionalInfo': additionalInfo,
    };
  }

  /// Копирование с изменениями
  DeviceInfo copyWith({
    String? deviceId,
    String? deviceModel,
    String? osVersion,
    String? platform,
    bool? isPhysicalDevice,
    Map<String, dynamic>? additionalInfo,
  }) {
    return DeviceInfo(
      deviceId: deviceId ?? this.deviceId,
      deviceModel: deviceModel ?? this.deviceModel,
      osVersion: osVersion ?? this.osVersion,
      platform: platform ?? this.platform,
      isPhysicalDevice: isPhysicalDevice ?? this.isPhysicalDevice,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo{deviceId: $deviceId, deviceModel: $deviceModel, osVersion: $osVersion, platform: $platform}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DeviceInfo && other.deviceId == deviceId;
  }

  @override
  int get hashCode => deviceId.hashCode;
}
