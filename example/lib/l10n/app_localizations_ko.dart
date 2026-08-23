// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'GOSTsimbox 게이트웨이';

  @override
  String get configureSipCredentials => 'SIP 인증 정보를 구성하세요';

  @override
  String get sipUsername => 'SIP 사용자명';

  @override
  String get sipPassword => 'SIP 비밀번호';

  @override
  String get sipServer => 'SIP 서버';

  @override
  String get sipPort => 'SIP 포트';

  @override
  String get connect => '연결';

  @override
  String get rememberCredentials => '인증 정보를 기억하고 자동 로그인';

  @override
  String get pleaseEnterSipUsername => 'SIP 사용자명을 입력하세요';

  @override
  String get pleaseEnterSipPassword => 'SIP 비밀번호를 입력하세요';

  @override
  String get pleaseEnterSipServer => 'SIP 서버를 입력하세요';

  @override
  String get pleaseEnterSipPort => 'SIP 포트를 입력하세요';

  @override
  String get pleaseEnterValidPort => '유효한 포트 번호를 입력하세요';

  @override
  String get authenticationFailed => '인증 실패';

  @override
  String get gatewayStatus => '게이트웨이 상태';

  @override
  String get sipConnection => 'SIP 연결';

  @override
  String get gsmConnection => 'GSM 연결';

  @override
  String get activeCalls => '활성 통화';

  @override
  String get registered => '등록됨';

  @override
  String get disconnected => '연결 해제됨';

  @override
  String get connected => '연결됨';

  @override
  String get noCalls => '통화 없음';

  @override
  String get oneActive => '1개 활성';

  @override
  String get gatewayControls => '게이트웨이 제어';

  @override
  String get startGateway => '게이트웨이 시작';

  @override
  String get stopGateway => '게이트웨이 중지';

  @override
  String get endCall => '통화 종료';

  @override
  String get recentLogs => '최근 로그';

  @override
  String get viewAll => '모두 보기';

  @override
  String get noLogsAvailable => '사용 가능한 로그가 없습니다';

  @override
  String get gatewayLogsWillAppearHere => '게이트웨이 로그가 여기에 표시됩니다';

  @override
  String get testControls => '테스트 제어';

  @override
  String get testSipCall => 'SIP 통화 테스트';

  @override
  String get testGsmCall => 'GSM 통화 테스트';

  @override
  String get settings => '설정';

  @override
  String get sipConfiguration => 'SIP 구성';

  @override
  String get gatewayOptions => '게이트웨이 옵션';

  @override
  String get autoStartGateway => '게이트웨이 자동 시작';

  @override
  String get autoStartGatewayDesc => '앱 시작 시 게이트웨이를 자동으로 시작';

  @override
  String get replaceDefaultDialer => '기본 다이얼러 교체';

  @override
  String get replaceDefaultDialerDesc => '시스템 다이얼러를 게이트웨이 다이얼러로 교체';

  @override
  String get enablePermissions => '권한 활성화';

  @override
  String get enablePermissionsDesc => '전화 기능을 위한 고급 권한 요청';

  @override
  String get rememberCredentialsSettings => '인증 정보 기억';

  @override
  String get rememberCredentialsDesc => '인증 정보를 저장하고 자동 로그인';

  @override
  String get saveSettings => '설정 저장';

  @override
  String get settingsSavedSuccessfully => '설정이 성공적으로 저장되었습니다';

  @override
  String get errorSavingSettings => '설정 저장 중 오류가 발생했습니다';

  @override
  String get gatewayLogs => '게이트웨이 로그';

  @override
  String get searchLogs => '로그 검색...';

  @override
  String get clearLogs => '로그 지우기';

  @override
  String get clearLogsConfirmation => '모든 로그를 지우시겠습니까? 이 작업은 취소할 수 없습니다.';

  @override
  String get cancel => '취소';

  @override
  String get clear => '지우기';

  @override
  String get logsClearedSuccessfully => '로그가 성공적으로 지워졌습니다';

  @override
  String get errorClearingLogs => '로그 지우기 중 오류가 발생했습니다';

  @override
  String get errorLoadingLogs => '로그 로드 중 오류가 발생했습니다';

  @override
  String get stopped => '중지됨';

  @override
  String get starting => '시작 중...';

  @override
  String get running => '실행 중';

  @override
  String get runningRegistered => '실행 중 (등록됨)';

  @override
  String get runningConnecting => '실행 중 (연결 중)';

  @override
  String get runningDisconnected => '실행 중 (연결 해제됨)';

  @override
  String get error => '오류';

  @override
  String get connecting => '연결 중...';

  @override
  String get registeredStatus => '등록됨';

  @override
  String get callInProgress => '통화 진행 중';

  @override
  String get unknownError => '알 수 없는 오류';

  @override
  String get smppConfiguration => 'SMPP Configuration';

  @override
  String get smppServerHost => 'SMPP Server Host';

  @override
  String get smppPort => 'SMPP Port';

  @override
  String get systemId => 'System ID';

  @override
  String get systemPassword => 'System Password';

  @override
  String get systemType => 'System Type';

  @override
  String get connectionStatus => 'Connection Status';

  @override
  String get bound => 'Bound';

  @override
  String get disconnect => 'Disconnect';

  @override
  String get testConnection => 'Test Connection';

  @override
  String get saveConfiguration => 'Save Configuration';

  @override
  String get resetConfiguration => 'Reset Configuration';

  @override
  String get advancedSettings => 'Advanced Settings';

  @override
  String get enableDeliveryReceipts => 'Enable Delivery Receipts';

  @override
  String get enableDeliveryReceiptsDesc => 'Receive delivery confirmations for sent messages';

  @override
  String get enableLogging => 'Enable Logging';

  @override
  String get enableLoggingDesc => 'Log SMPP protocol messages for debugging';

  @override
  String get configurationInfo => 'Configuration Info';

  @override
  String get protocolVersion => 'Protocol Version';

  @override
  String get defaultPort => 'Default Port';

  @override
  String get connectionType => 'Connection Type';

  @override
  String get keepAlive => 'Keep-alive';

  @override
  String get reconnectInterval => 'Reconnect Interval';

  @override
  String get pleaseEnterSmppHost => 'Please enter SMPP server host';

  @override
  String get pleaseEnterPort => 'Please enter port number';

  @override
  String get pleaseEnterSystemId => 'Please enter System ID';

  @override
  String get pleaseEnterPassword => 'Please enter password';

  @override
  String get configurationSaved => 'Configuration saved successfully';

  @override
  String get errorSavingConfiguration => 'Error saving configuration';

  @override
  String get connectionTestSuccess => 'Connection test successful';

  @override
  String get connectionTestFailed => 'Connection test failed';

  @override
  String get showPassword => 'Show Password';

  @override
  String get hidePassword => 'Hide Password';

  @override
  String get transceiver => 'Transceiver';

  @override
  String get transmitter => 'Transmitter';

  @override
  String get receiver => 'Receiver';

  @override
  String get seconds => 'seconds';

  @override
  String get callHistory => 'Call History';

  @override
  String get loadingCalls => 'Loading calls...';

  @override
  String get errorLoadingCalls => 'Error loading calls';

  @override
  String get noCallsFound => 'No calls found';

  @override
  String get callHistoryWillAppearHere => 'Your call history will appear here';

  @override
  String get all => 'All';

  @override
  String get incoming => 'Incoming';

  @override
  String get outgoing => 'Outgoing';

  @override
  String get missed => 'Missed';

  @override
  String get completed => 'Completed';

  @override
  String get rejected => 'Rejected';

  @override
  String get unknown => 'Unknown';

  @override
  String get makeCall => 'Make Call';

  @override
  String get phoneNumber => 'Phone Number';

  @override
  String get enterPhoneNumber => 'Enter phone number';

  @override
  String get callInformation => 'Call Information';

  @override
  String get from => 'From';

  @override
  String get to => 'To';

  @override
  String get duration => 'Duration';

  @override
  String get status => 'Status';

  @override
  String get lineId => 'Line ID';

  @override
  String get recording => 'Recording';

  @override
  String get filterCalls => 'Filter Calls';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get apply => 'Apply';

  @override
  String get calling => 'Calling';

  @override
  String get openingSmsTo => 'Opening SMS to';

  @override
  String get connectionError_1 => 'Connection error.';

  @override
  String get connectionError_2 => 'Connection error.';

  @override
  String get connectionError_3 => 'Connection error.';

  @override
  String get connectionError_4 => 'Connection error.';

  @override
  String get connectionError_5 => 'Connection error.';

  @override
  String get connectionError_6 => 'Connection error.';

  @override
  String get connectionError_7 => 'Connection error.';

  @override
  String get connectionError_8 => 'Connection error.';

  @override
  String get connectionError_9 => 'Connection error.';

  @override
  String get connectionError_10 => 'Connection error.';

  @override
  String get setupError_1 => 'Setup error.';

  @override
  String get setupError_2 => 'Setup error.';

  @override
  String get setupError_3 => 'Setup error.';

  @override
  String get setupError_4 => 'Setup error.';

  @override
  String get setupError_5 => 'Setup error.';

  @override
  String get setupError_6 => 'Setup error.';

  @override
  String get setupError_7 => 'Setup error.';

  @override
  String get setupError_8 => 'Setup error.';

  @override
  String get successMessage_1 => 'Success!';

  @override
  String get successMessage_2 => 'Success!';

  @override
  String get successMessage_3 => 'Success!';

  @override
  String get successMessage_4 => 'Success!';

  @override
  String get successMessage_5 => 'Success!';

  @override
  String get successMessage_6 => 'Success!';

  @override
  String get successMessage_7 => 'Success!';

  @override
  String get successMessage_8 => 'Success!';

  @override
  String get loadingMessage_1 => 'Loading...';

  @override
  String get loadingMessage_2 => 'Loading...';

  @override
  String get loadingMessage_3 => 'Loading...';

  @override
  String get loadingMessage_4 => 'Loading...';

  @override
  String get loadingMessage_5 => 'Loading...';

  @override
  String get loadingMessage_6 => 'Loading...';

  @override
  String get loadingMessage_7 => 'Loading...';

  @override
  String get loadingMessage_8 => 'Loading...';

  @override
  String get loadingMessage_9 => 'Loading...';

  @override
  String get loadingMessage_10 => 'Loading...';

  @override
  String get loadingMessage_11 => 'Loading...';

  @override
  String get loadingMessage_12 => 'Loading...';

  @override
  String get loadingMessage_13 => 'Loading...';

  @override
  String get loadingMessage_14 => 'Loading...';

  @override
  String get loadingMessage_15 => 'Loading...';

  @override
  String get loadingMessage_16 => 'Loading...';

  @override
  String get loadingMessage_17 => 'Loading...';

  @override
  String get loadingMessage_18 => 'Loading...';

  @override
  String get motivationalMessage_1 => 'You\'re doing great!';

  @override
  String get motivationalMessage_2 => 'You\'re doing great!';

  @override
  String get motivationalMessage_3 => 'You\'re doing great!';

  @override
  String get motivationalMessage_4 => 'You\'re doing great!';

  @override
  String get motivationalMessage_5 => 'You\'re doing great!';

  @override
  String get motivationalMessage_6 => 'You\'re doing great!';

  @override
  String get motivationalMessage_7 => 'You\'re doing great!';

  @override
  String get motivationalMessage_8 => 'You\'re doing great!';

  @override
  String get motivationalMessage_9 => 'You\'re doing great!';

  @override
  String get motivationalMessage_10 => 'You\'re doing great!';
}
