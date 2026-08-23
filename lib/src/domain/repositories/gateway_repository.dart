/// Gateway Repository interface
/// Defines the contract for gateway operations

import 'package:dartz/dartz.dart';
import '../entities/gateway_config.dart';
import '../entities/gateway_status.dart';
import '../entities/call_routing.dart';
import '../../core/error/failures.dart';

/// Result type alias for gateway operations
typedef GatewayResult<T> = Either<Failure, T>;

/// Async Result type alias for gateway operations
typedef AsyncGatewayResult<T> = Future<Either<Failure, T>>;

/// Gateway Repository interface
///
/// Defines all gateway operations that can be performed.
/// Implementations should use the Result pattern for error handling.
abstract class GatewayRepository {
  // ==================== Lifecycle ====================

  /// Initialize gateway with configuration
  AsyncGatewayResult<void> initialize(GatewayConfig config);

  /// Start gateway routing
  AsyncGatewayResult<void> start();

  /// Stop gateway routing
  AsyncGatewayResult<void> stop();

  /// Dispose gateway resources
  AsyncGatewayResult<void> dispose();

  // ==================== Configuration ====================

  /// Get current configuration
  GatewayResult<GatewayConfig?> getConfig();

  /// Save configuration
  AsyncGatewayResult<void> saveConfig(GatewayConfig config);

  /// Load configuration from storage
  AsyncGatewayResult<GatewayConfig?> loadConfig();

  // ==================== Call Operations ====================

  /// Make call via SIP (SIP→GSM routing)
  /// Returns routing ID if successful
  AsyncGatewayResult<String?> makeCallViaSip(String number);

  /// Make call via GSM (GSM→SIP routing)
  /// Returns routing ID if successful
  AsyncGatewayResult<String?> makeCallViaGsm(String number);

  // ==================== SMS Operations ====================

  /// Send SMS
  /// [useSmpp] - If true and SMPP configured, use SMPP; otherwise use local GSM
  AsyncGatewayResult<String?> sendSms(String recipient, String content, {bool useSmpp = false});

  // ==================== Routing Management ====================

  /// Get routing by ID
  GatewayResult<CallRouting?> getRouting(String routingId);

  /// Get all active routings
  GatewayResult<List<CallRouting>> getActiveRoutings();

  /// End specific routing
  AsyncGatewayResult<void> endRouting(String routingId);

  /// End all active routings
  AsyncGatewayResult<void> endAllRoutings();

  // ==================== Statistics ====================

  /// Get current statistics
  GatewayResult<Map<String, dynamic>> getStatistics();

  /// Reset statistics
  AsyncGatewayResult<void> resetStatistics();

  // ==================== Status ====================

  /// Get current gateway status
  GatewayResult<GatewayStatus> getStatus();

  /// Check if gateway is running
  bool get isRunning;

  // ==================== Event Streams ====================

  /// Stream of gateway status updates
  Stream<GatewayStatus> get statusStream;

  /// Stream of call routing updates
  Stream<CallRouting> get routingStream;

  /// Stream of log messages
  Stream<String> get logStream;
}
