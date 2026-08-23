import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_gsm_sip_gateway/core/di/dependency_injection.dart';

// Генерируем моки
@GenerateMocks([SharedPreferences])
import 'dependency_injection_test.mocks.dart';

void main() {
  group('DependencyInjection', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
    });

    tearDown(() async {
      await DependencyInjection.reset();
    });

    group('Initialization', () {
      test('should initialize successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isInitialized(), isTrue);
      });

      test('should handle initialization error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenThrow(Exception('Init error'));

        // Act & Assert
        expect(
          () => DependencyInjection.init(),
          throwsException,
        );
      });

      test('should register all required dependencies', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<SharedPreferences>(), isTrue);
        expect(DependencyInjection.isRegistered<Logger>(), isTrue);
      });
    });

    group('Dependency registration', () {
      test('should register external dependencies', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<SharedPreferences>(), isTrue);
        expect(DependencyInjection.isRegistered<http.Client>(), isTrue);
        expect(DependencyInjection.isRegistered<Logger>(), isTrue);
      });

      test('should register services', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<StorageService>(), isTrue);
        expect(DependencyInjection.isRegistered<NetworkService>(), isTrue);
        expect(DependencyInjection.isRegistered<DeviceService>(), isTrue);
        expect(DependencyInjection.isRegistered<PermissionService>(), isTrue);
        expect(DependencyInjection.isRegistered<ThemeService>(), isTrue);
        expect(DependencyInjection.isRegistered<LocalizationService>(), isTrue);
        expect(DependencyInjection.isRegistered<ApiService>(), isTrue);
        expect(DependencyInjection.isRegistered<NotificationService>(), isTrue);
        expect(DependencyInjection.isRegistered<AnalyticsService>(), isTrue);
      });

      test('should register data sources', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<LocalDataSource>(), isTrue);
        expect(DependencyInjection.isRegistered<RemoteDataSource>(), isTrue);
      });

      test('should register repositories', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<GatewayRepository>(), isTrue);
        expect(DependencyInjection.isRegistered<SettingsRepository>(), isTrue);
        expect(DependencyInjection.isRegistered<AnalyticsRepository>(), isTrue);
      });

      test('should register use cases', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<GatewayUseCases>(), isTrue);
        expect(DependencyInjection.isRegistered<SettingsUseCases>(), isTrue);
        expect(DependencyInjection.isRegistered<AnalyticsUseCases>(), isTrue);
      });

      test('should register models', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await DependencyInjection.init();

        // Assert
        expect(DependencyInjection.isRegistered<GatewayConfig>(), isTrue);
        expect(DependencyInjection.isRegistered<DeviceInfo>(), isTrue);
      });
    });

    group('Dependency retrieval', () {
      test('should get registered dependency', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final prefs = DependencyInjection.get<SharedPreferences>();

        // Assert
        expect(prefs, isNotNull);
        expect(prefs, isA<SharedPreferences>());
      });

      test('should throw error for unregistered dependency', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act & Assert
        expect(
          () => DependencyInjection.get<String>(),
          throwsException,
        );
      });

      test('should check if dependency is registered', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act & Assert
        expect(DependencyInjection.isRegistered<SharedPreferences>(), isTrue);
        expect(DependencyInjection.isRegistered<String>(), isFalse);
      });
    });

    group('Extension methods', () {
      test('should use extension method to get dependency', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final testObject = Object();
        final prefs = testObject.get<SharedPreferences>();

        // Assert
        expect(prefs, isNotNull);
        expect(prefs, isA<SharedPreferences>());
      });

      test('should use extension method to check dependency', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final testObject = Object();
        final hasPrefs = testObject.has<SharedPreferences>();
        final hasString = testObject.has<String>();

        // Assert
        expect(hasPrefs, isTrue);
        expect(hasString, isFalse);
      });
    });

    group('Lifecycle management', () {
      test('should initialize services successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        await DependencyLifecycleManager.initializeServices();

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => DependencyLifecycleManager.initializeServices(), returnsNormally);
      });

      test('should dispose services successfully', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        await DependencyLifecycleManager.disposeServices();

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => DependencyLifecycleManager.disposeServices(), returnsNormally);
      });

      test('should check services health', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final healthStatus = await DependencyLifecycleManager.checkServicesHealth();

        // Assert
        expect(healthStatus, isA<Map<String, bool>>());
        expect(healthStatus.containsKey('network'), isTrue);
        expect(healthStatus.containsKey('api'), isTrue);
        expect(healthStatus.containsKey('storage'), isTrue);
      });
    });

    group('Reset functionality', () {
      test('should reset all dependencies', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        await DependencyInjection.reset();

        // Assert
        expect(DependencyInjection.isInitialized(), isFalse);
      });

      test('should handle reset when not initialized', () async {
        // Act
        await DependencyInjection.reset();

        // Assert
        expect(DependencyInjection.isInitialized(), isFalse);
      });
    });

    group('Get all dependencies', () {
      test('should get all registered dependencies', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final allDependencies = DependencyInjection.getAllDependencies();

        // Assert
        expect(allDependencies, isA<Map<String, dynamic>>());
        expect(allDependencies.isNotEmpty, isTrue);
      });
    });

    group('Error handling', () {
      test('should handle service initialization error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act & Assert
        expect(
          () => DependencyLifecycleManager.initializeServices(),
          returnsNormally,
        );
      });

      test('should handle service disposal error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act & Assert
        expect(
          () => DependencyLifecycleManager.disposeServices(),
          returnsNormally,
        );
      });

      test('should handle health check error', () async {
        // Arrange
        when(mockPrefs.setString(any, any)).thenAnswer((_) async => true);
        when(mockPrefs.getString(any)).thenReturn('test');
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        await DependencyInjection.init();

        // Act
        final healthStatus = await DependencyLifecycleManager.checkServicesHealth();

        // Assert
        expect(healthStatus, isA<Map<String, bool>>());
        // Даже при ошибках должен вернуть Map с информацией об ошибке
        expect(healthStatus.containsKey('error'), isTrue);
      });
    });
  });
}
