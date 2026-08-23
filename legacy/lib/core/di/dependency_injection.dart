/// Система Dependency Injection
/// Управляет зависимостями между слоями приложения
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logger/logger.dart';
import 'package:http/http.dart' as http;

// Services
import '../../presentation/services/theme_service.dart';
import '../../presentation/services/localization_service.dart';
import '../../presentation/services/security_service.dart';
import '../../presentation/services/cache_service.dart';
import '../../presentation/services/api_service.dart';
import '../../presentation/services/storage_service.dart';
import '../../presentation/services/notification_service.dart';
import '../../presentation/services/analytics_service.dart';
import '../../presentation/services/network_service.dart';
import '../../presentation/services/device_service.dart';
import '../../presentation/services/permission_service.dart';

// SIP Services
import '../../data/services/sip_service.dart';
import '../../data/repositories/sip_repository_impl.dart';
import '../../domain/repositories/sip_repository.dart';
import '../../domain/usecases/sip_usecases.dart';
import '../../presentation/providers/sip_provider.dart';

// Gateway Services
import '../../data/services/gateway_service.dart';
import '../../data/repositories/gateway_repository_impl.dart';
import '../../domain/repositories/gateway_repository.dart';
import '../../domain/usecases/gateway_usecases.dart';
import '../../presentation/providers/gateway_provider.dart';

// Repositories
import '../../data/repositories/settings_repository.dart';
import '../../data/repositories/analytics_repository.dart';

// Data sources
import '../../data/datasources/local/local_data_source.dart';
import '../../data/datasources/remote/remote_data_source.dart';

// Use cases
import '../../domain/usecases/gateway_usecases.dart';
import '../../domain/usecases/settings_usecases.dart';
import '../../domain/usecases/analytics_usecases.dart';

// Models
import '../../domain/models/gateway_config.dart';

/// Глобальный экземпляр GetIt для dependency injection
final GetIt getIt = GetIt.instance;

/// Класс для инициализации dependency injection
class DependencyInjection {
  static final Logger _logger = Logger();

  /// Инициализация всех зависимостей
  static Future<void> init() async {
    _logger.i('Initializing dependency injection...');

    try {
      // Регистрация внешних зависимостей
      await _registerExternalDependencies();

      // Регистрация сервисов
      _registerServices();

      // Регистрация data sources
      _registerDataSources();

      // Регистрация repositories
      _registerRepositories();

      // Регистрация use cases
      _registerUseCases();

      // Регистрация провайдеров
      _registerProviders();

      // Регистрация моделей
      _registerModels();

      _logger.i('Dependency injection initialized successfully');
    } catch (error, stackTrace) {
      _logger.e('Failed to initialize dependency injection',
                error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Регистрация внешних зависимостей
  static Future<void> _registerExternalDependencies() async {
    // SharedPreferences
    final sharedPreferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<SharedPreferences>(sharedPreferences);

    // HTTP Client
    getIt.registerLazySingleton<http.Client>(() => http.Client());

    // Logger
    getIt.registerLazySingleton<Logger>(() => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
      ),
    ));
  }

  /// Регистрация сервисов
  static void _registerServices() {
    // Core services
    getIt.registerLazySingleton<StorageService>(
      () => StorageService(getIt<SharedPreferences>()),
    );

    getIt.registerLazySingleton<NetworkService>(
      () => NetworkService(getIt<http.Client>()),
    );

    getIt.registerLazySingleton<DeviceService>(
      () => DeviceService(),
    );

    getIt.registerLazySingleton<PermissionService>(
      () => PermissionService(),
    );

    // Business services
    getIt.registerLazySingleton<ThemeService>(
      () => ThemeService(getIt<StorageService>()),
    );

    getIt.registerLazySingleton<LocalizationService>(
      () => LocalizationService(getIt<StorageService>()),
    );

    getIt.registerLazySingleton<SecurityService>(
      () => SecurityService(),
    );

    getIt.registerLazySingleton<CacheService>(
      () => CacheService(getIt<StorageService>()),
    );

    getIt.registerLazySingleton<ApiService>(
      () => ApiService(
        getIt<http.Client>(),
        getIt<NetworkService>(),
        getIt<Logger>(),
      ),
    );

    getIt.registerLazySingleton<NotificationService>(
      () => NotificationService(),
    );

    getIt.registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(
        getIt<ApiService>(),
        getIt<StorageService>(),
        getIt<AnalyticsUseCases>(),
        getIt<Logger>(),
      ),
    );

    // SIP services
    getIt.registerLazySingleton<SipService>(() => SipService());

    getIt.registerLazySingleton<SipRepository>(
      () => SipRepositoryImpl(getIt<SipService>(), getIt<Logger>()),
    );

    // Gateway services
    getIt.registerLazySingleton<GatewayService>(() => GatewayService());

    getIt.registerLazySingleton<GatewayRepository>(
      () => GatewayRepositoryImpl(getIt<GatewayService>(), getIt<Logger>()),
    );
  }

  /// Регистрация data sources
  static void _registerDataSources() {
    getIt.registerLazySingleton<LocalDataSource>(
      () => LocalDataSource(getIt<StorageService>()),
    );

    getIt.registerLazySingleton<RemoteDataSource>(
      () => RemoteDataSource(
        getIt<ApiService>(),
        getIt<NetworkService>(),
        getIt<Logger>(),
      ),
    );
  }

  /// Регистрация repositories
  static void _registerRepositories() {
    getIt.registerLazySingleton<SettingsRepository>(
      () => SettingsRepository(
        getIt<LocalDataSource>(),
        getIt<RemoteDataSource>(),
        getIt<Logger>(),
      ),
    );

    getIt.registerLazySingleton<AnalyticsRepository>(
      () => AnalyticsRepository(
        getIt<LocalDataSource>(),
        getIt<RemoteDataSource>(),
        getIt<Logger>(),
      ),
    );
  }

  /// Регистрация use cases
  static void _registerUseCases() {
    getIt.registerLazySingleton<SettingsUseCases>(
      () => SettingsUseCases(getIt<SettingsRepository>()),
    );

    getIt.registerLazySingleton<AnalyticsUseCases>(
      () => AnalyticsUseCases(getIt<AnalyticsRepository>()),
    );

    // SIP use cases
    getIt.registerLazySingleton<InitializeSip>(
      () => InitializeSip(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<DestroySip>(
      () => DestroySip(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<CreateSipAccount>(
      () => CreateSipAccount(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<DeleteSipAccount>(
      () => DeleteSipAccount(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<GetSipAccount>(
      () => GetSipAccount(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<GetAllSipAccounts>(
      () => GetAllSipAccounts(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<MakeSipCall>(
      () => MakeSipCall(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<AnswerSipCall>(
      () => AnswerSipCall(getIt<SipRepository>()),
    );
    getIt.registerLazySingleton<HangupSipCall>(
      () => HangupSipCall(getIt<SipRepository>()),
    );

    // Gateway use cases
    getIt.registerLazySingleton<InitializeGateway>(
      () => InitializeGateway(getIt<GatewayRepository>()),
    );
    getIt.registerLazySingleton<StartGateway>(
      () => StartGateway(getIt<GatewayRepository>()),
    );
    getIt.registerLazySingleton<StopGateway>(
      () => StopGateway(getIt<GatewayRepository>()),
    );
    getIt.registerLazySingleton<MakeGatewaySipCall>(
      () => MakeGatewaySipCall(getIt<GatewayRepository>()),
    );
    getIt.registerLazySingleton<SendGatewaySms>(
      () => SendGatewaySms(getIt<GatewayRepository>()),
    );
    getIt.registerLazySingleton<GetGatewayStatus>(
      () => GetGatewayStatus(getIt<GatewayRepository>()),
    );
  }

  /// Регистрация провайдеров
  static void _registerProviders() {
    // SIP Provider
    getIt.registerFactory<SipProvider>(
      () => SipProvider(getIt<SipRepository>(), getIt<Logger>()),
    );

    // Gateway Provider
    getIt.registerFactory<GatewayProvider>(
      () => GatewayProvider(getIt<GatewayRepository>(), getIt<Logger>()),
    );
  }

  /// Регистрация моделей
  static void _registerModels() {
    // Singleton модели, которые могут быть переиспользованы
    getIt.registerLazySingleton<GatewayConfig>(
      () => GatewayConfig.defaultConfig(),
    );
  }

  /// Получение экземпляра по типу
  static T get<T extends Object>() {
    return getIt<T>();
  }

  /// Проверка регистрации зависимости
  static bool isRegistered<T extends Object>() {
    return getIt.isRegistered<T>();
  }

  /// Сброс всех зависимостей (для тестирования)
  static Future<void> reset() async {
    await getIt.reset();
    _logger.i('Dependency injection reset');
  }

  /// Проверка состояния dependency injection
  static bool isInitialized() {
    return getIt.isRegistered<SharedPreferences>() &&
           getIt.isRegistered<Logger>() &&
           getIt.isRegistered<ThemeService>() &&
           getIt.isRegistered<LocalizationService>();
  }
}

/// Расширение для удобного доступа к зависимостям
extension DependencyInjectionExtension on Object {
  T get<T extends Object>() => DependencyInjection.get<T>();
  
  bool has<T extends Object>() => DependencyInjection.isRegistered<T>();
}

/// Класс для управления жизненным циклом зависимостей
class DependencyLifecycleManager {
  static final Logger _logger = Logger();

  /// Инициализация сервисов при запуске приложения
  static Future<void> initializeServices() async {
    _logger.i('Initializing application services...');

    try {
      // Инициализация аналитики
      final analyticsService = DependencyInjection.get<AnalyticsService>();
      await analyticsService.initialize();

      // Инициализация уведомлений
      final notificationService = DependencyInjection.get<NotificationService>();
      await notificationService.initialize();

      // Инициализация сетевого мониторинга
      final networkService = DependencyInjection.get<NetworkService>();
      await networkService.initialize();

      _logger.i('Application services initialized successfully');
    } catch (error, stackTrace) {
      _logger.e('Failed to initialize application services', 
                error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  /// Очистка ресурсов при закрытии приложения
  static Future<void> disposeServices() async {
    _logger.i('Disposing application services...');

    try {
      // Очистка HTTP клиента
      final httpClient = DependencyInjection.get<http.Client>();
      httpClient.close();

      // Очистка аналитики
      final analyticsService = DependencyInjection.get<AnalyticsService>();
      await analyticsService.dispose();

      // Очистка уведомлений
      final notificationService = DependencyInjection.get<NotificationService>();
      await notificationService.dispose();

      // Очистка сетевого сервиса
      final networkService = DependencyInjection.get<NetworkService>();
      await networkService.dispose();

      _logger.i('Application services disposed successfully');
    } catch (error, stackTrace) {
      _logger.e('Failed to dispose application services', 
                error: error, stackTrace: stackTrace);
    }
  }

  /// Проверка здоровья сервисов
  static Future<Map<String, bool>> checkServicesHealth() async {
    final healthStatus = <String, bool>{};

    try {
      // Проверка сетевого сервиса
      final networkService = DependencyInjection.get<NetworkService>();
      healthStatus['network'] = await networkService.isConnected();

      // Проверка API сервиса
      final apiService = DependencyInjection.get<ApiService>();
      healthStatus['api'] = await apiService.isHealthy();

      // Проверка хранилища
      final storageService = DependencyInjection.get<StorageService>();
      healthStatus['storage'] = await storageService.isAvailable();

      _logger.i('Services health check completed: $healthStatus');
    } catch (error, stackTrace) {
      _logger.e('Failed to check services health', 
                error: error, stackTrace: stackTrace);
      healthStatus['error'] = false;
    }

    return healthStatus;
  }
}
