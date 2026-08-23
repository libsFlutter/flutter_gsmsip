import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class ClipboardService {
  static final ClipboardService _instance = ClipboardService._internal();
  factory ClipboardService() => _instance;
  ClipboardService._internal();

  /// Копирует текст в буфер обмена
  Future<void> copyToClipboard(String text) async {
    try {
      await Clipboard.setData(ClipboardData(text: text));
    } catch (e) {
      throw Exception('Failed to copy to clipboard: $e');
    }
  }

  /// Получает текст из буфера обмена
  Future<String?> getFromClipboard() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text;
    } catch (e) {
      throw Exception('Failed to get from clipboard: $e');
    }
  }

  /// Проверяет, есть ли текст в буфере обмена
  Future<bool> hasData() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      return clipboardData?.text?.isNotEmpty ?? false;
    } catch (e) {
      return false;
    }
  }
}
