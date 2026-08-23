import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import '../models/smpp_config.dart';
import 'smpp_logger.dart';

class SmppService {
  static final SmppService _instance = SmppService._internal();
  factory SmppService() => _instance;
  SmppService._internal();

  Socket? _socket;
  SmppConfig? _config;
  SmppConnectionState _connectionState = SmppConnectionState.disconnected;
  final SmppLogger _logger = SmppLogger();
  
  final StreamController<SmppConnectionState> _connectionStateController = 
      StreamController<SmppConnectionState>.broadcast();
  final StreamController<SmppMessage> _incomingMessageController = 
      StreamController<SmppMessage>.broadcast();
  final StreamController<SmppDeliveryReceipt> _deliveryReceiptController = 
      StreamController<SmppDeliveryReceipt>.broadcast();
  final StreamController<String> _logController = 
      StreamController<String>.broadcast();

  Stream<SmppConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<SmppMessage> get incomingMessageStream => _incomingMessageController.stream;
  Stream<SmppDeliveryReceipt> get deliveryReceiptStream => _deliveryReceiptController.stream;
  Stream<String> get logStream => _logController.stream;

  SmppConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == SmppConnectionState.bound;
  bool get isConnecting => _connectionState == SmppConnectionState.connecting;

  int _sequenceNumber = 1;
  final Map<int, Completer<SmppMessage>> _pendingRequests = {};
  Timer? _keepAliveTimer;
  Timer? _reconnectTimer;

  Future<void> initialize(SmppConfig config) async {
    _config = config;
    if (config.enableLogging) {
      _logger.setLogLevel(SmppLogLevel.debug);
    } else {
      _logger.setLogLevel(SmppLogLevel.error);
    }
    _logger.info('SMPP Service initialized with config: ${config.host}:${config.port}');
  }

  Future<bool> connect() async {
    if (_config == null) {
      _logger.error('SMPP config not initialized');
      return false;
    }

    if (_connectionState == SmppConnectionState.connecting) {
      _logger.warning('Already connecting...');
      return false;
    }

    _updateConnectionState(SmppConnectionState.connecting);

    try {
      _logger.info('Connecting to SMPP server: ${_config!.host}:${_config!.port}');
      
      _socket = await Socket.connect(_config!.host, _config!.port, 
          timeout: Duration(milliseconds: _config!.requestTimeout));
      
      _socket!.listen(
        _handleData,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _updateConnectionState(SmppConnectionState.connected);
      _logger.info('Connected to SMPP server');

      // Send bind request
      await _sendBindRequest();
      
      return true;
    } catch (e) {
      _logger.error('Error connecting to SMPP server: $e');
      _updateConnectionState(SmppConnectionState.error);
      _scheduleReconnect();
      return false;
    }
  }

  Future<void> disconnect() async {
    _log('Disconnecting from SMPP server...');
    
    _keepAliveTimer?.cancel();
    _reconnectTimer?.cancel();
    
    if (_socket != null) {
      await _sendUnbindRequest();
      await _socket!.close();
      _socket = null;
    }
    
    _updateConnectionState(SmppConnectionState.disconnected);
    _log('Disconnected from SMPP server');
  }

  Future<bool> sendSms(String destinationAddress, String message, {String? sourceAddress}) async {
    if (!isConnected) {
      _log('Error: Not connected to SMPP server');
      return false;
    }

    try {
      final smppMessage = SmppMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceAddress: sourceAddress ?? _config!.systemId,
        destinationAddress: destinationAddress,
        message: message,
        timestamp: DateTime.now(),
        status: SmppMessageStatus.pending,
        sequenceNumber: _getNextSequenceNumber(),
      );

      _log('Sending SMS to $destinationAddress: ${message.length} characters');
      
      final completer = Completer<SmppMessage>();
      _pendingRequests[smppMessage.sequenceNumber!] = completer;
      
      await _sendSubmitSmRequest(smppMessage);
      
      // Wait for response
      final response = await completer.future.timeout(
        Duration(milliseconds: _config!.requestTimeout),
        onTimeout: () {
          _pendingRequests.remove(smppMessage.sequenceNumber);
          throw TimeoutException('SMPP request timeout', Duration(milliseconds: _config!.requestTimeout));
        },
      );

      _log('SMS sent successfully. Message ID: ${response.id}');
      return response.status == SmppMessageStatus.sent;
    } catch (e) {
      _log('Error sending SMS: $e');
      return false;
    }
  }

  Future<List<SmppMessage>> getMessageHistory({int limit = 100}) async {
    // This would typically query a database
    // For now, return empty list
    return [];
  }

  Future<void> _sendBindRequest() async {
    if (_socket == null) return;

    final bindRequest = _createBindRequest();
    _socket!.add(bindRequest);
    
    _log('Sent bind request');
  }

  Future<void> _sendUnbindRequest() async {
    if (_socket == null) return;

    final unbindRequest = _createUnbindRequest();
    _socket!.add(unbindRequest);
    
    _log('Sent unbind request');
  }

  Future<void> _sendSubmitSmRequest(SmppMessage message) async {
    if (_socket == null) return;

    final submitSmRequest = _createSubmitSmRequest(message);
    _socket!.add(submitSmRequest);
  }

  Uint8List _createBindRequest() {
    // Simplified SMPP bind_transceiver request
    final commandLength = 23 + _config!.systemId.length + _config!.password.length + _config!.systemType.length;
    final buffer = ByteData(commandLength + 4);
    
    int offset = 0;
    
    // Command length
    buffer.setUint32(offset, commandLength, Endian.big);
    offset += 4;
    
    // Command ID (bind_transceiver = 0x00000009)
    buffer.setUint32(offset, 0x00000009, Endian.big);
    offset += 4;
    
    // Command status
    buffer.setUint32(offset, 0, Endian.big);
    offset += 4;
    
    // Sequence number
    buffer.setUint32(offset, _getNextSequenceNumber(), Endian.big);
    offset += 4;
    
    // System ID
    buffer.setUint8(offset, _config!.systemId.length);
    offset += 1;
    for (int i = 0; i < _config!.systemId.length; i++) {
      buffer.setUint8(offset + i, _config!.systemId.codeUnitAt(i));
    }
    offset += _config!.systemId.length;
    
    // Password
    buffer.setUint8(offset, _config!.password.length);
    offset += 1;
    for (int i = 0; i < _config!.password.length; i++) {
      buffer.setUint8(offset + i, _config!.password.codeUnitAt(i));
    }
    offset += _config!.password.length;
    
    // System type
    buffer.setUint8(offset, _config!.systemType.length);
    offset += 1;
    for (int i = 0; i < _config!.systemType.length; i++) {
      buffer.setUint8(offset + i, _config!.systemType.codeUnitAt(i));
    }
    offset += _config!.systemType.length;
    
    // Interface version
    buffer.setUint8(offset, _config!.interfaceVersion);
    offset += 1;
    
    // TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Address range
    buffer.setUint8(offset, _config!.addressRange.length);
    offset += 1;
    for (int i = 0; i < _config!.addressRange.length; i++) {
      buffer.setUint8(offset + i, _config!.addressRange.codeUnitAt(i));
    }
    
    return buffer.buffer.asUint8List();
  }

  Uint8List _createUnbindRequest() {
    final commandLength = 16;
    final buffer = ByteData(commandLength + 4);
    
    int offset = 0;
    
    // Command length
    buffer.setUint32(offset, commandLength, Endian.big);
    offset += 4;
    
    // Command ID (unbind = 0x00000006)
    buffer.setUint32(offset, 0x00000006, Endian.big);
    offset += 4;
    
    // Command status
    buffer.setUint32(offset, 0, Endian.big);
    offset += 4;
    
    // Sequence number
    buffer.setUint32(offset, _getNextSequenceNumber(), Endian.big);
    offset += 4;
    
    return buffer.buffer.asUint8List();
  }

  Uint8List _createSubmitSmRequest(SmppMessage message) {
    // Simplified submit_sm request
    final commandLength = 33 + message.sourceAddress.length + message.destinationAddress.length + message.message.length;
    final buffer = ByteData(commandLength + 4);
    
    int offset = 0;
    
    // Command length
    buffer.setUint32(offset, commandLength, Endian.big);
    offset += 4;
    
    // Command ID (submit_sm = 0x00000004)
    buffer.setUint32(offset, 0x00000004, Endian.big);
    offset += 4;
    
    // Command status
    buffer.setUint32(offset, 0, Endian.big);
    offset += 4;
    
    // Sequence number
    buffer.setUint32(offset, message.sequenceNumber!, Endian.big);
    offset += 4;
    
    // Service type
    buffer.setUint8(offset, 0); // Empty
    offset += 1;
    
    // Source addr TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // Source addr NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Source addr
    buffer.setUint8(offset, message.sourceAddress.length);
    offset += 1;
    for (int i = 0; i < message.sourceAddress.length; i++) {
      buffer.setUint8(offset + i, message.sourceAddress.codeUnitAt(i));
    }
    offset += message.sourceAddress.length;
    
    // Dest addr TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // Dest addr NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Destination addr
    buffer.setUint8(offset, message.destinationAddress.length);
    offset += 1;
    for (int i = 0; i < message.destinationAddress.length; i++) {
      buffer.setUint8(offset + i, message.destinationAddress.codeUnitAt(i));
    }
    offset += message.destinationAddress.length;
    
    // ESM class
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Protocol ID
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Priority flag
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Schedule delivery time
    buffer.setUint8(offset, 0); // Empty
    offset += 1;
    
    // Validity period
    buffer.setUint8(offset, 0); // Empty
    offset += 1;
    
    // Registered delivery
    buffer.setUint8(offset, _config!.enableDeliveryReceipts ? 1 : 0);
    offset += 1;
    
    // Replace if present flag
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Data coding
    buffer.setUint8(offset, 0); // Default alphabet
    offset += 1;
    
    // SM default msg ID
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // SM length
    buffer.setUint8(offset, message.message.length);
    offset += 1;
    
    // Short message
    for (int i = 0; i < message.message.length; i++) {
      buffer.setUint8(offset + i, message.message.codeUnitAt(i));
    }
    
    return buffer.buffer.asUint8List();
  }

  void _handleData(Uint8List data) {
    try {
      final commandId = _extractCommandId(data);
      final sequenceNumber = _extractSequenceNumber(data);
      final commandStatus = _extractCommandStatus(data);
      
      _log('Received SMPP response: Command ID: 0x${commandId.toRadixString(16)}, Status: $commandStatus');
      
      switch (commandId) {
        case 0x80000009: // bind_transceiver_resp
          _handleBindResponse(commandStatus);
          break;
        case 0x80000004: // submit_sm_resp
          _handleSubmitSmResponse(sequenceNumber, commandStatus, data);
          break;
        case 0x80000006: // unbind_resp
          _handleUnbindResponse();
          break;
        case 0x00000005: // deliver_sm
          _handleDeliverSm(data);
          break;
        default:
          _log('Unknown SMPP command: 0x${commandId.toRadixString(16)}');
      }
    } catch (e) {
      _log('Error handling SMPP data: $e');
    }
  }

  void _handleBindResponse(int status) {
    if (status == 0) {
      _updateConnectionState(SmppConnectionState.bound);
      _log('Successfully bound to SMPP server');
      _startKeepAlive();
    } else {
      _log('Bind failed with status: $status');
      _updateConnectionState(SmppConnectionState.error);
      _scheduleReconnect();
    }
  }

  void _handleSubmitSmResponse(int sequenceNumber, int status, Uint8List data) {
    final completer = _pendingRequests.remove(sequenceNumber);
    if (completer != null) {
      if (status == 0) {
        final messageId = _extractMessageId(data);
        final message = SmppMessage(
          id: messageId,
          sourceAddress: '',
          destinationAddress: '',
          message: '',
          timestamp: DateTime.now(),
          status: SmppMessageStatus.sent,
          sequenceNumber: sequenceNumber,
        );
        completer.complete(message);
      } else {
        final message = SmppMessage(
          id: '',
          sourceAddress: '',
          destinationAddress: '',
          message: '',
          timestamp: DateTime.now(),
          status: SmppMessageStatus.failed,
          sequenceNumber: sequenceNumber,
        );
        completer.complete(message);
      }
    }
  }

  void _handleUnbindResponse() {
    _log('Unbind response received');
  }

  void _handleDeliverSm(Uint8List data) {
    try {
      final sourceAddress = _extractSourceAddress(data);
      final destinationAddress = _extractDestinationAddress(data);
      final message = _extractMessage(data);
      
      final smppMessage = SmppMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        sourceAddress: sourceAddress,
        destinationAddress: destinationAddress,
        message: message,
        timestamp: DateTime.now(),
        status: SmppMessageStatus.delivered,
      );
      
      _log('Received incoming SMS from $sourceAddress: $message');
      _incomingMessageController.add(smppMessage);
      
      // Send deliver_sm_resp
      _sendDeliverSmResponse();
    } catch (e) {
      _log('Error handling deliver_sm: $e');
    }
  }

  void _sendDeliverSmResponse() {
    if (_socket == null) return;
    
    final response = _createDeliverSmResponse();
    _socket!.add(response);
  }

  Uint8List _createDeliverSmResponse() {
    final commandLength = 16;
    final buffer = ByteData(commandLength + 4);
    
    int offset = 0;
    
    // Command length
    buffer.setUint32(offset, commandLength, Endian.big);
    offset += 4;
    
    // Command ID (deliver_sm_resp = 0x80000005)
    buffer.setUint32(offset, 0x80000005, Endian.big);
    offset += 4;
    
    // Command status
    buffer.setUint32(offset, 0, Endian.big);
    offset += 4;
    
    // Sequence number
    buffer.setUint32(offset, _getNextSequenceNumber(), Endian.big);
    offset += 4;
    
    return buffer.buffer.asUint8List();
  }

  int _extractCommandId(Uint8List data) {
    if (data.length < 8) return 0;
    return ByteData.sublistView(data, 4, 8).getUint32(0, Endian.big);
  }

  int _extractSequenceNumber(Uint8List data) {
    if (data.length < 12) return 0;
    return ByteData.sublistView(data, 12, 16).getUint32(0, Endian.big);
  }

  int _extractCommandStatus(Uint8List data) {
    if (data.length < 12) return 0;
    return ByteData.sublistView(data, 8, 12).getUint32(0, Endian.big);
  }

  String _extractMessageId(Uint8List data) {
    // Simplified extraction - in real implementation would parse TLV parameters
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  String _extractSourceAddress(Uint8List data) {
    // Simplified extraction
    return 'Unknown';
  }

  String _extractDestinationAddress(Uint8List data) {
    // Simplified extraction
    return 'Unknown';
  }

  String _extractMessage(Uint8List data) {
    // Simplified extraction
    return 'Message content';
  }

  void _handleError(error) {
    _log('SMPP connection error: $error');
    _updateConnectionState(SmppConnectionState.error);
    _scheduleReconnect();
  }

  void _handleDisconnect() {
    _log('SMPP connection closed');
    _updateConnectionState(SmppConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _updateConnectionState(SmppConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  void _startKeepAlive() {
    _keepAliveTimer?.cancel();
    _keepAliveTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (isConnected) {
        _sendEnquireLink();
      }
    });
  }

  void _sendEnquireLink() {
    if (_socket == null) return;
    
    final enquireLink = _createEnquireLinkRequest();
    _socket!.add(enquireLink);
  }

  Uint8List _createEnquireLinkRequest() {
    final commandLength = 16;
    final buffer = ByteData(commandLength + 4);
    
    int offset = 0;
    
    // Command length
    buffer.setUint32(offset, commandLength, Endian.big);
    offset += 4;
    
    // Command ID (enquire_link = 0x00000015)
    buffer.setUint32(offset, 0x00000015, Endian.big);
    offset += 4;
    
    // Command status
    buffer.setUint32(offset, 0, Endian.big);
    offset += 4;
    
    // Sequence number
    buffer.setUint32(offset, _getNextSequenceNumber(), Endian.big);
    offset += 4;
    
    return buffer.buffer.asUint8List();
  }

  void _scheduleReconnect() {
    if (_reconnectTimer != null) return;
    
    _reconnectTimer = Timer(Duration(milliseconds: _config?.reconnectInterval ?? 5000), () {
      _reconnectTimer = null;
      if (_connectionState != SmppConnectionState.bound) {
        _log('Attempting to reconnect...');
        connect();
      }
    });
  }

  int _getNextSequenceNumber() {
    return _sequenceNumber++;
  }

  void _log(String message) {
    final timestamp = DateTime.now().toIso8601String();
    final logMessage = '[$timestamp] SMPP: $message';
    // Use debugPrint for development logging
    debugPrint(logMessage);
    _logController.add(logMessage);
  }

  void dispose() {
    disconnect();
    _connectionStateController.close();
    _incomingMessageController.close();
    _deliveryReceiptController.close();
    _logController.close();
  }
}
