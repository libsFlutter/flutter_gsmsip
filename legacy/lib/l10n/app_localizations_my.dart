// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Burmese (`my`).
class AppLocalizationsMy extends AppLocalizations {
  AppLocalizationsMy([String locale = 'my']) : super(locale);

  @override
  String get appTitle => 'GOSTsimbox Gateway';

  @override
  String get configureSipCredentials =>
      'သင့် SIP credentials များကို configure လုပ်ပါ';

  @override
  String get sipUsername => 'SIP အသုံးပြုသူအမည်';

  @override
  String get sipPassword => 'SIP စကားဝှက်';

  @override
  String get sipServer => 'SIP Server';

  @override
  String get sipPort => 'SIP Port';

  @override
  String get connect => 'ချိတ်ဆက်ပါ';

  @override
  String get rememberCredentials =>
      'credentials များကို မှတ်ထားပြီး အလိုအလျောက် login လုပ်ပါ';

  @override
  String get pleaseEnterSipUsername =>
      'ကျေးဇူးပြု၍ SIP အသုံးပြုသူအမည်ကို ထည့်သွင်းပါ';

  @override
  String get pleaseEnterSipPassword =>
      'ကျေးဇူးပြု၍ SIP စကားဝှက်ကို ထည့်သွင်းပါ';

  @override
  String get pleaseEnterSipServer => 'ကျေးဇူးပြု၍ SIP server ကို ထည့်သွင်းပါ';

  @override
  String get pleaseEnterSipPort => 'ကျေးဇူးပြု၍ SIP port ကို ထည့်သွင်းပါ';

  @override
  String get pleaseEnterValidPort => 'ကျေးဇူးပြု၍ port နံပါတ်မှန် ထည့်သွင်းပါ';

  @override
  String get authenticationFailed => 'အထောက်အထားစစ်ဆေးခြင်း မအောင်မြင်ပါ';

  @override
  String get gatewayStatus => 'Gateway အခြေအနေ';

  @override
  String get sipConnection => 'SIP ချိတ်ဆက်မှု';

  @override
  String get gsmConnection => 'GSM ချိတ်ဆက်မှု';

  @override
  String get activeCalls => 'အသုံးပြုနေသော ခေါ်ဆိုမှုများ';

  @override
  String get registered => 'မှတ်ပုံတင်ပြီး';

  @override
  String get disconnected => 'ချိတ်ဆက်မှု ဖြတ်တောက်ထား';

  @override
  String get connected => 'ချိတ်ဆက်ထား';

  @override
  String get noCalls => 'ခေါ်ဆိုမှု မရှိ';

  @override
  String get oneActive => '1 ခု အသုံးပြုနေ';

  @override
  String get gatewayControls => 'Gateway ထိန်းချုပ်မှု';

  @override
  String get startGateway => 'Gateway ကို စတင်ပါ';

  @override
  String get stopGateway => 'Gateway ကို ရပ်တန့်ပါ';

  @override
  String get endCall => 'ခေါ်ဆိုမှုကို အဆုံးသတ်ပါ';

  @override
  String get recentLogs => 'လတ်တလော မှတ်တမ်းများ';

  @override
  String get viewAll => 'အားလုံးကို ကြည့်ရှုပါ';

  @override
  String get noLogsAvailable => 'မှတ်တမ်း မရှိပါ';

  @override
  String get gatewayLogsWillAppearHere =>
      'Gateway မှတ်တမ်းများ ဤနေရာတွင် ပေါ်လာမည်';

  @override
  String get testControls => 'စမ်းသပ်မှု ထိန်းချုပ်မှု';

  @override
  String get testSipCall => 'SIP ခေါ်ဆိုမှုကို စမ်းသပ်ပါ';

  @override
  String get testGsmCall => 'GSM ခေါ်ဆိုမှုကို စမ်းသပ်ပါ';

  @override
  String get settings => 'ဆက်တင်များ';

  @override
  String get sipConfiguration => 'SIP ပြင်ဆင်မှု';

  @override
  String get gatewayOptions => 'Gateway ရွေးချယ်မှုများ';

  @override
  String get autoStartGateway => 'Gateway ကို အလိုအလျောက် စတင်ပါ';

  @override
  String get autoStartGatewayDesc =>
      'အပ်ပလီကေးရှင်း ဖွင့်သောအခါ Gateway ကို အလိုအလျောက် စတင်ပါ';

  @override
  String get replaceDefaultDialer => 'ပုံမှန် Dialer ကို အစားထိုးပါ';

  @override
  String get replaceDefaultDialerDesc =>
      'စနစ် dialer ကို Gateway dialer ဖြင့် အစားထိုးပါ';

  @override
  String get enablePermissions => 'ခွင့်ပြုချက်များကို ဖွင့်ပါ';

  @override
  String get enablePermissionsDesc =>
      'ဖုန်းခေါ်ဆိုမှုအတွက် အဆင့်မြင့် ခွင့်ပြုချက်များ တောင်းဆိုပါ';

  @override
  String get rememberCredentialsSettings => 'Credentials များကို မှတ်ထားပါ';

  @override
  String get rememberCredentialsDesc =>
      'credentials များကို သိမ်းဆည်းပြီး အလိုအလျောက် login လုပ်ပါ';

  @override
  String get saveSettings => 'ဆက်တင်များကို သိမ်းဆည်းပါ';

  @override
  String get settingsSavedSuccessfully =>
      'ဆက်တင်များ အောင်မြင်စွာ သိမ်းဆည်းပြီးပါပြီ';

  @override
  String get errorSavingSettings =>
      'ဆက်တင်များ သိမ်းဆည်းရာတွင် အမှားရှိနေပါသည်';

  @override
  String get gatewayLogs => 'Gateway မှတ်တမ်းများ';

  @override
  String get searchLogs => 'မှတ်တမ်းများကို ရှာဖွေပါ...';

  @override
  String get clearLogs => 'မှတ်တမ်းများကို ရှင်းလင်းပါ';

  @override
  String get clearLogsConfirmation =>
      'မှတ်တမ်းအားလုံးကို ရှင်းလင်းရန် သေချာပါသလား? ဤလုပ်ဆောင်ချက်ကို ပြန်လည်ပယ်ဖျက်မရပါ';

  @override
  String get cancel => 'ပယ်ဖျက်ပါ';

  @override
  String get clear => 'ရှင်းလင်းပါ';

  @override
  String get logsClearedSuccessfully =>
      'မှတ်တမ်းများ အောင်မြင်စွာ ရှင်းလင်းပြီးပါပြီ';

  @override
  String get errorClearingLogs =>
      'မှတ်တမ်းများ ရှင်းလင်းရာတွင် အမှားရှိနေပါသည်';

  @override
  String get errorLoadingLogs => 'မှတ်တမ်းများ ဖွင့်ရာတွင် အမှားရှိနေပါသည်';

  @override
  String get stopped => 'ရပ်တန့်ထား';

  @override
  String get starting => 'စတင်နေသည်...';

  @override
  String get running => 'အလုပ်လုပ်နေသည်';

  @override
  String get runningRegistered => 'အလုပ်လုပ်နေသည် (မှတ်ပုံတင်ပြီး)';

  @override
  String get runningConnecting => 'အလုပ်လုပ်နေသည် (ချိတ်ဆက်နေသည်)';

  @override
  String get runningDisconnected => 'အလုပ်လုပ်နေသည် (ချိတ်ဆက်မှု ဖြတ်တောက်ထား)';

  @override
  String get error => 'အမှား';

  @override
  String get connecting => 'ချိတ်ဆက်နေသည်...';

  @override
  String get registeredStatus => 'မှတ်ပုံတင်ပြီး';

  @override
  String get callInProgress => 'ခေါ်ဆိုမှု ဆက်လက်ဖြစ်ပွားနေသည်';

  @override
  String get unknownError => 'အမှားအမည် မသိ';

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
  String get enableDeliveryReceiptsDesc =>
      'Receive delivery confirmations for sent messages';

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
