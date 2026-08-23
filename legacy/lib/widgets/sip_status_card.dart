import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import '../models/sip_connection.dart';
import '../theme/app_colors.dart';

class SipStatusCard extends StatelessWidget {
  final SipConnection connection;

  const SipStatusCard({
    Key? key,
    required this.connection,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: _getStatusColor(connection.status).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _getStatusColor(connection.status).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    _getStatusIcon(connection.status),
                    color: _getStatusColor(connection.status),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SIP Connection',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _getStatusText(connection.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _getStatusColor(connection.status),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                if (connection.isRegistered)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.success.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.success.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Registered',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: 'Server',
                    value: connection.server,
                    icon: Icons.dns,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: 'Port',
                    value: '${connection.port}',
                    icon: Icons.settings_ethernet,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: 'Transport',
                    value: connection.transport,
                    icon: Icons.network_check,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Connection Quality',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildQualityMetric(
                    context: context,
                    label: 'MOS',
                    value: connection.mos.toStringAsFixed(1),
                    color: _getMosColor(connection.mos),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQualityMetric(
                    context: context,
                    label: 'Jitter',
                    value: '${connection.jitter.toStringAsFixed(1)}ms',
                    color: _getJitterColor(connection.jitter),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQualityMetric(
                    context: context,
                    label: 'Latency',
                    value: '${connection.latency.toStringAsFixed(1)}ms',
                    color: _getLatencyColor(connection.latency),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildQualityMetric(
                    context: context,
                    label: 'Packet Loss',
                    value: '${connection.packetLoss.toStringAsFixed(1)}%',
                    color: _getPacketLossColor(connection.packetLoss),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: 'Bandwidth In',
                    value: '${connection.bandwidthIn.toStringAsFixed(0)} kbps',
                    icon: Icons.download,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoItem(
                    context: context,
                    label: 'Bandwidth Out',
                    value: '${connection.bandwidthOut.toStringAsFixed(0)} kbps',
                    icon: Icons.upload,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Codecs',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.onSurface,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...connection.activeCodecs.map((codec) => _buildCodecChip(
                  context,
                  codec,
                  isActive: true,
                )),
                ...connection.supportedCodecs
                    .where((codec) => !connection.activeCodecs.contains(codec))
                    .map((codec) => _buildCodecChip(
                      context,
                      codec,
                      isActive: false,
                    )),
              ],
            ),
            if (connection.isRegistered) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'Last Registration',
                      value: _formatDateTime(connection.lastRegistration),
                      icon: Icons.schedule,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildInfoItem(
                      context: context,
                      label: 'Expires',
                      value: _formatDateTime(connection.registrationExpiry),
                      icon: Icons.timer,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: 12,
              color: colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildQualityMetric({
    required BuildContext context,
    required String label,
    required String value,
    required Color color,
  }) {
    final theme = Theme.of(context);
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCodecChip(BuildContext context, String codec, {required bool isActive}) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.primary.withOpacity(0.2)
            : colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? AppColors.primary.withOpacity(0.3)
              : colorScheme.outline.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        codec,
        style: theme.textTheme.bodySmall?.copyWith(
          color: isActive ? AppColors.primary : colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'connected':
        return Icons.check_circle;
      case 'connecting':
        return Icons.sync;
      case 'disconnected':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'connected':
        return AppColors.success;
      case 'connecting':
        return AppColors.warning;
      case 'disconnected':
        return AppColors.error;
      default:
        return AppColors.info;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'connected':
        return 'Connected';
      case 'connecting':
        return 'Connecting...';
      case 'disconnected':
        return 'Disconnected';
      default:
        return 'Unknown';
    }
  }

  Color _getMosColor(double mos) {
    if (mos >= 4.0) return AppColors.success;
    if (mos >= 3.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _getJitterColor(double jitter) {
    if (jitter <= 20) return AppColors.success;
    if (jitter <= 50) return AppColors.warning;
    return AppColors.error;
  }

  Color _getLatencyColor(double latency) {
    if (latency <= 100) return AppColors.success;
    if (latency <= 200) return AppColors.warning;
    return AppColors.error;
  }

  Color _getPacketLossColor(double packetLoss) {
    if (packetLoss <= 1.0) return AppColors.success;
    if (packetLoss <= 5.0) return AppColors.warning;
    return AppColors.error;
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
} 