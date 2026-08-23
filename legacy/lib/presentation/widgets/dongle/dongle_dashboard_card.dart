import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/dongle_provider.dart';
import '../../../domain/models/dongle_interface_type.dart';
import '../screens/dongle/dongle_status_screen.dart';

/// Карточка Dongle для Dashboard
class DongleDashboardCard extends StatelessWidget {
  const DongleDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DongleProvider>(
      builder: (context, provider, child) {
        final status = provider.dongleStatus;
        final hasDongle = status?.connected == true;
        final interfaceType = status?.interfaceType;
        final dongleType = status?.dongleType;

        return Card(
          child: InkWell(
            onTap: () => _navigateToDongle(context),
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
                        hasDongle ? Icons.usb : Icons.devices_off,
                        color: hasDongle ? Colors.green : Colors.grey,
                        size: 28,
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Dongle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        hasDongle ? Icons.check_circle : Icons.error,
                        color: hasDongle ? Colors.green : Colors.red,
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Status
                  if (hasDongle && interfaceType != null) ...[
                    Row(
                      children: [
                        Text(
                          'Interface:',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            interfaceType.displayName,
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

                    if (dongleType != null) ...[
                      Row(
                        children: [
                          Text(
                            'Type:',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              dongleType.displayName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
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
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Connected',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      'No dongle detected',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Connect USB-C or TRRS adapter',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToDongle(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DongleStatusScreen(),
      ),
    );
  }
}
