# Theme Implementation - Best Practices

## Обзор

Данный документ описывает имплементацию best practices по темам и другим аспектам в `gost_simbox_android`, аналогично тому, как это реализовано в `FreeDome Manager`.

## Структура файлов

```
lib/
├── theme/
│   ├── app_colors.dart          # Цветовая палитра
│   ├── app_theme.dart           # Определение тем
│   ├── app_dimensions.dart      # Размеры и отступы
│   ├── app_gradients.dart       # Градиенты
│   ├── app_widgets.dart         # Общие виджеты
│   ├── app_theme_export.dart    # Экспорт всех компонентов
│   └── README.md               # Документация темы
├── services/
│   ├── theme_service.dart       # Сервис управления темами
│   └── localization_service.dart # Сервис локализации
├── screens/
│   ├── theme_settings_screen.dart # Экран настроек темы
│   └── theme_demo_screen.dart   # Экран демонстрации темы
├── widgets/
│   └── status_indicator.dart    # Виджеты с тематическими цветами
└── main.dart                    # Интеграция сервисов
```

## Цветовая палитра (app_colors.dart)

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
- **Signal Strong**: `#10B981`
- **Signal Weak**: `#F59E0B`
- **Call Active**: `#10B981`

## Темы (app_theme.dart)

### Светлая тема
- Основана на белых и светло-серых тонах
- Подходит для дневного использования
- Хорошая читаемость текста

### Темная тема
- Основана на темно-серых и черных тонах
- Оптимальна для технического мониторинга
- Снижает нагрузку на глаза

### Material 3
- Использует современный дизайн Material 3
- Адаптивные цвета и компоненты
- Поддержка динамических цветов

## Сервис управления темами (theme_service.dart)

### Функциональность
- Переключение между светлой, темной и системной темами
- Сохранение выбранной темы в SharedPreferences
- Автоматическое определение системной темы
- Методы для получения цветов статусов

### Методы
```dart
// Установка тем
await themeService.setLightTheme();
await themeService.setDarkTheme();
await themeService.setSystemTheme();

// Переключение
await themeService.toggleTheme();

// Получение цветов статусов
themeService.getConnectionStatusColor(status);
themeService.getSignalLevelColor(level);
themeService.getCallStatusColor(status);
```

## Сервис локализации (localization_service.dart)

### Поддерживаемые языки
- Английский (en)
- Русский (ru)
- Испанский (es)
- Французский (fr)
- Немецкий (de)
- Китайский (zh)
- Японский (ja)
- Корейский (ko)
- Арабский (ar)
- Португальский (pt)
- Итальянский (it)
- Тайский (th)
- Таджикский (tg)
- Азербайджанский (az)
- Кхмерский (km)
- Лаосский (lo)
- Мьянманский (my)
- Малайский (ms)
- Суахили (sw)
- Зулу (zu)
- Африкаанс (af)
- Йоруба (yo)
- Игбо (ig)
- Хауса (ha)

### Функциональность
- Переключение между языками
- Сохранение выбранного языка
- Получение названий и описаний языков
- Отображение флагов стран

## Виджеты статуса (status_indicator.dart)

### StatusIndicator
Отображает статус подключения с соответствующими цветами:
- Подключен (зеленый)
- Подключение (желтый)
- Отключен (красный)

### SignalIndicator
Показывает уровень сигнала с визуальными индикаторами:
- Отличный (80%+) - зеленый
- Хороший (60-79%) - светло-зеленый
- Средний (40-59%) - желтый
- Слабый (20-39%) - оранжевый
- Очень слабый (<20%) - красный

### CallStatusIndicator
Отображает статус вызова:
- Активный (зеленый)
- Входящий/Исходящий (зеленый)
- Завершен/Пропущен (красный)
- Ожидание (желтый)

## Общие виджеты (app_widgets.dart)

### AppWidgets.gradientCard()
Создает карточку с градиентным фоном, адаптирующуюся под тему.

### AppWidgets.gradientButton()
Создает кнопку с градиентом и поддержкой состояния загрузки.

### AppWidgets.statusCard()
Создает карточку статуса с иконкой, цветом и описанием.

### AppWidgets.gradientProgressIndicator()
Создает индикатор прогресса с градиентом и меткой.

### AppWidgets.gradientChip()
Создает чип с градиентом и поддержкой выбора.

### AppWidgets.signalIndicator()
Создает индикатор сигнала с визуальными полосками.

### AppWidgets.connectionIndicator()
Создает индикатор подключения с иконкой и текстом.

### AppWidgets.callStatusIndicator()
Создает индикатор статуса вызова с дополнительной информацией.

## Размеры и отступы (app_dimensions.dart)

### Стандартизированные размеры
- Отступы: paddingXS, paddingS, paddingM, paddingL, paddingXL, paddingXXL, paddingXXXL
- Радиусы: radiusXS, radiusS, radiusM, radiusL, radiusXL, radiusXXL
- Иконки: iconSizeXS, iconSizeS, iconSizeM, iconSizeL, iconSizeXL, iconSizeXXL
- Высоты: buttonHeightS, buttonHeightM, buttonHeightL, buttonHeightXL
- Карточки: cardPadding, cardRadius, cardElevation

### Специализированные размеры для GSM-SIP Gateway
- gatewayStatusCardHeight, signalIndicatorSize, callStatusCardHeight
- connectionProgressHeight, sipStatusIndicatorSize, simCardHeight
- lineStatusCardHeight, codecCardHeight, baseStationCardHeight
- analyticsCardHeight, logEntryHeight, smsCardHeight, callHistoryCardHeight

## Градиенты (app_gradients.dart)

### Основные градиенты
- primaryGradient, accentGradient, technicalGradient, connectionGradient
- successGradient, warningGradient, errorGradient, infoGradient

### Специализированные градиенты для GSM-SIP Gateway
- gatewayConnectedGradient, gatewayDisconnectedGradient, gatewayConnectingGradient
- signalStrongGradient, signalWeakGradient, callActiveGradient

### Адаптивные градиенты
- cardGradient, navigationGradient, chipGradient, dialogGradient
- Методы для получения градиентов в зависимости от темы

## Экран настроек темы (theme_settings_screen.dart)

### Функциональность
- Отображение текущей темы
- Выбор из доступных тем
- Быстрое переключение
- Просмотр цветовой палитры
- Переход к демо экрану

### Интерфейс
- Карточки с иконками для каждой темы
- Описания и названия тем
- Индикаторы выбранной темы
- Кнопка быстрого переключения
- Кнопка "View Theme Demo"

## Экран демонстрации темы (theme_demo_screen.dart)

### Функциональность
- Демонстрация всех компонентов темы
- Просмотр в светлой и темной темах
- Интерактивные примеры
- Визуальное представление возможностей

### Разделы демонстрации
- **Color Palette**: Все цвета системы
- **Gradients**: Градиенты и их применение
- **Buttons**: Кнопки с градиентами и состояниями
- **Status Indicators**: Статусные индикаторы
- **Cards**: Карточки с градиентами
- **Progress Indicators**: Индикаторы прогресса
- **Chips**: Чипы с градиентами
- **Input Fields**: Поля ввода
- **Switches**: Переключатели
- **Sliders**: Слайдеры

## Интеграция в main.dart

### Инициализация сервисов
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final themeService = ThemeService();
  final localizationService = LocalizationService();
  
  await themeService.initialize();
  await localizationService.initialize();
  
  runApp(MyApp(
    themeService: themeService,
    localizationService: localizationService,
  ));
}
```

### Настройка MaterialApp
```dart
MaterialApp(
  theme: AppTheme.lightTheme,
  darkTheme: AppTheme.darkTheme,
  themeMode: themeService.themeMode,
  locale: languageProvider.currentLocale,
  // ...
)
```

## Best Practices

### 1. Консистентность дизайна
- Использование централизованной цветовой палитры (AppColors)
- Применение стандартных размеров (AppDimensions)
- Использование общих виджетов (AppWidgets)
- Семантические цвета для статусов
- Адаптация под светлую и темную темы

### 2. Доступность
- Достаточный контраст текста
- Семантические цвета для статусов
- Поддержка системных настроек
- Адаптивные размеры компонентов

### 3. Производительность
- Кэширование тем в SharedPreferences
- Минимальное количество перерисовок
- Эффективное использование Provider
- Использование const конструкторов

### 4. Расширяемость
- Легкое добавление новых тем
- Модульная структура сервисов
- Переиспользуемые виджеты
- Централизованная система компонентов

### 5. Пользовательский опыт
- Интуитивные иконки
- Понятные описания
- Быстрое переключение тем
- Визуальная привлекательность градиентов

### 6. Специализация для GSM-SIP Gateway
- Цвета и статусы для подключения шлюза
- Индикаторы уровня сигнала
- Статусы вызовов
- Технические тона и акценты связи

## Использование

### В виджетах
```dart
Consumer<ThemeService>(
  builder: (context, themeService, child) {
    final statusColor = themeService.getConnectionStatusColor(status);
    return Container(
      color: statusColor,
      child: Text(status),
    );
  },
)
```

### Использование общих виджетов
```dart
AppWidgets.gradientCard(
  child: AppWidgets.statusCard(
    title: 'Gateway Status',
    status: 'Connected',
    icon: Icons.wifi,
    statusColor: AppColors.gatewayConnected,
  ),
)

AppWidgets.gradientButton(
  text: 'Connect',
  onPressed: () {},
  icon: Icons.wifi,
  isLoading: false,
)

AppWidgets.signalIndicator(
  signalLevel: 85,
  showBars: true,
  showPercentage: true,
)
```

### Получение цветов в зависимости от темы
```dart
final brightness = Theme.of(context).brightness;
final backgroundColor = AppColors.getBackgroundPrimary(brightness);
final textColor = AppColors.getTextPrimary(brightness);
final cardColors = AppColors.getCardGradient(brightness);
```

### Использование градиентов
```dart
Container(
  decoration: BoxDecoration(
    gradient: AppGradients.getConnectionStatusGradient('connected'),
  ),
  child: Text('Connected'),
)
```

### В сервисах
```dart
final themeService = Provider.of<ThemeService>(context, listen: false);
await themeService.setDarkTheme();
```

### Добавление новых компонентов
1. **Цвета**: Добавить в `app_colors.dart`
2. **Размеры**: Добавить в `app_dimensions.dart`
3. **Градиенты**: Добавить в `app_gradients.dart`
4. **Виджеты**: Добавить в `app_widgets.dart`
5. **Экспорт**: Обновить `app_theme_export.dart`
6. **Документация**: Обновить `README.md`

## Заключение

Данная имплементация обеспечивает:
- **Современный и консистентный дизайн** с использованием Material Design 3
- **Полную поддержку светлой и темной тем** с темной темой по умолчанию
- **Специализацию для GSM-SIP Gateway** с техническими тонами и акцентами связи
- **Централизованную систему компонентов** с переиспользуемыми виджетами
- **Визуальную привлекательность** благодаря градиентам и современным UI элементам
- **Отличную производительность** с оптимизированными компонентами
- **Легкость поддержки и расширения** с модульной архитектурой
- **Документированность** с подробными README и примерами использования
- **Демонстрационные возможности** с интерактивным экраном демонстрации
- **Best practices** из других проектов (FreeDome Manager, LiveSkin)

### Ключевые особенности:
- ✅ Темная тема по умолчанию для технического приложения
- ✅ Поддержка системной темы
- ✅ Специализированные цвета и статусы для GSM-SIP Gateway
- ✅ Градиенты и современные UI компоненты
- ✅ Стандартизированные размеры и отступы
- ✅ Переиспользуемые виджеты
- ✅ Полная документация
- ✅ Демонстрационный экран
- ✅ Соответствие Material Design 3 