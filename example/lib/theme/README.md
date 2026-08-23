# Theme System - GSM-SIP Gateway

## Обзор

Система тем для GSM-SIP Gateway обеспечивает консистентный и современный дизайн с поддержкой светлой и темной тем. Основана на технических тонах с акцентами связи и безопасности.

## Структура файлов

```
lib/theme/
├── app_colors.dart          # Цветовая палитра
├── app_theme.dart           # Определение тем
├── app_dimensions.dart      # Размеры и отступы
├── app_gradients.dart       # Градиенты
├── app_widgets.dart         # Общие виджеты
├── app_theme_export.dart    # Экспорт всех компонентов
└── README.md               # Документация
```

## Цветовая палитра

### Основные цвета
- **Primary**: `#2563EB` - Технический синий
- **Accent**: `#10B981` - Зеленый связи
- **Technical**: `#8B5CF6` - Фиолетовый

### Статусные цвета
- **Success**: `#10B981` - Зеленый
- **Warning**: `#F59E0B` - Желтый
- **Error**: `#EF4444` - Красный
- **Info**: `#3B82F6` - Синий

### Специальные цвета для GSM-SIP Gateway
- **Gateway Connected**: `#10B981`
- **Gateway Disconnected**: `#EF4444`
- **Gateway Connecting**: `#F59E0B`
- **Signal Strong**: `#10B981`
- **Signal Weak**: `#F59E0B`
- **Call Active**: `#10B981`

## Темы

### Светлая тема
- Основана на белых и светло-серых тонах
- Подходит для дневного использования
- Хорошая читаемость текста

### Темная тема
- Основана на темно-серых и черных тонах
- Оптимальна для технического мониторинга
- Снижает нагрузку на глаза
- **По умолчанию** для технического приложения

### Material 3
- Использует современный дизайн Material 3
- Адаптивные цвета и компоненты
- Поддержка динамических цветов

## Размеры и отступы

### Отступы
- `paddingXS`: 4.0
- `paddingS`: 8.0
- `paddingM`: 12.0
- `paddingL`: 16.0
- `paddingXL`: 20.0
- `paddingXXL`: 24.0
- `paddingXXXL`: 32.0

### Радиусы скругления
- `radiusXS`: 4.0
- `radiusS`: 8.0
- `radiusM`: 12.0
- `radiusL`: 16.0
- `radiusXL`: 20.0
- `radiusXXL`: 24.0

### Размеры иконок
- `iconSizeXS`: 12.0
- `iconSizeS`: 16.0
- `iconSizeM`: 24.0
- `iconSizeL`: 32.0
- `iconSizeXL`: 48.0
- `iconSizeXXL`: 64.0

## Градиенты

### Основные градиенты
- `primaryGradient`: От primary к primaryLight
- `accentGradient`: От accent к accentLight
- `technicalGradient`: От technical к technicalLight
- `connectionGradient`: От primary к accent

### Градиенты для статусов
- `successGradient`: Для успешных операций
- `warningGradient`: Для предупреждений
- `errorGradient`: Для ошибок
- `infoGradient`: Для информации

### Градиенты для GSM-SIP Gateway
- `gatewayConnectedGradient`: Подключенный шлюз
- `gatewayDisconnectedGradient`: Отключенный шлюз
- `gatewayConnectingGradient`: Подключающийся шлюз
- `signalStrongGradient`: Сильный сигнал
- `signalWeakGradient`: Слабый сигнал
- `callActiveGradient`: Активный вызов

## Виджеты

### AppWidgets.gradientCard()
Создает карточку с градиентным фоном.

```dart
AppWidgets.gradientCard(
  child: Text('Content'),
  padding: EdgeInsets.all(16),
  borderRadius: 12,
  colors: [Colors.blue, Colors.green],
)
```

### AppWidgets.gradientButton()
Создает кнопку с градиентом.

```dart
AppWidgets.gradientButton(
  text: 'Click me',
  onPressed: () {},
  icon: Icons.check,
  isLoading: false,
)
```

### AppWidgets.statusCard()
Создает карточку статуса.

```dart
AppWidgets.statusCard(
  title: 'Gateway Status',
  status: 'Connected',
  icon: Icons.wifi,
  statusColor: AppColors.gatewayConnected,
  subtitle: 'All systems operational',
)
```

### AppWidgets.gradientProgressIndicator()
Создает индикатор прогресса с градиентом.

```dart
AppWidgets.gradientProgressIndicator(
  value: 0.75,
  label: 'Connection Progress',
  colors: [AppColors.accent, AppColors.accentLight],
)
```

### AppWidgets.gradientChip()
Создает чип с градиентом.

```dart
AppWidgets.gradientChip(
  label: 'Connected',
  icon: Icons.check,
  isSelected: true,
)
```

### AppWidgets.signalIndicator()
Создает индикатор сигнала.

```dart
AppWidgets.signalIndicator(
  signalLevel: 85,
  showBars: true,
  showPercentage: true,
)
```

### AppWidgets.connectionIndicator()
Создает индикатор подключения.

```dart
AppWidgets.connectionIndicator(
  status: 'Connected',
  showText: true,
)
```

### AppWidgets.callStatusIndicator()
Создает индикатор статуса вызова.

```dart
AppWidgets.callStatusIndicator(
  status: 'Active',
  phoneNumber: '+1234567890',
  duration: '2:34',
)
```

## Использование

### Импорт
```dart
import '../theme/app_theme_export.dart';
```

### Получение цветов в зависимости от темы
```dart
final brightness = Theme.of(context).brightness;
final backgroundColor = AppColors.getBackgroundPrimary(brightness);
final textColor = AppColors.getTextPrimary(brightness);
```

### Использование виджетов
```dart
AppWidgets.gradientCard(
  child: AppWidgets.statusCard(
    title: 'Status',
    status: 'Connected',
    icon: Icons.wifi,
  ),
)
```

### Переключение темы
```dart
final themeService = Provider.of<ThemeService>(context, listen: false);
await themeService.setLightTheme();
await themeService.setDarkTheme();
await themeService.setSystemTheme();
```

## Best Practices

### 1. Консистентность
- Используйте AppDimensions для всех размеров
- Применяйте AppColors для всех цветов
- Используйте AppWidgets для общих компонентов

### 2. Адаптивность
- Все компоненты поддерживают светлую и темную темы
- Используйте методы get*() для получения цветов в зависимости от темы
- Тестируйте в обеих темах

### 3. Производительность
- Кэшируйте цвета и размеры
- Используйте const конструкторы где возможно
- Минимизируйте перерисовки

### 4. Доступность
- Обеспечивайте достаточный контраст
- Используйте семантические цвета
- Поддерживайте системные настройки

### 5. Расширяемость
- Добавляйте новые цвета в AppColors
- Создавайте новые виджеты в AppWidgets
- Документируйте изменения

## Демонстрация

Для просмотра всех возможностей темы используйте экран демонстрации:

```dart
Navigator.pushNamed(context, '/theme-demo');
```

Этот экран показывает:
- Цветовую палитру
- Градиенты
- Кнопки
- Статусные индикаторы
- Карточки
- Прогресс-бары
- Чипы
- Поля ввода
- Переключатели
- Слайдеры

## Заключение

Система тем обеспечивает:
- Современный и консистентный дизайн
- Поддержку светлой и темной тем
- Легкость использования и расширения
- Отличную производительность
- Соответствие Material Design 3
- Специализацию для GSM-SIP Gateway 