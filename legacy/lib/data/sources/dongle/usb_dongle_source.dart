import 'package:flutter/foundation.dart';
import '../../domain/models/dongle_interface_type.dart';
import '../../domain/models/dongle_status.dart';
import '../../domain/models/quality_level.dart';

/// Информация об USB устройстве
class UsbDeviceInfo {
  final int vendorId;
  final int productId;
  final String? productName;
  final String? manufacturerName;
  final int? deviceClass;
  final int? deviceSubclass;

  const UsbDeviceInfo({
    required this.vendorId,
    required this.productId,
    this.productName,
    this.manufacturerName,
    this.deviceClass,
    this.deviceSubclass,
  });

  /// Это USB Audio Class устройство?
  bool get isAudioClass => deviceClass == 1; // USB_CLASS_AUDIO

  /// Это USB DAC?
  bool get isDac => isAudioClass && deviceSubclass == 2;
}

/// Источник для обнаружения USB-C донглов
abstract class IUsbDongleSource {
  /// Обнаружить тип интерфейса
  Future<DongleInterfaceType> detectInterface();

  /// Получить информацию об USB устройстве
  Future<UsbDeviceInfo?> getDeviceInfo();

  /// Проверить подключение USB устройства
  Future<bool> isUsbConnected();
}

/// Реализация источника USB-C донглов
class UsbDongleSource implements IUsbDongleSource {
  @override
  Future<DongleInterfaceType> detectInterface() async {
    try {
      // Проверка USB подключения
      if (!await isUsbConnected()) {
        return DongleInterfaceType.none;
      }

      // Получение информации об устройстве
      final deviceInfo = await getDeviceInfo();
      if (deviceInfo == null) {
        return DongleInterfaceType.none;
      }

      // Определение типа интерфейса
      if (deviceInfo.isDac) {
        // USB Audio Class с DAC
        return DongleInterfaceType.usbCWithDac;
      } else if (deviceInfo.isAudioClass) {
        // USB Audio Accessory Mode
        return DongleInterfaceType.usbCAudioAccessory;
      } else {
        // Другое USB устройство (не audio)
        return DongleInterfaceType.none;
      }
    } catch (e) {
      debugPrint('UsbDongleSource.detectInterface error: $e');
      return DongleInterfaceType.none;
    }
  }

  @override
  Future<UsbDeviceInfo?> getDeviceInfo() async {
    try {
      // В реальной реализации - platform channel для получения USB info
      // Для现在 возвращаем заглушку
      return await _getUsbDeviceInfo();
    } catch (e) {
      debugPrint('UsbDongleSource.getDeviceInfo error: $e');
      return null;
    }
  }

  @override
  Future<bool> isUsbConnected() async {
    try {
      // В реальной реализации - platform channel для проверки USB state
      return await _checkUsbConnection();
    } catch (e) {
      debugPrint('UsbDongleSource.isUsbConnected error: $e');
      return false;
    }
  }

  /// Получить статус донгла
  Future<DongleStatus> getStatus() async {
    final interfaceType = await detectInterface();
    
    if (interfaceType == DongleInterfaceType.none) {
      return const DongleStatus(
        connected: false,
        interfaceType: DongleInterfaceType.none,
        quality: QualityLevel.poor,
      );
    }

    final deviceInfo = await getDeviceInfo();
    final quality = DongleStatus.calculateQuality(
      interfaceType: interfaceType,
    );

    return DongleStatus(
      connected: true,
      interfaceType: interfaceType,
      quality: quality,
      statusMessage: deviceInfo?.productName ?? interfaceType.displayName,
    );
  }

  // Заглушка для получения USB информации
  Future<UsbDeviceInfo?> _getUsbDeviceInfo() async {
    // В реальной реализации - platform channel
    // Пример:
    // final result = await platformChannel.invokeMethod('getUsbDeviceInfo');
    // return UsbDeviceInfo(
    //   vendorId: result['vendorId'],
    //   productId: result['productId'],
    //   ...
    // );
    debugPrint('UsbDongleSource: getting USB device info...');
    return null; // Заглушка
  }

  // Заглушка для проверки USB подключения
  Future<bool> _checkUsbConnection() async {
    // В реальной реализации - platform channel
    // Пример:
    // return await platformChannel.invokeMethod('isUsbConnected');
    debugPrint('UsbDongleSource: checking USB connection...');
    return false; // Заглушка
  }
}

/// Расширение для определения типа USB устройства по VID/PID
extension UsbDeviceTypeExtension on UsbDeviceInfo {
  /// Известные USB DAC вендоры
  static const knownDacVendors = [
    0x0D8C, // C-Media
    0x041E, // Creative Labs
    0x045E, // Microsoft
    0x046D, // Logitech
    0x0951, // Kingston
    0x0B05, // ASUS
    0x1395, // Sennheiser
    0x262A, // AudioQuest
  ];

  /// Это известный USB DAC?
  bool get isKnownDac => knownDacVendors.contains(vendorId);

  /// Получить название DAC чипа (если известно)
  String? get dacChipName {
    if (vendorId == 0x0D8C && productId == 0x000C) {
      return 'CM108';
    }
    if (vendorId == 0x0D8C && productId == 0x0014) {
      return 'CM119';
    }
    if (vendorId == 0x041E && productId == 0x3220) {
      return 'Creative USB Audio';
    }
    return null;
  }
}
