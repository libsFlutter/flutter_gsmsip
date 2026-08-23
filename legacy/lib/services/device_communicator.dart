/// Device Communicator for IMEI Modification
///
/// Handles serial/USB communication with Huawei and Qtech devices
/// for IMEI reading and writing operations.
///
/// ## Usage
///
/// ```dart
/// final communicator = DeviceCommunicator();
///
/// // Detect devices
/// final devices = await communicator.detectDevices();
///
/// // Connect to device
/// await communicator.connect(devices.first);
///
/// // Send AT command
/// final response = await communicator.sendCommand('AT+CGSN');
/// print('IMEI: $response');
///
/// // Disconnect
/// await communicator.disconnect();
/// ```
///
/// ## Legal Warning
///
/// ⚠️ IMEI modification may be illegal in your jurisdiction.
/// Use only for permitted purposes (restoration after repair, testing, etc.)
library device_communicator;

import 'dart:async';
import 'dart:io';

/// Device connection state
enum ConnectionState {
  /// Not connected
  disconnected,

  /// Connecting to device
  connecting,

  /// Connected and ready
  connected,

  /// Error occurred
  error,
}

/// Device type identifier
enum DeviceType {
  /// Huawei devices
  huawei,

  /// Qtech devices
  qtech,

  /// Unknown device type
  unknown,
}

/// Device information
class DeviceInfo {
  /// Device port path (e.g., '/dev/ttyUSB0' or 'COM3')
  final String port;

  /// Device description
  final String description;

  /// Device serial number
  final String? serialNumber;

  /// Device manufacturer
  final String? manufacturer;

  /// Device model
  final String? model;

  /// Device type
  final DeviceType type;

  /// USB Vendor ID
  final int? vendorId;

  /// USB Product ID
  final int? productId;

  const DeviceInfo({
    required this.port,
    required this.description,
    this.serialNumber,
    this.manufacturer,
    this.model,
    this.type = DeviceType.unknown,
    this.vendorId,
    this.productId,
  });

  /// Check if device is Huawei
  bool get isHuawei => type == DeviceType.huawei;

  /// Check if device is Qtech
  bool get isQtech => type == DeviceType.qtech;

  /// Create from USB device info
  factory DeviceInfo.fromUSB({
    required String port,
    required String description,
    String? serialNumber,
    int? vendorId,
    int? productId,
  }) {
    DeviceType type = DeviceType.unknown;
    String? manufacturer;
    String? model;

    // Detect device type from VID/PID or description
    if (description.toLowerCase().contains('huawei') ||
        vendorId == 0x12D1) {  // Huawei VID
      type = DeviceType.huawei;
      manufacturer = 'Huawei';
    } else if (description.toLowerCase().contains('qtech') ||
               description.toLowerCase().contains('zte')) {
      type = DeviceType.qtech;
      manufacturer = 'Qtech';
    }

    // Extract model from description
    final modelMatch = RegExp(r'([A-Z][a-z]?[0-9]{3,}[a-z]?)', caseSensitive: false)
        .firstMatch(description);
    if (modelMatch != null) {
      model = modelMatch.group(0);
    }

    return DeviceInfo(
      port: port,
      description: description,
      serialNumber: serialNumber,
      manufacturer: manufacturer,
      model: model,
      type: type,
      vendorId: vendorId,
      productId: productId,
    );
  }

  @override
  String toString() => 'DeviceInfo($model at $port)';
}

/// AT Command response
class ATResponse {
  /// Command that was sent
  final String command;

  /// Response data (without OK/ERROR)
  final String data;

  /// Whether command succeeded
  final bool success;

  /// Error message if failed
  final String? error;

  /// Raw response lines
  final List<String> rawLines;

  const ATResponse({
    required this.command,
    required this.data,
    required this.success,
    this.error,
    List<String>? rawLines,
  }) : rawLines = rawLines ?? [];

  /// Create success response
  factory ATResponse.success(String command, String data, List<String> rawLines) {
    return ATResponse(
      command: command,
      data: data,
      success: true,
      rawLines: rawLines,
    );
  }

  /// Create error response
  factory ATResponse.error(String command, String error, List<String> rawLines) {
    return ATResponse(
      command: command,
      data: '',
      success: false,
      error: error,
      rawLines: rawLines,
    );
  }

  @override
  String toString() => success ? data : 'ERROR: $error';
}

/// Device Communicator for IMEI Modification
///
/// Provides low-level serial communication with devices.
/// In production, this would use the `serial_port` package.
class DeviceCommunicator {
  // Stream controller for connection state
  final StreamController<ConnectionState> _stateController =
      StreamController<ConnectionState>.broadcast();

  // Currently connected device
  DeviceInfo? _connectedDevice;

  // Connection state
  ConnectionState _state = ConnectionState.disconnected;

  // Serial port reference (placeholder for production)
  // In production: dynamic serialPort;

  /// Connection state stream
  Stream<ConnectionState> get connectionStateStream => _stateController.stream;

  /// Current connection state
  ConnectionState get state => _state;

  /// Whether connected to a device
  bool get isConnected => _state == ConnectionState.connected;

  /// Currently connected device
  DeviceInfo? get connectedDevice => _connectedDevice;

  /// Initialize the communicator
  ///
  /// Sets up serial port permissions and event listeners
  Future<void> initialize() async {
    // In production, request USB permissions here
    // For Android: UsbManager.requestPermission()
    // For Linux: Check dialout group membership
    // For macOS: Check serial port permissions
  }

  /// Detect connected USB devices
  ///
  /// Returns list of compatible devices (Huawei, Qtech)
  ///
  /// Example:
  /// ```dart
  /// final devices = await communicator.detectDevices();
  /// for (final device in devices) {
  ///   print('${device.model} at ${device.port}');
  /// }
  /// ```
  Future<List<DeviceInfo>> detectDevices() async {
    final devices = <DeviceInfo>[];

    try {
      // Platform-specific device detection
      if (Platform.isLinux) {
        devices.addAll(await _detectLinuxDevices());
      } else if (Platform.isMacOS) {
        devices.addAll(await _detectMacOSDevices());
      } else if (Platform.isWindows) {
        devices.addAll(await _detectWindowsDevices());
      } else if (Platform.isAndroid) {
        devices.addAll(await _detectAndroidDevices());
      }

      // Filter to only supported devices
      return devices.where((d) => d.type != DeviceType.unknown).toList();
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }

  /// Detect devices on Linux
  Future<List<DeviceInfo>> _detectLinuxDevices() async {
    final devices = <DeviceInfo>[];

    // Check common USB serial ports
    final portPatterns = [
      '/dev/ttyUSB*',  // Common for USB modems
      '/dev/ttyACM*',  // CDC ACM devices
      '/dev/ttyHS*',   // High-speed serial
    ];

    for (final pattern in portPatterns) {
      // In production, use Directory listing with glob pattern
      // For now, check common ports
      final commonPorts = [
        '/dev/ttyUSB0',
        '/dev/ttyUSB1',
        '/dev/ttyUSB2',
        '/dev/ttyUSB3',
        '/dev/ttyACM0',
      ];

      for (final port in commonPorts) {
        try {
          final stat = await Process.run('stat', [port]);
          if (stat.exitCode == 0) {
            // Port exists, get device info
            final info = await _getLinuxDeviceInfo(port);
            if (info != null) {
              devices.add(info);
            }
          }
        } catch (_) {
          // Port doesn't exist or not accessible
        }
      }
    }

    return devices;
  }

  /// Get device info on Linux
  Future<DeviceInfo?> _getLinuxDeviceInfo(String port) async {
    try {
      // Use udevadm to get device info
      final result = await Process.run(
        'udevadm',
        ['info', '-a', '-n', port],
      );

      if (result.exitCode == 0) {
        final output = result.stdout as String;

        // Extract manufacturer
        final manufacturerMatch = RegExp(r'ATTRS{manufacturer}=="([^"]+)"')
            .firstMatch(output);
        final manufacturer = manufacturerMatch?.group(1);

        // Extract product
        final productMatch = RegExp(r'ATTRS{product}=="([^"]+)"')
            .firstMatch(output);
        final product = productMatch?.group(1);

        // Extract serial
        final serialMatch = RegExp(r'ATTRS{serial}=="([^"]+)"')
            .firstMatch(output);
        final serial = serialMatch?.group(1);

        return DeviceInfo.fromUSB(
          port: port,
          description: product ?? 'USB Serial Device',
          serialNumber: serial,
          vendorId: null,
          productId: null,
        );
      }
    } catch (_) {
      // Ignore errors
    }

    return null;
  }

  /// Detect devices on macOS
  Future<List<DeviceInfo>> _detectMacOSDevices() async {
    final devices = <DeviceInfo>[];

    try {
      // List USB serial devices
      final result = await Process.run(
        'ls',
        ['-la', '/dev/cu.usbserial*', '/dev/cu.usbmodem*'],
      );

      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final lines = output.split('\n');

        for (final line in lines) {
          if (line.contains('/dev/cu.')) {
            final parts = line.split(' ');
            final port = parts.lastWhere((p) => p.startsWith('/dev/cu.'));

            devices.add(DeviceInfo.fromUSB(
              port: port,
              description: 'USB Serial Device',
            ));
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }

    return devices;
  }

  /// Detect devices on Windows
  Future<List<DeviceInfo>> _detectWindowsDevices() async {
    final devices = <DeviceInfo>[];

    try {
      // Use PowerShell to list COM ports
      final result = await Process.run(
        'powershell',
        ['-Command', 'Get-PnpDevice -Class Ports | Select-Object Name, FriendlyName'],
      );

      if (result.exitCode == 0) {
        final output = result.stdout as String;
        final lines = output.split('\n');

        for (final line in lines.skip(2)) {  // Skip header
          if (line.contains('COM')) {
            final parts = line.trim().split(RegExp(r'\s+'));
            if (parts.length >= 2) {
              devices.add(DeviceInfo.fromUSB(
                port: parts.first,
                description: parts.skip(1).join(' '),
              ));
            }
          }
        }
      }
    } catch (_) {
      // Ignore errors
    }

    return devices;
  }

  /// Detect devices on Android
  Future<List<DeviceInfo>> _detectAndroidDevices() async {
    final devices = <DeviceInfo>[];

    // On Android, use USB Host API via platform channel
    // This is a placeholder implementation
    // In production, communicate with native Android code

    // Common Android USB serial paths
    final androidPorts = [
      '/dev/bus/usb/001/001',
      '/dev/bus/usb/001/002',
    ];

    for (final port in androidPorts) {
      // Check if port exists
      if (await File(port).exists()) {
        devices.add(DeviceInfo.fromUSB(
          port: port,
          description: 'Android USB Device',
        ));
      }
    }

    return devices;
  }

  /// Connect to a device
  ///
  /// [device] - Device to connect to
  /// [baudRate] - Serial baud rate (default: 115200)
  ///
  /// Returns true if connection successful
  Future<bool> connect(DeviceInfo device, {int baudRate = 115200}) async {
    if (_state == ConnectionState.connected) {
      // Already connected
      return true;
    }

    try {
      _updateState(ConnectionState.connecting);

      // In production, open serial port:
      // serialPort = SerialPort(device.port);
      // await serialPort.open(baudRate: baudRate);

      _connectedDevice = device;
      _updateState(ConnectionState.connected);

      return true;
    } catch (e) {
      _updateState(ConnectionState.error);
      return false;
    }
  }

  /// Disconnect from current device
  Future<void> disconnect() async {
    if (_state != ConnectionState.connected) {
      return;
    }

    try {
      // In production, close serial port
      // await serialPort?.close();

      _connectedDevice = null;
      _updateState(ConnectionState.disconnected);
    } catch (e) {
      // Ignore disconnect errors
    }
  }

  /// Send AT command
  ///
  /// [command] - AT command to send (without trailing newline)
  /// [timeout] - Command timeout (default: 5 seconds)
  ///
  /// Returns AT command response
  ///
  /// Example:
  /// ```dart
  /// final response = await communicator.sendCommand('AT+CGSN');
  /// if (response.success) {
  ///   print('IMEI: ${response.data}');
  /// }
  /// ```
  Future<ATResponse> sendCommand(String command, {Duration? timeout}) async {
    if (_state != ConnectionState.connected) {
      return ATResponse.error(command, 'Not connected', []);
    }

    final actualTimeout = timeout ?? const Duration(seconds: 5);
    final rawLines = <String>[];

    try {
      // In production, send command via serial port:
      // serialPort?.write('$command\r\n');
      // final response = await serialPort?.readUntil('OK', timeout: actualTimeout);

      // Simulate response for common commands
      await Future.delayed(const Duration(milliseconds: 100));

      if (command == 'AT') {
        rawLines.addAll(['OK']);
        return ATResponse.success(command, 'OK', rawLines);
      } else if (command == 'AT+CGSN') {
        // Simulate IMEI response
        rawLines.addAll(['861234567890123', 'OK']);
        return ATResponse.success(command, '861234567890123', rawLines);
      } else if (command.startsWith('AT^CIMEI=')) {
        // Simulate IMEI write
        rawLines.addAll(['OK']);
        return ATResponse.success(command, 'OK', rawLines);
      }

      // Default response
      rawLines.addAll(['OK']);
      return ATResponse.success(command, 'OK', rawLines);
    } catch (e) {
      rawLines.add('ERROR');
      return ATResponse.error(command, e.toString(), rawLines);
    }
  }

  /// Send AT command and parse IMEI from response
  Future<String?> readIMEI() async {
    final response = await sendCommand('AT+CGSN');
    if (response.success && response.data.isNotEmpty) {
      // Extract IMEI from response (should be 15 digits)
      final imeiMatch = RegExp(r'\d{15}').firstMatch(response.data);
      return imeiMatch?.group(0);
    }
    return null;
  }

  /// Write IMEI to device
  ///
  /// [imei] - New IMEI (15 digits)
  ///
  /// Returns true if write successful
  Future<bool> writeIMEI(String imei) async {
    if (imei.length != 15 || !RegExp(r'^\d+$').hasMatch(imei)) {
      return false;
    }

    // Use Huawei-specific command
    final response = await sendCommand('AT^CIMEI=$imei');
    return response.success;
  }

  /// Reboot device
  Future<bool> reboot() async {
    final response = await sendCommand('AT+CFUN=1,1');
    return response.success;
  }

  /// Read ICCID (SIM card ID)
  Future<String?> readICCID() async {
    final response = await sendCommand('AT^ICCID?');
    if (response.success) {
      // Extract ICCID (20 digits)
      final iccidMatch = RegExp(r'\d{20}').firstMatch(response.data);
      return iccidMatch?.group(0);
    }
    return null;
  }

  /// Read IMSI (SIM subscriber ID)
  Future<String?> readIMSI() async {
    final response = await sendCommand('AT+CIMI');
    if (response.success && response.data.length >= 15) {
      // IMSI is typically 15 digits
      return response.data.substring(0, 15);
    }
    return null;
  }

  /// Get signal quality
  Future<SignalQuality?> getSignalQuality() async {
    final response = await sendCommand('AT+CSQ');
    if (response.success) {
      // Parse +CSQ: <rssi>,<ber>
      final match = RegExp(r'\+CSQ:\s*(\d+),(\d+)').firstMatch(response.data);
      if (match != null) {
        final rssi = int.tryParse(match.group(1) ?? '-1') ?? -1;
        final ber = int.tryParse(match.group(2) ?? '99') ?? 99;
        return SignalQuality(rssi: rssi, ber: ber);
      }
    }
    return null;
  }

  void _updateState(ConnectionState state) {
    _state = state;
    _stateController.add(state);
  }

  /// Clean up resources
  void dispose() {
    disconnect();
    _stateController.close();
  }
}

/// Signal quality information
class SignalQuality {
  /// RSSI (Received Signal Strength Indicator)
  /// 0: -113 dBm or less
  /// 1: -111 dBm
  /// 2-30: -109 to -53 dBm
  /// 31: -51 dBm or greater
  /// 99: Not known or not detectable
  final int rssi;

  /// BER (Bit Error Rate)
  /// 0-7: As per 3GPP TS 45.008
  /// 99: Not known or not detectable
  final int ber;

  const SignalQuality({
    required this.rssi,
    required this.ber,
  });

  /// Signal strength in dBm
  int get dBm {
    if (rssi == 0) return -113;
    if (rssi == 1) return -111;
    if (rssi >= 2 && rssi <= 30) return -109 + ((rssi - 2) * 2);
    if (rssi == 31) return -51;
    return -999; // Unknown
  }

  /// Signal strength as percentage
  int get percentage {
    if (rssi == 0) return 0;
    if (rssi == 31) return 100;
    if (rssi >= 1 && rssi <= 30) {
      return ((rssi / 31.0) * 100).round();
    }
    return 0;
  }

  /// Signal quality description
  String get description {
    if (rssi == 99) return 'Unknown';
    if (percentage >= 80) return 'Excellent';
    if (percentage >= 60) return 'Good';
    if (percentage >= 40) return 'Fair';
    if (percentage >= 20) return 'Poor';
    return 'Very Poor';
  }

  @override
  String toString() => 'SignalQuality(RSSI: $rssi, BER: $ber, ${percentage}%)';
}
