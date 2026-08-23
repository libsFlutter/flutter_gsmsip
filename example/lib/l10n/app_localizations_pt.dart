// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'Gateway GOSTsimbox';

  @override
  String get configureSipCredentials => 'Configure suas credenciais SIP';

  @override
  String get sipUsername => 'Nome de Usuário SIP';

  @override
  String get sipPassword => 'Senha SIP';

  @override
  String get sipServer => 'Servidor SIP';

  @override
  String get sipPort => 'Porta SIP';

  @override
  String get connect => 'Conectar';

  @override
  String get rememberCredentials => 'Lembrar credenciais e login automático';

  @override
  String get pleaseEnterSipUsername => 'Por favor, digite o nome de usuário SIP';

  @override
  String get pleaseEnterSipPassword => 'Por favor, digite a senha SIP';

  @override
  String get pleaseEnterSipServer => 'Por favor, digite o servidor SIP';

  @override
  String get pleaseEnterSipPort => 'Por favor, digite a porta SIP';

  @override
  String get pleaseEnterValidPort => 'Por favor, digite um número de porta válido';

  @override
  String get authenticationFailed => 'Falha na autenticação';

  @override
  String get gatewayStatus => 'Status do Gateway';

  @override
  String get sipConnection => 'Conexão SIP';

  @override
  String get gsmConnection => 'Conexão GSM';

  @override
  String get activeCalls => 'Chamadas Ativas';

  @override
  String get registered => 'Registrado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get connected => 'Conectado';

  @override
  String get noCalls => 'Sem Chamadas';

  @override
  String get oneActive => '1 Ativa';

  @override
  String get gatewayControls => 'Controles do Gateway';

  @override
  String get startGateway => 'Iniciar Gateway';

  @override
  String get stopGateway => 'Parar Gateway';

  @override
  String get endCall => 'Terminar Chamada';

  @override
  String get recentLogs => 'Logs Recentes';

  @override
  String get viewAll => 'Ver Tudo';

  @override
  String get noLogsAvailable => 'Nenhum log disponível';

  @override
  String get gatewayLogsWillAppearHere => 'Os logs do gateway aparecerão aqui';

  @override
  String get testControls => 'Controles de Teste';

  @override
  String get testSipCall => 'Testar Chamada SIP';

  @override
  String get testGsmCall => 'Testar Chamada GSM';

  @override
  String get settings => 'Configurações';

  @override
  String get sipConfiguration => 'Configuração SIP';

  @override
  String get gatewayOptions => 'Opções do Gateway';

  @override
  String get autoStartGateway => 'Iniciar Gateway Automaticamente';

  @override
  String get autoStartGatewayDesc => 'Iniciar gateway automaticamente ao abrir o aplicativo';

  @override
  String get replaceDefaultDialer => 'Substituir Discador Padrão';

  @override
  String get replaceDefaultDialerDesc => 'Substituir o discador do sistema pelo discador do gateway';

  @override
  String get enablePermissions => 'Habilitar Permissões';

  @override
  String get enablePermissionsDesc => 'Solicitar permissões elevadas para telefonia';

  @override
  String get rememberCredentialsSettings => 'Lembrar Credenciais';

  @override
  String get rememberCredentialsDesc => 'Salvar credenciais e login automático';

  @override
  String get saveSettings => 'Salvar Configurações';

  @override
  String get settingsSavedSuccessfully => 'Configurações salvas com sucesso';

  @override
  String get errorSavingSettings => 'Erro ao salvar configurações';

  @override
  String get gatewayLogs => 'Logs do Gateway';

  @override
  String get searchLogs => 'Pesquisar logs...';

  @override
  String get clearLogs => 'Limpar Logs';

  @override
  String get clearLogsConfirmation => 'Tem certeza de que deseja limpar todos os logs? Esta ação não pode ser desfeita.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Limpar';

  @override
  String get logsClearedSuccessfully => 'Logs limpos com sucesso';

  @override
  String get errorClearingLogs => 'Erro ao limpar logs';

  @override
  String get errorLoadingLogs => 'Erro ao carregar logs';

  @override
  String get stopped => 'Parado';

  @override
  String get starting => 'Iniciando...';

  @override
  String get running => 'Executando';

  @override
  String get runningRegistered => 'Executando (Registrado)';

  @override
  String get runningConnecting => 'Executando (Conectando)';

  @override
  String get runningDisconnected => 'Executando (Desconectado)';

  @override
  String get error => 'Erro';

  @override
  String get connecting => 'Conectando...';

  @override
  String get registeredStatus => 'Registrado';

  @override
  String get callInProgress => 'Chamada em andamento';

  @override
  String get unknownError => 'Erro desconhecido';

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
