import 'package:flutter/foundation.dart';
import '../../../domain/models/dongle_interface_type.dart';
import '../../../domain/models/dongle_status.dart';
import '../../../domain/models/quality_level.dart';

/// Источник для обнаружения TRRS донглов (3.5mm jack)
abstract class ITrrsDongleSource {
  /// Проверить подключение TRRS jack
  Future<bool> isJackInserted();

  /// Получить статус TRRS донгла
  Future<DongleStatus> getStatus();

  /// Получить состояние TRRS (0/1)
  Future<int> getTrrsState(); // 0=removed, 1=inserted
}

/// Реализация источника TRRS донглов
class TrrsDongleSource implements ITrrsDongleSource {
  @override
  Future<bool> isJackInserted() async {
    try {
      // В реальной реализации - platform channel или AudioManager
      // Проверка через AudioManager.ACTION_HEADSET_PLUG
      return await _checkJackState();
    } catch (e) {
      debugPrint('TrrsDongleSource.isJackInserted error: $e');
      return false;
    }
  }

  @override
  Future<int> getTrrsState() async {
    try {
      final inserted = await isJackInserted();
      return inserted ? 1 : 0;
    } catch (e) {
      debugPrint('TrrsDongleSource.getTrrsState error: $e');
      return 0;
    }
  }

  @override
  Future<DongleStatus> getStatus() async {
    final inserted = await isJackInserted();

    if (!inserted) {
      return const DongleStatus(
        connected: false,
        interfaceType: DongleInterfaceType.none,
        quality: QualityLevel.poor,
        statusMessage: 'TRRS jack not inserted',
      );
    }

    return DongleStatus(
      connected: true,
      interfaceType: DongleInterfaceType.trrs,
      quality: QualityLevel.good, // ★★★☆☆
      statusMessage: 'TRRS 3.5mm connected',
    );
  }

  /// Проверка состояния jack
  Future<bool> _checkJackState() async {
    // В реальной реализации - platform channel
    // Пример:
    // final result = await platformChannel.invokeMethod('isHeadsetPlugged');
    // return result ?? false;
    debugPrint('TrrsDongleSource: checking TRRS jack state...');
    return false; // Заглушка
  }
}

/// Расширение для работы с TRRS состояниями
extension TrrsStateExtension on int {
  /// Jack вставлен?
  bool get isInserted => this == 1;

  /// Jack извлечён?
  bool get isRemoved => this == 0;
}
