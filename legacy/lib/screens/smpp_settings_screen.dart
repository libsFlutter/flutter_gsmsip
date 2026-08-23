import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../utils/text_styles.dart';
import '../models/smpp_config.dart';
import '../providers/gateway_provider.dart';
import '../services/sms_service_smpp.dart';

class SmppSettingsScreen extends StatefulWidget {
  const SmppSettingsScreen({Key? key}) : super(key: key);

  @override
  State<SmppSettingsScreen> createState() => _SmppSettingsScreenState();
}

class _SmppSettingsScreenState extends State<SmppSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hostController = TextEditingController();
  final _portController = TextEditingController();
  final _systemIdController = TextEditingController();
  final _passwordController = TextEditingController();
  final _systemTypeController = TextEditingController();
  
  bool _enableDeliveryReceipts = true;
  bool _enableLogging = true;
  bool _isLoading = false;
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentConfig();
  }

  void _loadCurrentConfig() {
    // Load current SMPP config if exists
    // This would typically come from storage
    _portController.text = '2775';
    _systemTypeController.text = '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        elevation: 0,
        title: Text(
          'SMPP Settings',
          style: AppTextStyles.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            onPressed: () => Navigator.pushNamed(context, '/smpp-logs'),
          ),
          IconButton(
            icon: Icon(
              _isConnected ? Icons.link : Icons.link_off,
              color: _isConnected ? Colors.green : Colors.red,
            ),
            onPressed: _isConnected ? _disconnectSmpp : _connectSmpp,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildConnectionStatus(),
              const SizedBox(height: 24),
              _buildBasicSettings(),
              const SizedBox(height: 24),
              _buildAdvancedSettings(),
              const SizedBox(height: 32),
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildConnectionStatus() {
    return Consumer<GatewayProvider>(
      builder: (context, provider, child) {
        final smppService = provider.smsService as SmsServiceSmpp;
        final connectionState = smppService.smppConnectionState;
        
        Color statusColor;
        String statusText;
        IconData statusIcon;

        switch (connectionState) {
          case SmppConnectionState.disconnected:
            statusColor = Colors.red;
            statusText = 'Disconnected';
            statusIcon = Icons.link_off;
            break;
          case SmppConnectionState.connecting:
            statusColor = Colors.orange;
            statusText = 'Connecting...';
            statusIcon = Icons.link;
            break;
          case SmppConnectionState.connected:
            statusColor = Colors.blue;
            statusText = 'Connected';
            statusIcon = Icons.link;
            break;
          case SmppConnectionState.bound:
            statusColor = Colors.green;
            statusText = 'Bound';
            statusIcon = Icons.link;
            break;
          case SmppConnectionState.error:
            statusColor = Colors.red;
            statusText = 'Error';
            statusIcon = Icons.error;
            break;
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A1A),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: statusColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                statusIcon,
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SMPP Connection Status',
                      style: AppTextStyles.poppins(
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      statusText,
                      style: AppTextStyles.poppins(
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (smppService.isSmppEnabled)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Enabled',
                    style: AppTextStyles.poppins(
                      fontSize: 12,
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBasicSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Settings',
          style: AppTextStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _hostController,
          style: AppTextStyles.poppins(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'SMPP Server Host',
            labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.dns, color: Colors.grey[400]),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter SMPP server host';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _portController,
          style: AppTextStyles.poppins(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Port',
            labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.router, color: Colors.grey[400]),
          ),
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter port number';
            }
            final port = int.tryParse(value);
            if (port == null || port < 1 || port > 65535) {
              return 'Please enter a valid port number (1-65535)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _systemIdController,
          style: AppTextStyles.poppins(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'System ID',
            labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.account_circle, color: Colors.grey[400]),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter System ID';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          style: AppTextStyles.poppins(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.lock, color: Colors.grey[400]),
          ),
          obscureText: true,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter password';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _systemTypeController,
          style: AppTextStyles.poppins(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'System Type (optional)',
            labelStyle: AppTextStyles.poppins(color: Colors.grey[400]),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[600]!),
              borderRadius: BorderRadius.circular(8),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.blue),
              borderRadius: BorderRadius.circular(8),
            ),
            prefixIcon: Icon(Icons.settings, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }

  Widget _buildAdvancedSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Advanced Settings',
          style: AppTextStyles.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: Text(
            'Enable Delivery Receipts',
            style: AppTextStyles.poppins(color: Colors.white),
          ),
          subtitle: Text(
            'Receive delivery confirmations for sent messages',
            style: AppTextStyles.poppins(color: Colors.grey[400]),
          ),
          value: _enableDeliveryReceipts,
          onChanged: (value) {
            setState(() {
              _enableDeliveryReceipts = value;
            });
          },
          activeColor: Colors.blue,
        ),
        SwitchListTile(
          title: Text(
            'Enable Logging',
            style: AppTextStyles.poppins(color: Colors.white),
          ),
          subtitle: Text(
            'Log SMPP protocol messages for debugging',
            style: AppTextStyles.poppins(color: Colors.grey[400]),
          ),
          value: _enableLogging,
          onChanged: (value) {
            setState(() {
              _enableLogging = value;
            });
          },
          activeColor: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveConfig,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: _isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Text(
                    'Save Configuration',
                    style: AppTextStyles.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : _testConnection,
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Test Connection',
              style: AppTextStyles.poppins(
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _saveConfig() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = SmppConfig(
        host: _hostController.text,
        port: int.parse(_portController.text),
        systemId: _systemIdController.text,
        password: _passwordController.text,
        systemType: _systemTypeController.text,
        enableDeliveryReceipts: _enableDeliveryReceipts,
        enableLogging: _enableLogging,
      );

      final provider = Provider.of<GatewayProvider>(context, listen: false);
      await provider.updateSmppConfig(config);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('SMPP configuration saved successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving configuration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final config = SmppConfig(
        host: _hostController.text,
        port: int.parse(_portController.text),
        systemId: _systemIdController.text,
        password: _passwordController.text,
        systemType: _systemTypeController.text,
        enableDeliveryReceipts: _enableDeliveryReceipts,
        enableLogging: _enableLogging,
      );

      final provider = Provider.of<GatewayProvider>(context, listen: false);
      await provider.updateSmppConfig(config);
      final success = await provider.connectSmpp();

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMPP connection test successful'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('SMPP connection test failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error testing connection: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _connectSmpp() async {
    try {
      final provider = Provider.of<GatewayProvider>(context, listen: false);
      await provider.connectSmpp();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error connecting to SMPP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _disconnectSmpp() async {
    try {
      final provider = Provider.of<GatewayProvider>(context, listen: false);
      await provider.disconnectSmpp();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error disconnecting from SMPP: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _hostController.dispose();
    _portController.dispose();
    _systemIdController.dispose();
    _passwordController.dispose();
    _systemTypeController.dispose();
    super.dispose();
  }
}
