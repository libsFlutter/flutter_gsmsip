class CallStatistics {
  final int totalCalls;
  final int incomingCalls;
  final int outgoingCalls;
  final int missedCalls;
  final int answeredCalls;
  final int rejectedCalls;
  final Duration totalCallDuration;
  final Duration averageCallDuration;
  final DateTime lastCallTime;
  final String mostCalledNumber;
  final int mostCalledCount;
  final Map<String, int> callCountByNumber;
  final Map<String, Duration> callDurationByNumber;
  final DateTime periodStart;
  final DateTime periodEnd;

  CallStatistics({
    required this.totalCalls,
    required this.incomingCalls,
    required this.outgoingCalls,
    required this.missedCalls,
    required this.answeredCalls,
    required this.rejectedCalls,
    required this.totalCallDuration,
    required this.averageCallDuration,
    required this.lastCallTime,
    required this.mostCalledNumber,
    required this.mostCalledCount,
    required this.callCountByNumber,
    required this.callDurationByNumber,
    required this.periodStart,
    required this.periodEnd,
  });

  CallStatistics copyWith({
    int? totalCalls,
    int? incomingCalls,
    int? outgoingCalls,
    int? missedCalls,
    int? answeredCalls,
    int? rejectedCalls,
    Duration? totalCallDuration,
    Duration? averageCallDuration,
    DateTime? lastCallTime,
    String? mostCalledNumber,
    int? mostCalledCount,
    Map<String, int>? callCountByNumber,
    Map<String, Duration>? callDurationByNumber,
    DateTime? periodStart,
    DateTime? periodEnd,
  }) {
    return CallStatistics(
      totalCalls: totalCalls ?? this.totalCalls,
      incomingCalls: incomingCalls ?? this.incomingCalls,
      outgoingCalls: outgoingCalls ?? this.outgoingCalls,
      missedCalls: missedCalls ?? this.missedCalls,
      answeredCalls: answeredCalls ?? this.answeredCalls,
      rejectedCalls: rejectedCalls ?? this.rejectedCalls,
      totalCallDuration: totalCallDuration ?? this.totalCallDuration,
      averageCallDuration: averageCallDuration ?? this.averageCallDuration,
      lastCallTime: lastCallTime ?? this.lastCallTime,
      mostCalledNumber: mostCalledNumber ?? this.mostCalledNumber,
      mostCalledCount: mostCalledCount ?? this.mostCalledCount,
      callCountByNumber: callCountByNumber ?? this.callCountByNumber,
      callDurationByNumber: callDurationByNumber ?? this.callDurationByNumber,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalCalls': totalCalls,
      'incomingCalls': incomingCalls,
      'outgoingCalls': outgoingCalls,
      'missedCalls': missedCalls,
      'answeredCalls': answeredCalls,
      'rejectedCalls': rejectedCalls,
      'totalCallDuration': totalCallDuration.inSeconds,
      'averageCallDuration': averageCallDuration.inSeconds,
      'lastCallTime': lastCallTime.toIso8601String(),
      'mostCalledNumber': mostCalledNumber,
      'mostCalledCount': mostCalledCount,
      'callCountByNumber': callCountByNumber,
      'callDurationByNumber': callDurationByNumber.map(
        (key, value) => MapEntry(key, value.inSeconds),
      ),
      'periodStart': periodStart.toIso8601String(),
      'periodEnd': periodEnd.toIso8601String(),
    };
  }

  factory CallStatistics.fromJson(Map<String, dynamic> json) {
    return CallStatistics(
      totalCalls: json['totalCalls'] ?? 0,
      incomingCalls: json['incomingCalls'] ?? 0,
      outgoingCalls: json['outgoingCalls'] ?? 0,
      missedCalls: json['missedCalls'] ?? 0,
      answeredCalls: json['answeredCalls'] ?? 0,
      rejectedCalls: json['rejectedCalls'] ?? 0,
      totalCallDuration: Duration(seconds: json['totalCallDuration'] ?? 0),
      averageCallDuration: Duration(seconds: json['averageCallDuration'] ?? 0),
      lastCallTime: DateTime.parse(json['lastCallTime'] ?? DateTime.now().toIso8601String()),
      mostCalledNumber: json['mostCalledNumber'] ?? '',
      mostCalledCount: json['mostCalledCount'] ?? 0,
      callCountByNumber: Map<String, int>.from(json['callCountByNumber'] ?? {}),
      callDurationByNumber: (json['callDurationByNumber'] as Map<String, dynamic>?)?.map(
        (key, value) => MapEntry(key, Duration(seconds: value as int)),
      ) ?? {},
      periodStart: DateTime.parse(json['periodStart'] ?? DateTime.now().toIso8601String()),
      periodEnd: DateTime.parse(json['periodEnd'] ?? DateTime.now().toIso8601String()),
    );
  }

  factory CallStatistics.empty() {
    final now = DateTime.now();
    return CallStatistics(
      totalCalls: 0,
      incomingCalls: 0,
      outgoingCalls: 0,
      missedCalls: 0,
      answeredCalls: 0,
      rejectedCalls: 0,
      totalCallDuration: Duration.zero,
      averageCallDuration: Duration.zero,
      lastCallTime: now,
      mostCalledNumber: '',
      mostCalledCount: 0,
      callCountByNumber: {},
      callDurationByNumber: {},
      periodStart: now,
      periodEnd: now,
    );
  }

  double get answerRate {
    if (incomingCalls == 0) return 0.0;
    return answeredCalls / incomingCalls;
  }

  double get rejectionRate {
    if (incomingCalls == 0) return 0.0;
    return rejectedCalls / incomingCalls;
  }

  Duration get totalIncomingDuration {
    // This would need to be calculated from actual call data
    return Duration.zero;
  }

  Duration get totalOutgoingDuration {
    // This would need to be calculated from actual call data
    return Duration.zero;
  }
} 