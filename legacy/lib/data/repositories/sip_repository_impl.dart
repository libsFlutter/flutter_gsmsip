/// SIP Repository Implementation
/// Implements SipRepository using SipService for native operations

import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import '../services/sip_service.dart';
import '../../domain/entities/sip_account.dart';
import '../../domain/entities/sip_call.dart';
import '../../domain/entities/sip_event.dart';
import '../../domain/repositories/sip_repository.dart';
import '../../../core/error/failures.dart';

/// SIP Repository Implementation
///
/// Implements the SipRepository interface using SipService for native operations.
/// Handles error mapping and Result pattern conversion.
class SipRepositoryImpl implements SipRepository {
  final SipService _service;
  final Logger _logger;

  SipRepositoryImpl(this._service, this._logger);

  @override
  AsyncSipResult<void> initialize(Map<String, dynamic> config) async {
    try {
      if (!_service.isInitialized) {
        await _service.initialize();
      }
      await _service.initializeEndpoint(config);
      _logger.i('SIP endpoint initialized');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to initialize SIP', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to initialize SIP: $e',
        serviceName: 'SipService',
      ));
    }
  }

  @override
  AsyncSipResult<void> destroy() async {
    try {
      await _service.destroyEndpoint();
      _logger.i('SIP endpoint destroyed');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to destroy SIP', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to destroy SIP: $e',
        serviceName: 'SipService',
      ));
    }
  }

  // ==================== Account Operations ====================

  @override
  AsyncSipResult<SipAccount> createAccount(SipAccount account) async {
    try {
      final model = SipAccountModel.fromEntity(account);
      final result = await _service.createAccount(model);
      _logger.i('SIP account created: ${result.id}');
      return Right(result.toEntity());
    } catch (e) {
      _logger.e('Failed to create SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to create account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> deleteAccount(String accountId) async {
    try {
      await _service.deleteAccount(accountId);
      _logger.i('SIP account deleted: $accountId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to delete SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to delete account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<SipAccount?> getAccount(String accountId) async {
    try {
      final model = await _service.getAccount(accountId);
      return Right(model?.toEntity());
    } catch (e) {
      _logger.e('Failed to get SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to get account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<List<SipAccount>> getAccounts() async {
    try {
      final models = await _service.getAccounts();
      return Right(models.map((m) => m.toEntity()).toList());
    } catch (e) {
      _logger.e('Failed to get SIP accounts', error: e);
      return Left(SipFailure(
        message: 'Failed to get accounts: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<SipAccount?> getDefaultAccount() async {
    try {
      final accounts = await getAccounts();
      return accounts.fold(
        (failure) => Left(failure),
        (accountList) {
          final defaultAccount = accountList.firstWhere(
            (a) => a.isDefault,
            orElse: () => accountList.isNotEmpty ? accountList.first : const SipAccount(id: '', username: '', password: '', domain: ''),
          );
          return Right(defaultAccount);
        },
      );
    } catch (e) {
      _logger.e('Failed to get default SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to get default account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> setDefaultAccount(String accountId) async {
    try {
      // This would need native support - for now just a placeholder
      _logger.w('setDefaultAccount not fully implemented');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to set default account', error: e);
      return Left(SipFailure(
        message: 'Failed to set default account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> registerAccount(String accountId, {bool reregister = false}) async {
    try {
      await _service.registerAccount(accountId, reregister: reregister);
      _logger.i('SIP account registered: $accountId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to register SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to register account: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> unregisterAccount(String accountId) async {
    try {
      await _service.unregisterAccount(accountId);
      _logger.i('SIP account unregistered: $accountId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to unregister SIP account', error: e);
      return Left(SipFailure(
        message: 'Failed to unregister account: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Call Operations ====================

  @override
  AsyncSipResult<SipCall> makeCall(String accountId, String number) async {
    try {
      final model = await _service.makeCall(accountId, number);
      _logger.i('SIP call made: ${model.id} to $number');
      return Right(model.toEntity());
    } catch (e) {
      _logger.e('Failed to make SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to make call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> answerCall(String callId) async {
    try {
      await _service.answerCall(callId);
      _logger.i('SIP call answered: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to answer SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to answer call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> declineCall(String callId) async {
    try {
      await _service.declineCall(callId);
      _logger.i('SIP call declined: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to decline SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to decline call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> hangupCall(String callId) async {
    try {
      await _service.hangupCall(callId);
      _logger.i('SIP call hung up: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to hangup SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to hangup call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> holdCall(String callId) async {
    try {
      await _service.holdCall(callId);
      _logger.i('SIP call held: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to hold SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to hold call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> unholdCall(String callId) async {
    try {
      await _service.unholdCall(callId);
      _logger.i('SIP call unheld: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to unhold SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to unhold call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> muteCall(String callId) async {
    try {
      await _service.muteCall(callId);
      _logger.i('SIP call muted: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to mute SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to mute call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> unmuteCall(String callId) async {
    try {
      await _service.unmuteCall(callId);
      _logger.i('SIP call unmuted: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to unmute SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to unmute call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> useSpeaker(String callId) async {
    try {
      await _service.useSpeaker(callId);
      _logger.i('SIP call using speaker: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to use speaker for SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to use speaker: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> useEarpiece(String callId) async {
    try {
      await _service.useEarpiece(callId);
      _logger.i('SIP call using earpiece: $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to use earpiece for SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to use earpiece: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> sendDtmf(String callId, String digit) async {
    try {
      await _service.sendDtmf(callId, digit);
      _logger.d('DTMF sent: $digit on call $callId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to send DTMF', error: e);
      return Left(SipFailure(
        message: 'Failed to send DTMF: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> transferCall(String callId, String destination) async {
    try {
      await _service.transferCall(callId, destination);
      _logger.i('SIP call transferred: $callId to $destination');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to transfer SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to transfer call: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> attendedTransfer(String callId, String targetCallId) async {
    try {
      await _service.attendedTransfer(callId, targetCallId);
      _logger.i('SIP call attended transfer: $callId to $targetCallId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to attended transfer SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to attended transfer: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncSipResult<void> redirectCall(String callId, String destination) async {
    try {
      await _service.redirectCall(callId, destination);
      _logger.i('SIP call redirected: $callId to $destination');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to redirect SIP call', error: e);
      return Left(SipFailure(
        message: 'Failed to redirect call: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Event Streams ====================

  @override
  Stream<SipEvent> get eventStream => _service.eventStream;

  @override
  Stream<SipEvent> get accountStream => _service.accountStream;

  @override
  Stream<SipEvent> get callStream => _service.callStream;

  @override
  Stream<bool> get connectivityStream => _service.connectivityStream;

  // ==================== State Queries ====================

  @override
  bool get isInitialized => _service.isInitialized;

  @override
  bool get isConnected => _service.isConnected;

  @override
  int get accountCount => _service.accounts.length;

  @override
  int get activeCallCount => _service.activeCalls.length;

  @override
  List<SipCall> get activeCalls {
    return _service.activeCalls.map((c) => c.toEntity()).toList();
  }
}
