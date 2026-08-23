import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/voice_line_provider.dart';
import '../../domain/models/voice_line_method.dart';
import '../../domain/models/quality_level.dart';
import '../../domain/models/test_method_result.dart';

/// Экран тестирования Voice Line
class TestVoiceLineScreen extends StatefulWidget {
  const TestVoiceLineScreen({super.key});

  @override
  State<TestVoiceLineScreen> createState() => _TestVoiceLineScreenState();
}

class _TestVoiceLineScreenState extends State<TestVoiceLineScreen> {
  VoiceLineMethod? _selectedMethod;
  TestMethodResult? _lastResult;
  bool _isTesting = false;
  int _testProgress = 0;
  String _currentTestStep = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Voice Line'),
        actions: [
          if (_isTesting)
            IconButton(
              icon: const Icon(Icons.stop),
              onPressed: () => _stopTest(),
            ),
        ],
      ),
      body: Consumer<VoiceLineProvider>(
        builder: (context, provider, child) {
          if (_selectedMethod == null) {
            _selectedMethod = provider.currentMethod;
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Method selector
                _buildMethodSelector(provider),
                
                const SizedBox(height: 16),
                
                // Test selection
                _buildTestSelection(provider),
                
                const SizedBox(height: 24),
                
                // Progress (if testing)
                if (_isTesting) ...[
                  _buildProgressSection(),
                  const SizedBox(height: 24),
                ],
                
                // Results
                if (_lastResult != null) ...[
                  _buildResultsSection(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMethodSelector(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Method to Test',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<VoiceLineMethod>(
              value: _selectedMethod,
              decoration: const InputDecoration(
                labelText: 'Method',
                prefixIcon: Icon(Icons.devices),
              ),
              items: provider.availableMethods.map((m) => DropdownMenuItem(
                value: m.method,
                child: Text(m.method.displayName),
              )).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedMethod = value;
                  _lastResult = null;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSelection(VoiceLineProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Test Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            
            ListTile(
              leading: const Icon(Icons.route),
              title: const Text('Signal Path Test'),
              subtitle: const Text('Verify TX and RX paths'),
              onTap: () => _runSignalPathTest(provider),
            ),
            
            ListTile(
              leading: const Icon(Icons.graphic_eq),
              title: const Text('Audio Quality Test'),
              subtitle: const Text('Measure levels and THD'),
              onTap: () => _runAudioQualityTest(provider),
            ),
            
            ListTile(
              leading: const Icon(Icons.phone_callback),
              title: const Text('Full Call Test'),
              subtitle: const Text('Complete end-to-end test'),
              onTap: () => _runFullCallTest(provider),
            ),
            
            const SizedBox(height: 16),
            
            // Quick Test button
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Run All Tests'),
              onPressed: _isTesting ? null : () => _runAllTests(provider),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Testing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _currentTestStep,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: _testProgress / 100),
            const SizedBox(height: 8),
            Text(
              '$_testProgress%',
              style: TextStyle(color: Colors.grey.shade600),
            ),
            
            const SizedBox(height: 16),
            
            // Test steps
            _buildStepIndicator('Method detection', _testProgress >= 20),
            _buildStepIndicator('Hardware check', _testProgress >= 40),
            _buildStepIndicator('Signal path verification', _testProgress >= 60),
            _buildStepIndicator('Audio quality test', _testProgress >= 80),
            _buildStepIndicator('Full path test', _testProgress >= 100),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(String label, bool completed) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(
            completed ? Icons.check_circle : Icons.circle_outlined,
            size: 20,
            color: completed ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: completed ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_lastResult == null) return const SizedBox.shrink();
    
    final success = _lastResult!.success;
    
    return Card(
      color: success ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  success ? Icons.check_circle : Icons.error,
                  color: success ? Colors.green : Colors.red,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  success ? 'Test Passed' : 'Test Failed',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            if (_lastResult!.error != null) ...[
              const SizedBox(height: 12),
              Text(
                _lastResult!.error!,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Quality
            Row(
              children: [
                const Text('Quality: '),
                Text(
                  _lastResult!.quality.stars,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 8),
                Text(_lastResult!.quality.description),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Measurements
            if (_lastResult!.measurements.isNotEmpty) ...[
              const Text(
                'Measurements:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ..._lastResult!.measurements.entries.map((e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(e.key),
                    Text(
                      _formatValue(e.value),
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ],
                ),
              )),
            ],
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => _runAllTests(context.read<VoiceLineProvider>()),
                  child: const Text('Retry'),
                ),
                if (success)
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Done'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatValue(dynamic value) {
    if (value is double) {
      return value.toStringAsFixed(2);
    }
    return value.toString();
  }

  // === Test Methods ===

  Future<void> _runSignalPathTest(VoiceLineProvider provider) async {
    if (_selectedMethod == null) return;
    await _runTest(provider, 'Signal Path Test');
  }

  Future<void> _runAudioQualityTest(VoiceLineProvider provider) async {
    if (_selectedMethod == null) return;
    await _runTest(provider, 'Audio Quality Test');
  }

  Future<void> _runFullCallTest(VoiceLineProvider provider) async {
    if (_selectedMethod == null) return;
    await _runTest(provider, 'Full Call Test');
  }

  Future<void> _runAllTests(VoiceLineProvider provider) async {
    if (_selectedMethod == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a method')),
      );
      return;
    }

    setState(() {
      _isTesting = true;
      _testProgress = 0;
      _currentTestStep = 'Initializing...';
    });

    // Simulate test progression
    await _simulateTestProgress();

    // Run actual test
    final result = await provider.testMethod(_selectedMethod!);
    
    setState(() {
      _isTesting = false;
      _lastResult = result;
    });
  }

  Future<void> _runTest(VoiceLineProvider provider, String testName) async {
    if (_selectedMethod == null) return;

    setState(() {
      _isTesting = true;
      _testProgress = 0;
      _currentTestStep = testName;
    });

    await _simulateTestProgress();

    final result = await provider.testMethod(_selectedMethod!);
    
    setState(() {
      _isTesting = false;
      _lastResult = result;
    });
  }

  Future<void> _simulateTestProgress() async {
    final steps = [
      'Method detection',
      'Hardware check',
      'Signal path verification',
      'Audio quality test',
      'Full path test',
    ];

    for (int i = 0; i < steps.length; i++) {
      setState(() {
        _testProgress = ((i + 1) * 20);
        _currentTestStep = steps[i];
      });
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }

  void _stopTest() {
    setState(() {
      _isTesting = false;
    });
  }
}
