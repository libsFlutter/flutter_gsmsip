import 'package:flutter/foundation.dart';
import '../../domain/models/dongle_interface_type.dart';
import '../../domain/models/dongle_type.dart';
import '../../domain/models/dongle_status.dart';
import '../../domain/models/resistance_measurements.dart';
import '../../domain/entities/dongle_config.dart';
import '../../domain/repositories/dongle_repository.dart';
import '../../data/repositories/dongle_repository_impl.dart';

/// Состояние Dongle
enum DongleState {
  /// Начальное состояние
  initial,

  /// Загрузка статуса
  loading,

  /// Статус загружен
  ready,

  /// Измерение сопротивлений
  measuring,

  /// Тестирование
  testing,

  /// Ошибка
  error,
}

/// Provider для управления состоянием Dongle
class DongleProvider extends ChangeNotifier {
  /// Репозиторий
  final DongleRepository _repository;

  /// Текущее состояние
  DongleState _state = DongleState.initial;

  /// Статус донгла
  DongleStatus? _dongleStatus;

  /// Конфигурация
  DongleConfig? _config;

  /// Измерения сопротивлений
  ResistanceMeasurements? _lastMeasurements;

  /// Результат последнего теста
  String? _lastTestResult;

  /// Сообщение об ошибке
  String? _errorMessage;

  DongleProvider({
    DongleRepository? repository,
  }) : _repository = repository ?? DongleRepositoryImpl();

  // === Getters ===

  DongleState get state => _state;
  DongleStatus? get dongleStatus => _dongleStatus;
  DongleConfig? get config => _config;
  ResistanceMeasurements? get lastMeasurements => _lastMeasurements;
  String? get lastTestResult => _lastTestResult;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == DongleState.loading;
  bool get isReady => _state == DongleState.ready;
  bool get isMeasuring => _state == DongleState.measuring;
  bool get isTesting => _state == DongleState.testing;
  bool get hasError => _state == DongleState.error;
  bool get hasDongle => _dongleStatus?.connected == true;
  bool get isAnalog => _dongleStatus?.interfaceType == DongleInterfaceType.usbCAudioAccessory ||
      _dongleStatus?.interfaceType == DongleInterfaceType.trrs;

  /// Получить тип интерфейса
  DongleInterfaceType? get interfaceType => _dongleStatus?.interfaceType;

  /// Получить тип донгла
  DongleType? get dongleType => _dongleStatus?.dongleType;

  // === Methods ===

  /// Инициализация
  Future<void> initialize() async {
    _state = DongleState.loading;
    notifyListeners();

    try {
      // Загружаем конфигурацию
      _config = await _repository.loadConfig();

      // Загружаем статус донгла
      await refreshStatus();

      _state = DongleState.ready;
      notifyListeners();
    } catch (e) {
      _state = DongleState.error;
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  /// Обновить статус донгла
  Future<void> refreshStatus() async {
    try {
      _dongleStatus = await _repository.getStatus();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to refresh status: $e';
      notifyListeners();
    }
  }

  /// Измерить сопротивления
  Future<ResistanceMeasurements?> measureResistance() async {
    _state = DongleState.measuring;
    notifyListeners();

    try {
      final measurements = await _repository.measureResistance();
      _lastMeasurements = measurements;

      // Если измерения успешны, определяем тип донгла
      if (measurements.error == null) {
        final type = await _repository.detectDongleType();
        if (type != null && _dongleStatus != null) {
          _dongleStatus = _dongleStatus!.copyWith(
            dongleType: type,
            measuredResistanceMic: measurements.gndToMic,
            measuredResistanceLeft: measurements.leftToGnd,
            measuredResistanceRight: measurements.rightToGnd,
          );
        }
      }

      _state = DongleState.ready;
      notifyListeners();
      return measurements;
    } catch (e) {
      _state = DongleState.error;
      _errorMessage = 'Measurement failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Сохранить конфигурацию
  Future<void> saveConfig(DongleConfig config) async {
    try {
      await _repository.saveConfig(config);
      _config = config;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to save config: $e';
      notifyListeners();
    }
  }

  /// Установить тип донгла вручную
  Future<void> setDongleType(DongleType type) async {
    if (_config == null) return;

    final updatedConfig = _config!.copyWith(
      dongleType: type,
      autoDetectType: false,
    );
    await saveConfig(updatedConfig);

    if (_dongleStatus != null) {
      _dongleStatus = _dongleStatus!.copyWith(dongleType: type);
      notifyListeners();
    }
  }

  /// Переключить инверсию
  Future<void> toggleInversion(bool enabled) async {
    if (_config == null) return;

    final updatedConfig = _config!.copyWith(enableInversion: enabled);
    await saveConfig(updatedConfig);
  }

  /// Тестировать донгл
  Future<String?> testDongle(String testType) async {
    _state = DongleState.testing;
    _lastTestResult = null;
    notifyListeners();

    try {
      final result = await _repository.testDongle(testType);
      _lastTestResult = result.success
          ? 'Test passed: $testType'
          : 'Test failed: ${result.error}';
      _state = DongleState.ready;
      notifyListeners();
      return _lastTestResult;
    } catch (e) {
      _state = DongleState.error;
      _errorMessage = 'Test failed: $e';
      notifyListeners();
      return null;
    }
  }

  /// Сбросить конфигурацию
  Future<void> resetConfig() async {
    await _repository.saveConfig(DongleConfig.defaultConfig);
    _config = DongleConfig.defaultConfig;
    notifyListeners();
  }
}
