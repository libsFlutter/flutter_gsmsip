import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

/// Platform channel для Dongle функционала
/// Интеграция с Android для USB/TRRS detection и resistance measurement
class DonglePlatform {
  static const MethodChannel _channel =
      MethodChannel('com.gostsimbox/dongle');

  /// Проверить доступность platform channel
  static Future<bool> isAvailable() async {
    try {
      final result = await _channel.invokeMethod<bool>('isAvailable');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.isAvailable error: $e');
      return false;
    }
  }

  // === USB Dongle Methods ===

  /// Проверить подключение USB устройства
  static Future<bool> isUsbConnected() async {
    try {
      final result = await _channel.invokeMethod<bool>('isUsbConnected');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.isUsbConnected error: $e');
      return false;
    }
  }

  /// Получить информацию об USB устройстве
  static Future<Map<String, dynamic>?> getUsbDeviceInfo() async {
    try {
      final result =
          await _channel.invokeMapMethod<String, dynamic>('getUsbDeviceInfo');
      return result;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.getUsbDeviceInfo error: $e');
      return null;
    }
  }

  /// Определить тип USB интерфейса
  static Future<String?> detectUsbInterface() async {
    try {
      final result =
          await _channel.invokeMethod<String>('detectUsbInterface');
      return result;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.detectUsbInterface error: $e');
      return null;
    }
  }

  // === TRRS Dongle Methods ===

  /// Проверить подключение TRRS jack
  static Future<bool> isTrrsJackInserted() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('isTrrsJackInserted');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.isTrrsJackInserted error: $e');
      return false;
    }
  }

  /// Получить состояние TRRS (0=removed, 1=inserted)
  static Future<int> getTrrsState() async {
    try {
      final result = await _channel.invokeMethod<int>('getTrrsState');
      return result ?? 0;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.getTrrsState error: $e');
      return 0;
    }
  }

  // === Resistance Measurement Methods ===

  /// Измерить сопротивление между двумя точками
  static Future<int?> measureResistance(String from, String to) async {
    try {
      final result = await _channel.invokeMethod<int>('measureResistance', {
        'from': from,
        'to': to,
      });
      return result;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.measureResistance error: $e');
      return null;
    }
  }

  /// Измерить GND → MIC
  static Future<int?> measureGndToMic() async {
    return measureResistance('GND', 'MIC');
  }

  /// Измерить L → GND
  static Future<int?> measureLeftToGnd() async {
    return measureResistance('L', 'GND');
  }

  /// Измерить R → GND
  static Future<int?> measureRightToGnd() async {
    return measureResistance('R', 'GND');
  }

  /// Измерить L → MIC
  static Future<int?> measureLeftToMic() async {
    return measureResistance('L', 'MIC');
  }

  /// Измерить все сопротивления
  static Future<Map<String, int?>> measureAllResistances() async {
    try {
      final result = await _channel
          .invokeMapMethod<String, int>('measureAllResistances');
      return {
        'gndToMic': result?['gndToMic'],
        'leftToGnd': result?['leftToGnd'],
        'rightToGnd': result?['rightToGnd'],
        'leftToMic': result?['leftToMic'],
      };
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.measureAllResistances error: $e');
      return {
        'gndToMic': null,
        'leftToGnd': null,
        'rightToGnd': null,
        'leftToMic': null,
      };
    }
  }

  /// Проверить возможность измерения сопротивлений
  static Future<bool> canMeasureResistance() async {
    try {
      final result =
          await _channel.invokeMethod<bool>('canMeasureResistance');
      return result ?? false;
    } on PlatformException catch (e) {
      debugPrint('DonglePlatform.canMeasureResistance error: $e');
      return false;
    }
  }

  // === Stream для событий ===

  /// Stream для событий подключения/отключения донгла
  static final EventChannel _dongleEventChannel =
      const EventChannel('com.gostsimbox/dongle/events');

  static Stream<dynamic> get dongleEventStream {
    return _dongleEventChannel.receiveBroadcastStream();
  }

  /// Слушать события USB
  static Stream<dynamic> get usbEventStream {
    return _dongleEventChannel
        .receiveBroadcastStream({'event': 'usb'});
  }

  /// Слушать события TRRS
  static Stream<dynamic> get trrsEventStream {
    return _dongleEventChannel
        .receiveBroadcastStream({'event': 'trrs'});
  }
}

/// Extension для работы с USB Device Info
extension UsbDeviceInfoExtension on Map<String, dynamic>? {
  int get vendorId => this?['vendorId'] as int? ?? 0;
  int get productId => this?['productId'] as int? ?? 0;
  String? get productName => this?['productName'] as String?;
  String? get manufacturerName => this?['manufacturerName'] as String?;
  bool get isDac => this?['isDac'] as bool? ?? false;
  String? get dacChipName => this?['dacChipName'] as String?;
}
