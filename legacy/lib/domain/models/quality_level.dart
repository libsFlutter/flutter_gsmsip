/// Уровень качества метода доступа к линии
enum QualityLevel {
  excellent,  // ★★★★★
  great,      // ★★★★☆
  good,       // ★★★☆☆
  fair,       // ★★☆☆☆
  poor,       // ★☆☆☆☆
}

extension QualityLevelExtension on QualityLevel {
  /// Отображение качества звёздами
  String get stars {
    switch (this) {
      case QualityLevel.excellent:
        return '★★★★★';
      case QualityLevel.great:
        return '★★★★☆';
      case QualityLevel.good:
        return '★★★☆☆';
      case QualityLevel.fair:
        return '★★☆☆☆';
      case QualityLevel.poor:
        return '★☆☆☆☆';
    }
  }

  /// Текстовое описание
  String get description {
    switch (this) {
      case QualityLevel.excellent:
        return 'Excellent';
      case QualityLevel.great:
        return 'Great';
      case QualityLevel.good:
        return 'Good';
      case QualityLevel.fair:
        return 'Fair';
      case QualityLevel.poor:
        return 'Poor';
    }
  }

  /// Описание качества пути
  String get pathDescription {
    switch (this) {
      case QualityLevel.excellent:
        return 'Direct digital path, no loss';
      case QualityLevel.great:
        return 'High quality, minimal loss';
      case QualityLevel.good:
        return 'Acceptable for most calls';
      case QualityLevel.fair:
        return 'Noticeable quality loss';
      case QualityLevel.poor:
        return 'Usable but degraded';
    }
  }

  /// Числовое значение (0-4)
  int get value => index;

  /// Сериализация в JSON
  String toJson() => name;

  /// Десериализация из JSON
  static QualityLevel? fromJson(String? value) {
    if (value == null) return null;
    try {
      return QualityLevel.values.firstWhere((e) => e.name == value);
    } catch (e) {
      return null;
    }
  }

  /// Из числового значения
  static QualityLevel fromValue(int value) {
    if (value < 0 || value >= QualityLevel.values.length) {
      return QualityLevel.poor;
    }
    return QualityLevel.values[value];
  }
}
