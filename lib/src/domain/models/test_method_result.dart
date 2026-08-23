import 'quality_level.dart';

/// Результат тестирования метода доступа к линии
class TestMethodResult {
  /// Успешно ли тестирование
  final bool success;

  /// Сообщение об ошибке (если есть)
  final String? error;

  /// Измеренные параметры
  final Map<String, dynamic> measurements;

  /// Уровень качества по результатам теста
  final QualityLevel quality;

  const TestMethodResult({
    required this.success,
    this.error,
    required this.measurements,
    required this.quality,
  });

  /// Создание копии с изменениями
  TestMethodResult copyWith({
    bool? success,
    String? error,
    Map<String, dynamic>? measurements,
    QualityLevel? quality,
  }) {
    return TestMethodResult(
      success: success ?? this.success,
      error: error ?? this.error,
      measurements: measurements ?? this.measurements,
      quality: quality ?? this.quality,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (error != null) 'error': error,
      'measurements': measurements,
      'quality': quality.toJson(),
    };
  }

  /// Десериализация из JSON
  factory TestMethodResult.fromJson(Map<String, dynamic> json) {
    return TestMethodResult(
      success: json['success'] ?? false,
      error: json['error'] as String?,
      measurements: json['measurements'] as Map<String, dynamic>? ?? {},
      quality: QualityLevelExtension.fromJson(json['quality'] as String?) ??
          QualityLevel.poor,
    );
  }

  /// Результат теста TX пути
  factory TestMethodResult.txTest({
    required double txLevel,
    required double latency,
    required bool passed,
  }) {
    return TestMethodResult(
      success: passed,
      error: passed ? null : 'TX path failed',
      measurements: {
        'txLevel': txLevel,
        'latency': latency,
        'txPassed': passed,
      },
      quality: passed ? QualityLevel.good : QualityLevel.poor,
    );
  }

  /// Результат теста RX пути
  factory TestMethodResult.rxTest({
    required double rxLevel,
    required double thd,
    required bool passed,
  }) {
    return TestMethodResult(
      success: passed,
      error: passed ? null : 'RX path failed',
      measurements: {
        'rxLevel': rxLevel,
        'thd': thd,
        'rxPassed': passed,
      },
      quality: passed ? QualityLevel.good : QualityLevel.poor,
    );
  }

  /// Полный результат теста
  factory TestMethodResult.fullTest({
    required double txLevel,
    required double rxLevel,
    required double latency,
    required double thd,
    required bool passed,
  }) {
    return TestMethodResult(
      success: passed,
      error: passed ? null : 'Full path test failed',
      measurements: {
        'txLevel': txLevel,
        'rxLevel': rxLevel,
        'latency': latency,
        'thd': thd,
        'passed': passed,
      },
      quality: passed ? QualityLevel.good : QualityLevel.poor,
    );
  }

  @override
  String toString() {
    return 'TestMethodResult(success: $success, quality: ${quality.description}'
        '${error != null ? ', error: $error' : ''})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TestMethodResult &&
        other.success == success &&
        other.quality == quality &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(success, quality, error);
}
