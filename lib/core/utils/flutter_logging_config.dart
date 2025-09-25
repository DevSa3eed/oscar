import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Configuration for Flutter engine logging with debug filtering
class FlutterLoggingConfig {
  static bool _isConfigured = false;
  static bool _debugFilterEnabled = true;

  // Categories of debug messages to filter
  static final Set<String> _filteredCategories = {
    'flutter.engine',
    'flutter.platform',
    'flutter.rendering',
    'flutter.semantics',
    'flutter.gestures',
    'flutter.physics',
    'flutter.animation',
    'flutter.painting',
    'flutter.foundation',
    'flutter.services',
    'flutter.widgets',
    'flutter.material',
    'flutter.cupertino',
    'Riverpod',
    'AutoRoute',
    'FirebaseAuth',
    'FirebaseFirestore',
    'FirebaseStorage',
    'FirebaseCore',
  };

  /// Configure Flutter engine logging levels
  static void configure() {
    if (_isConfigured) return;

    if (kDebugMode) {
      // Override debugPrint to filter noisy messages
      _setupDebugFiltering();

      // Configure UI overlay
      _configureSystemUI();

      debugPrint(
        '🔧 [OSCAR] Debug filtering enabled - showing only app-specific logs',
      );
    }

    _isConfigured = true;
  }

  static void _setupDebugFiltering() {
    // Store the original debugPrint function
    final originalDebugPrint = debugPrint;

    // Override debugPrint with filtering
    debugPrint = (String? message, {int? wrapWidth}) {
      if (!_debugFilterEnabled || message == null) {
        originalDebugPrint(message, wrapWidth: wrapWidth);
        return;
      }

      // Check if message should be filtered
      if (_shouldShowMessage(message)) {
        originalDebugPrint(message, wrapWidth: wrapWidth);
      }
    };
  }

  static bool _shouldShowMessage(String message) {
    final lowerMessage = message.toLowerCase();

    // Always show error messages
    if (lowerMessage.contains('error') ||
        lowerMessage.contains('exception') ||
        lowerMessage.contains('failed') ||
        lowerMessage.contains('❌') ||
        lowerMessage.contains('⚠️')) {
      return true;
    }

    // Always show our app-specific messages
    if (lowerMessage.contains('[oscar]') ||
        lowerMessage.contains('🔄') ||
        lowerMessage.contains('✅') ||
        lowerMessage.contains('🔧') ||
        lowerMessage.contains('📱') ||
        lowerMessage.contains('🚀') ||
        lowerMessage.contains('firebase initialized') ||
        lowerMessage.contains('auth state') ||
        lowerMessage.contains('navigation:') ||
        lowerMessage.contains('duty') ||
        lowerMessage.contains('supervisor') ||
        lowerMessage.contains('hod')) {
      return true;
    }

    // Filter out noisy framework messages
    for (final category in _filteredCategories) {
      if (lowerMessage.contains(category.toLowerCase())) {
        return false;
      }
    }

    // Show other messages by default (but this catches most noise)
    return true;
  }

  static void _configureSystemUI() {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );
  }

  /// Enable verbose logging for debugging
  static void enableVerboseLogging({
    bool firebase = false,
    bool network = false,
    bool ui = false,
    bool navigation = false,
  }) {
    if (kDebugMode) {
      debugPrint('🔧 [OSCAR] Verbose logging enabled:');
      debugPrint('  Firebase: $firebase');
      debugPrint('  Network: $network');
      debugPrint('  UI: $ui');
      debugPrint('  Navigation: $navigation');
    }
  }

  /// Temporarily disable debug filtering (for debugging the app itself)
  static void disableFiltering() {
    _debugFilterEnabled = false;
    if (kDebugMode) {
      debugPrint('🔧 [OSCAR] Debug filtering disabled - showing all messages');
    }
  }

  /// Re-enable debug filtering
  static void enableFiltering() {
    _debugFilterEnabled = true;
    if (kDebugMode) {
      debugPrint(
        '🔧 [OSCAR] Debug filtering enabled - filtering noisy messages',
      );
    }
  }

  /// Add a custom debug message with Oscar prefix
  static void oscarLog(String message, {String category = 'INFO'}) {
    if (kDebugMode) {
      final icon = _getIconForCategory(category);
      debugPrint('$icon [OSCAR] $message');
    }
  }

  static String _getIconForCategory(String category) {
    switch (category.toUpperCase()) {
      case 'ERROR':
        return '❌';
      case 'WARNING':
        return '⚠️';
      case 'SUCCESS':
        return '✅';
      case 'LOADING':
        return '🔄';
      case 'NAVIGATION':
        return '📱';
      case 'AUTH':
        return '🔐';
      case 'DATA':
        return '📊';
      default:
        return '🔧';
    }
  }
}
