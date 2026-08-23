/// Gateway Use Cases
/// Encapsulates business logic for gateway operations

import 'package:dartz/dartz.dart';
import '../entities/gateway_config.dart';
import '../entities/gateway_status.dart';
import '../entities/call_routing.dart';
import '../repositories/gateway_repository.dart';
import '../../core/error/failures.dart';

// ==================== Lifecycle Use Cases ====================

/// Initialize gateway with configuration
class InitializeGateway {
  final GatewayRepository repository;

  InitializeGateway(this.repository);

  AsyncGatewayResult<void> call(GatewayConfig config) async {
    if (!config.isValid) {
      return Left(ValidationFailure(
        message: 'Invalid gateway configuration',
        fieldErrors: {'errors': config.validationErrors.join(', ')},
      ));
    }
    return await repository.initialize(config);
  }
}

/// Start gateway routing
class StartGateway {
  final GatewayRepository repository;

  StartGateway(this.repository);

  AsyncGatewayResult<void> call() async {
    return await repository.start();
  }
}

/// Stop gateway routing
class StopGateway {
  final GatewayRepository repository;

  StopGateway(this.repository);

  AsyncGatewayResult<void> call() async {
    return await repository.stop();
  }
}

/// Dispose gateway resources
class DisposeGateway {
  final GatewayRepository repository;

  DisposeGateway(this.repository);

  AsyncGatewayResult<void> call() async {
    return await repository.dispose();
  }
}

// ==================== Configuration Use Cases ====================

/// Get current configuration
class GetGatewayConfig {
  final GatewayRepository repository;

  GetGatewayConfig(this.repository);

  GatewayResult<GatewayConfig?> call() {
    return repository.getConfig();
  }
}

/// Save configuration
class SaveGatewayConfig {
  final GatewayRepository repository;

  SaveGatewayConfig(this.repository);

  AsyncGatewayResult<void> call(GatewayConfig config) async {
    if (!config.isValid) {
      return Left(ValidationFailure(
        message: 'Invalid gateway configuration',
        fieldErrors: {'errors': config.validationErrors.join(', ')},
      ));
    }
    return await repository.saveConfig(config);
  }
}

/// Load configuration from storage
class LoadGatewayConfig {
  final GatewayRepository repository;

  LoadGatewayConfig(this.repository);

  AsyncGatewayResult<GatewayConfig?> call() async {
    return await repository.loadConfig();
  }
}

// ==================== Call Use Cases ====================

/// Make call via SIP (SIP→GSM routing)
class MakeGatewaySipCall {
  final GatewayRepository repository;

  MakeGatewaySipCall(this.repository);

  AsyncGatewayResult<String?> call(String number) async {
    if (number.isEmpty) {
      return Left(ValidationFailure(message: 'Destination number is required'));
    }
    return await repository.makeCallViaSip(number);
  }
}

/// Make call via GSM (GSM→SIP routing)
class MakeGatewayGsmCall {
  final GatewayRepository repository;

  MakeGatewayGsmCall(this.repository);

  AsyncGatewayResult<String?> call(String number) async {
    if (number.isEmpty) {
      return Left(ValidationFailure(message: 'Destination number is required'));
    }
    return await repository.makeCallViaGsm(number);
  }
}

// ==================== SMS Use Cases ====================

/// Send SMS via gateway
class SendGatewaySms {
  final GatewayRepository repository;

  SendGatewaySms(this.repository);

  AsyncGatewayResult<String?> call(String recipient, String content, {bool useSmpp = false}) async {
    if (recipient.isEmpty) {
      return Left(ValidationFailure(message: 'Recipient is required'));
    }
    if (content.isEmpty) {
      return Left(ValidationFailure(message: 'Message content is required'));
    }
    return await repository.sendSms(recipient, content, useSmpp: useSmpp);
  }
}

// ==================== Routing Use Cases ====================

/// Get routing by ID
class GetGatewayRouting {
  final GatewayRepository repository;

  GetGatewayRouting(this.repository);

  GatewayResult<CallRouting?> call(String routingId) {
    if (routingId.isEmpty) {
      return Left(ValidationFailure(message: 'Routing ID is required'));
    }
    return repository.getRouting(routingId);
  }
}

/// Get all active routings
class GetActiveGatewayRoutings {
  final GatewayRepository repository;

  GetActiveGatewayRoutings(this.repository);

  GatewayResult<List<CallRouting>> call() {
    return repository.getActiveRoutings();
  }
}

/// End specific routing
class EndGatewayRouting {
  final GatewayRepository repository;

  EndGatewayRouting(this.repository);

  AsyncGatewayResult<void> call(String routingId) async {
    if (routingId.isEmpty) {
      return Left(ValidationFailure(message: 'Routing ID is required'));
    }
    return await repository.endRouting(routingId);
  }
}

/// End all active routings
class EndAllGatewayRoutings {
  final GatewayRepository repository;

  EndAllGatewayRoutings(this.repository);

  AsyncGatewayResult<void> call() async {
    return await repository.endAllRoutings();
  }
}

// ==================== Statistics Use Cases ====================

/// Get gateway statistics
class GetGatewayStatistics {
  final GatewayRepository repository;

  GetGatewayStatistics(this.repository);

  GatewayResult<Map<String, dynamic>> call() {
    return repository.getStatistics();
  }
}

/// Reset gateway statistics
class ResetGatewayStatistics {
  final GatewayRepository repository;

  ResetGatewayStatistics(this.repository);

  AsyncGatewayResult<void> call() async {
    return await repository.resetStatistics();
  }
}

// ==================== Status Use Cases ====================

/// Get current gateway status
class GetGatewayStatus {
  final GatewayRepository repository;

  GetGatewayStatus(this.repository);

  GatewayResult<GatewayStatus> call() {
    return repository.getStatus();
  }
}

/// Check if gateway is running
class IsGatewayRunning {
  final GatewayRepository repository;

  IsGatewayRunning(this.repository);

  bool call() {
    return repository.isRunning;
  }
}
