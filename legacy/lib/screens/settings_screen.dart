import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/gateway_service.dart';
import '../services/theme_service.dart';
import '../core/error/error_handler.dart';
import 'setup_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  GatewayConfig? _config;
  ThemeMode? _currentThemeMode;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    _loadTheme();
  }

  Future<void> _loadConfig() async {
    final gatewayService = context.read<GatewayService>();
    final config = await gatewayService.loadConfiguration();
    if (mounted) {
      setState(() {
        _config = config;
      });
    }
  }

  void _loadTheme() {
    final themeService = context.read<ThemeService>();
    setState(() {
      _currentThemeMode = themeService.themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: _config == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildThemeSection(),
                const SizedBox(height: 16),
                _buildSipConfigSection(),
                const SizedBox(height: 16),
                _buildSmppConfigSection(),
                const SizedBox(height: 16),
                _buildGatewaySettingsSection(),
                const SizedBox(height: 16),
                _buildActionsSection(),
              ],
            ),
    );
  }

  Widget _buildThemeSection() {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.palette, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                const Text(
                  'Theme',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildThemeOption(
                    'Light',
                    Icons.wb_sunny,
                    ThemeMode.light,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    'Dark',
                    Icons.nightlight_round,
                    ThemeMode.dark,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildThemeOption(
                    'System',
                    Icons.settings_system_daydream,
                    ThemeMode.system,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeOption(String label, IconData icon, ThemeMode mode) {
    final isSelected = _currentThemeMode == mode;
    return InkWell(
      onTap: () async {
        final themeService = context.read<ThemeService>();
        await themeService.setThemeMode(mode);
        setState(() {
          _currentThemeMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSipConfigSection() {
    final sipAccount = _config!.sipAccount;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIP Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildConfigRow('Username', sipAccount.username),
            _buildConfigRow('Domain', sipAccount.domain),
            if (sipAccount.proxy != null)
              _buildConfigRow('Proxy', sipAccount.proxy!),
            _buildConfigRow('Port', sipAccount.port.toString()),
            _buildConfigRow('Secure', sipAccount.useSecure ? 'Yes' : 'No'),
          ],
        ),
      ),
    );
  }

  Widget _buildSmppConfigSection() {
    final smppConfig = _config!.smppConfig;
    
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SMPP Configuration',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            if (smppConfig != null) ...[
              _buildConfigRow('Host', smppConfig.host),
              _buildConfigRow('Port', smppConfig.port.toString()),
              _buildConfigRow('System ID', smppConfig.systemId),
            ] else
              const Text(
                'SMPP not configured',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGatewaySettingsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gateway Settings',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            _buildConfigRow('Auto Answer', _config!.autoAnswer ? 'Yes' : 'No'),
            _buildConfigRow('Enable Logging', _config!.enableLogging ? 'Yes' : 'No'),
            _buildConfigRow('Route SIP to GSM', _config!.routeSipToGsm ? 'Yes' : 'No'),
            _buildConfigRow('Route GSM to SIP', _config!.routeGsmToSip ? 'Yes' : 'No'),
            _buildConfigRow('Route SMS to SMPP', _config!.routeSmsToSmpp ? 'Yes' : 'No'),
            _buildConfigRow('Route SMPP to SMS', _config!.routeSmppToSms ? 'Yes' : 'No'),
            _buildConfigRow('Max Concurrent Calls', _config!.maxConcurrentCalls.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildActionsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Actions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Reconfigure Gateway'),
              subtitle: const Text('Change gateway settings'),
              onTap: _reconfigureGateway,
            ),
            
            ListTile(
              leading: const Icon(Icons.refresh),
              title: const Text('Restart Services'),
              subtitle: const Text('Restart SIP and SMPP connections'),
              onTap: _restartServices,
            ),
            
            ListTile(
              leading: const Icon(Icons.delete_sweep),
              title: const Text('Clear Logs'),
              subtitle: const Text('Clear application logs'),
              onTap: _clearLogs,
            ),
            
            const Divider(),
            
            ListTile(
              leading: const Icon(Icons.info),
              title: const Text('About'),
              subtitle: const Text('GOSTsimbox Gateway v3.0.0'),
              onTap: _showAboutDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfigRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _reconfigureGateway() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const SetupScreen()),
    );
  }

  Future<void> _restartServices() async {
    final confirmed = await _showConfirmDialog(
      'Restart Services',
      'This will restart SIP and SMPP connections. Continue?',
    );
    
    if (confirmed && mounted) {
      final gatewayService = context.read<GatewayService>();
      
      try {
        await gatewayService.stop();
        await Future.delayed(const Duration(seconds: 1));
        await gatewayService.start();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Services restarted successfully')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to restart services: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _clearLogs() async {
    final confirmed = await _showConfirmDialog(
      'Clear Logs',
      'This will delete all application logs. Continue?',
    );
    
    if (confirmed && mounted) {
      try {
        await ErrorHandler.clearErrorLogs();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Logs cleared')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to clear logs: $e')),
        );
      }
    }
  }

  void _showAboutDialog() {
    showAboutDialog(
      context: context,
      applicationName: 'GOSTsimbox Gateway',
      applicationVersion: '3.0.0',
      applicationIcon: const Icon(Icons.router, size: 48),
      children: [
        const Text('A bidirectional gateway between GSM telephony and SIP/SMPP protocols.'),
        const SizedBox(height: 16),
        const Text('Features:'),
        const Text('• SIP to GSM call routing'),
        const Text('• GSM to SIP call routing'),
        const Text('• SMS via SMPP protocol'),
        const Text('• Real-time monitoring'),
        const Text('• Comprehensive logging'),
      ],
    );
  }

  Future<bool> _showConfirmDialog(String title, String content) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Continue'),
          ),
        ],
      ),
    );
    
    return result ?? false;
  }
}