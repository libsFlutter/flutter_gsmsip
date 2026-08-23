import 'package:flutter/foundation.dart';
import '../../domain/entities/voice_line_config.dart';
import '../../domain/models/voice_line_method.dart';

/// Хранилище конфигурации VoiceLine
/// В реальной реализации будет использовать SharedPreferences или Hive
class VoiceLineConfigStorage {
  // In-memory storage for now
  VoiceLineMethod? _selectedMethod;
  bool _autoSelect = true;
  String? _ttyPortPath;
  int _ttyBaudRate = 115200;
  bool _enableInversion = true;
  bool _enableEchoCancellation = true;
  bool _enableNoiseReduction = false;
  bool _enableAutomaticGainControl = false;

  /// Загрузить конфигурацию
  Future<VoiceLineConfig> load() async {
    // В реальной реализации - загрузка из SharedPreferences
    debugPrint('VoiceLineConfigStorage: loading config...');
    
    return VoiceLineConfig(
      selectedMethod: _selectedMethod,
      autoSelect: _autoSelect,
      ttyPortPath: _ttyPortPath,
      ttyBaudRate: _ttyBaudRate,
      enableInversion: _enableInversion,
      enableEchoCancellation: _enableEchoCancellation,
      enableNoiseReduction: _enableNoiseReduction,
      enableAutomaticGainControl: _enableAutomaticGainControl,
    );
  }

  /// Сохранить конфигурацию
  Future<void> save(VoiceLineConfig config) async {
    // В реальной реализации - сохранение в SharedPreferences
    debugPrint('VoiceLineConfigStorage: saving config...');
    
    _selectedMethod = config.selectedMethod;
    _autoSelect = config.autoSelect;
    _ttyPortPath = config.ttyPortPath;
    _ttyBaudRate = config.ttyBaudRate;
    _enableInversion = config.enableInversion;
    _enableEchoCancellation = config.enableEchoCancellation;
    _enableNoiseReduction = config.enableNoiseReduction;
    _enableAutomaticGainControl = config.enableAutomaticGainControl;
  }

  /// Получить выбранный метод
  Future<VoiceLineMethod?> getSelectedMethod() async => _selectedMethod;

  /// Установить выбранный метод
  Future<void> setSelectedMethod(VoiceLineMethod method) async {
    _selectedMethod = method;
  }

  /// Получить путь к TTY порту
  Future<String?> getTtyPortPath() async => _ttyPortPath;

  /// Установить путь к TTY порту
  Future<void> setTtyPortPath(String path) async {
    _ttyPortPath = path;
  }

  /// Получить скорость обмена TTY
  Future<int> getTtyBaudRate() async => _ttyBaudRate;

  /// Установить скорость обмена TTY
  Future<void> setTtyBaudRate(int baudRate) async {
    _ttyBaudRate = baudRate;
  }

  /// Проверить включена ли инверсия
  Future<bool> isInversionEnabled() async => _enableInversion;

  /// Установить инверсию
  Future<void> setInversionEnabled(bool enabled) async {
    _enableInversion = enabled;
  }

  /// Сбросить к настройкам по умолчанию
  Future<void> reset() async {
    _selectedMethod = null;
    _autoSelect = true;
    _ttyPortPath = null;
    _ttyBaudRate = 115200;
    _enableInversion = true;
    _enableEchoCancellation = true;
    _enableNoiseReduction = false;
    _enableAutomaticGainControl = false;
  }

  /// Загрузить из JSON (для миграции)
  Future<void> loadFromJson(Map<String, dynamic> json) async {
    _selectedMethod = VoiceLineMethodExtension.fromJson(
      json['selectedMethod'] as String?,
    );
    _autoSelect = json['autoSelect'] as bool? ?? true;
    _ttyPortPath = json['ttyPortPath'] as String?;
    _ttyBaudRate = json['ttyBaudRate'] as int? ?? 115200;
    _enableInversion = json['enableInversion'] as bool? ?? true;
    _enableEchoCancellation =
        json['enableEchoCancellation'] as bool? ?? true;
    _enableNoiseReduction = json['enableNoiseReduction'] as bool? ?? false;
    _enableAutomaticGainControl =
        json['enableAutomaticGainControl'] as bool? ?? false;
  }

  /// Сохранить в JSON (для миграции)
  Future<Map<String, dynamic>> toJson() async {
    return {
      'selectedMethod': _selectedMethod?.toJson(),
      'autoSelect': _autoSelect,
      'ttyPortPath': _ttyPortPath,
      'ttyBaudRate': _ttyBaudRate,
      'enableInversion': _enableInversion,
      'enableEchoCancellation': _enableEchoCancellation,
      'enableNoiseReduction': _enableNoiseReduction,
      'enableAutomaticGainControl': _enableAutomaticGainControl,
    };
  }
}

/// Сервис для работы с хранилищем GatewayConfig
class GatewayConfigStorageService {
  final VoiceLineConfigStorage _voiceLineStorage = VoiceLineConfigStorage();

  /// Загрузить конфигурацию шлюза
  Future<Map<String, dynamic>> loadGatewayConfig() async {
    debugPrint('GatewayConfigStorageService: loading gateway config...');
    
    final voiceLineConfig = await _voiceLineStorage.toJson();
    
    return {
      'voiceLine': voiceLineConfig,
      // Другие настройки шлюза...
    };
  }

  /// Сохранить конфигурацию шлюза
  Future<void> saveGatewayConfig(Map<String, dynamic> config) async {
    debugPrint('GatewayConfigStorageService: saving gateway config...');
    
    if (config.containsKey('voiceLine')) {
      await _voiceLineStorage.loadFromJson(
        config['voiceLine'] as Map<String, dynamic>,
      );
    }
  }

  /// Получить VoiceLineConfig
  Future<VoiceLineConfig> getVoiceLineConfig() async {
    return _voiceLineStorage.load();
  }

  /// Сохранить VoiceLineConfig
  Future<void> saveVoiceLineConfig(VoiceLineConfig config) async {
    await _voiceLineStorage.save(config);
  }
}
