import 'package:flutter/material.dart';
import 'dart:async';
import '../services/connection_monitor_service.dart';
import '../models/connection_stats.dart';
import '../theme/app_colors.dart';

/// Виджет для отображения мониторинга соединений в реальном времени
class ConnectionMonitorWidget extends StatefulWidget {
  final String? sipServer;
  final int? sipPort;
  final String? smppServer;
  final int? smppPort;
  final bool showDetailedStats;

  const ConnectionMonitorWidget({
    Key? key,
    this.sipServer,
    this.sipPort,
    this.smppServer,
    this.smppPort,
    this.showDetailedStats = true,
  }) : super(key: key);

  @override
  State<ConnectionMonitorWidget> createState() => _ConnectionMonitorWidgetState();
}

class _ConnectionMonitorWidgetState extends State<ConnectionMonitorWidget>
    with TickerProviderStateMixin {
  final ConnectionMonitorService _monitorService = ConnectionMonitorService();
  
  late StreamSubscription<ConnectionStats> _sipStatsSubscription;
  late StreamSubscription<ConnectionStats> _smppStatsSubscription;
  late StreamSubscription<Map<String, dynamic>> _networkStatusSubscription;
  
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  
  ConnectionStats _sipStats = ConnectionStats.initial('SIP');
  ConnectionStats _smppStats = ConnectionStats.initial('SMPP');
  Map<String, dynamic> _networkStatus = {};
  
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    
    // Настройка анимации
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _pulseController.repeat(reverse: true);
    
    _initializeMonitoring();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _sipStatsSubscription.cancel();
    _smppStatsSubscription.cancel();
    _networkStatusSubscription.cancel();
    _monitorService.stopMonitoring();
    super.dispose();
  }

  void _initializeMonitoring() {
    // Подписка на обновления статистики
    _sipStatsSubscription = _monitorService.sipStatsStream.listen((stats) {
      if (mounted) {
        setState(() {
          _sipStats = stats;
        });
      }
    });

    _smppStatsSubscription = _monitorService.smppStatsStream.listen((stats) {
      if (mounted) {
        setState(() {
          _smppStats = stats;
        });
      }
    });

    _networkStatusSubscription = _monitorService.networkStatusStream.listen((status) {
      if (mounted) {
        setState(() {
          _networkStatus = status;
        });
      }
    });

    // Запуск мониторинга
    _monitorService.startMonitoring(
      sipServer: widget.sipServer,
      sipPort: widget.sipPort,
      smppServer: widget.smppServer,
      smppPort: widget.smppPort,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.all(8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildHeader(context),
          if (_isExpanded) ...[
            const Divider(height: 1),
            _buildDetailedView(context),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return InkWell(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getOverallStatusColor().withOpacity(_pulseAnimation.value),
                  ),
                );
              },
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Мониторинг соединений',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _getOverallStatusText(),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            _buildQuickStats(context),
            const SizedBox(width: 8),
            Icon(
              _isExpanded ? Icons.expand_less : Icons.expand_more,
              color: colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusDot('SIP', _sipStats.isConnected),
        const SizedBox(width: 8),
        _buildStatusDot('SMPP', _smppStats.isConnected),
      ],
    );
  }

  Widget _buildStatusDot(String label, bool isConnected) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isConnected ? AppColors.success : AppColors.error,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildDetailedView(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildConnectionCard('SIP Server', _sipStats),
          const SizedBox(height: 12),
          _buildConnectionCard('SMPP Server', _smppStats),
          const SizedBox(height: 12),
          _buildNetworkInfo(context),
          if (widget.showDetailedStats) ...[
            const SizedBox(height: 12),
            _buildActionButtons(context),
          ],
        ],
      ),
    );
  }

  Widget _buildConnectionCard(String title, ConnectionStats stats) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: stats.isConnected ? AppColors.success : AppColors.error,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: stats.isConnected ? AppColors.success : AppColors.error,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  stats.isConnected ? 'Подключено' : 'Отключено',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (stats.isConnected) ...[
            _buildStatRow('Задержка', '${stats.latency.toStringAsFixed(0)} мс'),
            _buildStatRow('Качество', stats.qualityDescription),
            _buildStatRow('Аптайм', '${stats.uptimePercentage.toStringAsFixed(1)}%'),
            if (stats.reconnectAttempts > 0)
              _buildStatRow('Переподключения', '${stats.reconnectAttempts}'),
          ] else ...[
            if (stats.errorMessage != null)
              Text(
                'Ошибка: ${stats.errorMessage}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.error,
                ),
              ),
            if (stats.reconnectAttempts > 0)
              Text(
                'Попыток переподключения: ${stats.reconnectAttempts}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkInfo(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    if (_networkStatus.isEmpty) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Сеть',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          _buildStatRow('Тип', _networkStatus['connectivity_type'] ?? 'Unknown'),
          _buildStatRow('Статус', _networkStatus['is_connected'] == true ? 'Подключено' : 'Отключено'),
          _buildStatRow('Сигнал', '${_networkStatus['signal_strength'] ?? 0}%'),
          _buildStatRow('Качество', _networkStatus['network_quality'] ?? 'Unknown'),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _performSpeedTest,
            icon: const Icon(Icons.speed, size: 16),
            label: const Text('Тест скорости'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _showDetailedStats,
            icon: const Icon(Icons.analytics, size: 16),
            label: const Text('Статистика'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
      ],
    );
  }

  Color _getOverallStatusColor() {
    if (_sipStats.isConnected && _smppStats.isConnected) {
      return AppColors.success;
    } else if (_sipStats.isConnected || _smppStats.isConnected) {
      return AppColors.warning;
    } else {
      return AppColors.error;
    }
  }

  String _getOverallStatusText() {
    final sipConnected = _sipStats.isConnected;
    final smppConnected = _smppStats.isConnected;
    
    if (sipConnected && smppConnected) {
      return 'Все соединения активны';
    } else if (sipConnected) {
      return 'Только SIP подключен';
    } else if (smppConnected) {
      return 'Только SMPP подключен';
    } else {
      return 'Нет активных соединений';
    }
  }

  void _performSpeedTest() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Запуск теста скорости...')),
    );
    
    try {
      final results = await _monitorService.performSpeedTest();
      final downloadSpeed = results['download_speed_kbps']?.toStringAsFixed(1) ?? '0';
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Скорость загрузки: $downloadSpeed kbps'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка теста: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  void _showDetailedStats() {
    final stats = _monitorService.getDetailedStats();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Детальная статистика'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Период: ${stats['period_start']} - ${stats['period_end']}'),
              const SizedBox(height: 16),
              const Text('SIP:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...stats['sip_stats'].entries.map((e) => 
                Text('${e.key}: ${e.value}')),
              const SizedBox(height: 16),
              const Text('SMPP:', style: TextStyle(fontWeight: FontWeight.bold)),
              ...stats['smpp_stats'].entries.map((e) => 
                Text('${e.key}: ${e.value}')),
              const SizedBox(height: 16),
              Text('Качество сети: ${stats['network_quality']}'),
              Text('Мониторинг активен: ${stats['monitoring_active']}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Закрыть'),
          ),
        ],
      ),
    );
  }
}
