/// Модель конфигурации шлюза
class GatewayConfig {
  final String id;
  final String name;
  final String description;
  final Map<String, dynamic> settings;
  final DateTime createdAt;
  final DateTime updatedAt;

  GatewayConfig({
    required this.id,
    required this.name,
    required this.description,
    required this.settings,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Создание конфигурации по умолчанию
  factory GatewayConfig.defaultConfig() {
    return GatewayConfig(
      id: 'default',
      name: 'Default Gateway',
      description: 'Default gateway configuration',
      settings: {
        'enabled': true,
        'port': 5060,
        'host': 'localhost',
        'protocol': 'sip',
      },
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Создание из JSON
  factory GatewayConfig.fromJson(Map<String, dynamic> json) {
    return GatewayConfig(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      settings: json['settings'] as Map<String, dynamic>,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );
  }

  /// Преобразование в JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'settings': settings,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  /// Копирование с изменениями
  GatewayConfig copyWith({
    String? id,
    String? name,
    String? description,
    Map<String, dynamic>? settings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return GatewayConfig(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      settings: settings ?? this.settings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'GatewayConfig{id: $id, name: $name, description: $description}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is GatewayConfig && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
