import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CallControls extends StatelessWidget {
  final bool isRunning;
  final bool hasActiveCall;
  final VoidCallback onStart;
  final VoidCallback onStop;
  final VoidCallback onEndCall;

  const CallControls({
    Key? key,
    required this.isRunning,
    required this.hasActiveCall,
    required this.onStart,
    required this.onStop,
    required this.onEndCall,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey[600]!,
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            AppLocalizations.of(context)?.gatewayControls ?? 'Gateway Controls',
            style: AppTextStyles.poppins(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          
          // Main Control Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton.icon(
              onPressed: isRunning ? onStop : onStart,
              icon: Icon(
                isRunning ? Icons.stop : Icons.play_arrow,
                size: 24,
              ),
              label: Text(
                isRunning ? (AppLocalizations.of(context)?.stopGateway ?? 'Stop Gateway') : (AppLocalizations.of(context)?.startGateway ?? 'Start Gateway'),
                style: AppTextStyles.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: isRunning ? Colors.red[600] : Colors.green[600],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          
          // Call Control Button (only show when there's an active call)
          if (hasActiveCall) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: onEndCall,
                icon: const Icon(Icons.call_end, color: Colors.red),
                label: Text(
                  AppLocalizations.of(context)?.endCall ?? 'End Call',
                  style: AppTextStyles.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
} 