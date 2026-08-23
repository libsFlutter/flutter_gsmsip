import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dongle_provider.dart';

/// Экран мониторинга донгла во время звонка
class DongleMonitorScreen extends StatefulWidget {
  const DongleMonitorScreen({super.key});

  @override
  State<DongleMonitorScreen> createState() => _DongleMonitorScreenState();
}

class _DongleMonitorScreenState extends State<DongleMonitorScreen> {
  int _callDuration = 0; // seconds
  bool _isMuted = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _callDuration++;
      });
    });
  }

  String _formatDuration(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    final secs = seconds % 60;
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dongle Monitor'),
        actions: [
          IconButton(
            icon: Icon(_isMuted ? Icons.mic_off : Icons.mic),
            onPressed: () => setState(() => _isMuted = !_isMuted),
          ),
          IconButton(
            icon: const Icon(Icons.call_end),
            color: Colors.red,
            onPressed: () => _endCall(context),
          ),
        ],
      ),
      body: Consumer<DongleProvider>(
        builder: (context, provider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Call Status
                _buildCallStatusCard(),
                
                const SizedBox(height: 16),
                
                // Audio Levels
                _buildAudioLevelsCard(),
                
                const SizedBox(height: 16),
                
                // Signal Path
                _buildSignalPathCard(provider),
                
                const SizedBox(height: 16),
                
                // Statistics
                _buildStatisticsCard(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCallStatusCard() {
    return Card(
      color: Colors.green.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.call, size: 48, color: Colors.green.shade700),
            const SizedBox(height: 16),
            const Text(
              'Call Active',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDuration(_callDuration),
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioLevelsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Audio Levels',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // TX Level
            _buildLevelRow(
              'TX (SIP → Line)',
              0.75,
              -6,
              Colors.blue,
            ),
            
            const SizedBox(height: 16),
            
            // RX Level
            _buildLevelRow(
              'RX (Line → SIP)',
              0.5,
              -12,
              Colors.orange,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelRow(String label, double level, int db, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 14)),
            Text(
              '$db dB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: level,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildSignalPathCard(DongleProvider provider) {
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
            const SizedBox(height: 16),
            
            // TX Path
            _buildPathRow(
              'TX',
              ['SIP', 'Inversion', 'Dongle', 'Line'],
              ['[L,R]', '[L,-R]', 'analog', 'diff'],
            ),
            
            const SizedBox(height: 16),
            
            // RX Path
            _buildPathRow(
              'RX',
              ['Line', 'Dongle', 'ADC', 'SIP'],
              ['diff', 'analog', '', ''],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPathRow(String label, List<String> stages, List<String> formats) {
    return Row(
      children: [
        SizedBox(
          width: 40,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: Row(
            children: List.generate(
              stages.length,
              (index) => Expanded(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        stages[index],
                        style: const TextStyle(fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (formats[index].isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        formats[index],
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Packet stats
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('TX Packets', '15,234'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox('RX Packets', '15,230'),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Loss stats
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('TX Lost', '0 (0.00%)', isSuccess: true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox('RX Lost', '4', isSuccess: false),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            // Latency/Jitter
            Row(
              children: [
                Expanded(
                  child: _buildStatBox('Latency', '8ms'),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatBox('Jitter', '2ms'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatBox(String label, String value, {bool? isSuccess}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isSuccess == null
            ? Colors.grey.shade100
            : (isSuccess ? Colors.green.shade50 : Colors.orange.shade50),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  void _endCall(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Call'),
        content: const Text('Are you sure you want to end this call?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close screen
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}
