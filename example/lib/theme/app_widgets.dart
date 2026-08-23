import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_gradients.dart';

/// Общие виджеты приложения GOSTsimbox Gateway
/// Обеспечивает консистентность UI компонентов
/// Поддерживает светлую и темную темы
/// Основан на технических тонах с акцентами связи и безопасности
class AppWidgets {
  // Приватный конструктор для предотвращения создания экземпляров
  AppWidgets._();

  /// Карточка с градиентным фоном
  static Widget gradientCard({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    List<Color>? colors,
    AlignmentGeometry? begin,
    AlignmentGeometry? end,
    Brightness? brightness,
  }) {
    final themeBrightness = brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final cardColors = colors ?? AppColors.getCardGradient(themeBrightness);
    
    return Container(
      padding: padding ?? const EdgeInsets.all(AppDimensions.cardPadding),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.cardRadius),
        gradient: LinearGradient(
          colors: cardColors,
          begin: begin ?? Alignment.topLeft,
          end: end ?? Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }

  /// Кнопка с градиентом
  static Widget gradientButton({
    required String text,
    required VoidCallback onPressed,
    IconData? icon,
    bool isLoading = false,
    EdgeInsetsGeometry? padding,
    double? borderRadius,
    List<Color>? colors,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusM),
        gradient: LinearGradient(
          colors: colors ?? [AppColors.primary, AppColors.accent],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: padding ?? const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingXXL,
            vertical: AppDimensions.paddingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.radiusM),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: AppDimensions.loadingIndicatorSize,
                height: AppDimensions.loadingIndicatorSize,
                child: CircularProgressIndicator(
                  strokeWidth: AppDimensions.loadingIndicatorStrokeWidth,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.buttonText),
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: AppColors.buttonText),
                    const SizedBox(width: AppDimensions.paddingS),
                  ],
                  Text(
                    text,
                    style: const TextStyle(
                      color: AppColors.buttonText,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  /// Карточка статуса
  static Widget statusCard({
    required String title,
    required String status,
    IconData? icon,
    Color? statusColor,
    String? subtitle,
    VoidCallback? onTap,
    Brightness? brightness,
  }) {
    final themeBrightness = brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final color = statusColor ?? AppColors.success;
    
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        child: Padding(
          padding: const EdgeInsets.all(AppDimensions.cardPadding),
          child: Row(
            children: [
              Container(
                width: AppDimensions.iconSizeXL,
                height: AppDimensions.iconSizeXL,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                  border: Border.all(
                    color: color.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Icon(
                  icon ?? Icons.info,
                  color: color,
                  size: AppDimensions.iconSizeM,
                ),
              ),
              const SizedBox(width: AppDimensions.paddingL),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.getTextSecondary(themeBrightness),
                      ),
                    ),
                    const SizedBox(height: AppDimensions.paddingXS),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.getTextTertiary(themeBrightness),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (onTap != null)
                Icon(
                  Icons.arrow_forward_ios,
                  color: AppColors.getTextTertiary(themeBrightness),
                  size: AppDimensions.iconSizeS,
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Индикатор прогресса с градиентом
  static Widget gradientProgressIndicator({
    required double value,
    double? height,
    double? borderRadius,
    List<Color>? colors,
    String? label,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: AppDimensions.paddingXS),
        ],
        Container(
          height: height ?? AppDimensions.progressBarHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.progressBarRadius),
            color: AppColors.progressBackground,
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius ?? AppDimensions.progressBarRadius),
                gradient: LinearGradient(
                  colors: colors ?? [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Чип с градиентом
  static Widget gradientChip({
    required String label,
    IconData? icon,
    VoidCallback? onTap,
    bool isSelected = false,
    List<Color>? colors,
    Brightness? brightness,
  }) {
    final themeBrightness = brightness ?? WidgetsBinding.instance.platformDispatcher.platformBrightness;
    final chipColors = colors ?? (isSelected 
      ? [AppColors.primary, AppColors.primaryLight]
      : AppGradients.getChipGradient(themeBrightness).colors);
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.paddingM,
          vertical: AppDimensions.paddingS,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.chipRadius),
          gradient: LinearGradient(
            colors: chipColors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          border: isSelected 
            ? Border.all(color: AppColors.primary, width: 2)
            : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: AppDimensions.iconSizeS,
                color: isSelected ? Colors.white : AppColors.getTextSecondary(themeBrightness),
              ),
              const SizedBox(width: AppDimensions.paddingXS),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppColors.getTextSecondary(themeBrightness),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Индикатор сигнала
  static Widget signalIndicator({
    required int signalLevel,
    double? size,
    bool showBars = true,
    bool showPercentage = true,
  }) {
    final signalColor = _getSignalColor(signalLevel);
    final signalText = _getSignalText(signalLevel);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.signal_cellular_alt,
          color: signalColor,
          size: size ?? AppDimensions.signalIndicatorSize,
        ),
        if (showBars) ...[
          const SizedBox(width: AppDimensions.paddingXS),
          _buildSignalBars(signalLevel, signalColor),
        ],
        if (showPercentage) ...[
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            '$signalLevel%',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: signalColor,
            ),
          ),
        ],
      ],
    );
  }

  /// Индикатор статуса подключения
  static Widget connectionIndicator({
    required String status,
    double? size,
    bool showText = true,
  }) {
    final statusColor = _getConnectionColor(status);
    final statusIcon = _getConnectionIcon(status);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          statusIcon,
          color: statusColor,
          size: size ?? AppDimensions.iconSizeM,
        ),
        if (showText) ...[
          const SizedBox(width: AppDimensions.paddingS),
          Text(
            status,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: statusColor,
            ),
          ),
        ],
      ],
    );
  }

  /// Индикатор статуса вызова
  static Widget callStatusIndicator({
    required String status,
    String? phoneNumber,
    String? duration,
    double? size,
  }) {
    final callColor = _getCallColor(status);
    final callIcon = _getCallIcon(status);
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          callIcon,
          color: callColor,
          size: size ?? AppDimensions.iconSizeM,
        ),
        const SizedBox(width: AppDimensions.paddingS),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: callColor,
              ),
            ),
            if (phoneNumber != null)
              Text(
                phoneNumber,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
            if (duration != null)
              Text(
                duration,
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.grey,
                ),
              ),
          ],
        ),
      ],
    );
  }

  // Вспомогательные методы
  static Color _getSignalColor(int level) {
    if (level >= 80) return AppColors.signalStrong;
    if (level >= 60) return const Color(0xFF34D399);
    if (level >= 40) return AppColors.signalWeak;
    if (level >= 20) return const Color(0xFFF97316);
    return AppColors.error;
  }

  static String _getSignalText(int level) {
    if (level >= 80) return 'Excellent';
    if (level >= 60) return 'Good';
    if (level >= 40) return 'Fair';
    if (level >= 20) return 'Poor';
    return 'Very Poor';
  }

  static Color _getConnectionColor(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
      case 'online':
        return AppColors.gatewayConnected;
      case 'connecting':
      case 'connecting...':
        return AppColors.gatewayConnecting;
      case 'disconnected':
      case 'offline':
        return AppColors.gatewayDisconnected;
      default:
        return AppColors.info;
    }
  }

  static IconData _getConnectionIcon(String status) {
    switch (status.toLowerCase()) {
      case 'connected':
      case 'online':
        return Icons.check_circle;
      case 'connecting':
      case 'connecting...':
        return Icons.sync;
      case 'disconnected':
      case 'offline':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  static Color _getCallColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'incoming':
      case 'outgoing':
        return AppColors.callActive;
      case 'ended':
      case 'missed':
        return AppColors.error;
      case 'idle':
      case 'waiting':
        return AppColors.warning;
      default:
        return AppColors.info;
    }
  }

  static IconData _getCallIcon(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Icons.call;
      case 'incoming':
        return Icons.call_received;
      case 'outgoing':
        return Icons.call_made;
      case 'ended':
        return Icons.call_end;
      case 'missed':
        return Icons.call_missed;
      case 'idle':
      case 'waiting':
        return Icons.phone_in_talk;
      default:
        return Icons.phone;
    }
  }

  static Widget _buildSignalBars(int level, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final barHeight = (index + 1) * 4.0;
        final isActive = level >= (index + 1) * 20;
        
        return Container(
          width: 3,
          height: barHeight,
          margin: const EdgeInsets.symmetric(horizontal: 1),
          decoration: BoxDecoration(
            color: isActive ? color : color.withOpacity(0.3),
            borderRadius: BorderRadius.circular(1.5),
          ),
        );
      }),
    );
  }
} 