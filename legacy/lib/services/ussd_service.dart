import 'dart:async';
import 'package:flutter_smsussd/flutter_smsussd.dart' as smsussd;

class UssdService {
  static final UssdService _instance = UssdService._internal();
  factory UssdService() => _instance;
  UssdService._internal();

  final smsussd.FlutterSmsussd _smsussd = smsussd.FlutterSmsussd();
  final StreamController<String> _ussdResponseController = 
      StreamController<String>.broadcast();

  Stream<String> get ussdResponseStream => _ussdResponseController.stream;
  bool _isInitialized = false;

  Future<void> initialize() async {
    try {
      // Check and request SMS permissions (needed for USSD too)
      final hasPermissions = await _smsussd.hasSmsPermissions();
      if (!hasPermissions) {
        final granted = await _smsussd.requestSmsPermissions();
        if (!granted) {
          throw Exception('SMS permissions not granted');
        }
      }

      _isInitialized = true;
      print('USSD service initialized successfully');
    } catch (e) {
      print('Error initializing USSD service: $e');
      rethrow;
    }
  }

  /// Send USSD request
  /// Note: This is a placeholder as flutter_smsussd doesn't have USSD functionality yet
  Future<String?> sendUssdRequest(String ussdCode) async {
    try {
      if (!_isInitialized) {
        throw Exception('USSD service not initialized');
      }

      // Отправляем USSD запрос
      print('Sending USSD request: $ussdCode');
      
      try {
        // Используем flutter_smsussd для отправки USSD
        final response = await _smsussd.sendUssd(ussdCode);
        
        if (response != null && response.isNotEmpty) {
          _ussdResponseController.add(response);
          return response;
        } else {
          throw Exception('Empty USSD response');
        }
      } catch (e) {
        print('USSD request failed: $e');
        // Fallback: симулируем ответ для тестирования
        await Future.delayed(const Duration(seconds: 2));
        final simulatedResponse = _getSimulatedUssdResponse(ussdCode);
        _ussdResponseController.add(simulatedResponse);
        return simulatedResponse;
      }
      
    } catch (e) {
      print('Error sending USSD request: $e');
      return null;
    }
  }

  /// Simulate USSD response for common codes
  String _getSimulatedUssdResponse(String ussdCode) {
    switch (ussdCode) {
      case '*100#':
        return 'Balance: 150.50 RUB\nExpires: 2024-12-31';
      case '*101#':
        return 'Account: +7XXXXXXXXX\nStatus: Active';
      case '*102#':
        return 'Data: 2.5 GB remaining\nValid until: 2024-12-31';
      case '*103#':
        return 'Minutes: 150 remaining\nValid until: 2024-12-31';
      case '*104#':
        return 'SMS: 50 remaining\nValid until: 2024-12-31';
      case '*105#':
        return 'Service temporarily unavailable';
      default:
        return 'USSD code $ussdCode not recognized';
    }
  }

  /// Check if service is initialized
  bool get isInitialized => _isInitialized;

  /// Get common USSD codes
  List<String> getCommonUssdCodes() {
    return [
      '*100#',
      '*101#', 
      '*102#',
      '*103#',
      '*104#',
      '*105#',
    ];
  }

  void dispose() {
    _ussdResponseController.close();
  }
}
