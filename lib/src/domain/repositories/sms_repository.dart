/// Интерфейс репозитория для работы с SMS
/// Определяет контракт для доступа к SMS данным
import '../entities/sms_entity.dart';

abstract class SmsRepository {
  /// Получить все SMS сообщения
  Future<List<SmsMessage>> getAllMessages();
  
  /// Получить сообщения по типу
  Future<List<SmsMessage>> getMessagesByType(SmsType type);
  
  /// Получить сообщения по номеру
  Future<List<SmsMessage>> getMessagesByNumber(String number);
  
  /// Отправить SMS
  Future<bool> sendSms(String number, String message);
  
  /// Удалить SMS
  Future<bool> deleteSms(String messageId);
  
  /// Отметить SMS как прочитанное
  Future<bool> markAsRead(String messageId);
  
  /// Поиск сообщений
  Future<List<SmsMessage>> searchMessages(String query);
  
  /// Получить статистику SMS
  Future<Map<String, int>> getMessageCounts();
  
  /// Обновить сообщения
  Future<void> refreshMessages();
  
  /// Проверить разрешения
  Future<bool> hasPermissions();
  
  /// Запросить разрешения
  Future<bool> requestPermissions();
  
  /// Подписаться на обновления сообщений
  Stream<List<SmsMessage>> get messagesStream;
  
  /// Подписаться на новые сообщения
  Stream<SmsMessage> get newMessageStream;
}
