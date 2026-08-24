import 'dart:convert';

import 'package:flutter_gsmsip/flutter_gsmsip.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists [GatewayConfig] independent of [GatewayService.initialize]'s
/// success/failure.
///
/// [GatewayService] has no public save/clear method — it only persists
/// configuration as a side effect of a *successful* `initialize()` call
/// (SIP registration must succeed), which never happens on platforms
/// without a SIP implementation (Linux/macOS today). This store reads
/// and writes the same `SharedPreferences` key (`'gateway_config'`) and
/// the same JSON shape (`GatewayConfig.toJson()`/`.fromJson()`, both
/// public) that `GatewayService.loadConfiguration()` itself uses, so
/// Setup/Settings screens can persist and clear configuration
/// regardless of whether the gateway ever successfully starts.
///
/// This is a deliberate coupling to an internal storage-key detail of
/// `GatewayService`, not a public contract — see `example/README.md`'s
/// "Configuration persistence" section for the accepted risk this
/// carries. There is no public API alternative today without modifying
/// the library.
class ExampleConfigStore {
  static const _storageKey = 'gateway_config';

  Future<GatewayConfig?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final configJson = prefs.getString(_storageKey);
    if (configJson == null) return null;
    return GatewayConfig.fromJson(jsonDecode(configJson) as Map<String, dynamic>);
  }

  Future<void> save(GatewayConfig config) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(config.toJson()));
  }

  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
