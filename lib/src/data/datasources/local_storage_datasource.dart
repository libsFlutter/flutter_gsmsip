/// Источник данных для локального хранения
/// Использует SharedPreferences для хранения настроек
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/gateway_config_model.dart';

abstract class LocalStorageDataSource {
  Future<void> saveConfig(GatewayConfigModel config);
  Future<GatewayConfigModel?> getConfig();
  Future<void> saveLogs(List<String> logs);
  Future<List<String>> getLogs();
  Future<void> clearLogs();
  Future<void> saveLanguage(String languageCode);
  Future<String> getLanguage();
  Future<void> saveThemeMode(String themeMode);
  Future<String> getThemeMode();
}

class LocalStorageDataSourceImpl implements LocalStorageDataSource {
  static const String _configKey = 'gateway_config';
  static const String _logsKey = 'gateway_logs';
  static const String _languageKey = 'app_language';
  static const String _themeModeKey = 'app_theme_mode';
  static const String _isFirstRunKey = 'is_first_run';

  @override
  Future<void> saveConfig(GatewayConfigModel config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = config.toJsonString();
      await prefs.setString(_configKey, configJson);
    } catch (e) {
      throw Exception('Failed to save config: $e');
    }
  }

  @override
  Future<GatewayConfigModel?> getConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configKey);
      
      if (configString == null) return null;
      
      return GatewayConfigModel.fromJsonString(configString);
    } catch (e) {
      throw Exception('Failed to load config: $e');
    }
  }

  @override
  Future<void> saveLogs(List<String> logs) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsJson = jsonEncode(logs);
      await prefs.setString(_logsKey, logsJson);
    } catch (e) {
      throw Exception('Failed to save logs: $e');
    }
  }

  @override
  Future<List<String>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final logsString = prefs.getString(_logsKey);
      
      if (logsString == null) return [];
      
      final logsList = jsonDecode(logsString) as List<dynamic>;
      return logsList.cast<String>();
    } catch (e) {
      throw Exception('Failed to load logs: $e');
    }
  }

  @override
  Future<void> clearLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_logsKey);
    } catch (e) {
      throw Exception('Failed to clear logs: $e');
    }
  }

  @override
  Future<void> saveLanguage(String languageCode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (e) {
      throw Exception('Failed to save language: $e');
    }
  }

  @override
  Future<String> getLanguage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_languageKey) ?? 'en';
    } catch (e) {
      throw Exception('Failed to get language: $e');
    }
  }

  @override
  Future<void> saveThemeMode(String themeMode) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_themeModeKey, themeMode);
    } catch (e) {
      throw Exception('Failed to save theme mode: $e');
    }
  }

  @override
  Future<String> getThemeMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_themeModeKey) ?? 'system';
    } catch (e) {
      throw Exception('Failed to get theme mode: $e');
    }
  }

  Future<bool> isFirstRun() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_isFirstRunKey) ?? true;
    } catch (e) {
      return true;
    }
  }

  Future<void> setFirstRunComplete() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_isFirstRunKey, false);
    } catch (e) {
      // Игнорируем ошибки
    }
  }
}
