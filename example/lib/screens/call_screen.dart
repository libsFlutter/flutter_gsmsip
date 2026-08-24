import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

import '../theme/app_widgets.dart';

/// Shows active [CallRouting]s (SIP<->GSM call pairs) and the only call
/// actions [GatewayService] actually exposes: initiate via SIP or GSM,
/// end one, end all. No answer/hold/mute/DTMF — `GatewayService` doesn't
/// proxy `SipRepository`'s per-call methods for those, and this example
/// doesn't invent controls the library can't back.
class CallScreen extends StatefulWidget {
  const CallScreen({super.key});

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> {
  final _gateway = GatewayService();
  StreamSubscription<CallRouting>? _routingSub;
  final _numberCtrl = TextEditingController(text: '+1234567890');

  @override
  void initState() {
    super.initState();
    _routingSub = _gateway.routingStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _routingSub?.cancel();
    _numberCtrl.dispose();
    super.dispose();
  }

  Future<void> _callViaSip() async {
    final id = await _gateway.makeCallViaSip(_numberCtrl.text.trim());
    _showMessage(id != null ? 'Routing started: $id' : 'Call failed — see Logs');
  }

  Future<void> _callViaGsm() async {
    final id = await _gateway.makeCallViaGsm(_numberCtrl.text.trim());
    _showMessage(id != null ? 'GSM call started: $id' : 'Call failed — see Logs');
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  String _statusLabel(CallRoutingState state) {
    switch (state) {
      case CallRoutingState.connecting:
        return 'waiting';
      case CallRoutingState.active:
        return 'active';
      case CallRoutingState.ended:
        return 'ended';
      case CallRoutingState.failed:
        return 'missed';
    }
  }

  @override
  Widget build(BuildContext context) {
    final routings = _gateway.getActiveRoutings();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Call'),
        actions: [
          if (routings.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.call_end),
              tooltip: 'End all',
              onPressed: () async {
                await _gateway.endAllRoutings();
                if (mounted) setState(() {});
              },
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _numberCtrl,
                  decoration: const InputDecoration(labelText: 'Number'),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    OutlinedButton(
                      onPressed: _callViaSip,
                      child: const Text('Test Call via SIP→GSM'),
                    ),
                    OutlinedButton(
                      onPressed: _callViaGsm,
                      child: const Text('Test Call via GSM→SIP'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Card(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Padding(
                    padding: EdgeInsets.all(12),
                    child: Text(
                      "Answer/hold/mute controls aren't available: GatewayService only "
                      'exposes call routing, not per-call SIP actions. See README.',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: routings.isEmpty
                ? const Center(child: Text('No active routings'))
                : ListView.builder(
                    itemCount: routings.length,
                    itemBuilder: (context, index) {
                      final routing = routings[index];
                      return ListTile(
                        leading: AppWidgets.callStatusIndicator(
                          status: _statusLabel(routing.state),
                          phoneNumber: routing.number,
                          duration: routing.formattedDuration,
                        ),
                        title: Text(routing.number),
                        subtitle:
                            Text('${routing.direction.name} • ${routing.formattedDuration}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.call_end),
                          onPressed: () async {
                            await _gateway.endRouting(routing.id);
                            if (mounted) setState(() {});
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
