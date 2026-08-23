import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Platform channel для Voice Line функционала
/// Интеграция с Android для TTY портов и Enhanced Mode
class VoiceLinePlatform {
  static const MethodChannel _channel =
      MethodChannel('com.gostsimbox/voice_line');

  /// Проверить доступность platform channel
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.isAvailable error: $e');
      return false;
    }
  }

  // === TTY Port Methods ===

  /// Сканировать TTY порты
  /// Возвращает список путей к портам
  static Future<List<String>> scanTtyPorts() async {
    try {
      final result = await _channel.invokeList<String>('scanTtyPorts');
      return result ?? [];
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.scanTtyPorts error: $e');
      return [];
    }
  }

  /// Тестировать TTY порт
  static Future<Map<String, dynamic>?> testTtyPort({
    required String path,
    required int baudRate,
  }) async {
    try {
      final result = await _channel.invokeMapMethod<String, dynamic>(
        'testTtyPort',
        {'path': path, 'baudRate': baudRate},
      );
      return result;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.testTtyPort error: $e');
      return null;
    }
  }

  /// Открыть TTY порт
  static Future<bool> openTtyPort({
    required String path,
    required int baudRate,
  }) async {
    try {
      final result = await _channel.invokeMethod<bool>('openTtyPort', {
        'path': path,
        'baudRate': baudRate,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.openTtyPort error: $e');
      return false;
    }
  }

  /// Закрыть TTY порт
  static Future<void> closeTtyPort() async {
    try {
      await _channel.invokeMethod('closeTtyPort');
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.closeTtyPort error: $e');
    }
  }

  /// Отправить данные в TTY порт
  static Future<bool> writeTtyData(String data) async {
    try {
      final result = await _channel.invokeMethod<bool>('writeTtyData', {
        'data': data,
      });
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.writeTtyData error: $e');
      return false;
    }
  }

  /// Прочитать данные из TTY порта
  static Future<String?> readTtyData({int timeoutMs = 2000}) async {
    try {
      final result = await _channel.invokeMethod<String>('readTtyData', {
        'timeoutMs': timeoutMs,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.readTtyData error: $e');
      return null;
    }
  }

  // === Enhanced Mode Methods ===

  /// Проверить наличие Magisk
  static Future<bool> checkMagisk() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkMagisk');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.checkMagisk error: $e');
      return false;
    }
  }

  /// Проверить установку как системного приложения
  static Future<bool> checkSystemApp() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkSystemApp');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.checkSystemApp error: $e');
      return false;
    }
  }

  /// Проверить привилегированные разрешения
  static Future<bool> checkPrivilegedPermissions() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('checkPrivilegedPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.checkPrivilegedPermissions error: $e');
      return false;
    }
  }

  /// Получить статус Enhanced Mode
  static Future<Map<String, dynamic>?> getEnhancedModeStatus() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getEnhancedModeStatus');
      return result;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.getEnhancedModeStatus error: $e');
      return null;
    }
  }

  // === Dongle Methods ===

  /// Проверить подключение USB донгла
  static Future<bool> checkUsbDongleConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkUsbDongleConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.checkUsbDongleConnected error: $e');
      return false;
    }
  }

  /// Проверить подключение TRRS донгла
  static Future<bool> checkTrrsDongleConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('checkTrrsDongleConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.checkTrrsDongleConnected error: $e');
      return false;
    }
  }

  /// Измерить сопротивление (для определения типа донгла)
  static Future<Map<String, int>?> measureResistance() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, int>('measureResistance');
      return result;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.measureResistance error: $e');
      return null;
    }
  }

  /// Получить тип USB устройства
  static Future<Map<String, dynamic>?> getUsbDeviceType() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getUsbDeviceType');
      return result;
    } on PlatformException catch (e) {
      debugPrint('VoiceLinePlatform.getUsbDeviceType error: $e');
      return null;
    }
  }
}
