import 'package:flutter/foundation.dart';
import '../../../domain/models/resistance_measurements.dart';

/// Измеритель сопротивлений для определения типа донгла
abstract class IResistanceMeter {
  /// Измерить сопротивление GND → MIC
  Future<int?> measureGndToMic();

  /// Измерить сопротивление L → GND
  Future<int?> measureLeftToGnd();

  /// Измерить сопротивление R → GND
  Future<int?> measureRightToGnd();

  /// Измерить сопротивление L → MIC
  Future<int?> measureLeftToMic();

  /// Измерить все сопротивления
  Future<ResistanceMeasurements> measureAll();

  /// Проверить возможность измерения
  Future<bool> canMeasure();
}

/// Реализация измерителя сопротивлений
class ResistanceMeter implements IResistanceMeter {
  @override
  Future<int?> measureGndToMic() async {
    try {
      if (!await canMeasure()) return null;
      return await _measureResistance('GND', 'MIC');
    } catch (e) {
      debugPrint('ResistanceMeter.measureGndToMic error: $e');
      return null;
    }
  }

  @override
  Future<int?> measureLeftToGnd() async {
    try {
      if (!await canMeasure()) return null;
      return await _measureResistance('L', 'GND');
    } catch (e) {
      debugPrint('ResistanceMeter.measureLeftToGnd error: $e');
      return null;
    }
  }

  @override
  Future<int?> measureRightToGnd() async {
    try {
      if (!await canMeasure()) return null;
      return await _measureResistance('R', 'GND');
    } catch (e) {
      debugPrint('ResistanceMeter.measureRightToGnd error: $e');
      return null;
    }
  }

  @override
  Future<int?> measureLeftToMic() async {
    try {
      if (!await canMeasure()) return null;
      return await _measureResistance('L', 'MIC');
    } catch (e) {
      debugPrint('ResistanceMeter.measureLeftToMic error: $e');
      return null;
    }
  }

  @override
  Future<ResistanceMeasurements> measureAll() async {
    try {
      if (!await canMeasure()) {
        return const ResistanceMeasurements(
          error: 'Cannot measure resistance',
        );
      }

      final gndToMic = await measureGndToMic();
      final leftToGnd = await measureLeftToGnd();
      final rightToGnd = await measureRightToGnd();
      final leftToMic = await measureLeftToMic();

      return ResistanceMeasurements(
        gndToMic: gndToMic,
        leftToGnd: leftToGnd,
        rightToGnd: rightToGnd,
        leftToMic: leftToMic,
      );
    } catch (e) {
      debugPrint('ResistanceMeter.measureAll error: $e');
      return ResistanceMeasurements(
        error: 'Measurement failed: $e',
      );
    }
  }

  @override
  Future<bool> canMeasure() async {
    try {
      // В реальной реализации - проверка возможности измерения
      // через platform channel
      return await _checkMeasurementCapability();
    } catch (e) {
      debugPrint('ResistanceMeter.canMeasure error: $e');
      return false;
    }
  }

  /// Измерение сопротивления между двумя точками
  Future<int> _measureResistance(String from, String to) async {
    // В реальной реализации - platform channel для измерения
    // Пример:
    // final result = await platformChannel.invokeMethod(
    //   'measureResistance',
    //   {'from': from, 'to': to},
    // );
    // return result as int?;
    debugPrint('ResistanceMeter: measuring $from → $to...');
    return -1; // Заглушка (∞)
  }

  /// Проверка возможности измерения
  Future<bool> _checkMeasurementCapability() async {
    // В реальной реализации - platform channel
    // Проверка наличия HID interface или другого метода измерения
    debugPrint('ResistanceMeter: checking measurement capability...');
    return false; // Заглушка
  }
}

/// Расширение для форматирования значений сопротивлений
extension ResistanceValueExtension on int? {
  /// Форматированное представление сопротивления
  String format() {
    if (this == null) return 'N/A';
    if (this == -1) return '∞';
    if (this! >= 1000000) return '${(this! / 1000000).toStringAsFixed(1)}MΩ';
    if (this! >= 1000) return '${(this! / 1000).toStringAsFixed(1)}kΩ';
    return '${this}Ω';
  }

  /// Это бесконечность (обрыв)?
  bool get isInfinite => this == null || this == -1 || this! > 1000000;

  /// Это в диапазоне?
  bool isInRange(int target, {double tolerance = 0.2}) {
    if (this == null || isInfinite) return false;
    final min = target * (1 - tolerance);
    final max = target * (1 + tolerance);
    return this! >= min && this! <= max;
  }
}
