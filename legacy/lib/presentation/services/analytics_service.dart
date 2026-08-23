import 'package:logger/logger.dart';
import 'api_service.dart';
import '../../domain/usecases/analytics_usecases.dart';

/// Сервис для работы с аналитикой
class AnalyticsService {
  final ApiService _apiService;
  final StorageService _storageService;
  final AnalyticsUseCases _analyticsUseCases;
  final Logger _logger;

  AnalyticsService(
    this._apiService,
    this._storageService,
    this._analyticsUseCases,
    this._logger,
  );

  /// Инициализация сервиса
  Future<void> initialize() async {
    try {
      _logger.i('Initializing analytics service...');
      
      // Отправляем событие инициализации
      await _analyticsUseCases.sendAnalytics({
        'event': 'analytics_service_initialized',
        'timestamp': DateTime.now().toIso8601String(),
        'version': '3.0.0',
      });
      
      _logger.i('Analytics service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize analytics service', error: e);
      rethrow;
    }
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      _logger.i('Disposing analytics service...');
      
      // Отправляем событие завершения работы
      await _analyticsUseCases.sendAnalytics({
        'event': 'analytics_service_disposed',
        'timestamp': DateTime.now().toIso8601String(),
      });
      
      _logger.i('Analytics service disposed successfully');
    } catch (e) {
      _logger.e('Failed to dispose analytics service', error: e);
    }
  }
}
