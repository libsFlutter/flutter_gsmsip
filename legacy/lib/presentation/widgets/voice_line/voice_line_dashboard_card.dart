import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voice_line_provider.dart';
import '../../../domain/models/voice_line_method.dart';
import '../screens/voice_line/voice_line_status_screen.dart';

/// Карточка Voice Line для Dashboard
class VoiceLineDashboardCard extends StatelessWidget {
  const VoiceLineDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<VoiceLineProvider>(
      builder: (context, provider, child) {
        final currentMethod = provider.currentMethod;
        final currentStatus = provider.currentMethodStatus;
        final isAvailable = currentStatus?.available ?? false;

        return Card(
          child: InkWell(
            onTap: () => _navigateToVoiceLine(context),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  Row(
                    children: [
                      Icon(
                        isAvailable ? Icons.phone : Icons.phone_disabled,
                        color: isAvailable ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Voice Line',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        isAvailable
                            ? Icons.check_circle
                            : Icons.error,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Current Method
                  if (currentMethod != null) ...[
                    Row(
                      children: [
                        Text(
                          'Method:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            currentMethod.displayName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Quality
                    Row(
                      children: [
                        Text(
                          'Quality:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        if (currentStatus != null) ...[
                          Text(
                            currentStatus.quality.stars,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                  ] else ...[
                    Text(
                      'No method selected',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? Colors.green.shade50
                          : Colors.orange.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isAvailable ? Icons.check_circle : Icons.warning,
                          size: 14,
                          color: isAvailable
                              ? Colors.green.shade700
                              : Colors.orange.shade700,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          isAvailable ? 'Ready' : 'Check Configuration',
                          style: TextStyle(
                            fontSize: 12,
                            color: isAvailable
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToVoiceLine(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const VoiceLineStatusScreen(),
      ),
    );
  }
}
