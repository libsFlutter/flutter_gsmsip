import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';
import '../../domain/entities/dongle_config.dart';
import '../../domain/models/dongle_type.dart';

/// Экран конфигурации USB-C с DAC донгла
class UsbDacConfigScreen extends StatefulWidget {
  const UsbDacConfigScreen({super.key});

  @override
  State<UsbDacConfigScreen> createState() => _UsbDacConfigScreenState();
}

class _UsbDacConfigScreenState extends State<UsbDacConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  int _sampleRate = 48000;
  int _bitDepth = 16;
  int _outputVolume = 90;
  bool _enableInversion = true;
  String _latencyMode = 'Low';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('USB DAC Adapter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () => _saveConfig(),
          ),
        ],
      ),
      body: Consumer<DongleProvider>(
        builder: (context, provider, child) {
          // Load current config
          if (provider.config != null) {
            _sampleRate = provider.config!.sampleRate ?? 48000;
            _bitDepth = provider.config!.bitDepth ?? 16;
            _enableInversion = provider.config!.enableInversion;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Name
                  _buildNameField(),
                  
                  const SizedBox(height: 24),
                  
                  // Device Status
                  _buildDeviceStatusCard(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Audio Settings
                  _buildAudioSettingsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Output Volume
                  _buildVolumeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Right Channel Inversion
                  _buildInversionSection(),
                  
                  const SizedBox(height: 24),
                  
                  // DAC Quality Info
                  _buildDacQualitySection(),
                  
                  const SizedBox(height: 24),
                  
                  // Save button
                  ElevatedButton(
                    onPressed: () => _saveConfig(),
                    child: const Text('Save Configuration'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNameField() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Name',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextFormField(
              initialValue: 'USB DAC Adapter',
              decoration: const InputDecoration(
                hintText: 'Enter dongle name',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatusCard(DongleProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Status',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _buildStatusRow('USB Port', 'Type-C'),
            _buildStatusRow('Mode', 'USB Audio Class (UAC)'),
            _buildStatusRow('DAC Chip', 'PCM2704 (Detected)'),
            _buildStatusRow(
              'Status',
              provider.hasDongle ? 'Connected' : 'Disconnected',
              isSuccess: provider.hasDongle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Sample Rate
            DropdownButtonFormField<int>(
              value: _sampleRate,
              decoration: const InputDecoration(
                labelText: 'Sample Rate',
                prefixIcon: Icon(Icons.audio_file),
              ),
              items: const [
                DropdownMenuItem(value: 8000, child: Text('8000 Hz')),
                DropdownMenuItem(value: 16000, child: Text('16000 Hz')),
                DropdownMenuItem(value: 44100, child: Text('44100 Hz')),
                DropdownMenuItem(value: 48000, child: Text('48000 Hz')),
                DropdownMenuItem(value: 96000, child: Text('96000 Hz')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _sampleRate = value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Bit Depth
            DropdownButtonFormField<int>(
              value: _bitDepth,
              decoration: const InputDecoration(
                labelText: 'Bit Depth',
                prefixIcon: Icon(Icons.bitcoin),
              ),
              items: const [
                DropdownMenuItem(value: 16, child: Text('16-bit')),
                DropdownMenuItem(value: 24, child: Text('24-bit')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _bitDepth = value);
              },
            ),
            
            const SizedBox(height: 16),
            
            // Latency Mode
            DropdownButtonFormField<String>(
              value: _latencyMode,
              decoration: const InputDecoration(
                labelText: 'Latency Mode',
                prefixIcon: Icon(Icons.timer),
              ),
              items: const [
                DropdownMenuItem(value: 'Low', child: Text('Low (< 10ms)')),
                DropdownMenuItem(value: 'Normal', child: Text('Normal (10-20ms)')),
                DropdownMenuItem(value: 'High', child: Text('High (> 20ms)')),
              ],
              onChanged: (value) {
                if (value != null) setState(() => _latencyMode = value);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVolumeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Output Volume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.volume_up),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _outputVolume.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    label: '$_outputVolume%',
                    onChanged: (value) {
                      setState(() => _outputVolume = value.toInt());
                    },
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 50,
                  child: Text(
                    '$_outputVolume%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInversionSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Right Channel Inversion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('Enable Inversion'),
              subtitle: const Text('For differential signaling'),
              value: _enableInversion,
              onChanged: (value) => setState(() => _enableInversion = value),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Signal Path:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SIP → [L, -R] → USB → DAC → 4R+1C → Phone',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDacQualitySection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Text(
                  'DAC Quality',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildQualityRow('THD+N', '< 0.01%'),
            _buildQualityRow('SNR', '> 90dB'),
            _buildQualityRow('Dynamic Range', '> 85dB'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, {bool? isSuccess}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade600)),
          Row(
            children: [
              if (isSuccess != null) ...[
                Icon(
                  isSuccess ? Icons.check_circle : Icons.cancel,
                  size: 16,
                  color: isSuccess ? Colors.green : Colors.red,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                value,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQualityRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  void _saveConfig() {
    final provider = context.read<DongleProvider>();
    final config = DongleConfig(
      interfaceType: provider.interfaceType!,
      dongleType: DongleType.differential, // Default for USB DAC
      enableInversion: _enableInversion,
      sampleRate: _sampleRate,
      bitDepth: _bitDepth,
      outputVolume: _outputVolume,
    );

    provider.saveConfig(config);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved')),
    );
    
    Navigator.pop(context);
  }
}
