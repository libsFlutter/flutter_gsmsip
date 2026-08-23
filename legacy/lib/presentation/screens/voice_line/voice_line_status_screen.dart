import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/quality_level.dart';
import 'select_method_screen.dart';
import 'test_voice_line_screen.dart';
import '../widgets/voice_line/method_status_card.dart';
import '../widgets/voice_line/signal_path_diagram.dart';

/// Главный экран статуса Voice Line
class VoiceLineStatusScreen extends StatefulWidget {
  const VoiceLineStatusScreen({super.key});

  @override
  State<VoiceLineStatusScreen> createState() => _VoiceLineStatusScreenState();
}

class _VoiceLineStatusScreenState extends State<VoiceLineStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Инициализация при загрузке
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoiceLineProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Line'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Consumer<VoiceLineProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.hasError) {
            return _buildErrorState(provider);
          }

          return _buildContent(context, provider);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, VoiceLineProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Current Method Card
          _buildCurrentMethodCard(provider),

          const SizedBox(height: 16),

          // Available Methods
          _buildAvailableMethodsCard(provider),

          const SizedBox(height: 16),

          // Signal Path Diagram
          _buildSignalPathCard(provider),

          const SizedBox(height: 24),

          // Action Buttons
          _buildActionButtons(context, provider),
        ],
      ),
    );
  }

  Widget _buildCurrentMethodCard(VoiceLineProvider provider) {
    final currentStatus = provider.currentMethodStatus;
    final method = provider.currentMethod;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  currentStatus?.available == true
                      ? Icons.check_circle
                      : Icons.error,
                  color: currentStatus?.available == true
                      ? Colors.green
                      : Colors.red,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Current Method',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (provider.isAutoSelect)
                  Chip(
                    label: const Text('Auto'),
                    backgroundColor: Colors.blue.shade100,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (method != null && currentStatus != null) ...[
              Text(
                method.displayName,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentStatus.available ? 'Connected' : 'Unavailable',
                style: TextStyle(
                  color: currentStatus.available ? Colors.green : Colors.red,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Text(
                    currentStatus.quality.stars,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    currentStatus.quality.description,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ] else ...[
              const Text(
                'No method selected',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAvailableMethodsCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Methods',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...provider.availableMethods.map((method) => ListTile(
                  leading: Icon(
                    method.available
                        ? Icons.check_circle
                        : Icons.cancel,
                    color: method.available ? Colors.green : Colors.grey,
                  ),
                  title: Text(method.method.displayName),
                  subtitle: Text(method.method.description),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(method.quality.stars),
                      const SizedBox(width: 8),
                      if (method.method == provider.currentMethod)
                        const Icon(Icons.radio_button_checked,
                            color: Colors.blue),
                    ],
                  ),
                  onTap: () => _showMethodDetails(context, method),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalPathCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signal Path',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SignalPathDiagram(method: provider.currentMethod),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, VoiceLineProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Change Method'),
          onPressed: () => _navigateToSelectMethod(context),
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.test_rounded),
          label: const Text('Test'),
          onPressed: () => _navigateToTest(context),
        ),
      ],
    );
  }

  Widget _buildErrorState(VoiceLineProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              provider.errorMessage ?? 'Unknown error',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => provider.initialize(),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showHelp(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Voice Line Methods'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem('TTY Port', 'Direct access via serial port. Best quality, device-specific.'),
              _buildHelpItem('Enhanced Mode', 'System-level audio access. Requires special setup.'),
              _buildHelpItem('Dongle', 'External USB-C or TRRS adapter. Plug and play.'),
              _buildHelpItem('Telecom API', 'Standard Android API. Works on all devices.'),
              _buildHelpItem('Acoustic', 'Earphone to microphone. Fallback option.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(description, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  void _showMethodDetails(BuildContext context, VoiceLineMethodStatus method) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(method.method.displayName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Quality: ${method.quality.stars}'),
            const SizedBox(height: 8),
            Text('Status: ${method.available ? "Available" : "Unavailable"}'),
            if (!method.available && method.reasonUnavailable != null) ...[
              const SizedBox(height: 8),
              Text(
                'Reason: ${method.reasonUnavailable}',
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ],
        ),
        actions: [
          if (!method.available)
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Why unavailable?'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _navigateToSelectMethod(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SelectMethodScreen(),
      ),
    );
  }

  void _navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestVoiceLineScreen(),
      ),
    );
  }
}
