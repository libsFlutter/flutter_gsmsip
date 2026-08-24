import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gsm/flutter_gsm.dart' as gsm;
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

import '../data/example_config_store.dart';
import '../platform_capabilities.dart';
import '../theme/app_widgets.dart';

/// Demo of [GatewayService], the real SIP<->GSM gateway orchestrator.
/// Device/modem info is read from a separate, example-owned
/// `flutter_gsm` [gsm.ModemRepositoryImpl] instance (the pattern already
/// established by this file before this rewrite), not through
/// [GatewayService] (which doesn't expose its internal one).
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _gateway = GatewayService();
  final _configStore = ExampleConfigStore();
  final _modemRepo = gsm.ModemRepositoryImpl();

  StreamSubscription<GatewayStatus>? _statusSub;
  StreamSubscription<String>? _logSub;

  GatewayStatus? _status;
  final List<String> _recentLogs = [];

  gsm.ModemDevice? _modem;
  String? _modemUnavailableReason;

  final _testNumberCtrl = TextEditingController(text: '+1234567890');

  @override
  void initState() {
    super.initState();
    _statusSub = _gateway.statusStream.listen((s) {
      if (mounted) setState(() => _status = s);
    });
    _logSub = _gateway.logStream.listen((line) {
      _recentLogs.add(line);
      if (_recentLogs.length > 20) _recentLogs.removeAt(0);
    });
    _loadModem();
  }

  Future<void> _loadModem() async {
    if (!PlatformCapabilities.modemDriverSupported) {
      setState(() =>
          _modemUnavailableReason = 'GSM modem driver not available on this platform');
      return;
    }
    try {
      final modems = await _modemRepo.listModems();
      if (!mounted) return;
      setState(() {
        _modem = modems.isEmpty ? null : modems.first;
        _modemUnavailableReason = modems.isEmpty ? 'No modem currently found' : null;
      });
    } on gsm.ModemException catch (e) {
      if (mounted) setState(() => _modemUnavailableReason = e.message);
    }
  }

  Future<void> _toggleGateway() async {
    if (_status?.isRunning ?? false) {
      await _gateway.stop();
      return;
    }

    final config = await _configStore.load();
    if (config == null) {
      _showMessage('No configuration found — save one in Setup first');
      return;
    }

    final initialized = await _gateway.initialize(config);
    if (!initialized) {
      _showFailure('Failed to initialize gateway');
      return;
    }

    final started = await _gateway.start();
    if (!started) {
      _showFailure('Gateway initialized but failed to start');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Surfaces the real reason from [GatewayService.logStream] rather
  /// than a generic message — this is the concrete fix for the example
  /// silently discarding `initialize()`/`start()`'s failure results.
  void _showFailure(String headline) {
    if (!mounted) return;
    final tail =
        _recentLogs.length > 5 ? _recentLogs.sublist(_recentLogs.length - 5) : _recentLogs;
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(headline),
        content: SingleChildScrollView(
          child: Text(
            tail.isEmpty
                ? 'No log detail available — check the Logs tab.'
                : tail.join('\n'),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _makeTestCall() async {
    final routingId = await _gateway.makeCallViaSip(_testNumberCtrl.text.trim());
    _showMessage(routingId != null ? 'Call initiated: $routingId' : 'Call failed — see Logs');
  }

  Future<void> _sendTestSms() async {
    final messageId = await _gateway.sendSms(
      _testNumberCtrl.text.trim(),
      'Test message from flutter_gsmsip example',
    );
    _showMessage(messageId != null ? 'SMS sent: $messageId' : 'SMS failed — see Logs');
  }

  @override
  void dispose() {
    _statusSub?.cancel();
    _logSub?.cancel();
    _testNumberCtrl.dispose();
    super.dispose();
  }

  Color _colorFor(String name) {
    switch (name) {
      case 'green':
        return Colors.green;
      case 'orange':
        return Colors.orange;
      case 'red':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = _status ?? const GatewayStatus();
    final isRunning = status.isRunning;
    final capabilityWarnings = [
      if (!PlatformCapabilities.sipSupported) 'SIP is not supported on this platform.',
      if (!PlatformCapabilities.modemDriverSupported)
        'GSM modem driver is not available on this platform.',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (capabilityWarnings.isNotEmpty) ...[
            Card(
              color: Theme.of(context).colorScheme.tertiaryContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(capabilityWarnings.join(' ')),
              ),
            ),
            const SizedBox(height: 12),
          ],
          AppWidgets.statusCard(
            title: 'Gateway',
            status: status.statusSummary,
            statusColor: _colorFor(status.statusColor),
            subtitle:
                'SIP: ${status.sipState.name}  •  SMPP: ${status.smppState?.name ?? "not configured"}',
            icon: Icons.dns,
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Modem', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  if (_modem != null) ...[
                    Text(_modem!.displayName ?? _modem!.id),
                    if (_modem!.imei != null) Text('IMEI: ${_modem!.imei}'),
                    if (_modem!.signal != null) ...[
                      const SizedBox(height: 4),
                      AppWidgets.signalIndicator(
                        signalLevel: ((_modem!.signal! / 31) * 100).round().clamp(0, 100),
                      ),
                    ],
                    Text('Registration: ${_modem!.registration.name}'),
                  ] else
                    Text(_modemUnavailableReason ?? 'Looking for a modem…'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _toggleGateway,
            icon: Icon(isRunning ? Icons.stop : Icons.play_arrow),
            label: Text(isRunning ? 'Stop Gateway' : 'Start Gateway'),
          ),
          const SizedBox(height: 24),
          Text('Quick Actions', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          TextField(
            controller: _testNumberCtrl,
            decoration: const InputDecoration(labelText: 'Test number'),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(
                onPressed: _makeTestCall,
                child: const Text('Make Test Call (SIP→GSM)'),
              ),
              OutlinedButton(onPressed: _sendTestSms, child: const Text('Send Test SMS')),
            ],
          ),
        ],
      ),
    );
  }
}
