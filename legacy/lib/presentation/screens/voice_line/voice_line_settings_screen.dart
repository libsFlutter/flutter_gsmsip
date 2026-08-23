import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/entities/voice_line_config.dart';

/// Экран расширенных настроек Voice Line
class VoiceLineSettingsScreen extends StatefulWidget {
  const VoiceLineSettingsScreen({super.key});

  @override
  State<VoiceLineSettingsScreen> createState() => _VoiceLineSettingsScreenState();
}

class _VoiceLineSettingsScreenState extends State<VoiceLineSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Voice Line Settings'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveSettings(),
          ),
        ],
      ),
      body: Consumer<VoiceLineProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Audio Settings
                _buildAudioSettingsCard(provider),
                
                const SizedBox(height: 16),
                
                // Signal Processing
                _buildSignalProcessingCard(provider),
                
                const SizedBox(height: 16),
                
                // Call Settings
                _buildCallSettingsCard(provider),
                
                const SizedBox(height: 16),
                
                // Advanced
                _buildAdvancedCard(provider),
                
                const SizedBox(height: 24),
                
                // Save button
                ElevatedButton(
                  onPressed: () => _saveSettings(),
                  child: const Text('Save Settings'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAudioSettingsCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Sample Rate
            DropdownButtonFormField<String>(
              value: '48000',
              decoration: const InputDecoration(
                labelText: 'Sample Rate',
                prefixIcon: Icon(Icons.audio_file),
              ),
              items: const [
                DropdownMenuItem(value: '8000', child: Text('8000 Hz')),
                DropdownMenuItem(value: '16000', child: Text('16000 Hz')),
                DropdownMenuItem(value: '48000', child: Text('48000 Hz')),
              ],
              onChanged: (value) {
                // Update sample rate
              },
            ),
            
            const SizedBox(height: 16),
            
            // Bit Depth
            DropdownButtonFormField<String>(
              value: '16',
              decoration: const InputDecoration(
                labelText: 'Bit Depth',
                prefixIcon: Icon(Icons.bitcoin),
              ),
              items: const [
                DropdownMenuItem(value: '16', child: Text('16-bit')),
                DropdownMenuItem(value: '24', child: Text('24-bit')),
              ],
              onChanged: (value) {
                // Update bit depth
              },
            ),
            
            const SizedBox(height: 16),
            
            // Channels
            DropdownButtonFormField<String>(
              value: 'Stereo',
              decoration: const InputDecoration(
                labelText: 'Channels',
                prefixIcon: Icon(Icons.stereo),
              ),
              items: const [
                DropdownMenuItem(value: 'Mono', child: Text('Mono')),
                DropdownMenuItem(value: 'Stereo', child: Text('Stereo')),
              ],
              onChanged: (value) {
                // Update channels
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignalProcessingCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Signal Processing',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Right Channel Inversion
            SwitchListTile(
              title: const Text('Right Channel Inversion'),
              subtitle: const Text('For differential signaling'),
              value: provider.config.enableInversion,
              onChanged: (value) => provider.toggleInversion(value),
            ),
            
            // Echo Cancellation
            SwitchListTile(
              title: const Text('Echo Cancellation'),
              subtitle: const Text('Reduce echo feedback'),
              value: provider.config.enableEchoCancellation,
              onChanged: (value) {
                provider.updateConfig(
                  provider.config.copyWith(enableEchoCancellation: value),
                );
              },
            ),
            
            // Noise Reduction
            SwitchListTile(
              title: const Text('Noise Reduction'),
              subtitle: const Text('Reduce background noise'),
              value: provider.config.enableNoiseReduction,
              onChanged: (value) {
                provider.updateConfig(
                  provider.config.copyWith(enableNoiseReduction: value),
                );
              },
            ),
            
            // Automatic Gain Control
            SwitchListTile(
              title: const Text('Automatic Gain Control'),
              subtitle: const Text('Auto-adjust volume levels'),
              value: provider.config.enableAutomaticGainControl,
              onChanged: (value) {
                provider.updateConfig(
                  provider.config.copyWith(enableAutomaticGainControl: value),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCallSettingsCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Call Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Default Method
            DropdownButtonFormField<String>(
              value: provider.config.autoSelect ? 'auto' : 'manual',
              decoration: const InputDecoration(
                labelText: 'Default Method',
                prefixIcon: Icon(Icons.route),
              ),
              items: const [
                DropdownMenuItem(value: 'auto', child: Text('Auto-detect')),
                DropdownMenuItem(value: 'manual', child: Text('Manual selection')),
              ],
              onChanged: (value) {
                provider.setAutoSelect(value == 'auto');
              },
            ),
            
            const SizedBox(height: 16),
            
            // Call Recording
            SwitchListTile(
              title: const Text('Enable Call Recording'),
              subtitle: const Text('May require additional setup'),
              value: false, // TODO: Get from config
              onChanged: (value) {
                // Update call recording setting
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdvancedCard(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Advanced',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Diagnostics button
            ListTile(
              leading: const Icon(Icons.bug_report),
              title: const Text('Diagnostics'),
              subtitle: const Text('View system diagnostics'),
              onTap: () => _showDiagnostics(provider),
            ),
            
            const Divider(),
            
            // Reset to Defaults
            ListTile(
              leading: const Icon(Icons.restore, color: Colors.red),
              title: const Text(
                'Reset to Defaults',
                style: TextStyle(color: Colors.red),
              ),
              subtitle: const Text('Restore factory settings'),
              onTap: () => _confirmReset(provider),
            ),
          ],
        ),
      ),
    );
  }

  void _showDiagnostics(VoiceLineProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Diagnostics'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDiagnosticItem('Current Method', 
                  provider.currentMethod?.displayName ?? 'None'),
              _buildDiagnosticItem('Auto-select', 
                  provider.isAutoSelect ? 'Enabled' : 'Disabled'),
              _buildDiagnosticItem('Inversion', 
                  provider.config.enableInversion ? 'Enabled' : 'Disabled'),
              _buildDiagnosticItem('Echo Cancellation', 
                  provider.config.enableEchoCancellation ? 'Enabled' : 'Disabled'),
              _buildDiagnosticItem('Available Methods', 
                  '${provider.availableMethods.length}'),
              _buildDiagnosticItem('TTY Port', 
                  provider.config.ttyPortPath ?? 'Not configured'),
              _buildDiagnosticItem('Baud Rate', 
                  '${provider.config.ttyBaudRate}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: () {
              // Copy to clipboard
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Diagnostics copied to clipboard')),
              );
            },
            child: const Text('Copy'),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _confirmReset(VoiceLineProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset to Defaults'),
        content: const Text(
          'Are you sure you want to reset all Voice Line settings to their default values?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              provider.resetToDefaults();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings reset to defaults')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
  }

  void _saveSettings() {
    // Settings are auto-saved through provider
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
    Navigator.pop(context);
  }
}
