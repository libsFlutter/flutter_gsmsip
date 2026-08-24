import 'package:flutter_gsmsip/flutter_gsmsip.dart';
import 'package:flutter_gsmsip_example/data/example_config_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  GatewayConfig sampleConfig() => const GatewayConfig(
        sipAccount: SipAccount(
          id: 'default',
          username: 'alice',
          password: 'secret',
          domain: 'sip.example.com',
        ),
      );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('load returns null when nothing saved', () async {
    final store = ExampleConfigStore();
    expect(await store.load(), isNull);
  });

  test('save then load round-trips the config', () async {
    final store = ExampleConfigStore();
    final config = sampleConfig();

    await store.save(config);
    final loaded = await store.load();

    expect(loaded, isNotNull);
    expect(loaded!.sipAccount.username, 'alice');
    expect(loaded.sipAccount.domain, 'sip.example.com');
  });

  test('clear removes the saved config', () async {
    final store = ExampleConfigStore();
    await store.save(sampleConfig());

    await store.clear();

    expect(await store.load(), isNull);
  });

  test('a value saved by ExampleConfigStore is readable by GatewayService.loadConfiguration', () async {
    final store = ExampleConfigStore();
    await store.save(sampleConfig());

    final loaded = await GatewayService().loadConfiguration();

    expect(loaded, isNotNull);
    expect(loaded!.sipAccount.username, 'alice');
  });
}
