// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Puerta de Enlace GOSTsimbox';

  @override
  String get configureSipCredentials => 'Configure sus credenciales SIP';

  @override
  String get sipUsername => 'Nombre de Usuario SIP';

  @override
  String get sipPassword => 'Contraseña SIP';

  @override
  String get sipServer => 'Servidor SIP';

  @override
  String get sipPort => 'Puerto SIP';

  @override
  String get connect => 'Conectar';

  @override
  String get rememberCredentials => 'Recordar credenciales e inicio automático';

  @override
  String get pleaseEnterSipUsername => 'Por favor ingrese el nombre de usuario SIP';

  @override
  String get pleaseEnterSipPassword => 'Por favor ingrese la contraseña SIP';

  @override
  String get pleaseEnterSipServer => 'Por favor ingrese el servidor SIP';

  @override
  String get pleaseEnterSipPort => 'Por favor ingrese el puerto SIP';

  @override
  String get pleaseEnterValidPort => 'Por favor ingrese un número de puerto válido';

  @override
  String get authenticationFailed => 'Error de autenticación';

  @override
  String get gatewayStatus => 'Estado de la Puerta de Enlace';

  @override
  String get sipConnection => 'Conexión SIP';

  @override
  String get gsmConnection => 'Conexión GSM';

  @override
  String get activeCalls => 'Llamadas Activas';

  @override
  String get registered => 'Registrado';

  @override
  String get disconnected => 'Desconectado';

  @override
  String get connected => 'Conectado';

  @override
  String get noCalls => 'Sin Llamadas';

  @override
  String get oneActive => '1 Activa';

  @override
  String get gatewayControls => 'Controles de la Puerta de Enlace';

  @override
  String get startGateway => 'Iniciar Puerta de Enlace';

  @override
  String get stopGateway => 'Detener Puerta de Enlace';

  @override
  String get endCall => 'Terminar Llamada';

  @override
  String get recentLogs => 'Registros Recientes';

  @override
  String get viewAll => 'Ver Todo';

  @override
  String get noLogsAvailable => 'No hay registros disponibles';

  @override
  String get gatewayLogsWillAppearHere => 'Los registros de la puerta de enlace aparecerán aquí';

  @override
  String get testControls => 'Controles de Prueba';

  @override
  String get testSipCall => 'Probar Llamada SIP';

  @override
  String get testGsmCall => 'Probar Llamada GSM';

  @override
  String get settings => 'Configuración';

  @override
  String get sipConfiguration => 'Configuración SIP';

  @override
  String get gatewayOptions => 'Opciones de la Puerta de Enlace';

  @override
  String get autoStartGateway => 'Inicio Automático de la Puerta de Enlace';

  @override
  String get autoStartGatewayDesc => 'Iniciar automáticamente la puerta de enlace al abrir la aplicación';

  @override
  String get replaceDefaultDialer => 'Reemplazar Marcador Predeterminado';

  @override
  String get replaceDefaultDialerDesc => 'Reemplazar el marcador del sistema con el marcador de la puerta de enlace';

  @override
  String get enablePermissions => 'Habilitar Permisos';

  @override
  String get enablePermissionsDesc => 'Solicitar permisos elevados para telefonía';

  @override
  String get rememberCredentialsSettings => 'Recordar Credenciales';

  @override
  String get rememberCredentialsDesc => 'Guardar credenciales e inicio automático';

  @override
  String get saveSettings => 'Guardar Configuración';

  @override
  String get settingsSavedSuccessfully => 'Configuración guardada exitosamente';

  @override
  String get errorSavingSettings => 'Error al guardar la configuración';

  @override
  String get gatewayLogs => 'Registros de la Puerta de Enlace';

  @override
  String get searchLogs => 'Buscar registros...';

  @override
  String get clearLogs => 'Limpiar Registros';

  @override
  String get clearLogsConfirmation => '¿Está seguro de que desea limpiar todos los registros? Esta acción no se puede deshacer.';

  @override
  String get cancel => 'Cancelar';

  @override
  String get clear => 'Limpiar';

  @override
  String get logsClearedSuccessfully => 'Registros limpiados exitosamente';

  @override
  String get errorClearingLogs => 'Error al limpiar registros';

  @override
  String get errorLoadingLogs => 'Error al cargar registros';

  @override
  String get stopped => 'Detenido';

  @override
  String get starting => 'Iniciando...';

  @override
  String get running => 'Ejecutándose';

  @override
  String get runningRegistered => 'Ejecutándose (Registrado)';

  @override
  String get runningConnecting => 'Ejecutándose (Conectando)';

  @override
  String get runningDisconnected => 'Ejecutándose (Desconectado)';

  @override
  String get error => 'Error';

  @override
  String get connecting => 'Conectando...';

  @override
  String get registeredStatus => 'Registrado';

  @override
  String get callInProgress => 'Llamada en progreso';

  @override
  String get unknownError => 'Error desconocido';

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
