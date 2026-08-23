// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Gateway GOSTsimbox';

  @override
  String get configureSipCredentials => 'Configura le tue credenziali SIP';

  @override
  String get sipUsername => 'Nome Utente SIP';

  @override
  String get sipPassword => 'Password SIP';

  @override
  String get sipServer => 'Server SIP';

  @override
  String get sipPort => 'Porta SIP';

  @override
  String get connect => 'Connetti';

  @override
  String get rememberCredentials => 'Ricorda credenziali e login automatico';

  @override
  String get pleaseEnterSipUsername => 'Inserisci il nome utente SIP';

  @override
  String get pleaseEnterSipPassword => 'Inserisci la password SIP';

  @override
  String get pleaseEnterSipServer => 'Inserisci il server SIP';

  @override
  String get pleaseEnterSipPort => 'Inserisci la porta SIP';

  @override
  String get pleaseEnterValidPort => 'Inserisci un numero di porta valido';

  @override
  String get authenticationFailed => 'Autenticazione fallita';

  @override
  String get gatewayStatus => 'Stato del Gateway';

  @override
  String get sipConnection => 'Connessione SIP';

  @override
  String get gsmConnection => 'Connessione GSM';

  @override
  String get activeCalls => 'Chiamate Attive';

  @override
  String get registered => 'Registrato';

  @override
  String get disconnected => 'Disconnesso';

  @override
  String get connected => 'Connesso';

  @override
  String get noCalls => 'Nessuna Chiamata';

  @override
  String get oneActive => '1 Attiva';

  @override
  String get gatewayControls => 'Controlli del Gateway';

  @override
  String get startGateway => 'Avvia Gateway';

  @override
  String get stopGateway => 'Ferma Gateway';

  @override
  String get endCall => 'Termina Chiamata';

  @override
  String get recentLogs => 'Log Recenti';

  @override
  String get viewAll => 'Visualizza Tutto';

  @override
  String get noLogsAvailable => 'Nessun log disponibile';

  @override
  String get gatewayLogsWillAppearHere => 'I log del gateway appariranno qui';

  @override
  String get testControls => 'Controlli di Test';

  @override
  String get testSipCall => 'Test Chiamata SIP';

  @override
  String get testGsmCall => 'Test Chiamata GSM';

  @override
  String get settings => 'Impostazioni';

  @override
  String get sipConfiguration => 'Configurazione SIP';

  @override
  String get gatewayOptions => 'Opzioni del Gateway';

  @override
  String get autoStartGateway => 'Avvio Automatico del Gateway';

  @override
  String get autoStartGatewayDesc =>
      'Avvia automaticamente il gateway all\'apertura dell\'app';

  @override
  String get replaceDefaultDialer => 'Sostituisci Compositore Predefinito';

  @override
  String get replaceDefaultDialerDesc =>
      'Sostituisci il compositore di sistema con quello del gateway';

  @override
  String get enablePermissions => 'Abilita Permessi';

  @override
  String get enablePermissionsDesc =>
      'Richiedi permessi elevati per la telefonia';

  @override
  String get rememberCredentialsSettings => 'Ricorda Credenziali';

  @override
  String get rememberCredentialsDesc => 'Salva credenziali e login automatico';

  @override
  String get saveSettings => 'Salva Impostazioni';

  @override
  String get settingsSavedSuccessfully => 'Impostazioni salvate con successo';

  @override
  String get errorSavingSettings => 'Errore nel salvataggio delle impostazioni';

  @override
  String get gatewayLogs => 'Log del Gateway';

  @override
  String get searchLogs => 'Cerca nei log...';

  @override
  String get clearLogs => 'Cancella Log';

  @override
  String get clearLogsConfirmation =>
      'Sei sicuro di voler cancellare tutti i log? Questa azione non può essere annullata.';

  @override
  String get cancel => 'Annulla';

  @override
  String get clear => 'Cancella';

  @override
  String get logsClearedSuccessfully => 'Log cancellati con successo';

  @override
  String get errorClearingLogs => 'Errore nella cancellazione dei log';

  @override
  String get errorLoadingLogs => 'Errore nel caricamento dei log';

  @override
  String get stopped => 'Fermato';

  @override
  String get starting => 'Avvio...';

  @override
  String get running => 'In esecuzione';

  @override
  String get runningRegistered => 'In esecuzione (Registrato)';

  @override
  String get runningConnecting => 'In esecuzione (Connessione)';

  @override
  String get runningDisconnected => 'In esecuzione (Disconnesso)';

  @override
  String get error => 'Errore';

  @override
  String get connecting => 'Connessione...';

  @override
  String get registeredStatus => 'Registrato';

  @override
  String get callInProgress => 'Chiamata in corso';

  @override
  String get unknownError => 'Errore sconosciuto';

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
