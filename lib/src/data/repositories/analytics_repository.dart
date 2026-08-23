import 'package:logger/logger.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';

/// Репозиторий для работы с аналитикой
class AnalyticsRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final Logger _logger;

  AnalyticsRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._logger,
  );

  /// Отправка аналитических данных
  Future<bool> sendAnalytics(Map<String, dynamic> data) async {
    try {
      _logger.d('Sending analytics data...');
      
      if (_remoteDataSource.isNetworkAvailable) {
        final success = await _remoteDataSource.postData('/api/analytics', data);
        if (success != null) {
          _logger.d('Analytics data sent successfully');
          return true;
        } else {
          _logger.w('Failed to send analytics data remotely');
          // Сохраняем локально для последующей отправки
          await _localDataSource.saveData('pending_analytics', data);
          return false;
        }
      } else {
        _logger.w('Network not available, saving analytics locally');
        await _localDataSource.saveData('pending_analytics', data);
        return false;
      }
    } catch (e) {
      _logger.e('Failed to send analytics data', error: e);
      return false;
    }
  }

  /// Получение аналитических данных
  Future<Map<String, dynamic>?> getAnalytics() async {
    try {
      _logger.d('Getting analytics data...');
      
      if (_remoteDataSource.isNetworkAvailable) {
        final data = await _remoteDataSource.getData('/api/analytics');
        if (data != null) {
          _logger.d('Analytics data retrieved successfully');
          return data;
        }
      }

      _logger.w('Analytics data not available');
      return null;
    } catch (e) {
      _logger.e('Failed to get analytics data', error: e);
      return null;
    }
  }
}
