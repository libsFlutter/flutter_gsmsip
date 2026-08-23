import 'dart:async';
import 'package:flutter_smsussd/flutter_smsussd.dart' as smsussd;
import '../models/sms_message.dart';
import '../models/smpp_config.dart';
import 'smpp_service.dart';

class SmsServiceSmpp {
  static final SmsServiceSmpp _instance = SmsServiceSmpp._internal();
  factory SmsServiceSmpp() => _instance;
  SmsServiceSmpp._internal();

  final smsussd.FlutterSmsussd _smsussd = smsussd.FlutterSmsussd();
  final SmppService _smppService = SmppService();
  
  final StreamController<List<SmsMessage>> _messagesController = 
      StreamController<List<SmsMessage>>.broadcast();
  final StreamController<SmsMessage> _newMessageController = 
      StreamController<SmsMessage>.broadcast();

  Stream<List<SmsMessage>> get messagesStream => _messagesController.stream;
  Stream<SmsMessage> get newMessageStream => _newMessageController.stream;

  List<SmsMessage> _messages = [];
  bool _isInitialized = false;
  bool _useSmpp = false;
  SmppConfig? _smppConfig;

  StreamSubscription<SmppMessage>? _smppMessageSubscription;
  StreamSubscription<SmppConnectionState>? _smppConnectionSubscription;

  Future<void> initialize({SmppConfig? smppConfig}) async {
    try {
      _smppConfig = smppConfig;
      _useSmpp = smppConfig != null;

      // Initialize local SMS functionality
      final hasPermissions = await _smsussd.hasSmsPermissions();
      if (!hasPermissions) {
        final granted = await _smsussd.requestSmsPermissions();
        if (!granted) {
          throw Exception('SMS permissions not granted');
        }
      }

      // Initialize SMPP if configured
      if (_useSmpp && _smppConfig != null) {
        await _smppService.initialize(_smppConfig!);
        await _setupSmppListeners();
        await _smppService.connect();
      }

      // Load existing messages
      await loadMessages();
      
      _isInitialized = true;
      print('SMS Service (SMPP) initialized successfully. SMPP: $_useSmpp');
    } catch (e) {
      print('Error initializing SMS service: $e');
      rethrow;
    }
  }

  Future<void> _setupSmppListeners() async {
    // Listen for incoming SMPP messages
    _smppMessageSubscription = _smppService.incomingMessageStream.listen((smppMessage) {
      final smsMessage = SmsMessage(
        id: smppMessage.id,
        address: smppMessage.sourceAddress,
        body: smppMessage.message,
        timestamp: smppMessage.timestamp,
        type: SmsType.inbox,
        status: _convertSmppStatus(smppMessage.status),
        isRead: false,
      );

      _messages.insert(0, smsMessage);
      _messagesController.add(_messages);
      _newMessageController.add(smsMessage);
    });

    // Listen for SMPP connection state changes
    _smppConnectionSubscription = _smppService.connectionStateStream.listen((state) {
      print('SMPP connection state changed: $state');
    });
  }

  SmsStatus _convertSmppStatus(SmppMessageStatus smppStatus) {
    switch (smppStatus) {
      case SmppMessageStatus.pending:
        return SmsStatus.pending;
      case SmppMessageStatus.sent:
        return SmsStatus.sent;
      case SmppMessageStatus.delivered:
        return SmsStatus.delivered;
      case SmppMessageStatus.failed:
        return SmsStatus.failed;
      case SmppMessageStatus.expired:
        return SmsStatus.failed;
      case SmppMessageStatus.rejected:
        return SmsStatus.failed;
      case SmppMessageStatus.unknown:
        return SmsStatus.pending;
    }
  }

  Future<void> loadMessages() async {
    try {
      List<SmsMessage> messages = [];

      // Load local SMS messages
      final localMessages = await _smsussd.getSmsMessages();
      messages.addAll(localMessages.map((msg) => SmsMessage.fromSmsussd(msg)));

      // Load SMPP messages if available
      if (_useSmpp && _smppService.isConnected) {
        final smppMessages = await _smppService.getMessageHistory();
        messages.addAll(smppMessages.map((smppMsg) => SmsMessage(
          id: smppMsg.id,
          address: smppMsg.sourceAddress,
          body: smppMsg.message,
          timestamp: smppMsg.timestamp,
          type: SmsType.inbox,
          status: _convertSmppStatus(smppMsg.status),
          isRead: true,
        )));
      }

      // Sort by timestamp (newest first)
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      _messages = messages;
      _messagesController.add(_messages);
    } catch (e) {
      print('Error loading SMS messages: $e');
      rethrow;
    }
  }

  Future<bool> sendSms(String number, String message) async {
    try {
      if (!_isInitialized) {
        throw Exception('SMS service not initialized');
      }

      bool success = false;

      // Try SMPP first if available
      if (_useSmpp && _smppService.isConnected) {
        success = await _smppService.sendSms(number, message);
        if (success) {
          print('SMS sent via SMPP to $number');
        } else {
          print('SMPP SMS sending failed, trying local SMS');
        }
      }

      // Fallback to local SMS if SMPP failed or not available
      if (!success) {
        success = await _smsussd.sendSms(
          phoneNumber: number,
          message: message,
        );
        if (success) {
          print('SMS sent via local SMS to $number');
        }
      }

      if (success) {
        // Create a new SMS message for the sent message
        final sentMessage = SmsMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          address: number,
          body: message,
          timestamp: DateTime.now(),
          type: SmsType.sent,
          status: SmsStatus.sent,
        );

        _messages.insert(0, sentMessage);
        _messagesController.add(_messages);
        _newMessageController.add(sentMessage);
      }

      return success;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  Future<bool> deleteSms(String messageId) async {
    try {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        _messages.removeAt(index);
        _messagesController.add(_messages);
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting SMS: $e');
      return false;
    }
  }

  Future<bool> markAsRead(String messageId) async {
    try {
      final index = _messages.indexWhere((msg) => msg.id == messageId);
      if (index != -1) {
        final message = _messages[index];
        final updatedMessage = message.copyWith(isRead: true);
        _messages[index] = updatedMessage;
        _messagesController.add(_messages);
        return true;
      }
      return false;
    } catch (e) {
      print('Error marking SMS as read: $e');
      return false;
    }
  }

  Future<List<SmsMessage>> getMessagesByType(SmsType type) async {
    return _messages.where((msg) => msg.type == type).toList();
  }

  Future<List<SmsMessage>> getMessagesByNumber(String number) async {
    try {
      List<SmsMessage> messages = [];

      // Get local messages
      final localMessages = await _smsussd.getSmsMessagesByPhoneNumber(number);
      messages.addAll(localMessages.map((msg) => SmsMessage.fromSmsussd(msg)));

      // Get SMPP messages if available
      if (_useSmpp && _smppService.isConnected) {
        // This would require additional SMPP service method
        // For now, filter from loaded messages
        messages.addAll(_messages.where((msg) => msg.address == number));
      }

      return messages;
    } catch (e) {
      print('Error getting messages by number: $e');
      return _messages.where((msg) => msg.address == number).toList();
    }
  }

  Future<List<SmsMessage>> searchMessages(String query) async {
    return _messages.where((msg) => 
      msg.address.toLowerCase().contains(query.toLowerCase()) || 
      msg.body.toLowerCase().contains(query.toLowerCase())
    ).toList();
  }

  Future<Map<String, int>> getMessageCounts() async {
    final counts = <String, int>{};
    for (final msg in _messages) {
      counts[msg.type.name] = (counts[msg.type.name] ?? 0) + 1;
    }
    return counts;
  }

  Future<void> refreshMessages() async {
    await loadMessages();
  }

  Future<bool> hasPermissions() async {
    return await _smsussd.hasSmsPermissions();
  }

  Future<bool> requestPermissions() async {
    return await _smsussd.requestSmsPermissions();
  }

  // SMPP specific methods
  bool get isSmppEnabled => _useSmpp;
  bool get isSmppConnected => _smppService.isConnected;
  SmppConnectionState get smppConnectionState => _smppService.connectionState;

  Future<bool> connectSmpp() async {
    if (!_useSmpp || _smppConfig == null) {
      return false;
    }
    return await _smppService.connect();
  }

  Future<void> disconnectSmpp() async {
    if (_useSmpp) {
      await _smppService.disconnect();
    }
  }

  Future<bool> testConnection() async {
    if (!_useSmpp || _smppConfig == null) {
      return false;
    }
    
    try {
      // Try to connect temporarily
      final wasConnected = _smppService.isConnected;
      if (!wasConnected) {
        final success = await _smppService.connect();
        if (success) {
          await _smppService.disconnect();
        }
        return success;
      }
      return true;
    } catch (e) {
      print('SMPP connection test failed: $e');
      return false;
    }
  }

  Stream<SmppConnectionState> get smppConnectionStateStream => _smppService.connectionStateStream;
  Stream<String> get smppLogStream => _smppService.logStream;

  Future<void> updateSmppConfig(SmppConfig config) async {
    _smppConfig = config;
    _useSmpp = true;
    
    if (_isInitialized) {
      await disconnectSmpp();
      await _smppService.initialize(config);
      await _setupSmppListeners();
      await _smppService.connect();
    }
  }

  void disableSmpp() {
    _useSmpp = false;
    disconnectSmpp();
  }

  void dispose() {
    _messagesController.close();
    _newMessageController.close();
    _smppMessageSubscription?.cancel();
    _smppConnectionSubscription?.cancel();
    _smppService.dispose();
  }
}
