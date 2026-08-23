import '../models/dongle_interface_type.dart';
import '../models/dongle_type.dart';
import '../models/dongle_status.dart';
import '../models/resistance_measurements.dart';
import '../entities/dongle_config.dart';

/// Результат теста донгла
class DongleTestResult {
  final bool success;
  final String? error;
  final Map<String, dynamic> measurements;
  final String testType;

  const DongleTestResult({
    required this.success,
    this.error,
    required this.measurements,
    required this.testType,
  });
}

/// Репозиторий для управления донглами
abstract class DongleRepository {
  /// Получить статус донгла
  Future<DongleStatus> getStatus();

  /// Определить тип интерфейса
  Future<DongleInterfaceType> detectInterface();

  /// Измерить сопротивления
  Future<ResistanceMeasurements> measureResistance();

  /// Определить тип донгла
  Future<DongleType?> detectDongleType();

  /// Сохранить конфигурацию донгла
  Future<void> saveConfig(DongleConfig config);

  /// Загрузить конфигурацию донгла
  Future<DongleConfig?> loadConfig();

  /// Тестировать донгл
  Future<DongleTestResult> testDongle(String testType);

  /// Получить информацию об USB устройстве (для USB-C with DAC)
  Future<Map<String, dynamic>?> getUsbDeviceInfo();

  /// Проверить возможность измерения сопротивлений
  Future<bool> canMeasureResistance();
}
