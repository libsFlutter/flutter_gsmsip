import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/theme_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_widgets.dart';
import '../theme/app_dimensions.dart';

/// Виджет для отображения статуса подключения
class StatusIndicator extends StatelessWidget {
  final String status;
  final String? subtitle;
  final IconData? icon;
  final VoidCallback? onTap;

  const StatusIndicator({
    Key? key,
    required this.status,
    this.subtitle,
    this.icon,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final statusColor = themeService.getConnectionStatusColor(status);
        final statusIcon = icon ?? _getStatusIcon(status);
        
        return AppWidgets.statusCard(
          title: 'Connection Status',
          status: status,
          icon: statusIcon,
          statusColor: statusColor,
          subtitle: subtitle,
          onTap: onTap,
        );
      },
    );
  }

  IconData _getStatusIcon(String status) {
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
}

/// Виджет для отображения уровня сигнала
class SignalIndicator extends StatelessWidget {
  final int signalLevel;
  final String? subtitle;

  const SignalIndicator({
    Key? key,
    required this.signalLevel,
    this.subtitle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final signalColor = themeService.getSignalLevelColor(signalLevel);
        final signalText = _getSignalText(signalLevel);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.iconSizeXL,
                  height: AppDimensions.iconSizeXL,
                  decoration: BoxDecoration(
                    color: signalColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: signalColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    Icons.signal_cellular_alt,
                    color: signalColor,
                    size: AppDimensions.iconSizeM,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Signal Level',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        signalText,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: signalColor,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        '$signalLevel%',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppWidgets.signalIndicator(
                  signalLevel: signalLevel,
                  showBars: true,
                  showPercentage: false,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getSignalText(int level) {
    if (level >= 80) {
      return 'Excellent';
    } else if (level >= 60) {
      return 'Good';
    } else if (level >= 40) {
      return 'Fair';
    } else if (level >= 20) {
      return 'Poor';
    } else {
      return 'Very Poor';
    }
  }


}

/// Виджет для отображения статуса вызова
class CallStatusIndicator extends StatelessWidget {
  final String callStatus;
  final String? phoneNumber;
  final String? duration;

  const CallStatusIndicator({
    Key? key,
    required this.callStatus,
    this.phoneNumber,
    this.duration,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeService>(
      builder: (context, themeService, child) {
        final callColor = themeService.getCallStatusColor(callStatus);
        final callIcon = _getCallIcon(callStatus);
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.cardPadding),
            child: Row(
              children: [
                Container(
                  width: AppDimensions.iconSizeXL,
                  height: AppDimensions.iconSizeXL,
                  decoration: BoxDecoration(
                    color: callColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppDimensions.radiusM),
                    border: Border.all(
                      color: callColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    callIcon,
                    color: callColor,
                    size: AppDimensions.iconSizeM,
                  ),
                ),
                const SizedBox(width: AppDimensions.paddingL),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Call Status',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: AppDimensions.paddingXS),
                      Text(
                        callStatus,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: callColor,
                        ),
                      ),
                      if (phoneNumber != null) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          phoneNumber!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                      if (duration != null) ...[
                        const SizedBox(height: AppDimensions.paddingXS),
                        Text(
                          duration!,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AppWidgets.callStatusIndicator(
                  status: callStatus,
                  phoneNumber: phoneNumber,
                  duration: duration,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getCallIcon(String status) {
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
} 