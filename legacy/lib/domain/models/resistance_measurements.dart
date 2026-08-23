import 'dongle_type.dart';

/// Измерения сопротивлений донгла
class ResistanceMeasurements {
  /// GND → MIC (омы)
  final int? gndToMic;

  /// L → GND (омы)
  final int? leftToGnd;

  /// R → GND (омы)
  final int? rightToGnd;

  /// L → MIC (омы)
  final int? leftToMic;

  /// Точность измерений (0.0 - 1.0)
  final double accuracy;

  /// Сообщение об ошибке измерения
  final String? error;

  const ResistanceMeasurements({
    this.gndToMic,
    this.leftToGnd,
    this.rightToGnd,
    this.leftToMic,
    this.accuracy = 1.0,
    this.error,
  });

  ResistanceMeasurements copyWith({
    int? gndToMic,
    int? leftToGnd,
    int? rightToGnd,
    int? leftToMic,
    double? accuracy,
    String? error,
  }) {
    return ResistanceMeasurements(
      gndToMic: gndToMic ?? this.gndToMic,
      leftToGnd: leftToGnd ?? this.leftToGnd,
      rightToGnd: rightToGnd ?? this.rightToGnd,
      leftToMic: leftToMic ?? this.leftToMic,
      accuracy: accuracy ?? this.accuracy,
      error: error ?? this.error,
    );
  }

  /// Определить тип донгла по измерениям
  DongleType? detectType() {
    if (error != null) return null;

    return DongleTypeDetector.detect(
      gndToMic: gndToMic,
      leftToGnd: leftToGnd,
      rightToGnd: rightToGnd,
      leftToMic: leftToMic,
    );
  }

  /// Получить уверенность определения
  double getConfidence(DongleType type) {
    return DongleTypeDetector.getConfidence(
      gndToMic: gndToMic,
      leftToGnd: leftToGnd,
      type: type,
    );
  }

  /// Все ли измерения получены
  bool get isComplete =>
      gndToMic != null && leftToGnd != null && rightToGnd != null;

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      if (gndToMic != null) 'gndToMic': gndToMic,
      if (leftToGnd != null) 'leftToGnd': leftToGnd,
      if (rightToGnd != null) 'rightToGnd': rightToGnd,
      if (leftToMic != null) 'leftToMic': leftToMic,
      'accuracy': accuracy,
      if (error != null) 'error': error,
    };
  }

  /// Десериализация из JSON
  factory ResistanceMeasurements.fromJson(Map<String, dynamic> json) {
    return ResistanceMeasurements(
      gndToMic: json['gndToMic'] as int?,
      leftToGnd: json['leftToGnd'] as int?,
      rightToGnd: json['rightToGnd'] as int?,
      leftToMic: json['leftToMic'] as int?,
      accuracy: json['accuracy'] as double? ?? 1.0,
      error: json['error'] as String?,
    );
  }

  /// Пустые измерения
  static const empty = ResistanceMeasurements();

  @override
  String toString() {
    return 'ResistanceMeasurements('
        'GND→MIC: ${gndToMic ?? "N/A"}, '
        'L→GND: ${leftToGnd ?? "N/A"}, '
        'R→GND: ${rightToGnd ?? "N/A"})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ResistanceMeasurements &&
        other.gndToMic == gndToMic &&
        other.leftToGnd == leftToGnd &&
        other.rightToGnd == rightToGnd &&
        other.leftToMic == leftToMic;
  }

  @override
  int get hashCode => Object.hash(gndToMic, leftToGnd, rightToGnd, leftToMic);
}

/// Результат измерения сопротивления
class ResistanceMeasurementResult {
  /// Успешно ли измерение
  final bool success;

  /// Измерения
  final ResistanceMeasurements measurements;

  /// Сообщение об ошибке
  final String? error;

  const ResistanceMeasurementResult({
    required this.success,
    required this.measurements,
    this.error,
  });

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'measurements': measurements.toJson(),
      if (error != null) 'error': error,
    };
  }

  /// Десериализация из JSON
  factory ResistanceMeasurementResult.fromJson(Map<String, dynamic> json) {
    return ResistanceMeasurementResult(
      success: json['success'] as bool? ?? false,
      measurements: ResistanceMeasurements.fromJson(
        json['measurements'] as Map<String, dynamic>,
      ),
      error: json['error'] as String?,
    );
  }
}
