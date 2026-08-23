import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';

/// Экран выбора режима тестирования донгла
class TestMenuScreen extends StatelessWidget {
  const TestMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Dongle'),
      ),
      body: Consumer<DongleProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Local Test Section
                _buildSectionTitle('LOCAL TEST (without phone line)'),
                const SizedBox(height: 12),

                _buildTestCard(
                  context,
                  icon: Icons.loop,
                  title: 'Loopback Test',
                  description: 'TX → internal → RX\nVerify signal processing chain',
                  onTap: () => _runTest(context, provider, 'loopback'),
                ),

                const SizedBox(height: 12),

                _buildTestCard(
                  context,
                  icon: Icons.graphic_eq,
                  title: 'Tone Generator',
                  description: 'Generate 1kHz tone → measure output level\nVerify dongle output works',
                  onTap: () => _runTest(context, provider, 'tone'),
                ),

                const SizedBox(height: 24),

                // Line Test Section
                _buildSectionTitle('LINE TEST (with phone line connected)'),
                const SizedBox(height: 12),

                _buildTestCard(
                  context,
                  icon: Icons.echo,
                  title: 'Echo Test',
                  description: 'Send tone → wait for echo from line\nVerify TX and RX path through line',
                  onTap: () => _runTest(context, provider, 'echo'),
                ),

                const SizedBox(height: 12),

                _buildTestCard(
                  context,
                  icon: Icons.phone_callback,
                  title: 'Call Test',
                  description: 'Make test call to verify full path\nRequires: test phone number',
                  onTap: () => _runTest(context, provider, 'call'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.grey,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildTestCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(icon, size: 32, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _runTest(
    BuildContext context,
    DongleProvider provider,
    String testType,
  ) async {
    // Navigate to specific test screen
    // For now, just run the test and show result
    final result = await provider.testDongle(testType);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result ?? 'Test completed'),
          backgroundColor: result?.contains('passed') == true
              ? Colors.green
              : Colors.orange,
        ),
      );
    }
  }
}
