# flutter_gsmsip

[![Pub Version](https://img.shields.io/pub/v/flutter_gsmsip.svg)](https://pub.dev/packages/flutter_gsmsip)
[![License: NativeMindNONC](https://img.shields.io/badge/license-NativeMindNONC-blue.svg)](LICENSE)

A Flutter plugin for Android and Linux that provides GSM, SIP, and SMPP functionality. Enables voice calls and SMS over SIP with GSM integration for building telephony gateway applications.

## 🖥️ Platform Support

| Platform | Status |
|---|---|
| Android | Full — audio-passthrough Dongle scheme + SIP, native telephony via `TelephonyService` |
| Linux | Interface registered (`ModemRepository`/`FlutterGsmsipPlatform` modem API); ttyUSB/AT-command driver not yet built for *this* package — the sibling `flutter_gsm` package has one (`LinuxFlutterGsm` + `libsimbox`, via `flows/flutter_gsm/sdd-flutter_gsm-ffi`), not yet ported/shared here |
| Windows / macOS | Planned — not yet started |

Linux telephony is modem-based (direct AT-command communication with USB
GSM/UMTS dongles over `/dev/ttyUSBx`, chan_svistok-derived logic re-hosted
without Asterisk), which is architecturally distinct from Android's
audio-passthrough Dongle/SIP path — see `flows/sdd-flutter_gsmsip-interface/`
for the full design rationale.

## 📱 Features

- **Automatic Call Routing** — SIP↔GSM bidirectional routing (incoming SIP → outgoing GSM, incoming GSM → outgoing SIP)
- **SMS over SMPP** — Receive SMS from SMPP and send via GSM automatically
- **SIP Voice Calls** — Native PJSIP integration for VoIP calls
- **GSM Integration** — Direct Android telephony integration
- **SMPP Protocol** — SMPP client for SMS center connectivity
- **Event Streaming** — Real-time status, call, and SMS event streams
- **Error Handling** — Functional error handling with Either type

## 📦 Installation

Add this to your Flutter project's `pubspec.yaml`:

```yaml
dependencies:
  flutter_gsmsip: ^0.1.0
```

Or use a local path for development:

```yaml
dependencies:
  flutter_gsmsip:
    path: ../flutter_gsmsip
```

Then run:

```bash
flutter pub get
```

### Android Configuration

Ensure your `AndroidManifest.xml` includes the required permissions:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## 🚀 Quick Start

### 1. Initialize the Bridge

```dart
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

final bridge = GsmSipBridge();

// Load saved configuration (optional)
final config = await bridge.loadConfiguration();
if (config == null) {
  // Create new configuration
  config = GatewayConfig(
    sipAccount: SipAccount(
      id: 'account-1',
      username: 'user',
      password: 'password',
      domain: 'sip.example.com',
      port: 5060,
    ),
    smppConfig: SmppConfig(
      host: 'smpp.example.com',
      port: 2775,
      systemId: 'user',
      password: 'pass',
    ),
    autoAnswer: false,
    enableLogging: true,
  );
}

// Initialize with error handling
final result = await bridge.initialize(config);
result.fold(
  (failure) => print('Initialization failed: ${failure.message}'),
  (_) => print('Initialized successfully!'),
);

// Start the gateway (auto-routing enabled)
await bridge.start();
```

### 2. Listen to Events

```dart
// Gateway status changes
bridge.statusStream.listen((status) {
  print('Gateway running: ${status.isRunning}');
  print('SIP state: ${status.sipState}');
  print('SMPP state: ${status.smppState}');
  print('Active calls: ${status.activeCalls}');
});

// Incoming SMS (received from SMPP, sent to GSM)
bridge.smsStream.listen((sms) {
  print('SMS received: ${sms.content} from ${sms.sender}');
});

// Call events
bridge.callEventsStream.listen((event) {
  print('Call event: ${event.type} - ${event.data}');
});
```

### 3. Send SMS via SMPP (automatically routed to GSM)

```dart
// Request SMS via SMPP - library automatically sends via GSM
await bridge.smppService.sendSmsRequest('+1234567890', 'Hello from SMPP!');
// → Library handles: SMPP request → GSM SMS send
```

### 4. Debug Operations (for testing only)

```dart
// Make a test call (SIP → GSM)
await bridge.sipService.makeCall('+1234567890');

// Send test SMS via GSM
await bridge.smsService.sendSms('+1234567890', 'Test message');

// Send test USSD
await bridge.telephonyService.sendUssd('*100#');

// Hangup all active calls (both SIP and GSM sides)
if (bridge.canHangup) {
  await bridge.endAllCalls();
}
```

### 5. Stop the Gateway

```dart
await bridge.stop();
await bridge.dispose();
```

## 📚 API Reference

### GsmSipBridge (Main Facade)

#### Lifecycle

| Method | Description | Returns |
|--------|-------------|---------|
| `initialize(GatewayConfig config)` | Initialize with configuration | `Either<Failure, bool>` |
| `start()` | Start gateway (auto-routing enabled) | `Future<bool>` |
| `stop()` | Stop gateway | `Future<void>` |
| `dispose()` | Clean up resources | `void` |
| `loadConfiguration()` | Load saved config from storage | `Future<GatewayConfig?>` |
| `saveConfiguration(GatewayConfig config)` | Save config to storage | `Future<bool>` |

#### Streams

| Stream | Description |
|--------|-------------|
| `statusStream` | Gateway status changes (running, SIP state, SMPP state) |
| `callEventsStream` | Call events (incoming, answered, ended, failed) |
| `smsStream` | SMS events (received from SMPP, sent to GSM) |

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isRunning` | `bool` | Gateway is running |
| `status` | `GatewayStatus?` | Current gateway status |
| `canHangup` | `bool` | Can hangup active calls |
| `sipService` | `SipService` | SIP service (debug) |
| `smsService` | `SmsService` | SMS service (debug) |
| `telephonyService` | `TelephonyService` | GSM service (debug) |
| `smppService` | `SmppService` | SMPP service |

---

### GatewayConfig

```dart
GatewayConfig({
  required SipAccount sipAccount,
  SmppConfig? smppConfig,
  bool autoAnswer = false,
  bool enableLogging = true,
  bool routeSipToGsm = true,
  bool routeGsmToSip = true,
  bool routeSmsToSmpp = false,
  bool routeSmppToSms = true,
  int maxConcurrentCalls = 5,
})
```

---

### SipAccount

```dart
SipAccount({
  required String id,
  required String username,
  required String password,
  required String domain,
  int port = 5060,
  SipTransport transport = SipTransport.udp,
  int registrationTimeout = 3600,
  bool enableKeepAlive = true,
  String? displayName,
  String? proxy,
})
```

---

### SmppConfig

```dart
SmppConfig({
  required String host,
  required int port,
  required String systemId,
  required String password,
  int interfaceVersion = 0x34,
  bool enableDeliveryReceipts = true,
  int requestTimeout = 30000,
  bool enableLogging = true,
})
```

---

### GatewayStatus

| Property | Type | Description |
|----------|------|-------------|
| `isRunning` | `bool` | Gateway is running |
| `sipState` | `SipConnectionState` | SIP connection state |
| `smppState` | `SmppConnectionState` | SMPP connection state |
| `activeCalls` | `int` | Number of active calls |
| `totalCallsHandled` | `int` | Total calls handled |
| `totalMessagesHandled` | `int` | Total messages handled |
| `startTime` | `DateTime?` | Gateway start time |
| `uptime` | `Duration?` | Gateway uptime |

---

### Error Handling

All async operations return `Either<Failure, T>` from the `dartz` package:

```dart
final result = await bridge.initialize(config);

result.fold(
  (failure) {
    // Handle error
    print('Error: ${failure.message}');
    print('Code: ${failure.code}');
    print('Original: ${failure.originalError}');
  },
  (success) {
    // Handle success
    print('Success: $success');
  },
);
```

**Failure Types:**
- `SipFailure` — SIP operation failed
- `SmppFailure` — SMPP operation failed
- `TelephonyFailure` — GSM operation failed
- `GatewayFailure` — Gateway operation failed
- `StorageFailure` — Storage operation failed
- `UnknownFailure` — Unknown error

---

## 🏗️ Architecture

### Library Structure

```
flutter_gsmsip/
├── lib/
│   ├── flutter_gsmsip.dart       # Main export
│   └── src/
│       ├── domain/               # Business logic
│       │   ├── entities/         # Domain models
│       │   ├── repositories/     # Interfaces
│       │   └── usecases/         # Use cases
│       ├── data/                 # Implementation
│       │   ├── repositories/     # Repository impls
│       │   └── services/         # Service impls
│       └── services/             # Public API
│           ├── gateway_service.dart
│           ├── sip_service.dart
│           ├── sms_service.dart
│           ├── telephony_service.dart
│           └── smpp_service.dart
├── android/                      # Native Kotlin code
│   └── src/main/kotlin/...
└── pubspec.yaml
```

### Call Flow

```
┌─────────────────────────────────────────────────────────┐
│                    Incoming SIP Call                     │
│                          ↓                               │
│              GsmSipBridge (auto-route)                   │
│                          ↓                               │
│                    Outgoing GSM Call                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                   Incoming GSM Call                      │
│                          ↓                               │
│              GsmSipBridge (auto-route)                   │
│                          ↓                               │
│                    Outgoing SIP Call                     │
└─────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────┐
│                    SMPP SMS Request                      │
│                          ↓                               │
│              GsmSipBridge (auto-send)                    │
│                          ↓                               │
│                      GSM SMS Send                        │
└─────────────────────────────────────────────────────────┘
```

---

## 📖 Example App

The `example/` directory contains a complete working application demonstrating:

- Gateway initialization with saved configuration
- Real-time status monitoring
- Call and SMS event streaming
- Debug operations for testing

To run the example:

```bash
cd example
flutter pub get
flutter run
```

---

## 📋 Requirements

- **Flutter**: >=3.3.0
- **Dart**: ^3.10.8
- **Android**: API level 21+ (Android 5.0)
- **Kotlin**: 1.7.0+

## 🐛 Known Issues

See the [GitHub Issues](https://github.com/telon/flutter_gsmsip/issues) for known issues and roadmap.

### Current Limitations

- **Android Only**: iOS support not yet implemented
- **PJSIP Version**: Uses specific PJSIP version (bundled in native libs)
- **Service Architecture**: Uses Android foreground services with Intents

---

## 📄 License

This project is licensed under the **NativeMindNONC License** — see the [LICENSE](LICENSE) file for details.

**Key Terms:**
- ✅ **Free for non-commercial use** (education, research, personal learning)
- ⚠️ **Commercial use requires written permission** from the copyright holder
- 🔄 **ShareAlike**: Derivative works must be published as GitHub Forks under the same license
- 📝 **Attribution required**: Credit the original authors with link to repository

---

**Package**: `flutter_gsmsip`  
**Version**: 0.1.0  
**License**: NativeMindNONC  
**Homepage**: <https://github.com/telon/flutter_gsmsip>  
**Issues**: <https://github.com/telon/flutter_gsmsip/issues>
