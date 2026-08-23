/// Flutter GSM SIP SMPP Library
///
/// SIP<->GSM voice-gateway bridging and SMPP SMS gateway. Depends on
/// `flutter_gsm` (GSM leg — modem/device types: `ModemDevice`,
/// `ModemCall`, `ModemRepository`, etc., import from
/// `package:flutter_gsm/flutter_gsm.dart`) and `flutter_nmsip` (SIP leg —
/// `Account`, `Call`, `FlutterSip2`, import from
/// `package:flutter_nmsip/flutter_nmsip.dart`). See
/// flows/sdd-flutter_gsm for the split rationale.
library flutter_gsmsip;

// Core - Error Handling
export 'src/core/error/exceptions.dart';
export 'src/core/error/failures.dart';

// Core - Utils
export 'src/core/utils/result.dart';
export 'src/core/utils/extensions.dart';
export 'src/core/utils/validators.dart';

// Core - Constants
export 'src/core/constants/app_constants.dart';
export 'src/core/constants/storage_keys.dart';

// Domain - Entities (excluding duplicates with models/)
// Modem-layer entities (ModemDevice, ModemCall, ModemGroupConfig,
// CarrierProfile) moved to flutter_gsm — import from
// package:flutter_gsm/flutter_gsm.dart instead.
export 'src/domain/entities/account.dart';
export 'src/domain/entities/account_registration.dart';
export 'src/domain/entities/call_routing.dart';
export 'src/domain/entities/dongle_config.dart';
export 'src/domain/entities/gateway_config.dart';
export 'src/domain/entities/gateway_status.dart';
export 'src/domain/entities/sip_account.dart';
export 'src/domain/entities/sip_call.dart';
export 'src/domain/entities/sip_event.dart';
// export 'src/domain/entities/sms_entity.dart';  // Duplicate SmsType with models/sms_message.dart
export 'src/domain/entities/voice_line_config.dart';

// Domain - Repositories (interfaces)
// ModemRepository moved to flutter_gsm.
export 'src/domain/repositories/dongle_repository.dart';
export 'src/domain/repositories/gateway_repository.dart';
export 'src/domain/repositories/sip_repository.dart';
export 'src/domain/repositories/sms_repository.dart';
export 'src/domain/repositories/voice_line_repository.dart';

// Domain - Use Cases
export 'src/domain/usecases/analytics_usecases.dart';
export 'src/domain/usecases/gateway_usecases.dart';
export 'src/domain/usecases/settings_usecases.dart';
export 'src/domain/usecases/sip_usecases.dart';

// Domain - Exceptions
// Modem exceptions moved to flutter_gsm.
export 'src/domain/exceptions/dongle_exceptions.dart';
export 'src/domain/exceptions/voice_line_exceptions.dart';

// Domain - Models
// at_command_result/modem_event/modem_state/network_mode/restart_mode
// moved to flutter_gsm.
export 'src/domain/models/device_info.dart';
export 'src/domain/models/dongle_interface_type.dart';
export 'src/domain/models/dongle_status.dart';
export 'src/domain/models/dongle_type.dart';
export 'src/domain/models/quality_level.dart';
export 'src/domain/models/resistance_measurements.dart';
export 'src/domain/models/test_method_result.dart';
export 'src/domain/models/voice_line_method.dart';
export 'src/domain/models/voice_line_method_status.dart';

// Data - Repositories (implementations)
// ModemRepositoryImpl moved to flutter_gsm.
export 'src/data/repositories/analytics_repository.dart';
export 'src/data/repositories/dongle_repository_impl.dart';
export 'src/data/repositories/gateway_repository_impl.dart';
export 'src/data/repositories/settings_repository.dart';
export 'src/data/repositories/sip_repository_impl.dart';
export 'src/data/repositories/voice_line_repository_impl.dart';

// Services
export 'src/services/sip_state_tracker.dart';

// Data - Models
export 'src/data/models/gateway_config_model.dart';
export 'src/data/models/sip_account_model.dart';
export 'src/data/models/sip_call_model.dart';
export 'src/data/models/sip_event_model.dart';

// Data - Datasources
export 'src/data/datasources/local_storage_datasource.dart';
export 'src/data/datasources/local/local_data_source.dart';
export 'src/data/datasources/remote/remote_data_source.dart';

// Services - Core API
// SipService (embedded PJSIP glue) and TelephonyService (Android-only
// Dart-side invention) removed — superseded by SipRepositoryImpl
// (flutter_nmsip-backed) and flutter_gsm's ModemRepository respectively.
export 'src/services/gateway_service.dart';
export 'src/services/sms_service.dart';
export 'src/services/smpp_service.dart';
export 'src/services/smpp_logger.dart';

// Models (preferred versions - no duplicates)
export 'src/models/smpp_config.dart';
// SmsMessage is exported from services/sms_service.dart
