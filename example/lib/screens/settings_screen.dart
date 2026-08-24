import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

import '../data/example_config_store.dart';
import 'widgets/gateway_config_form.dart';

/// Edits the saved configuration, and offers clearing it —
/// [GatewayService] has no public clear method, so this goes through
/// [ExampleConfigStore] directly (same accepted coupling as Setup; see
/// example/README.md).
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _configStore = ExampleConfigStore();
  final _gateway = GatewayService();

  GatewayConfig? _config;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final config = await _configStore.load();
    if (!mounted) return;
    setState(() {
      _config = config;
      _loading = false;
    });
  }

  Future<void> _save(GatewayConfig config) async {
    await _configStore.save(config);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Configuration updated')));
    setState(() => _config = config);
  }

  Future<void> _clear() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Clear configuration?'),
        content: const Text('This removes the saved SIP/SMPP configuration from this device.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    if (_gateway.isRunning) {
      await _gateway.stop();
    }
    await _configStore.clear();
    if (!mounted) return;
    setState(() => _config = null);
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Configuration cleared')));
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_config == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Settings')),
        body: const Center(child: Text('No configuration yet — save one in Setup first.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: GatewayConfigForm(
        initialConfig: _config,
        submitLabel: 'Save Changes',
        onSubmit: _save,
        footer: OutlinedButton.icon(
          onPressed: _clear,
          icon: const Icon(Icons.delete_outline),
          label: const Text('Clear saved configuration'),
        ),
      ),
    );
  }
}
