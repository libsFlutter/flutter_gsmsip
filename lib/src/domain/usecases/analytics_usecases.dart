import '../../data/repositories/analytics_repository.dart';

/// Use cases для работы с аналитикой
class AnalyticsUseCases {
  final AnalyticsRepository _repository;

  AnalyticsUseCases(this._repository);

  /// Отправка аналитических данных
  Future<bool> sendAnalytics(Map<String, dynamic> data) async {
    return await _repository.sendAnalytics(data);
  }

  /// Получение аналитических данных
  Future<Map<String, dynamic>?> getAnalytics() async {
    return await _repository.getAnalytics();
  }
}
