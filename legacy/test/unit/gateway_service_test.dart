import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_gsm_sip_gateway/domain/entities/gateway_config.dart';
import 'package:flutter_gsm_sip_gateway/domain/repositories/gateway_repository.dart';
import 'package:flutter_gsm_sip_gateway/domain/usecases/start_gateway_usecase.dart';
import 'package:flutter_gsm_sip_gateway/domain/usecases/stop_gateway_usecase.dart';
import 'package:flutter_gsm_sip_gateway/domain/usecases/get_gateway_status_usecase.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_gsm_sip_gateway/core/error/failures.dart';

import 'gateway_service_test.mocks.dart';

@GenerateMocks([GatewayRepository])
void main() {
  group('Gateway Use Cases', () {
    late MockGatewayRepository mockRepository;
    late StartGatewayUseCase startUseCase;
    late StopGatewayUseCase stopUseCase;
    late GetGatewayStatusUseCase statusUseCase;

    setUp(() {
      mockRepository = MockGatewayRepository();
      startUseCase = StartGatewayUseCase(mockRepository);
      stopUseCase = StopGatewayUseCase(mockRepository);
      statusUseCase = GetGatewayStatusUseCase(mockRepository);
    });

    group('StartGatewayUseCase', () {
      final testConfig = GatewayConfig(
        sipServer: 'test.server.com',
        sipPort: 5060,
        username: 'testuser',
        password: 'testpass',
        enabled: true,
      );

      test('should start gateway successfully', () async {
        // arrange
        when(mockRepository.startGateway(testConfig))
            .thenAnswer((_) async => const Right(true));

        // act
        final result = await startUseCase.execute(testConfig);

        // assert
        expect(result, const Right(true));
        verify(mockRepository.startGateway(testConfig));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when repository fails', () async {
        // arrange
        when(mockRepository.startGateway(testConfig))
            .thenAnswer((_) async => Left(ServerFailure('Failed to start')));

        // act
        final result = await startUseCase.execute(testConfig);

        // assert
        expect(result, Left(ServerFailure('Failed to start')));
        verify(mockRepository.startGateway(testConfig));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('StopGatewayUseCase', () {
      test('should stop gateway successfully', () async {
        // arrange
        when(mockRepository.stopGateway())
            .thenAnswer((_) async => const Right(true));

        // act
        final result = await stopUseCase.execute();

        // assert
        expect(result, const Right(true));
        verify(mockRepository.stopGateway());
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when repository fails', () async {
        // arrange
        when(mockRepository.stopGateway())
            .thenAnswer((_) async => Left(ServerFailure('Failed to stop')));

        // act
        final result = await stopUseCase.execute();

        // assert
        expect(result, Left(ServerFailure('Failed to stop')));
        verify(mockRepository.stopGateway());
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('GetGatewayStatusUseCase', () {
      test('should return gateway status successfully', () async {
        // arrange
        const expectedStatus = GatewayStatus.running;
        when(mockRepository.getGatewayStatus())
            .thenAnswer((_) async => const Right(expectedStatus));

        // act
        final result = await statusUseCase.execute();

        // assert
        expect(result, const Right(expectedStatus));
        verify(mockRepository.getGatewayStatus());
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when repository fails', () async {
        // arrange
        when(mockRepository.getGatewayStatus())
            .thenAnswer((_) async => Left(ServerFailure('Failed to get status')));

        // act
        final result = await statusUseCase.execute();

        // assert
        expect(result, Left(ServerFailure('Failed to get status')));
        verify(mockRepository.getGatewayStatus());
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
