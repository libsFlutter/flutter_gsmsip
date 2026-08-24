import 'package:flutter/material.dart';

import 'data/example_config_store.dart';
import 'screens/call_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/logs_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'screens/sms_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const GostSimboxExampleApp());
}

class GostSimboxExampleApp extends StatelessWidget {
  const GostSimboxExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'flutter_gsmsip Example',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const RootShell(),
    );
  }
}

/// App shell: bottom navigation across the 6 screens that demonstrate
/// `GatewayService`. On first launch (no saved config found via
/// [ExampleConfigStore]) opens on Setup instead of Dashboard — see
/// flows/flutter_gsmsip/sdd-flutter_gsmsip-example/02-specifications.md.
class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  static const _tabs = [
    _Tab('Setup', Icons.settings_input_antenna_outlined, Icons.settings_input_antenna),
    _Tab('Dashboard', Icons.dashboard_outlined, Icons.dashboard),
    _Tab('Settings', Icons.tune_outlined, Icons.tune),
    _Tab('Call', Icons.call_outlined, Icons.call),
    _Tab('SMS', Icons.sms_outlined, Icons.sms),
    _Tab('Logs', Icons.article_outlined, Icons.article),
  ];

  final _configStore = ExampleConfigStore();
  int _index = 1;
  bool _resolvedInitialTab = false;

  @override
  void initState() {
    super.initState();
    _resolveInitialTab();
  }

  Future<void> _resolveInitialTab() async {
    final config = await _configStore.load();
    if (!mounted) return;
    setState(() {
      _index = config == null ? 0 : 1;
      _resolvedInitialTab = true;
    });
  }

  void _goToDashboard() => setState(() => _index = 1);

  @override
  Widget build(BuildContext context) {
    if (!_resolvedInitialTab) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final screens = <Widget>[
      SetupScreen(onSaved: _goToDashboard),
      const DashboardScreen(),
      const SettingsScreen(),
      const CallScreen(),
      const SmsScreen(),
      const LogsScreen(),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

class _Tab {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const _Tab(this.label, this.icon, this.selectedIcon);
}
