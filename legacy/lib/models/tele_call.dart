/// TeleCall - Comprehensive Call Model
/// 
/// Full-featured call model with 40+ fields for complete call state tracking.
/// This is the Flutter-side rich model that receives minimal events from Android
/// and enriches them with computed/local fields.
/// 
/// GAP-007 Resolution: The model mismatch between Dart (40+ fields) and Kotlin (10 fields)
/// is intentional by design. Android streams only essential state changes, while Flutter
/// enriches events with computed fields (duration, media info, status codes, etc.).
/// 
/// Source: sdd-call-model specification
/// Tasks: callmodel-001, callmodel-002, callmodel-003, callmodel-004, callmodel-005, callmodel-006
class TeleCall {
  // ==================== Identity Properties ====================
  
  /// Internal Flutter-side call identifier
  final int id;
  
  /// Native telephony system call ID
  final String? callId;
  
  /// Account identifier for multi-account setups
  final int? accountId;
  
  /// Hash for call comparison/equality
  final String? callHashCode;

  // ==================== Participant Properties ====================
  
  /// Local contact name/identifier
  final String? localContact;
  
  /// Local SIP/tel URI
  final String? localUri;
  
  /// Remote contact name/identifier
  final String? remoteContact;
  
  /// Remote SIP/tel URI
  final String? remoteUri;
  
  /// Extracted phone number from URI
  final String? remoteNumber;
  
  /// Extracted display name from URI
  final String? remoteName;

  // ==================== State Properties ====================
  
  /// Call state enum string (PJSIP_INV_STATE_*)
  final String? state;
  
  /// Human-readable state description
  final String? stateText;
  
  /// Call is on hold
  final bool? held;
  
  /// Microphone is muted
  final bool? muted;
  
  /// Speakerphone is active
  final bool? speaker;
  
  /// Call direction: DIRECTION_INCOMING or DIRECTION_OUTGOING
  final String? direction;
  
  /// Reason for disconnection
  final String? disconnectCause;

  // ==================== Timing Properties ====================
  
  /// Connected duration in seconds (from Android events)
  final int? connectDuration;
  
  /// Total duration in seconds (from Android events)
  final int? totalDuration;
  
  /// ISO 8601 creation timestamp
  final String? creationTime;
  
  /// ISO 8601 connection timestamp
  final String? connectTime;
  
  /// Epoch milliseconds for creation (used for duration calculations)
  final int? creationTimeMillis;
  
  /// Epoch milliseconds for connection
  final int? connectTimeMillis;

  // ==================== Media Properties ====================
  
  /// Number of local audio streams
  final int? audioCount;
  
  /// Number of local video streams
  final int? videoCount;
  
  /// Number of remote audio streams
  final int? remoteAudioCount;
  
  /// Number of remote video streams
  final int? remoteVideoCount;
  
  /// True if remote initiated media negotiation
  final bool? remoteOfferer;
  
  /// Current media details
  final Map<String, dynamic>? media;
  
  /// Pre-negotiation media details
  final Map<String, dynamic>? provisionalMedia;

  // ==================== Status Properties ====================
  
  /// Last SIP/telephony status code
  final int? lastStatusCode;
  
  /// Last error/reason text
  final String? lastReason;
  
  /// Additional call details
  final Map<String, dynamic>? details;
  
  /// Vendor-specific extras
  final Map<String, dynamic>? extras;

  // ==================== SIM Properties ====================
  
  /// SIM slot used (0-based or 1-based)
  final int? simSlot;
  
  /// SIM slot 1 identifier
  final int? simSlot1;
  
  /// SIM slot 2 identifier
  final int? simSlot2;

  const TeleCall({
    required this.id,
    this.callId,
    this.accountId,
    this.callHashCode,
    this.localContact,
    this.localUri,
    this.remoteContact,
    this.remoteUri,
    this.remoteNumber,
    this.remoteName,
    this.state,
    this.stateText,
    this.held,
    this.muted,
    this.speaker,
    this.direction,
    this.disconnectCause,
    this.connectDuration,
    this.totalDuration,
    this.creationTime,
    this.connectTime,
    this.creationTimeMillis,
    this.connectTimeMillis,
    this.audioCount,
    this.videoCount,
    this.remoteAudioCount,
    this.remoteVideoCount,
    this.remoteOfferer,
    this.media,
    this.provisionalMedia,
    this.lastStatusCode,
    this.lastReason,
    this.details,
    this.extras,
    this.simSlot,
    this.simSlot1,
    this.simSlot2,
  });

  /// Create from JSON map (Android event enrichment)
  /// 
  /// Handles the model mismatch by:
  /// 1. Accepting minimal fields from Android (10 fields)
  /// 2. Parsing URI for remoteNumber/remoteName if not provided
  /// 3. Setting creationTimeMillis for duration calculations
  factory TeleCall.fromMap(Map<String, dynamic> map) {
    // Parse remote number and name from URI if not explicitly provided
    String? remoteNumber;
    String? remoteName;

    if (map['remoteUri'] != null) {
      final remoteUri = map['remoteUri'] as String;
      
      // Pattern 1: SIP with display name
      // "John Doe" <sip:123@domain.com>
      final nameMatch = RegExp(r'"([^"]+)" <sip:([^@]+)@').firstMatch(remoteUri);
      if (nameMatch != null) {
        remoteName = nameMatch.group(1);
        remoteNumber = nameMatch.group(2);
      } else {
        // Pattern 2: Bare SIP
        // sip:123@domain.com
        final numberMatch = RegExp(r'sip:([^@]+)@').firstMatch(remoteUri);
        if (numberMatch != null) {
          remoteNumber = numberMatch.group(1);
        }
      }
      
      // Pattern 3: tel URI (checked regardless of above)
      // tel:+1234567890
      final telMatch = RegExp(r'tel:([^@]+)').firstMatch(remoteUri);
      if (telMatch != null) {
        remoteNumber = Uri.decodeComponent(telMatch.group(1)!);
      }
    }

    // Get current time for duration calculations (GAP-005: using UTC)
    final nowMillis = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;

    return TeleCall(
      // Identity
      id: map['id'] as int? ?? 0,
      callId: map['callId'] as String?,
      accountId: map['accountId'] as int?,
      callHashCode: map['callHashCode'] as String?,
      
      // Participants (use parsed values if not in map)
      localContact: map['localContact'] as String?,
      localUri: map['localUri'] as String?,
      remoteContact: map['remoteContact'] as String?,
      remoteUri: map['remoteUri'] as String?,
      remoteNumber: map['remoteNumber'] as String? ?? remoteNumber,
      remoteName: map['remoteName'] as String? ?? remoteName,
      
      // State
      state: map['state'] as String?,
      stateText: map['stateText'] as String?,
      held: map['held'] as bool?,
      muted: map['muted'] as bool?,
      speaker: map['speaker'] as bool?,
      direction: map['direction'] as String?,
      disconnectCause: map['disconnectCause'] as String?,
      
      // Timing
      connectDuration: map['connectDuration'] as int?,
      totalDuration: map['totalDuration'] as int?,
      creationTime: map['creationTime'] as String?,
      connectTime: map['connectTime'] as String?,
      creationTimeMillis: map['creationTimeMillis'] as int? ?? nowMillis,
      connectTimeMillis: map['connectTimeMillis'] as int?,
      
      // Media
      audioCount: map['audioCount'] as int?,
      videoCount: map['videoCount'] as int?,
      remoteAudioCount: map['remoteAudioCount'] as int?,
      remoteVideoCount: map['remoteVideoCount'] as int?,
      remoteOfferer: map['remoteOfferer'] as bool?,
      media: map['media'] as Map<String, dynamic>?,
      provisionalMedia: map['provisionalMedia'] as Map<String, dynamic>?,
      
      // Status
      lastStatusCode: map['lastStatusCode'] as int?,
      lastReason: map['lastReason'] as String?,
      details: map['details'] as Map<String, dynamic>?,
      extras: map['extras'] as Map<String, dynamic>?,
      
      // SIM
      simSlot: map['simSlot'] as int?,
      simSlot1: map['simSlot1'] as int?,
      simSlot2: map['simSlot2'] as int?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      // Identity
      'id': id,
      'callId': callId,
      'accountId': accountId,
      'callHashCode': callHashCode,
      
      // Participants
      'localContact': localContact,
      'localUri': localUri,
      'remoteContact': remoteContact,
      'remoteUri': remoteUri,
      'remoteNumber': remoteNumber,
      'remoteName': remoteName,
      
      // State
      'state': state,
      'stateText': stateText,
      'held': held,
      'muted': muted,
      'speaker': speaker,
      'direction': direction,
      'disconnectCause': disconnectCause,
      
      // Timing
      'connectDuration': connectDuration,
      'totalDuration': totalDuration,
      'creationTime': creationTime,
      'connectTime': connectTime,
      'creationTimeMillis': creationTimeMillis,
      'connectTimeMillis': connectTimeMillis,
      
      // Media
      'audioCount': audioCount,
      'videoCount': videoCount,
      'remoteAudioCount': remoteAudioCount,
      'remoteVideoCount': remoteVideoCount,
      'remoteOfferer': remoteOfferer,
      'media': media,
      'provisionalMedia': provisionalMedia,
      
      // Status
      'lastStatusCode': lastStatusCode,
      'lastReason': lastReason,
      'details': details,
      'extras': extras,
      
      // SIM
      'simSlot': simSlot,
      'simSlot1': simSlot1,
      'simSlot2': simSlot2,
    };
  }

  // ==================== Getters ====================
  
  int getId() => id;
  String? getCallId() => callId;
  int? getAccountId() => accountId;
  String? getRemoteNumber() => remoteNumber;
  String? getRemoteName() => remoteName;
  String? getState() => state;
  String? getStateText() => stateText;
  bool? isHeld() => held;
  bool? isMuted() => muted;
  bool? isSpeaker() => speaker;
  String? getDirection() => direction;
  bool? isTerminated() => state == 'PJSIP_INV_STATE_DISCONNECTED';
  bool? isIncoming() => direction == 'DIRECTION_INCOMING';
  bool? isOutgoing() => direction == 'DIRECTION_OUTGOING';

  // ==================== Duration Calculations (GAP-005: UTC) ====================
  
  /// Calculate total call duration from creation to current moment
  /// 
  /// Uses UTC time to avoid DST issues (GAP-005 resolution)
  int getTotalDuration() {
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final constructionTime = creationTimeMillis ?? 0;
    final offset = now - constructionTime;
    return (totalDuration ?? 0) + offset;
  }

  /// Calculate connected call duration
  /// 
  /// Returns stored connectDuration if call is terminated
  /// Returns elapsed time since creation for active calls
  int getConnectDuration() {
    // Return stored value if not connected or already terminated
    if (connectDuration == null ||
        connectDuration! < 0 ||
        isTerminated() == true) {
      return connectDuration ?? 0;
    }

    // Calculate elapsed time since connection
    final now = DateTime.now().toUtc().millisecondsSinceEpoch ~/ 1000;
    final constructionTime = creationTimeMillis ?? 0;
    final offset = now - constructionTime;
    return offset;
  }

  /// Get formatted total duration as MM:SS
  String getFormattedTotalDuration() => _formatTime(getTotalDuration());

  /// Get formatted connect duration as MM:SS
  String getFormattedConnectDuration() => _formatTime(getConnectDuration());

  /// Format seconds as MM:SS string
  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // ==================== Call Operations ====================
  
  /// Create a copy with updated state
  TeleCall copyWith({
    String? callId,
    int? accountId,
    String? callHashCode,
    String? localContact,
    String? localUri,
    String? remoteContact,
    String? remoteUri,
    String? remoteNumber,
    String? remoteName,
    String? state,
    String? stateText,
    bool? held,
    bool? muted,
    bool? speaker,
    String? direction,
    String? disconnectCause,
    int? connectDuration,
    int? totalDuration,
    String? creationTime,
    String? connectTime,
    int? creationTimeMillis,
    int? connectTimeMillis,
    int? audioCount,
    int? videoCount,
    int? remoteAudioCount,
    int? remoteVideoCount,
    bool? remoteOfferer,
    Map<String, dynamic>? media,
    Map<String, dynamic>? provisionalMedia,
    int? lastStatusCode,
    String? lastReason,
    Map<String, dynamic>? details,
    Map<String, dynamic>? extras,
    int? simSlot,
    int? simSlot1,
    int? simSlot2,
  }) {
    return TeleCall(
      id: id, // id is immutable
      callId: callId ?? this.callId,
      accountId: accountId ?? this.accountId,
      callHashCode: callHashCode ?? this.callHashCode,
      localContact: localContact ?? this.localContact,
      localUri: localUri ?? this.localUri,
      remoteContact: remoteContact ?? this.remoteContact,
      remoteUri: remoteUri ?? this.remoteUri,
      remoteNumber: remoteNumber ?? this.remoteNumber,
      remoteName: remoteName ?? this.remoteName,
      state: state ?? this.state,
      stateText: stateText ?? this.stateText,
      held: held ?? this.held,
      muted: muted ?? this.muted,
      speaker: speaker ?? this.speaker,
      direction: direction ?? this.direction,
      disconnectCause: disconnectCause ?? this.disconnectCause,
      connectDuration: connectDuration ?? this.connectDuration,
      totalDuration: totalDuration ?? this.totalDuration,
      creationTime: creationTime ?? this.creationTime,
      connectTime: connectTime ?? this.connectTime,
      creationTimeMillis: creationTimeMillis ?? this.creationTimeMillis,
      connectTimeMillis: connectTimeMillis ?? this.connectTimeMillis,
      audioCount: audioCount ?? this.audioCount,
      videoCount: videoCount ?? this.videoCount,
      remoteAudioCount: remoteAudioCount ?? this.remoteAudioCount,
      remoteVideoCount: remoteVideoCount ?? this.remoteVideoCount,
      remoteOfferer: remoteOfferer ?? this.remoteOfferer,
      media: media ?? this.media,
      provisionalMedia: provisionalMedia ?? this.provisionalMedia,
      lastStatusCode: lastStatusCode ?? this.lastStatusCode,
      lastReason: lastReason ?? this.lastReason,
      details: details ?? this.details,
      extras: extras ?? this.extras,
      simSlot: simSlot ?? this.simSlot,
      simSlot1: simSlot1 ?? this.simSlot1,
      simSlot2: simSlot2 ?? this.simSlot2,
    );
  }

  @override
  String toString() {
    return 'TeleCall(id: $id, remoteNumber: $remoteNumber, state: $state, direction: $direction)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TeleCall && 
        other.id == id &&
        other.callId == callId;
  }

  @override
  int get hashCode => Object.hash(id, callId);
}

/// Call direction constants
class CallDirection {
  static const String incoming = 'DIRECTION_INCOMING';
  static const String outgoing = 'DIRECTION_OUTGOING';
}

/// Call state constants (PJSIP)
class CallState {
  static const String null_ = 'PJSIP_INV_STATE_NULL';
  static const String calling = 'PJSIP_INV_STATE_CALLING';
  static const String incoming = 'PJSIP_INV_STATE_INCOMING';
  static const String early = 'PJSIP_INV_STATE_EARLY';
  static const String connecting = 'PJSIP_INV_STATE_CONNECTING';
  static const String confirmed = 'PJSIP_INV_STATE_CONFIRMED';
  static const String disconnected = 'PJSIP_INV_STATE_DISCONNECTED';
}
