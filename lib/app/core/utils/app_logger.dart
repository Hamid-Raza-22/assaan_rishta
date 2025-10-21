import 'package:flutter/foundation.dart';

/// App-wide logging configuration
/// Controls whether logs should be shown based on build mode
class AppLogger {
  // Private constructor to prevent instantiation
  AppLogger._();

  /// Whether to show logs in current build mode
  /// - Debug mode: Always true
  /// - Release mode: false (disabled for production)
  /// - Profile mode: false (disabled for profiling)
  static bool get isLoggingEnabled => kDebugMode;

  /// Log a debug message (only shows in debug mode)
  static void debug(String message) {
    if (isLoggingEnabled) {
      debugPrint('🐛 $message');
    }
  }

  /// Log an info message (only shows in debug mode)
  static void info(String message) {
    if (isLoggingEnabled) {
      debugPrint('ℹ️ $message');
    }
  }

  /// Log a warning message (only shows in debug mode)
  static void warning(String message) {
    if (isLoggingEnabled) {
      debugPrint('⚠️ $message');
    }
  }

  /// Log an error message (shows in all modes for crash reporting)
  static void error(String message, [Object? error, StackTrace? stackTrace]) {
    // Errors should always be logged for crash reporting
    debugPrint('❌ ERROR: $message');
    if (error != null) {
      debugPrint('Error details: $error');
    }
    if (stackTrace != null && isLoggingEnabled) {
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Log a success message (only shows in debug mode)
  static void success(String message) {
    if (isLoggingEnabled) {
      debugPrint('✅ $message');
    }
  }

  /// Log a network request (only shows in debug mode)
  static void network(String message) {
    if (isLoggingEnabled) {
      debugPrint('🌐 $message');
    }
  }

  /// Log a database operation (only shows in debug mode)
  static void database(String message) {
    if (isLoggingEnabled) {
      debugPrint('💾 $message');
    }
  }

  /// Log a navigation action (only shows in debug mode)
  static void navigation(String message) {
    if (isLoggingEnabled) {
      debugPrint('🧭 $message');
    }
  }

  /// Log a lifecycle event (only shows in debug mode)
  static void lifecycle(String message) {
    if (isLoggingEnabled) {
      debugPrint('🔄 $message');
    }
  }
}
