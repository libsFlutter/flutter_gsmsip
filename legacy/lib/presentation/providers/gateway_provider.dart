/// Gateway Provider
/// State management for gateway operations using Provider pattern

import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/gateway_config.dart';
import '../../domain/entities/gateway_status.dart';
import '../../domain/entities/call_routing.dart';
import '../../domain/repositories/gateway_repository.dart';

/// Gateway State
///
/// Immutable state object for gateway provider
class GatewayState {
  /// Whether gateway is running
  final bool isRunning;

  /// Current gateway status
  final GatewayStatus? status;

  /// Active routings
  final Map<String, CallRouting> activeRoutings;

  /// Error message (if any)
  final String? errorMessage;

  /// Whether is initializing
  final bool isInitializing;

  const GatewayState({
    this.isRunning = false,
    this.status,
    this.activeRoutings = const {},
    this.errorMessage,
    this.isInitializing = false,
  });

  /// Create a copy with updated fields
  GatewayState copyWith({
    bool? isRunning,
    GatewayStatus? status,
    Map<String, CallRouting>? activeRoutings,
    String? errorMessage,
    bool? isInitializing,
  }) {
    return GatewayState(
      isRunning: isRunning ?? this.isRunning,
      status: status ?? this.status,
      activeRoutings: activeRoutings ?? this.activeRoutings,
      errorMessage: errorMessage ?? this.errorMessage,
      isInitializing: isInitializing ?? this.isInitializing,
    );
  }

  /// Get active routing count
  int get activeRoutingCount => activeRoutings.length;

  /// Get active call count
  int get activeCallCount =>
      activeRoutings.values.where((r) => r.isActive).length;
}

/// Gateway Provider
///
/// Manages gateway state and operations using Provider pattern.
/// Listens to gateway events and updates state accordingly.
class GatewayProvider extends ChangeNotifier {
  final GatewayRepository _repository;
  final Logger _logger;

  GatewayState _state = const GatewayState();
  StreamSubscription? _statusSubscription;
  StreamSubscription? _routingSubscription;

  GatewayProvider(this._repository, this._logger) {
    _setupEventListeners();
  }

  /// Current gateway state
  GatewayState get state => _state;

  /// Get current status
  GatewayStatus? get status => _state.status;

  /// Check if running
  bool get isRunning => _state.isRunning;

  /// Get active routings
  Map<String, CallRouting> get activeRoutings => _state.activeRoutings;

  /// Get error message
  String? get errorMessage => _state.errorMessage;

  /// Setup event listeners
  void _setupEventListeners() {
    _statusSubscription = _repository.statusStream.listen(
      (status) {
        _updateState((state) => state.copyWith(status: status));
        notifyListeners();
      },
      onError: _handleError,
    );

    _routingSubscription = _repository.routingStream.listen(
      (routing) {
        _updateState((state) {
          final routings = {...state.activeRoutings, routing.id: routing};
          return state.copyWith(activeRoutings: routings);
        });
        notifyListeners();
      },
      onError: _handleError,
    );
  }

  /// Handle error
  void _handleError(dynamic error) {
    _logger.e('Gateway event stream error', error: error);
    _updateState((state) => state.copyWith(
          errorMessage: error.toString(),
        ));
    notifyListeners();
  }

  /// Update state
  void _updateState(GatewayState Function(GatewayState) update) {
    _state = update(_state);
  }

  // ==================== Lifecycle ====================

  /// Initialize gateway
  Future<bool> initialize(GatewayConfig config) async {
    try {
      _updateState((state) => state.copyWith(
            isInitializing: true,
            errorMessage: null,
          ));
      notifyListeners();

      final result = await _repository.initialize(config);

      return result.fold(
        (failure) {
          _logger.e('Failed to initialize gateway', error: failure);
          _updateState((state) => state.copyWith(
                isInitializing: false,
                errorMessage: failure.message,
              ));
          notifyListeners();
          return false;
        },
        (_) {
          _updateState((state) => state.copyWith(
                isInitializing: false,
                isRunning: false, // Initialized but not started yet
              ));
          notifyListeners();
          _logger.i('Gateway initialized successfully');
          return true;
        },
      );
    } catch (e) {
      _logger.e('Gateway initialization error', error: e);
      _updateState((state) => state.copyWith(
            isInitializing: false,
            errorMessage: e.toString(),
          ));
      notifyListeners();
      return false;
    }
  }

  /// Start gateway
  Future<bool> start() async {
    try {
      final result = await _repository.start();

      return result.fold(
        (failure) {
          _logger.e('Failed to start gateway', error: failure);
          _updateState((state) => state.copyWith(
                errorMessage: failure.message,
              ));
          notifyListeners();
          return false;
        },
        (_) {
          _updateState((state) => state.copyWith(
                isRunning: true,
              ));
          notifyListeners();
          _logger.i('Gateway started successfully');
          return true;
        },
      );
    } catch (e) {
      _logger.e('Gateway start error', error: e);
      _updateState((state) => state.copyWith(
            errorMessage: e.toString(),
          ));
      notifyListeners();
      return false;
    }
  }

  /// Stop gateway
  Future<bool> stop() async {
    try {
      final result = await _repository.stop();

      return result.fold(
        (failure) {
          _logger.e('Failed to stop gateway', error: failure);
          return false;
        },
        (_) {
          _updateState((state) => state.copyWith(
                isRunning: false,
              ));
          notifyListeners();
          _logger.i('Gateway stopped');
          return true;
        },
      );
    } catch (e) {
      _logger.e('Gateway stop error', error: e);
      return false;
    }
  }

  // ==================== Call Operations ====================

  /// Make call via SIP
  Future<String?> makeCall(String number) async {
    final result = await _repository.makeCallViaSip(number);
    return result.fold(
      (failure) {
        _logger.e('Failed to make call', error: failure);
        return null;
      },
      (routingId) {
        _logger.i('Call made, routing: $routingId');
        return routingId;
      },
    );
  }

  /// Send SMS
  Future<String?> sendSms(String recipient, String content) async {
    final result = await _repository.sendSms(recipient, content);
    return result.fold(
      (failure) {
        _logger.e('Failed to send SMS', error: failure);
        return null;
      },
      (messageId) {
        _logger.i('SMS sent, id: $messageId');
        return messageId;
      },
    );
  }

  /// End routing
  Future<bool> endRouting(String routingId) async {
    final result = await _repository.endRouting(routingId);
    return result.fold(
      (failure) {
        _logger.e('Failed to end routing', error: failure);
        return false;
      },
      (_) {
        _updateState((state) {
          final routings = {...state.activeRoutings};
          routings.remove(routingId);
          return state.copyWith(activeRoutings: routings);
        });
        notifyListeners();
        return true;
      },
    );
  }

  /// Get current status
  GatewayStatus? getStatus() {
    final result = _repository.getStatus();
    return result.fold(
      (failure) {
        _logger.e('Failed to get status', error: failure);
        return null;
      },
      (status) => status,
    );
  }

  @override
  void dispose() {
    _statusSubscription?.cancel();
    _routingSubscription?.cancel();
    super.dispose();
  }
}
