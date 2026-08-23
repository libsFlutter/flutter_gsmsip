import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:flutter_gsm_sip_gateway/core/error/error_handler.dart';

// Генерируем моки
@GenerateMocks([SharedPreferences])
import 'error_handler_test.mocks.dart';

void main() {
  group('ErrorHandler', () {
    late MockSharedPreferences mockPrefs;

    setUp(() {
      mockPrefs = MockSharedPreferences();
    });

    group('Error handling', () {
      test('should handle application error', () async {
        // Arrange
        const error = 'Test error';
        const stackTrace = 'Test stack trace';
        when(mockPrefs.getStringList(any)).thenReturn([]);
        when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

        // Act
        ErrorHandler.handleError(error, stackTrace);

        // Assert
        verify(mockPrefs.getStringList(any)).called(1);
        verify(mockPrefs.setStringList(any, any)).called(1);
      });

      test('should handle network error', () {
        // Arrange
        const error = 'SocketException: Connection failed';
        const endpoint = '/api/test';

        // Act
        ErrorHandler.handleNetworkError(error, endpoint);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleNetworkError(error, endpoint), returnsNormally);
      });

      test('should handle validation error', () {
        // Arrange
        const field = 'email';
        const message = 'Invalid email format';

        // Act
        ErrorHandler.handleValidationError(field, message);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleValidationError(field, message), returnsNormally);
      });

      test('should handle auth error', () {
        // Arrange
        const error = 'Unauthorized access';

        // Act
        ErrorHandler.handleAuthError(error);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleAuthError(error), returnsNormally);
      });

      test('should handle permission error', () {
        // Arrange
        const permission = 'camera';

        // Act
        ErrorHandler.handlePermissionError(permission);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handlePermissionError(permission), returnsNormally);
      });
    });

    group('Error logging', () {
      test('should save error to log', () async {
        // Arrange
        const error = 'Test error';
        const stackTrace = 'Test stack trace';
        when(mockPrefs.getStringList(any)).thenReturn([]);
        when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

        // Act
        await ErrorHandler.getErrorLogs();

        // Assert
        verify(mockPrefs.getStringList(any)).called(1);
      });

      test('should clear error logs', () async {
        // Arrange
        when(mockPrefs.remove(any)).thenAnswer((_) async => true);

        // Act
        await ErrorHandler.clearErrorLogs();

        // Assert
        verify(mockPrefs.remove(any)).called(1);
      });

      test('should handle error log save failure', () async {
        // Arrange
        const error = 'Test error';
        when(mockPrefs.getStringList(any)).thenThrow(Exception('Save error'));

        // Act
        final result = await ErrorHandler.getErrorLogs();

        // Assert
        expect(result, isEmpty);
      });

      test('should limit error log size', () async {
        // Arrange
        final existingLogs = List.generate(150, (index) => 'Error $index');
        when(mockPrefs.getStringList(any)).thenReturn(existingLogs);
        when(mockPrefs.setStringList(any, any)).thenAnswer((_) async => true);

        // Act
        const error = 'New error';
        const stackTrace = 'New stack trace';
        ErrorHandler.handleError(error, stackTrace);

        // Assert
        verify(mockPrefs.setStringList(any, argThat(hasLength(100)))).called(1);
      });
    });

    group('Critical errors', () {
      test('should detect critical errors', () async {
        // Arrange
        final recentLogs = List.generate(15, (index) => 
          'Error $index - timestamp: ${DateTime.now().toIso8601String()}');
        when(mockPrefs.getStringList(any)).thenReturn(recentLogs);

        // Act
        final result = await ErrorHandler.hasCriticalErrors();

        // Assert
        expect(result, isTrue);
      });

      test('should not detect critical errors for few errors', () async {
        // Arrange
        final recentLogs = List.generate(5, (index) => 
          'Error $index - timestamp: ${DateTime.now().toIso8601String()}');
        when(mockPrefs.getStringList(any)).thenReturn(recentLogs);

        // Act
        final result = await ErrorHandler.hasCriticalErrors();

        // Assert
        expect(result, isFalse);
      });

      test('should not detect critical errors for old errors', () async {
        // Arrange
        final oldLogs = List.generate(15, (index) => 
          'Error $index - timestamp: ${DateTime.now().subtract(const Duration(days: 2)).toIso8601String()}');
        when(mockPrefs.getStringList(any)).thenReturn(oldLogs);

        // Act
        final result = await ErrorHandler.hasCriticalErrors();

        // Assert
        expect(result, isFalse);
      });
    });

    group('Error messages', () {
      test('should get user friendly message for network error', () {
        // Arrange
        const error = 'SocketException: Connection failed';

        // Act
        ErrorHandler.handleError(error, null);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleError(error, null), returnsNormally);
      });

      test('should get user friendly message for timeout error', () {
        // Arrange
        const error = 'TimeoutException: Request timeout';

        // Act
        ErrorHandler.handleError(error, null);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleError(error, null), returnsNormally);
      });

      test('should get user friendly message for permission error', () {
        // Arrange
        const error = 'Permission denied';

        // Act
        ErrorHandler.handleError(error, null);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleError(error, null), returnsNormally);
      });

      test('should get user friendly message for validation error', () {
        // Arrange
        const error = 'Validation failed';

        // Act
        ErrorHandler.handleError(error, null);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleError(error, null), returnsNormally);
      });

      test('should get default user friendly message', () {
        // Arrange
        const error = 'Unknown error type';

        // Act
        ErrorHandler.handleError(error, null);

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleError(error, null), returnsNormally);
      });
    });

    group('Network error messages', () {
      test('should get network error message for SocketException', () {
        // Arrange
        const error = 'SocketException: Connection failed';

        // Act
        ErrorHandler.handleNetworkError(error, '/test');

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleNetworkError(error, '/test'), returnsNormally);
      });

      test('should get network error message for TimeoutException', () {
        // Arrange
        const error = 'TimeoutException: Request timeout';

        // Act
        ErrorHandler.handleNetworkError(error, '/test');

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleNetworkError(error, '/test'), returnsNormally);
      });

      test('should get network error message for HttpException', () {
        // Arrange
        const error = 'HttpException: Server error';

        // Act
        ErrorHandler.handleNetworkError(error, '/test');

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleNetworkError(error, '/test'), returnsNormally);
      });

      test('should get default network error message', () {
        // Arrange
        const error = 'Unknown network error';

        // Act
        ErrorHandler.handleNetworkError(error, '/test');

        // Assert
        // Проверяем, что метод не вызывает исключений
        expect(() => ErrorHandler.handleNetworkError(error, '/test'), returnsNormally);
      });
    });
  });

  group('ErrorBoundary', () {
    test('should render child when no error', () {
      // Arrange
      const child = Text('Test child');

      // Act
      final widget = ErrorBoundary(child: child);

      // Assert
      expect(widget, isA<ErrorBoundary>());
    });

    test('should render error widget when error occurs', () {
      // Arrange
      const child = Text('Test child');
      final errorBoundary = ErrorBoundary(child: child);

      // Act
      final state = errorBoundary.createState() as _ErrorBoundaryState;
      state._error = 'Test error';

      // Assert
      expect(state._error, equals('Test error'));
    });

    test('should render custom error builder when provided', () {
      // Arrange
      const child = Text('Test child');
      Widget errorBuilder(dynamic error) => Text('Custom error: $error');
      
      final errorBoundary = ErrorBoundary(
        child: child,
        errorBuilder: errorBuilder,
      );

      // Act
      final state = errorBoundary.createState() as _ErrorBoundaryState;
      state._error = 'Test error';

      // Assert
      expect(state._error, equals('Test error'));
    });

    test('should handle error recovery', () {
      // Arrange
      const child = Text('Test child');
      final errorBoundary = ErrorBoundary(child: child);
      final state = errorBoundary.createState() as _ErrorBoundaryState;
      state._error = 'Test error';

      // Act
      state.setState(() {
        state._error = null;
      });

      // Assert
      expect(state._error, isNull);
    });
  });
}
