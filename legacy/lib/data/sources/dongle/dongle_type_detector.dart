import 'package:flutter/foundation.dart';
import '../../domain/models/dongle_type.dart';
import '../../domain/models/resistance_measurements.dart';
import 'resistance_meter.dart';

/// Детектор типа донгла (implementation)
class DongleTypeDetectorImpl {
  final IResistanceMeter _resistanceMeter;

  DongleTypeDetectorImpl({
    IResistanceMeter? resistanceMeter,
  }) : _resistanceMeter = resistanceMeter ?? ResistanceMeter();

  /// Определить тип донгла
  Future<DongleType?> detectType() async {
    try {
      final measurements = await _resistanceMeter.measureAll();

      if (measurements.error != null) {
        debugPrint('DongleTypeDetector: measurement error: ${measurements.error}');
        return null;
      }

      return measurements.detectType();
    } catch (e) {
      debugPrint('DongleTypeDetector.detectType error: $e');
      return null;
    }
  }

  /// Получить измерения и тип
  Future<DongleTypeDetectionResult> detectWithMeasurements() async {
    try {
      final measurements = await _resistanceMeter.measureAll();
      final type = measurements.detectType();

      return DongleTypeDetectionResult(
        measurements: measurements,
        detectedType: type,
        confidence: type != null ? measurements.getConfidence(type) : 0.0,
      );
    } catch (e) {
      debugPrint('DongleTypeDetector.detectWithMeasurements error: $e');
      return DongleTypeDetectionResult(
        measurements: const ResistanceMeasurements(
          error: 'Detection failed',
        ),
        detectedType: null,
        confidence: 0.0,
      );
    }
  }

  /// Проверить возможность определения
  Future<bool> canDetect() async {
    return await _resistanceMeter.canMeasure();
  }
}

/// Результат определения типа донгла
class DongleTypeDetectionResult {
  final ResistanceMeasurements measurements;
  final DongleType? detectedType;
  final double confidence;

  const DongleTypeDetectionResult({
    required this.measurements,
    this.detectedType,
    this.confidence = 0.0,
  });

  /// Успешно ли определение
  bool get success => detectedType != null && confidence > 0.5;

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'measurements': measurements.toJson(),
      'detectedType': detectedType?.toJson(),
      'confidence': confidence,
      'success': success,
    };
  }

  @override
  String toString() {
    return 'DongleTypeDetectionResult(type: $detectedType, '
        'confidence: ${(confidence * 100).toStringAsFixed(1)}%, '
        'success: $success)';
  }
}

/// Extension для интерпретации результатов измерений
extension ResistanceInterpretation on ResistanceMeasurements {
  /// Интерпретировать измерения
  String interpret() {
    if (error != null) return 'Measurement error: $error';

    final gndToMicStr = gndToMic.format();
    final leftToGndStr = leftToGnd.format();
    final rightToGndStr = rightToGnd.format();

    return 'GND→MIC: $gndToMicStr, L→GND: $leftToGndStr, R→GND: $rightToGndStr';
  }

  /// Соответствует ли Differential (4R+1C)?
  bool get isDifferential {
    return gndToMic.isInRange(10000) && leftToGnd.isInRange(15000);
  }

  /// Соответствует ли Mono Loopback?
  bool get isMonoLoopback {
    return gndToMic.isInRange(1800) && leftToGnd.isInRange(100000);
  }

  /// Соответствует ли Stereo Loopback?
  bool get isStereoLoopback {
    return gndToMic.isInRange(1800) && leftToGnd.isInfinite;
  }

  /// Соответствует ли Earphone-to-Mic?
  bool get isEarphoneToMic {
    return gndToMic.isInRange(10000) && leftToGnd.isInfinite;
  }
}
