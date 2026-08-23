// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get appTitle => 'GOSTsimbox ゲートウェイ';

  @override
  String get configureSipCredentials => 'SIP認証情報を設定してください';

  @override
  String get sipUsername => 'SIPユーザー名';

  @override
  String get sipPassword => 'SIPパスワード';

  @override
  String get sipServer => 'SIPサーバー';

  @override
  String get sipPort => 'SIPポート';

  @override
  String get connect => '接続';

  @override
  String get rememberCredentials => '認証情報を記憶して自動ログイン';

  @override
  String get pleaseEnterSipUsername => 'SIPユーザー名を入力してください';

  @override
  String get pleaseEnterSipPassword => 'SIPパスワードを入力してください';

  @override
  String get pleaseEnterSipServer => 'SIPサーバーを入力してください';

  @override
  String get pleaseEnterSipPort => 'SIPポートを入力してください';

  @override
  String get pleaseEnterValidPort => '有効なポート番号を入力してください';

  @override
  String get authenticationFailed => '認証に失敗しました';

  @override
  String get gatewayStatus => 'ゲートウェイステータス';

  @override
  String get sipConnection => 'SIP接続';

  @override
  String get gsmConnection => 'GSM接続';

  @override
  String get activeCalls => 'アクティブな通話';

  @override
  String get registered => '登録済み';

  @override
  String get disconnected => '切断';

  @override
  String get connected => '接続済み';

  @override
  String get noCalls => '通話なし';

  @override
  String get oneActive => '1件アクティブ';

  @override
  String get gatewayControls => 'ゲートウェイ制御';

  @override
  String get startGateway => 'ゲートウェイ開始';

  @override
  String get stopGateway => 'ゲートウェイ停止';

  @override
  String get endCall => '通話終了';

  @override
  String get recentLogs => '最近のログ';

  @override
  String get viewAll => 'すべて表示';

  @override
  String get noLogsAvailable => 'ログが利用できません';

  @override
  String get gatewayLogsWillAppearHere => 'ゲートウェイログがここに表示されます';

  @override
  String get testControls => 'テスト制御';

  @override
  String get testSipCall => 'SIP通話テスト';

  @override
  String get testGsmCall => 'GSM通話テスト';

  @override
  String get settings => '設定';

  @override
  String get sipConfiguration => 'SIP設定';

  @override
  String get gatewayOptions => 'ゲートウェイオプション';

  @override
  String get autoStartGateway => 'ゲートウェイ自動開始';

  @override
  String get autoStartGatewayDesc => 'アプリ起動時にゲートウェイを自動開始';

  @override
  String get replaceDefaultDialer => 'デフォルトダイヤラーを置換';

  @override
  String get replaceDefaultDialerDesc => 'システムダイヤラーをゲートウェイダイヤラーに置換';

  @override
  String get enablePermissions => '権限を有効化';

  @override
  String get enablePermissionsDesc => '電話機能の高度な権限を要求';

  @override
  String get rememberCredentialsSettings => '認証情報を記憶';

  @override
  String get rememberCredentialsDesc => '認証情報を保存して自動ログイン';

  @override
  String get saveSettings => '設定を保存';

  @override
  String get settingsSavedSuccessfully => '設定が正常に保存されました';

  @override
  String get errorSavingSettings => '設定の保存中にエラーが発生しました';

  @override
  String get gatewayLogs => 'ゲートウェイログ';

  @override
  String get searchLogs => 'ログを検索...';

  @override
  String get clearLogs => 'ログをクリア';

  @override
  String get clearLogsConfirmation => 'すべてのログをクリアしてもよろしいですか？この操作は元に戻せません。';

  @override
  String get cancel => 'キャンセル';

  @override
  String get clear => 'クリア';

  @override
  String get logsClearedSuccessfully => 'ログが正常にクリアされました';

  @override
  String get errorClearingLogs => 'ログのクリア中にエラーが発生しました';

  @override
  String get errorLoadingLogs => 'ログの読み込み中にエラーが発生しました';

  @override
  String get stopped => '停止';

  @override
  String get starting => '開始中...';

  @override
  String get running => '実行中';

  @override
  String get runningRegistered => '実行中（登録済み）';

  @override
  String get runningConnecting => '実行中（接続中）';

  @override
  String get runningDisconnected => '実行中（切断）';

  @override
  String get error => 'エラー';

  @override
  String get connecting => '接続中...';

  @override
  String get registeredStatus => '登録済み';

  @override
  String get callInProgress => '通話中';

  @override
  String get unknownError => '不明なエラー';

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
