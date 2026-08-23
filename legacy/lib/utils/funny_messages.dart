import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class FunnyMessages {
  static String getConnectionError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.connectionError_1,
      l10n.connectionError_2,
      l10n.connectionError_3,
      l10n.connectionError_4,
      l10n.connectionError_5,
      l10n.connectionError_6,
      l10n.connectionError_7,
      l10n.connectionError_8,
      l10n.connectionError_9,
      l10n.connectionError_10,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getSetupError(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.setupError_1,
      l10n.setupError_2,
      l10n.setupError_3,
      l10n.setupError_4,
      l10n.setupError_5,
      l10n.setupError_6,
      l10n.setupError_7,
      l10n.setupError_8,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getSuccessMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.successMessage_1,
      l10n.successMessage_2,
      l10n.successMessage_3,
      l10n.successMessage_4,
      l10n.successMessage_5,
      l10n.successMessage_6,
      l10n.successMessage_7,
      l10n.successMessage_8,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getLoadingMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.loadingMessage_1,
      l10n.loadingMessage_2,
      l10n.loadingMessage_3,
      l10n.loadingMessage_4,
      l10n.loadingMessage_5,
      l10n.loadingMessage_6,
      l10n.loadingMessage_7,
      l10n.loadingMessage_8,
      l10n.loadingMessage_9,
      l10n.loadingMessage_10,
      l10n.loadingMessage_11,
      l10n.loadingMessage_12,
      l10n.loadingMessage_13,
      l10n.loadingMessage_14,
      l10n.loadingMessage_15,
      l10n.loadingMessage_16,
      l10n.loadingMessage_17,
      l10n.loadingMessage_18,
    ];
    return messages[Random().nextInt(messages.length)];
  }

  static String getMotivationalMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final messages = [
      l10n.motivationalMessage_1,
      l10n.motivationalMessage_2,
      l10n.motivationalMessage_3,
      l10n.motivationalMessage_4,
      l10n.motivationalMessage_5,
      l10n.motivationalMessage_6,
      l10n.motivationalMessage_7,
      l10n.motivationalMessage_8,
      l10n.motivationalMessage_9,
      l10n.motivationalMessage_10,
    ];
    return messages[Random().nextInt(messages.length)];
  }
}
