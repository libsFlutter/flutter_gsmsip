/// Размеры и отступы приложения GOSTsimbox Gateway
/// Обеспечивает консистентность дизайна
/// Основан на технических тонах с акцентами связи и безопасности
class AppDimensions {
  // Приватный конструктор для предотвращения создания экземпляров
  AppDimensions._();

  // Отступы
  static const double paddingXS = 4.0;
  static const double paddingS = 8.0;
  static const double paddingM = 12.0;
  static const double paddingL = 16.0;
  static const double paddingXL = 20.0;
  static const double paddingXXL = 24.0;
  static const double paddingXXXL = 32.0;

  // Радиусы скругления
  static const double radiusXS = 4.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;
  static const double borderRadius = radiusM; // Алиас для совместимости

  // Размеры иконок
  static const double iconSizeXS = 12.0;
  static const double iconSizeS = 16.0;
  static const double iconSizeM = 24.0;
  static const double iconSizeL = 32.0;
  static const double iconSizeXL = 48.0;
  static const double iconSizeXXL = 64.0;

  // Высоты элементов
  static const double buttonHeightS = 32.0;
  static const double buttonHeightM = 40.0;
  static const double buttonHeightL = 48.0;
  static const double buttonHeightXL = 56.0;

  static const double inputHeightS = 32.0;
  static const double inputHeightM = 40.0;
  static const double inputHeightL = 48.0;

  static const double appBarHeight = 56.0;
  static const double bottomNavigationHeight = 80.0;

  // Размеры карточек
  static const double cardPadding = paddingL;
  static const double cardRadius = radiusL;
  static const double cardElevation = 2.0;

  // Размеры диалогов
  static const double dialogRadius = radiusL;
  static const double dialogPadding = paddingXL;

  // Размеры прогресс-баров
  static const double progressBarHeight = 8.0;
  static const double progressBarRadius = radiusXS;

  // Размеры чипов
  static const double chipHeight = 32.0;
  static const double chipRadius = radiusXL;

  // Размеры аватаров
  static const double avatarSizeS = 32.0;
  static const double avatarSizeM = 48.0;
  static const double avatarSizeL = 64.0;
  static const double avatarSizeXL = 80.0;
  static const double avatarSizeXXL = 100.0;

  // Размеры изображений
  static const double imageSizeS = 64.0;
  static const double imageSizeM = 96.0;
  static const double imageSizeL = 128.0;
  static const double imageSizeXL = 192.0;

  // Размеры сетки
  static const int gridCrossAxisCount = 2;
  static const double gridSpacing = paddingL;
  static const double gridChildAspectRatio = 1.0;

  // Размеры списков
  static const double listItemHeight = 56.0;
  static const double listItemPadding = paddingL;

  // Размеры навигации
  static const double navigationItemHeight = 48.0;
  static const double navigationItemPadding = paddingL;

  // Размеры для мобильных устройств
  static const double mobileMaxWidth = 600.0;
  static const double tabletMaxWidth = 1200.0;

  // Размеры для анимаций
  static const Duration animationDurationFast = Duration(milliseconds: 200);
  static const Duration animationDurationNormal = Duration(milliseconds: 300);
  static const Duration animationDurationSlow = Duration(milliseconds: 500);
  
  // Дополнительные отступы для совместимости
  static const double paddingSmall = paddingS;
  static const double paddingMedium = paddingM;
  static const double paddingLarge = paddingL;
  static const double spacingSmall = paddingS;
  static const double spacingMedium = paddingM;
  static const double spacingLarge = paddingL;
  static const double radiusSmall = radiusS;
  static const double radiusMedium = radiusM;
  static const double radiusLarge = radiusL;

  // Размеры для загрузки
  static const double loadingIndicatorSize = 24.0;
  static const double loadingIndicatorStrokeWidth = 2.0;

  // Размеры для уведомлений
  static const double snackBarHeight = 48.0;
  static const double snackBarPadding = paddingL;

  // Размеры для модальных окон
  static const double modalMaxWidth = 400.0;
  static const double modalMaxHeight = 600.0;

  // Размеры для GOSTsimbox Gateway специфичные
  static const double gatewayStatusCardHeight = 120.0;
  static const double signalIndicatorSize = 32.0;
  static const double callStatusCardHeight = 140.0;
  static const double connectionProgressHeight = 6.0;
  static const double sipStatusIndicatorSize = 24.0;
  static const double simCardHeight = 160.0;
  static const double lineStatusCardHeight = 180.0;
  static const double codecCardHeight = 200.0;
  static const double baseStationCardHeight = 220.0;
  static const double analyticsCardHeight = 240.0;
  static const double logEntryHeight = 80.0;
  static const double smsCardHeight = 120.0;
  static const double callHistoryCardHeight = 160.0;
} 