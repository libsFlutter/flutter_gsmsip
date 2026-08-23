// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Passerelle GOSTsimbox';

  @override
  String get configureSipCredentials => 'Configurez vos identifiants SIP';

  @override
  String get sipUsername => 'Nom d\'utilisateur SIP';

  @override
  String get sipPassword => 'Mot de passe SIP';

  @override
  String get sipServer => 'Serveur SIP';

  @override
  String get sipPort => 'Port SIP';

  @override
  String get connect => 'Se connecter';

  @override
  String get rememberCredentials => 'Mémoriser les identifiants et connexion automatique';

  @override
  String get pleaseEnterSipUsername => 'Veuillez saisir le nom d\'utilisateur SIP';

  @override
  String get pleaseEnterSipPassword => 'Veuillez saisir le mot de passe SIP';

  @override
  String get pleaseEnterSipServer => 'Veuillez saisir le serveur SIP';

  @override
  String get pleaseEnterSipPort => 'Veuillez saisir le port SIP';

  @override
  String get pleaseEnterValidPort => 'Veuillez saisir un numéro de port valide';

  @override
  String get authenticationFailed => 'Échec de l\'authentification';

  @override
  String get gatewayStatus => 'État de la Passerelle';

  @override
  String get sipConnection => 'Connexion SIP';

  @override
  String get gsmConnection => 'Connexion GSM';

  @override
  String get activeCalls => 'Appels Actifs';

  @override
  String get registered => 'Enregistré';

  @override
  String get disconnected => 'Déconnecté';

  @override
  String get connected => 'Connecté';

  @override
  String get noCalls => 'Aucun Appel';

  @override
  String get oneActive => '1 Actif';

  @override
  String get gatewayControls => 'Contrôles de la Passerelle';

  @override
  String get startGateway => 'Démarrer la Passerelle';

  @override
  String get stopGateway => 'Arrêter la Passerelle';

  @override
  String get endCall => 'Terminer l\'Appel';

  @override
  String get recentLogs => 'Journaux Récents';

  @override
  String get viewAll => 'Voir Tout';

  @override
  String get noLogsAvailable => 'Aucun journal disponible';

  @override
  String get gatewayLogsWillAppearHere => 'Les journaux de la passerelle apparaîtront ici';

  @override
  String get testControls => 'Contrôles de Test';

  @override
  String get testSipCall => 'Tester l\'Appel SIP';

  @override
  String get testGsmCall => 'Tester l\'Appel GSM';

  @override
  String get settings => 'Paramètres';

  @override
  String get sipConfiguration => 'Configuration SIP';

  @override
  String get gatewayOptions => 'Options de la Passerelle';

  @override
  String get autoStartGateway => 'Démarrage Automatique de la Passerelle';

  @override
  String get autoStartGatewayDesc => 'Démarrer automatiquement la passerelle au lancement de l\'application';

  @override
  String get replaceDefaultDialer => 'Remplacer le Composeur par Défaut';

  @override
  String get replaceDefaultDialerDesc => 'Remplacer le composeur système par le composeur de la passerelle';

  @override
  String get enablePermissions => 'Activer les Permissions';

  @override
  String get enablePermissionsDesc => 'Demander des permissions élevées pour la téléphonie';

  @override
  String get rememberCredentialsSettings => 'Mémoriser les Identifiants';

  @override
  String get rememberCredentialsDesc => 'Sauvegarder les identifiants et connexion automatique';

  @override
  String get saveSettings => 'Sauvegarder les Paramètres';

  @override
  String get settingsSavedSuccessfully => 'Paramètres sauvegardés avec succès';

  @override
  String get errorSavingSettings => 'Erreur lors de la sauvegarde des paramètres';

  @override
  String get gatewayLogs => 'Journaux de la Passerelle';

  @override
  String get searchLogs => 'Rechercher dans les journaux...';

  @override
  String get clearLogs => 'Effacer les Journaux';

  @override
  String get clearLogsConfirmation => 'Êtes-vous sûr de vouloir effacer tous les journaux ? Cette action ne peut pas être annulée.';

  @override
  String get cancel => 'Annuler';

  @override
  String get clear => 'Effacer';

  @override
  String get logsClearedSuccessfully => 'Journaux effacés avec succès';

  @override
  String get errorClearingLogs => 'Erreur lors de l\'effacement des journaux';

  @override
  String get errorLoadingLogs => 'Erreur lors du chargement des journaux';

  @override
  String get stopped => 'Arrêté';

  @override
  String get starting => 'Démarrage...';

  @override
  String get running => 'En cours d\'exécution';

  @override
  String get runningRegistered => 'En cours d\'exécution (Enregistré)';

  @override
  String get runningConnecting => 'En cours d\'exécution (Connexion)';

  @override
  String get runningDisconnected => 'En cours d\'exécution (Déconnecté)';

  @override
  String get error => 'Erreur';

  @override
  String get connecting => 'Connexion...';

  @override
  String get registeredStatus => 'Enregistré';

  @override
  String get callInProgress => 'Appel en cours';

  @override
  String get unknownError => 'Erreur inconnue';

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
