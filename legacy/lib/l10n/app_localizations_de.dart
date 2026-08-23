// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'GOSTsimbox Gateway';

  @override
  String get configureSipCredentials =>
      'Konfigurieren Sie Ihre SIP-Anmeldedaten';

  @override
  String get sipUsername => 'SIP Benutzername';

  @override
  String get sipPassword => 'SIP Passwort';

  @override
  String get sipServer => 'SIP Server';

  @override
  String get sipPort => 'SIP Port';

  @override
  String get connect => 'Verbinden';

  @override
  String get rememberCredentials =>
      'Anmeldedaten merken und automatisch anmelden';

  @override
  String get pleaseEnterSipUsername =>
      'Bitte geben Sie den SIP-Benutzernamen ein';

  @override
  String get pleaseEnterSipPassword => 'Bitte geben Sie das SIP-Passwort ein';

  @override
  String get pleaseEnterSipServer => 'Bitte geben Sie den SIP-Server ein';

  @override
  String get pleaseEnterSipPort => 'Bitte geben Sie den SIP-Port ein';

  @override
  String get pleaseEnterValidPort =>
      'Bitte geben Sie eine gültige Portnummer ein';

  @override
  String get authenticationFailed => 'Authentifizierung fehlgeschlagen';

  @override
  String get gatewayStatus => 'Gateway-Status';

  @override
  String get sipConnection => 'SIP-Verbindung';

  @override
  String get gsmConnection => 'GSM-Verbindung';

  @override
  String get activeCalls => 'Aktive Anrufe';

  @override
  String get registered => 'Registriert';

  @override
  String get disconnected => 'Getrennt';

  @override
  String get connected => 'Verbunden';

  @override
  String get noCalls => 'Keine Anrufe';

  @override
  String get oneActive => '1 Aktiv';

  @override
  String get gatewayControls => 'Gateway-Steuerung';

  @override
  String get startGateway => 'Gateway starten';

  @override
  String get stopGateway => 'Gateway stoppen';

  @override
  String get endCall => 'Anruf beenden';

  @override
  String get recentLogs => 'Letzte Protokolle';

  @override
  String get viewAll => 'Alle anzeigen';

  @override
  String get noLogsAvailable => 'Keine Protokolle verfügbar';

  @override
  String get gatewayLogsWillAppearHere =>
      'Gateway-Protokolle werden hier angezeigt';

  @override
  String get testControls => 'Test-Steuerung';

  @override
  String get testSipCall => 'SIP-Anruf testen';

  @override
  String get testGsmCall => 'GSM-Anruf testen';

  @override
  String get settings => 'Einstellungen';

  @override
  String get sipConfiguration => 'SIP-Konfiguration';

  @override
  String get gatewayOptions => 'Gateway-Optionen';

  @override
  String get autoStartGateway => 'Gateway automatisch starten';

  @override
  String get autoStartGatewayDesc =>
      'Gateway automatisch beim App-Start starten';

  @override
  String get replaceDefaultDialer => 'Standard-Wähler ersetzen';

  @override
  String get replaceDefaultDialerDesc =>
      'System-Wähler durch Gateway-Wähler ersetzen';

  @override
  String get enablePermissions => 'Berechtigungen aktivieren';

  @override
  String get enablePermissionsDesc =>
      'Erhöhte Berechtigungen für Telefonie anfordern';

  @override
  String get rememberCredentialsSettings => 'Anmeldedaten merken';

  @override
  String get rememberCredentialsDesc =>
      'Anmeldedaten speichern und automatisch anmelden';

  @override
  String get saveSettings => 'Einstellungen speichern';

  @override
  String get settingsSavedSuccessfully =>
      'Einstellungen erfolgreich gespeichert';

  @override
  String get errorSavingSettings => 'Fehler beim Speichern der Einstellungen';

  @override
  String get gatewayLogs => 'Gateway-Protokolle';

  @override
  String get searchLogs => 'Protokolle durchsuchen...';

  @override
  String get clearLogs => 'Protokolle löschen';

  @override
  String get clearLogsConfirmation =>
      'Sind Sie sicher, dass Sie alle Protokolle löschen möchten? Diese Aktion kann nicht rückgängig gemacht werden.';

  @override
  String get cancel => 'Abbrechen';

  @override
  String get clear => 'Löschen';

  @override
  String get logsClearedSuccessfully => 'Protokolle erfolgreich gelöscht';

  @override
  String get errorClearingLogs => 'Fehler beim Löschen der Protokolle';

  @override
  String get errorLoadingLogs => 'Fehler beim Laden der Protokolle';

  @override
  String get stopped => 'Gestoppt';

  @override
  String get starting => 'Startet...';

  @override
  String get running => 'Läuft';

  @override
  String get runningRegistered => 'Läuft (Registriert)';

  @override
  String get runningConnecting => 'Läuft (Verbinde)';

  @override
  String get runningDisconnected => 'Läuft (Getrennt)';

  @override
  String get error => 'Fehler';

  @override
  String get connecting => 'Verbinde...';

  @override
  String get registeredStatus => 'Registriert';

  @override
  String get callInProgress => 'Anruf läuft';

  @override
  String get unknownError => 'Unbekannter Fehler';

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
