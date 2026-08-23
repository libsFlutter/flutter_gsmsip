import 'dart:math';
import 'package:flutter/material.dart';

class FunnyMessages {
  static String getConnectionError(BuildContext context) {
    final messages = [
      'Упс! Что-то пошло не так при подключении.',
      'Сервер не отвечает. Попробуйте позже.',
      'Проблемы с сетью. Проверьте соединение.',
      'Сервер решил вздремнуть. Попробуйте через минуту.',
      'Хьюстон, у нас проблема с подключением!',
      'Сервер играет в прятки. Не можем его найти.',
      'Ой! Кажется, сервер ушёл на перерыв.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getSetupError(BuildContext context) {
    final messages = [
      'Настройки не сохранены. Проверьте данные.',
      'Что-то пошло не так при настройке.',
      'Сервер не принял настройки. Попробуйте снова.',
      'Упс! Настройки не применены.',
      'Ошибка настройки. Проверьте соединение.',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getSuccessMessage(BuildContext context) {
    final messages = [
      'Успешно! Всё работает как надо.',
      'Готово! Настройки применены.',
      'Отлично! Сервер подключён.',
      'Супер! Всё настроено.',
      'Готово к работе!',
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getMotivationalMessage(BuildContext context) {
    final messages = [
      'Вы отлично справляетесь! Так держать!',
      'Продолжайте в том же духе!',
      'Каждый день — новый прогресс!',
      'Вы на правильном пути!',
      'Не сдавайтесь, успех близок!',
    ];
    return messages[Random().nextInt(messages.length)];
  }
}
