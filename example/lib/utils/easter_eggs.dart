import 'dart:math';
import 'package:flutter/material.dart';

class EasterEggs {
  static List<String> getDeveloperMessages(BuildContext context) {
    return [
      'Разработчик любит кофе больше, чем сон.',
      'Этот код писался с любовью и терпением.',
      'Баги? Нет, это фичи!',
      'Разработчик слушает музыку и пишет код.',
      'Ошибки — это просто возможности для обучения.',
      'Код работает на продакшене (почти).',
      'Разработчик верит в магию кода.',
      'Этот экран создан вручную с заботой.',
      'Разработчик знает все секретные комбинации.',
      'Код написан в состоянии потока.',
    ];
  }

  static String? checkSecretCommand(BuildContext context, String input) {
    final secretCommands = ['secret', 'debug', 'dev mode', 'konami'];
    if (secretCommands.contains(input.toLowerCase())) {
      return 'Секретная команда активирована!';
    }
    return null;
  }

  static String getMotivationalQuote(BuildContext context) {
    final quotes = [
      'Код — это поэзия будущего.',
      'Каждая строка кода имеет значение.',
      'Программирование — это искусство.',
      'Создавай, тестируй, повторяй.',
      'Код меняет мир к лучшему.',
    ];
    return quotes[Random().nextInt(quotes.length)];
  }
}
