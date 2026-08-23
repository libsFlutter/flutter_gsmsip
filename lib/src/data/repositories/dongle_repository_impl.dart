import 'package:flutter/foundation.dart';
import '../../domain/models/dongle_interface_type.dart';
import '../../domain/models/dongle_type.dart';
import '../../domain/models/dongle_status.dart';
import '../../domain/models/resistance_measurements.dart';
import '../../domain/models/quality_level.dart';
import '../../domain/entities/dongle_config.dart';
import '../../domain/repositories/dongle_repository.dart';
import '../sources/dongle/usb_dongle_source.dart';
import '../sources/dongle/trrs_dongle_source.dart';
import '../sources/dongle/resistance_meter.dart';
import '../sources/dongle/dongle_type_detector.dart';

/// Реализация DongleRepository
class DongleRepositoryImpl implements DongleRepository {
  /// Источник USB-C донглов
  final IUsbDongleSource _usbSource;

  /// Источник TRRS донглов
  final ITrrsDongleSource _trrsSource;

  /// Измеритель сопротивлений
  final IResistanceMeter _resistanceMeter;

  /// Детектор типа донгла
  final DongleTypeDetectorImpl _typeDetector;

  /// Хранилище конфигурации
  final DongleConfigStorage _configStorage;

  DongleRepositoryImpl({
    IUsbDongleSource? usbSource,
    ITrrsDongleSource? trrsSource,
    IResistanceMeter? resistanceMeter,
    DongleTypeDetectorImpl? typeDetector,
    DongleConfigStorage? configStorage,
  })  : _usbSource = usbSource ?? UsbDongleSource(),
        _trrsSource = trrsSource ?? TrrsDongleSource(),
        _resistanceMeter = resistanceMeter ?? ResistanceMeter(),
        _typeDetector = typeDetector ??
            DongleTypeDetectorImpl(resistanceMeter: resistanceMeter),
        _configStorage = configStorage ?? DongleConfigStorage();

  @override
  Future<DongleStatus> getStatus() async {
    try {
      // Сначала проверяем USB
      final usbStatus = await _usbSource.getStatus();
      if (usbStatus.connected) {
        // Для USB-C with DAC, тип донгла не определяется по R
        if (usbStatus.interfaceType == DongleInterfaceType.usbCWithDac) {
          final config = await loadConfig();
          return usbStatus.copyWith(
            dongleType: config?.dongleType ?? DongleType.differential,
          );
        }
        // Для USB Accessory, пытаемся определить тип
        return await _getAnalogDongleStatus(usbStatus);
      }

      // Проверяем TRRS
      final trrsStatus = await _trrsSource.getStatus();
      if (trrsStatus.connected) {
        return await _getAnalogDongleStatus(trrsStatus);
      }

      // Нет донгла
      return const DongleStatus(
        connected: false,
        interfaceType: DongleInterfaceType.none,
        quality: QualityLevel.poor,
      );
    } catch (e) {
      debugPrint('DongleRepositoryImpl.getStatus error: $e');
      return DongleStatus(
        connected: false,
        interfaceType: DongleInterfaceType.none,
        quality: QualityLevel.poor,
        statusMessage: 'Error: $e',
      );
    }
  }

  @override
  Future<DongleInterfaceType> detectInterface() async {
    // Проверяем USB
    final usbInterface = await _usbSource.detectInterface();
    if (usbInterface != DongleInterfaceType.none) {
      return usbInterface;
    }

    // Проверяем TRRS
    final trrsInserted = await _trrsSource.isJackInserted();
    if (trrsInserted) {
      return DongleInterfaceType.trrs;
    }

    return DongleInterfaceType.none;
  }

  @override
  Future<ResistanceMeasurements> measureResistance() async {
    return await _resistanceMeter.measureAll();
  }

  @override
  Future<DongleType?> detectDongleType() async {
    return await _typeDetector.detectType();
  }

  @override
  Future<void> saveConfig(DongleConfig config) async {
    await _configStorage.save(config);
  }

  @override
  Future<DongleConfig?> loadConfig() async {
    return await _configStorage.load();
  }

  @override
  Future<DongleTestResult> testDongle(String testType) async {
    // В реальной реализации - запуск теста
    return DongleTestResult(
      success: true,
      measurements: {'testType': testType},
      testType: testType,
    );
  }

  @override
  Future<Map<String, dynamic>?> getUsbDeviceInfo() async {
    final deviceInfo = await _usbSource.getDeviceInfo();
    if (deviceInfo == null) return null;

    return {
      'vendorId': deviceInfo.vendorId,
      'productId': deviceInfo.productId,
      'productName': deviceInfo.productName,
      'manufacturerName': deviceInfo.manufacturerName,
      'isDac': deviceInfo.isDac,
      'dacChipName': deviceInfo.dacChipName,
    };
  }

  @override
  Future<bool> canMeasureResistance() async {
    return await _resistanceMeter.canMeasure();
  }

  /// Получить статус для аналогового донгла (USB Accessory или TRRS)
  Future<DongleStatus> _getAnalogDongleStatus(DongleStatus baseStatus) async {
    // Пытаемся определить тип донгла
    final type = await _typeDetector.detectType();
    final measurements = await _resistanceMeter.measureAll();

    return baseStatus.copyWith(
      dongleType: type,
      measuredResistanceMic: measurements.gndToMic,
      measuredResistanceLeft: measurements.leftToGnd,
      measuredResistanceRight: measurements.rightToGnd,
    );
  }
}

/// Хранилище конфигурации донгла
/// В реальной реализации будет использовать SharedPreferences
class DongleConfigStorage {
  DongleConfig? _config;

  /// Загрузить конфигурацию
  Future<DongleConfig?> load() async {
    // В реальной реализации - загрузка из SharedPreferences
    debugPrint('DongleConfigStorage: loading config...');
    return _config ?? DongleConfig.defaultConfig;
  }

  /// Сохранить конфигурацию
  Future<void> save(DongleConfig config) async {
    // В реальной реализации - сохранение в SharedPreferences
    debugPrint('DongleConfigStorage: saving config...');
    _config = config;
  }

  /// Загрузить из JSON
  Future<void> loadFromJson(Map<String, dynamic> json) async {
    _config = DongleConfig.fromJson(json);
  }

  /// Сохранить в JSON
  Future<Map<String, dynamic>> toJson() async {
    return _config?.toJson() ?? DongleConfig.defaultConfig.toJson();
  }
}
