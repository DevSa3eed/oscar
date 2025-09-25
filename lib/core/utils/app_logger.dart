import 'package:flutter/foundation.dart';

/// Centralized logging utility for the app
class AppLogger {
  static const bool _enableDebugLogs = kDebugMode;
  static const bool _enableInfoLogs = kDebugMode;
  static const bool _enableWarningLogs = true;
  static const bool _enableErrorLogs = true;
  static const bool _enableFirebaseLogs = kDebugMode;
  static const bool _enableNetworkLogs = kDebugMode;

  /// Log debug messages (only in debug mode)
  static void debug(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableDebugLogs) {
      debugPrint('[DEBUG] $message');
      if (error != null) {
        debugPrint('[DEBUG] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[DEBUG] StackTrace: $stackTrace');
      }
    }
  }

  /// Log info messages (only in debug mode)
  static void info(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableInfoLogs) {
      debugPrint('[INFO] $message');
      if (error != null) {
        debugPrint('[INFO] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[INFO] StackTrace: $stackTrace');
      }
    }
  }

  /// Log warning messages (always enabled)
  static void warning(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableWarningLogs) {
      debugPrint('[WARNING] $message');
      if (error != null) {
        debugPrint('[WARNING] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[WARNING] StackTrace: $stackTrace');
      }
    }
  }

  /// Log error messages (always enabled)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableErrorLogs) {
      debugPrint('[ERROR] $message');
      if (error != null) {
        debugPrint('[ERROR] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[ERROR] StackTrace: $stackTrace');
      }
    }
  }

  /// Log Firebase-specific messages with reduced verbosity
  static void firebase(
    String message, [
    Object? error,
    StackTrace? stackTrace,
  ]) {
    if (_enableFirebaseLogs) {
      debugPrint('[FIREBASE] $message');
      if (error != null) {
        debugPrint('[FIREBASE] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[FIREBASE] StackTrace: $stackTrace');
      }
    }
  }

  /// Log network-related messages
  static void network(String message, [Object? error, StackTrace? stackTrace]) {
    if (_enableNetworkLogs) {
      debugPrint('[NETWORK] $message');
      if (error != null) {
        debugPrint('[NETWORK] Error: $error');
      }
      if (stackTrace != null) {
        debugPrint('[NETWORK] StackTrace: $stackTrace');
      }
    }
  }
}
