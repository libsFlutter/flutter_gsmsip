import 'package:flutter/material.dart';
import '../../../domain/models/voice_line_method.dart';
import '../../../domain/models/quality_level.dart';
import '../../../domain/models/voice_line_method_status.dart';

/// Карточка статуса метода
class MethodStatusCard extends StatelessWidget {
  final VoiceLineMethodStatus status;
  final bool isSelected;
  final VoidCallback? onTap;

  const MethodStatusCard({
    super.key,
    required this.status,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: isSelected ? Colors.blue.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Icon(
                    _getMethodIcon(status.method),
                    color: status.available ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 12),
                  
                  // Name and quality
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.method.displayName,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          status.method.description,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Quality stars
                  Column(
                    children: [
                      Text(
                        status.quality.stars,
                        style: const TextStyle(fontSize: 14),
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 4),
                        Icon(
                          Icons.radio_button_checked,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
              
              // Status indicator
              if (!status.available && status.reasonUnavailable != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.red.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          status.reasonUnavailable!,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.red.shade700,
                          ),
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
  }

  IconData _getMethodIcon(VoiceLineMethod method) {
    switch (method) {
      case VoiceLineMethod.ttyPort:
        return Icons.usb;
      case VoiceLineMethod.enhancedMode:
        return Icons.security;
      case VoiceLineMethod.dongle:
        return Icons.devices;
      case VoiceLineMethod.telecomApi:
        return Icons.phone_android;
      case VoiceLineMethod.acoustic:
        return Icons.headset;
    }
  }
}

/// Список методов
class MethodList extends StatelessWidget {
  final List<VoiceLineMethodStatus> methods;
  final VoiceLineMethod? selectedMethod;
  final Function(VoiceLineMethod) onMethodSelected;

  const MethodList({
    super.key,
    required this.methods,
    this.selectedMethod,
    required this.onMethodSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: methods.map((method) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: MethodStatusCard(
          status: method,
          isSelected: method.method == selectedMethod,
          onTap: method.available
              ? () => onMethodSelected(method.method)
              : null,
        ),
      )).toList(),
    );
  }
}
