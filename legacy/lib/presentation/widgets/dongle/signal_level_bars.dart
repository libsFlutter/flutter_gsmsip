import 'package:flutter/material.dart';

/// Индикатор уровня сигнала
class SignalLevelBar extends StatelessWidget {
  /// Метка (например, "TX (to line)")
  final String label;

  /// Уровень (0.0 - 1.0)
  final double level;

  /// Значение в dB
  final int dbValue;

  const SignalLevelBar({
    super.key,
    required this.label,
    required this.level,
    required this.dbValue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14),
            ),
            Text(
              '$dbValue dB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: _getColor(level),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: level,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_getColor(level)),
          ),
        ),
      ],
    );
  }

  Color _getColor(double level) {
    if (level < 0.3) return Colors.green;
    if (level < 0.7) return Colors.orange;
    if (level < 0.9) return Colors.yellow.shade700;
    return Colors.red;
  }
}

/// Двойной индикатор (TX и RX)
class DualSignalLevelBars extends StatelessWidget {
  final double txLevel;
  final int txDb;
  final double rxLevel;
  final int rxDb;

  const DualSignalLevelBars({
    super.key,
    required this.txLevel,
    required this.txDb,
    required this.rxLevel,
    required this.rxDb,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SignalLevelBar(
          label: 'TX (to line)',
          level: txLevel,
          dbValue: txDb,
        ),
        const SizedBox(height: 12),
        SignalLevelBar(
          label: 'RX (from line)',
          level: rxLevel,
          dbValue: rxDb,
        ),
      ],
    );
  }
}
