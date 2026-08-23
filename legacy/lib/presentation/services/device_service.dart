import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с информацией об устройстве
class DeviceService {
  final Logger _logger;
  final DeviceInfoPlugin _deviceInfo;

  DeviceService() 
    : _logger = Logger(),
      _deviceInfo = DeviceInfoPlugin();

  /// Получение информации об устройстве
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      _logger.d('Getting device info...');
      
      final deviceInfo = <String, dynamic>{
        'platform': Platform.operatingSystem,
        'platformVersion': Platform.operatingSystemVersion,
        'localHostname': Platform.localHostname,
        'numberOfProcessors': Platform.numberOfProcessors,
        'environment': Platform.environment,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo.addAll({
          'brand': androidInfo.brand,
          'model': androidInfo.model,
          'version': {
            'release': androidInfo.version.release,
            'sdkInt': androidInfo.version.sdkInt,
            'codename': androidInfo.version.codename,
          },
          'hardware': androidInfo.hardware,
          'manufacturer': androidInfo.manufacturer,
          'product': androidInfo.product,
          'device': androidInfo.device,
          'fingerprint': androidInfo.fingerprint,
          'host': androidInfo.host,
          'tags': androidInfo.tags,
          'type': androidInfo.type,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
          'androidId': androidInfo.id,
          'systemFeatures': androidInfo.systemFeatures,
          'displayMetrics': {
            'widthPx': androidInfo.displayMetrics.widthPx,
            'heightPx': androidInfo.displayMetrics.heightPx,
            'xDpi': androidInfo.displayMetrics.xDpi,
            'yDpi': androidInfo.displayMetrics.yDpi,
          },
        });
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo.addAll({
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
          'utsname': {
            'sysname': iosInfo.utsname.sysname,
            'nodename': iosInfo.utsname.nodename,
            'release': iosInfo.utsname.release,
            'version': iosInfo.utsname.version,
            'machine': iosInfo.utsname.machine,
          },
        });
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceInfo.addAll({
          'computerName': windowsInfo.computerName,
          'majorVersion': windowsInfo.majorVersion,
          'minorVersion': windowsInfo.minorVersion,
          'buildNumber': windowsInfo.buildNumber,
          'platformId': windowsInfo.platformId,
          'csdVersion': windowsInfo.csdVersion,
          'servicePackMajor': windowsInfo.servicePackMajor,
          'servicePackMinor': windowsInfo.servicePackMinor,
          'suitMask': windowsInfo.suitMask,
          'productType': windowsInfo.productType,
          'reserved': windowsInfo.reserved,
          'buildLab': windowsInfo.buildLab,
          'buildLabEx': windowsInfo.buildLabEx,
          'digitalProductId': windowsInfo.digitalProductId,
          'displayVersion': windowsInfo.displayVersion,
          'editionId': windowsInfo.editionId,
          'installDateFromRegistry': windowsInfo.installDateFromRegistry,
          'productId': windowsInfo.productId,
          'productName': windowsInfo.productName,
          'registeredOwner': windowsInfo.registeredOwner,
          'releaseId': windowsInfo.releaseId,
          'deviceId': windowsInfo.deviceId,
        });
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        deviceInfo.addAll({
          'computerName': macOsInfo.computerName,
          'hostName': macOsInfo.hostName,
          'osRelease': macOsInfo.osRelease,
          'activeCPUs': macOsInfo.activeCPUs,
          'memorySize': macOsInfo.memorySize,
          'cpuFrequency': macOsInfo.cpuFrequency,
          'modelName': macOsInfo.modelName,
          'modelIdentifier': macOsInfo.modelIdentifier,
          'kernelArchitecture': macOsInfo.kernelArchitecture,
          'kernelVersion': macOsInfo.kernelVersion,
        });
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        deviceInfo.addAll({
          'name': linuxInfo.name,
          'version': linuxInfo.version,
          'id': linuxInfo.id,
          'idLike': linuxInfo.idLike,
          'versionCodename': linuxInfo.versionCodename,
          'versionId': linuxInfo.versionId,
          'prettyName': linuxInfo.prettyName,
          'buildId': linuxInfo.buildId,
          'variant': linuxInfo.variant,
          'variantId': linuxInfo.variantId,
          'machineId': linuxInfo.machineId,
        });
      }

      _logger.d('Device info retrieved successfully');
      return deviceInfo;
    } catch (e) {
      _logger.e('Failed to get device info', error: e);
      return {
        'error': e.toString(),
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Получение уникального идентификатора устройства
  Future<String?> getDeviceId() async {
    try {
      _logger.d('Getting device ID...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return windowsInfo.deviceId;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return macOsInfo.computerName;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.machineId;
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to get device ID', error: e);
      return null;
    }
  }

  /// Получение информации о дисплее
  Future<Map<String, dynamic>?> getDisplayInfo() async {
    try {
      _logger.d('Getting display info...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'widthPx': androidInfo.displayMetrics.widthPx,
          'heightPx': androidInfo.displayMetrics.heightPx,
          'xDpi': androidInfo.displayMetrics.xDpi,
          'yDpi': androidInfo.displayMetrics.yDpi,
          'density': androidInfo.displayMetrics.xDpi / 160.0,
        };
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to get display info', error: e);
      return null;
    }
  }

  /// Проверка, является ли устройство физическим
  Future<bool> isPhysicalDevice() async {
    try {
      _logger.d('Checking if device is physical...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.isPhysicalDevice;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.isPhysicalDevice;
      }
      
      return true; // По умолчанию считаем физическим
    } catch (e) {
      _logger.e('Failed to check if device is physical', error: e);
      return true;
    }
  }

  /// Получение версии операционной системы
  Future<String> getOsVersion() async {
    try {
      _logger.d('Getting OS version...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.version.release;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.systemVersion;
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        return '${windowsInfo.majorVersion}.${windowsInfo.minorVersion}.${windowsInfo.buildNumber}';
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return macOsInfo.osRelease;
      } else if (Platform.isLinux) {
        final linuxInfo = await _deviceInfo.linuxInfo;
        return linuxInfo.version;
      }
      
      return Platform.operatingSystemVersion;
    } catch (e) {
      _logger.e('Failed to get OS version', error: e);
      return Platform.operatingSystemVersion;
    }
  }

  /// Получение модели устройства
  Future<String?> getDeviceModel() async {
    try {
      _logger.d('Getting device model...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return '${androidInfo.manufacturer} ${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.model;
      } else if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return macOsInfo.modelName;
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to get device model', error: e);
      return null;
    }
  }

  /// Получение информации о процессоре
  Future<Map<String, dynamic>?> getCpuInfo() async {
    try {
      _logger.d('Getting CPU info...');
      
      final cpuInfo = <String, dynamic>{
        'numberOfProcessors': Platform.numberOfProcessors,
      };

      if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        cpuInfo.addAll({
          'activeCPUs': macOsInfo.activeCPUs,
          'cpuFrequency': macOsInfo.cpuFrequency,
        });
      }

      return cpuInfo;
    } catch (e) {
      _logger.e('Failed to get CPU info', error: e);
      return null;
    }
  }

  /// Получение информации о памяти
  Future<Map<String, dynamic>?> getMemoryInfo() async {
    try {
      _logger.d('Getting memory info...');
      
      if (Platform.isMacOS) {
        final macOsInfo = await _deviceInfo.macOsInfo;
        return {
          'memorySize': macOsInfo.memorySize,
        };
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to get memory info', error: e);
      return null;
    }
  }

  /// Получение системных функций (Android)
  Future<List<String>?> getSystemFeatures() async {
    try {
      _logger.d('Getting system features...');
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return androidInfo.systemFeatures;
      }
      
      return null;
    } catch (e) {
      _logger.e('Failed to get system features', error: e);
      return null;
    }
  }

  /// Проверка поддержки определенной функции
  Future<bool> hasSystemFeature(String feature) async {
    try {
      final features = await getSystemFeatures();
      return features?.contains(feature) ?? false;
    } catch (e) {
      _logger.e('Failed to check system feature: $feature', error: e);
      return false;
    }
  }

  /// Получение краткой информации об устройстве
  Future<Map<String, dynamic>> getDeviceSummary() async {
    try {
      _logger.d('Getting device summary...');
      
      final deviceId = await getDeviceId();
      final deviceModel = await getDeviceModel();
      final osVersion = await getOsVersion();
      final isPhysical = await isPhysicalDevice();
      
      return {
        'deviceId': deviceId,
        'deviceModel': deviceModel,
        'osVersion': osVersion,
        'platform': Platform.operatingSystem,
        'isPhysicalDevice': isPhysical,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Failed to get device summary', error: e);
      return {
        'error': e.toString(),
        'platform': Platform.operatingSystem,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Получение информации о производительности устройства
  Future<Map<String, dynamic>> getPerformanceInfo() async {
    try {
      _logger.d('Getting performance info...');
      
      final cpuInfo = await getCpuInfo();
      final memoryInfo = await getMemoryInfo();
      final displayInfo = await getDisplayInfo();
      
      return {
        'cpu': cpuInfo,
        'memory': memoryInfo,
        'display': displayInfo,
        'numberOfProcessors': Platform.numberOfProcessors,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      _logger.e('Failed to get performance info', error: e);
      return {
        'error': e.toString(),
        'numberOfProcessors': Platform.numberOfProcessors,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Проверка совместимости устройства
  Future<Map<String, dynamic>> checkDeviceCompatibility() async {
    try {
      _logger.d('Checking device compatibility...');
      
      final osVersion = await getOsVersion();
      final isPhysical = await isPhysicalDevice();
      final displayInfo = await getDisplayInfo();
      
      final compatibility = <String, dynamic>{
        'isCompatible': true,
        'warnings': <String>[],
        'errors': <String>[],
      };

      // Проверка минимальной версии Android
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        if (androidInfo.version.sdkInt < 21) {
          compatibility['isCompatible'] = false;
          compatibility['errors'].add('Android API level ${androidInfo.version.sdkInt} is not supported. Minimum required: 21');
        }
      }

      // Проверка минимальной версии iOS
      if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        final versionParts = iosInfo.systemVersion.split('.');
        final majorVersion = int.tryParse(versionParts[0]) ?? 0;
        if (majorVersion < 12) {
          compatibility['isCompatible'] = false;
          compatibility['errors'].add('iOS version ${iosInfo.systemVersion} is not supported. Minimum required: 12.0');
        }
      }

      // Проверка эмулятора
      if (!isPhysical) {
        compatibility['warnings'].add('Running on emulator/simulator. Some features may not work correctly.');
      }

      // Проверка разрешения экрана
      if (displayInfo != null) {
        final width = displayInfo['widthPx'] as int? ?? 0;
        final height = displayInfo['heightPx'] as int? ?? 0;
        if (width < 320 || height < 480) {
          compatibility['warnings'].add('Screen resolution ${width}x$height is very low. UI may not display correctly.');
        }
      }

      compatibility['osVersion'] = osVersion;
      compatibility['isPhysicalDevice'] = isPhysical;
      compatibility['timestamp'] = DateTime.now().toIso8601String();

      _logger.d('Device compatibility check completed');
      return compatibility;
    } catch (e) {
      _logger.e('Failed to check device compatibility', error: e);
      return {
        'isCompatible': false,
        'errors': ['Failed to check compatibility: ${e.toString()}'],
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }
}
