import 'package:flutter/material.dart';
import '../../../domain/models/dongle_type.dart';

/// Карточка типа донгла
class DongleTypeCard extends StatelessWidget {
  final DongleType? dongleType;
  final int? measuredResistanceMic;
  final int? measuredResistanceLeft;
  final int? measuredResistanceRight;
  final bool canChange;
  final VoidCallback? onChange;

  const DongleTypeCard({
    super.key,
    this.dongleType,
    this.measuredResistanceMic,
    this.measuredResistanceLeft,
    this.measuredResistanceRight,
    this.canChange = false,
    this.onChange,
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
                  'Dongle Type (auto-detected)',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                if (canChange && onChange != null)
                  TextButton(
                    onPressed: onChange,
                    child: const Text('Change'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (dongleType != null) ...[
              _buildTypeRow(dongleType!),
              if (measuredResistanceMic != null) ...[
                const SizedBox(height: 8),
                _buildResistanceInfo(),
              ],
            ] else ...[
              Text(
                'Not detected',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRow(DongleType type) {
    return Row(
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.green,
          size: 24,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            type.displayName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResistanceInfo() {
    final micStr = _formatResistance(measuredResistanceMic);
    final leftStr = _formatResistance(measuredResistanceLeft);
    final rightStr = _formatResistance(measuredResistanceRight);

    return Text(
      'Measured: GND→MIC=$micStr, L→GND=$leftStr, R→GND=$rightStr',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey.shade600,
      ),
    );
  }

  String _formatResistance(int? value) {
    if (value == null) return 'N/A';
    if (value == -1) return '∞';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}MΩ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}kΩ';
    return '${value}Ω';
  }
}
