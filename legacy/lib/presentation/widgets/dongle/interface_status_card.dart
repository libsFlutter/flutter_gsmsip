import 'package:flutter/material.dart';
import '../../../domain/models/dongle_interface_type.dart';

/// Карточка статуса интерфейса
class InterfaceStatusCard extends StatelessWidget {
  final DongleInterfaceType interfaceType;
  final bool connected;
  final VoidCallback? onRefresh;

  const InterfaceStatusCard({
    super.key,
    required this.interfaceType,
    required this.connected,
    this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Interface (auto-detected)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (onRefresh != null)
                  IconButton(
                    icon: const Icon(Icons.refresh, size: 20),
                    onPressed: onRefresh,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getInterfaceIcon(interfaceType),
                  color: connected ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        interfaceType.displayName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        interfaceType.signalType,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusIndicator(connected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicator(bool connected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: connected ? Colors.green.shade50 : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        connected ? 'Connected' : 'Disconnected',
        style: TextStyle(
          color: connected ? Colors.green.shade700 : Colors.grey.shade700,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  IconData _getInterfaceIcon(DongleInterfaceType type) {
    switch (type) {
      case DongleInterfaceType.usbCWithDac:
      case DongleInterfaceType.usbCAudioAccessory:
        return Icons.usb;
      case DongleInterfaceType.trrs:
        return Icons.headset;
      case DongleInterfaceType.none:
        return Icons.devices_off;
    }
  }
}
