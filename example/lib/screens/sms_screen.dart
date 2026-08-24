import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

import '../data/example_config_store.dart';

/// Reads message history/updates directly from [SmsService] (a public
/// singleton — same instance [GatewayService] uses internally, safe to
/// read from both places), and sends through [GatewayService.sendSms].
///
/// SMPP is a simulated stub in the library today (fixed-delay
/// "connection", randomized delivery success) — this screen labels it
/// as such rather than presenting it as real, per example/README.md.
class SmsScreen extends StatefulWidget {
  const SmsScreen({super.key});

  @override
  State<SmsScreen> createState() => _SmsScreenState();
}

class _SmsScreenState extends State<SmsScreen> {
  final _smsService = SmsService();
  final _gateway = GatewayService();
  final _configStore = ExampleConfigStore();

  StreamSubscription<SmsMessage>? _messageSub;
  final _recipientCtrl = TextEditingController(text: '+1234567890');
  final _contentCtrl =
      TextEditingController(text: 'Test message from flutter_gsmsip example');
  bool _useSmpp = false;
  bool _smppConfigured = false;

  @override
  void initState() {
    super.initState();
    _messageSub = _smsService.messageStream.listen((_) {
      if (mounted) setState(() {});
    });
    _loadSmppAvailability();
  }

  Future<void> _loadSmppAvailability() async {
    final config = await _configStore.load();
    if (!mounted) return;
    setState(() => _smppConfigured = config?.smppConfig != null);
  }

  @override
  void dispose() {
    _messageSub?.cancel();
    _recipientCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final messageId = await _gateway.sendSms(
      _recipientCtrl.text.trim(),
      _contentCtrl.text,
      useSmpp: _useSmpp && _smppConfigured,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(messageId != null ? 'Sent: $messageId' : 'Send failed — see Logs'),
      ),
    );
  }

  IconData _statusIcon(SmsMessageStatus status) {
    switch (status) {
      case SmsMessageStatus.pending:
        return Icons.schedule;
      case SmsMessageStatus.sent:
        return Icons.check;
      case SmsMessageStatus.delivered:
        return Icons.done_all;
      case SmsMessageStatus.failed:
        return Icons.error_outline;
      case SmsMessageStatus.received:
        return Icons.inbox;
    }
  }

  @override
  Widget build(BuildContext context) {
    final messages = _smsService.getMessageHistory();

    return Scaffold(
      appBar: AppBar(title: const Text('SMS')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _recipientCtrl,
                  decoration: const InputDecoration(labelText: 'Recipient'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _contentCtrl,
                  decoration: const InputDecoration(labelText: 'Message'),
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Send via SMPP (simulated)'),
                  subtitle: _smppConfigured
                      ? null
                      : const Text('No SMPP configured — will send via local GSM instead'),
                  value: _useSmpp && _smppConfigured,
                  onChanged: _smppConfigured ? (v) => setState(() => _useSmpp = v) : null,
                ),
                FilledButton(onPressed: _send, child: const Text('Send')),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('No messages yet'))
                : ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final m = messages[index];
                      return ListTile(
                        leading: Icon(_statusIcon(m.status)),
                        title: Text(m.type == SmsMessageType.incoming ? m.sender : m.recipient),
                        subtitle: Text(m.content),
                        trailing: Text(m.status.name),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
