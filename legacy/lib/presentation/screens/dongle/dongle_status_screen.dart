import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';
import '../../domain/models/dongle_interface_type.dart';
import '../../domain/models/dongle_type.dart';
import 'detect_type_screen.dart';
import 'test_menu_screen.dart';
import '../widgets/dongle/interface_status_card.dart';
import '../widgets/dongle/dongle_type_card.dart';
import '../widgets/dongle/signal_level_bars.dart';

/// Главный экран статуса донгла
class DongleStatusScreen extends StatefulWidget {
  const DongleStatusScreen({super.key});

  @override
  State<DongleStatusScreen> createState() => _DongleStatusScreenState();
}

class _DongleStatusScreenState extends State<DongleStatusScreen> {
  @override
  void initState() {
    super.initState();
    // Инициализация при загрузке
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DongleProvider>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dongle'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DongleProvider>().refreshStatus(),
          ),
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => _showHelp(context),
          ),
        ],
      ),
      body: Consumer<DongleProvider>(
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

  Widget _buildContent(BuildContext context, DongleProvider provider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Interface Status Card
          _buildInterfaceCard(provider),

          const SizedBox(height: 16),

          // Dongle Type Card
          _buildDongleTypeCard(provider),

          const SizedBox(height: 16),

          // Signal Levels (если донгл подключён)
          if (provider.hasDongle) ...[
            _buildSignalLevelsCard(),
            const SizedBox(height: 16),
          ],

          // Action Buttons
          _buildActionButtons(context, provider),
        ],
      ),
    );
  }

  Widget _buildInterfaceCard(DongleProvider provider) {
    final status = provider.dongleStatus;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interface (auto-detected)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _getInterfaceIcon(provider.interfaceType),
                  color: provider.hasDongle ? Colors.green : Colors.grey,
                  size: 32,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        status?.interfaceType.displayName ?? 'None detected',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        status?.interfaceType.signalType ?? '',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (provider.hasDongle)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDongleTypeCard(DongleProvider provider) {
    final status = provider.dongleStatus;
    final type = provider.dongleType;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Dongle Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (provider.isAnalog)
                  TextButton(
                    onPressed: () => _navigateToDetectType(context),
                    child: const Text('Change'),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            if (type != null) ...[
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    color: Colors.green,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    type.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              if (status?.measuredResistanceMic != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Measured: GND→MIC=${status!.measuredResistanceMic}Ω, '
                  'L→GND=${status.measuredResistanceLeft ?? 'N/A'}Ω',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ] else if (provider.hasDongle) ...[
              Text(
                'Auto-detecting...',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ] else ...[
              Text(
                'No dongle detected',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSignalLevelsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signal Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const SignalLevelBar(
              label: 'TX (to line)',
              level: 0.75,
              dbValue: -6,
            ),
            const SizedBox(height: 12),
            const SignalLevelBar(
              label: 'RX (from line)',
              level: 0.5,
              dbValue: -12,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, DongleProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.settings),
          label: const Text('Configure'),
          onPressed: provider.hasDongle
              ? () => _navigateToConfig(context, provider.interfaceType!)
              : null,
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.test_rounded),
          label: const Text('Test'),
          onPressed: provider.hasDongle
              ? () => _navigateToTest(context)
              : null,
        ),
      ],
    );
  }

  Widget _buildErrorState(DongleProvider provider) {
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
        title: const Text('Dongle Help'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpItem(
                'USB-C with DAC',
                'Digital interface with external DAC chip. Best quality.',
              ),
              _buildHelpItem(
                'USB-C Audio Accessory',
                'Analog interface using device DAC via SBU pins.',
              ),
              _buildHelpItem(
                'TRRS 3.5mm',
                'Analog headset jack connection.',
              ),
              const SizedBox(height: 16),
              const Text(
                'Dongle Types:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              _buildHelpItem(
                'Differential (4R+1C)',
                'GND→MIC ~10k, L→GND ~15k',
              ),
              _buildHelpItem(
                'Mono Loopback',
                'GND→MIC ~1.8k, L→GND ~100k',
              ),
              _buildHelpItem(
                'Stereo Loopback',
                'GND→MIC ~1.8k, L→GND ∞',
              ),
              _buildHelpItem(
                'Earphone-to-Mic',
                'GND→MIC ~10k, L→GND ∞',
              ),
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
          Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(description, style: TextStyle(color: Colors.grey.shade600)),
        ],
      ),
    );
  }

  IconData _getInterfaceIcon(DongleInterfaceType? type) {
    switch (type) {
      case DongleInterfaceType.usbCWithDac:
      case DongleInterfaceType.usbCAudioAccessory:
        return Icons.usb;
      case DongleInterfaceType.trrs:
        return Icons.headset;
      case DongleInterfaceType.none:
        return Icons.devices_off;
      default:
        return Icons.devices;
    }
  }

  void _navigateToDetectType(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const DetectDongleTypeScreen(),
      ),
    );
  }

  void _navigateToConfig(BuildContext context, DongleInterfaceType type) {
    // Navigation to config screen based on type
    // TODO: Implement config screens
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Config for ${type.displayName} coming soon')),
    );
  }

  void _navigateToTest(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TestMenuScreen(),
      ),
    );
  }
}
