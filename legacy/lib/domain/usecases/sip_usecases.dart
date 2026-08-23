/// SIP Use Cases
/// Encapsulates business logic for SIP operations

import 'package:dartz/dartz.dart';
import '../entities/sip_account.dart';
import '../entities/sip_call.dart';
import '../entities/sip_event.dart';
import 'sip_repository.dart';
import '../../core/error/failures.dart';

/// Base class for SIP use cases
abstract class SipUseCase<T, Params> {
  final SipRepository repository;

  SipUseCase(this.repository);

  Either<Failure, T> call(Params params);
}

/// No parameters needed
class NoParams {
  const NoParams();
}

// ==================== Lifecycle Use Cases ====================

/// Initialize SIP endpoint
class InitializeSip {
  final SipRepository repository;

  InitializeSip(this.repository);

  AsyncSipResult<void> call(Map<String, dynamic> config) async {
    return await repository.initialize(config);
  }
}

/// Destroy SIP endpoint
class DestroySip {
  final SipRepository repository;

  DestroySip(this.repository);

  AsyncSipResult<void> call() async {
    return await repository.destroy();
  }
}

// ==================== Account Use Cases ====================

/// Create a new SIP account
class CreateSipAccount {
  final SipRepository repository;

  CreateSipAccount(this.repository);

  AsyncSipResult<SipAccount> call(SipAccount account) async {
    if (!account.isValid) {
      return Left(ValidationFailure(
        message: 'Invalid account configuration',
        fieldErrors: {
          'errors': account.validationErrors.join(', '),
        },
      ));
    }
    return await repository.createAccount(account);
  }
}

/// Delete a SIP account
class DeleteSipAccount {
  final SipRepository repository;

  DeleteSipAccount(this.repository);

  AsyncSipResult<void> call(String accountId) async {
    if (accountId.isEmpty) {
      return Left(ValidationFailure(message: 'Account ID is required'));
    }
    return await repository.deleteAccount(accountId);
  }
}

/// Get a SIP account
class GetSipAccount {
  final SipRepository repository;

  GetSipAccount(this.repository);

  AsyncSipResult<SipAccount?> call(String accountId) async {
    if (accountId.isEmpty) {
      return Left(ValidationFailure(message: 'Account ID is required'));
    }
    return await repository.getAccount(accountId);
  }
}

/// Get all SIP accounts
class GetAllSipAccounts {
  final SipRepository repository;

  GetAllSipAccounts(this.repository);

  AsyncSipResult<List<SipAccount>> call() async {
    return await repository.getAccounts();
  }
}

/// Register a SIP account
class RegisterSipAccount {
  final SipRepository repository;

  RegisterSipAccount(this.repository);

  AsyncSipResult<void> call(String accountId, {bool reregister = false}) async {
    if (accountId.isEmpty) {
      return Left(ValidationFailure(message: 'Account ID is required'));
    }
    return await repository.registerAccount(accountId, reregister: reregister);
  }
}

/// Unregister a SIP account
class UnregisterSipAccount {
  final SipRepository repository;

  UnregisterSipAccount(this.repository);

  AsyncSipResult<void> call(String accountId) async {
    if (accountId.isEmpty) {
      return Left(ValidationFailure(message: 'Account ID is required'));
    }
    return await repository.unregisterAccount(accountId);
  }
}

// ==================== Call Use Cases ====================

/// Make an outgoing SIP call
class MakeSipCall {
  final SipRepository repository;

  MakeSipCall(this.repository);

  AsyncSipResult<SipCall> call(String accountId, String number) async {
    if (accountId.isEmpty) {
      return Left(ValidationFailure(message: 'Account ID is required'));
    }
    if (number.isEmpty) {
      return Left(ValidationFailure(message: 'Destination number is required'));
    }
    return await repository.makeCall(accountId, number);
  }
}

/// Answer an incoming call
class AnswerSipCall {
  final SipRepository repository;

  AnswerSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.answerCall(callId);
  }
}

/// Decline an incoming call
class DeclineSipCall {
  final SipRepository repository;

  DeclineSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.declineCall(callId);
  }
}

/// Hangup a call
class HangupSipCall {
  final SipRepository repository;

  HangupSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.hangupCall(callId);
  }
}

/// Hold a call
class HoldSipCall {
  final SipRepository repository;

  HoldSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.holdCall(callId);
  }
}

/// Unhold a call
class UnholdSipCall {
  final SipRepository repository;

  UnholdSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.unholdCall(callId);
  }
}

/// Mute a call
class MuteSipCall {
  final SipRepository repository;

  MuteSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.muteCall(callId);
  }
}

/// Unmute a call
class UnmuteSipCall {
  final SipRepository repository;

  UnmuteSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.unmuteCall(callId);
  }
}

/// Use speaker for a call
class UseSpeakerSipCall {
  final SipRepository repository;

  UseSpeakerSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.useSpeaker(callId);
  }
}

/// Use earpiece for a call
class UseEarpieceSipCall {
  final SipRepository repository;

  UseEarpieceSipCall(this.repository);

  AsyncSipResult<void> call(String callId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    return await repository.useEarpiece(callId);
  }
}

/// Send DTMF tone
class SendDtmfSipCall {
  final SipRepository repository;

  SendDtmfSipCall(this.repository);

  AsyncSipResult<void> call(String callId, String digit) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    if (digit.isEmpty) {
      return Left(ValidationFailure(message: 'DTMF digit is required'));
    }
    // Validate DTMF digit
    final validDigits = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '*', '#', 'A', 'B', 'C', 'D'];
    if (!validDigits.contains(digit.toUpperCase())) {
      return Left(ValidationFailure(
        message: 'Invalid DTMF digit. Must be 0-9, *, #, or A-D',
      ));
    }
    return await repository.sendDtmf(callId, digit);
  }
}

/// Blind transfer a call
class TransferSipCall {
  final SipRepository repository;

  TransferSipCall(this.repository);

  AsyncSipResult<void> call(String callId, String destination) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    if (destination.isEmpty) {
      return Left(ValidationFailure(message: 'Transfer destination is required'));
    }
    return await repository.transferCall(callId, destination);
  }
}

/// Attended transfer a call
class AttendedTransferSipCall {
  final SipRepository repository;

  AttendedTransferSipCall(this.repository);

  AsyncSipResult<void> call(String callId, String targetCallId) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    if (targetCallId.isEmpty) {
      return Left(ValidationFailure(message: 'Target call ID is required'));
    }
    return await repository.attendedTransfer(callId, targetCallId);
  }
}

/// Redirect a call
class RedirectSipCall {
  final SipRepository repository;

  RedirectSipCall(this.repository);

  AsyncSipResult<void> call(String callId, String destination) async {
    if (callId.isEmpty) {
      return Left(ValidationFailure(message: 'Call ID is required'));
    }
    if (destination.isEmpty) {
      return Left(ValidationFailure(message: 'Redirect destination is required'));
    }
    return await repository.redirectCall(callId, destination);
  }
}

// ==================== Query Use Cases ====================

/// Get all active calls
class GetActiveSipCalls {
  final SipRepository repository;

  GetActiveSipCalls(this.repository);

  List<SipCall> call() {
    return repository.activeCalls;
  }
}

/// Check if connected
class IsSipConnected {
  final SipRepository repository;

  IsSipConnected(this.repository);

  bool call() {
    return repository.isConnected;
  }
}
