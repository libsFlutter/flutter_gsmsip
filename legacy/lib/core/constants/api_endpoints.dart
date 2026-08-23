/// API endpoints and network constants
/// Centralized configuration for all external API calls

class ApiEndpoints {
  // Приватный конструктор
  ApiEndpoints._();

  // === Default Server Configuration ===
  /// Default SIP server address
  static const String defaultSipServer = '192.168.88.254';
  
  /// Default SIP server port
  static const int defaultSipPort = 5060;
  
  /// Default SMPP server address
  static const String defaultSmppServer = '192.168.88.254';
  
  /// Default SMPP server port
  static const int defaultSmppPort = 2775;

  // === SIP Endpoints ===
  /// SIP registration endpoint
  static const String sipRegister = 'sip:register';
  
  /// SIP invite endpoint
  static const String sipInvite = 'sip:invite';
  
  /// SIP bye endpoint
  static const String sipBye = 'sip:bye';
  
  /// SIP cancel endpoint
  static const String sipCancel = 'sip:cancel';
  
  /// SIP options endpoint
  static const String sipOptions = 'sip:options';
  
  /// SIP info endpoint (for DTMF)
  static const String sipInfo = 'sip:info';
  
  /// SIP subscribe endpoint
  static const String sipSubscribe = 'sip:subscribe';
  
  /// SIP notify endpoint
  static const String sipNotify = 'sip:notify';

  // === SMPP Endpoints ===
  /// SMPP bind_transceiver
  static const String smppBindTransceiver = 'bind_transceiver';
  
  /// SMPP bind_transmitter
  static const String smppBindTransmitter = 'bind_transmitter';
  
  /// SMPP bind_receiver
  static const String smppBindReceiver = 'bind_receiver';
  
  /// SMPP submit_sm
  static const String smppSubmitSm = 'submit_sm';
  
  /// SMPP deliver_sm
  static const String smppDeliverSm = 'deliver_sm';
  
  /// SMPP query_sm
  static const String smppQuerySm = 'query_sm';
  
  /// SMPP cancel_sm
  static const String smppCancelSm = 'cancel_sm';
  
  /// SMPP unbind
  static const String smppUnbind = 'unbind';
  
  /// SMPP enquire_link
  static const String smppEnquireLink = 'enquire_link';

  // === HTTP API Endpoints (for analytics, monitoring, etc.) ===
  /// Base API URL
  static const String baseUrl = 'http://192.168.88.254:8080/api';
  
  /// Health check endpoint
  static const String health = '/health';
  
  /// Version endpoint
  static const String version = '/version';
  
  /// Analytics endpoint
  static const String analytics = '/analytics';
  
  /// Logs endpoint
  static const String logs = '/logs';
  
  /// Configuration endpoint
  static const String config = '/config';
  
  /// Status endpoint
  static const String status = '/status';

  // === Gateway HTTP API ===
  /// Gateway start endpoint
  static const String gatewayStart = '/api/gateway/start';
  
  /// Gateway stop endpoint
  static const String gatewayStop = '/api/gateway/stop';
  
  /// Gateway status endpoint
  static const String gatewayStatus = '/api/gateway/status';
  
  /// Gateway config endpoint
  static const String gatewayConfig = '/api/gateway/config';
  
  /// Gateway statistics endpoint
  static const String gatewayStats = '/api/gateway/stats';

  // === Call API ===
  /// Call initiate endpoint
  static const String callInitiate = '/api/call/initiate';
  
  /// Call answer endpoint
  static const String callAnswer = '/api/call/answer';
  
  /// Call reject endpoint
  static const String callReject = '/api/call/reject';
  
  /// Call hangup endpoint
  static const String callHangup = '/api/call/hangup';
  
  /// Call hold endpoint
  static const String callHold = '/api/call/hold';
  
  /// Call resume endpoint
  static const String callResume = '/api/call/resume';
  
  /// Call mute endpoint
  static const String callMute = '/api/call/mute';
  
  /// Call unmute endpoint
  static const String callUnmute = '/api/call/unmute';
  
  /// Call transfer endpoint
  static const String callTransfer = '/api/call/transfer';
  
  /// Call history endpoint
  static const String callHistory = '/api/call/history';

  // === SMS API ===
  /// SMS send endpoint
  static const String smsSend = '/api/sms/send';
  
  /// SMS received endpoint
  static const String smsReceived = '/api/sms/received';
  
  /// SMS history endpoint
  static const String smsHistory = '/api/sms/history';
  
  /// SMS delivery report endpoint
  static const String smsDeliveryReport = '/api/sms/delivery-report';

  // === Authentication API ===
  /// Login endpoint
  static const String authLogin = '/api/auth/login';
  
  /// Logout endpoint
  static const String authLogout = '/api/auth/logout';
  
  /// Refresh token endpoint
  static const String authRefresh = '/api/auth/refresh';
  
  /// Change password endpoint
  static const String authChangePassword = '/api/auth/change-password';
  
  /// Reset password endpoint
  static const String authResetPassword = '/api/auth/reset-password';

  // === WebSocket Endpoints ===
  /// WebSocket URL for real-time events
  static const String websocketUrl = 'ws://192.168.88.254:8080/ws';
  
  /// WebSocket events channel
  static const String wsEvents = 'events';
  
  /// WebSocket status channel
  static const String wsStatus = 'status';
  
  /// WebSocket logs channel
  static const String wsLogs = 'logs';

  // === Timeout Configuration ===
  /// Connection timeout in milliseconds
  static const int connectionTimeoutMs = 30000;
  
  /// Read timeout in milliseconds
  static const int readTimeoutMs = 30000;
  
  /// Write timeout in milliseconds
  static const int writeTimeoutMs = 30000;
  
  /// SIP registration timeout in seconds
  static const int sipRegistrationTimeoutSec = 3600;
  
  /// SMPP bind timeout in milliseconds
  static const int smppBindTimeoutMs = 10000;
  
  /// SMPP response timeout in milliseconds
  static const int smppResponseTimeoutMs = 30000;

  // === Retry Configuration ===
  /// Maximum retry attempts
  static const int maxRetries = 3;
  
  /// Initial retry delay in milliseconds
  static const int initialRetryDelayMs = 1000;
  
  /// Maximum retry delay in milliseconds
  static const int maxRetryDelayMs = 30000;
  
  /// Retry backoff multiplier
  static const double retryBackoffMultiplier = 2.0;

  // === HTTP Headers ===
  /// Content-Type header
  static const String contentTypeHeader = 'Content-Type';
  
  /// Content-Type JSON value
  static const String contentTypeJson = 'application/json';
  
  /// Content-Type form value
  static const String contentTypeForm = 'application/x-www-form-urlencoded';
  
  /// Authorization header
  static const String authorizationHeader = 'Authorization';
  
  /// Bearer token prefix
  static const String bearerPrefix = 'Bearer ';
  
  /// Accept header
  static const String acceptHeader = 'Accept';
  
  /// User-Agent header
  static const String userAgentHeader = 'User-Agent';
  
  /// X-Request-ID header
  static const String requestIdHeader = 'X-Request-ID';
  
  /// X-Device-ID header
  static const String deviceIdHeader = 'X-Device-ID';

  // === Response Codes ===
  /// Success
  static const int httpOk = 200;
  
  /// Created
  static const int httpCreated = 201;
  
  /// No content
  static const int httpNoContent = 204;
  
  /// Bad request
  static const int httpBadRequest = 400;
  
  /// Unauthorized
  static const int httpUnauthorized = 401;
  
  /// Forbidden
  static const int httpForbidden = 403;
  
  /// Not found
  static const int httpNotFound = 404;
  
  /// Method not allowed
  static const int httpMethodNotAllowed = 405;
  
  /// Conflict
  static const int httpConflict = 409;
  
  /// Internal server error
  static const int httpInternalServerError = 500;
  
  /// Bad gateway
  static const int httpBadGateway = 502;
  
  /// Service unavailable
  static const int httpServiceUnavailable = 503;
  
  /// Gateway timeout
  static const int httpGatewayTimeout = 504;

  // === SIP Response Codes ===
  /// Trying
  static const int sipTrying = 100;
  
  /// Ringing
  static const int sipRinging = 180;
  
  /// Call is being forwarded
  static const int sipCallForwarded = 181;
  
  /// OK
  static const int sipOk = 200;
  
  /// Multiple choices
  static const int sipMultipleChoices = 300;
  
  /// Moved permanently
  static const int sipMovedPermanently = 301;
  
  /// Moved temporarily
  static const int sipMovedTemporarily = 302;
  
  /// Bad request
  static const int sipBadRequest = 400;
  
  /// Unauthorized
  static const int sipUnauthorized = 401;
  
  /// Forbidden
  static const int sipForbidden = 403;
  
  /// Not found
  static const int sipNotFound = 404;
  
  /// Method not allowed
  static const int sipMethodNotAllowed = 405;
  
  /// Request timeout
  static const int sipRequestTimeout = 408;
  
  /// Conflict
  static const int sipConflict = 409;
  
  /// Internal server error
  static const int sipInternalServerError = 500;
  
  /// Not implemented
  static const int sipNotImplemented = 501;
  
  /// Service unavailable
  static const int sipServiceUnavailable = 503;
}
