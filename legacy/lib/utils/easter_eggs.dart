
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class EasterEggs {
  static List<String> getDeveloperMessages(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.developerMessage_1,
      l10n.developerMessage_2,
      l10n.developerMessage_3,
      l10n.developerMessage_4,
      l10n.developerMessage_5,
      l10n.developerMessage_6,
      l10n.developerMessage_7,
      l10n.developerMessage_8,
      l10n.developerMessage_9,
      l10n.developerMessage_10,
    ];
  }

  static const List<String> secretCommands = [
    'Мозгач108',
    'Мозгач',
    'Brain',
    'Easter Egg',
    'Пасхалка',
    'Секрет',
    'Магия',
    'Кофе',
    'Кот',
  ];

  static Map<String, String> getSecretResponses(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return {
      'Мозгач108': l10n.secretResponse_mozgach108,
      'Мозгач': l10n.secretResponse_mozgach,
      'Brain': l10n.secretResponse_brain,
      'Easter Egg': l10n.secretResponse_easterEgg,
      'Пасхалка': l10n.secretResponse_paskhalka,
      'Секрет': l10n.secretResponse_secret,
      'Магия': l10n.secretResponse_magic,
      'Кофе': l10n.secretResponse_coffee,
      'Кот': l10n.secretResponse_cat,
    };
  }

  static List<String> getMotivationalQuotes(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      l10n.motivationalQuote_1,
      l10n.motivationalQuote_2,
      l10n.motivationalQuote_3,
      l10n.motivationalQuote_4,
      l10n.motivationalQuote_5,
      l10n.motivationalQuote_6,
      l10n.motivationalQuote_7,
    ];
  }

  static String getRandomDeveloperMessage(BuildContext context) {
    final messages = getDeveloperMessages(context);
    final random = Random();
    return messages[random.nextInt(messages.length)];
  }

  static String? checkSecretCommand(BuildContext context, String input) {
    final normalizedInput = input.toLowerCase().trim();
    final responses = getSecretResponses(context);

    for (final command in secretCommands) {
      if (normalizedInput.contains(command.toLowerCase())) {
        return responses[command];
      }
    }

    return null;
  }

  static bool isSecretCommand(BuildContext context, String input) {
    return checkSecretCommand(context, input) != null;
  }

  static String getMotivationalQuote(BuildContext context) {
    final quotes = getMotivationalQuotes(context);
    final random = Random();
    return quotes[random.nextInt(quotes.length)];
  }
}
