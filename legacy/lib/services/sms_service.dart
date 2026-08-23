import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:logger/logger.dart';
import '../models/smpp_config.dart';

/// SMS Message model
class SmsMessage {
  final String id;
  final String sender;
  final String recipient;
  final String content;
  final DateTime timestamp;
  final SmsMessageType type;
  final SmsMessageStatus status;

  const SmsMessage({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.content,
    required this.timestamp,
    required this.type,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'sender': sender,
    'recipient': recipient,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type.name,
    'status': status.name,
  };

  factory SmsMessage.fromJson(Map<String, dynamic> json) => SmsMessage(
    id: json['id'],
    sender: json['sender'],
    recipient: json['recipient'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    type: SmsMessageType.values.firstWhere((e) => e.name == json['type']),
    status: SmsMessageStatus.values.firstWhere((e) => e.name == json['status']),
  );
}

enum SmsMessageType { incoming, outgoing }
enum SmsMessageStatus { pending, sent, delivered, failed, received }

enum SmppConnectionState { 
  disconnected, 
  connecting, 
  bound, 
  error 
}

/// SMS Receiver for handling incoming SMS via Android broadcast
///
/// Task: sms-002 - Implement SMS receiver (broadcast receiver for incoming SMS)
class SmsReceiver {
  static const MethodChannel _channel = MethodChannel('flutter_smsussd');

  final Logger _logger = Logger();
  final StreamController<SmsMessage> _incomingSmsController =
      StreamController<SmsMessage>.broadcast();

  bool _isRegistered = false;

  /// Get stream of incoming SMS messages
  Stream<SmsMessage> get incomingSmsStream => _incomingSmsController.stream;

  /// Check if receiver is registered
  bool get isRegistered => _isRegistered;

  /// Register the SMS broadcast receiver
  ///
  /// This sets up native Android broadcast receiver for SMS_DELIVER broadcasts.
  /// Returns true if successfully registered.
  Future<bool> register() async {
    if (_isRegistered) {
      _logger.w('SmsReceiver already registered');
      return true;
    }

    try {
      _logger.i('SmsReceiver: Registering broadcast receiver...');

      // Request permissions first
      final hasPermissions = await hasPermissions();
      if (!hasPermissions) {
        _logger.w('SmsReceiver: SMS permissions not granted');
        return false;
      }

      // Register native broadcast receiver
      await _channel.invokeMethod<void>('registerSmsReceiver', {});
      _isRegistered = true;
      _logger.i('SmsReceiver: Broadcast receiver registered successfully');
      return true;
    } on PlatformException catch (e) {
      _logger.e('SmsReceiver: Failed to register', error: e);
      return false;
    } catch (e, stackTrace) {
      _logger.e('SmsReceiver: Error registering', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Unregister the SMS broadcast receiver
  Future<bool> unregister() async {
    if (!_isRegistered) {
      return true;
    }

    try {
      _logger.i('SmsReceiver: Unregistering broadcast receiver...');
      await _channel.invokeMethod<void>('unregisterSmsReceiver', {});
      _isRegistered = false;
      _logger.i('SmsReceiver: Broadcast receiver unregistered');
      return true;
    } on PlatformException catch (e) {
      _logger.e('SmsReceiver: Failed to unregister', error: e);
      return false;
    } catch (e, stackTrace) {
      _logger.e('SmsReceiver: Error unregistering', error: e, stackTrace: stackTrace);
      return false;
    }
  }

  /// Handle incoming SMS from native broadcast receiver
  ///
  /// Called by native code when SMS_DELIVER broadcast is received.
  void handleIncomingSms(Map<String, dynamic> smsData) {
    try {
      final message = SmsMessage(
        id: smsData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
        sender: smsData['sender'] ?? smsData['address'] ?? '',
        recipient: smsData['recipient'] ?? '',
        content: smsData['body'] ?? smsData['message'] ?? '',
        timestamp: smsData['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(smsData['timestamp'])
            : DateTime.now(),
        type: SmsMessageType.incoming,
        status: SmsMessageStatus.received,
      );

      _logger.i('SmsReceiver: Incoming SMS from ${message.sender}');
      _incomingSmsController.add(message);
    } catch (e, stackTrace) {
      _logger.e('SmsReceiver: Error handling incoming SMS', error: e, stackTrace: stackTrace);
    }
  }

  /// Check SMS permissions
  Future<bool> hasPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('hasSmsPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('SmsReceiver: Permission check failed', error: e);
      return false;
    }
  }

  /// Request SMS permissions
  Future<bool> requestPermissions() async {
    try {
      final result = await _channel.invokeMethod<bool>('requestSmsPermissions');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('SmsReceiver: Permission request failed', error: e);
      return false;
    }
  }

  /// Clean up resources
  void dispose() async {
    await unregister();
    await _incomingSmsController.close();
  }
}

/// SMS Service for handling SMS via SMPP and local SMS
///
/// Tasks:
/// - sms-001: Implement SmsService (SmsManager for sending SMS)
/// - sms-002: Implement SMS receiver (broadcast receiver for incoming SMS)
class SmsService {
  static final SmsService _instance = SmsService._internal();
  factory SmsService() => _instance;
  SmsService._internal();

  final Logger _logger = Logger();

  SmppConfig? _smppConfig;
  SmppConnectionState _smppConnectionState = SmppConnectionState.disconnected;
  final Map<String, SmsMessage> _messages = {};
  int _messageCounter = 0;

  // SMS Receiver for incoming SMS
  final SmsReceiver _smsReceiver = SmsReceiver();

  // Stream controllers
  final StreamController<SmppConnectionState> _connectionStateController =
      StreamController<SmppConnectionState>.broadcast();
  final StreamController<SmsMessage> _messageController =
      StreamController<SmsMessage>.broadcast();
  final StreamController<String> _logController =
      StreamController<String>.broadcast();

  // Getters
  SmppConnectionState get connectionState => _smppConnectionState;
  SmppConfig? get smppConfig => _smppConfig;
  List<SmsMessage> get messages => _messages.values.toList();
  SmsReceiver get smsReceiver => _smsReceiver;

  // Streams
  Stream<SmppConnectionState> get connectionStateStream =>
      _connectionStateController.stream;
  Stream<SmsMessage> get messageStream => _messageController.stream;
  Stream<String> get logStream => _logController.stream;

  /// Get stream of incoming SMS messages (from broadcast receiver)
  Stream<SmsMessage> get incomingSmsStream => _smsReceiver.incomingSmsStream;

  /// Initialize SMS service
  ///
  /// [enableReceiver] - If true, registers broadcast receiver for incoming SMS
  /// [smppConfig] - Optional SMPP configuration for SMPP-based SMS
  Future<bool> initialize({bool enableReceiver = false, SmppConfig? smppConfig}) async {
    try {
      _logger.i('SmsService: Initializing...');

      // Initialize SMS receiver if requested
      if (enableReceiver) {
        final receiverRegistered = await _smsReceiver.register();
        if (receiverRegistered) {
          // Listen for incoming SMS and add to message store
          _smsReceiver.incomingSmsStream.listen((message) {
            _messages[message.id] = message;
            _messageController.add(message);
            _log('Incoming SMS stored: ${message.id}');
          });
          _log('SMS receiver registered for incoming SMS broadcasts');
        }
      }

      // Initialize SMPP if configured
      if (smppConfig != null) {
        await initializeSmpp(smppConfig);
      }

      _logger.i('SmsService: Initialization complete');
      return true;
    } catch (e, stackTrace) {
      _logger.e('SmsService: Initialization failed', error: e, stackTrace: stackTrace);
      _log('Initialization failed: $e');
      return false;
    }
  }

  /// Initialize SMS service with SMPP configuration
  Future<bool> initializeSmpp(SmppConfig config) async {
    try {
      _smppConfig = config;
      _log('Initializing SMPP connection to ${config.host}:${config.port}');
      
      _updateConnectionState(SmppConnectionState.connecting);
      await Future.delayed(const Duration(seconds: 2));
      
      // Simulate SMPP bind operation
      _updateConnectionState(SmppConnectionState.bound);
      _log('SMPP connection established and bound');
      return true;
    } catch (e) {
      _log('Failed to initialize SMPP: $e');
      _updateConnectionState(SmppConnectionState.error);
      return false;
    }
  }

  /// Connect to SMPP server
  Future<bool> connectSmpp() async {
    if (_smppConfig == null) {
      _log('No SMPP configuration available');
      return false;
    }

    try {
      _log('Connecting to SMPP server...');
      _updateConnectionState(SmppConnectionState.connecting);
      
      // Simulate connection process
      await Future.delayed(const Duration(seconds: 1));
      
      _updateConnectionState(SmppConnectionState.bound);
      _log('Successfully connected to SMPP server');
      return true;
    } catch (e) {
      _log('SMPP connection failed: $e');
      _updateConnectionState(SmppConnectionState.error);
      return false;
    }
  }

  /// Disconnect from SMPP server
  Future<void> disconnectSmpp() async {
    try {
      _log('Disconnecting from SMPP server...');
      _updateConnectionState(SmppConnectionState.disconnected);
      _log('Disconnected from SMPP server');
    } catch (e) {
      _log('SMPP disconnection failed: $e');
    }
  }

  /// Send SMS via SMPP
  Future<String?> sendSmsViaSmpp(String recipient, String content) async {
    if (_smppConnectionState != SmppConnectionState.bound) {
      _log('Cannot send SMS: SMPP not connected');
      return null;
    }

    try {
      final messageId = 'smpp_${++_messageCounter}_${DateTime.now().millisecondsSinceEpoch}';
      _log('Sending SMS via SMPP to $recipient (ID: $messageId)');
      
      final message = SmsMessage(
        id: messageId,
        sender: _smppConfig?.systemId ?? 'SMPP',
        recipient: recipient,
        content: content,
        timestamp: DateTime.now(),
        type: SmsMessageType.outgoing,
        status: SmsMessageStatus.pending,
      );
      
      _messages[messageId] = message;
      _messageController.add(message);
      
      // Simulate message delivery
      _simulateMessageDelivery(messageId);
      
      return messageId;
    } catch (e) {
      _log('Failed to send SMS via SMPP: $e');
      return null;
    }
  }

  /// Send SMS via local Android SMS
  Future<String?> sendSmsLocal(String recipient, String content) async {
    try {
      final messageId = 'local_${++_messageCounter}_${DateTime.now().millisecondsSinceEpoch}';
      _log('Sending SMS locally to $recipient (ID: $messageId)');
      
      final message = SmsMessage(
        id: messageId,
        sender: 'Local',
        recipient: recipient,
        content: content,
        timestamp: DateTime.now(),
        type: SmsMessageType.outgoing,
        status: SmsMessageStatus.pending,
      );
      
      _messages[messageId] = message;
      _messageController.add(message);
      
      // Simulate local SMS sending
      Timer(const Duration(seconds: 1), () {
        _updateMessageStatus(messageId, SmsMessageStatus.sent);
        Timer(const Duration(seconds: 2), () {
          _updateMessageStatus(messageId, SmsMessageStatus.delivered);
        });
      });
      
      return messageId;
    } catch (e) {
      _log('Failed to send local SMS: $e');
      return null;
    }
  }

  /// Receive SMS (simulate incoming SMS)
  void simulateIncomingSms(String sender, String content) {
    final messageId = 'incoming_${++_messageCounter}_${DateTime.now().millisecondsSinceEpoch}';
    _log('Received SMS from $sender (ID: $messageId)');
    
    final message = SmsMessage(
      id: messageId,
      sender: sender,
      recipient: 'Local',
      content: content,
      timestamp: DateTime.now(),
      type: SmsMessageType.incoming,
      status: SmsMessageStatus.received,
    );
    
    _messages[messageId] = message;
    _messageController.add(message);
  }

  /// Get message history
  List<SmsMessage> getMessageHistory({
    String? sender,
    String? recipient,
    SmsMessageType? type,
    DateTime? fromDate,
    DateTime? toDate,
  }) {
    return _messages.values.where((message) {
      if (sender != null && message.sender != sender) return false;
      if (recipient != null && message.recipient != recipient) return false;
      if (type != null && message.type != type) return false;
      if (fromDate != null && message.timestamp.isBefore(fromDate)) return false;
      if (toDate != null && message.timestamp.isAfter(toDate)) return false;
      return true;
    }).toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  /// Get message by ID
  SmsMessage? getMessage(String messageId) {
    return _messages[messageId];
  }

  /// Delete message
  bool deleteMessage(String messageId) {
    return _messages.remove(messageId) != null;
  }

  /// Clear all messages
  void clearMessages() {
    _messages.clear();
    _log('Cleared all messages');
  }

  /// Get message statistics
  Map<String, int> getMessageStats() {
    final stats = <String, int>{
      'total': _messages.length,
      'incoming': 0,
      'outgoing': 0,
      'sent': 0,
      'delivered': 0,
      'failed': 0,
    };

    for (final message in _messages.values) {
      stats[message.type.name] = (stats[message.type.name] ?? 0) + 1;
      stats[message.status.name] = (stats[message.status.name] ?? 0) + 1;
    }

    return stats;
  }

  /// Simulate message delivery for SMPP messages
  void _simulateMessageDelivery(String messageId) {
    Timer(const Duration(seconds: 1), () {
      _updateMessageStatus(messageId, SmsMessageStatus.sent);
      
      Timer(const Duration(seconds: 3), () {
        // 95% delivery success rate
        final delivered = DateTime.now().millisecond % 100 < 95;
        _updateMessageStatus(
          messageId, 
          delivered ? SmsMessageStatus.delivered : SmsMessageStatus.failed
        );
      });
    });
  }

  /// Update message status
  void _updateMessageStatus(String messageId, SmsMessageStatus status) {
    final message = _messages[messageId];
    if (message != null) {
      final updatedMessage = SmsMessage(
        id: message.id,
        sender: message.sender,
        recipient: message.recipient,
        content: message.content,
        timestamp: message.timestamp,
        type: message.type,
        status: status,
      );
      
      _messages[messageId] = updatedMessage;
      _messageController.add(updatedMessage);
      _log('Message $messageId status updated to ${status.name}');
    }
  }

  void _updateConnectionState(SmppConnectionState state) {
    _smppConnectionState = state;
    _connectionStateController.add(state);
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] SMS: $message';
    _logger.i(logMessage);
    _logController.add(logMessage);
  }

  /// Clean up resources
  void dispose() {
    _logger.i('SmsService: Disposing...');
    _smsReceiver.dispose();
    _connectionStateController.close();
    _messageController.close();
    _logController.close();
    _messages.clear();
  }
}