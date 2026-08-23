/// Storage keys for SharedPreferences
/// Centralized key constants for all persistent storage

class StorageKeys {
  // Privатный конструктор
  StorageKeys._();

  // === Gateway Configuration ===
  /// Gateway configuration (JSON serialized)
  static const String gatewayConfig = 'gateway_config';
  
  /// Gateway last state
  static const String gatewayLastState = 'gateway_last_state';
  
  /// Gateway auto-start preference
  static const String gatewayAutoStart = 'gateway_auto_start';

  // === SIP Configuration ===
  /// SIP username
  static const String sipUsername = 'sip_username';
  
  /// SIP password (encrypted)
  static const String sipPassword = 'sip_password';
  
  /// SIP server address
  static const String sipServer = 'sip_server';
  
  /// SIP server port
  static const String sipPort = 'sip_port';
  
  /// SIP transport protocol (UDP/TCP/TLS)
  static const String sipTransport = 'sip_transport';
  
  /// SIP registration timeout
  static const String sipRegistrationTimeout = 'sip_registration_timeout';
  
  /// SIP enable keep-alive
  static const String sipEnableKeepAlive = 'sip_enable_keep_alive';
  
  /// SIP keep-alive interval
  static const String sipKeepAliveInterval = 'sip_keep_alive_interval';

  // === SMPP Configuration ===
  /// SMPP server address
  static const String smppServer = 'smpp_server';
  
  /// SMPP server port
  static const String smppPort = 'smpp_port';
  
  /// SMPP system ID
  static const String smppSystemId = 'smpp_system_id';
  
  /// SMPP password
  static const String smppPassword = 'smpp_password';
  
  /// SMPP service type
  static const String smppServiceType = 'smpp_service_type';
  
  /// SMPP address range
  static const String smppAddressRange = 'smpp_address_range';

  // === Call Settings ===
  /// Enable auto-answer for GSM calls
  static const String callAutoAnswer = 'call_auto_answer';
  
  /// Call timeout in seconds
  static const String callTimeout = 'call_timeout';
  
  /// Enable call forwarding
  static const String callForwarding = 'call_forwarding';
  
  /// Call forwarding number
  static const String callForwardingNumber = 'call_forwarding_number';
  
  /// Enable call recording
  static const String callRecording = 'call_recording';
  
  /// Call recording path
  static const String callRecordingPath = 'call_recording_path';

  // === SMS Settings ===
  /// Enable SMS to SMPP routing
  static const String smsToSmpp = 'sms_to_smpp';
  
  /// Enable SMPP to SMS routing
  static const String smppToSms = 'smpp_to_sms';
  
  /// SMS center number
  static const String smsCenterNumber = 'sms_center_number';
  
  /// SMS delivery reports
  static const String smsDeliveryReports = 'sms_delivery_reports';

  // === Application Settings ===
  /// Application language
  static const String appLanguage = 'app_language';
  
  /// Theme mode (light/dark/system)
  static const String themeMode = 'app_theme_mode';
  
  /// Is first run
  static const String isFirstRun = 'is_first_run';
  
  /// Has completed onboarding
  static const String hasCompletedOnboarding = 'has_completed_onboarding';
  
  /// User agreed to terms
  static const String agreedToTerms = 'agreed_to_terms';
  
  /// User agreed to privacy policy
  static const String agreedToPrivacyPolicy = 'agreed_to_privacy_policy';

  // === Logging ===
  /// Error logs
  static const String errorLogs = 'error_logs';
  
  /// Application logs
  static const String appLogs = 'app_logs';
  
  /// Call logs
  static const String callLogs = 'call_logs';
  
  /// SMS logs
  static const String smsLogs = 'sms_logs';
  
  /// Maximum log entries
  static const String maxLogEntries = 'max_log_entries';
  
  /// Log level (DEBUG/INFO/WARNING/ERROR)
  static const String logLevel = 'log_level';
  
  /// Enable log streaming
  static const String enableLogStreaming = 'enable_log_streaming';

  // === Analytics ===
  /// Analytics enabled
  static const String analyticsEnabled = 'analytics_enabled';
  
  /// Analytics user ID
  static const String analyticsUserId = 'analytics_user_id';
  
  /// Analytics session ID
  static const String analyticsSessionId = 'analytics_session_id';
  
  /// Last analytics sync
  static const String lastAnalyticsSync = 'last_analytics_sync';

  // === Cache ===
  /// Gateway status cache
  static const String gatewayStatusCache = 'gateway_status_cache';
  
  /// Call history cache
  static const String callHistoryCache = 'call_history_cache';
  
  /// SMS history cache
  static const String smsHistoryCache = 'sms_history_cache';
  
  /// Contact cache
  static const String contactCache = 'contact_cache';
  
  /// Cache expiration time
  static const String cacheExpiration = 'cache_expiration';

  // === Security ===
  /// Encrypted master key
  static const String encryptedMasterKey = 'encrypted_master_key';
  
  /// Biometric enabled
  static const String biometricEnabled = 'biometric_enabled';
  
  /// PIN code (encrypted)
  static const String pinCode = 'pin_code';
  
  /// Auto-lock timeout
  static const String autoLockTimeout = 'auto_lock_timeout';
  
  /// Last auth time
  static const String lastAuthTime = 'last_auth_time';

  // === Network ===
  /// Preferred network type
  static const String preferredNetworkType = 'preferred_network_type';
  
  /// Use WiFi for SIP
  static const String useWifiForSip = 'use_wifi_for_sip';
  
  /// Use mobile data for SIP
  static const String useMobileDataForSip = 'use_mobile_data_for_sip';
  
  /// Network check interval
  static const String networkCheckInterval = 'network_check_interval';

  // === Notifications ===
  /// Notifications enabled
  static const String notificationsEnabled = 'notifications_enabled';
  
  /// Call notifications
  static const String callNotifications = 'call_notifications';
  
  /// SMS notifications
  static const String smsNotifications = 'sms_notifications';
  
  /// Gateway status notifications
  static const String gatewayStatusNotifications = 'gateway_status_notifications';
  
  /// Notification sound
  static const String notificationSound = 'notification_sound';
  
  /// Vibration enabled
  static const String vibrationEnabled = 'vibration_enabled';

  // === Statistics ===
  /// Total calls made
  static const String totalCallsMade = 'total_calls_made';
  
  /// Total calls received
  static const String totalCallsReceived = 'total_calls_received';
  
  /// Total SMS sent
  static const String totalSmsSent = 'total_sms_sent';
  
  /// Total SMS received
  static const String totalSmsReceived = 'total_sms_received';
  
  /// Gateway uptime
  static const String gatewayUptime = 'gateway_uptime';
  
  /// Last gateway start
  static const String lastGatewayStart = 'last_gateway_start';
  
  /// Last gateway stop
  static const String lastGatewayStop = 'last_gateway_stop';

  // === Debug ===
  /// Debug mode enabled
  static const String debugMode = 'debug_mode';
  
  /// Show test controls
  static const String showTestControls = 'show_test_controls';
  
  /// Mock SIP service
  static const String mockSipService = 'mock_sip_service';
  
  /// Mock telephony service
  static const String mockTelephonyService = 'mock_telephony_service';
  
  /// Force crash (for testing)
  static const String forceCrash = 'force_crash';
}
