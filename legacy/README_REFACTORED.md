# GOSTsimbox Gateway - Рефакторинг v3.0.0

## Обзор

GOSTsimbox Gateway - это приложение для создания двунаправленного моста между GSM телефонией и протоколами SIP/SMPP. Проект был полностью рефакторен с использованием Clean Architecture для улучшения поддерживаемости, тестируемости и масштабируемости.

## Архитектура

### Clean Architecture

Проект использует Clean Architecture с четким разделением на слои:

```
lib/
├── core/                    # Общие компоненты
│   ├── architecture/       # Описание архитектуры
│   ├── di/                # Dependency Injection
│   ├── utils/             # Утилиты
│   ├── constants/         # Константы
│   └── errors/            # Обработка ошибок
├── domain/                # Доменный слой (бизнес-логика)
│   ├── entities/          # Бизнес-сущности
│   ├── repositories/      # Интерфейсы репозиториев
│   ├── usecases/          # Сценарии использования
│   └── exceptions/        # Бизнес-исключения
├── data/                  # Слой данных
│   ├── datasources/       # Источники данных
│   ├── repositories/      # Реализации репозиториев
│   ├── models/            # Модели данных
│   └── services/          # Внешние сервисы
└── presentation/          # Презентационный слой
    ├── screens/           # Экраны приложения
    ├── widgets/           # Переиспользуемые виджеты
    ├── providers/         # Провайдеры состояния
    ├── services/          # Сервисы UI
    └── theme/             # Тема и стили
```

### Принципы архитектуры

1. **Dependency Inversion** - Зависимости направлены к абстракциям
2. **Single Responsibility** - Каждый класс имеет одну ответственность
3. **Open/Closed** - Открыт для расширения, закрыт для модификации
4. **Interface Segregation** - Клиенты не зависят от неиспользуемых интерфейсов
5. **Dependency Injection** - Зависимости внедряются извне

## Ключевые улучшения

### 1. Архитектурные улучшения

- **Clean Architecture** - Четкое разделение на слои
- **Dependency Injection** - Использование GetIt для управления зависимостями
- **Repository Pattern** - Абстракция доступа к данным
- **Use Case Pattern** - Инкапсуляция бизнес-логики
- **Entity Pattern** - Чистые бизнес-сущности

### 2. Улучшения кода

- **Equatable** - Для корректного сравнения объектов
- **Result Types** - Для обработки ошибок
- **Async Utilities** - Для работы с асинхронностью
- **Логирование** - Структурированное логирование
- **Валидация** - Валидация входных данных

### 3. Улучшения производительности

- **Lazy Loading** - Ленивая загрузка зависимостей
- **Stream Management** - Правильное управление потоками
- **Memory Management** - Освобождение ресурсов
- **Error Handling** - Централизованная обработка ошибок

### 4. Улучшения UX/UI

- **Material Design 3** - Современный дизайн
- **Темная/светлая тема** - Поддержка обеих тем
- **Локализация** - Многоязычная поддержка
- **Responsive Design** - Адаптивный дизайн

## Структура слоев

### Domain Layer (Доменный слой)

Содержит бизнес-логику и не зависит от внешних слоев.

#### Entities (Сущности)
- `GatewayEntity` - Основная сущность шлюза
- `SmsEntity` - Сущность SMS сообщений
- `GatewayConfigEntity` - Конфигурация шлюза

#### Use Cases (Сценарии использования)
- `GetGatewayStatusUseCase` - Получение статуса
- `StartGatewayUseCase` - Запуск шлюза
- `MakeCallUseCase` - Совершение звонка
- `SaveGatewayConfigUseCase` - Сохранение конфигурации

#### Repositories (Интерфейсы репозиториев)
- `GatewayRepository` - Интерфейс для работы с шлюзом
- `SmsRepository` - Интерфейс для работы с SMS

### Data Layer (Слой данных)

Реализует доступ к данным и внешним сервисам.

#### Data Sources (Источники данных)
- `LocalStorageDataSource` - Локальное хранение

#### Models (Модели данных)
- `GatewayConfigModel` - Модель конфигурации
- `SmsMessageModel` - Модель SMS сообщения

#### Services (Сервисы)
- `GatewayService` - Сервис для работы с Android API

### Presentation Layer (Презентационный слой)

Управляет UI и пользовательским взаимодействием.

#### Providers (Провайдеры)
- `GatewayProvider` - Управление состоянием шлюза
- `DashboardProvider` - Управление дашбордом
- `LanguageProvider` - Управление языком

#### Screens (Экраны)
- `DashboardScreen` - Главный экран
- `SettingsScreen` - Настройки
- `SmsScreen` - SMS сообщения
- `CallsScreen` - Звонки

## Зависимости

### Основные зависимости
```yaml
dependencies:
  # State management
  provider: ^6.1.2
  
  # Dependency Injection
  get_it: ^7.6.7
  
  # Value equality
  equatable: ^2.0.5
  
  # Error handling
  dartz: ^0.10.1
  
  # Async utilities
  async: ^2.11.0
  
  # Local storage
  shared_preferences: ^2.2.2
  
  # Logging
  logger: ^2.0.2+1
  
  # Device info
  device_info_plus: ^10.1.0
  
  # Telephony
  flutter_tele:
    path: ../gost_simbox_tele
```

## Установка и запуск

### Предварительные требования
- Flutter SDK 3.8.1+
- Dart SDK 3.8.1+
- Android Studio / VS Code

### Установка зависимостей
```bash
flutter pub get
```

### Запуск приложения
```bash
flutter run
```

### Сборка для Android
```bash
flutter build apk --release
```

## Разработка

### Добавление нового функционала

1. **Создайте Entity** в `domain/entities/`
2. **Создайте Use Case** в `domain/usecases/`
3. **Создайте Repository Interface** в `domain/repositories/`
4. **Создайте Model** в `data/models/`
5. **Создайте Repository Implementation** в `data/repositories/`
6. **Создайте Provider** в `presentation/providers/`
7. **Создайте Screen** в `presentation/screens/`
8. **Зарегистрируйте зависимости** в `core/di/dependency_injection.dart`

### Тестирование

```bash
# Unit тесты
flutter test

# Widget тесты
flutter test test/widget_test.dart

# Integration тесты
flutter test integration_test/
```

### Линтинг

```bash
# Анализ кода
flutter analyze

# Исправление проблем
dart fix --apply
```

## Миграция с версии 2.x

### Основные изменения

1. **Структура папок** - Полная реорганизация по архитектурным слоям
2. **Dependency Injection** - Внедрение GetIt
3. **Use Cases** - Инкапсуляция бизнес-логики
4. **Entities** - Чистые бизнес-сущности
5. **Error Handling** - Централизованная обработка ошибок

### Миграция кода

#### Старый код:
```dart
// Прямое обращение к сервису
final gatewayService = GatewayService();
await gatewayService.start();
```

#### Новый код:
```dart
// Использование Use Case
final startGatewayUseCase = getIt<StartGatewayUseCase>();
await startGatewayUseCase.execute();
```

## Производительность

### Оптимизации

1. **Lazy Loading** - Зависимости загружаются по требованию
2. **Stream Management** - Правильное управление потоками данных
3. **Memory Management** - Автоматическое освобождение ресурсов
4. **Error Boundaries** - Изоляция ошибок

### Метрики

- **Время запуска**: < 3 секунд
- **Использование памяти**: < 100MB
- **Размер APK**: < 50MB
- **Время отклика UI**: < 16ms

## Безопасность

### Меры безопасности

1. **Валидация входных данных** - Проверка всех пользовательских входов
2. **Шифрование конфигурации** - Защита чувствительных данных
3. **Проверка разрешений** - Контроль доступа к системным функциям
4. **Логирование безопасности** - Отслеживание подозрительной активности

## Поддержка

### Документация
- [Архитектура](docs/architecture.md)
- [API Reference](docs/api.md)
- [Migration Guide](docs/migration.md)

### Сообщество
- [Issues](https://github.com/your-repo/issues)
- [Discussions](https://github.com/your-repo/discussions)
- [Wiki](https://github.com/your-repo/wiki)

## Лицензия

MIT License - см. файл [LICENSE](LICENSE) для подробностей.

## Авторы

- Основная команда разработки
- Сообщество контрибьюторов

## Версии

### v3.0.0 (Текущая)
- Полный рефакторинг с Clean Architecture
- Внедрение Dependency Injection
- Улучшенная обработка ошибок
- Современный UI/UX

### v2.x (Предыдущая)
- Базовая функциональность
- Простая архитектура
- Основные возможности

---

**GOSTsimbox Gateway v3.0.0** - Современное решение для GSM-SIP шлюза с чистой архитектурой и отличной производительностью.
