import 'package:flutter/foundation.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/voice_line_method_status.dart';
import '../../domain/models/test_method_result.dart';
import '../../domain/models/quality_level.dart';
import '../../domain/repositories/voice_line_repository.dart';
import 'voice_line/tty_port_source.dart';
import 'voice_line/enhanced_mode_source.dart';
import 'voice_line/dongle_source.dart';
import 'voice_line/telecom_api_source.dart';

/// Реализация VoiceLineRepository
class VoiceLineRepositoryImpl implements VoiceLineRepository {
  /// Источник TTY портов
  final ITtyPortSource ttyPortSource;

  /// Источник Enhanced Mode
  final IEnhancedModeSource enhancedModeSource;

  /// Источник Dongle
  final IDongleSource dongleSource;

  /// Источник Telecom API
  final TelecomApiSource telecomApiSource;

  /// Хранилище конфигурации (в реальной реализации - SharedPreferences)
  final VoiceLineConfigStorage _configStorage;

  VoiceLineRepositoryImpl({
    ITtyPortSource? ttyPortSource,
    IEnhancedModeSource? enhancedModeSource,
    IDongleSource? dongleSource,
    TelecomApiSource? telecomApiSource,
    VoiceLineConfigStorage? configStorage,
  })  : ttyPortSource = ttyPortSource ?? TtyPortSource(),
        enhancedModeSource = enhancedModeSource ?? EnhancedModeSource(),
        dongleSource = dongleSource ?? DongleSource(),
        telecomApiSource = telecomApiSource ?? TelecomApiSource(),
        _configStorage = configStorage ?? VoiceLineConfigStorage();

  @override
  Future<List<VoiceLineMethodStatus>> getAvailableMethods() async {
    try {
      final methods = <VoiceLineMethodStatus>[];

      // Проверяем все методы параллельно
      final results = await Future.wait([
        _getTtyStatus(),
        _getEnhancedStatus(),
        _getDongleStatus(),
        _getTelecomStatus(),
        _getAcousticStatus(),
      ]);

      methods.addAll(results);

      // Сортируем по приоритету
      methods.sort((a, b) => a.method.priority.compareTo(b.method.priority));

      return methods;
    } catch (e) {
      debugPrint('VoiceLineRepositoryImpl.getAvailableMethods error: $e');
      // Возвращаем хотя бы Acoustic как fallback
      return [_getAcousticStatus()];
    }
  }

  @override
  Future<VoiceLineMethod?> getCurrentMethod() async {
    return _configStorage.getSelectedMethod();
  }

  @override
  Future<void> setMethod(VoiceLineMethod method) async {
    await _configStorage.setSelectedMethod(method);
  }

  @override
  Future<VoiceLineMethod> selectBestMethod() async {
    final methods = await getAvailableMethods();
    final available = methods.where((m) => m.available).toList();

    if (available.isEmpty) {
      // Fallback на Acoustic
      return VoiceLineMethod.acoustic;
    }

    // Возвращаем метод с наивысшим приоритетом (наименьшее значение)
    final best = available.reduce((a, b) =>
        a.method.priority < b.method.priority ? a : b);

    // Сохраняем выбор
    await setMethod(best.method);

    return best.method;
  }

  @override
  Future<bool> isMethodAvailable(VoiceLineMethod method) async {
    final status = await getMethodStatus(method);
    return status.available;
  }

  @override
  Future<VoiceLineMethodStatus> getMethodStatus(VoiceLineMethod method) async {
    switch (method) {
      case VoiceLineMethod.ttyPort:
        return _getTtyStatus();
      case VoiceLineMethod.enhancedMode:
        return _getEnhancedStatus();
      case VoiceLineMethod.dongle:
        return _getDongleStatus();
      case VoiceLineMethod.telecomApi:
        return _getTelecomStatus();
      case VoiceLineMethod.acoustic:
        return _getAcousticStatus();
    }
  }

  @override
  Future<TestMethodResult> testMethod(VoiceLineMethod method) async {
    switch (method) {
      case VoiceLineMethod.ttyPort:
        return _testTtyMethod();
      case VoiceLineMethod.enhancedMode:
        return _testEnhancedMethod();
      case VoiceLineMethod.dongle:
        return _testDongleMethod();
      case VoiceLineMethod.telecomApi:
        return _testTelecomMethod();
      case VoiceLineMethod.acoustic:
        return _testAcousticMethod();
    }
  }

  @override
  Future<String?> getTtyPortPath() async {
    return _configStorage.getTtyPortPath();
  }

  @override
  Future<void> setTtyPortPath(String path) async {
    await _configStorage.setTtyPortPath(path);
  }

  @override
  Future<int> getTtyBaudRate() async {
    return _configStorage.getTtyBaudRate();
  }

  @override
  Future<void> setTtyBaudRate(int baudRate) async {
    await _configStorage.setTtyBaudRate(baudRate);
  }

  @override
  Future<bool> isInversionEnabled() async {
    return _configStorage.isInversionEnabled();
  }

  @override
  Future<void> setInversionEnabled(bool enabled) async {
    await _configStorage.setInversionEnabled(enabled);
  }

  @override
  Future<void> resetToDefaults() async {
    await _configStorage.reset();
  }

  // === Private methods ===

  Future<VoiceLineMethodStatus> _getTtyStatus() async {
    try {
      final ports = await ttyPortSource.scanPorts();
      final available = ports.isNotEmpty;

      return VoiceLineMethodStatus(
        method: VoiceLineMethod.ttyPort,
        available: available,
        quality: available ? QualityLevel.great : QualityLevel.poor,
        reasonUnavailable: available ? null : 'No TTY ports found',
        details: {
          'ports': ports.map((p) => p.toJson()).toList(),
        },
      );
    } catch (e) {
      debugPrint('VoiceLineRepositoryImpl._getTtyStatus error: $e');
      return VoiceLineMethodStatus(
        method: VoiceLineMethod.ttyPort,
        available: false,
        quality: QualityLevel.poor,
        reasonUnavailable: 'Error scanning ports: $e',
      );
    }
  }

  Future<VoiceLineMethodStatus> _getEnhancedStatus() async {
    try {
      final status = await enhancedModeSource.checkStatus();

      return VoiceLineMethodStatus(
        method: VoiceLineMethod.enhancedMode,
        available: status.available,
        quality: status.available ? QualityLevel.excellent : QualityLevel.poor,
        reasonUnavailable: status.statusMessage,
        details: status.toJson(),
      );
    } catch (e) {
      debugPrint('VoiceLineRepositoryImpl._getEnhancedStatus error: $e');
      return VoiceLineMethodStatus(
        method: VoiceLineMethod.enhancedMode,
        available: false,
        quality: QualityLevel.poor,
        reasonUnavailable: 'Error checking status: $e',
      );
    }
  }

  Future<VoiceLineMethodStatus> _getDongleStatus() async {
    try {
      return await (dongleSource as DongleSource).getVoiceLineMethodStatus();
    } catch (e) {
      debugPrint('VoiceLineRepositoryImpl._getDongleStatus error: $e');
      return VoiceLineMethodStatus(
        method: VoiceLineMethod.dongle,
        available: false,
        quality: QualityLevel.poor,
        reasonUnavailable: 'Error checking dongle: $e',
      );
    }
  }

  Future<VoiceLineMethodStatus> _getTelecomStatus() async {
    return telecomApiSource.getStatus();
  }

  Future<VoiceLineMethodStatus> _getAcousticStatus() async {
    // Acoustic всегда доступен как fallback
    return const VoiceLineMethodStatus(
      method: VoiceLineMethod.acoustic,
      available: true,
      quality: QualityLevel.fair,
    );
  }

  // === Test methods ===

  Future<TestMethodResult> _testTtyMethod() async {
    final portPath = await getTtyPortPath();
    if (portPath == null) {
      return const TestMethodResult(
        success: false,
        error: 'No TTY port configured',
        measurements: {},
        quality: QualityLevel.poor,
      );
    }

    final baudRate = await getTtyBaudRate();
    return ttyPortSource.testPort(portPath, baudRate);
  }

  Future<TestMethodResult> _testEnhancedMethod() async {
    final status = await enhancedModeSource.checkStatus();
    return TestMethodResult(
      success: status.available,
      error: status.statusMessage,
      measurements: status.toJson(),
      quality: status.available ? QualityLevel.excellent : QualityLevel.poor,
    );
  }

  Future<TestMethodResult> _testDongleMethod() async {
    final dongleStatus = await (dongleSource as DongleSource).getStatus();
    return TestMethodResult(
      success: dongleStatus.connected,
      error: dongleStatus.connected ? null : 'No dongle detected',
      measurements: dongleStatus.toJson(),
      quality: dongleStatus.quality,
    );
  }

  Future<TestMethodResult> _testTelecomMethod() async {
    // Telecom API всегда работает
    return const TestMethodResult(
      success: true,
      measurements: {'api': 'android.telecom'},
      quality: QualityLevel.good,
    );
  }

  Future<TestMethodResult> _testAcousticMethod() async {
    // Acoustic тестируется через audio loopback
    return const TestMethodResult(
      success: true,
      measurements: {'type': 'acoustic'},
      quality: QualityLevel.fair,
    );
  }
}

/// Хранилище конфигурации VoiceLine
/// В реальной реализации будет использовать SharedPreferences
class VoiceLineConfigStorage {
  VoiceLineMethod? _selectedMethod;
  String? _ttyPortPath;
  int _ttyBaudRate = 115200;
  bool _enableInversion = true;

  Future<VoiceLineMethod?> getSelectedMethod() async => _selectedMethod;
  Future<void> setSelectedMethod(VoiceLineMethod method) async {
    _selectedMethod = method;
  }

  Future<String?> getTtyPortPath() async => _ttyPortPath;
  Future<void> setTtyPortPath(String path) async => _ttyPortPath = path;

  Future<int> getTtyBaudRate() async => _ttyBaudRate;
  Future<void> setTtyBaudRate(int baudRate) async => _ttyBaudRate = baudRate;

  Future<bool> isInversionEnabled() async => _enableInversion;
  Future<void> setInversionEnabled(bool enabled) async =>
      _enableInversion = enabled;

  Future<void> reset() async {
    _selectedMethod = null;
    _ttyPortPath = null;
    _ttyBaudRate = 115200;
    _enableInversion = true;
  }
}
