import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/gateway_service.dart';
import '../services/sip_service.dart';
import '../services/sms_service.dart';
import '../utils/funny_messages.dart';
import '../utils/easter_eggs.dart';
import 'dashboard_screen.dart';

class SetupScreen extends StatefulWidget {
  const SetupScreen({super.key});

  @override
  State<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends State<SetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _pageController = PageController();
  int _currentPage = 0;
  
  // SIP Configuration
  final _sipUsernameController = TextEditingController();
  final _sipPasswordController = TextEditingController();
  final _sipDomainController = TextEditingController();
  final _sipProxyController = TextEditingController();
  final _sipPortController = TextEditingController(text: '5060');
  bool _sipUseSecure = false;
  
  // SMPP Configuration (optional)
  final _smppHostController = TextEditingController();
  final _smppPortController = TextEditingController(text: '2775');
  final _smppSystemIdController = TextEditingController();
  final _smppPasswordController = TextEditingController();
  bool _enableSmpp = false;
  
  // Gateway Settings
  bool _autoAnswer = false;
  bool _enableLogging = true;
  bool _routeSipToGsm = true;
  bool _routeGsmToSip = true;
  bool _routeSmsToSmpp = false;
  bool _routeSmppToSms = false;
  
  bool _isLoading = false;

  @override
  void dispose() {
    _sipUsernameController.dispose();
    _sipPasswordController.dispose();
    _sipDomainController.dispose();
    _sipProxyController.dispose();
    _sipPortController.dispose();
    _smppHostController.dispose();
    _smppPortController.dispose();
    _smppSystemIdController.dispose();
    _smppPasswordController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройка шлюза ⚙️'),
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          // Progress indicator
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                for (int i = 0; i < 3; i++)
                  Expanded(
                    child: Container(
                      height: 4,
                      margin: EdgeInsets.only(right: i < 2 ? 8 : 0),
                      decoration: BoxDecoration(
                        color: i <= _currentPage 
                            ? Theme.of(context).colorScheme.primary
                            : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          // Page content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              children: [
                _buildSipConfigPage(),
                _buildSmppConfigPage(),
                _buildGatewaySettingsPage(),
              ],
            ),
          ),
          
          // Navigation buttons
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text('Back'),
                  )
                else
                  const SizedBox(),
                
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleNextOrFinish,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_currentPage < 2 ? 'Next' : 'Finish'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSipConfigPage() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SIP Configuration',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Configure your SIP account settings to connect to the VoIP server.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb, color: Colors.amber.shade600, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '💡 Совет: Если не знаете настройки, спросите у системного администратора или у кота 🐱',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            TextFormField(
              controller: _sipUsernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                hintText: 'Введите имя пользователя (не "admin" 😄)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                helperText: '💡 Обычно это ваш номер телефона или логин',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Username is required';
                }
                
                // Проверяем на пасхалки
                final easterEggResponse = EasterEggs.checkSecretCommand(value);
                if (easterEggResponse != null) {
                  // Показываем пасхалку, но не блокируем валидацию
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _showEasterEggDialog(easterEggResponse);
                  });
                }
                
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _sipPasswordController,
              decoration: const InputDecoration(
                labelText: 'Password',
                hintText: 'Введите пароль (не "123456" 😅)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                helperText: '🔒 Пароль должен быть сложнее "password"',
              ),
              obscureText: true,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _sipDomainController,
              decoration: const InputDecoration(
                labelText: 'Domain/Server',
                hintText: 'sip.example.com (или IP адрес)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
                helperText: '🌐 Адрес сервера, куда будем подключаться',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Domain is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _sipProxyController,
                    decoration: const InputDecoration(
                      labelText: 'Proxy (Optional)',
                      hintText: 'proxy.example.com',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.router),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _sipPortController,
                    decoration: const InputDecoration(
                      labelText: 'Port',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Port required';
                      }
                      final port = int.tryParse(value);
                      if (port == null || port <= 0 || port > 65535) {
                        return 'Invalid port';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            SwitchListTile(
              title: const Text('Use Secure Connection (TLS)'),
              subtitle: const Text('Enable for encrypted SIP communication'),
              value: _sipUseSecure,
              onChanged: (value) {
                setState(() {
                  _sipUseSecure = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSmppConfigPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'SMS Configuration',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure SMPP settings for SMS routing (optional).',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          
          SwitchListTile(
            title: const Text('Enable SMPP'),
            subtitle: const Text('Route SMS messages via SMPP protocol'),
            value: _enableSmpp,
            onChanged: (value) {
              setState(() {
                _enableSmpp = value;
              });
            },
          ),
          const SizedBox(height: 16),
          
          if (_enableSmpp) ...[
            TextFormField(
              controller: _smppHostController,
              decoration: const InputDecoration(
                labelText: 'SMPP Host',
                hintText: 'smpp.example.com',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.dns),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _smppPortController,
              decoration: const InputDecoration(
                labelText: 'SMPP Port',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.settings_ethernet),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _smppSystemIdController,
              decoration: const InputDecoration(
                labelText: 'System ID',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.account_circle),
              ),
            ),
            const SizedBox(height: 16),
            
            TextFormField(
              controller: _smppPasswordController,
              decoration: const InputDecoration(
                labelText: 'SMPP Password',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
              ),
              obscureText: true,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildGatewaySettingsPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gateway Settings',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'Configure gateway behavior and routing options.',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.settings, color: Colors.green.shade600, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '⚙️ Здесь настраиваем магию шлюза! Выберите, что должно работать 🪄',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.green.shade700,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Auto Answer Calls'),
                  subtitle: const Text('Автоматически отвечать на входящие звонки 🤖'),
                  value: _autoAnswer,
                  onChanged: (value) {
                    setState(() {
                      _autoAnswer = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Enable Logging'),
                  subtitle: const Text('Записывать все действия шлюза 📝'),
                  value: _enableLogging,
                  onChanged: (value) {
                    setState(() {
                      _enableLogging = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Call Routing'),
                  subtitle: Text('Настройка маршрутизации звонков 🛣️'),
                ),
                SwitchListTile(
                  title: const Text('Route SIP to GSM'),
                  subtitle: const Text('Перенаправлять SIP звонки на GSM 📞➡️📱'),
                  value: _routeSipToGsm,
                  onChanged: (value) {
                    setState(() {
                      _routeSipToGsm = value;
                    });
                  },
                ),
                SwitchListTile(
                  title: const Text('Route GSM to SIP'),
                  subtitle: const Text('Перенаправлять GSM звонки на SIP 📱➡️📞'),
                  value: _routeGsmToSip,
                  onChanged: (value) {
                    setState(() {
                      _routeGsmToSip = value;
                    });
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          if (_enableSmpp)
            Card(
              child: Column(
                children: [
                  const ListTile(
                    title: Text('SMS Routing'),
                    subtitle: Text('Configure SMS routing behavior'),
                  ),
                  SwitchListTile(
                    title: const Text('Route SMS to SMPP'),
                    subtitle: const Text('Forward local SMS to SMPP'),
                    value: _routeSmsToSmpp,
                    onChanged: (value) {
                      setState(() {
                        _routeSmsToSmpp = value;
                      });
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Route SMPP to SMS'),
                    subtitle: const Text('Forward SMPP messages to local SMS'),
                    value: _routeSmppToSms,
                    onChanged: (value) {
                      setState(() {
                        _routeSmppToSms = value;
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _handleNextOrFinish() async {
    if (_currentPage < 2) {
      if (_currentPage == 0 && !_formKey.currentState!.validate()) {
        return;
      }
      
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      await _finishSetup();
    }
  }

  Future<void> _finishSetup() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final gatewayService = context.read<GatewayService>();
      
      // Create SIP account
      final sipAccount = SipAccount(
        username: _sipUsernameController.text,
        password: _sipPasswordController.text,
        domain: _sipDomainController.text,
        proxy: _sipProxyController.text.isNotEmpty ? _sipProxyController.text : null,
        port: int.parse(_sipPortController.text),
        useSecure: _sipUseSecure,
      );
      
      // Create SMPP config if enabled
      SmppConfig? smppConfig;
      if (_enableSmpp) {
        smppConfig = SmppConfig(
          host: _smppHostController.text,
          port: int.parse(_smppPortController.text),
          systemId: _smppSystemIdController.text,
          password: _smppPasswordController.text,
        );
      }
      
      // Create gateway configuration
      final config = GatewayConfig(
        sipAccount: sipAccount,
        smppConfig: smppConfig,
        autoAnswer: _autoAnswer,
        enableLogging: _enableLogging,
        routeSipToGsm: _routeSipToGsm,
        routeGsmToSip: _routeGsmToSip,
        routeSmsToSmpp: _routeSmsToSmpp,
        routeSmppToSms: _routeSmppToSms,
      );
      
      // Initialize gateway
      final success = await gatewayService.initialize(config);
      
      if (success && mounted) {
        _showSuccessDialog();
      } else {
        _showErrorDialog('${FunnyMessages.getSetupError()}\n\nПроверьте настройки и попробуйте снова.');
      }
    } catch (e) {
      _showErrorDialog('${FunnyMessages.getSetupError()}\n\nОшибка: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            const SizedBox(width: 8),
            const Text('Успех!'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              FunnyMessages.getSuccessMessage(),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            const Text(
              'Шлюз готов к работе! 🚀',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const DashboardScreen()),
              );
            },
            child: const Text('Поехали! 🎉'),
          ),
        ],
      ),
    );
  }

  void _showEasterEggDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.amber, size: 28),
            const SizedBox(width: 8),
            const Text('Пасхалка! 🥚'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Text(
              EasterEggs.getMotivationalQuote(),
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.white,
            ),
            child: const Text('Круто! 🎉'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            const SizedBox(width: 8),
            const Text('Ой-ой!'),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Понятно 😅'),
          ),
        ],
      ),
    );
  }
}
