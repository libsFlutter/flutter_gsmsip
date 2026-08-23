import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/gateway_status.dart';
import '../utils/text_styles.dart';
import '../theme/app_colors.dart';

class ConnectionStatusCard extends StatelessWidget {
  final GatewayStatus status;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final VoidCallback? onDisconnect;

  const ConnectionStatusCard({
    Key? key,
    required this.status,
    this.onTap,
    this.onConnect,
    this.onDisconnect,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getStatusGradientColors(status.sipConnectionState).start,
            _getStatusGradientColors(status.sipConnectionState).end,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getStatusGradientColors(status.sipConnectionState).start.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                _buildHeader(theme, l10n),
                const SizedBox(height: 20),
                _buildConnectionInfo(theme, l10n),
                const SizedBox(height: 20),
                _buildActionButtons(theme, l10n),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            _getStatusIcon(status.sipConnectionState),
            color: Colors.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.gatewayStatus,
                style: AppTextStyles.poppins(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _getStatusText(status.sipConnectionState, l10n),
                style: AppTextStyles.poppins(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 20,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(theme),
      ],
    );
  }

  Widget _buildStatusBadge(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _isConnected(status.sipConnectionState) ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _isConnected(status.sipConnectionState) ? 'ON' : 'OFF',
            style: AppTextStyles.poppins(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionInfo(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          _buildConnectionRow(
            l10n.sipConnection,
            _getConnectionStatusText(status.sipConnectionState, l10n),
            Icons.phone,
            theme,
          ),
          const SizedBox(height: 12),
          _buildConnectionRow(
            l10n.gsmConnection,
            _getConnectionStatusText(status.gsmConnectionState, l10n),
            Icons.signal_cellular_alt,
            theme,
          ),
          const SizedBox(height: 12),
          _buildConnectionRow(
            l10n.activeCalls,
            '${status.activeCalls}',
            Icons.call,
            theme,
          ),
        ],
      ),
    );
  }

  Widget _buildConnectionRow(String label, String value, IconData icon, ThemeData theme) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: AppTextStyles.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.poppins(
            color: Colors.white,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(ThemeData theme, AppLocalizations l10n) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _isConnected(status.sipConnectionState) ? onDisconnect : onConnect,
            icon: Icon(
              _isConnected(status.sipConnectionState) ? Icons.link_off : Icons.link,
              size: 18,
            ),
            label: Text(
              _isConnected(status.sipConnectionState) ? l10n.disconnect : l10n.connect,
              style: AppTextStyles.poppins(fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: onTap,
            icon: const Icon(Icons.settings, size: 18),
            label: Text(
              'Settings',
              style: AppTextStyles.poppins(fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3)),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getStatusIcon(ConnectionState state) {
    switch (state) {
      case ConnectionState.disconnected:
        return Icons.link_off;
      case ConnectionState.connecting:
        return Icons.sync;
      case ConnectionState.connected:
        return Icons.link;
      case ConnectionState.registered:
        return Icons.check_circle;
      case ConnectionState.error:
        return Icons.error;
    }
  }

  String _getStatusText(ConnectionState state, AppLocalizations l10n) {
    switch (state) {
      case ConnectionState.disconnected:
        return l10n.disconnected;
      case ConnectionState.connecting:
        return l10n.connecting;
      case ConnectionState.connected:
        return l10n.connected;
      case ConnectionState.registered:
        return l10n.registered;
      case ConnectionState.error:
        return l10n.error;
    }
  }

  String _getConnectionStatusText(ConnectionState state, AppLocalizations l10n) {
    switch (state) {
      case ConnectionState.disconnected:
        return l10n.disconnected;
      case ConnectionState.connecting:
        return l10n.connecting;
      case ConnectionState.connected:
        return l10n.connected;
      case ConnectionState.registered:
        return l10n.registered;
      case ConnectionState.error:
        return l10n.error;
    }
  }

  bool _isConnected(ConnectionState state) {
    return state == ConnectionState.connected || state == ConnectionState.registered;
  }

  ({Color start, Color end}) _getStatusGradientColors(ConnectionState state) {
    switch (state) {
      case ConnectionState.disconnected:
        return (start: AppColors.error, end: AppColors.error.withOpacity(0.8));
      case ConnectionState.connecting:
        return (start: AppColors.warning, end: AppColors.warning.withOpacity(0.8));
      case ConnectionState.connected:
        return (start: AppColors.primary, end: AppColors.primary.withOpacity(0.8));
      case ConnectionState.registered:
        return (start: AppColors.accent, end: AppColors.accent.withOpacity(0.8));
      case ConnectionState.error:
        return (start: AppColors.error, end: AppColors.error.withOpacity(0.8));
    }
  }
}
