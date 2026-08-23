import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class RecentLogs extends StatelessWidget {
  final List<String> logs;
  final VoidCallback onViewAll;

  const RecentLogs({
    Key? key,
    required this.logs,
    required this.onViewAll,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final recentLogs = logs.take(5).toList();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey[600]!,
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
                AppLocalizations.of(context)?.recentLogs ?? 'Recent Logs',
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  AppLocalizations.of(context)?.viewAll ?? 'View All',
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    color: Colors.blue[400],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          if (recentLogs.isEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  AppLocalizations.of(context)?.noLogsAvailable ?? 'No logs available',
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            )
          else
            Column(
              children: recentLogs.map((log) => _buildLogEntry(log)).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildLogEntry(String log) {
    // Parse timestamp and message
    final parts = log.split('] ');
    final timestamp = parts.isNotEmpty ? parts[0].replaceAll('[', '') : '';
    final message = parts.length > 1 ? parts[1] : log;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            timestamp,
            style: AppTextStyles.poppins(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: AppTextStyles.poppins(
              fontSize: 13,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
} 