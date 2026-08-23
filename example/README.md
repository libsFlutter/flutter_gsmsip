# flutter_gsmsip Example

Example application demonstrating the use of the `flutter_gsmsip` library for GSM/SIP/SMPP gateway functionality.

## 📱 Features

- **Gateway Status Dashboard** — Real-time SIP, SMPP, and GSM status
- **Automatic Call Routing** — SIP↔GSM bidirectional routing
- **SMS via SMPP** — Send/receive SMS through SMPP → GSM
- **Debug Operations** — Test calls, SMS, and USSD
- **Settings Screen** — Configure SIP and SMPP credentials
- **Persistent Configuration** — Settings saved between sessions

## 🚀 Getting Started

### Prerequisites

- Android device or emulator (API 21+)
- Flutter SDK >=3.3.0
- SIP account credentials
- SMPP server credentials (optional)

### Installation

1. Clone the repository:
```bash
git clone https://github.com/telon/flutter_gsmsip.git
cd flutter_gsmsip/example
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run on device:
```bash
flutter run
```

## 📖 Usage

### 1. First Launch — Setup Screen

On first launch, you'll see the setup screen. Enter your credentials:

**SIP Account:**
- Username: Your SIP username
- Password: Your SIP password
- Domain: SIP server domain (e.g., `sip.example.com`)
- Port: SIP port (default: 5060)

**SMPP (Optional):**
- Host: SMPP server host
- Port: SMPP port (default: 2775)
- System ID: SMPP username
- Password: SMPP password

Settings are saved automatically and loaded on subsequent launches.

### 2. Dashboard Screen

After setup, you'll see the dashboard with:

**Device Information:**
- Phone number
- Signal strength
- Network operator

**Gateway Status:**
- Running state
- SIP connection state
- SMPP connection state
- Active calls count

**Controls:**
- **Start/Stop Gateway** — Toggle gateway on/off
- **Make Test Call** — Debug: initiate test SIP call
- **Send Test SMS** — Debug: send test SMS via GSM

### 3. Settings Screen

Access settings from the dashboard to:
- Update SIP credentials
- Update SMPP credentials
- Enable/disable auto-answer
- Enable/disable logging
- Clear saved configuration

### 4. Call Screen

View active calls:
- SIP calls
- GSM calls
- Active routings (SIP↔GSM pairs)

Actions:
- Answer incoming call
- End active call
- Mute/unmute
- Hold/resume

### 5. SMS Screen

View SMS messages:
- Received from SMPP
- Sent via GSM
- Pending messages

### 6. Logs Screen

View application logs:
- Gateway events
- SIP events
- SMPP events
- Telephony events

Filter by:
- Log level (Error, Warning, Info, Debug)
- Source (Gateway, SIP, SMPP, Telephony)

Actions:
- Search logs
- Clear logs
- Export logs

## 🏗️ Architecture

This example app demonstrates the **Facade Pattern** for using `flutter_gsmsip`:

```dart
// main.dart
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

class GatewayController {
  final bridge = GsmSipBridge();

  Future<void> initialize() async {
    // Load saved configuration
    final config = await bridge.loadConfiguration();
    if (config == null) return;

    // Initialize with error handling
    final result = await bridge.initialize(config);
    result.fold(
      (failure) => print('Failed: ${failure.message}'),
      (_) => print('Initialized!'),
    );

    // Start gateway (auto-routing enabled)
    await bridge.start();
  }
}
```

### Key Concepts

**1. Single Bridge Instance:**
```dart
final bridge = GsmSipBridge();
```

**2. Configuration Persistence:**
```dart
// Save
await bridge.saveConfiguration(config);

// Load
final config = await bridge.loadConfiguration();
```

**3. Event Streams:**
```dart
// Gateway status
bridge.statusStream.listen((status) {
  print('SIP: ${status.sipState}, SMPP: ${status.smppState}');
});

// SMS events
bridge.smsStream.listen((sms) {
  print('SMS: ${sms.content}');
});

// Call events
bridge.callEventsStream.listen((event) {
  print('Call: ${event.type}');
});
```

**4. Error Handling:**
```dart
final result = await bridge.start();
result.fold(
  (failure) => showError(failure.message),
  (_) => showSuccess('Gateway started'),
);
```

## 🔧 Debug Operations

Debug operations are available through the service classes for testing purposes:

### Test Call
```dart
// Make a test SIP call (routed to GSM)
await bridge.sipService.makeCall('+1234567890');
```

### Test SMS
```dart
// Send test SMS via GSM
await bridge.smsService.sendSms('+1234567890', 'Test message');
```

### Test USSD
```dart
// Send test USSD
await bridge.telephonyService.sendUssd('*100#');
```

### Hangup All Calls
```dart
// End all active calls (both SIP and GSM sides)
if (bridge.canHangup) {
  await bridge.endAllCalls();
}
```

## 📁 Project Structure

```
example/
├── lib/
│   ├── main.dart              # App entry point
│   ├── screens/
│   │   ├── dashboard_screen.dart
│   │   ├── setup_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── call_screen.dart
│   │   ├── sms_screen.dart
│   │   └── logs_screen.dart
│   └── utils/
│       ├── funny_messages.dart
│       └── easter_eggs.dart
├── android/
│   └── app/
│       └── src/main/
│           ├── AndroidManifest.xml
│           └── kotlin/        # Empty (native code in library)
└── pubspec.yaml
```

## 🔐 Permissions

The app requires the following Android permissions (already in `AndroidManifest.xml`):

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.CALL_PHONE"/>
<uses-permission android:name="android.permission.SEND_SMS"/>
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_PHONE_STATE"/>
<uses-permission android:name="android.permission.FOREGROUND_SERVICE"/>
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
```

## 🐛 Troubleshooting

### Gateway Won't Start

1. Check SIP credentials are correct
2. Verify network connectivity
3. Check SIP server is reachable
4. Review logs for error messages

### No Audio in Calls

1. Check microphone permission is granted
2. Verify audio routing settings
3. Test with different SIP server

### SMS Not Sending

1. Check GSM signal strength
2. Verify SMS center number
3. Check SMPP connection (if using SMPP)

### App Crashes on Launch

1. Clear app data and re-enter credentials
2. Check Android version compatibility
3. Review crash logs via `adb logcat`

## 📚 Additional Resources

- [Library Documentation](../README.md)
- [API Reference](https://pub.dev/packages/flutter_gsmsip/documentation)
- [GitHub Issues](https://github.com/telon/flutter_gsmsip/issues)

## 📄 License

This example app is part of the `flutter_gsmsip` project and is licensed under the **NativeMindNONC License**.

See the [LICENSE](../LICENSE) file for details.

---

**Example App Version**: 1.0.0  
**Library Version**: 0.1.0  
**Homepage**: <https://github.com/telon/flutter_gsmsip>
