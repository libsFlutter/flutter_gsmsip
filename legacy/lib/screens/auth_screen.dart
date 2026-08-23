import 'package:flutter/material.dart';
import '../utils/text_styles.dart';
import '../models/gateway_config.dart';
import '../services/storage_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AuthScreen extends StatefulWidget {
  final Function(GatewayConfig) onAuthenticated;

  const AuthScreen({Key? key, required this.onAuthenticated}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _serverController = TextEditingController();
  final _portController = TextEditingController();
  
  bool _rememberCredentials = false;
  bool _isLoading = false;
  bool _isFirstRun = true;

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final storage = StorageService();
    final config = await storage.getConfig();
    final autoLogin = await storage.getAutoLogin();
    final isFirstRun = await storage.isFirstRun();

    setState(() {
      _isFirstRun = isFirstRun;
      if (config.sipUsername.isNotEmpty) {
        _usernameController.text = config.sipUsername;
        _passwordController.text = config.sipPassword;
        _serverController.text = config.sipServer;
        _portController.text = config.sipPort.toString();
      }
      _rememberCredentials = autoLogin;
    });

    // Auto-login if enabled and credentials are saved
    if (autoLogin && config.sipUsername.isNotEmpty && !_isFirstRun) {
      _authenticate();
    }
  }

  Future<void> _authenticate() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final config = GatewayConfig(
        sipUsername: _usernameController.text.trim(),
        sipPassword: _passwordController.text,
        sipServer: _serverController.text.trim(),
        sipPort: int.tryParse(_portController.text) ?? 5060,
        autoStart: false,
      );

      final storage = StorageService();
      await storage.saveConfig(config);
      await storage.saveAutoLogin(_rememberCredentials);
      
      if (_isFirstRun) {
        await storage.setFirstRunComplete();
      }

      widget.onAuthenticated(config);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Authentication failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                
                // Logo and Title
                Icon(
                  Icons.router,
                  size: 80,
                  color: Colors.blue[400],
                ),
                const SizedBox(height: 24),
                Text(
                  AppLocalizations.of(context)?.appTitle ?? 'GOSTsimbox Gateway',
                  style: AppTextStyles.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppLocalizations.of(context)?.configureSipCredentials ?? 'Configure your SIP credentials',
                  style: AppTextStyles.poppins(
                    fontSize: 16,
                    color: Colors.grey[400],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // SIP Username
                _buildTextField(
                  controller: _usernameController,
                  label: AppLocalizations.of(context)?.sipUsername ?? 'SIP Username',
                  icon: Icons.person,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterSipUsername ?? 'Please enter SIP username';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // SIP Password
                _buildTextField(
                  controller: _passwordController,
                  label: AppLocalizations.of(context)?.sipPassword ?? 'SIP Password',
                  icon: Icons.lock,
                  isPassword: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterSipPassword ?? 'Please enter SIP password';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // SIP Server
                _buildTextField(
                  controller: _serverController,
                  label: AppLocalizations.of(context)?.sipServer ?? 'SIP Server',
                  icon: Icons.dns,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterSipServer ?? 'Please enter SIP server';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // SIP Port
                _buildTextField(
                  controller: _portController,
                  label: AppLocalizations.of(context)?.sipPort ?? 'SIP Port',
                  icon: Icons.settings_ethernet,
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return AppLocalizations.of(context)?.pleaseEnterSipPort ?? 'Please enter SIP port';
                    }
                    final port = int.tryParse(value);
                    if (port == null || port < 1 || port > 65535) {
                      return AppLocalizations.of(context)?.pleaseEnterValidPort ?? 'Please enter a valid port number';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Remember Credentials
                Row(
                  children: [
                    Checkbox(
                      value: _rememberCredentials,
                      onChanged: (value) {
                        setState(() {
                          _rememberCredentials = value ?? false;
                        });
                      },
                      activeColor: Colors.blue[400],
                    ),
                    Expanded(
                      child: Text(
                        AppLocalizations.of(context)?.rememberCredentials ?? 'Remember credentials and auto-login',
                        style: AppTextStyles.poppins(
                          fontSize: 14,
                          color: Colors.grey[300],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Login Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          AppLocalizations.of(context)?.connect ?? 'Connect',
                          style: AppTextStyles.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      validator: validator,
      style: AppTextStyles.poppins(
        fontSize: 16,
        color: Colors.white,
      ),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: AppTextStyles.poppins(
          color: Colors.grey[400],
        ),
        prefixIcon: Icon(
          icon,
          color: Colors.grey[400],
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[600]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue[400]!),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!),
        ),
        filled: true,
        fillColor: const Color(0xFF2A2A2A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _serverController.dispose();
    _portController.dispose();
    super.dispose();
  }
} 