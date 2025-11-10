import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../utils/app_colors.dart';
import 'app_logger.dart';

/// Developer Mode Detection & Handling
/// Checks if developer mode is enabled and BLOCKS app at splash screen
class DeveloperModeChecker {
  static final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Check if developer mode is enabled (Android only)
  static Future<bool> isDeveloperModeEnabled() async {
    try {
      // Only check on Android
      if (!Platform.isAndroid) {
        AppLogger.info('Not Android platform - skipping developer mode check');
        return false;
      }

      final androidInfo = await _deviceInfo.androidInfo;
      
      // Check if device is in developer mode
      // Note: This checks if USB debugging is enabled
      final isDeveloperMode = androidInfo.isPhysicalDevice && 
                              await _isUsbDebuggingEnabled();

      if (isDeveloperMode) {
        AppLogger.warning('Developer mode detected!');
      } else {
        AppLogger.info('Developer mode not detected');
      }

      return isDeveloperMode;
    } catch (e) {
      AppLogger.error('Error checking developer mode', e);
      return false; // On error, don't block the app
    }
  }

  /// Check if USB debugging is enabled using platform channel
  static Future<bool> _isUsbDebuggingEnabled() async {
    try {
      const platform = MethodChannel('com.asaanrishta.app/developer_mode');
      final bool isEnabled = await platform.invokeMethod('isDeveloperModeEnabled');
      return isEnabled;
    } catch (e) {
      AppLogger.error('Error checking USB debugging', e);
      return false;
    }
  }

  /// Show developer mode warning dialog
  static void showDeveloperModeDialog() {
    Get.dialog(
      WillPopScope(
        // Prevent dialog dismiss on back button
        onWillPop: () async {
          _exitApp();
          return false;
        },
        child: AlertDialog(
          backgroundColor: AppColors.whiteColor,
          title: Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: AppColors.primaryColor,
                size: 28,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Developer Mode Detected',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'For security reasons, this app cannot run with Developer Options enabled.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 12),
              // Container(
              //   padding: EdgeInsets.all(10),
              //   decoration: BoxDecoration(
              //     color: Colors.blue.shade50,
              //     borderRadius: BorderRadius.circular(8),
              //     border: Border.all(color: Colors.blue.shade200),
              //   ),
              //   child: Row(
              //     children: [
              //       Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
              //       SizedBox(width: 8),
              //       Expanded(
              //         child: Text(
              //           'App will automatically continue once Developer Options are disabled.',
              //           style: TextStyle(
              //             fontSize: 12,
              //             color: Colors.blue.shade900,
              //             height: 1.3,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.borderColor),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'How to disable:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                    SizedBox(height: 8),
                    _buildStep('1. Tap "Turn Off" button below'),
                    _buildStep('2. Find and tap "Developer options"'),
                    _buildStep('3. Toggle OFF "Developer options" or "USB debugging"'),
                    _buildStep('4. Restart the app'),
                  ],
                ),
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actions: [
            // Exit button
            TextButton(
              onPressed: _exitApp,
              style: TextButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'Exit',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Turn Off button
            ElevatedButton(
              onPressed: _openDeveloperSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Turn Off',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false, // Prevent dismiss by tapping outside
    );
  }

  /// Helper widget for steps
  static Widget _buildStep(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.circle,
            size: 6,
            color: AppColors.primaryColor,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange.shade900,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Open device developer settings
  static void _openDeveloperSettings() {
    try {
      const platform = MethodChannel('com.asaanrishta.app/developer_mode');
      platform.invokeMethod('openDeveloperSettings');
      
      AppLogger.info('Opening developer settings...');
      
      // Show snackbar
      Get.snackbar(
        'Settings Opened',
        'Please disable Developer Options and restart the app',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        icon: Icon(Icons.settings, color: Colors.white),
        duration: Duration(seconds: 4),
      );
      
      // Exit app after a short delay
      Future.delayed(Duration(seconds: 2), () {
        _exitApp();
      });
    } catch (e) {
      AppLogger.error('Error opening developer settings', e);
      Get.snackbar(
        'Error',
        'Could not open settings. Please go to Settings > Developer Options manually.',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: Duration(seconds: 4),
      );
    }
  }

  /// Exit the app
  static void _exitApp() {
    AppLogger.lifecycle('User chose to exit app due to developer mode');
    SystemNavigator.pop(); // Exit app
  }
}
