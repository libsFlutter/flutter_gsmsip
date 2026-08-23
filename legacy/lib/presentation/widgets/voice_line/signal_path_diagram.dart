import 'package:flutter/material.dart';
import '../../../domain/models/voice_line_method.dart';

/// Диаграмма сигнала (Signal Path Diagram)
class SignalPathDiagram extends StatelessWidget {
  final VoiceLineMethod? method;

  const SignalPathDiagram({
    super.key,
    this.method,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          // SIP
          _buildStep('SIP', Icons.voicemail, Colors.blue),
          
          // Arrow
          _buildArrow(),
          
          // Inversion
          _buildStep('Inversion', Icons.swap_horiz, Colors.orange),
          
          // Arrow
          _buildArrow(),
          
          // Current Method
          _buildMethodStep(method),
          
          // Arrow
          _buildArrow(),
          
          // Phone Line
          _buildStep('Line', Icons.phone, Colors.green),
        ],
      ),
    );
  }

  Widget _buildStep(String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMethodStep(VoiceLineMethod? method) {
    String label;
    IconData icon;
    
    switch (method) {
      case VoiceLineMethod.ttyPort:
        label = 'TTY';
        icon = Icons.usb;
        break;
      case VoiceLineMethod.enhancedMode:
        label = 'Enhanced';
        icon = Icons.security;
        break;
      case VoiceLineMethod.dongle:
        label = 'Dongle';
        icon = Icons.devices;
        break;
      case VoiceLineMethod.telecomApi:
        label = 'Telecom';
        icon = Icons.phone_android;
        break;
      case VoiceLineMethod.acoustic:
        label = 'Acoustic';
        icon = Icons.headset;
        break;
      case null:
        label = 'Method';
        icon = Icons.help_outline;
    }
    
    return _buildStep(label, icon, Colors.purple);
  }

  Widget _buildArrow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Icon(
        Icons.arrow_downward,
        color: Colors.grey.shade400,
      ),
    );
  }
}
