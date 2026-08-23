/// SIP Account Registration Status
/// 
/// Tracks the registration state of a SIP account with the SIP server.
/// 
/// Source: sdd-account specification
/// Tasks: account-002, account-004
class AccountRegistration {
  /// Registration status (true = registered, false = not registered)
  final bool status;
  
  /// SIP status code (200 = OK, 401 = Unauthorized, etc.)
  final int? code;
  
  /// Human-readable reason for the status
  final String? reason;
  
  /// Registration expiration time in seconds
  final int? expiration;
  
  /// Retry-after hint in seconds (if registration failed)
  final int? retryAfter;

  const AccountRegistration({
    required this.status,
    this.code,
    this.reason,
    this.expiration,
    this.retryAfter,
  });

  /// Create from JSON map
  factory AccountRegistration.fromMap(Map<String, dynamic> map) {
    return AccountRegistration(
      status: map['status'] as bool? ?? false,
      code: map['code'] as int?,
      reason: map['reason'] as String?,
      expiration: map['expiration'] as int?,
      retryAfter: map['retryAfter'] as int?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toMap() {
    return {
      'status': status,
      'code': code,
      'reason': reason,
      'expiration': expiration,
      'retryAfter': retryAfter,
    };
  }

  /// Check if registration is active
  bool get isActive => status && code == 200;

  /// Check if registration failed due to authentication
  bool get isAuthenticationError => code == 401 || code == 403;

  /// Check if registration failed due to server error
  bool get isServerError => code != null && code! >= 500;

  /// Check if registration failed due to client error
  bool get isClientError => code != null && code! >= 400 && code! < 500;

  /// Get status text description
  String get statusText {
    if (code == null) return status ? 'Registered' : 'Not Registered';
    
    switch (code) {
      case 200:
        return 'OK';
      case 401:
        return 'Unauthorized';
      case 403:
        return 'Forbidden';
      case 404:
        return 'Not Found';
      case 408:
        return 'Request Timeout';
      case 503:
        return 'Service Unavailable';
      default:
        return reason ?? 'Unknown';
    }
  }

  @override
  String toString() => 'AccountRegistration(status: $status, code: $code, reason: $reason)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AccountRegistration &&
        other.status == status &&
        other.code == code &&
        other.reason == reason &&
        other.expiration == expiration &&
        other.retryAfter == retryAfter;
  }

  @override
  int get hashCode => Object.hash(status, code, reason, expiration, retryAfter);
}
