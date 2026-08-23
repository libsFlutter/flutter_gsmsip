import 'package:flutter/services.dart';

/// DialerPlugin provides dialer replacement functionality for the GOSTsimbox Gateway.
/// 
/// This plugin wraps the native Android ReplaceDialerModule to provide:
/// - Check if the app is the default dialer
/// - Request to become the default dialer
/// - Check if the app can become the default dialer
/// 
/// Platform Support:
/// - Android: Full functionality (API 23+)
/// - iOS: Returns false for all methods (dialer replacement not supported)
/// 
/// Usage:
/// ```dart
/// final dialer = DialerPlugin();
/// 
/// // Check if default dialer
/// final isDefault = await dialer.isDefaultDialer();
/// 
/// // Request to become default dialer
/// if (!isDefault) {
///   final success = await dialer.setDefaultDialer();
///   if (success) {
///     print('Successfully set as default dialer');
///   }
/// }
/// ```
/// 
/// ## GAP Resolutions
/// 
/// ### GAP-010: setDefaultDialer() callback timing
/// The native implementation properly waits for user confirmation before
/// invoking the callback. The system dialog is modal, so the callback
/// is only invoked after the user confirms or cancels.
/// 
/// ### GAP-013: ActivityEventListener interface
/// The native module implements ActivityEventListener to properly handle
/// activity results from the system dialer selection dialog.
/// 
/// ## Thread Safety
/// 
/// The native implementation uses synchronization to prevent concurrent
/// calls to setDefaultDialer(). Only one request can be in progress at a time.
class DialerPlugin {
  /// Method channel for communicating with native ReplaceDialerModule
  static const MethodChannel _channel = MethodChannel('org.telon/replace_dialer');

  /// Check if this app is the default dialer.
  /// 
  /// Returns `true` if the app is currently set as the default dialer,
  /// `false` otherwise.
  /// 
  /// On Android versions below API 23 (Marshmallow), returns `true`
  /// as the default dialer concept is not applicable.
  /// 
  /// On iOS, returns `false` as dialer replacement is not supported.
  /// 
  /// Throws [PlatformException] if the native module is not available
  /// or an error occurs during the check.
  /// 
  /// Example:
  /// ```dart
  /// final dialer = DialerPlugin();
  /// final isDefault = await dialer.isDefaultDialer();
  /// if (isDefault) {
  ///   print('App is already the default dialer');
  /// }
  /// ```
  Future<bool> isDefaultDialer() async {
    try {
      final result = await _channel.invokeMethod<bool>('isDefaultDialer');
      return result ?? false;
    } on PlatformException catch (e) {
      throw DialerPluginException(
        'IS_DEFAULT_DIALER_ERROR',
        'Failed to check if default dialer: ${e.message}',
        e,
      );
    }
  }

  /// Request to become the default dialer.
  /// 
  /// This method opens the system dialog asking the user to confirm
  /// setting this app as the default dialer. The method returns after
  /// the user has made their decision.
  /// 
  /// Returns `true` if the user confirmed and the app was set as default,
  /// `false` if the user cancelled or the operation failed.
  /// 
  /// On Android versions below API 23 (Marshmallow), returns `true`
  /// immediately as the default dialer concept is not applicable.
  /// 
  /// On iOS, returns `false` as dialer replacement is not supported.
  /// 
  /// Throws [DialerPluginException] with code 'CALL_IN_PROGRESS' if
  /// another setDefaultDialer request is already in progress.
  /// 
  /// Example:
  /// ```dart
  /// final dialer = DialerPlugin();
  /// final isDefault = await dialer.isDefaultDialer();
  /// if (!isDefault) {
  ///   final success = await dialer.setDefaultDialer();
  ///   if (success) {
  ///     print('Successfully set as default dialer');
  ///   } else {
  ///     print('User cancelled or operation failed');
  ///   }
  /// }
  /// ```
  /// 
  /// ## GAP-010 Resolution
  /// 
  /// This method properly waits for user confirmation before returning.
  /// The native implementation stores the callback and invokes it in
  /// onActivityResult() after the system dialog is dismissed.
  Future<bool> setDefaultDialer() async {
    try {
      final result = await _channel.invokeMethod<bool>('setDefaultDialer');
      return result ?? false;
    } on PlatformException catch (e) {
      if (e.code == 'CALL_IN_PROGRESS') {
        throw DialerPluginException(
          'CALL_IN_PROGRESS',
          'Another setDefaultDialer request is already in progress',
          e,
        );
      }
      throw DialerPluginException(
        'SET_DEFAULT_DIALER_ERROR',
        'Failed to set default dialer: ${e.message}',
        e,
      );
    }
  }

  /// Check if this app can be set as the default dialer.
  /// 
  /// Returns `true` if the app is capable of becoming the default dialer
  /// (i.e., it's not already the default and the platform supports it).
  /// 
  /// On Android versions below API 23 (Marshmallow), returns `false`
  /// as the default dialer concept is not applicable.
  /// 
  /// On iOS, returns `false` as dialer replacement is not supported.
  /// 
  /// This method can be used to determine whether to show the
  /// "Set as default dialer" button in the UI.
  /// 
  /// Example:
  /// ```dart
  /// final dialer = DialerPlugin();
  /// if (await dialer.canSetDefaultDialer()) {
  ///   // Show "Set as default dialer" button
  /// } else {
  ///   // Hide button or show explanation
  /// }
  /// ```
  Future<bool> canSetDefaultDialer() async {
    try {
      final result = await _channel.invokeMethod<bool>('canSetDefaultDialer');
      return result ?? false;
    } on PlatformException catch (e) {
      throw DialerPluginException(
        'CAN_SET_DEFAULT_DIALER_ERROR',
        'Failed to check if can set default dialer: ${e.message}',
        e,
      );
    }
  }
}

/// Exception thrown when a dialer plugin operation fails.
/// 
/// Contains error code, message, and optional original exception.
class DialerPluginException implements Exception {
  /// Error code identifying the type of error.
  /// 
  /// Common codes:
  /// - 'IS_DEFAULT_DIALER_ERROR': Failed to check default dialer status
  /// - 'SET_DEFAULT_DIALER_ERROR': Failed to set default dialer
  /// - 'CAN_SET_DEFAULT_DIALER_ERROR': Failed to check capability
  /// - 'CALL_IN_PROGRESS': Another request is already in progress
  final String code;

  /// Human-readable error message.
  final String message;

  /// Original exception that caused this error, if any.
  final Exception? originalException;

  /// Creates a new DialerPluginException.
  const DialerPluginException(this.code, this.message, [this.originalException]);

  @override
  String toString() {
    if (originalException != null) {
      return 'DialerPluginException($code): $message (caused by: $originalException)';
    }
    return 'DialerPluginException($code): $message';
  }
}

/// Static utility class for dialer operations.
/// 
/// Provides convenient static methods for common dialer operations
/// without needing to instantiate [DialerPlugin].
/// 
/// Example:
/// ```dart
/// if (await TeleDialer.isDefaultDialer()) {
///   print('Already default dialer');
/// }
/// 
/// await TeleDialer.requestDefaultDialer();
/// ```
class TeleDialer {
  /// Singleton instance for convenience
  static final DialerPlugin _instance = DialerPlugin();

  /// Check if this app is the default dialer.
  /// 
  /// See [DialerPlugin.isDefaultDialer] for details.
  static Future<bool> isDefaultDialer() async {
    return await _instance.isDefaultDialer();
  }

  /// Request to become the default dialer.
  /// 
  /// See [DialerPlugin.setDefaultDialer] for details.
  static Future<bool> setDefaultDialer() async {
    return await _instance.setDefaultDialer();
  }

  /// Check if this app can be set as the default dialer.
  /// 
  /// See [DialerPlugin.canSetDefaultDialer] for details.
  static Future<bool> canSetDefaultDialer() async {
    return await _instance.canSetDefaultDialer();
  }

  /// Request to become the default dialer (alias for setDefaultDialer).
  /// 
  /// This method name better reflects that the operation requests
  /// user permission via a system dialog.
  /// 
  /// See [DialerPlugin.setDefaultDialer] for details.
  static Future<bool> requestDefaultDialer() async {
    return await _instance.setDefaultDialer();
  }
}
