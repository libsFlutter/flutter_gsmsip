/// Extension methods for common Dart and Flutter types
/// Provides convenient utilities throughout the application

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// DateTime extensions for formatting and manipulation
extension DateTimeExtension on DateTime {
  /// Format date as YYYY-MM-DD
  String toDateString() {
    return DateFormat('yyyy-MM-dd').format(this);
  }

  /// Format time as HH:MM
  String toTimeString() {
    return DateFormat('HH:mm').format(this);
  }

  /// Format datetime as YYYY-MM-DD HH:MM
  String toDateTimeString() {
    return DateFormat('yyyy-MM-dd HH:mm').format(this);
  }

  /// Format as relative time (e.g., "2 hours ago")
  String toRelativeString() {
    final now = DateTime.now();
    final difference = now.difference(this);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inSeconds > 0) {
      return '${difference.inSeconds} seconds ago';
    } else {
      return 'Just now';
    }
  }

  /// Check if date is today
  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }

  /// Check if date is yesterday
  bool get isYesterday {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return year == yesterday.year && month == yesterday.month && day == yesterday.day;
  }

  /// Check if date is tomorrow
  bool get isTomorrow {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return year == tomorrow.year && month == tomorrow.month && day == tomorrow.day;
  }

  /// Add days to date
  DateTime addDays(int days) => add(Duration(days: days));

  /// Subtract days from date
  DateTime subtractDays(int days) => subtract(Duration(days: days));

  /// Start of day (midnight)
  DateTime get startOfDay => DateTime(year, month, day);

  /// End of day (23:59:59)
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59);

  /// Start of month
  DateTime get startOfMonth => DateTime(year, month, 1);

  /// End of month
  DateTime get endOfMonth => DateTime(year, month + 1, 0, 23, 59, 59);

  /// Check if date is in the past
  bool get isPast => isBefore(DateTime.now());

  /// Check if date is in the future
  bool get isFuture => isAfter(DateTime.now());

  /// Check if date is between two dates
  bool isBetween(DateTime start, DateTime end) {
    return isAfter(start) && isBefore(end);
  }

  /// Format duration from this date to another
  String durationTo(DateTime other) {
    final difference = other.difference(this).abs();
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ${difference.inHours % 24}h';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes % 60}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ${difference.inSeconds % 60}s';
    } else {
      return '${difference.inSeconds}s';
    }
  }
}

/// Duration extensions for formatting
extension DurationExtension on Duration {
  /// Format as HH:MM:SS
  String toTimeString() {
    final hours = inHours.toString().padLeft(2, '0');
    final minutes = inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes:$seconds';
  }

  /// Format as MM:SS (for calls, videos, etc.)
  String toMinutesSecondsString() {
    final minutes = inMinutes.toString().padLeft(2, '0');
    final seconds = inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  /// Format as human readable string
  String toHumanString() {
    final parts = <String>[];
    
    if (inDays > 0) {
      parts.add('$inDays day${inDays > 1 ? 's' : ''}');
    }
    if (inHours > 0) {
      parts.add('$inHours hour${inHours > 1 ? 's' : ''}');
    }
    if (inMinutes > 0 && inHours < 24) {
      parts.add('$inMinutes minute${inMinutes > 1 ? 's' : ''}');
    }
    if (inSeconds > 0 && inMinutes < 60) {
      parts.add('$inSeconds second${inSeconds > 1 ? 's' : ''}');
    }
    
    if (parts.isEmpty) {
      return '0 seconds';
    }
    
    return parts.join(', ');
  }

  /// Check if duration is zero
  bool get isZero => inMilliseconds == 0;

  /// Check if duration is negative
  bool get isNegative => inMilliseconds < 0;

  /// Check if duration is positive
  bool get isPositive => inMilliseconds > 0;

  /// Absolute value of duration
  Duration get abs => Duration(milliseconds: inMilliseconds.abs());

  /// Negate duration
  Duration get negate => Duration(milliseconds: -inMilliseconds);
}

/// String extensions for common string operations
extension StringExtension on String {
  /// Check if string is null, empty, or whitespace only
  bool get isNullOrEmpty => trim().isEmpty;

  /// Check if string is not null, empty, or whitespace only
  bool get isNotNullOrEmpty => trim().isNotEmpty;

  /// Check if string is a valid email
  bool get isValidEmail {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(this);
  }

  /// Check if string is a valid phone number
  bool get isValidPhoneNumber {
    final clean = replaceAll(RegExp(r'[\s\-\(\)]'), '');
    return RegExp(r'^[\+]?[0-9]{7,15}$').hasMatch(clean);
  }

  /// Check if string is a valid URL
  bool get isValidUrl {
    try {
      Uri.parse(this);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Check if string is a valid IP address
  bool get isValidIpAddress {
    return RegExp(r'^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$').hasMatch(this);
  }

  /// Capitalize first letter
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Capitalize first letter of each word
  String capitalizeWords() {
    return split(' ').map((word) => word.capitalize()).join(' ');
  }

  /// Truncate string to max length with ellipsis
  String truncate(int maxLength, {String ellipsis = '...'}) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength - ellipsis.length)}$ellipsis';
  }

  /// Remove all non-numeric characters
  String get onlyDigits => replaceAll(RegExp(r'[^\d]'), '');

  /// Remove all whitespace
  String get withoutWhitespace => replaceAll(RegExp(r'\s'), '');

  /// Mask string (e.g., for passwords, credit cards)
  String mask({String maskChar = '*', int visibleAtEnd = 0}) {
    if (isEmpty) return this;
    if (visibleAtEnd >= length) return this;
    
    final visiblePart = visibleAtEnd > 0 ? substring(length - visibleAtEnd) : '';
    final maskedPart = maskChar * (length - visibleAtEnd);
    return maskedPart + visiblePart;
  }

  /// Format as phone number (+X XXX XXX-XX-XX)
  String formatAsPhoneNumber() {
    final clean = onlyDigits;
    if (clean.isEmpty) return this;
    
    // Handle Russian phone numbers
    if (clean.length == 11 && clean.startsWith('8')) {
      return '+7 ${clean.substring(1, 4)} ${clean.substring(4, 7)}-${clean.substring(7, 9)}-${clean.substring(9)}';
    }
    
    if (clean.length == 11 && clean.startsWith('7')) {
      return '+7 ${clean.substring(1, 4)} ${clean.substring(4, 7)}-${clean.substring(7, 9)}-${clean.substring(9)}';
    }
    
    // Generic formatting
    if (clean.length >= 10) {
      return '+${clean.substring(0, 1)} ${clean.substring(1, 4)} ${clean.substring(4, 7)}-${clean.substring(7, 9)}-${clean.substring(9, 11)}';
    }
    
    return this;
  }

  /// Parse as DateTime
  DateTime? tryParseDateTime({String format = 'yyyy-MM-dd HH:mm:ss'}) {
    try {
      return DateFormat(format).parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Parse as int
  int? tryParseInt({int radix = 10}) {
    try {
      return int.parse(this, radix: radix);
    } catch (e) {
      return null;
    }
  }

  /// Parse as double
  double? tryParseDouble() {
    try {
      return double.parse(this);
    } catch (e) {
      return null;
    }
  }

  /// Repeat string n times
  String repeat(int times) => List.filled(times, this).join();

  /// Remove prefix if exists
  String removePrefix(String prefix) {
    if (startsWith(prefix)) {
      return substring(prefix.length);
    }
    return this;
  }

  /// Remove suffix if exists
  String removeSuffix(String suffix) {
    if (endsWith(suffix)) {
      return substring(0, length - suffix.length);
    }
    return this;
  }

  /// Extract numbers from string
  List<int> extractNumbers() {
    final matches = RegExp(r'\d+').allMatches(this);
    return matches.map((m) => int.parse(m.group(0)!)).toList();
  }

  /// Split by camelCase
  List<String> splitByCamelCase() {
    return split(RegExp('(?=[A-Z])'));
  }

  /// Convert camelCase to snake_case
  String camelToSnake() {
    return replaceAllMapped(
      RegExp('[A-Z]'),
      (match) => '_${match.group(0)!.toLowerCase()}',
    ).replaceFirst('_', '');
  }

  /// Convert snake_case to camelCase
  String snakeToCamel() {
    final parts = split('_');
    return parts[0] + parts.skip(1).map((p) => p.capitalize()).join();
  }
}

/// Num extensions for formatting
extension NumExtension on num {
  /// Format as currency
  String toCurrencyString({String symbol = '\$', int decimalDigits = 2}) {
    return NumberFormat.currency(symbol: symbol, decimalDigits: decimalDigits).format(this);
  }

  /// Format as percentage
  String toPercentageString({int decimalDigits = 1}) {
    return '${toStringAsFixed(decimalDigits)}%';
  }

  /// Format with thousands separator
  String toThousandsString() {
    return toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (match) => '${match[1]},',
    );
  }

  /// Clamp value between min and max
  num clampTo(num min, num max) {
    if (this < min) return min;
    if (this > max) return max;
    return this;
  }

  /// Check if value is in range
  bool isInRange(num min, num max) => this >= min && this <= max;

  /// Round to decimal places
  double roundTo(int places) {
    final mod = pow(10, places).toDouble();
    return ((this * mod).round().toDouble() / mod);
  }
}

/// Map extensions
extension MapExtension<K, V> on Map<K, V> {
  /// Get value or default
  V getOrElse(K key, V defaultValue) => this[key] ?? defaultValue;

  /// Get value or null if key doesn't exist
  V? getOrNull(K key) => this[key];

  /// Check if map contains all keys
  bool containsAllKeys(Iterable<K> keys) => keys.every(containsKey);

  /// Check if map contains all values
  bool containsAllValues(Iterable<V> values) => values.every(containsValue);

  /// Filter map by key
  Map<K, V> filterKeys(bool Function(K) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.key)),
    );
  }

  /// Filter map by value
  Map<K, V> filterValues(bool Function(V) test) {
    return Map.fromEntries(
      entries.where((entry) => test(entry.value)),
    );
  }

  /// Transform map values
  Map<K, R> mapValues<R>(R Function(V) mapper) {
    return map((key, value) => MapEntry(key, mapper(value)));
  }

  /// Transform map keys
  Map<R, V> mapKeys<R>(R Function(K) mapper) {
    return map((key, value) => MapEntry(mapper(key), value));
  }
}

/// List extensions
extension ListExtension<T> on List<T> {
  /// Get first element or null
  T? get firstOrNull => isEmpty ? null : first;

  /// Get last element or null
  T? get lastOrNull => isEmpty ? null : last;

  /// Get element at index or null if out of bounds
  T? elementAtOrNull(int index) {
    if (index < 0 || index >= length) return null;
    return this[index];
  }

  /// Get element at index or default
  T elementAtOrElse(int index, T defaultValue) {
    if (index < 0 || index >= length) return defaultValue;
    return this[index];
  }

  /// Check if list is empty
  bool get isNullOrEmpty => isEmpty;

  /// Check if list is not empty
  bool get isNotNullOrEmpty => isNotEmpty;

  /// Get first n elements
  List<T> takeFirst(int n) => take(n).toList();

  /// Get last n elements
  List<T> takeLast(int n) {
    if (n >= length) return this;
    return skip(length - n).toList();
  }

  /// Remove duplicates
  List<T> distinct() => toSet().toList();

  /// Chunk list into sublists of size n
  List<List<T>> chunk(int size) {
    final result = <List<T>>[];
    for (var i = 0; i < length; i += size) {
      result.add(sublist(i, i < length - size ? i + size : length));
    }
    return result;
  }

  /// Interleave two lists
  List<T> interleave(List<T> other) {
    final result = <T>[];
    final maxLength = length > other.length ? length : other.length;
    for (var i = 0; i < maxLength; i++) {
      if (i < length) result.add(this[i]);
      if (i < other.length) result.add(other[i]);
    }
    return result;
  }
}

/// BuildContext extensions for common operations
extension BuildContextExtension on BuildContext {
  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get color scheme
  ColorScheme get colorScheme => Theme.of(this).colorScheme;

  /// Get text theme
  TextTheme get textTheme => Theme.of(this).textTheme;

  /// Get media query
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen width
  double get screenWidth => MediaQuery.of(this).size.width;

  /// Get screen height
  double get screenHeight => MediaQuery.of(this).size.height;

  /// Check if dark mode
  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => Theme.of(this).brightness == Brightness.light;

  /// Get text scaler
  TextScaler get textScaler => MediaQuery.of(this).textScaler;

  /// Show snackbar
  void showSnackBar(String message, {Color? backgroundColor}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor ?? colorScheme.primary,
      ),
    );
  }

  /// Show error snackbar
  void showErrorSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.error);
  }

  /// Show success snackbar
  void showSuccessSnackBar(String message) {
    showSnackBar(message, backgroundColor: colorScheme.primary);
  }

  /// Navigate to named route
  Future<T?> navigateTo<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed<T>(routeName, arguments: arguments);
  }

  /// Navigate and remove all previous routes
  Future<T?> navigateAndRemoveAll<T>(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamedAndRemoveUntil<T>(
      routeName,
      (route) => false,
      arguments: arguments,
    );
  }

  /// Pop the current route
  void goBack<T>([T? result]) {
    Navigator.of(this).pop(result);
  }
}
