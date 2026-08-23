import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

/// Сервис для работы с разрешениями
class PermissionService {
  final Logger _logger;

  PermissionService() : _logger = Logger();

  /// Проверка статуса разрешения
  Future<PermissionStatus> checkPermission(Permission permission) async {
    try {
      _logger.d('Checking permission: ${permission.toString()}');
      final status = await permission.status;
      _logger.d('Permission ${permission.toString()} status: $status');
      return status;
    } catch (e) {
      _logger.e('Failed to check permission: ${permission.toString()}', error: e);
      return PermissionStatus.denied;
    }
  }

  /// Запрос разрешения
  Future<PermissionStatus> requestPermission(Permission permission) async {
    try {
      _logger.d('Requesting permission: ${permission.toString()}');
      final status = await permission.request();
      _logger.d('Permission ${permission.toString()} request result: $status');
      return status;
    } catch (e) {
      _logger.e('Failed to request permission: ${permission.toString()}', error: e);
      return PermissionStatus.denied;
    }
  }

  /// Проверка и запрос разрешения
  Future<PermissionStatus> checkAndRequestPermission(Permission permission) async {
    try {
      _logger.d('Checking and requesting permission: ${permission.toString()}');
      
      final status = await permission.status;
      
      if (status.isGranted) {
        _logger.d('Permission ${permission.toString()} already granted');
        return status;
      }
      
      if (status.isDenied) {
        _logger.d('Permission ${permission.toString()} denied, requesting...');
        return await permission.request();
      }
      
      if (status.isPermanentlyDenied) {
        _logger.w('Permission ${permission.toString()} permanently denied');
        return status;
      }
      
      if (status.isRestricted) {
        _logger.w('Permission ${permission.toString()} restricted');
        return status;
      }
      
      return status;
    } catch (e) {
      _logger.e('Failed to check and request permission: ${permission.toString()}', error: e);
      return PermissionStatus.denied;
    }
  }

  /// Проверка нескольких разрешений
  Future<Map<Permission, PermissionStatus>> checkPermissions(List<Permission> permissions) async {
    try {
      _logger.d('Checking multiple permissions: ${permissions.map((p) => p.toString()).join(', ')}');
      
      final results = <Permission, PermissionStatus>{};
      
      for (final permission in permissions) {
        final status = await checkPermission(permission);
        results[permission] = status;
      }
      
      _logger.d('Multiple permissions check completed');
      return results;
    } catch (e) {
      _logger.e('Failed to check multiple permissions', error: e);
      return {};
    }
  }

  /// Запрос нескольких разрешений
  Future<Map<Permission, PermissionStatus>> requestPermissions(List<Permission> permissions) async {
    try {
      _logger.d('Requesting multiple permissions: ${permissions.map((p) => p.toString()).join(', ')}');
      
      final results = <Permission, PermissionStatus>{};
      
      for (final permission in permissions) {
        final status = await requestPermission(permission);
        results[permission] = status;
      }
      
      _logger.d('Multiple permissions request completed');
      return results;
    } catch (e) {
      _logger.e('Failed to request multiple permissions', error: e);
      return {};
    }
  }

  /// Проверка и запрос нескольких разрешений
  Future<Map<Permission, PermissionStatus>> checkAndRequestPermissions(List<Permission> permissions) async {
    try {
      _logger.d('Checking and requesting multiple permissions: ${permissions.map((p) => p.toString()).join(', ')}');
      
      final results = <Permission, PermissionStatus>{};
      
      for (final permission in permissions) {
        final status = await checkAndRequestPermission(permission);
        results[permission] = status;
      }
      
      _logger.d('Multiple permissions check and request completed');
      return results;
    } catch (e) {
      _logger.e('Failed to check and request multiple permissions', error: e);
      return {};
    }
  }

  /// Проверка разрешений для камеры
  Future<PermissionStatus> checkCameraPermission() async {
    return await checkPermission(Permission.camera);
  }

  /// Запрос разрешения для камеры
  Future<PermissionStatus> requestCameraPermission() async {
    return await requestPermission(Permission.camera);
  }

  /// Проверка разрешений для микрофона
  Future<PermissionStatus> checkMicrophonePermission() async {
    return await checkPermission(Permission.microphone);
  }

  /// Запрос разрешения для микрофона
  Future<PermissionStatus> requestMicrophonePermission() async {
    return await requestPermission(Permission.microphone);
  }

  /// Проверка разрешений для телефона
  Future<PermissionStatus> checkPhonePermission() async {
    return await checkPermission(Permission.phone);
  }

  /// Запрос разрешения для телефона
  Future<PermissionStatus> requestPhonePermission() async {
    return await requestPermission(Permission.phone);
  }

  /// Проверка разрешений для SMS
  Future<PermissionStatus> checkSmsPermission() async {
    return await checkPermission(Permission.sms);
  }

  /// Запрос разрешения для SMS
  Future<PermissionStatus> requestSmsPermission() async {
    return await requestPermission(Permission.sms);
  }

  /// Проверка разрешений для контактов
  Future<PermissionStatus> checkContactsPermission() async {
    return await checkPermission(Permission.contacts);
  }

  /// Запрос разрешения для контактов
  Future<PermissionStatus> requestContactsPermission() async {
    return await requestPermission(Permission.contacts);
  }

  /// Проверка разрешений для хранилища
  Future<PermissionStatus> checkStoragePermission() async {
    if (Platform.isAndroid) {
      return await checkPermission(Permission.storage);
    } else if (Platform.isIOS) {
      return await checkPermission(Permission.photos);
    }
    return PermissionStatus.granted;
  }

  /// Запрос разрешения для хранилища
  Future<PermissionStatus> requestStoragePermission() async {
    if (Platform.isAndroid) {
      return await requestPermission(Permission.storage);
    } else if (Platform.isIOS) {
      return await requestPermission(Permission.photos);
    }
    return PermissionStatus.granted;
  }

  /// Проверка разрешений для местоположения
  Future<PermissionStatus> checkLocationPermission() async {
    return await checkPermission(Permission.location);
  }

  /// Запрос разрешения для местоположения
  Future<PermissionStatus> requestLocationPermission() async {
    return await requestPermission(Permission.location);
  }

  /// Проверка разрешений для уведомлений
  Future<PermissionStatus> checkNotificationPermission() async {
    return await checkPermission(Permission.notification);
  }

  /// Запрос разрешения для уведомлений
  Future<PermissionStatus> requestNotificationPermission() async {
    return await requestPermission(Permission.notification);
  }

  /// Проверка разрешений для календаря
  Future<PermissionStatus> checkCalendarPermission() async {
    return await checkPermission(Permission.calendar);
  }

  /// Запрос разрешения для календаря
  Future<PermissionStatus> requestCalendarPermission() async {
    return await requestPermission(Permission.calendar);
  }

  /// Проверка разрешений для сенсоров
  Future<PermissionStatus> checkSensorsPermission() async {
    return await checkPermission(Permission.sensors);
  }

  /// Запрос разрешения для сенсоров
  Future<PermissionStatus> requestSensorsPermission() async {
    return await requestPermission(Permission.sensors);
  }

  /// Проверка разрешений для Bluetooth
  Future<PermissionStatus> checkBluetoothPermission() async {
    return await checkPermission(Permission.bluetooth);
  }

  /// Запрос разрешения для Bluetooth
  Future<PermissionStatus> requestBluetoothPermission() async {
    return await requestPermission(Permission.bluetooth);
  }

  /// Проверка разрешений для управления звонками
  Future<PermissionStatus> checkManageExternalStoragePermission() async {
    if (Platform.isAndroid) {
      return await checkPermission(Permission.manageExternalStorage);
    }
    return PermissionStatus.granted;
  }

  /// Запрос разрешения для управления звонками
  Future<PermissionStatus> requestManageExternalStoragePermission() async {
    if (Platform.isAndroid) {
      return await requestPermission(Permission.manageExternalStorage);
    }
    return PermissionStatus.granted;
  }

  /// Проверка всех необходимых разрешений для приложения
  Future<Map<Permission, PermissionStatus>> checkAllRequiredPermissions() async {
    final requiredPermissions = <Permission>[
      Permission.phone,
      Permission.microphone,
      Permission.notification,
    ];

    // Добавляем платформо-зависимые разрешения
    if (Platform.isAndroid) {
      requiredPermissions.addAll([
        Permission.storage,
        Permission.camera,
        Permission.contacts,
      ]);
    } else if (Platform.isIOS) {
      requiredPermissions.addAll([
        Permission.photos,
        Permission.camera,
        Permission.contacts,
      ]);
    }

    return await checkPermissions(requiredPermissions);
  }

  /// Запрос всех необходимых разрешений для приложения
  Future<Map<Permission, PermissionStatus>> requestAllRequiredPermissions() async {
    final requiredPermissions = <Permission>[
      Permission.phone,
      Permission.microphone,
      Permission.notification,
    ];

    // Добавляем платформо-зависимые разрешения
    if (Platform.isAndroid) {
      requiredPermissions.addAll([
        Permission.storage,
        Permission.camera,
        Permission.contacts,
      ]);
    } else if (Platform.isIOS) {
      requiredPermissions.addAll([
        Permission.photos,
        Permission.camera,
        Permission.contacts,
      ]);
    }

    return await requestPermissions(requiredPermissions);
  }

  /// Проверка и запрос всех необходимых разрешений
  Future<Map<Permission, PermissionStatus>> checkAndRequestAllRequiredPermissions() async {
    final requiredPermissions = <Permission>[
      Permission.phone,
      Permission.microphone,
      Permission.notification,
    ];

    // Добавляем платформо-зависимые разрешения
    if (Platform.isAndroid) {
      requiredPermissions.addAll([
        Permission.storage,
        Permission.camera,
        Permission.contacts,
      ]);
    } else if (Platform.isIOS) {
      requiredPermissions.addAll([
        Permission.photos,
        Permission.camera,
        Permission.contacts,
      ]);
    }

    return await checkAndRequestPermissions(requiredPermissions);
  }

  /// Получение статуса разрешений в удобном формате
  Future<Map<String, dynamic>> getPermissionsStatus() async {
    try {
      _logger.d('Getting permissions status...');
      
      final permissions = await checkAllRequiredPermissions();
      final status = <String, dynamic>{
        'allGranted': true,
        'permissions': <String, String>{},
        'deniedPermissions': <String>[],
        'permanentlyDeniedPermissions': <String>[],
        'restrictedPermissions': <String>[],
        'timestamp': DateTime.now().toIso8601String(),
      };

      for (final entry in permissions.entries) {
        final permissionName = entry.key.toString().split('.').last;
        final permissionStatus = entry.value;
        
        status['permissions'][permissionName] = permissionStatus.toString();
        
        if (!permissionStatus.isGranted) {
          status['allGranted'] = false;
          
          if (permissionStatus.isDenied) {
            status['deniedPermissions'].add(permissionName);
          } else if (permissionStatus.isPermanentlyDenied) {
            status['permanentlyDeniedPermissions'].add(permissionName);
          } else if (permissionStatus.isRestricted) {
            status['restrictedPermissions'].add(permissionName);
          }
        }
      }

      _logger.d('Permissions status retrieved successfully');
      return status;
    } catch (e) {
      _logger.e('Failed to get permissions status', error: e);
      return {
        'error': e.toString(),
        'allGranted': false,
        'timestamp': DateTime.now().toIso8601String(),
      };
    }
  }

  /// Проверка, все ли необходимые разрешения предоставлены
  Future<bool> areAllRequiredPermissionsGranted() async {
    try {
      final permissions = await checkAllRequiredPermissions();
      return permissions.values.every((status) => status.isGranted);
    } catch (e) {
      _logger.e('Failed to check if all permissions are granted', error: e);
      return false;
    }
  }

  /// Открытие настроек приложения
  Future<bool> openAppSettings() async {
    try {
      _logger.d('Opening app settings...');
      final opened = await openAppSettings();
      _logger.d('App settings opened: $opened');
      return opened;
    } catch (e) {
      _logger.e('Failed to open app settings', error: e);
      return false;
    }
  }

  /// Получение описания разрешения
  String getPermissionDescription(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return 'Camera access is required for video calls and photo capture';
      case Permission.microphone:
        return 'Microphone access is required for voice calls and audio recording';
      case Permission.phone:
        return 'Phone access is required for making and receiving calls';
      case Permission.sms:
        return 'SMS access is required for sending and receiving messages';
      case Permission.contacts:
        return 'Contacts access is required for managing phone contacts';
      case Permission.storage:
        return 'Storage access is required for saving files and data';
      case Permission.location:
        return 'Location access is required for location-based features';
      case Permission.notification:
        return 'Notification access is required for receiving app notifications';
      case Permission.calendar:
        return 'Calendar access is required for managing events';
      case Permission.sensors:
        return 'Sensors access is required for device orientation and movement';
      case Permission.bluetooth:
        return 'Bluetooth access is required for wireless connectivity';
      case Permission.manageExternalStorage:
        return 'External storage management is required for file operations';
      default:
        return 'This permission is required for app functionality';
    }
  }

  /// Получение рекомендаций по разрешениям
  List<String> getPermissionRecommendations(Map<Permission, PermissionStatus> permissions) {
    final recommendations = <String>[];
    
    for (final entry in permissions.entries) {
      final permission = entry.key;
      final status = entry.value;
      
      if (status.isPermanentlyDenied) {
        recommendations.add(
          '${getPermissionDescription(permission)}. Please enable it in app settings.'
        );
      } else if (status.isDenied) {
        recommendations.add(
          '${getPermissionDescription(permission)}. Please grant this permission when prompted.'
        );
      } else if (status.isRestricted) {
        recommendations.add(
          '${getPermissionDescription(permission)}. This permission is restricted by system settings.'
        );
      }
    }
    
    return recommendations;
  }
}
