import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';
import '../../domain/entities/dongle_config.dart';
import '../../domain/models/dongle_type.dart';

/// Экран конфигурации TRRS донгла
class TrrsConfigScreen extends StatefulWidget {
  const TrrsConfigScreen({super.key});

  @override
  State<TrrsConfigScreen> createState() => _TrrsConfigScreenState();
}

class _TrrsConfigScreenState extends State<TrrsConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  DongleType? _selectedType;
  bool _enableInversion = true;
  String _wiringStandard = 'CTIA'; // CTIA or OMTP

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TRRS Dongle Config'),
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
            _selectedType ??= provider.config!.dongleType;
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
                  
                  // Audio Mode
                  _buildAudioModeSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Wiring Standard
                  _buildWiringSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Right Channel Inversion
                  _buildInversionSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Circuit Diagram Preview
                  _buildCircuitPreview(),
                  
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
              initialValue: 'TRRS Dongle',
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

  Widget _buildAudioModeSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Mode',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<DongleType>(
              title: const Text('Earphone-to-Mic (Acoustic Coupling)'),
              subtitle: const Text('Speaker → Physical contact → Microphone'),
              value: DongleType.earphoneToMic,
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
            ),
            
            RadioListTile<DongleType>(
              title: const Text('Android Audio Loopback'),
              subtitle: const Text('Software loopback via Android API'),
              value: DongleType.monoLoopback,
              groupValue: _selectedType,
              onChanged: (value) => setState(() => _selectedType = value),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWiringSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Wiring Standard',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            RadioListTile<String>(
              title: const Text('CTIA (L-R-G-M)'),
              subtitle: const Text('Standard (most devices)'),
              value: 'CTIA',
              groupValue: _wiringStandard,
              onChanged: (value) => setState(() => _wiringStandard = value),
            ),
            
            RadioListTile<String>(
              title: const Text('OMTP (L-R-M-G)'),
              subtitle: const Text('Legacy (older devices)'),
              value: 'OMTP',
              groupValue: _wiringStandard,
              onChanged: (value) => setState(() => _wiringStandard = value),
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
              title: const Text('Enable inversion'),
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
              child: Text(
                'Signal Path: SIP: [L, R] → Output: [L, -R]',
                style: TextStyle(color: Colors.blue.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCircuitPreview() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Circuit Diagram',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Show full schematic
                  },
                  child: const Text('Show Schematic'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Simple ASCII-style diagram
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  _buildDiagramRow('LEFT', '────R1────┬────R3──── TIP'),
                  _buildDiagramRow('', '            │'),
                  _buildDiagramRow('', '           C1'),
                  _buildDiagramRow('', '            │'),
                  _buildDiagramRow('RIGHT', '────R2────┴────R4──── RING'),
                  _buildDiagramRow('', '            │'),
                  _buildDiagramRow('GND', '────────────●'),
                  _buildDiagramRow('', '            │'),
                  _buildDiagramRow('MIC', '────────────●'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Components: R1,R2=10k, R3,R4=10k, C1=100nF',
              style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiagramRow(String label, String diagram) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            diagram,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'monospace',
            ),
          ),
        ),
      ],
    );
  }

  void _saveConfig() {
    if (_selectedType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select audio mode')),
      );
      return;
    }

    final provider = context.read<DongleProvider>();
    final config = DongleConfig(
      interfaceType: provider.interfaceType!,
      dongleType: _selectedType,
      enableInversion: _enableInversion,
    );

    provider.saveConfig(config);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved')),
    );
    
    Navigator.pop(context);
  }
}
