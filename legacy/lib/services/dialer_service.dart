/// DialerService - Dial pad and call initiation service
///
/// Provides dialer functionality including:
/// - Dial pad number input and formatting
/// - Contact integration for phone number lookup
/// - Call initiation via SIP or GSM
/// - Recent calls management
///
/// Source: sdd-dialer specification
/// Tasks: dialer-001, dialer-002

import 'dart:async';
import 'package:flutter/services.dart';
import 'package:logger/logger.dart';

/// Phone number formatting style
enum PhoneNumberFormat {
  /// National format (e.g., (555) 123-4567)
  national,

  /// International format (e.g., +1 555 123 4567)
  international,

  /// E.164 format (e.g., +15551234567)
  e164,

  /// Raw format (no formatting, digits only)
  raw
}

/// Contact information for dialer integration
class DialerContact {
  final String id;
  final String displayName;
  final String phoneNumber;
  final String? normalizedNumber;
  final int? simSlot;

  const DialerContact({
    required this.id,
    required this.displayName,
    required this.phoneNumber,
    this.normalizedNumber,
    this.simSlot,
  });

  factory DialerContact.fromMap(Map<String, dynamic> map) {
    return DialerContact(
      id: map['id'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      normalizedNumber: map['normalizedNumber'] as String?,
      simSlot: map['simSlot'] as int?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'displayName': displayName,
    'phoneNumber': phoneNumber,
    'normalizedNumber': normalizedNumber,
    'simSlot': simSlot,
  };

  DialerContact copyWith({
    String? id,
    String? displayName,
    String? phoneNumber,
    String? normalizedNumber,
    int? simSlot,
  }) {
    return DialerContact(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      normalizedNumber: normalizedNumber ?? this.normalizedNumber,
      simSlot: simSlot ?? this.simSlot,
    );
  }
}

/// Recent call entry
class RecentCall {
  final String id;
  final String phoneNumber;
  final String? contactName;
  final DateTime timestamp;
  final int duration;
  final bool isIncoming;
  final bool wasMissed;

  const RecentCall({
    required this.id,
    required this.phoneNumber,
    this.contactName,
    required this.timestamp,
    required this.duration,
    required this.isIncoming,
    required this.wasMissed,
  });

  factory RecentCall.fromMap(Map<String, dynamic> map) {
    return RecentCall(
      id: map['id'] as String? ?? '',
      phoneNumber: map['phoneNumber'] as String? ?? '',
      contactName: map['contactName'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String? ?? DateTime.now().toIso8601String()),
      duration: map['duration'] as int? ?? 0,
      isIncoming: map['isIncoming'] as bool? ?? true,
      wasMissed: map['wasMissed'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'phoneNumber': phoneNumber,
    'contactName': contactName,
    'timestamp': timestamp.toIso8601String(),
    'duration': duration,
    'isIncoming': isIncoming,
    'wasMissed': wasMissed,
  };
}

/// Dialer Service for dial pad and contact integration
///
/// Provides:
/// - Dial pad input with formatting
/// - Contact lookup by name or number
/// - Call initiation (SIP or GSM)
/// - Recent calls management
class DialerService {
  static final DialerService _instance = DialerService._internal();
  factory DialerService() => _instance;
  DialerService._internal();

  final Logger _logger = Logger();

  // Method channels
  static const MethodChannel _channel = MethodChannel('gsm_sip_gateway/dialer');
  static const MethodChannel _contactsChannel = MethodChannel('gsm_sip_gateway/contacts');

  // Current dial pad input
  String _dialPadInput = '';
  final StreamController<String> _dialPadController = StreamController<String>.broadcast();

  /// Stream of dial pad input changes
  Stream<String> get dialPadStream => _dialPadController.stream;

  /// Current dial pad input
  String get dialPadInput => _dialPadInput;

  /// Clear dial pad input
  void clearDialPad() {
    _dialPadInput = '';
    _dialPadController.add(_dialPadInput);
    _logger.d('DialerService: Dial pad cleared');
  }

  /// Append digit to dial pad input
  void appendDigit(String digit) {
    if (digit.length != 1 || !RegExp(r'[0-9*#]').hasMatch(digit)) {
      _logger.w('DialerService: Invalid digit: $digit');
      return;
    }

    _dialPadInput += digit;
    _dialPadController.add(_dialPadInput);
    _logger.d('DialerService: Appended digit: $digit, input: $_dialPadInput');
  }

  /// Remove last digit from dial pad input
  void removeLastDigit() {
    if (_dialPadInput.isNotEmpty) {
      _dialPadInput = _dialPadInput.substring(0, _dialPadInput.length - 1);
      _dialPadController.add(_dialPadInput);
      _logger.d('DialerService: Removed last digit, input: $_dialPadInput');
    }
  }

  /// Format phone number according to specified style
  ///
  /// [number] - Phone number to format
  /// [format] - Formatting style
  /// Returns formatted phone number string
  String formatPhoneNumber(String number, PhoneNumberFormat format) {
    // Remove all non-digit characters except +
    final digits = number.replaceAll(RegExp(r'[^\d+]'), '');

    switch (format) {
      case PhoneNumberFormat.raw:
        return digits;

      case PhoneNumberFormat.e164:
        // Ensure starts with +
        if (!digits.startsWith('+')) {
          // Assume country code if missing (could be made configurable)
          return '+$digits';
        }
        return digits;

      case PhoneNumberFormat.national:
        return _formatNational(digits);

      case PhoneNumberFormat.international:
        if (!digits.startsWith('+')) {
          return '+$digits';
        }
        return _formatInternational(digits);
    }
  }

  /// Format as national (e.g., (555) 123-4567)
  String _formatNational(String digits) {
    // Remove + for national format
    final clean = digits.replaceAll('+', '');

    if (clean.length == 10) {
      // US format: (XXX) XXX-XXXX
      return '(${clean.substring(0, 3)}) ${clean.substring(3, 6)}-${clean.substring(6)}';
    } else if (clean.length == 11) {
      // US with leading 1: X (XXX) XXX-XXXX
      return '${clean[0]} (${clean.substring(1, 4)}) ${clean.substring(4, 7)}-${clean.substring(7)}';
    }

    // Default: group by 3s
    return _groupByThrees(clean);
  }

  /// Format as international (e.g., +1 555 123 4567)
  String _formatInternational(String digits) {
    final clean = digits.replaceAll('+', '');

    if (clean.length >= 10) {
      // Add spaces every 3 digits after country code
      final countryCode = clean.substring(0, clean.length - 10);
      final rest = clean.substring(clean.length - 10);
      return '+$countryCode ${_groupByThrees(rest)}';
    }

    return '+$_groupByThrees(clean)';
  }

  /// Group digits by threes with spaces
  String _groupByThrees(String digits) {
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 3 == 0) {
        buffer.write(' ');
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }

  /// Look up contact by phone number
  ///
  /// [phoneNumber] - Phone number to search
  /// Returns [DialerContact] if found, null otherwise
  Future<DialerContact?> lookupContact(String phoneNumber) async {
    try {
      _logger.d('DialerService: Looking up contact for: $phoneNumber');

      final result = await _contactsChannel.invokeMethod<Map<dynamic, dynamic>>(
        'lookupContact',
        {'phoneNumber': phoneNumber},
      );

      if (result != null) {
        final contact = DialerContact.fromMap(result.cast<String, dynamic>());
        _logger.d('DialerService: Contact found: ${contact.displayName}');
        return contact;
      }

      _logger.d('DialerService: No contact found for: $phoneNumber');
      return null;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Contact lookup failed', error: e);
      return null;
    }
  }

  /// Search contacts by name
  ///
  /// [query] - Search query string
  /// Returns list of matching contacts
  Future<List<DialerContact>> searchContacts(String query) async {
    try {
      _logger.d('DialerService: Searching contacts for: $query');

      final result = await _contactsChannel.invokeMethod<List<dynamic>>(
        'searchContacts',
        {'query': query},
      );

      final contacts = result
          ?.whereType<Map<dynamic, dynamic>>()
          .map((m) => DialerContact.fromMap(m.cast<String, dynamic>()))
          .toList() ?? [];

      _logger.d('DialerService: Found ${contacts.length} contacts');
      return contacts;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Contact search failed', error: e);
      return [];
    }
  }

  /// Get recent calls
  ///
  /// [limit] - Maximum number of recent calls to return
  /// Returns list of recent calls
  Future<List<RecentCall>> getRecentCalls({int limit = 50}) async {
    try {
      _logger.d('DialerService: Getting recent calls (limit: $limit)');

      final result = await _channel.invokeMethod<List<dynamic>>(
        'getRecentCalls',
        {'limit': limit},
      );

      final calls = result
          ?.whereType<Map<dynamic, dynamic>>()
          .map((m) => RecentCall.fromMap(m.cast<String, dynamic>()))
          .toList() ?? [];

      _logger.d('DialerService: Got ${calls.length} recent calls');
      return calls;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Get recent calls failed', error: e);
      return [];
    }
  }

  /// Initiate a call
  ///
  /// [phoneNumber] - Phone number to call
  /// [useSip] - If true, use SIP; if false, use GSM
  /// Returns true if call initiated successfully
  Future<bool> initiateCall(String phoneNumber, {bool useSip = true}) async {
    try {
      _logger.i('DialerService: Initiating call to $phoneNumber (useSip: $useSip)');

      final method = useSip ? 'initiateSipCall' : 'initiateGsmCall';
      final result = await _channel.invokeMethod<bool>(
        method,
        {'phoneNumber': phoneNumber},
      );

      if (result == true) {
        _logger.i('DialerService: Call initiated successfully');
        // Clear dial pad after successful call initiation
        clearDialPad();
        return true;
      }

      _logger.w('DialerService: Call initiation failed');
      return false;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Call initiation failed', error: e);
      return false;
    }
  }

  /// Initiate SIP call
  ///
  /// [phoneNumber] - Phone number to call
  /// Returns true if call initiated successfully
  Future<bool> initiateSipCall(String phoneNumber) async {
    return initiateCall(phoneNumber, useSip: true);
  }

  /// Initiate GSM call
  ///
  /// [phoneNumber] - Phone number to call
  /// Returns true if call initiated successfully
  Future<bool> initiateGsmCall(String phoneNumber) async {
    return initiateCall(phoneNumber, useSip: false);
  }

  /// Open system dialer with pre-filled number
  ///
  /// [phoneNumber] - Phone number to pre-fill
  /// Returns true if dialer opened successfully
  Future<bool> openSystemDialer({String? phoneNumber}) async {
    try {
      _logger.d('DialerService: Opening system dialer');

      final result = await _channel.invokeMethod<bool>(
        'openSystemDialer',
        {'phoneNumber': phoneNumber},
      );

      if (result == true) {
        _logger.d('DialerService: System dialer opened');
        return true;
      }

      _logger.w('DialerService: Failed to open system dialer');
      return false;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Open system dialer failed', error: e);
      return false;
    }
  }

  /// Check if contacts permission is granted
  ///
  /// Returns true if permission granted
  Future<bool> hasContactsPermission() async {
    try {
      final result = await _contactsChannel.invokeMethod<bool>('hasPermission');
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Permission check failed', error: e);
      return false;
    }
  }

  /// Request contacts permission
  ///
  /// Returns true if permission granted
  Future<bool> requestContactsPermission() async {
    try {
      final result = await _contactsChannel.invokeMethod<bool>('requestPermission');
      if (result == true) {
        _logger.d('DialerService: Contacts permission granted');
      } else {
        _logger.w('DialerService: Contacts permission denied');
      }
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('DialerService: Permission request failed', error: e);
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _dialPadController.close();
    _logger.d('DialerService: Disposed');
  }
}

// ============================================================================
// Gateway-Specific Features (SIP↔GSM Bridge)
// ============================================================================

/// Gateway line status
enum LineStatus {
  /// Line is available
  available,

  /// Line is degraded (poor signal/quality)
  degraded,

  /// Line is unavailable
  unavailable,
}

/// Call route type
enum CallRoute {
  /// SIP → Gateway → GSM bridge
  sipBridge,

  /// Direct GSM call
  directGsm,

  /// Direct SIP call (VoIP)
  directSip,
}

/// Gateway line information
class GatewayLineInfo {
  final String id;
  final String name;
  final LineStatus status;
  final String? signalStrength;
  final String? networkType;
  final bool isRegistered;

  const GatewayLineInfo({
    required this.id,
    required this.name,
    required this.status,
    this.signalStrength,
    this.networkType,
    this.isRegistered = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'status': status.index,
    'signalStrength': signalStrength,
    'networkType': networkType,
    'isRegistered': isRegistered,
  };

  factory GatewayLineInfo.fromMap(Map<String, dynamic> map) {
    return GatewayLineInfo(
      id: map['id'] as String? ?? '',
      name: map['name'] as String? ?? '',
      status: LineStatus.values[map['status'] as int? ?? 0],
      signalStrength: map['signalStrength'] as String?,
      networkType: map['networkType'] as String?,
      isRegistered: map['isRegistered'] as bool? ?? false,
    );
  }
}

/// Call route with cost estimate
class CallRouteInfo {
  final CallRoute route;
  final String displayName;
  final double costPerMinute;
  final String currency;
  final String qualityRating;
  final GatewayLineInfo lineInfo;

  const CallRouteInfo({
    required this.route,
    required this.displayName,
    required this.costPerMinute,
    this.currency = 'RUB',
    this.qualityRating = '★★★★☆',
    required this.lineInfo,
  });

  Map<String, dynamic> toMap() => {
    'route': route.index,
    'displayName': displayName,
    'costPerMinute': costPerMinute,
    'currency': currency,
    'qualityRating': qualityRating,
    'lineInfo': lineInfo.toMap(),
  };

  factory CallRouteInfo.fromMap(Map<String, dynamic> map) {
    return CallRouteInfo(
      route: CallRoute.values[map['route'] as int? ?? 0],
      displayName: map['displayName'] as String? ?? '',
      costPerMinute: map['costPerMinute'] as double? ?? 0.0,
      currency: map['currency'] as String? ?? 'RUB',
      qualityRating: map['qualityRating'] as String? ?? '★★★☆☆',
      lineInfo: GatewayLineInfo.fromMap(map['lineInfo'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Network quality statistics
class NetworkQualityStats {
  final int latencyMs;
  final int jitterMs;
  final double packetLossPercent;
  final double mos;
  final String codec;
  final int bandwidthKbps;

  const NetworkQualityStats({
    this.latencyMs = 0,
    this.jitterMs = 0,
    this.packetLossPercent = 0.0,
    this.mos = 0.0,
    this.codec = 'Unknown',
    this.bandwidthKbps = 0,
  });

  Map<String, dynamic> toMap() => {
    'latencyMs': latencyMs,
    'jitterMs': jitterMs,
    'packetLossPercent': packetLossPercent,
    'mos': mos,
    'codec': codec,
    'bandwidthKbps': bandwidthKbps,
  };

  factory NetworkQualityStats.fromMap(Map<String, dynamic> map) {
    return NetworkQualityStats(
      latencyMs: map['latencyMs'] as int? ?? 0,
      jitterMs: map['jitterMs'] as int? ?? 0,
      packetLossPercent: map['packetLossPercent'] as double? ?? 0.0,
      mos: map['mos'] as double? ?? 0.0,
      codec: map['codec'] as String? ?? 'Unknown',
      bandwidthKbps: map['bandwidthKbps'] as int? ?? 0,
    );
  }

  /// Get quality description
  String get qualityDescription {
    if (mos >= 4.0) return 'Excellent';
    if (mos >= 3.0) return 'Good';
    if (mos >= 2.0) return 'Fair';
    return 'Poor';
  }
}

/// Bridge call status (SIP + GSM legs)
class BridgeCallStatus {
  final String callId;
  final bool sipLegConnected;
  final bool gsmLegConnected;
  final bool bridgeActive;
  final Duration sipLegDuration;
  final Duration gsmLegDuration;
  final NetworkQualityStats sipStats;
  final NetworkQualityStats gsmStats;

  const BridgeCallStatus({
    required this.callId,
    required this.sipLegConnected,
    required this.gsmLegConnected,
    required this.bridgeActive,
    this.sipLegDuration = Duration.zero,
    this.gsmLegDuration = Duration.zero,
    this.sipStats = const NetworkQualityStats(),
    this.gsmStats = const NetworkQualityStats(),
  });

  Map<String, dynamic> toMap() => {
    'callId': callId,
    'sipLegConnected': sipLegConnected,
    'gsmLegConnected': gsmLegConnected,
    'bridgeActive': bridgeActive,
    'sipLegDuration': sipLegDuration.inSeconds,
    'gsmLegDuration': gsmLegDuration.inSeconds,
    'sipStats': sipStats.toMap(),
    'gsmStats': gsmStats.toMap(),
  };

  factory BridgeCallStatus.fromMap(Map<String, dynamic> map) {
    return BridgeCallStatus(
      callId: map['callId'] as String? ?? '',
      sipLegConnected: map['sipLegConnected'] as bool? ?? false,
      gsmLegConnected: map['gsmLegConnected'] as bool? ?? false,
      bridgeActive: map['bridgeActive'] as bool? ?? false,
      sipLegDuration: Duration(seconds: map['sipLegDuration'] as int? ?? 0),
      gsmLegDuration: Duration(seconds: map['gsmLegDuration'] as int? ?? 0),
      sipStats: NetworkQualityStats.fromMap(map['sipStats'] as Map<String, dynamic>? ?? {}),
      gsmStats: NetworkQualityStats.fromMap(map['gsmStats'] as Map<String, dynamic>? ?? {}),
    );
  }
}

/// Gateway Dialer Service extension for SIP↔GSM bridge features
extension GatewayDialerService on DialerService {
  /// Get available gateway lines
  Future<List<GatewayLineInfo>> getAvailableLines() async {
    try {
      final result = await DialerService._channel.invokeList<Map<dynamic, dynamic>>('getAvailableLines');
      return result
          ?.map((line) => GatewayLineInfo.fromMap(line as Map<String, dynamic>))
          .toList() ?? [];
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get available lines failed', error: e);
      return [];
    }
  }

  /// Get gateway status (SIP registration, GSM signal)
  Future<Map<String, dynamic>> getGatewayStatus() async {
    try {
      final result = await DialerService._channel.invokeMapMethod<String, dynamic>('getGatewayStatus');
      return result ?? {
        'sipRegistered': false,
        'gsmSignalStrength': 0,
        'gsmNetworkType': 'Unknown',
      };
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get gateway status failed', error: e);
      return {
        'sipRegistered': false,
        'gsmSignalStrength': 0,
        'gsmNetworkType': 'Unknown',
      };
    }
  }

  /// Get available call routes for a phone number
  Future<List<CallRouteInfo>> getAvailableRoutes(String phoneNumber) async {
    try {
      final result = await DialerService._channel.invokeList<Map<dynamic, dynamic>>(
        'getAvailableRoutes',
        {'phoneNumber': phoneNumber},
      );
      return result
          ?.map((route) => CallRouteInfo.fromMap(route as Map<String, dynamic>))
          .toList() ?? [];
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get available routes failed', error: e);
      return [];
    }
  }

  /// Select call route
  Future<bool> selectRoute(CallRoute route) async {
    try {
      final result = await DialerService._channel.invokeMethod<bool>(
        'selectRoute',
        {'route': route.index},
      );
      return result ?? false;
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Select route failed', error: e);
      return false;
    }
  }

  /// Get current call route
  Future<CallRoute?> getCurrentRoute() async {
    try {
      final result = await DialerService._channel.invokeMethod<int>('getCurrentRoute');
      if (result != null && result < CallRoute.values.length) {
        return CallRoute.values[result];
      }
      return null;
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get current route failed', error: e);
      return null;
    }
  }

  /// Get network quality stats for active call
  Future<NetworkQualityStats> getNetworkQualityStats() async {
    try {
      final result = await DialerService._channel.invokeMapMethod<String, dynamic>('getNetworkQualityStats');
      return NetworkQualityStats.fromMap(result ?? {});
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get network quality stats failed', error: e);
      return const NetworkQualityStats();
    }
  }

  /// Get bridge call status
  Future<BridgeCallStatus?> getBridgeCallStatus(String callId) async {
    try {
      final result = await DialerService._channel.invokeMapMethod<String, dynamic>(
        'getBridgeCallStatus',
        {'callId': callId},
      );
      if (result == null) return null;
      return BridgeCallStatus.fromMap(result);
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get bridge call status failed', error: e);
      return null;
    }
  }

  /// Get audio levels for active call
  Future<Map<String, double>> getAudioLevels() async {
    try {
      final result = await DialerService._channel.invokeMapMethod<String, double>('getAudioLevels');
      return result ?? {
        'sipTx': 0.0,
        'sipRx': 0.0,
        'gsmTx': 0.0,
        'gsmRx': 0.0,
      };
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Get audio levels failed', error: e);
      return {
        'sipTx': 0.0,
        'sipRx': 0.0,
        'gsmTx': 0.0,
        'gsmRx': 0.0,
      };
    }
  }

  /// Initiate bridge call (SIP → GSM)
  Future<bool> initiateBridgeCall(String phoneNumber, String sipUri) async {
    try {
      _logger.d('GatewayDialerService: Initiating bridge call: $phoneNumber via $sipUri');

      final result = await DialerService._channel.invokeMethod<bool>(
        'initiateBridgeCall',
        {
          'phoneNumber': phoneNumber,
          'sipUri': sipUri,
        },
      );

      if (result == true) {
        _logger.i('GatewayDialerService: Bridge call initiated successfully');
        return true;
      }

      _logger.w('GatewayDialerService: Bridge call initiation failed');
      return false;
    } on PlatformException catch (e) {
      _logger.e('GatewayDialerService: Bridge call initiation failed', error: e);
      return false;
    }
  }
}
