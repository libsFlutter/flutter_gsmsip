import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';
import '../../domain/models/dongle_type.dart';
import '../../domain/models/resistance_measurements.dart';

/// Экран автоопределения типа донгла
class DetectDongleTypeScreen extends StatefulWidget {
  const DetectDongleTypeScreen({super.key});

  @override
  State<DetectDongleTypeScreen> createState() => _DetectDongleTypeScreenState();
}

class _DetectDongleTypeScreenState extends State<DetectDongleTypeScreen> {
  bool _isMeasuring = false;
  ResistanceMeasurements? _measurements;
  DongleType? _detectedType;
  double _confidence = 0.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detect Dongle Type'),
      ),
      body: Consumer<DongleProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Interface info
                _buildInterfaceInfo(provider),

                const SizedBox(height: 24),

                // Resistance measurements
                _buildResistanceSection(provider),

                const SizedBox(height: 24),

                // Detected type
                if (_detectedType != null) ...[
                  _buildDetectedTypeSection(),
                  const SizedBox(height: 24),
                ],

                // Action buttons
                _buildActionButtons(provider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInterfaceInfo(DongleProvider provider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Interface',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.interfaceType?.displayName ?? 'Unknown',
              style: const TextStyle(fontSize: 16),
            ),
            if (provider.interfaceType == DongleInterfaceType.usbCWithDac) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Cannot measure resistance (digital interface)',
                        style: TextStyle(color: Colors.orange.shade700),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildResistanceSection(DongleProvider provider) {
    final measurements = provider.lastMeasurements ?? _measurements;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Resistance Measurements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (!_isMeasuring && provider.isAnalog)
                  IconButton(
                    icon: const Icon(Icons.refresh),
                    onPressed: () => _measureResistance(provider),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            if (_isMeasuring) ...[
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            ] else if (measurements != null) ...[
              _buildMeasurementRow('GND → MIC', measurements.gndToMic),
              _buildMeasurementRow('L → GND', measurements.leftToGnd),
              _buildMeasurementRow('R → GND', measurements.rightToGnd),
              if (measurements.leftToMic != null)
                _buildMeasurementRow('L → MIC', measurements.leftToMic),
            ] else ...[
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    children: [
                      Icon(Icons.usb, size: 48, color: Colors.grey.shade400),
                      const SizedBox(height: 16),
                      Text(
                        'Press measure to start',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementRow(String label, int? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 16),
          ),
          Text(
            _formatResistance(value),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetectedTypeSection() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green.shade700),
                const SizedBox(width: 12),
                Text(
                  'Detected Dongle Type',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              _detectedType!.displayName,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              _detectedType!.resistanceSignature,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 16),
            if (_confidence > 0) ...[
              const Text('Confidence:'),
              const SizedBox(height: 4),
              LinearProgressIndicator(
                value: _confidence,
                color: Colors.green,
              ),
              const SizedBox(height: 4),
              Text(
                '${(_confidence * 100).toStringAsFixed(1)}%',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(DongleProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        if (provider.isAnalog && !_isMeasuring)
          ElevatedButton.icon(
            icon: const Icon(Icons.usb),
            label: const Text('Measure'),
            onPressed: () => _measureResistance(provider),
          ),
        if (_detectedType != null)
          ElevatedButton(
            onPressed: () => _acceptType(provider),
            child: const Text('Accept & Configure'),
          ),
      ],
    );
  }

  Future<void> _measureResistance(DongleProvider provider) async {
    setState(() {
      _isMeasuring = true;
      _measurements = null;
      _detectedType = null;
    });

    final measurements = await provider.measureResistance();

    setState(() {
      _isMeasuring = false;
      _measurements = measurements;

      if (measurements != null && measurements.error == null) {
        _detectedType = measurements.detectType();
        if (_detectedType != null) {
          _confidence = measurements.getConfidence(_detectedType!);
        }
      }
    });
  }

  void _acceptType(DongleProvider provider) {
    if (_detectedType == null) return;

    provider.setDongleType(_detectedType!);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Dongle type saved')),
    );
    Navigator.pop(context);
  }

  String _formatResistance(int? value) {
    if (value == null) return 'N/A';
    if (value == -1) return '∞';
    if (value >= 1000000) return '${(value / 1000000).toStringAsFixed(1)}MΩ';
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}kΩ';
    return '${value}Ω';
  }
}
