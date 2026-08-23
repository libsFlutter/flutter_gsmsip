/// Gateway Repository Implementation
/// Implements GatewayRepository using GatewayService

import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../services/gateway_service.dart' as service;
import '../../domain/entities/gateway_config.dart';
import '../../domain/entities/gateway_status.dart';
import '../../domain/entities/call_routing.dart';
import '../../domain/repositories/gateway_repository.dart';
import '../../core/error/failures.dart';

/// Gateway Repository Implementation
///
/// Implements the GatewayRepository interface using GatewayService.
/// Handles configuration persistence and Result pattern conversion.
class GatewayRepositoryImpl implements GatewayRepository {
  final service.GatewayService _service;
  final Logger _logger;

  static const String _configKey = 'gateway_config';

  GatewayRepositoryImpl(this._service, this._logger);

  @override
  bool get isRunning => _service.isRunning;

  // ==================== Lifecycle ====================

  @override
  AsyncGatewayResult<void> initialize(GatewayConfig config) async {
    try {
      final success = await _service.initialize(config);
      if (success) {
        _logger.i('Gateway initialized');
        return const Right(null);
      } else {
        return Left(ServiceUnavailableFailure(
          message: 'Gateway initialization failed',
          serviceName: 'GatewayService',
        ));
      }
    } catch (e) {
      _logger.e('Failed to initialize gateway', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to initialize gateway: $e',
        serviceName: 'GatewayService',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> start() async {
    try {
      final success = await _service.start();
      if (success) {
        _logger.i('Gateway started');
        return const Right(null);
      } else {
        return Left(ServiceUnavailableFailure(
          message: 'Gateway start failed',
          serviceName: 'GatewayService',
        ));
      }
    } catch (e) {
      _logger.e('Failed to start gateway', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to start gateway: $e',
        serviceName: 'GatewayService',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> stop() async {
    try {
      await _service.stop();
      _logger.i('Gateway stopped');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to stop gateway', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to stop gateway: $e',
        serviceName: 'GatewayService',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> dispose() async {
    try {
      _service.dispose();
      _logger.i('Gateway disposed');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to dispose gateway', error: e);
      return Left(ServiceUnavailableFailure(
        message: 'Failed to dispose gateway: $e',
        serviceName: 'GatewayService',
        originalError: e,
      ));
    }
  }

  // ==================== Configuration ====================

  @override
  GatewayResult<GatewayConfig?> getConfig() {
    try {
      return Right(_service.config);
    } catch (e) {
      _logger.e('Failed to get config', error: e);
      return Left(StorageFailure(
        message: 'Failed to get configuration: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> saveConfig(GatewayConfig config) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configJson = jsonEncode(config.toJson());
      await prefs.setString(_configKey, configJson);
      _logger.i('Configuration saved');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to save config', error: e);
      return Left(StorageFailure(
        message: 'Failed to save configuration: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<GatewayConfig?> loadConfig() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final configString = prefs.getString(_configKey);

      if (configString == null) {
        _logger.d('No saved configuration found');
        return const Right(null);
      }

      final configJson = jsonDecode(configString) as Map<String, dynamic>;
      final config = GatewayConfig.fromJson(configJson);
      _logger.i('Configuration loaded');
      return Right(config);
    } catch (e) {
      _logger.e('Failed to load config', error: e);
      return Left(StorageFailure(
        message: 'Failed to load configuration: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Call Operations ====================

  @override
  AsyncGatewayResult<String?> makeCallViaSip(String number) async {
    try {
      final routingId = await _service.makeCallViaSip(number);
      if (routingId != null) {
        _logger.i('Call made via SIP: $number, routing: $routingId');
        return Right(routingId);
      } else {
        return Left(SipFailure(message: 'Failed to make call via SIP'));
      }
    } catch (e) {
      _logger.e('Failed to make call via SIP', error: e);
      return Left(SipFailure(
        message: 'Failed to make call via SIP: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<String?> makeCallViaGsm(String number) async {
    try {
      final routingId = await _service.makeCallViaGsm(number);
      if (routingId != null) {
        _logger.i('Call made via GSM: $number, routing: $routingId');
        return Right(routingId);
      } else {
        return Left(TelephonyFailure(message: 'Failed to make call via GSM'));
      }
    } catch (e) {
      _logger.e('Failed to make call via GSM', error: e);
      return Left(TelephonyFailure(
        message: 'Failed to make call via GSM: $e',
        originalError: e,
      ));
    }
  }

  // ==================== SMS Operations ====================

  @override
  AsyncGatewayResult<String?> sendSms(String recipient, String content, {bool useSmpp = false}) async {
    try {
      final messageId = await _service.sendSms(recipient, content, useSmpp: useSmpp);
      if (messageId != null) {
        _logger.i('SMS sent: $recipient, id: $messageId');
        return Right(messageId);
      } else {
        return Left(SipFailure(message: 'Failed to send SMS'));
      }
    } catch (e) {
      _logger.e('Failed to send SMS', error: e);
      return Left(SipFailure(
        message: 'Failed to send SMS: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Routing Management ====================

  @override
  GatewayResult<CallRouting?> getRouting(String routingId) {
    try {
      return Right(_service.getRouting(routingId));
    } catch (e) {
      _logger.e('Failed to get routing', error: e);
      return Left(GatewayFailure(
        message: 'Failed to get routing: $e',
        originalError: e,
      ));
    }
  }

  @override
  GatewayResult<List<CallRouting>> getActiveRoutings() {
    try {
      return Right(_service.getActiveRoutings());
    } catch (e) {
      _logger.e('Failed to get active routings', error: e);
      return Left(GatewayFailure(
        message: 'Failed to get active routings: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> endRouting(String routingId) async {
    try {
      await _service.endRouting(routingId);
      _logger.i('Routing ended: $routingId');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to end routing', error: e);
      return Left(GatewayFailure(
        message: 'Failed to end routing: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> endAllRoutings() async {
    try {
      await _service.endAllRoutings();
      _logger.i('All routings ended');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to end all routings', error: e);
      return Left(GatewayFailure(
        message: 'Failed to end all routings: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Statistics ====================

  @override
  GatewayResult<Map<String, dynamic>> getStatistics() {
    try {
      return Right(_service.getStatistics());
    } catch (e) {
      _logger.e('Failed to get statistics', error: e);
      return Left(GatewayFailure(
        message: 'Failed to get statistics: $e',
        originalError: e,
      ));
    }
  }

  @override
  AsyncGatewayResult<void> resetStatistics() async {
    try {
      _service.resetStatistics();
      _logger.i('Statistics reset');
      return const Right(null);
    } catch (e) {
      _logger.e('Failed to reset statistics', error: e);
      return Left(GatewayFailure(
        message: 'Failed to reset statistics: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Status ====================

  @override
  GatewayResult<GatewayStatus> getStatus() {
    try {
      return Right(_service.getStatus());
    } catch (e) {
      _logger.e('Failed to get status', error: e);
      return Left(GatewayFailure(
        message: 'Failed to get status: $e',
        originalError: e,
      ));
    }
  }

  // ==================== Event Streams ====================

  @override
  Stream<GatewayStatus> get statusStream => _service.statusStream;

  @override
  Stream<CallRouting> get routingStream => _service.routingStream;

  @override
  Stream<String> get logStream => _service.logStream;
}
