/// Архитектура приложения GOSTsimbox Gateway
/// Основана на Clean Architecture с разделением на слои
/// 
/// Структура слоев:
/// 
/// Presentation Layer (UI)
/// ├── screens/          - Экраны приложения
/// ├── widgets/          - Переиспользуемые виджеты
/// ├── providers/        - Провайдеры состояния
/// └── theme/            - Тема и стили
/// 
/// Domain Layer (Business Logic)
/// ├── entities/         - Бизнес-сущности
/// ├── repositories/     - Интерфейсы репозиториев
/// ├── usecases/         - Сценарии использования
/// └── exceptions/       - Бизнес-исключения
/// 
/// Data Layer (Data & External)
/// ├── datasources/      - Источники данных
/// ├── repositories/     - Реализации репозиториев
/// ├── models/           - Модели данных
/// └── services/         - Внешние сервисы
/// 
/// Core (Shared)
/// ├── di/               - Dependency Injection
/// ├── utils/            - Утилиты
/// ├── constants/        - Константы
/// └── errors/           - Обработка ошибок

class AppArchitecture {
  static const String presentationLayer = 'presentation';
  static const String domainLayer = 'domain';
  static const String dataLayer = 'data';
  static const String coreLayer = 'core';
  
  // Принципы архитектуры
  static const List<String> principles = [
    'Dependency Inversion - Зависимости направлены к абстракциям',
    'Single Responsibility - Каждый класс имеет одну ответственность',
    'Open/Closed - Открыт для расширения, закрыт для модификации',
    'Interface Segregation - Клиенты не зависят от неиспользуемых интерфейсов',
    'Dependency Injection - Зависимости внедряются извне',
  ];
  
  // Слои и их ответственности
  static const Map<String, List<String>> layerResponsibilities = {
    presentationLayer: [
      'Отображение UI',
      'Обработка пользовательского ввода',
      'Управление состоянием UI',
      'Навигация',
    ],
    domainLayer: [
      'Бизнес-логика',
      'Правила валидации',
      'Сценарии использования',
      'Доменные сущности',
    ],
    dataLayer: [
      'Доступ к данным',
      'Внешние API',
      'Локальное хранение',
      'Сетевое взаимодействие',
    ],
    coreLayer: [
      'Общие утилиты',
      'Dependency Injection',
      'Обработка ошибок',
      'Константы',
    ],
  };
}
