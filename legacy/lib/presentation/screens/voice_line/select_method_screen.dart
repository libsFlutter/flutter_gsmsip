import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/voice_line_method_status.dart';
import '../widgets/voice_line/method_status_card.dart';
import 'tty_config_screen.dart';
import 'enhanced_mode_screen.dart';

/// Экран выбора метода
class SelectMethodScreen extends StatefulWidget {
  const SelectMethodScreen({super.key});

  @override
  State<SelectMethodScreen> createState() => _SelectMethodScreenState();
}

class _SelectMethodScreenState extends State<SelectMethodScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Method'),
      ),
      body: Consumer<VoiceLineProvider>(
        builder: (context, provider, child) {
          final bestMethod = provider.bestAvailableMethod;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Auto-select toggle
                _buildAutoSelectCard(provider),
                
                const SizedBox(height: 16),
                
                // Recommended
                if (bestMethod != null) ...[
                  _buildRecommendedSection(provider, bestMethod),
                  const SizedBox(height: 16),
                ],
                
                // Available methods
                _buildAvailableMethodsSection(provider),
                
                const SizedBox(height: 16),
                
                // Not available methods
                _buildNotAvailableMethodsSection(provider),
                
                const SizedBox(height: 24),
                
                // Apply button
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Apply'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAutoSelectCard(VoiceLineProvider provider) {
    return Card(
      child: SwitchListTile(
        title: const Text('Auto-select Best Method'),
        subtitle: const Text('Automatically choose the best available method'),
        value: provider.isAutoSelect,
        onChanged: (value) => provider.setAutoSelect(value),
        secondary: Icon(
          provider.isAutoSelect ? Icons.auto_awesome : Icons.tune,
          color: provider.isAutoSelect ? Colors.blue : Colors.grey,
        ),
      ),
    );
  }

  Widget _buildRecommendedSection(
    VoiceLineProvider provider,
    VoiceLineMethod bestMethod,
  ) {
    final bestStatus = provider.availableMethods.firstWhere(
      (m) => m.method == bestMethod,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.star, color: Colors.amber.shade700),
            const SizedBox(width: 8),
            const Text(
              'Recommended',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        MethodStatusCard(
          status: bestStatus,
          isSelected: provider.currentMethod == bestMethod,
          onTap: () => provider.setMethod(bestMethod),
        ),
      ],
    );
  }

  Widget _buildAvailableMethodsSection(VoiceLineProvider provider) {
    final availableMethods = provider.availableMethods
        .where((m) => m.available && m.method != provider.bestAvailableMethod)
        .toList();
    
    if (availableMethods.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Other Available Methods',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...availableMethods.map((method) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: MethodStatusCard(
            status: method,
            isSelected: provider.currentMethod == method.method,
            onTap: () => provider.setMethod(method.method),
          ),
        )),
      ],
    );
  }

  Widget _buildNotAvailableMethodsSection(VoiceLineProvider provider) {
    final notAvailableMethods = provider.availableMethods
        .where((m) => !m.available)
        .toList();
    
    if (notAvailableMethods.isEmpty) {
      return const SizedBox.shrink();
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Not Available',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        ...notAvailableMethods.map((method) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: MethodStatusCard(
            status: method,
            isSelected: false,
            onTap: () => _showWhyUnavailable(context, method),
          ),
        )),
      ],
    );
  }

  void _showWhyUnavailable(BuildContext context, VoiceLineMethodStatus method) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.orange.shade700),
                const SizedBox(width: 8),
                Text(
                  'Why ${method.method.displayName} is unavailable?',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (method.reasonUnavailable != null)
              Text(
                method.reasonUnavailable!,
                style: const TextStyle(fontSize: 16),
              ),
            const SizedBox(height: 16),
            _buildMethodSpecificInfo(method.method),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
                if (method.method == VoiceLineMethod.ttyPort) ...[
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToTtyConfig(context);
                    },
                    child: const Text('Manual Config'),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodSpecificInfo(VoiceLineMethod method) {
    switch (method) {
      case VoiceLineMethod.ttyPort:
        return _buildInfoCard(
          'TTY Port requires:',
          [
            'Device-specific serial port path',
            'Proper permissions',
            'Known configuration for your device',
          ],
          'Common paths: /dev/ttyUSB*, /dev/ttyHS*, /dev/ttyGS*',
        );
      case VoiceLineMethod.enhancedMode:
        return _buildInfoCard(
          'Enhanced Mode requires:',
          [
            'System-level access (Magisk)',
            'Special installation procedure',
            'Device modifications',
          ],
          'Contact support for installation assistance.',
        );
      case VoiceLineMethod.dongle:
        return _buildInfoCard(
          'Dongle requires:',
          [
            'USB-C or TRRS adapter',
            'Hardware connection',
          ],
          'Connect a compatible dongle to use this method.',
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildInfoCard(
    String title,
    List<String> requirements,
    String suggestion,
  ) {
    return Card(
      color: Colors.grey.shade100,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ...requirements.map((req) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Icon(Icons.circle, size: 8, color: Colors.grey.shade600),
                  const SizedBox(width: 8),
                  Expanded(child: Text(req)),
                ],
              ),
            )),
            const SizedBox(height: 12),
            Text(
              suggestion,
              style: TextStyle(
                color: Colors.blue.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToTtyConfig(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TtyConfigScreen(),
      ),
    );
  }
}
