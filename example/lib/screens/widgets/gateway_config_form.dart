import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

/// Shared SIP+SMPP+routing form, used by both Setup (first-time entry)
/// and Settings (editing a saved config) — extracted to avoid
/// duplicating the same ~15 fields and validation flow twice.
class GatewayConfigForm extends StatefulWidget {
  final GatewayConfig? initialConfig;
  final String submitLabel;
  final Future<void> Function(GatewayConfig config) onSubmit;
  final Widget? footer;

  const GatewayConfigForm({
    super.key,
    this.initialConfig,
    required this.submitLabel,
    required this.onSubmit,
    this.footer,
  });

  @override
  State<GatewayConfigForm> createState() => _GatewayConfigFormState();
}

class _GatewayConfigFormState extends State<GatewayConfigForm> {
  late final _usernameCtrl =
      TextEditingController(text: widget.initialConfig?.sipAccount.username);
  late final _passwordCtrl =
      TextEditingController(text: widget.initialConfig?.sipAccount.password);
  late final _domainCtrl =
      TextEditingController(text: widget.initialConfig?.sipAccount.domain);
  late final _portCtrl = TextEditingController(
      text: (widget.initialConfig?.sipAccount.port ?? 5060).toString());
  late final _displayNameCtrl =
      TextEditingController(text: widget.initialConfig?.sipAccount.displayName);
  late SipTransport _transport =
      widget.initialConfig?.sipAccount.transport ?? SipTransport.udp;

  late bool _smppEnabled = widget.initialConfig?.smppConfig != null;
  late final _smppHostCtrl =
      TextEditingController(text: widget.initialConfig?.smppConfig?.host);
  late final _smppPortCtrl = TextEditingController(
      text: (widget.initialConfig?.smppConfig?.port ?? 2775).toString());
  late final _smppSystemIdCtrl =
      TextEditingController(text: widget.initialConfig?.smppConfig?.systemId);
  late final _smppPasswordCtrl =
      TextEditingController(text: widget.initialConfig?.smppConfig?.password);

  late bool _autoAnswer = widget.initialConfig?.autoAnswer ?? false;
  late bool _enableLogging = widget.initialConfig?.enableLogging ?? true;
  late bool _routeSipToGsm = widget.initialConfig?.routeSipToGsm ?? true;
  late bool _routeGsmToSip = widget.initialConfig?.routeGsmToSip ?? true;
  late bool _routeSmsToSmpp = widget.initialConfig?.routeSmsToSmpp ?? false;
  late bool _routeSmppToSms = widget.initialConfig?.routeSmppToSms ?? false;
  late final _maxCallsCtrl = TextEditingController(
      text: (widget.initialConfig?.maxConcurrentCalls ?? 5).toString());

  List<String> _validationErrors = const [];
  bool _submitting = false;

  GatewayConfig _buildConfig() {
    return GatewayConfig(
      sipAccount: SipAccount(
        id: widget.initialConfig?.sipAccount.id ?? 'default',
        username: _usernameCtrl.text.trim(),
        password: _passwordCtrl.text,
        domain: _domainCtrl.text.trim(),
        port: int.tryParse(_portCtrl.text) ?? 5060,
        transport: _transport,
        displayName:
            _displayNameCtrl.text.trim().isEmpty ? null : _displayNameCtrl.text.trim(),
      ),
      smppConfig: _smppEnabled
          ? SmppConfig(
              host: _smppHostCtrl.text.trim(),
              port: int.tryParse(_smppPortCtrl.text) ?? 2775,
              systemId: _smppSystemIdCtrl.text.trim(),
              password: _smppPasswordCtrl.text,
            )
          : null,
      autoAnswer: _autoAnswer,
      enableLogging: _enableLogging,
      routeSipToGsm: _routeSipToGsm,
      routeGsmToSip: _routeGsmToSip,
      routeSmsToSmpp: _routeSmsToSmpp,
      routeSmppToSms: _routeSmppToSms,
      maxConcurrentCalls: int.tryParse(_maxCallsCtrl.text) ?? 5,
    );
  }

  Future<void> _submit() async {
    final config = _buildConfig();
    final errors = config.validationErrors;
    setState(() => _validationErrors = errors);
    if (errors.isNotEmpty) return;

    setState(() => _submitting = true);
    try {
      await widget.onSubmit(config);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _passwordCtrl.dispose();
    _domainCtrl.dispose();
    _portCtrl.dispose();
    _displayNameCtrl.dispose();
    _smppHostCtrl.dispose();
    _smppPortCtrl.dispose();
    _smppSystemIdCtrl.dispose();
    _smppPasswordCtrl.dispose();
    _maxCallsCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_validationErrors.isNotEmpty)
          Card(
            color: theme.colorScheme.errorContainer,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Fix before saving:',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                  for (final e in _validationErrors)
                    Text('• $e', style: TextStyle(color: theme.colorScheme.onErrorContainer)),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('SIP Account', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        TextField(
          controller: _usernameCtrl,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _passwordCtrl,
          decoration: const InputDecoration(labelText: 'Password'),
          obscureText: true,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _domainCtrl,
          decoration: const InputDecoration(labelText: 'Domain / Server'),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _portCtrl,
          decoration: const InputDecoration(labelText: 'Port'),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _displayNameCtrl,
          decoration: const InputDecoration(labelText: 'Display Name (optional)'),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<SipTransport>(
          initialValue: _transport,
          decoration: const InputDecoration(labelText: 'Transport'),
          items: [
            for (final t in SipTransport.values)
              DropdownMenuItem(value: t, child: Text(t.name.toUpperCase())),
          ],
          onChanged: (t) => setState(() => _transport = t ?? SipTransport.udp),
        ),
        const Divider(height: 32),
        SwitchListTile(
          title: const Text('Enable SMPP'),
          subtitle: const Text('Simulated in this library build — see README'),
          value: _smppEnabled,
          onChanged: (v) => setState(() => _smppEnabled = v),
        ),
        if (_smppEnabled) ...[
          TextField(
            controller: _smppHostCtrl,
            decoration: const InputDecoration(labelText: 'SMPP Host'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _smppPortCtrl,
            decoration: const InputDecoration(labelText: 'SMPP Port'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _smppSystemIdCtrl,
            decoration: const InputDecoration(labelText: 'System ID'),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _smppPasswordCtrl,
            decoration: const InputDecoration(labelText: 'SMPP Password'),
            obscureText: true,
          ),
        ],
        const Divider(height: 32),
        Text('Gateway Options', style: theme.textTheme.titleMedium),
        SwitchListTile(
          title: const Text('Auto-answer incoming GSM calls'),
          value: _autoAnswer,
          onChanged: (v) => setState(() => _autoAnswer = v),
        ),
        SwitchListTile(
          title: const Text('Enable logging'),
          value: _enableLogging,
          onChanged: (v) => setState(() => _enableLogging = v),
        ),
        SwitchListTile(
          title: const Text('Route SIP → GSM'),
          value: _routeSipToGsm,
          onChanged: (v) => setState(() => _routeSipToGsm = v),
        ),
        SwitchListTile(
          title: const Text('Route GSM → SIP'),
          value: _routeGsmToSip,
          onChanged: (v) => setState(() => _routeGsmToSip = v),
        ),
        SwitchListTile(
          title: const Text('Route SMS → SMPP'),
          value: _routeSmsToSmpp,
          onChanged: (v) => setState(() => _routeSmsToSmpp = v),
        ),
        SwitchListTile(
          title: const Text('Route SMPP → SMS'),
          value: _routeSmppToSms,
          onChanged: (v) => setState(() => _routeSmppToSms = v),
        ),
        ListTile(
          title: const Text('Max concurrent calls'),
          trailing: SizedBox(
            width: 80,
            child: TextField(
              textAlign: TextAlign.end,
              keyboardType: TextInputType.number,
              controller: _maxCallsCtrl,
            ),
          ),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: _submitting ? null : _submit,
          child: Text(widget.submitLabel),
        ),
        if (widget.footer != null) ...[
          const SizedBox(height: 12),
          widget.footer!,
        ],
      ],
    );
  }
}
