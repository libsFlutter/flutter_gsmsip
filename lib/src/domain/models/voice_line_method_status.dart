import 'voice_line_method.dart';
import 'quality_level.dart';

/// Статус метода доступа к голосовой линии
class VoiceLineMethodStatus {
  /// Метод доступа
  final VoiceLineMethod method;

  /// Доступен ли метод
  final bool available;

  /// Уровень качества
  final QualityLevel quality;

  /// Причина недоступности (если есть)
  final String? reasonUnavailable;

  /// Дополнительные детали
  final Map<String, dynamic>? details;

  const VoiceLineMethodStatus({
    required this.method,
    required this.available,
    required this.quality,
    this.reasonUnavailable,
    this.details,
  });

  /// Создание копии с изменениями
  VoiceLineMethodStatus copyWith({
    VoiceLineMethod? method,
    bool? available,
    QualityLevel? quality,
    String? reasonUnavailable,
    Map<String, dynamic>? details,
  }) {
    return VoiceLineMethodStatus(
      method: method ?? this.method,
      available: available ?? this.available,
      quality: quality ?? this.quality,
      reasonUnavailable: reasonUnavailable ?? this.reasonUnavailable,
      details: details ?? this.details,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'method': method.toJson(),
      'available': available,
      'quality': quality.toJson(),
      if (reasonUnavailable != null)
        'reasonUnavailable': reasonUnavailable,
      if (details != null) 'details': details,
    };
  }

  /// Десериализация из JSON
  factory VoiceLineMethodStatus.fromJson(Map<String, dynamic> json) {
    return VoiceLineMethodStatus(
      method: VoiceLineMethodExtension.fromJson(json['method']) ??
          VoiceLineMethod.acoustic,
      available: json['available'] ?? false,
      quality: QualityLevelExtension.fromJson(json['quality']) ??
          QualityLevel.poor,
      reasonUnavailable: json['reasonUnavailable'] as String?,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  @override
  String toString() {
    return 'VoiceLineMethodStatus(method: ${method.displayName}, '
        'available: $available, quality: ${quality.stars})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is VoiceLineMethodStatus &&
        other.method == method &&
        other.available == available &&
        other.quality == quality &&
        other.reasonUnavailable == reasonUnavailable;
  }

  @override
  int get hashCode {
    return Object.hash(method, available, quality, reasonUnavailable);
  }
}
