import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'services/gateway_service.dart';
import 'services/sip_service.dart';
import 'services/sms_service.dart';
import 'services/telephony_service.dart';
import 'screens/dashboard_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/setup_screen.dart';
import 'utils/funny_messages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Настройка ориентации экрана
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Настройка системного UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );
  
  runApp(const GOSTsimboxApp());
}

class GOSTsimboxApp extends StatelessWidget {
  const GOSTsimboxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<GatewayService>.value(value: GatewayService()),
        Provider<SipService>.value(value: SipService()),
        Provider<SmsService>.value(value: SmsService()),
        Provider<TelephonyService>.value(value: TelephonyService()),
      ],
      child: MaterialApp(
        title: 'GOSTsimbox Gateway',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1E88E5),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: true,
            elevation: 0,
            scrolledUnderElevation: 1,
          ),
          cardTheme: CardThemeData(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ),
        home: const SetupCheckScreen(),
      ),
    );
  }
}

/// Screen to check if setup is complete
class SetupCheckScreen extends StatefulWidget {
  const SetupCheckScreen({super.key});

  @override
  State<SetupCheckScreen> createState() => _SetupCheckScreenState();
}

class _SetupCheckScreenState extends State<SetupCheckScreen> {
  String _loadingMessage = 'Инициализация...';

  @override
  void initState() {
    super.initState();
    _startLoadingAnimation();
    _checkSetup();
  }

  void _startLoadingAnimation() {
    Timer.periodic(const Duration(milliseconds: 800), (timer) {
      if (mounted) {
        setState(() {
          _loadingMessage = FunnyMessages.getLoadingMessage();
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _checkSetup() async {
    final gatewayService = context.read<GatewayService>();
    final config = await gatewayService.loadConfiguration();
    
    // Add a small delay to show the splash effect
    await Future.delayed(const Duration(seconds: 1));
    
    if (mounted) {
      if (config != null) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const DashboardScreen()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SetupScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.router,
                size: 80,
                color: Colors.white,
              ),
              SizedBox(height: 24),
              Text(
                'GOSTsimbox Gateway',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Bridging GSM and SIP networks',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              SizedBox(height: 40),
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              SizedBox(height: 16),
              Text(
                _loadingMessage,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

