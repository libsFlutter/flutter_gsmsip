/// SIP Event Handlers
/// Handles SIP events and updates state accordingly

import '../entities/sip_account.dart';
import '../entities/sip_call.dart';
import '../entities/sip_event.dart';
import 'sip_provider.dart';

/// SIP Event Handlers
///
/// Pure functions for handling SIP events and updating state.
/// Separated from provider for testability.
class SipEventHandlers {
  /// Handle SIP event
  void handleEvent(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    switch (event.type) {
      case SipEventType.registrationChanged:
        _handleRegistrationChanged(event, currentState, updateState);
        break;

      case SipEventType.accountChanged:
        _handleAccountChanged(event, currentState, updateState);
        break;

      case SipEventType.callReceived:
        _handleCallReceived(event, currentState, updateState);
        break;

      case SipEventType.callChanged:
        _handleCallChanged(event, currentState, updateState);
        break;

      case SipEventType.callTerminated:
        _handleCallTerminated(event, currentState, updateState);
        break;

      case SipEventType.connectivityChanged:
        _handleConnectivityChanged(event, currentState, updateState);
        break;

      case SipEventType.callScreenLocked:
        _handleCallScreenLocked(event, currentState, updateState);
        break;

      case SipEventType.appStateChanged:
        _handleAppStateChanged(event, currentState, updateState);
        break;

      case SipEventType.settingsChanged:
        _handleSettingsChanged(event, currentState, updateState);
        break;

      case SipEventType.unknown:
        // Ignore unknown events
        break;
    }
  }

  /// Handle registration changed event
  void _handleRegistrationChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final accountId = event.accountId;
    if (accountId == null) return;

    final state = event.data['state'] as String?;
    final status = event.data['status'] as String?;

    if (state == null) return;

    final registrationState = _parseRegistrationState(state);

    updateState((state) {
      final accounts = {...state.accounts};
      final existing = accounts[accountId];

      if (existing != null) {
        accounts[accountId] = existing.copyWith(
          registrationState: registrationState,
          registrationStatus: status,
        );
      } else {
        // Create placeholder account
        accounts[accountId] = SipAccount(
          id: accountId,
          username: event.data['username'] ?? '',
          password: '',
          domain: event.data['domain'] ?? '',
          registrationState: registrationState,
          registrationStatus: status,
        );
      }

      // Update overall registration state
      final hasRegistered = accounts.values.any((a) => a.isRegistered);
      final hasFailed = accounts.values.any((a) => a.registrationFailed);

      return state.copyWith(
        accounts: accounts,
        registrationState: hasRegistered
            ? SipRegistrationState.registered
            : hasFailed
                ? SipRegistrationState.registrationFailed
                : registrationState,
      );
    });
  }

  /// Handle account changed event
  void _handleAccountChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final accountData = event.accountData;
    if (accountData == null) return;

    // Account data would come from native layer
    // For now, we just update the cache
  }

  /// Handle incoming call event
  void _handleCallReceived(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final callData = event.callData;
    if (callData == null) return;

    final callId = callData['id'] as String?;
    if (callId == null) return;

    final call = SipCall.incoming(
      id: callId,
      accountId: callData['accountId'] as String? ?? '',
      number: callData['number'] as String? ?? '',
      callerName: callData['callerName'] as String?,
    );

    updateState((state) => state.copyWith(
          calls: {...state.calls, call.id: call},
        ));
  }

  /// Handle call changed event
  void _handleCallChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final callData = event.callData;
    if (callData == null) return;

    final callId = callData['id'] as String?;
    if (callId == null) return;

    final existingCall = currentState.getCall(callId);
    if (existingCall == null) return;

    final state = callData['state'] as String?;
    final isMuted = callData['isMuted'] as bool?;
    final isOnHold = callData['isOnHold'] as bool?;
    final isSpeaker = callData['isSpeaker'] as bool?;

    final callState = state != null ? _parseCallState(state) : existingCall.state;

    updateState((state) {
      final calls = {...state.calls};
      calls[callId] = existingCall.copyWith(
        state: callState,
        isMuted: isMuted ?? existingCall.isMuted,
        isOnHold: isOnHold ?? existingCall.isOnHold,
        isSpeaker: isSpeaker ?? existingCall.isSpeaker,
      );
      return state.copyWith(calls: calls);
    });
  }

  /// Handle call terminated event
  void _handleCallTerminated(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final callId = event.callId;
    if (callId == null) return;

    updateState((state) {
      final calls = {...state.calls};
      calls.remove(callId);
      return state.copyWith(calls: calls);
    });
  }

  /// Handle connectivity changed event
  void _handleConnectivityChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final connected = event.isConnected ?? false;

    updateState((state) => state.copyWith(
          isConnected: connected,
          connectionState: connected
              ? SipConnectionState.connected
              : SipConnectionState.disconnected,
        ));
  }

  /// Handle call screen locked event
  void _handleCallScreenLocked(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    // Screen lock state - could be used to prevent call operations
  }

  /// Handle app state changed event
  void _handleAppStateChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    final appState = event.appState;
    // Handle app state changes (active/background)
    // Could trigger re-registration when coming back to foreground
  }

  /// Handle settings changed event
  void _handleSettingsChanged(
    SipEvent event,
    SipState currentState,
    void Function(SipState Function(SipState)) updateState,
  ) {
    // Settings changed - may need to reinitialize
  }

  /// Parse registration state from string
  SipRegistrationState _parseRegistrationState(String state) {
    switch (state.toLowerCase()) {
      case 'registered':
      case 'registration_ok':
        return SipRegistrationState.registered;
      case 'registering':
      case 'registration_in_progress':
        return SipRegistrationState.registering;
      case 'registration_failed':
      case 'failed':
        return SipRegistrationState.registrationFailed;
      case 'reregistering':
        return SipRegistrationState.reregistering;
      case 'unregistered':
      default:
        return SipRegistrationState.unregistered;
    }
  }

  /// Parse call state from string
  CallState _parseCallState(String state) {
    switch (state.toLowerCase()) {
      case 'initiated':
      case 'calling':
        return CallState.initiated;
      case 'incoming':
      case 'ringing':
        return CallState.incoming;
      case 'active':
      case 'connected':
      case 'established':
        return CallState.active;
      case 'held':
      case 'on_hold':
        return CallState.held;
      case 'terminated':
      case 'ended':
      case 'disconnected':
        return CallState.terminated;
      case 'failed':
      case 'error':
        return CallState.failed;
      default:
        return CallState.initiated;
    }
  }
}
