# Theme Usage Guide - GSM-SIP Gateway

## Быстрый старт

### Импорт
```dart
import '../theme/app_theme_export.dart';
```

### Основные компоненты
- `AppColors` - Цветовая палитра
- `AppDimensions` - Размеры и отступы
- `AppGradients` - Градиенты
- `AppWidgets` - Общие виджеты

## Часто используемые паттерны

### 1. Карточка статуса
```dart
AppWidgets.statusCard(
  title: 'Gateway Status',
  status: 'Connected',
  icon: Icons.wifi,
  statusColor: AppColors.gatewayConnected,
  subtitle: 'All systems operational',
)
```

### 2. Кнопка с градиентом
```dart
AppWidgets.gradientButton(
  text: 'Connect',
  onPressed: () {},
  icon: Icons.wifi,
  isLoading: false,
)
```

### 3. Индикатор сигнала
```dart
AppWidgets.signalIndicator(
  signalLevel: 85,
  showBars: true,
  showPercentage: true,
)
```

### 4. Карточка с градиентом
```dart
AppWidgets.gradientCard(
  child: Text('Content'),
  padding: EdgeInsets.all(AppDimensions.paddingL),
)
```

### 5. Прогресс-бар
```dart
AppWidgets.gradientProgressIndicator(
  value: 0.75,
  label: 'Connection Progress',
)
```

## Цвета в зависимости от темы

```dart
final brightness = Theme.of(context).brightness;

// Фоны
final backgroundColor = AppColors.getBackgroundPrimary(brightness);
final cardBackground = AppColors.getCardBackground(brightness);

// Тексты
final textColor = AppColors.getTextPrimary(brightness);
final secondaryTextColor = AppColors.getTextSecondary(brightness);

// Градиенты
final cardGradient = AppColors.getCardGradient(brightness);
```

## Статусные цвета

```dart
// Подключение
AppColors.gatewayConnected    // Зеленый
AppColors.gatewayDisconnected // Красный
AppColors.gatewayConnecting   // Желтый

// Сигнал
AppColors.signalStrong        // Зеленый
AppColors.signalWeak          // Желтый
AppColors.signalNone          // Красный

// Вызовы
AppColors.callActive          // Зеленый
AppColors.callInactive        // Серый
```

## Размеры

```dart
// Отступы
AppDimensions.paddingS        // 8.0
AppDimensions.paddingM        // 12.0
AppDimensions.paddingL        // 16.0
AppDimensions.paddingXL       // 20.0

// Радиусы
AppDimensions.radiusS         // 8.0
AppDimensions.radiusM         // 12.0
AppDimensions.radiusL         // 16.0

// Иконки
AppDimensions.iconSizeS       // 16.0
AppDimensions.iconSizeM       // 24.0
AppDimensions.iconSizeL       // 32.0
```

## Переключение темы

```dart
final themeService = Provider.of<ThemeService>(context, listen: false);

// Установка темы
await themeService.setLightTheme();
await themeService.setDarkTheme();
await themeService.setSystemTheme();

// Переключение
await themeService.toggleTheme();
```

## Демонстрация

Для просмотра всех возможностей:
```dart
Navigator.pushNamed(context, '/theme-demo');
```

## Best Practices

1. **Всегда используйте AppDimensions** для размеров
2. **Используйте AppColors** для всех цветов
3. **Применяйте AppWidgets** для общих компонентов
4. **Тестируйте в обеих темах**
5. **Используйте семантические цвета** для статусов

## Добавление новых компонентов

1. Добавьте цвет в `app_colors.dart`
2. Добавьте размер в `app_dimensions.dart` (если нужно)
3. Добавьте градиент в `app_gradients.dart` (если нужно)
4. Добавьте виджет в `app_widgets.dart` (если нужно)
5. Обновите `app_theme_export.dart`
6. Обновите документацию

## Примеры использования в проекте

Смотрите файлы:
- `lib/widgets/status_indicator.dart` - Примеры статусных индикаторов
- `lib/screens/theme_demo_screen.dart` - Полная демонстрация
- `lib/screens/theme_settings_screen.dart` - Настройки темы 