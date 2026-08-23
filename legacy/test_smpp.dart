import 'dart:io';
import 'dart:convert';
import 'lib/models/smpp_config.dart';
import 'lib/services/smpp_service.dart';

void main() async {
  print('=== SMPP SMS Test ===');
  
  // Load configuration from file
  SmppConfig config;
  String testNumber;
  String testMessage;
  
  try {
    final configFile = File('smpp_config.json');
    if (await configFile.exists()) {
      final configJson = jsonDecode(await configFile.readAsString());
      config = SmppConfig(
        host: configJson['host'] ?? 'localhost',
        port: configJson['port'] ?? 2775,
        systemId: configJson['systemId'] ?? 'test',
        password: configJson['password'] ?? 'test',
        systemType: configJson['systemType'] ?? '',
        enableLogging: true,
      );
      testNumber = configJson['testNumber'] ?? '+1234567890';
      testMessage = configJson['testMessage'] ?? 'Test SMS';
    } else {
      // Default configuration
      config = SmppConfig(
        host: 'localhost',
        port: 2775,
        systemId: 'test',
        password: 'test',
        systemType: '',
        enableLogging: true,
      );
      testNumber = '+1234567890';
      testMessage = 'Test SMS from SMPP Gateway';
    }
  } catch (e) {
    print('⚠️  Error loading config: $e');
    print('Using default configuration...');
    config = SmppConfig(
      host: 'localhost',
      port: 2775,
      systemId: 'test',
      password: 'test',
      systemType: '',
      enableLogging: true,
    );
    testNumber = '+1234567890';
    testMessage = 'Test SMS from SMPP Gateway';
  }
  
  print('SMPP Config: ${config.host}:${config.port}');
  print('System ID: ${config.systemId}');
  
  final smppService = SmppService();
  
  try {
    // Initialize SMPP service
    print('\n1. Initializing SMPP service...');
    await smppService.initialize(config);
    
    // Connect to SMPP server
    print('2. Connecting to SMPP server...');
    final connected = await smppService.connect();
    
    if (!connected) {
      print('❌ Failed to connect to SMPP server');
      exit(1);
    }
    
    print('✅ Connected to SMPP server');
    
    // Wait a bit for the connection to stabilize
    await Future.delayed(Duration(seconds: 2));
    
    if (!smppService.isConnected) {
      print('❌ SMPP service is not in bound state');
      exit(1);
    }
    
    print('✅ SMPP service is bound and ready');
    
    // Send test SMS
    print('\n3. Sending test SMS...');
    final finalMessage = '$testMessage - ${DateTime.now()}';
    
    print('To: $testNumber');
    print('Message: $finalMessage');
    
    final success = await smppService.sendSms(testNumber, finalMessage);
    
    if (success) {
      print('✅ SMS sent successfully!');
    } else {
      print('❌ Failed to send SMS');
    }
    
    // Wait a bit to see any delivery receipts
    print('\n4. Waiting for delivery receipts...');
    await Future.delayed(Duration(seconds: 5));
    
  } catch (e) {
    print('❌ Error during SMPP test: $e');
  } finally {
    // Disconnect
    print('\n5. Disconnecting...');
    await smppService.disconnect();
    print('✅ Disconnected from SMPP server');
  }
  
  print('\n=== Test Complete ===');
}
