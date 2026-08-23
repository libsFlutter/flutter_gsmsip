import 'package:flutter/material.dart';

/// Цветовая палитра для GOSTsimbox Gateway
/// Основана на технических тонах с акцентами связи и безопасности
class AppColors {
  // Приватный конструктор
  AppColors._();

  // Основные цвета бренда
  static const Color primary = Color(0xFF2563EB); // Технический синий
  static const Color primaryLight = Color(0xFF3B82F6); // Светло-синий
  static const Color primaryDark = Color(0xFF1D4ED8); // Темно-синий
  
  // Акцентные цвета
  static const Color accent = Color(0xFF10B981); // Зеленый связи
  static const Color accentLight = Color(0xFF34D399); // Светло-зеленый
  static const Color accentDark = Color(0xFF059669); // Темно-зеленый
  
  // Технические цвета
  static const Color technical = Color(0xFF8B5CF6); // Фиолетовый
  static const Color technicalLight = Color(0xFFA78BFA); // Светло-фиолетовый
  static const Color technicalDark = Color(0xFF7C3AED); // Темно-фиолетовый
  
  // Светлая тема
  static const ColorScheme light = ColorScheme(
    brightness: Brightness.light,
    primary: primary,
    onPrimary: Colors.white,
    secondary: accent,
    onSecondary: Colors.white,
    tertiary: technical,
    onTertiary: Colors.white,
    error: Color(0xFFEF4444),
    onError: Colors.white,
    background: lightBackgroundPrimary,
    onBackground: lightTextPrimary,
    surface: lightCardBackground,
    onSurface: lightTextPrimary,
    surfaceVariant: lightCardBackgroundSecondary,
    onSurfaceVariant: lightTextSecondary,
    outline: lightBorder,
    outlineVariant: lightBorderSecondary,
    shadow: lightShadow,
    scrim: Colors.black12,
    inverseSurface: darkCardBackground,
    onInverseSurface: darkTextPrimary,
    inversePrimary: primaryLight,
    surfaceTint: primary,
  );

  // Темная тема
  static const ColorScheme dark = ColorScheme(
    brightness: Brightness.dark,
    primary: primaryLight,
    onPrimary: Colors.white,
    secondary: accentLight,
    onSecondary: Colors.white,
    tertiary: technicalLight,
    onTertiary: Colors.white,
    error: Color(0xFFF87171),
    onError: Colors.white,
    background: darkBackgroundPrimary,
    onBackground: darkTextPrimary,
    surface: darkCardBackground,
    onSurface: darkTextPrimary,
    surfaceVariant: darkCardBackgroundSecondary,
    onSurfaceVariant: darkTextSecondary,
    outline: darkBorder,
    outlineVariant: darkBorderSecondary,
    shadow: darkShadow,
    scrim: Colors.black38,
    inverseSurface: lightCardBackground,
    onInverseSurface: lightTextPrimary,
    inversePrimary: primary,
    surfaceTint: primaryLight,
  );

  // Светлая тема - фоны
  static const Color lightBackgroundPrimary = Color(0xFFFAFAFA);
  static const Color lightBackgroundSecondary = Color(0xFFF5F5F5);
  static const Color lightCardBackground = Colors.white;
  static const Color lightCardBackgroundSecondary = Color(0xFFF8F9FA);
  static const Color lightNavigationBackground = Colors.white;
  static const Color lightInputBackground = Color(0xFFF8F9FA);

  // Светлая тема - тексты
  static const Color lightTextPrimary = Color(0xFF1F2937);
  static const Color lightTextSecondary = Color(0xFF6B7280);
  static const Color lightTextTertiary = Color(0xFF9CA3AF);
  static const Color lightNavigationText = Color(0xFF1F2937);

  // Светлая тема - границы и тени
  static const Color lightBorder = Color(0xFFE5E7EB);
  static const Color lightBorderSecondary = Color(0xFFF3F4F6);
  static const Color lightBorderFocused = primary;
  static const Color lightInputBorder = Color(0xFFD1D5DB);
  static const Color lightInputBorderFocused = primary;
  static const Color lightShadow = Color(0x1A000000);
  static const Color lightCardShadow = Color(0x0A000000);

  // Темная тема - фоны
  static const Color darkBackgroundPrimary = Color(0xFF0A0A0A);
  static const Color darkBackgroundSecondary = Color(0xFF1A1A1A);
  static const Color darkCardBackground = Color(0xFF1A1A1A);
  static const Color darkCardBackgroundSecondary = Color(0xFF2A2A2A);
  static const Color darkNavigationBackground = Color(0xFF1A1A1A);
  static const Color darkInputBackground = Color(0xFF2A2A2A);

  // Темная тема - тексты
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
  static const Color darkTextTertiary = Color(0xFF94A3B8);
  static const Color darkNavigationText = Color(0xFFF8FAFC);

  // Темная тема - границы и тени
  static const Color darkBorder = Color(0xFF2A2A2A);
  static const Color darkBorderSecondary = Color(0xFF3A3A3A);
  static const Color darkBorderFocused = primaryLight;
  static const Color darkInputBorder = Color(0xFF3A3A3A);
  static const Color darkInputBorderFocused = primaryLight;
  static const Color darkShadow = Color(0x40000000);
  static const Color darkCardShadow = Color(0x20000000);

  // Статусные цвета
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Кнопки
  static const Color buttonPrimary = primary;
  static const Color buttonSecondary = accent;
  static const Color buttonText = Colors.white;
  static const Color buttonDisabled = Color(0xFF9CA3AF);

  // Переключатели
  static const Color switchActive = accent;
  static const Color switchInactive = Color(0xFFD1D5DB);
  static const Color switchActiveDark = accentLight;
  static const Color switchInactiveDark = Color(0xFF3A3A3A);

  // Градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient technicalGradient = LinearGradient(
    colors: [technical, technicalLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient connectionGradient = LinearGradient(
    colors: [primary, accent],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Специальные цвета для GOSTsimbox Gateway
  static const Color gatewayConnected = success;
  static const Color gatewayDisconnected = error;
  static const Color gatewayConnecting = warning;
  static const Color gatewayCalibrating = info;
  static const Color signalStrong = success;
  static const Color signalWeak = warning;
  static const Color signalNone = error;
  static const Color callActive = accent;
  static const Color callInactive = darkTextSecondary;
  static const Color smsUnread = warning;
  static const Color smsRead = darkTextSecondary;

  // Цвета для прогресс-баров
  static const Color progressBackground = Color(0xFFE5E7EB);
  static const Color progressFill = accent;

  // Методы для получения цветов в зависимости от темы
  static Color getBackgroundPrimary(Brightness brightness) {
    return brightness == Brightness.light ? lightBackgroundPrimary : darkBackgroundPrimary;
  }

  static Color getBackgroundSecondary(Brightness brightness) {
    return brightness == Brightness.light ? lightBackgroundSecondary : darkBackgroundSecondary;
  }

  static Color getBackgroundTertiary(Brightness brightness) {
    return brightness == Brightness.light ? lightBackgroundSecondary : darkBackgroundSecondary;
  }

  static Color getTextPrimary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;
  }

  static Color getTextSecondary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;
  }

  static Color getTextTertiary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextTertiary : darkTextTertiary;
  }

  static Color getCardBackground(Brightness brightness) {
    return brightness == Brightness.light ? lightCardBackground : darkCardBackground;
  }

  static Color getCardBackgroundSecondary(Brightness brightness) {
    return brightness == Brightness.light ? lightCardBackgroundSecondary : darkCardBackgroundSecondary;
  }

  static Color getCardShadow(Brightness brightness) {
    return brightness == Brightness.light ? lightCardShadow : darkCardShadow;
  }

  static Color getNavigationBackground(Brightness brightness) {
    return brightness == Brightness.light ? lightNavigationBackground : darkNavigationBackground;
  }

  static Color getNavigationText(Brightness brightness) {
    return brightness == Brightness.light ? lightNavigationText : darkNavigationText;
  }

  static Color getDialogBackground(Brightness brightness) {
    return brightness == Brightness.light ? lightCardBackground : darkCardBackground;
  }

  static Color getDialogText(Brightness brightness) {
    return brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;
  }

  static Color getDialogTextSecondary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;
  }

  static Color getIconPrimary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;
  }

  static Color getIconSecondary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextSecondary : darkTextSecondary;
  }

  static Color getIconTertiary(Brightness brightness) {
    return brightness == Brightness.light ? lightTextTertiary : darkTextTertiary;
  }

  static Color getInputBackground(Brightness brightness) {
    return brightness == Brightness.light ? lightInputBackground : darkInputBackground;
  }

  static Color getInputBorder(Brightness brightness) {
    return brightness == Brightness.light ? lightInputBorder : darkInputBorder;
  }

  static Color getInputBorderFocused(Brightness brightness) {
    return brightness == Brightness.light ? lightInputBorderFocused : darkInputBorderFocused;
  }

  static Color getInputText(Brightness brightness) {
    return brightness == Brightness.light ? lightTextPrimary : darkTextPrimary;
  }

  static List<Color> getCardGradient(Brightness brightness) {
    return brightness == Brightness.light 
        ? [lightCardBackground, lightCardBackgroundSecondary]
        : [darkCardBackground, darkCardBackgroundSecondary];
  }
} 