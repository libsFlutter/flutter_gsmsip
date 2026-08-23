// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Malay (`ms`).
class AppLocalizationsMs extends AppLocalizations {
  AppLocalizationsMs([String locale = 'ms']) : super(locale);

  @override
  String get appTitle => 'Gerbang GOSTsimbox';

  @override
  String get configureSipCredentials => 'Konfigurasi kredensial SIP anda';

  @override
  String get sipUsername => 'Nama Pengguna SIP';

  @override
  String get sipPassword => 'Kata Laluan SIP';

  @override
  String get sipServer => 'Pelayan SIP';

  @override
  String get sipPort => 'Port SIP';

  @override
  String get connect => 'Sambung';

  @override
  String get rememberCredentials => 'Ingat kredensial dan log masuk automatik';

  @override
  String get pleaseEnterSipUsername => 'Sila masukkan nama pengguna SIP';

  @override
  String get pleaseEnterSipPassword => 'Sila masukkan kata laluan SIP';

  @override
  String get pleaseEnterSipServer => 'Sila masukkan pelayan SIP';

  @override
  String get pleaseEnterSipPort => 'Sila masukkan port SIP';

  @override
  String get pleaseEnterValidPort => 'Sila masukkan nombor port yang sah';

  @override
  String get authenticationFailed => 'Pengesahan gagal';

  @override
  String get gatewayStatus => 'Status Gerbang';

  @override
  String get sipConnection => 'Sambungan SIP';

  @override
  String get gsmConnection => 'Sambungan GSM';

  @override
  String get activeCalls => 'Panggilan Aktif';

  @override
  String get registered => 'Berdaftar';

  @override
  String get disconnected => 'Terputus';

  @override
  String get connected => 'Disambungkan';

  @override
  String get noCalls => 'Tiada Panggilan';

  @override
  String get oneActive => '1 Aktif';

  @override
  String get gatewayControls => 'Kawalan Gerbang';

  @override
  String get startGateway => 'Mulakan Gerbang';

  @override
  String get stopGateway => 'Hentikan Gerbang';

  @override
  String get endCall => 'Tamatkan Panggilan';

  @override
  String get recentLogs => 'Log Terkini';

  @override
  String get viewAll => 'Lihat Semua';

  @override
  String get noLogsAvailable => 'Tiada log tersedia';

  @override
  String get gatewayLogsWillAppearHere => 'Log gerbang akan muncul di sini';

  @override
  String get testControls => 'Kawalan Ujian';

  @override
  String get testSipCall => 'Uji Panggilan SIP';

  @override
  String get testGsmCall => 'Uji Panggilan GSM';

  @override
  String get settings => 'Tetapan';

  @override
  String get sipConfiguration => 'Konfigurasi SIP';

  @override
  String get gatewayOptions => 'Pilihan Gerbang';

  @override
  String get autoStartGateway => 'Mulakan Gerbang Secara Automatik';

  @override
  String get autoStartGatewayDesc => 'Mulakan gerbang secara automatik apabila aplikasi dibuka';

  @override
  String get replaceDefaultDialer => 'Ganti Pemanggil Lalai';

  @override
  String get replaceDefaultDialerDesc => 'Ganti pemanggil sistem dengan pemanggil gerbang';

  @override
  String get enablePermissions => 'Dayakan Kebenaran';

  @override
  String get enablePermissionsDesc => 'Minta kebenaran tinggi untuk telefon';

  @override
  String get rememberCredentialsSettings => 'Ingat Kredensial';

  @override
  String get rememberCredentialsDesc => 'Simpan kredensial dan log masuk automatik';

  @override
  String get saveSettings => 'Simpan Tetapan';

  @override
  String get settingsSavedSuccessfully => 'Tetapan berjaya disimpan';

  @override
  String get errorSavingSettings => 'Ralat menyimpan tetapan';

  @override
  String get gatewayLogs => 'Log Gerbang';

  @override
  String get searchLogs => 'Cari log...';

  @override
  String get clearLogs => 'Kosongkan Log';

  @override
  String get clearLogsConfirmation => 'Adakah anda pasti mahu mengosongkan semua log? Tindakan ini tidak dapat dibatalkan.';

  @override
  String get cancel => 'Batal';

  @override
  String get clear => 'Kosongkan';

  @override
  String get logsClearedSuccessfully => 'Log berjaya dikosongkan';

  @override
  String get errorClearingLogs => 'Ralat mengosongkan log';

  @override
  String get errorLoadingLogs => 'Ralat memuat log';

  @override
  String get stopped => 'Dihentikan';

  @override
  String get starting => 'Memulakan...';

  @override
  String get running => 'Berjalan';

  @override
  String get runningRegistered => 'Berjalan (Berdaftar)';

  @override
  String get runningConnecting => 'Berjalan (Menyambung)';

  @override
  String get runningDisconnected => 'Berjalan (Terputus)';

  @override
  String get error => 'Ralat';

  @override
  String get connecting => 'Menyambung...';

  @override
  String get registeredStatus => 'Berdaftar';

  @override
  String get callInProgress => 'Panggilan sedang berlangsung';

  @override
  String get unknownError => 'Ralat tidak diketahui';

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
