import '../models/voice_line_method.dart';
import '../models/voice_line_method_status.dart';
import '../models/test_method_result.dart';

/// Репозиторий для управления методами доступа к голосовой линии
abstract class VoiceLineRepository {
  /// Получить все доступные методы
  Future<List<VoiceLineMethodStatus>> getAvailableMethods();

  /// Получить текущий выбранный метод
  Future<VoiceLineMethod?> getCurrentMethod();

  /// Установить метод вручную
  Future<void> setMethod(VoiceLineMethod method);

  /// Автоматически выбрать лучший метод
  Future<VoiceLineMethod> selectBestMethod();

  /// Проверить доступность конкретного метода
  Future<bool> isMethodAvailable(VoiceLineMethod method);

  /// Получить информацию о методе
  Future<VoiceLineMethodStatus> getMethodStatus(VoiceLineMethod method);

  /// Тестировать метод
  Future<TestMethodResult> testMethod(VoiceLineMethod method);

  /// Получить TTY порт для ручного конфигурирования
  Future<String?> getTtyPortPath();

  /// Установить TTY порт
  Future<void> setTtyPortPath(String path);

  /// Получить скорость обмена TTY
  Future<int> getTtyBaudRate();

  /// Установить скорость обмена TTY
  Future<void> setTtyBaudRate(int baudRate);

  /// Включена ли инверсия правого канала
  Future<bool> isInversionEnabled();

  /// Установить инверсию правого канала
  Future<void> setInversionEnabled(bool enabled);

  /// Сбросить конфигурацию к значениям по умолчанию
  Future<void> resetToDefaults();
}
