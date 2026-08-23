class ActiveCall {
  final String id;
  final String direction; // incoming/outgoing
  final String fromNumber;
  final String toNumber;
  final DateTime startTime;
  final Duration duration;
  final String status; // ringing/connected/ended
  final String lineId;
  final bool isSipSpeakerEnabled;
  final bool isGsmSpeakerEnabled;
  final bool isSipMicrophoneEnabled;
  final bool isGsmMicrophoneEnabled;
  final bool isRecording;
  final String recordingPath;
  final double sipMos;
  final double gsmMos;
  final double sipJitter;
  final double gsmJitter;
  final double sipLatency;
  final double gsmLatency;

  ActiveCall({
    required this.id,
    required this.direction,
    required this.fromNumber,
    required this.toNumber,
    required this.startTime,
    required this.duration,
    required this.status,
    required this.lineId,
    required this.isSipSpeakerEnabled,
    required this.isGsmSpeakerEnabled,
    required this.isSipMicrophoneEnabled,
    required this.isGsmMicrophoneEnabled,
    required this.isRecording,
    required this.recordingPath,
    required this.sipMos,
    required this.gsmMos,
    required this.sipJitter,
    required this.gsmJitter,
    required this.sipLatency,
    required this.gsmLatency,
  });

  factory ActiveCall.fromJson(Map<String, dynamic> json) {
    return ActiveCall(
      id: json['id'] ?? '',
      direction: json['direction'] ?? 'outgoing',
      fromNumber: json['fromNumber'] ?? '',
      toNumber: json['toNumber'] ?? '',
      startTime: DateTime.parse(json['startTime'] ?? DateTime.now().toIso8601String()),
      duration: Duration(seconds: json['durationSeconds'] ?? 0),
      status: json['status'] ?? 'ringing',
      lineId: json['lineId'] ?? '',
      isSipSpeakerEnabled: json['isSipSpeakerEnabled'] ?? false,
      isGsmSpeakerEnabled: json['isGsmSpeakerEnabled'] ?? false,
      isSipMicrophoneEnabled: json['isSipMicrophoneEnabled'] ?? false,
      isGsmMicrophoneEnabled: json['isGsmMicrophoneEnabled'] ?? false,
      isRecording: json['isRecording'] ?? false,
      recordingPath: json['recordingPath'] ?? '',
      sipMos: (json['sipMos'] ?? 0.0).toDouble(),
      gsmMos: (json['gsmMos'] ?? 0.0).toDouble(),
      sipJitter: (json['sipJitter'] ?? 0.0).toDouble(),
      gsmJitter: (json['gsmJitter'] ?? 0.0).toDouble(),
      sipLatency: (json['sipLatency'] ?? 0.0).toDouble(),
      gsmLatency: (json['gsmLatency'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'direction': direction,
      'fromNumber': fromNumber,
      'toNumber': toNumber,
      'startTime': startTime.toIso8601String(),
      'durationSeconds': duration.inSeconds,
      'status': status,
      'lineId': lineId,
      'isSipSpeakerEnabled': isSipSpeakerEnabled,
      'isGsmSpeakerEnabled': isGsmSpeakerEnabled,
      'isSipMicrophoneEnabled': isSipMicrophoneEnabled,
      'isGsmMicrophoneEnabled': isGsmMicrophoneEnabled,
      'isRecording': isRecording,
      'recordingPath': recordingPath,
      'sipMos': sipMos,
      'gsmMos': gsmMos,
      'sipJitter': sipJitter,
      'gsmJitter': gsmJitter,
      'sipLatency': sipLatency,
      'gsmLatency': gsmLatency,
    };
  }

  ActiveCall copyWith({
    String? id,
    String? direction,
    String? fromNumber,
    String? toNumber,
    DateTime? startTime,
    Duration? duration,
    String? status,
    String? lineId,
    bool? isSipSpeakerEnabled,
    bool? isGsmSpeakerEnabled,
    bool? isSipMicrophoneEnabled,
    bool? isGsmMicrophoneEnabled,
    bool? isRecording,
    String? recordingPath,
    double? sipMos,
    double? gsmMos,
    double? sipJitter,
    double? gsmJitter,
    double? sipLatency,
    double? gsmLatency,
  }) {
    return ActiveCall(
      id: id ?? this.id,
      direction: direction ?? this.direction,
      fromNumber: fromNumber ?? this.fromNumber,
      toNumber: toNumber ?? this.toNumber,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      status: status ?? this.status,
      lineId: lineId ?? this.lineId,
      isSipSpeakerEnabled: isSipSpeakerEnabled ?? this.isSipSpeakerEnabled,
      isGsmSpeakerEnabled: isGsmSpeakerEnabled ?? this.isGsmSpeakerEnabled,
      isSipMicrophoneEnabled: isSipMicrophoneEnabled ?? this.isSipMicrophoneEnabled,
      isGsmMicrophoneEnabled: isGsmMicrophoneEnabled ?? this.isGsmMicrophoneEnabled,
      isRecording: isRecording ?? this.isRecording,
      recordingPath: recordingPath ?? this.recordingPath,
      sipMos: sipMos ?? this.sipMos,
      gsmMos: gsmMos ?? this.gsmMos,
      sipJitter: sipJitter ?? this.sipJitter,
      gsmJitter: gsmJitter ?? this.gsmJitter,
      sipLatency: sipLatency ?? this.sipLatency,
      gsmLatency: gsmLatency ?? this.gsmLatency,
    );
  }
} 