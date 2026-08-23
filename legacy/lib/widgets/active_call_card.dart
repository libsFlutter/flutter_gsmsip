import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import '../models/active_call.dart';
import '../theme/app_colors.dart';

class ActiveCallCard extends StatelessWidget {
  final ActiveCall call;
  final VoidCallback? onEndCall;
  final VoidCallback? onHoldCall;
  final VoidCallback? onMuteCall;
  final VoidCallback? onToggleSpeaker;

  const ActiveCallCard({
    super.key,
    required this.call,
    this.onEndCall,
    this.onHoldCall,
    this.onMuteCall,
    this.onToggleSpeaker,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Card(
      color: colorScheme.surface,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getCallDirectionColor(call.direction),
                  child: Icon(
                    call.direction == 'incoming' 
                      ? Icons.call_received 
                      : Icons.call_made,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        call.fromNumber ?? 'Unknown',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        _getCallStatusText(call.status),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.warning.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _formatDuration(call.duration),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'Line ID',
                    value: call.lineId,
                    icon: Icons.phone,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'SIP MOS',
                    value: call.sipMos.toStringAsFixed(1),
                    icon: Icons.assessment,
                    color: AppColors.success,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'GSM MOS',
                    value: call.gsmMos.toStringAsFixed(1),
                    icon: Icons.signal_cellular_alt,
                    color: AppColors.warning,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'SIP Jitter',
                    value: '${call.sipJitter.toStringAsFixed(1)}ms',
                    icon: Icons.trending_up,
                    color: AppColors.technical,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'GSM Jitter',
                    value: '${call.gsmJitter.toStringAsFixed(1)}ms',
                    icon: Icons.trending_down,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCallInfo(
                    context: context,
                    title: 'Latency',
                    value: '${call.sipLatency.toStringAsFixed(1)}ms',
                    icon: Icons.speed,
                    color: AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildCallControls(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCallInfo({
    required BuildContext context,
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return Container(
      padding: const EdgeInsets.all(12),
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
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: color,
              ),
              const SizedBox(width: 4),
              Text(
                title,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCallControls(BuildContext context) {
    final theme = Theme.of(context);
    
    return Row(
      children: [
        Expanded(
          child: _buildControlButton(
            context: context,
            title: 'End Call',
            icon: Icons.call_end,
            color: AppColors.error,
            onPressed: onEndCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlButton(
            context: context,
            title: 'Hold',
            icon: Icons.pause,
            color: AppColors.warning,
            onPressed: onHoldCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlButton(
            context: context,
            title: 'Mute',
            icon: Icons.mic_off,
            color: theme.colorScheme.onSurfaceVariant,
            onPressed: onMuteCall,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildControlButton(
            context: context,
            title: 'Speaker',
            icon: Icons.volume_up,
            color: AppColors.primary,
            onPressed: onToggleSpeaker,
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
  }) {
    final theme = Theme.of(context);
    
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        padding: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20),
          const SizedBox(height: 4),
          Text(
            title,
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Color _getCallDirectionColor(String direction) {
    switch (direction) {
      case 'incoming':
        return AppColors.success;
      case 'outgoing':
        return AppColors.primary;
      default:
        return AppColors.info;
    }
  }

  String _getCallStatusText(String status) {
    switch (status) {
      case 'connected':
        return 'Connected';
      case 'ringing':
        return 'Ringing';
      case 'dialing':
        return 'Dialing';
      case 'ended':
        return 'Ended';
      default:
        return 'Unknown';
    }
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
} 