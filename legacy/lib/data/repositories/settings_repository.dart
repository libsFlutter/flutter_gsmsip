import 'package:logger/logger.dart';
import '../datasources/local/local_data_source.dart';
import '../datasources/remote/remote_data_source.dart';

/// Репозиторий для работы с настройками
class SettingsRepository {
  final LocalDataSource _localDataSource;
  final RemoteDataSource _remoteDataSource;
  final Logger _logger;

  SettingsRepository(
    this._localDataSource,
    this._remoteDataSource,
    this._logger,
  );

  /// Получение настроек
  Future<Map<String, dynamic>?> getSettings() async {
    try {
      _logger.d('Getting settings...');
      
      final localData = _localDataSource.getData('app_settings');
      if (localData != null) {
        _logger.d('Settings found in local storage');
        return localData;
      }

      if (_remoteDataSource.isNetworkAvailable) {
        final remoteData = await _remoteDataSource.getData('/api/settings');
        if (remoteData != null) {
          await _localDataSource.saveData('app_settings', remoteData);
          _logger.d('Settings retrieved from remote and saved locally');
          return remoteData;
        }
      }

      _logger.w('Settings not found');
      return null;
    } catch (e) {
      _logger.e('Failed to get settings', error: e);
      return null;
    }
  }

  /// Сохранение настроек
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    try {
      _logger.d('Saving settings...');
      
      bool success = true;

      final localSuccess = await _localDataSource.saveData('app_settings', settings);
      if (!localSuccess) {
        _logger.w('Failed to save settings locally');
        success = false;
      }

      if (_remoteDataSource.isNetworkAvailable) {
        final remoteSuccess = await _remoteDataSource.postData('/api/settings', settings);
        if (remoteSuccess == null) {
          _logger.w('Failed to save settings remotely');
          success = false;
        }
      } else {
        _logger.w('Network not available, skipping remote save');
      }

      return success;
    } catch (e) {
      _logger.e('Failed to save settings', error: e);
      return false;
    }
  }
}
