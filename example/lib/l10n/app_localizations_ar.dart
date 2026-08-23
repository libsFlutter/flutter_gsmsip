// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'بوابة GOSTsimbox';

  @override
  String get configureSipCredentials => 'قم بتكوين بيانات اعتماد SIP الخاصة بك';

  @override
  String get sipUsername => 'اسم مستخدم SIP';

  @override
  String get sipPassword => 'كلمة مرور SIP';

  @override
  String get sipServer => 'خادم SIP';

  @override
  String get sipPort => 'منفذ SIP';

  @override
  String get connect => 'اتصال';

  @override
  String get rememberCredentials => 'تذكر بيانات الاعتماد وتسجيل الدخول التلقائي';

  @override
  String get pleaseEnterSipUsername => 'يرجى إدخال اسم مستخدم SIP';

  @override
  String get pleaseEnterSipPassword => 'يرجى إدخال كلمة مرور SIP';

  @override
  String get pleaseEnterSipServer => 'يرجى إدخال خادم SIP';

  @override
  String get pleaseEnterSipPort => 'يرجى إدخال منفذ SIP';

  @override
  String get pleaseEnterValidPort => 'يرجى إدخال رقم منفذ صحيح';

  @override
  String get authenticationFailed => 'فشل في المصادقة';

  @override
  String get gatewayStatus => 'حالة البوابة';

  @override
  String get sipConnection => 'اتصال SIP';

  @override
  String get gsmConnection => 'اتصال GSM';

  @override
  String get activeCalls => 'المكالمات النشطة';

  @override
  String get registered => 'مسجل';

  @override
  String get disconnected => 'مفصول';

  @override
  String get connected => 'متصل';

  @override
  String get noCalls => 'لا توجد مكالمات';

  @override
  String get oneActive => '1 نشط';

  @override
  String get gatewayControls => 'أدوات تحكم البوابة';

  @override
  String get startGateway => 'بدء البوابة';

  @override
  String get stopGateway => 'إيقاف البوابة';

  @override
  String get endCall => 'إنهاء المكالمة';

  @override
  String get recentLogs => 'السجلات الحديثة';

  @override
  String get viewAll => 'عرض الكل';

  @override
  String get noLogsAvailable => 'لا توجد سجلات متاحة';

  @override
  String get gatewayLogsWillAppearHere => 'ستظهر سجلات البوابة هنا';

  @override
  String get testControls => 'أدوات التحكم التجريبية';

  @override
  String get testSipCall => 'اختبار مكالمة SIP';

  @override
  String get testGsmCall => 'اختبار مكالمة GSM';

  @override
  String get settings => 'الإعدادات';

  @override
  String get sipConfiguration => 'تكوين SIP';

  @override
  String get gatewayOptions => 'خيارات البوابة';

  @override
  String get autoStartGateway => 'بدء البوابة تلقائياً';

  @override
  String get autoStartGatewayDesc => 'بدء البوابة تلقائياً عند تشغيل التطبيق';

  @override
  String get replaceDefaultDialer => 'استبدال الطابع الافتراضي';

  @override
  String get replaceDefaultDialerDesc => 'استبدال طابع النظام بطابع البوابة';

  @override
  String get enablePermissions => 'تمكين الأذونات';

  @override
  String get enablePermissionsDesc => 'طلب أذونات متقدمة للهاتف';

  @override
  String get rememberCredentialsSettings => 'تذكر بيانات الاعتماد';

  @override
  String get rememberCredentialsDesc => 'حفظ بيانات الاعتماد وتسجيل الدخول التلقائي';

  @override
  String get saveSettings => 'حفظ الإعدادات';

  @override
  String get settingsSavedSuccessfully => 'تم حفظ الإعدادات بنجاح';

  @override
  String get errorSavingSettings => 'خطأ في حفظ الإعدادات';

  @override
  String get gatewayLogs => 'سجلات البوابة';

  @override
  String get searchLogs => 'البحث في السجلات...';

  @override
  String get clearLogs => 'مسح السجلات';

  @override
  String get clearLogsConfirmation => 'هل أنت متأكد من أنك تريد مسح جميع السجلات؟ لا يمكن التراجع عن هذا الإجراء.';

  @override
  String get cancel => 'إلغاء';

  @override
  String get clear => 'مسح';

  @override
  String get logsClearedSuccessfully => 'تم مسح السجلات بنجاح';

  @override
  String get errorClearingLogs => 'خطأ في مسح السجلات';

  @override
  String get errorLoadingLogs => 'خطأ في تحميل السجلات';

  @override
  String get stopped => 'متوقف';

  @override
  String get starting => 'بدء التشغيل...';

  @override
  String get running => 'قيد التشغيل';

  @override
  String get runningRegistered => 'قيد التشغيل (مسجل)';

  @override
  String get runningConnecting => 'قيد التشغيل (اتصال)';

  @override
  String get runningDisconnected => 'قيد التشغيل (مفصول)';

  @override
  String get error => 'خطأ';

  @override
  String get connecting => 'جاري الاتصال...';

  @override
  String get registeredStatus => 'مسجل';

  @override
  String get callInProgress => 'مكالمة قيد التقدم';

  @override
  String get unknownError => 'خطأ غير معروف';

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
