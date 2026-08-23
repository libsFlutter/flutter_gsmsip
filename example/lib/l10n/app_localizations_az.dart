// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Azerbaijani (`az`).
class AppLocalizationsAz extends AppLocalizations {
  AppLocalizationsAz([String locale = 'az']) : super(locale);

  @override
  String get appTitle => 'GOSTsimbox Gateway';

  @override
  String get configureSipCredentials => 'SIP məlumatlarınızı konfiqurasiya edin';

  @override
  String get sipUsername => 'SIP İstifadəçi Adı';

  @override
  String get sipPassword => 'SIP Şifrəsi';

  @override
  String get sipServer => 'SIP Server';

  @override
  String get sipPort => 'SIP Portu';

  @override
  String get connect => 'Qoşul';

  @override
  String get rememberCredentials => 'Məlumatları yadda saxla və avtomatik daxil ol';

  @override
  String get pleaseEnterSipUsername => 'Zəhmət olmasa SIP istifadəçi adını daxil edin';

  @override
  String get pleaseEnterSipPassword => 'Zəhmət olmasa SIP şifrəsini daxil edin';

  @override
  String get pleaseEnterSipServer => 'Zəhmət olmasa SIP serverini daxil edin';

  @override
  String get pleaseEnterSipPort => 'Zəhmət olmasa SIP portunu daxil edin';

  @override
  String get pleaseEnterValidPort => 'Zəhmət olmasa düzgün port nömrəsi daxil edin';

  @override
  String get authenticationFailed => 'Autentifikasiya uğursuz oldu';

  @override
  String get gatewayStatus => 'Gateway Statusu';

  @override
  String get sipConnection => 'SIP Bağlantısı';

  @override
  String get gsmConnection => 'GSM Bağlantısı';

  @override
  String get activeCalls => 'Aktiv Zənglər';

  @override
  String get registered => 'Qeydiyyatdan keçdi';

  @override
  String get disconnected => 'Bağlantı kəsildi';

  @override
  String get connected => 'Bağlandı';

  @override
  String get noCalls => 'Zəng yoxdur';

  @override
  String get oneActive => '1 Aktiv';

  @override
  String get gatewayControls => 'Gateway İdarəetməsi';

  @override
  String get startGateway => 'Gateway-i Başlat';

  @override
  String get stopGateway => 'Gateway-i Dayandır';

  @override
  String get endCall => 'Zəngi Bitir';

  @override
  String get recentLogs => 'Son Loglar';

  @override
  String get viewAll => 'Hamısına Bax';

  @override
  String get noLogsAvailable => 'Log mövcud deyil';

  @override
  String get gatewayLogsWillAppearHere => 'Gateway logları burada görünəcək';

  @override
  String get testControls => 'Test İdarəetməsi';

  @override
  String get testSipCall => 'SIP Zəngini Test Et';

  @override
  String get testGsmCall => 'GSM Zəngini Test Et';

  @override
  String get settings => 'Tənzimləmələr';

  @override
  String get sipConfiguration => 'SIP Konfiqurasiyası';

  @override
  String get gatewayOptions => 'Gateway Seçimləri';

  @override
  String get autoStartGateway => 'Gateway-i Avtomatik Başlat';

  @override
  String get autoStartGatewayDesc => 'Tətbiq açılanda gateway-i avtomatik başlat';

  @override
  String get replaceDefaultDialer => 'Standart Dialer-ı Dəyişdir';

  @override
  String get replaceDefaultDialerDesc => 'Sistem dialer-ını gateway dialer-ı ilə dəyişdir';

  @override
  String get enablePermissions => 'İcazələri Aktivləşdir';

  @override
  String get enablePermissionsDesc => 'Telefoniya üçün yüksək icazələr tələb et';

  @override
  String get rememberCredentialsSettings => 'Məlumatları Yadda Saxla';

  @override
  String get rememberCredentialsDesc => 'Məlumatları saxla və avtomatik daxil ol';

  @override
  String get saveSettings => 'Tənzimləmələri Saxla';

  @override
  String get settingsSavedSuccessfully => 'Tənzimləmələr uğurla saxlanıldı';

  @override
  String get errorSavingSettings => 'Tənzimləmələri saxlamaqda xəta';

  @override
  String get gatewayLogs => 'Gateway Logları';

  @override
  String get searchLogs => 'Logları axtar...';

  @override
  String get clearLogs => 'Logları Təmizlə';

  @override
  String get clearLogsConfirmation => 'Bütün logları təmizləmək istədiyinizə əminsiniz? Bu əməliyyat geri alına bilməz.';

  @override
  String get cancel => 'Ləğv et';

  @override
  String get clear => 'Təmizlə';

  @override
  String get logsClearedSuccessfully => 'Loglar uğurla təmizləndi';

  @override
  String get errorClearingLogs => 'Logları təmizləməkdə xəta';

  @override
  String get errorLoadingLogs => 'Logları yükləməkdə xəta';

  @override
  String get stopped => 'Dayandırıldı';

  @override
  String get starting => 'Başlanır...';

  @override
  String get running => 'İşləyir';

  @override
  String get runningRegistered => 'İşləyir (Qeydiyyatdan keçdi)';

  @override
  String get runningConnecting => 'İşləyir (Qoşulur)';

  @override
  String get runningDisconnected => 'İşləyir (Bağlantı kəsildi)';

  @override
  String get error => 'Xəta';

  @override
  String get connecting => 'Qoşulur...';

  @override
  String get registeredStatus => 'Qeydiyyatdan keçdi';

  @override
  String get callInProgress => 'Zəng davam edir';

  @override
  String get unknownError => 'Naməlum xəta';

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
