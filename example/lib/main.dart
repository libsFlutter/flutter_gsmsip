import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

void main() {
  runApp(const GOSTsimboxApp());
}

class GOSTsimboxApp extends StatelessWidget {
  const GOSTsimboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GOSTsimbox Gateway',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

/// Demo of [GatewayService], the SIP<->GSM gateway orchestrator. Device
/// info (phone number/signal) moved out with `TelephonyService`'s removal —
/// see flows/sdd-flutter_gsm/04-implementation-log.md Task 11; use
/// `flutter_gsm`'s `ModemRepository` directly for that.
class _DashboardScreenState extends State<DashboardScreen> {
  final GatewayService _gatewayService = GatewayService();

  GatewayStatus? _status;

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Listen to gateway status
    _gatewayService.statusStream.listen((status) {
      if (mounted) {
        setState(() {
          _status = status;
        });
      }
    });

    // Load configuration
    final config = await _gatewayService.loadConfiguration();
    if (config != null) {
      await _gatewayService.initialize(config);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GOSTsimbox Gateway'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gateway Status Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Gateway Status',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    _buildStatusRow(
                      'Running',
                      _status?.isRunning ?? false,
                    ),
                    _buildStatusRow(
                      'SIP',
                      _status?.sipState == SipConnectionState.connected,
                    ),
                    _buildStatusRow(
                      'SMPP',
                      _status?.smppState == SmppConnectionState.connected,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Controls
            ElevatedButton(
              onPressed: _toggleGateway,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    _status?.isRunning ?? false ? Colors.red : Colors.green,
                foregroundColor: Colors.white,
              ),
              child: Text(_status?.isRunning ?? false ? 'Stop Gateway' : 'Start Gateway'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _makeTestCall,
              child: const Text('Make Test Call (via SIP)'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _sendTestSms,
              child: const Text('Send Test SMS'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusRow(String label, bool isActive) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: isActive ? Colors.green : Colors.red,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleGateway() async {
    if (_status?.isRunning ?? false) {
      await _gatewayService.stop();
    } else {
      final config = await _gatewayService.loadConfiguration();
      if (config != null) {
        await _gatewayService.initialize(config);
        await _gatewayService.start();
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No configuration found')),
          );
        }
      }
    }
  }

  Future<void> _makeTestCall() async {
    final routingId = await _gatewayService.makeCallViaSip('+1234567890');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(routingId != null ? 'Call initiated: $routingId' : 'Call failed')),
    );
  }

  Future<void> _sendTestSms() async {
    final messageId = await _gatewayService.sendSms('+1234567890', 'Test message from GOSTsimbox');
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(messageId != null ? 'SMS sent: $messageId' : 'SMS failed')),
    );
  }
}
