import 'package:logger/logger.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../core/utils/app_constants.dart';
import 'permission_service.dart';

/// Сервис для работы с уведомлениями
class NotificationService {
  final Logger _logger;
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final PermissionService _permissionService;

  NotificationService() 
    : _logger = Logger(),
      _notificationsPlugin = FlutterLocalNotificationsPlugin(),
      _permissionService = PermissionService();

  /// Инициализация сервиса
  Future<void> initialize() async {
    try {
      _logger.i('Initializing notification service...');
      
      // Проверяем разрешения на уведомления
      final permissionStatus = await _permissionService.checkNotificationPermission();
      if (permissionStatus != PermissionStatus.granted) {
        await _permissionService.requestNotificationPermission();
      }
      
      // Инициализируем плагин уведомлений
      const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      
      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );
      
      await _notificationsPlugin.initialize(initSettings);
      
      // Создаем канал уведомлений для Android
      await _createNotificationChannel();
      
      _logger.i('Notification service initialized successfully');
    } catch (e) {
      _logger.e('Failed to initialize notification service', error: e);
      rethrow;
    }
  }

  /// Очистка ресурсов
  Future<void> dispose() async {
    try {
      _logger.i('Disposing notification service...');
      
      // Отменяем все активные уведомления
      await _notificationsPlugin.cancelAll();
      
      _logger.i('Notification service disposed successfully');
    } catch (e) {
      _logger.e('Failed to dispose notification service', error: e);
    }
  }

  /// Создание канала уведомлений для Android
  Future<void> _createNotificationChannel() async {
    const androidChannel = AndroidNotificationChannel(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      description: AppConstants.notificationChannelDescription,
      importance: Importance.high,
    );

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  /// Показать уведомление
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _notificationsPlugin.show(
        id,
        title,
        body,
        notificationDetails,
        payload: payload,
      );
    } catch (e) {
      _logger.e('Failed to show notification', error: e);
    }
  }
}
