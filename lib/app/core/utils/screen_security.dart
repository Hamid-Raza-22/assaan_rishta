import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';
import 'app_logger.dart';

/// Screen Security Utility
/// Prevents screenshots and screen recording on sensitive screens
class ScreenSecurity {
  static const _channel = MethodChannel('com.asaanrishta.app/screen_security');

  /// Enable screen security (block screenshots & recording)
  static Future<void> enableScreenSecurity() async {
    try {
      if (kDebugMode) {
        AppLogger.info('Screen security enabled (screenshots blocked)');
      }
      await _channel.invokeMethod('enableScreenSecurity');
    } catch (e) {
      AppLogger.error('Failed to enable screen security', e);
    }
  }

  /// Disable screen security (allow screenshots & recording)
  static Future<void> disableScreenSecurity() async {
    try {
      if (kDebugMode) {
        AppLogger.info('Screen security disabled (screenshots allowed)');
      }
      await _channel.invokeMethod('disableScreenSecurity');
    } catch (e) {
      AppLogger.error('Failed to disable screen security', e);
    }
  }
}
