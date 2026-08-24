# flutter_gsmsip Example

Example application demonstrating real usage of the `flutter_gsmsip`
library — a SIP↔GSM voice-gateway/SMS orchestrator (`GatewayService`)
built on `flutter_gsm` (GSM leg) and `flutter_nmsip` (SIP leg).

> This README describes the app as it is actually implemented. If
> something here stops matching the code, that's a bug in the example —
> not aspirational documentation. (An earlier version of this README
> described a `GsmSipBridge` API and screens that never existed in code;
> this rewrite replaces that.)

## ⚠️ Per-platform capability ceiling

Neither leg of the gateway has full cross-platform native support today.
This is a property of the underlying libraries, not a bug in the
example, and the app surfaces it honestly rather than failing silently:

| Leg | Android | Linux | macOS |
|-----|---------|-------|-------|
| SIP (`flutter_nmsip`) | ✅ Real | ❌ No native implementation | ❌ No native implementation |
| GSM modem (`flutter_gsm`) | ✅ Real (Android telephony) | ✅ Real (`SimboxModemRepository`, serial/AT via libsimbox) | ❌ Stub only, throws `ModemDriverNotAvailableException` |

Practically: **only Android can run a fully working gateway** (SIP
registered + GSM leg routed) today. On Linux the GSM/modem leg can work
against a real device, but pressing "Start Gateway" will always fail at
the SIP-registration step — the Dashboard shows the specific reason
(read from the gateway's log stream) rather than a generic error. On
macOS neither leg has a real backend; the app is still fully buildable
and browsable, but nothing will actually connect.

Porting SIP or a modem driver to a new platform is out of scope for this
example — that's sibling-library work (`flutter_nmsip`, `flutter_gsm`),
not something this app can fix by itself.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK matching `../pubspec.yaml`'s constraint (`^3.10.8`)
- For a real end-to-end run: an Android device/emulator (API 21+), a SIP
  account, and (optionally) a GSM modem or SIM-capable device

### Installation

```bash
cd libsFlutter/flutter_gsmsip/example
flutter pub get
flutter run   # -d linux / -d macos / -d <android-device-id>
```

## 📱 Screens

### Setup

First-launch screen (shown automatically when no configuration is saved
yet). Collects a `SipAccount` (username/password/domain/port/transport/
display name) and an optional `SmppConfig` (host/port/system ID/
password), plus `GatewayConfig`-level toggles (auto-answer, logging,
SIP↔GSM routing directions, SMS↔SMPP routing directions, max concurrent
calls). Runs `GatewayConfig.validationErrors` before saving and shows
them inline instead of silently accepting bad input.

### Dashboard

- A capability banner reflecting the table above.
- A modem/device-info card (via `flutter_gsm`'s `ModemRepositoryImpl`
  directly — the recommended pattern per `flows/sdd-flutter_gsm`'s
  split of GSM concerns out of this package): shows the first discovered
  modem's name/signal/registration/IMEI, or an honest "not available on
  this platform" message.
- `GatewayStatus` card (running state, SIP/SMPP connection state) wired
  to `GatewayService().statusStream`.
- Start/Stop: calls `GatewayService().initialize(config)` then `.start()`
  — and **checks the result**. On failure, the specific reason (read
  from `GatewayService().logStream`) is shown, not a generic message.
- Quick actions: test call via SIP→GSM, send test SMS, against a
  user-entered number (not a hardcoded placeholder).

### Settings

Same fields as Setup, pre-filled from the saved configuration, plus
**Clear saved configuration** (stops the gateway first if it's running,
then wipes the saved config).

### Call

Shows active `CallRouting` entries (SIP↔GSM call pairs) from
`GatewayService().routingStream` / `.getActiveRoutings()`. Actions:
make a test call via SIP→GSM or GSM→SIP, end a routing, end all
routings.

**Known limitation, by design**: there are no answer/hold/mute/DTMF
controls here. `GatewayService` only exposes call *routing*
(`makeCallViaSip`/`makeCallViaGsm`/`endRouting`/`endAllRoutings`) — the
underlying `SipRepository` has `answerCall`/`holdCall`/`muteCall`/etc.,
but `GatewayService` doesn't proxy them for direct use. Adding that
would mean changing the library, which is out of scope for this example.

### SMS

Message history and live updates come directly from `SmsService()` (the
same singleton `GatewayService` uses internally — it's safe to read from
both places). Sending goes through `GatewayService().sendSms(...)`.

**SMPP is simulated in the library today** — `SmsService.initializeSmpp`/
`connectSmpp` resolve after a fixed delay and always report "connected";
delivery status is a randomized 95%-success roll
(`_simulateMessageDelivery`), not a real SMPP client round-trip. This
example surfaces that fact rather than presenting it as production
behavior — it's a property of `flutter_gsmsip` as it stands, not
something the example can or should paper over.

### Logs

A merged, in-memory view of `GatewayService().logStream` and
`SmsService().logStream` (two distinct streams — there's no single
unified log stream in the library), with a text-search filter and a
local "clear" (doesn't affect the underlying streams, just this
screen's buffer). There's no log-level filter — the library's log lines
aren't leveled/tagged, so that control would be fake.

## 🏗️ Architecture

```dart
import 'package:flutter_gsmsip/flutter_gsmsip.dart';

final gateway = GatewayService(); // singleton (factory-backed)

// Load previously saved config, or null on first run
final config = await gateway.loadConfiguration();

if (config != null) {
  final ok = await gateway.initialize(config);
  if (!ok) {
    // Check gateway.logStream for the specific reason — SIP
    // registration failure, no modem, wrong credentials, etc.
  } else {
    await gateway.start();
  }
}

gateway.statusStream.listen((status) { /* ... */ });
gateway.routingStream.listen((routing) { /* ... */ });
gateway.logStream.listen(print);
```

### Configuration persistence — a documented coupling, not a lib feature

`GatewayService` has **no public save or clear method**. Configuration
is only persisted as a side effect of a *successful* `initialize()`
call (internally, via a private `_saveConfiguration()`), which requires
SIP registration to succeed — meaning on Linux/macOS, where SIP always
fails, `GatewayService` alone would never persist anything you type into
Setup.

To make Setup/Settings work regardless of platform, this example ships
its own `ExampleConfigStore` (`lib/data/example_config_store.dart`),
which reads/writes `SharedPreferences` directly under the same key
(`'gateway_config'`) and the same JSON shape
(`GatewayConfig.toJson()`/`.fromJson()`, both public) that
`GatewayService.loadConfiguration()` itself reads.

**This is an accepted coupling to an internal implementation detail**,
not a public contract of the library. If a future `flutter_gsmsip`
version changes that storage key or shape, `ExampleConfigStore` would
silently stop agreeing with `GatewayService.loadConfiguration()`. There
is currently no public API to save/clear configuration without this
workaround; fixing that properly would require a change to the library,
which is out of scope here.

## 🔐 Permissions

Android permissions are declared in
`android/app/src/main/AndroidManifest.xml` — telephony (call/answer/
modify state), SMS (send/receive/read), contacts, audio, and foreground
service permissions, matching what `GatewayService`'s SIP+GSM+SMS legs
actually need on Android.

## 🐛 Troubleshooting

### Start Gateway fails immediately

Check the Dashboard's failure message and the Logs screen — as of this
rewrite, the reason is always surfaced (SIP not supported on this
platform, no SIP server reachable, wrong credentials, etc.) rather than
hidden. See the capability table above for what's expected to fail on
Linux/macOS.

### No modem found

Expected on macOS (no driver). On Linux, confirm a device is actually
attached and reachable — the modem card distinguishes "driver not
available on this platform" from "no device currently found."

### SMS status stuck on "pending"

If not using SMPP, local-GSM sends transition pending→sent→delivered on
fixed timers (see `SmsService.sendSmsLocal`). If using SMPP, remember
it's simulated (see above) — a "failed" result ~5% of the time is
expected, simulated behavior, not a real delivery failure.

## 📄 License

This example app is part of the `flutter_gsmsip` project and is
licensed under the **NativeMindNONC License**. See the
[LICENSE](../LICENSE) file for details.
