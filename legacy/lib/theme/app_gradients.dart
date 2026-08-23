import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Градиенты для приложения GOSTsimbox Gateway
/// Обеспечивает визуальную привлекательность и консистентность
/// Основан на технических тонах с акцентами связи и безопасности
class AppGradients {
  // Приватный конструктор для предотвращения создания экземпляров
  AppGradients._();

  // Основные градиенты
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient technicalGradient = LinearGradient(
    colors: [AppColors.technical, AppColors.technicalLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient connectionGradient = LinearGradient(
    colors: [AppColors.primary, AppColors.accent],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Градиенты для статусов
  static const LinearGradient successGradient = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warningGradient = LinearGradient(
    colors: [AppColors.warning, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient errorGradient = LinearGradient(
    colors: [AppColors.error, Color(0xFFF87171)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient infoGradient = LinearGradient(
    colors: [AppColors.info, Color(0xFF60A5FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Градиенты для GOSTsimbox Gateway
  static const LinearGradient gatewayConnectedGradient = LinearGradient(
    colors: [AppColors.gatewayConnected, Color(0xFF34D399)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gatewayDisconnectedGradient = LinearGradient(
    colors: [AppColors.gatewayDisconnected, Color(0xFFF87171)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gatewayConnectingGradient = LinearGradient(
    colors: [AppColors.gatewayConnecting, Color(0xFFFBBF24)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient signalStrongGradient = LinearGradient(
    colors: [AppColors.signalStrong, Color(0xFF34D399)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient signalWeakGradient = LinearGradient(
    colors: [AppColors.signalWeak, Color(0xFFFBBF24)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient callActiveGradient = LinearGradient(
    colors: [AppColors.callActive, Color(0xFF34D399)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Градиенты для карточек
  static const LinearGradient cardGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Градиенты для кнопок
  static const LinearGradient buttonPrimaryGradient = LinearGradient(
    colors: [AppColors.buttonPrimary, AppColors.primaryLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient buttonSecondaryGradient = LinearGradient(
    colors: [AppColors.buttonSecondary, AppColors.accentLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Градиенты для навигации
  static const LinearGradient navigationGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF5F5F5)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient navigationGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF0A0A0A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Градиенты для прогресс-баров
  static const LinearGradient progressGradient = LinearGradient(
    colors: [AppColors.accent, AppColors.accentLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient progressSuccessGradient = LinearGradient(
    colors: [AppColors.success, Color(0xFF34D399)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient progressWarningGradient = LinearGradient(
    colors: [AppColors.warning, Color(0xFFFBBF24)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient progressErrorGradient = LinearGradient(
    colors: [AppColors.error, Color(0xFFF87171)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Градиенты для чипов
  static const LinearGradient chipGradient = LinearGradient(
    colors: [Color(0xFFF8F9FA), Color(0xFFE5E7EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient chipGradientDark = LinearGradient(
    colors: [Color(0xFF2A2A2A), Color(0xFF3A3A3A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Градиенты для диалогов
  static const LinearGradient dialogGradient = LinearGradient(
    colors: [Colors.white, Color(0xFFF8F9FA)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient dialogGradientDark = LinearGradient(
    colors: [Color(0xFF1A1A1A), Color(0xFF2A2A2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Методы для получения градиентов в зависимости от темы
  static LinearGradient getCardGradient(Brightness brightness) {
    return brightness == Brightness.light ? cardGradient : cardGradientDark;
  }

  static LinearGradient getNavigationGradient(Brightness brightness) {
    return brightness == Brightness.light ? navigationGradient : navigationGradientDark;
  }

  static LinearGradient getChipGradient(Brightness brightness) {
    return brightness == Brightness.light ? chipGradient : chipGradientDark;
  }

  static LinearGradient getDialogGradient(Brightness brightness) {
    return brightness == Brightness.light ? dialogGradient : dialogGradientDark;
  }

  // Градиенты для статусов подключения
  static LinearGradient getConnectionStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
      case 'online':
        return gatewayConnectedGradient;
      case 'connecting':
      case 'connecting...':
        return gatewayConnectingGradient;
      case 'disconnected':
      case 'offline':
        return gatewayDisconnectedGradient;
      default:
        return connectionGradient;
    }
  }

  // Градиенты для уровней сигнала
  static LinearGradient getSignalLevelGradient(int level) {
    if (level >= 80) {
      return signalStrongGradient;
    } else if (level >= 40) {
      return signalWeakGradient;
    } else {
      return errorGradient;
    }
  }

  // Градиенты для статусов вызовов
  static LinearGradient getCallStatusGradient(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'incoming':
      case 'outgoing':
        return callActiveGradient;
      case 'ended':
      case 'missed':
        return errorGradient;
      case 'idle':
      case 'waiting':
        return warningGradient;
      default:
        return infoGradient;
    }
  }
} 