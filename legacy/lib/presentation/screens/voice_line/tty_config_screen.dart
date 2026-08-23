import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/models/voice_line_method.dart';

/// Экран конфигурации TTY порта
class TtyConfigScreen extends StatefulWidget {
  const TtyConfigScreen({super.key});

  @override
  State<TtyConfigScreen> createState() => _TtyConfigScreenState();
}

class _TtyConfigScreenState extends State<TtyConfigScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Common TTY paths
  static const List<String> commonPaths = [
    '/dev/ttyUSB0',
    '/dev/ttyUSB1',
    '/dev/ttyHS0',
    '/dev/ttyHS1',
    '/dev/ttyGS0',
    '/dev/ttyGS1',
    '/dev/ttyMSM0',
    '/dev/ttyS0',
  ];

  static const List<int> commonBaudRates = [
    9600,
    19200,
    38400,
    57600,
    115200,
  ];

  String? _selectedPath;
  int _selectedBaudRate = 115200;
  String? _customPath;
  bool _isCustomPath = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TTY Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveConfig,
          ),
        ],
      ),
      body: Consumer<VoiceLineProvider>(
        builder: (context, provider, child) {
          _selectedPath ??= provider.config.ttyPortPath;
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Port Path Section
                  _buildPortPathSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Serial Settings
                  _buildSerialSettingsSection(),
                  
                  const SizedBox(height: 24),
                  
                  // Test Connection
                  _buildTestSection(provider),
                  
                  const SizedBox(height: 24),
                  
                  // Device Model
                  _buildDeviceModelSection(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortPathSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Port Path',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Toggle custom path
            SwitchListTile(
              title: const Text('Custom Path'),
              subtitle: const Text('Enter path manually'),
              value: _isCustomPath,
              onChanged: (value) {
                setState(() {
                  _isCustomPath = value;
                });
              },
            ),
            
            if (_isCustomPath) ...[
              // Custom path input
              TextFormField(
                initialValue: _customPath,
                decoration: const InputDecoration(
                  labelText: 'Custom Path',
                  hintText: '/dev/ttyUSB0',
                  prefixIcon: Icon(Icons.usb),
                ),
                onChanged: (value) => _customPath = value,
              ),
            ] else ...[
              // Predefined paths
              DropdownButtonFormField<String>(
                value: _selectedPath,
                decoration: const InputDecoration(
                  labelText: 'Port Path',
                  prefixIcon: Icon(Icons.usb),
                ),
                items: commonPaths.map((path) => DropdownMenuItem(
                  value: path,
                  child: Text(path),
                )).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPath = value;
                  });
                },
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Common paths info
            ExpansionTile(
              title: const Text('Common Paths'),
              children: commonPaths.map((path) => ListTile(
                title: Text(path),
                subtitle: Text(_getPathDescription(path)),
                onTap: () {
                  setState(() {
                    _selectedPath = path;
                    _isCustomPath = false;
                  });
                },
              )).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSerialSettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Serial Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Baud Rate
            DropdownButtonFormField<int>(
              value: _selectedBaudRate,
              decoration: const InputDecoration(
                labelText: 'Baud Rate',
                prefixIcon: Icon(Icons.speed),
              ),
              items: commonBaudRates.map((rate) => DropdownMenuItem(
                value: rate,
                child: Text('$rate bps'),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedBaudRate = value ?? 115200;
                });
              },
            ),
            
            const SizedBox(height: 16),
            
            // Other settings (fixed for now)
            _buildReadOnlySetting('Data Bits', '8'),
            _buildReadOnlySetting('Stop Bits', '1'),
            _buildReadOnlySetting('Parity', 'None'),
          ],
        ),
      ),
    );
  }

  Widget _buildReadOnlySetting(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSection(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Connection',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton.icon(
              icon: const Icon(Icons.test_rounded),
              label: const Text('Test Port'),
              onPressed: () => _testPort(provider),
            ),
            
            const SizedBox(height: 12),
            
            // Last test result
            if (provider.lastTestResult != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: provider.lastTestResult!.success
                      ? Colors.green.shade50
                      : Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          provider.lastTestResult!.success
                              ? Icons.check_circle
                              : Icons.error,
                          color: provider.lastTestResult!.success
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          provider.lastTestResult!.success
                              ? 'Port opened successfully'
                              : 'Test failed',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (provider.lastTestResult!.error != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        provider.lastTestResult!.error!,
                        style: TextStyle(color: Colors.red.shade700),
                      ),
                    ],
                    if (provider.lastTestResult!.measurements.containsKey('latencyMs')) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Latency: ${provider.lastTestResult!.measurements['latencyMs']} ms',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ],
                ),
              ),
            ] else ...[
              Text(
                'Last result: Port not tested',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceModelSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Device Model',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Help us add support for your device',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              decoration: const InputDecoration(
                labelText: 'Device Model',
                hintText: 'e.g., Samsung Galaxy S21',
                prefixIcon: Icon(Icons.phone_android),
              ),
              onChanged: (value) {
                // Save device model for reporting
              },
            ),
            
            const SizedBox(height: 16),
            
            OutlinedButton.icon(
              icon: const Icon(Icons.bug_report),
              label: const Text('Report Device Model'),
              onPressed: () {
                // Send device model to developers
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Device model reported. Thank you!')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getPathDescription(String path) {
    if (path.contains('USB')) return 'USB Serial (most common)';
    if (path.contains('HS')) return 'Qualcomm High-Speed';
    if (path.contains('GS')) return 'GSM Serial';
    if (path.contains('MSM')) return 'MSM Serial';
    if (path.contains('ttyS')) return 'Standard Serial';
    return 'Unknown';
  }

  Future<void> _testPort(VoiceLineProvider provider) async {
    final path = _isCustomPath ? _customPath : _selectedPath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a port path')),
      );
      return;
    }

    await provider.testMethod(VoiceLineMethod.ttyPort);
    
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(provider.lastTestResult!.success
              ? 'Test Successful'
              : 'Test Failed'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (provider.lastTestResult!.error != null)
                Text(provider.lastTestResult!.error!),
              if (provider.lastTestResult!.measurements.containsKey('latencyMs'))
                Text('Latency: ${provider.lastTestResult!.measurements['latencyMs']} ms'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
            if (provider.lastTestResult!.success)
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveConfig();
                },
                child: const Text('Use This Port'),
              ),
          ],
        ),
      );
    }
  }

  void _saveConfig() {
    final path = _isCustomPath ? _customPath : _selectedPath;
    if (path == null || path.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a port path')),
      );
      return;
    }

    final provider = context.read<VoiceLineProvider>();
    provider.setTtyPort(path, _selectedBaudRate);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Configuration saved')),
    );
    
    Navigator.pop(context);
  }
}
