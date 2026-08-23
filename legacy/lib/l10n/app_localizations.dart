import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_af.dart';
import 'app_localizations_ar.dart';
import 'app_localizations_az.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ha.dart';
import 'app_localizations_ig.dart';
import 'app_localizations_it.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_km.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_lo.dart';
import 'app_localizations_ms.dart';
import 'app_localizations_my.dart';
import 'app_localizations_pt.dart';
import 'app_localizations_ru.dart';
import 'app_localizations_sw.dart';
import 'app_localizations_tg.dart';
import 'app_localizations_th.dart';
import 'app_localizations_yo.dart';
import 'app_localizations_zh.dart';
import 'app_localizations_zu.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('af'),
    Locale('ar'),
    Locale('az'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ha'),
    Locale('ig'),
    Locale('it'),
    Locale('ja'),
    Locale('km'),
    Locale('ko'),
    Locale('lo'),
    Locale('ms'),
    Locale('my'),
    Locale('pt'),
    Locale('ru'),
    Locale('sw'),
    Locale('tg'),
    Locale('th'),
    Locale('yo'),
    Locale('zh'),
    Locale('zu'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'GOSTsimbox Gateway'**
  String get appTitle;

  /// No description provided for @configureSipCredentials.
  ///
  /// In en, this message translates to:
  /// **'Configure your SIP credentials'**
  String get configureSipCredentials;

  /// No description provided for @sipUsername.
  ///
  /// In en, this message translates to:
  /// **'SIP Username'**
  String get sipUsername;

  /// No description provided for @sipPassword.
  ///
  /// In en, this message translates to:
  /// **'SIP Password'**
  String get sipPassword;

  /// No description provided for @sipServer.
  ///
  /// In en, this message translates to:
  /// **'SIP Server'**
  String get sipServer;

  /// No description provided for @sipPort.
  ///
  /// In en, this message translates to:
  /// **'SIP Port'**
  String get sipPort;

  /// No description provided for @connect.
  ///
  /// In en, this message translates to:
  /// **'Connect'**
  String get connect;

  /// No description provided for @rememberCredentials.
  ///
  /// In en, this message translates to:
  /// **'Remember credentials and auto-login'**
  String get rememberCredentials;

  /// No description provided for @pleaseEnterSipUsername.
  ///
  /// In en, this message translates to:
  /// **'Please enter SIP username'**
  String get pleaseEnterSipUsername;

  /// No description provided for @pleaseEnterSipPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter SIP password'**
  String get pleaseEnterSipPassword;

  /// No description provided for @pleaseEnterSipServer.
  ///
  /// In en, this message translates to:
  /// **'Please enter SIP server'**
  String get pleaseEnterSipServer;

  /// No description provided for @pleaseEnterSipPort.
  ///
  /// In en, this message translates to:
  /// **'Please enter SIP port'**
  String get pleaseEnterSipPort;

  /// No description provided for @pleaseEnterValidPort.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid port number (1-65535)'**
  String get pleaseEnterValidPort;

  /// No description provided for @authenticationFailed.
  ///
  /// In en, this message translates to:
  /// **'Authentication failed'**
  String get authenticationFailed;

  /// No description provided for @gatewayStatus.
  ///
  /// In en, this message translates to:
  /// **'Gateway Status'**
  String get gatewayStatus;

  /// No description provided for @sipConnection.
  ///
  /// In en, this message translates to:
  /// **'SIP Connection'**
  String get sipConnection;

  /// No description provided for @gsmConnection.
  ///
  /// In en, this message translates to:
  /// **'GSM Connection'**
  String get gsmConnection;

  /// No description provided for @activeCalls.
  ///
  /// In en, this message translates to:
  /// **'Active Calls'**
  String get activeCalls;

  /// No description provided for @registered.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registered;

  /// No description provided for @disconnected.
  ///
  /// In en, this message translates to:
  /// **'Disconnected'**
  String get disconnected;

  /// No description provided for @connected.
  ///
  /// In en, this message translates to:
  /// **'Connected'**
  String get connected;

  /// No description provided for @noCalls.
  ///
  /// In en, this message translates to:
  /// **'No Calls'**
  String get noCalls;

  /// No description provided for @oneActive.
  ///
  /// In en, this message translates to:
  /// **'1 Active'**
  String get oneActive;

  /// No description provided for @gatewayControls.
  ///
  /// In en, this message translates to:
  /// **'Gateway Controls'**
  String get gatewayControls;

  /// No description provided for @startGateway.
  ///
  /// In en, this message translates to:
  /// **'Start Gateway'**
  String get startGateway;

  /// No description provided for @stopGateway.
  ///
  /// In en, this message translates to:
  /// **'Stop Gateway'**
  String get stopGateway;

  /// No description provided for @endCall.
  ///
  /// In en, this message translates to:
  /// **'End Call'**
  String get endCall;

  /// No description provided for @recentLogs.
  ///
  /// In en, this message translates to:
  /// **'Recent Logs'**
  String get recentLogs;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @noLogsAvailable.
  ///
  /// In en, this message translates to:
  /// **'No logs available'**
  String get noLogsAvailable;

  /// No description provided for @gatewayLogsWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Gateway logs will appear here'**
  String get gatewayLogsWillAppearHere;

  /// No description provided for @testControls.
  ///
  /// In en, this message translates to:
  /// **'Test Controls'**
  String get testControls;

  /// No description provided for @testSipCall.
  ///
  /// In en, this message translates to:
  /// **'Test SIP Call'**
  String get testSipCall;

  /// No description provided for @testGsmCall.
  ///
  /// In en, this message translates to:
  /// **'Test GSM Call'**
  String get testGsmCall;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @sipConfiguration.
  ///
  /// In en, this message translates to:
  /// **'SIP Configuration'**
  String get sipConfiguration;

  /// No description provided for @gatewayOptions.
  ///
  /// In en, this message translates to:
  /// **'Gateway Options'**
  String get gatewayOptions;

  /// No description provided for @autoStartGateway.
  ///
  /// In en, this message translates to:
  /// **'Auto Start Gateway'**
  String get autoStartGateway;

  /// No description provided for @autoStartGatewayDesc.
  ///
  /// In en, this message translates to:
  /// **'Automatically start gateway when app launches'**
  String get autoStartGatewayDesc;

  /// No description provided for @replaceDefaultDialer.
  ///
  /// In en, this message translates to:
  /// **'Replace Default Dialer'**
  String get replaceDefaultDialer;

  /// No description provided for @replaceDefaultDialerDesc.
  ///
  /// In en, this message translates to:
  /// **'Replace system dialer with gateway dialer'**
  String get replaceDefaultDialerDesc;

  /// No description provided for @enablePermissions.
  ///
  /// In en, this message translates to:
  /// **'Enable Permissions'**
  String get enablePermissions;

  /// No description provided for @enablePermissionsDesc.
  ///
  /// In en, this message translates to:
  /// **'Request elevated permissions for telephony'**
  String get enablePermissionsDesc;

  /// No description provided for @rememberCredentialsSettings.
  ///
  /// In en, this message translates to:
  /// **'Remember Credentials'**
  String get rememberCredentialsSettings;

  /// No description provided for @rememberCredentialsDesc.
  ///
  /// In en, this message translates to:
  /// **'Save credentials and auto-login'**
  String get rememberCredentialsDesc;

  /// No description provided for @saveSettings.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get saveSettings;

  /// No description provided for @settingsSavedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Settings saved successfully'**
  String get settingsSavedSuccessfully;

  /// No description provided for @errorSavingSettings.
  ///
  /// In en, this message translates to:
  /// **'Error saving settings'**
  String get errorSavingSettings;

  /// No description provided for @gatewayLogs.
  ///
  /// In en, this message translates to:
  /// **'Gateway Logs'**
  String get gatewayLogs;

  /// No description provided for @searchLogs.
  ///
  /// In en, this message translates to:
  /// **'Search logs...'**
  String get searchLogs;

  /// No description provided for @clearLogs.
  ///
  /// In en, this message translates to:
  /// **'Clear Logs'**
  String get clearLogs;

  /// No description provided for @clearLogsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to clear all logs? This action cannot be undone.'**
  String get clearLogsConfirmation;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @logsClearedSuccessfully.
  ///
  /// In en, this message translates to:
  /// **'Logs cleared successfully'**
  String get logsClearedSuccessfully;

  /// No description provided for @errorClearingLogs.
  ///
  /// In en, this message translates to:
  /// **'Error clearing logs'**
  String get errorClearingLogs;

  /// No description provided for @errorLoadingLogs.
  ///
  /// In en, this message translates to:
  /// **'Error loading logs'**
  String get errorLoadingLogs;

  /// No description provided for @stopped.
  ///
  /// In en, this message translates to:
  /// **'Stopped'**
  String get stopped;

  /// No description provided for @starting.
  ///
  /// In en, this message translates to:
  /// **'Starting...'**
  String get starting;

  /// No description provided for @running.
  ///
  /// In en, this message translates to:
  /// **'Running'**
  String get running;

  /// No description provided for @runningRegistered.
  ///
  /// In en, this message translates to:
  /// **'Running (Registered)'**
  String get runningRegistered;

  /// No description provided for @runningConnecting.
  ///
  /// In en, this message translates to:
  /// **'Running (Connecting)'**
  String get runningConnecting;

  /// No description provided for @runningDisconnected.
  ///
  /// In en, this message translates to:
  /// **'Running (Disconnected)'**
  String get runningDisconnected;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @connecting.
  ///
  /// In en, this message translates to:
  /// **'Connecting...'**
  String get connecting;

  /// No description provided for @registeredStatus.
  ///
  /// In en, this message translates to:
  /// **'Registered'**
  String get registeredStatus;

  /// No description provided for @callInProgress.
  ///
  /// In en, this message translates to:
  /// **'Call in progress'**
  String get callInProgress;

  /// No description provided for @unknownError.
  ///
  /// In en, this message translates to:
  /// **'Unknown error'**
  String get unknownError;

  /// No description provided for @smppConfiguration.
  ///
  /// In en, this message translates to:
  /// **'SMPP Configuration'**
  String get smppConfiguration;

  /// No description provided for @smppServerHost.
  ///
  /// In en, this message translates to:
  /// **'SMPP Server Host'**
  String get smppServerHost;

  /// No description provided for @smppPort.
  ///
  /// In en, this message translates to:
  /// **'SMPP Port'**
  String get smppPort;

  /// No description provided for @systemId.
  ///
  /// In en, this message translates to:
  /// **'System ID'**
  String get systemId;

  /// No description provided for @systemPassword.
  ///
  /// In en, this message translates to:
  /// **'System Password'**
  String get systemPassword;

  /// No description provided for @systemType.
  ///
  /// In en, this message translates to:
  /// **'System Type'**
  String get systemType;

  /// No description provided for @connectionStatus.
  ///
  /// In en, this message translates to:
  /// **'Connection Status'**
  String get connectionStatus;

  /// No description provided for @bound.
  ///
  /// In en, this message translates to:
  /// **'Bound'**
  String get bound;

  /// No description provided for @disconnect.
  ///
  /// In en, this message translates to:
  /// **'Disconnect'**
  String get disconnect;

  /// No description provided for @testConnection.
  ///
  /// In en, this message translates to:
  /// **'Test Connection'**
  String get testConnection;

  /// No description provided for @saveConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Save Configuration'**
  String get saveConfiguration;

  /// No description provided for @resetConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Reset Configuration'**
  String get resetConfiguration;

  /// No description provided for @advancedSettings.
  ///
  /// In en, this message translates to:
  /// **'Advanced Settings'**
  String get advancedSettings;

  /// No description provided for @enableDeliveryReceipts.
  ///
  /// In en, this message translates to:
  /// **'Enable Delivery Receipts'**
  String get enableDeliveryReceipts;

  /// No description provided for @enableDeliveryReceiptsDesc.
  ///
  /// In en, this message translates to:
  /// **'Receive delivery confirmations for sent messages'**
  String get enableDeliveryReceiptsDesc;

  /// No description provided for @enableLogging.
  ///
  /// In en, this message translates to:
  /// **'Enable Logging'**
  String get enableLogging;

  /// No description provided for @enableLoggingDesc.
  ///
  /// In en, this message translates to:
  /// **'Log SMPP protocol messages for debugging'**
  String get enableLoggingDesc;

  /// No description provided for @configurationInfo.
  ///
  /// In en, this message translates to:
  /// **'Configuration Info'**
  String get configurationInfo;

  /// No description provided for @protocolVersion.
  ///
  /// In en, this message translates to:
  /// **'Protocol Version'**
  String get protocolVersion;

  /// No description provided for @defaultPort.
  ///
  /// In en, this message translates to:
  /// **'Default Port'**
  String get defaultPort;

  /// No description provided for @connectionType.
  ///
  /// In en, this message translates to:
  /// **'Connection Type'**
  String get connectionType;

  /// No description provided for @keepAlive.
  ///
  /// In en, this message translates to:
  /// **'Keep-alive'**
  String get keepAlive;

  /// No description provided for @reconnectInterval.
  ///
  /// In en, this message translates to:
  /// **'Reconnect Interval'**
  String get reconnectInterval;

  /// No description provided for @pleaseEnterSmppHost.
  ///
  /// In en, this message translates to:
  /// **'Please enter SMPP server host'**
  String get pleaseEnterSmppHost;

  /// No description provided for @pleaseEnterPort.
  ///
  /// In en, this message translates to:
  /// **'Please enter port number'**
  String get pleaseEnterPort;

  /// No description provided for @pleaseEnterSystemId.
  ///
  /// In en, this message translates to:
  /// **'Please enter System ID'**
  String get pleaseEnterSystemId;

  /// No description provided for @pleaseEnterPassword.
  ///
  /// In en, this message translates to:
  /// **'Please enter password'**
  String get pleaseEnterPassword;

  /// No description provided for @configurationSaved.
  ///
  /// In en, this message translates to:
  /// **'Configuration saved successfully'**
  String get configurationSaved;

  /// No description provided for @errorSavingConfiguration.
  ///
  /// In en, this message translates to:
  /// **'Error saving configuration'**
  String get errorSavingConfiguration;

  /// No description provided for @connectionTestSuccess.
  ///
  /// In en, this message translates to:
  /// **'Connection test successful'**
  String get connectionTestSuccess;

  /// No description provided for @connectionTestFailed.
  ///
  /// In en, this message translates to:
  /// **'Connection test failed'**
  String get connectionTestFailed;

  /// No description provided for @showPassword.
  ///
  /// In en, this message translates to:
  /// **'Show Password'**
  String get showPassword;

  /// No description provided for @hidePassword.
  ///
  /// In en, this message translates to:
  /// **'Hide Password'**
  String get hidePassword;

  /// No description provided for @transceiver.
  ///
  /// In en, this message translates to:
  /// **'Transceiver'**
  String get transceiver;

  /// No description provided for @transmitter.
  ///
  /// In en, this message translates to:
  /// **'Transmitter'**
  String get transmitter;

  /// No description provided for @receiver.
  ///
  /// In en, this message translates to:
  /// **'Receiver'**
  String get receiver;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'seconds'**
  String get seconds;

  /// No description provided for @callHistory.
  ///
  /// In en, this message translates to:
  /// **'Call History'**
  String get callHistory;

  /// No description provided for @loadingCalls.
  ///
  /// In en, this message translates to:
  /// **'Loading calls...'**
  String get loadingCalls;

  /// No description provided for @errorLoadingCalls.
  ///
  /// In en, this message translates to:
  /// **'Error loading calls'**
  String get errorLoadingCalls;

  /// No description provided for @noCallsFound.
  ///
  /// In en, this message translates to:
  /// **'No calls found'**
  String get noCallsFound;

  /// No description provided for @callHistoryWillAppearHere.
  ///
  /// In en, this message translates to:
  /// **'Your call history will appear here'**
  String get callHistoryWillAppearHere;

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @incoming.
  ///
  /// In en, this message translates to:
  /// **'Incoming'**
  String get incoming;

  /// No description provided for @outgoing.
  ///
  /// In en, this message translates to:
  /// **'Outgoing'**
  String get outgoing;

  /// No description provided for @missed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get missed;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @rejected.
  ///
  /// In en, this message translates to:
  /// **'Rejected'**
  String get rejected;

  /// No description provided for @unknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown'**
  String get unknown;

  /// No description provided for @makeCall.
  ///
  /// In en, this message translates to:
  /// **'Make Call'**
  String get makeCall;

  /// No description provided for @phoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// No description provided for @enterPhoneNumber.
  ///
  /// In en, this message translates to:
  /// **'Enter phone number'**
  String get enterPhoneNumber;

  /// No description provided for @callInformation.
  ///
  /// In en, this message translates to:
  /// **'Call Information'**
  String get callInformation;

  /// No description provided for @from.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get from;

  /// No description provided for @to.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get to;

  /// No description provided for @duration.
  ///
  /// In en, this message translates to:
  /// **'Duration'**
  String get duration;

  /// No description provided for @status.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get status;

  /// No description provided for @lineId.
  ///
  /// In en, this message translates to:
  /// **'Line ID'**
  String get lineId;

  /// No description provided for @recording.
  ///
  /// In en, this message translates to:
  /// **'Recording'**
  String get recording;

  /// No description provided for @filterCalls.
  ///
  /// In en, this message translates to:
  /// **'Filter Calls'**
  String get filterCalls;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @calling.
  ///
  /// In en, this message translates to:
  /// **'Calling'**
  String get calling;

  /// No description provided for @openingSmsTo.
  ///
  /// In en, this message translates to:
  /// **'Opening SMS to'**
  String get openingSmsTo;

  /// No description provided for @connectionError_1.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_1;

  /// No description provided for @connectionError_2.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_2;

  /// No description provided for @connectionError_3.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_3;

  /// No description provided for @connectionError_4.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_4;

  /// No description provided for @connectionError_5.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_5;

  /// No description provided for @connectionError_6.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_6;

  /// No description provided for @connectionError_7.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_7;

  /// No description provided for @connectionError_8.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_8;

  /// No description provided for @connectionError_9.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_9;

  /// No description provided for @connectionError_10.
  ///
  /// In en, this message translates to:
  /// **'Connection error.'**
  String get connectionError_10;

  /// No description provided for @setupError_1.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_1;

  /// No description provided for @setupError_2.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_2;

  /// No description provided for @setupError_3.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_3;

  /// No description provided for @setupError_4.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_4;

  /// No description provided for @setupError_5.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_5;

  /// No description provided for @setupError_6.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_6;

  /// No description provided for @setupError_7.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_7;

  /// No description provided for @setupError_8.
  ///
  /// In en, this message translates to:
  /// **'Setup error.'**
  String get setupError_8;

  /// No description provided for @successMessage_1.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_1;

  /// No description provided for @successMessage_2.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_2;

  /// No description provided for @successMessage_3.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_3;

  /// No description provided for @successMessage_4.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_4;

  /// No description provided for @successMessage_5.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_5;

  /// No description provided for @successMessage_6.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_6;

  /// No description provided for @successMessage_7.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_7;

  /// No description provided for @successMessage_8.
  ///
  /// In en, this message translates to:
  /// **'Success!'**
  String get successMessage_8;

  /// No description provided for @loadingMessage_1.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_1;

  /// No description provided for @loadingMessage_2.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_2;

  /// No description provided for @loadingMessage_3.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_3;

  /// No description provided for @loadingMessage_4.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_4;

  /// No description provided for @loadingMessage_5.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_5;

  /// No description provided for @loadingMessage_6.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_6;

  /// No description provided for @loadingMessage_7.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_7;

  /// No description provided for @loadingMessage_8.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_8;

  /// No description provided for @loadingMessage_9.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_9;

  /// No description provided for @loadingMessage_10.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_10;

  /// No description provided for @loadingMessage_11.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_11;

  /// No description provided for @loadingMessage_12.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_12;

  /// No description provided for @loadingMessage_13.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_13;

  /// No description provided for @loadingMessage_14.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_14;

  /// No description provided for @loadingMessage_15.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_15;

  /// No description provided for @loadingMessage_16.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_16;

  /// No description provided for @loadingMessage_17.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_17;

  /// No description provided for @loadingMessage_18.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loadingMessage_18;

  /// No description provided for @motivationalMessage_1.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_1;

  /// No description provided for @motivationalMessage_2.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_2;

  /// No description provided for @motivationalMessage_3.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_3;

  /// No description provided for @motivationalMessage_4.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_4;

  /// No description provided for @motivationalMessage_5.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_5;

  /// No description provided for @motivationalMessage_6.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_6;

  /// No description provided for @motivationalMessage_7.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_7;

  /// No description provided for @motivationalMessage_8.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_8;

  /// No description provided for @motivationalMessage_9.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_9;

  /// No description provided for @motivationalMessage_10.
  ///
  /// In en, this message translates to:
  /// **'You\'re doing great!'**
  String get motivationalMessage_10;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'af',
    'ar',
    'az',
    'de',
    'en',
    'es',
    'fr',
    'ha',
    'ig',
    'it',
    'ja',
    'km',
    'ko',
    'lo',
    'ms',
    'my',
    'pt',
    'ru',
    'sw',
    'tg',
    'th',
    'yo',
    'zh',
    'zu',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'af':
      return AppLocalizationsAf();
    case 'ar':
      return AppLocalizationsAr();
    case 'az':
      return AppLocalizationsAz();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ha':
      return AppLocalizationsHa();
    case 'ig':
      return AppLocalizationsIg();
    case 'it':
      return AppLocalizationsIt();
    case 'ja':
      return AppLocalizationsJa();
    case 'km':
      return AppLocalizationsKm();
    case 'ko':
      return AppLocalizationsKo();
    case 'lo':
      return AppLocalizationsLo();
    case 'ms':
      return AppLocalizationsMs();
    case 'my':
      return AppLocalizationsMy();
    case 'pt':
      return AppLocalizationsPt();
    case 'ru':
      return AppLocalizationsRu();
    case 'sw':
      return AppLocalizationsSw();
    case 'tg':
      return AppLocalizationsTg();
    case 'th':
      return AppLocalizationsTh();
    case 'yo':
      return AppLocalizationsYo();
    case 'zh':
      return AppLocalizationsZh();
    case 'zu':
      return AppLocalizationsZu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
