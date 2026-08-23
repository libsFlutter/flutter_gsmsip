import 'package:flutter/foundation.dart';
import '../../../domain/models/voice_line_method.dart';
import '../../../domain/models/quality_level.dart';
import '../../../domain/models/voice_line_method_status.dart';

/// Источник для Telecom API (всегда доступен)
class TelecomApiSource {
  /// Telecom API всегда доступен на Android устройствах
  static const bool isAlwaysAvailable = true;

  /// Качество Telecom API - medium (good)
  static const QualityLevel defaultQuality = QualityLevel.good;

  /// Получить статус Telecom API
  Future<VoiceLineMethodStatus> getStatus() async {
    return const VoiceLineMethodStatus(
      method: VoiceLineMethod.telecomApi,
      available: true,
      quality: QualityLevel.good,
    );
  }

  /// Проверить доступность (всегда true)
  Future<bool> isAvailable() async {
    return true;
  }

  /// Получить качество
  QualityLevel getQuality() {
    return defaultQuality;
  }

  /// Получить описание
  String getDescription() {
    return 'Standard Android telephony API';
  }

  /// Получить преимущества
  List<String> getBenefits() {
    return [
      'Works on all Android devices',
      'No special permissions required',
      'No external hardware needed',
      'Standard Android API',
    ];
  }

  /// Получить ограничения
  List<String> getLimitations() {
    return [
      'Medium audio quality',
      'Uses device audio path',
      'Limited control over audio routing',
      'May have echo issues',
    ];
  }
}
