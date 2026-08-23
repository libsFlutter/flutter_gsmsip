import 'package:flutter/foundation.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/voice_line_method_status.dart';
import '../../domain/models/quality_level.dart';
import '../../domain/models/test_method_result.dart';
import '../../domain/entities/voice_line_config.dart';
import '../../domain/repositories/voice_line_repository.dart';
import '../../data/repositories/voice_line_repository_impl.dart';

/// Состояние VoiceLine
enum VoiceLineState {
  /// Начальное состояние
  initial,

  /// Загрузка доступных методов
  loading,

  /// Методы загружены
  ready,

  /// Тестирование метода
  testing,

  /// Ошибка
  error,
}

/// Provider для управления состоянием Voice Line
class VoiceLineProvider extends ChangeNotifier {
  /// Репозиторий
  final VoiceLineRepository _repository;

  /// Текущее состояние
  VoiceLineState _state = VoiceLineState.initial;

  /// Доступные методы
  List<VoiceLineMethodStatus> _availableMethods = [];

  /// Текущий выбранный метод
  VoiceLineMethod? _currentMethod;

  /// Конфигурация
  VoiceLineConfig _config = const VoiceLineConfig();

  /// Результат последнего теста
  TestMethodResult? _lastTestResult;

  /// Сообщение об ошибке
  String? _errorMessage;

  VoiceLineProvider({
    VoiceLineRepository? repository,
  }) : _repository = repository ?? VoiceLineRepositoryImpl();

  // === Getters ===

  VoiceLineState get state => _state;
  List<VoiceLineMethodStatus> get availableMethods => _availableMethods;
  VoiceLineMethod? get currentMethod => _currentMethod;
  VoiceLineConfig get config => _config;
  TestMethodResult? get lastTestResult => _lastTestResult;
  String? get errorMessage => _errorMessage;

  bool get isLoading => _state == VoiceLineState.loading;
  bool get isReady => _state == VoiceLineState.ready;
  bool get isTesting => _state == VoiceLineState.testing;
  bool get hasError => _state == VoiceLineState.error;
  bool get isAutoSelect => _config.autoSelect;

  /// Получить лучший доступный метод
  VoiceLineMethod? get bestAvailableMethod {
    final available = _availableMethods.where((m) => m.available).toList();
    if (available.isEmpty) return null;
    return available.reduce((a, b) =>
        a.method.priority < b.method.priority ? a : b).method;
  }

  /// Получить статус текущего метода
  VoiceLineMethodStatus? get currentMethodStatus {
    if (_currentMethod == null) return null;
    return _availableMethods.firstWhere(
      (m) => m.method == _currentMethod,
      orElse: () => VoiceLineMethodStatus(
        method: _currentMethod!,
        available: false,
        quality: QualityLevel.poor,
      ),
    );
  }

  // === Methods ===

  /// Инициализация
  Future<void> initialize() async {
    _state = VoiceLineState.loading;
    notifyListeners();

    try {
      // Загружаем конфигурацию
      _config = await _loadConfig();

      // Загружаем доступные методы
      await loadAvailableMethods();

      // Если auto-select, выбираем лучший метод
      if (_config.autoSelect) {
        await selectBestMethod();
      } else if (_config.selectedMethod != null) {
        _currentMethod = _config.selectedMethod;
      }

      _state = VoiceLineState.ready;
      notifyListeners();
    } catch (e) {
      _state = VoiceLineState.error;
      _errorMessage = 'Failed to initialize: $e';
      notifyListeners();
    }
  }

  /// Загрузить доступные методы
  Future<void> loadAvailableMethods() async {
    try {
      _availableMethods = await _repository.getAvailableMethods();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to load methods: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Выбрать лучший метод автоматически
  Future<void> selectBestMethod() async {
    try {
      final method = await _repository.selectBestMethod();
      _currentMethod = method;
      await _repository.setMethod(method);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to select best method: $e';
      notifyListeners();
    }
  }

  /// Установить метод вручную
  Future<void> setMethod(VoiceLineMethod method) async {
    try {
      await _repository.setMethod(method);
      _currentMethod = method;
      _config = _config.copyWith(
        selectedMethod: method,
        autoSelect: false,
      );
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Failed to set method: $e';
      notifyListeners();
    }
  }

  /// Включить автоматический выбор
  Future<void> setAutoSelect(bool enabled) async {
    _config = _config.copyWith(autoSelect: enabled);
    if (enabled) {
      await selectBestMethod();
    }
    notifyListeners();
  }

  /// Тестировать метод
  Future<TestMethodResult> testMethod(VoiceLineMethod method) async {
    _state = VoiceLineState.testing;
    _lastTestResult = null;
    notifyListeners();

    try {
      final result = await _repository.testMethod(method);
      _lastTestResult = result;
      _state = VoiceLineState.ready;
      notifyListeners();
      return result;
    } catch (e) {
      _state = VoiceLineState.error;
      _errorMessage = 'Test failed: $e';
      notifyListeners();
      return TestMethodResult(
        success: false,
        error: e.toString(),
        measurements: {},
        quality: QualityLevel.poor,
      );
    }
  }

  /// Обновить конфигурацию
  Future<void> updateConfig(VoiceLineConfig config) async {
    _config = config;
    notifyListeners();
  }

  /// Сбросить к настройкам по умолчанию
  Future<void> resetToDefaults() async {
    await _repository.resetToDefaults();
    _config = const VoiceLineConfig();
    await initialize();
  }

  /// Загрузить конфигурацию
  Future<VoiceLineConfig> _loadConfig() async {
    // В реальной реализации - загрузка из хранилища
    return const VoiceLineConfig();
  }

  /// Обновить TTY порт
  Future<void> setTtyPort(String path, int baudRate) async {
    await _repository.setTtyPortPath(path);
    await _repository.setTtyBaudRate(baudRate);
    _config = _config.copyWith(
      ttyPortPath: path,
      ttyBaudRate: baudRate,
    );
    notifyListeners();
  }

  /// Переключить инверсию
  Future<void> toggleInversion(bool enabled) async {
    await _repository.setInversionEnabled(enabled);
    _config = _config.copyWith(enableInversion: enabled);
    notifyListeners();
  }
}
