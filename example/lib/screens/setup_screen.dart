import 'package:flutter/material.dart';
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

import '../data/example_config_store.dart';
import 'widgets/gateway_config_form.dart';

/// First-launch (and re-editable) configuration form. Builds a
/// [GatewayConfig], runs its already-public [GatewayConfig.
/// validationErrors] before saving, and persists via [ExampleConfigStore]
/// rather than relying on [GatewayService]'s save-on-successful-
/// initialize behavior (see example/README.md's "Configuration
/// persistence" section for why).
class SetupScreen extends StatefulWidget {
  final VoidCallback onSaved;

  const SetupScreen({super.key, required this.onSaved});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _configStore = ExampleConfigStore();

  GatewayConfig? _existingConfig;
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
      _existingConfig = config;
      _loading = false;
    });
  }

  Future<void> _save(GatewayConfig config) async {
    await _configStore.save(config);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Configuration saved')));
    widget.onSaved();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Setup')),
      body: GatewayConfigForm(
        initialConfig: _existingConfig,
        submitLabel: 'Save & Continue',
        onSubmit: _save,
      ),
    );
  }
}
