import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import '../models/gateway_config.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final Logger _logger = Logger();

  static const String _configKey = 'gateway_config';
  static const String _isFirstRunKey = 'is_first_run';
  static const String _autoLoginKey = 'auto_login';
  static const String _logsKey = 'gateway_logs';
  static const String _languageKey = 'app_language';

  Future<void> saveConfig(GatewayConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = config.toJson();
    await prefs.setString(_configKey, jsonEncode(configJson));
  }

  Future<GatewayConfig?> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final configString = prefs.getString(_configKey);
    
    if (configString == null) return null;
    
    try {
      final configJson = jsonDecode(configString) as Map<String, dynamic>;
      return GatewayConfig.fromJson(configJson);
    } catch (e) {
      _logger.e('Error loading config: $e');
      return null;
    }
  }

  Future<GatewayConfig> getConfig() async {
    final config = await loadConfig();
    return config ?? GatewayConfig.defaultConfig();
  }

  Future<void> saveAutoLogin(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoLoginKey, enabled);
  }

  Future<bool> getAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoLoginKey) ?? false;
  }

  Future<bool> isFirstRun() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isFirstRunKey) ?? true;
  }

  Future<void> setFirstRunComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isFirstRunKey, false);
  }

  Future<void> saveLogs(List<String> logs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_logsKey, logs);
  }

  Future<List<String>> loadLogs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_logsKey) ?? [];
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logsKey);
  }

  Future<void> addLog(String log) async {
    final logs = await loadLogs();
    logs.add(log);
    
    // Keep only last 1000 logs
    if (logs.length > 1000) {
      logs.removeRange(0, logs.length - 1000);
    }
    
    await saveLogs(logs);
  }

  Future<void> clearAllData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  Future<void> saveLanguage(String languageCode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, languageCode);
  }

  Future<String> getLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_languageKey) ?? 'en';
  }

  Future<void> setLanguage(String languageCode) async {
    await saveLanguage(languageCode);
  }
} 