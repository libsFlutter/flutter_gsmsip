import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:convert';

class SmppConfig {
  final String host;
  final int port;
  final String systemId;
  final String password;
  final String systemType;
  final int interfaceVersion;
  final int ton;
  final int npi;
  final String addressRange;
  final bool enableDeliveryReceipts;
  final int requestTimeout;

  SmppConfig({
    required this.host,
    required this.port,
    required this.systemId,
    required this.password,
    this.systemType = '',
    this.interfaceVersion = 0x34,
    this.ton = 0,
    this.npi = 0,
    this.addressRange = '',
    this.enableDeliveryReceipts = true,
    this.requestTimeout = 30000,
  });
}

enum SmppConnectionState {
  disconnected,
  connecting,
  connected,
  bound,
  error,
}

class StandaloneSmppService {
  Socket? _socket;
  SmppConfig? _config;
  SmppConnectionState _connectionState = SmppConnectionState.disconnected;
  int _sequenceNumber = 1;
  final Map<int, Completer<bool>> _pendingRequests = {};

  SmppConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == SmppConnectionState.bound;

  Future<void> initialize(SmppConfig config) async {
    _config = config;
    print('SMPP Service initialized with config: ${config.host}:${config.port}');
  }

  Future<bool> connect() async {
    if (_config == null) {
      print('❌ SMPP config not initialized');
      return false;
    }

    if (_connectionState == SmppConnectionState.connecting) {
      print('⚠️ Already connecting...');
      return false;
    }

    _updateConnectionState(SmppConnectionState.connecting);

    try {
      print('🔌 Connecting to SMPP server: ${_config!.host}:${_config!.port}');
      
      _socket = await Socket.connect(_config!.host, _config!.port, 
          timeout: Duration(milliseconds: _config!.requestTimeout));
      
      _socket!.listen(
        _handleData,
        onError: _handleError,
        onDone: _handleDisconnect,
        cancelOnError: false,
      );

      _updateConnectionState(SmppConnectionState.connected);
      print('✅ Connected to SMPP server');

      // Send bind request
      await _sendBindRequest();
      
      return true;
    } catch (e) {
      print('❌ Error connecting to SMPP server: $e');
      _updateConnectionState(SmppConnectionState.error);
      return false;
    }
  }

  Future<void> disconnect() async {
    print('🔌 Disconnecting from SMPP server...');
    
    if (_socket != null) {
      await _sendUnbindRequest();
      await _socket!.close();
      _socket = null;
    }
    
    _updateConnectionState(SmppConnectionState.disconnected);
    print('✅ Disconnected from SMPP server');
  }

  Future<bool> sendSms(String destinationAddress, String message, {String? sourceAddress}) async {
    if (!isConnected) {
      print('❌ Not connected to SMPP server');
      return false;
    }

    try {
      final sequenceNumber = _getNextSequenceNumber();
      
      print('📤 Sending SMS to $destinationAddress: ${message.length} characters');
      
      final completer = Completer<bool>();
      _pendingRequests[sequenceNumber] = completer;
      
      await _sendSubmitSmRequest(
        sourceAddress ?? _config!.systemId,
        destinationAddress,
        message,
        sequenceNumber,
      );
      
      // Wait for response
      final success = await completer.future.timeout(
        Duration(milliseconds: _config!.requestTimeout),
        onTimeout: () {
          _pendingRequests.remove(sequenceNumber);
          throw TimeoutException('SMPP request timeout', Duration(milliseconds: _config!.requestTimeout));
        },
      );

      if (success) {
        print('✅ SMS sent successfully');
      } else {
        print('❌ SMS sending failed');
      }
      
      return success;
    } catch (e) {
      print('❌ Error sending SMS: $e');
      return false;
    }
  }

  Future<void> _sendBindRequest() async {
    if (_socket == null) return;

    final bindRequest = _createBindRequest();
    _socket!.add(bindRequest);
    
    print('📤 Sent bind request');
  }

  Future<void> _sendUnbindRequest() async {
    if (_socket == null) return;

    final unbindRequest = _createUnbindRequest();
    _socket!.add(unbindRequest);
    
    print('📤 Sent unbind request');
  }

  Future<void> _sendSubmitSmRequest(String sourceAddress, String destinationAddress, String message, int sequenceNumber) async {
    if (_socket == null) return;

    final submitSmRequest = _createSubmitSmRequest(sourceAddress, destinationAddress, message, sequenceNumber);
    _socket!.add(submitSmRequest);
  }

  Uint8List _createBindRequest() {
    final systemIdBytes = utf8.encode(_config!.systemId);
    final passwordBytes = utf8.encode(_config!.password);
    final systemTypeBytes = utf8.encode(_config!.systemType);
    final addressRangeBytes = utf8.encode(_config!.addressRange);
    
    final commandLength = 16 + systemIdBytes.length + 1 + passwordBytes.length + 1 + 
                         systemTypeBytes.length + 1 + 1 + 1 + 1 + addressRangeBytes.length + 1;
    
    final buffer = ByteData(commandLength);
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
    
    // System ID (null-terminated)
    for (int i = 0; i < systemIdBytes.length; i++) {
      buffer.setUint8(offset + i, systemIdBytes[i]);
    }
    offset += systemIdBytes.length;
    buffer.setUint8(offset, 0); // null terminator
    offset += 1;
    
    // Password (null-terminated)
    for (int i = 0; i < passwordBytes.length; i++) {
      buffer.setUint8(offset + i, passwordBytes[i]);
    }
    offset += passwordBytes.length;
    buffer.setUint8(offset, 0); // null terminator
    offset += 1;
    
    // System type (null-terminated)
    for (int i = 0; i < systemTypeBytes.length; i++) {
      buffer.setUint8(offset + i, systemTypeBytes[i]);
    }
    offset += systemTypeBytes.length;
    buffer.setUint8(offset, 0); // null terminator
    offset += 1;
    
    // Interface version
    buffer.setUint8(offset, _config!.interfaceVersion);
    offset += 1;
    
    // TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Address range (null-terminated)
    for (int i = 0; i < addressRangeBytes.length; i++) {
      buffer.setUint8(offset + i, addressRangeBytes[i]);
    }
    offset += addressRangeBytes.length;
    buffer.setUint8(offset, 0); // null terminator
    
    return buffer.buffer.asUint8List();
  }

  Uint8List _createUnbindRequest() {
    final commandLength = 16;
    final buffer = ByteData(commandLength);
    
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

  Uint8List _createSubmitSmRequest(String sourceAddress, String destinationAddress, String message, int sequenceNumber) {
    final sourceBytes = utf8.encode(sourceAddress);
    final destBytes = utf8.encode(destinationAddress);
    final messageBytes = utf8.encode(message);
    
    final commandLength = 16 + 1 + 1 + 1 + sourceBytes.length + 1 + 1 + 1 + 
                         destBytes.length + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + 1 + messageBytes.length;
    
    final buffer = ByteData(commandLength);
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
    buffer.setUint32(offset, sequenceNumber, Endian.big);
    offset += 4;
    
    // Service type (null-terminated)
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Source addr TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // Source addr NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Source addr (null-terminated)
    for (int i = 0; i < sourceBytes.length; i++) {
      buffer.setUint8(offset + i, sourceBytes[i]);
    }
    offset += sourceBytes.length;
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Dest addr TON
    buffer.setUint8(offset, _config!.ton);
    offset += 1;
    
    // Dest addr NPI
    buffer.setUint8(offset, _config!.npi);
    offset += 1;
    
    // Destination addr (null-terminated)
    for (int i = 0; i < destBytes.length; i++) {
      buffer.setUint8(offset + i, destBytes[i]);
    }
    offset += destBytes.length;
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // ESM class
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Protocol ID
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Priority flag
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Schedule delivery time (null-terminated)
    buffer.setUint8(offset, 0);
    offset += 1;
    
    // Validity period (null-terminated)
    buffer.setUint8(offset, 0);
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
    buffer.setUint8(offset, messageBytes.length);
    offset += 1;
    
    // Short message
    for (int i = 0; i < messageBytes.length; i++) {
      buffer.setUint8(offset + i, messageBytes[i]);
    }
    
    return buffer.buffer.asUint8List();
  }

  void _handleData(Uint8List data) {
    try {
      if (data.length < 16) return;
      
      final commandId = _extractCommandId(data);
      final sequenceNumber = _extractSequenceNumber(data);
      final commandStatus = _extractCommandStatus(data);
      
      print('📥 Received SMPP response: Command ID: 0x${commandId.toRadixString(16)}, Status: $commandStatus');
      
      switch (commandId) {
        case 0x80000009: // bind_transceiver_resp
          _handleBindResponse(commandStatus);
          break;
        case 0x80000004: // submit_sm_resp
          _handleSubmitSmResponse(sequenceNumber, commandStatus);
          break;
        case 0x80000006: // unbind_resp
          print('📥 Unbind response received');
          break;
        default:
          print('❓ Unknown SMPP command: 0x${commandId.toRadixString(16)}');
      }
    } catch (e) {
      print('❌ Error handling SMPP data: $e');
    }
  }

  void _handleBindResponse(int status) {
    if (status == 0) {
      _updateConnectionState(SmppConnectionState.bound);
      print('✅ Successfully bound to SMPP server');
    } else {
      print('❌ Bind failed with status: $status');
      _updateConnectionState(SmppConnectionState.error);
    }
  }

  void _handleSubmitSmResponse(int sequenceNumber, int status) {
    final completer = _pendingRequests.remove(sequenceNumber);
    if (completer != null) {
      completer.complete(status == 0);
    }
  }

  int _extractCommandId(Uint8List data) {
    return ByteData.sublistView(data, 4, 8).getUint32(0, Endian.big);
  }

  int _extractSequenceNumber(Uint8List data) {
    return ByteData.sublistView(data, 12, 16).getUint32(0, Endian.big);
  }

  int _extractCommandStatus(Uint8List data) {
    return ByteData.sublistView(data, 8, 12).getUint32(0, Endian.big);
  }

  void _handleError(error) {
    print('❌ SMPP connection error: $error');
    _updateConnectionState(SmppConnectionState.error);
  }

  void _handleDisconnect() {
    print('🔌 SMPP connection closed');
    _updateConnectionState(SmppConnectionState.disconnected);
  }

  void _updateConnectionState(SmppConnectionState state) {
    _connectionState = state;
  }

  int _getNextSequenceNumber() {
    return _sequenceNumber++;
  }
}

void main() async {
  print('=== Standalone SMPP SMS Test ===');
  
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
    );
    testNumber = '+1234567890';
    testMessage = 'Test SMS from SMPP Gateway';
  }
  
  print('📋 SMPP Config: ${config.host}:${config.port}');
  print('📋 System ID: ${config.systemId}');
  
  final smppService = StandaloneSmppService();
  
  try {
    // Initialize SMPP service
    print('\n1️⃣ Initializing SMPP service...');
    await smppService.initialize(config);
    
    // Connect to SMPP server
    print('2️⃣ Connecting to SMPP server...');
    final connected = await smppService.connect();
    
    if (!connected) {
      print('❌ Failed to connect to SMPP server');
      exit(1);
    }
    
    // Wait a bit for the connection to stabilize
    await Future.delayed(Duration(seconds: 2));
    
    if (!smppService.isConnected) {
      print('❌ SMPP service is not in bound state');
      exit(1);
    }
    
    print('✅ SMPP service is bound and ready');
    
    // Send test SMS
    print('\n3️⃣ Sending test SMS...');
    final finalMessage = '$testMessage - ${DateTime.now()}';
    
    print('📱 To: $testNumber');
    print('💬 Message: $finalMessage');
    
    final success = await smppService.sendSms(testNumber, finalMessage);
    
    if (success) {
      print('🎉 SMS sent successfully!');
    } else {
      print('❌ Failed to send SMS');
    }
    
    // Wait a bit to see any delivery receipts
    print('\n4️⃣ Waiting for delivery receipts...');
    await Future.delayed(Duration(seconds: 5));
    
  } catch (e) {
    print('❌ Error during SMPP test: $e');
  } finally {
    // Disconnect
    print('\n5️⃣ Disconnecting...');
    await smppService.disconnect();
  }
  
  print('\n🏁 Test Complete ===');
}
