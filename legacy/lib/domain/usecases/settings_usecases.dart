import '../../data/repositories/settings_repository.dart';

/// Use cases для работы с настройками
class SettingsUseCases {
  final SettingsRepository _repository;

  SettingsUseCases(this._repository);

  /// Получение настроек
  Future<Map<String, dynamic>?> getSettings() async {
    return await _repository.getSettings();
  }

  /// Сохранение настроек
  Future<bool> saveSettings(Map<String, dynamic> settings) async {
    return await _repository.saveSettings(settings);
  }
}
