import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/call_statistics.dart';
import '../utils/text_styles.dart';
import '../theme/app_colors.dart';

class CallStatisticsCard extends StatelessWidget {
  final CallStatistics statistics;
  final VoidCallback? onTap;

  const CallStatisticsCard({
    Key? key,
    required this.statistics,
    this.onTap,
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
            AppColors.getCardBackground(theme.brightness),
            AppColors.getCardBackgroundSecondary(theme.brightness),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.getCardShadow(theme.brightness),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.getCardShadow(theme.brightness),
            blurRadius: 15,
            offset: const Offset(0, 8),
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
                _buildStatisticsGrid(theme, l10n),
                const SizedBox(height: 20),
                _buildQualityMetrics(theme, l10n),
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
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary,
                AppColors.primaryLight,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            Icons.analytics,
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
                'Call Statistics',
                style: AppTextStyles.poppins(
                  color: AppColors.getTextPrimary(theme.brightness),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              Text(
                'Performance metrics and quality indicators',
                style: AppTextStyles.poppins(
                  color: AppColors.getTextSecondary(theme.brightness),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsGrid(ThemeData theme, AppLocalizations l10n) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          title: 'Total Calls',
          value: statistics.totalCalls.toString(),
          icon: Icons.call,
          color: AppColors.primary,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Active Calls',
          value: statistics.activeCalls.toString(),
          icon: Icons.call_active,
          color: AppColors.accent,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Incoming',
          value: statistics.incomingCalls.toString(),
          icon: Icons.call_received,
          color: AppColors.success,
          theme: theme,
        ),
        _buildStatCard(
          title: 'Outgoing',
          value: statistics.outgoingCalls.toString(),
          icon: Icons.call_made,
          color: AppColors.warning,
          theme: theme,
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withOpacity(0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: AppTextStyles.poppins(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: AppTextStyles.poppins(
                color: AppColors.getTextSecondary(theme.brightness),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQualityMetrics(ThemeData theme, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.getInputBackground(theme.brightness),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.getInputBorder(theme.brightness),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.assessment,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Quality Metrics',
                style: AppTextStyles.poppins(
                  color: AppColors.getTextPrimary(theme.brightness),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildQualityRow('Average MOS', '${statistics.averageMos.toStringAsFixed(1)}', theme),
          const SizedBox(height: 8),
          _buildQualityRow('Average Jitter', '${statistics.averageJitter.toStringAsFixed(1)}ms', theme),
          const SizedBox(height: 8),
          _buildQualityRow('Average Latency', '${statistics.averageLatency.toStringAsFixed(1)}ms', theme),
          const SizedBox(height: 8),
          _buildQualityRow('Packet Loss', '${statistics.packetLoss.toStringAsFixed(2)}%', theme),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String label, String value, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: AppTextStyles.poppins(
            color: AppColors.getTextSecondary(theme.brightness),
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.poppins(
            color: AppColors.getTextPrimary(theme.brightness),
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
