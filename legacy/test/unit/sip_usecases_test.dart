import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_gsm_sip_gateway/domain/usecases/sip_usecases.dart';
import 'package:flutter_gsm_sip_gateway/domain/entities/sip_account.dart';
import 'package:flutter_gsm_sip_gateway/domain/entities/sip_call.dart';
import 'package:flutter_gsm_sip_gateway/core/error/failures.dart';

import 'sip_usecases_test.mocks.dart';

@GenerateMocks([SipRepository])
void main() {
  group('SIP Use Cases', () {
    late MockSipRepository mockRepository;
    late InitializeSip initializeSip;
    late DestroySip destroySip;
    late CreateSipAccount createSipAccount;
    late DeleteSipAccount deleteSipAccount;
    late MakeSipCall makeSipCall;
    late AnswerSipCall answerSipCall;
    late HangupSipCall hangupSipCall;

    setUp(() {
      mockRepository = MockSipRepository();
      initializeSip = InitializeSip(mockRepository);
      destroySip = DestroySip(mockRepository);
      createSipAccount = CreateSipAccount(mockRepository);
      deleteSipAccount = DeleteSipAccount(mockRepository);
      makeSipCall = MakeSipCall(mockRepository);
      answerSipCall = AnswerSipCall(mockRepository);
      hangupSipCall = HangupSipCall(mockRepository);
    });

    group('InitializeSip', () {
      final testConfig = {
        'server': 'sip.example.com',
        'port': 5060,
        'username': 'testuser',
        'password': 'testpass',
      };

      test('should initialize SIP endpoint successfully', () async {
        // arrange
        when(mockRepository.initialize(testConfig))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await initializeSip(testConfig);

        // assert
        expect(result, const Right(null));
        verify(mockRepository.initialize(testConfig));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when initialization fails', () async {
        // arrange
        when(mockRepository.initialize(testConfig))
            .thenAnswer((_) async => Left(ServerFailure('Failed to initialize SIP')));

        // act
        final result = await initializeSip(testConfig);

        // assert
        expect(result, Left(ServerFailure('Failed to initialize SIP')));
        verify(mockRepository.initialize(testConfig));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('DestroySip', () {
      test('should destroy SIP endpoint successfully', () async {
        // arrange
        when(mockRepository.destroy())
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await destroySip();

        // assert
        expect(result, const Right(null));
        verify(mockRepository.destroy());
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return failure when destruction fails', () async {
        // arrange
        when(mockRepository.destroy())
            .thenAnswer((_) async => Left(ServerFailure('Failed to destroy SIP')));

        // act
        final result = await destroySip();

        // assert
        expect(result, Left(ServerFailure('Failed to destroy SIP')));
        verify(mockRepository.destroy());
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('CreateSipAccount', () {
      final validAccount = SipAccount(
        id: 'account1',
        username: 'testuser',
        password: 'testpass',
        domain: 'sip.example.com',
        port: 5060,
      );

      final invalidAccount = SipAccount(
        id: '',
        username: '',
        password: '',
        domain: '',
        port: 5060,
      );

      test('should create account successfully when account is valid', () async {
        // arrange
        when(mockRepository.createAccount(validAccount))
            .thenAnswer((_) async => Right(validAccount));

        // act
        final result = await createSipAccount(validAccount);

        // assert
        expect(result, Right(validAccount));
        verify(mockRepository.createAccount(validAccount));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return validation failure when account is invalid', () async {
        // act
        final result = await createSipAccount(invalidAccount);

        // assert
        expect(result, isA<Left<ValidationFailure, SipAccount>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Invalid account configuration');
        verifyZeroInteractions(mockRepository);
      });

      test('should return failure when repository fails', () async {
        // arrange
        when(mockRepository.createAccount(validAccount))
            .thenAnswer((_) async => Left(ServerFailure('Failed to create account')));

        // act
        final result = await createSipAccount(validAccount);

        // assert
        expect(result, Left(ServerFailure('Failed to create account')));
        verify(mockRepository.createAccount(validAccount));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('DeleteSipAccount', () {
      const testAccountId = 'account1';

      test('should delete account successfully', () async {
        // arrange
        when(mockRepository.deleteAccount(testAccountId))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await deleteSipAccount(testAccountId);

        // assert
        expect(result, const Right(null));
        verify(mockRepository.deleteAccount(testAccountId));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return validation failure when account ID is empty', () async {
        // act
        final result = await deleteSipAccount('');

        // assert
        expect(result, isA<Left<ValidationFailure, void>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Account ID is required');
        verifyZeroInteractions(mockRepository);
      });

      test('should return failure when deletion fails', () async {
        // arrange
        when(mockRepository.deleteAccount(testAccountId))
            .thenAnswer((_) async => Left(ServerFailure('Failed to delete account')));

        // act
        final result = await deleteSipAccount(testAccountId);

        // assert
        expect(result, Left(ServerFailure('Failed to delete account')));
        verify(mockRepository.deleteAccount(testAccountId));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('MakeSipCall', () {
      const testAccountId = 'account1';
      const testNumber = '+1234567890';
      final testCall = SipCall(
        id: 'call1',
        accountId: testAccountId,
        destination: testNumber,
        state: SipCallState.calling,
      );

      test('should make call successfully', () async {
        // arrange
        when(mockRepository.makeCall(testAccountId, testNumber))
            .thenAnswer((_) async => Right(testCall));

        // act
        final result = await makeSipCall(testAccountId, testNumber);

        // assert
        expect(result, Right(testCall));
        verify(mockRepository.makeCall(testAccountId, testNumber));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return validation failure when account ID is empty', () async {
        // act
        final result = await makeSipCall('', testNumber);

        // assert
        expect(result, isA<Left<ValidationFailure, SipCall>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Account ID is required');
        verifyZeroInteractions(mockRepository);
      });

      test('should return validation failure when number is empty', () async {
        // act
        final result = await makeSipCall(testAccountId, '');

        // assert
        expect(result, isA<Left<ValidationFailure, SipCall>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Destination number is required');
        verifyZeroInteractions(mockRepository);
      });

      test('should return failure when call initiation fails', () async {
        // arrange
        when(mockRepository.makeCall(testAccountId, testNumber))
            .thenAnswer((_) async => Left(ServerFailure('Failed to make call')));

        // act
        final result = await makeSipCall(testAccountId, testNumber);

        // assert
        expect(result, Left(ServerFailure('Failed to make call')));
        verify(mockRepository.makeCall(testAccountId, testNumber));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('AnswerSipCall', () {
      const testCallId = 'call1';

      test('should answer call successfully', () async {
        // arrange
        when(mockRepository.answerCall(testCallId))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await answerSipCall(testCallId);

        // assert
        expect(result, const Right(null));
        verify(mockRepository.answerCall(testCallId));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return validation failure when call ID is empty', () async {
        // act
        final result = await answerSipCall('');

        // assert
        expect(result, isA<Left<ValidationFailure, void>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Call ID is required');
        verifyZeroInteractions(mockRepository);
      });

      test('should return failure when answering fails', () async {
        // arrange
        when(mockRepository.answerCall(testCallId))
            .thenAnswer((_) async => Left(ServerFailure('Failed to answer call')));

        // act
        final result = await answerSipCall(testCallId);

        // assert
        expect(result, Left(ServerFailure('Failed to answer call')));
        verify(mockRepository.answerCall(testCallId));
        verifyNoMoreInteractions(mockRepository);
      });
    });

    group('HangupSipCall', () {
      const testCallId = 'call1';

      test('should hangup call successfully', () async {
        // arrange
        when(mockRepository.hangupCall(testCallId))
            .thenAnswer((_) async => const Right(null));

        // act
        final result = await hangupSipCall(testCallId);

        // assert
        expect(result, const Right(null));
        verify(mockRepository.hangupCall(testCallId));
        verifyNoMoreInteractions(mockRepository);
      });

      test('should return validation failure when call ID is empty', () async {
        // act
        final result = await hangupSipCall('');

        // assert
        expect(result, isA<Left<ValidationFailure, void>>());
        final failure = (result as Left).value;
        expect(failure, isA<ValidationFailure>());
        expect(failure.message, 'Call ID is required');
        verifyZeroInteractions(mockRepository);
      });

      test('should return failure when hangup fails', () async {
        // arrange
        when(mockRepository.hangupCall(testCallId))
            .thenAnswer((_) async => Left(ServerFailure('Failed to hangup call')));

        // act
        final result = await hangupSipCall(testCallId);

        // assert
        expect(result, Left(ServerFailure('Failed to hangup call')));
        verify(mockRepository.hangupCall(testCallId));
        verifyNoMoreInteractions(mockRepository);
      });
    });
  });
}
