import 'dart:io';

/// Hand-derived per-platform capability ceiling for the two legs
/// `GatewayService` orchestrates.
///
/// Not queryable from `flutter_gsmsip`/`flutter_gsm`/`flutter_nmsip` at
/// runtime — no such API exists in any of them. These values were
/// determined by reading the libraries' source directly (see
/// `flows/flutter_gsmsip/sdd-flutter_gsmsip-example/02-specifications.md`'s
/// capability table):
///
/// - SIP: `flutter_nmsip`'s `pubspec.yaml` declares only an `android`
///   platform implementation.
/// - GSM modem: `flutter_gsm` has a real driver on Linux
///   (`SimboxModemRepository`, FFI→libsimbox) and Android (telephony),
///   but only a stub on macOS (`MacosFlutterGsm`, throws
///   `ModemDriverNotAvailableException`).
///
/// **Must be kept in sync by hand** if those libraries gain new platform
/// support — there is no way to detect that automatically from here.
class PlatformCapabilities {
  static bool get sipSupported => Platform.isAndroid;

  static bool get modemDriverSupported => Platform.isAndroid || Platform.isLinux;
}
