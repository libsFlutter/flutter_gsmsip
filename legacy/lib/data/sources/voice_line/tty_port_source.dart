import 'package:flutter/foundation.dart';

/// Информация о TTY порте
class TtyPortInfo {
  /// Путь к порту
  final String path;

  /// Отображаемое имя
  final String? name;

  /// Производитель
  final String? manufacturer;

  /// Поддерживаемые скорости обмена
  final List<int> supportedBaudRates;

  /// Требуются ли специальные разрешения
  final bool requiresPermissions;

  const TtyPortInfo({
    required this.path,
    this.name,
    this.manufacturer,
    this.supportedBaudRates = const [9600, 19200, 115200],
    this.requiresPermissions = false,
  });

  TtyPortInfo copyWith({
    String? path,
    String? name,
    String? manufacturer,
    List<int>? supportedBaudRates,
    bool? requiresPermissions,
  }) {
    return TtyPortInfo(
      path: path ?? this.path,
      name: name ?? this.name,
      manufacturer: manufacturer ?? this.manufacturer,
      supportedBaudRates: supportedBaudRates ?? this.supportedBaudRates,
      requiresPermissions: requiresPermissions ?? this.requiresPermissions,
    );
  }

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      if (name != null) 'name': name,
      if (manufacturer != null) 'manufacturer': manufacturer,
      'supportedBaudRates': supportedBaudRates,
      'requiresPermissions': requiresPermissions,
    };
  }

  /// Десериализация из JSON
  factory TtyPortInfo.fromJson(Map<String, dynamic> json) {
    return TtyPortInfo(
      path: json['path'] as String? ?? '',
      name: json['name'] as String?,
      manufacturer: json['manufacturer'] as String?,
      supportedBaudRates: (json['supportedBaudRates'] as List?)
              ?.map((e) => e as int)
              .toList() ??
          const [9600, 19200, 115200],
      requiresPermissions: json['requiresPermissions'] as bool? ?? false,
    );
  }

  @override
  String toString() => 'TtyPortInfo(path: $path, name: $name)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is TtyPortInfo && other.path == path;
  }

  @override
  int get hashCode => path.hashCode;
}

/// Результат теста TTY порта
class TtyTestResult {
  /// Успешно ли тестирование
  final bool success;

  /// Сообщение об ошибке
  final String? error;

  /// Измеренная задержка (ms)
  final double? latencyMs;

  /// Ответ от порта
  final String? response;

  const TtyTestResult({
    required this.success,
    this.error,
    this.latencyMs,
    this.response,
  });

  /// Сериализация в JSON
  Map<String, dynamic> toJson() {
    return {
      'success': success,
      if (error != null) 'error': error,
      if (latencyMs != null) 'latencyMs': latencyMs,
      if (response != null) 'response': response,
    };
  }

  /// Десериализация из JSON
  factory TtyTestResult.fromJson(Map<String, dynamic> json) {
    return TtyTestResult(
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      latencyMs: json['latencyMs'] as double?,
      response: json['response'] as String?,
    );
  }
}

/// Источник для TTY портов
abstract class ITtyPortSource {
  /// Сканировать доступные TTY порты
  Future<List<TtyPortInfo>> scanPorts();

  /// Тестировать порт
  Future<TtyTestResult> testPort(String path, int baudRate);

  /// Открыть порт
  Future<bool> openPort(String path, int baudRate);

  /// Закрыть порт
  Future<void> closePort();

  /// Отправить данные
  Future<bool> writeData(String data);

  /// Прочитать данные
  Future<String> readData({Duration timeout = const Duration(seconds: 2)});
}

/// Реализация источника TTY портов
class TtyPortSource implements ITtyPortSource {
  // Общие пути к TTY портам для разных устройств
  static const List<String> commonTtyPaths = [
    '/dev/ttyUSB0', // USB serial (наиболее распространённый)
    '/dev/ttyUSB1',
    '/dev/ttyUSB2',
    '/dev/ttyHS0', // Qualcomm high-speed
    '/dev/ttyHS1',
    '/dev/ttyGS0', // GSM serial
    '/dev/ttyGS1',
    '/dev/ttyMSM0', // MSM serial
    '/dev/ttyMSM1',
    '/dev/ttyS0', // Standard serial
    '/dev/ttyS1',
  ];

  @override
  Future<List<TtyPortInfo>> scanPorts() async {
    try {
      final foundPorts = <TtyPortInfo>[];

      // В реальной реализации здесь будет сканирование через platform channel
      // Для现在 возвращаем заглушку
      for (final path in commonTtyPaths) {
        // Проверяем существование порта через platform channel
        final exists = await _checkPortExists(path);
        if (exists) {
          foundPorts.add(TtyPortInfo(
            path: path,
            name: _getPortName(path),
            manufacturer: _getManufacturer(path),
            requiresPermissions: _requiresPermissions(path),
          ));
        }
      }

      return foundPorts;
    } catch (e) {
      debugPrint('TtyPortSource.scanPorts error: $e');
      return [];
    }
  }

  @override
  Future<TtyTestResult> testPort(String path, int baudRate) async {
    try {
      final startTime = DateTime.now();

      // Попытка открыть и отправить AT команду
      final opened = await openPort(path, baudRate);
      if (!opened) {
        return const TtyTestResult(
          success: false,
          error: 'Failed to open port',
        );
      }

      // Отправка AT команды
      await writeData('AT\r\n');
      final response = await readData();
      await closePort();

      final latency = DateTime.now().difference(startTime).inMilliseconds;

      final success = response.contains('OK');
      return TtyTestResult(
        success: success,
        error: success ? null : 'No OK response',
        latencyMs: latency.toDouble(),
        response: response,
      );
    } catch (e) {
      debugPrint('TtyPortSource.testPort error: $e');
      return TtyTestResult(
        success: false,
        error: e.toString(),
      );
    }
  }

  @override
  Future<bool> openPort(String path, int baudRate) async {
    // В реальной реализации - platform channel для открытия порта
    debugPrint('TtyPortSource.openPort: $path @ $baudRate');
    return true;
  }

  @override
  Future<void> closePort() async {
    debugPrint('TtyPortSource.closePort');
  }

  @override
  Future<bool> writeData(String data) async {
    debugPrint('TtyPortSource.writeData: $data');
    return true;
  }

  @override
  Future<String> readData({Duration timeout = const Duration(seconds: 2)}) async {
    // Заглушка - в реальности чтение из порта
    await Future.delayed(timeout);
    return 'OK';
  }

  // Проверка существования порта
  Future<bool> _checkPortExists(String path) async {
    // В реальной реализации - platform channel
    // Для现在 возвращаем false (порты не найдены без platform channel)
    return false;
  }

  // Получение имени порта
  String _getPortName(String path) {
    if (path.contains('USB')) return 'USB Serial';
    if (path.contains('HS')) return 'High-Speed Serial';
    if (path.contains('GS')) return 'GSM Serial';
    if (path.contains('MSM')) return 'MSM Serial';
    if (path.contains('ttyS')) return 'Standard Serial';
    return 'Unknown';
  }

  // Получение производителя
  String? _getManufacturer(String path) {
    if (path.contains('USB')) return 'Generic USB';
    if (path.contains('HS') || path.contains('MSM')) return 'Qualcomm';
    if (path.contains('GS')) return 'Android GSM';
    return null;
  }

  // Проверка требований к разрешениям
  bool _requiresPermissions(String path) {
    // Некоторые порты требуют root или специальных разрешений
    return path.contains('ttyGS') || path.contains('ttyHS');
  }
}
