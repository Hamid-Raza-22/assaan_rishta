import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

import '../account_status_service.dart';
import '../../utils/app_logger.dart';

/// ApiResponseInterceptor - Intercepts API responses to check for account deactivation
/// This class checks every API response for deactivation status and triggers
/// automatic logout across all devices when detected.
class ApiResponseInterceptor {
  static final ApiResponseInterceptor _instance = ApiResponseInterceptor._internal();
  factory ApiResponseInterceptor() => _instance;
  ApiResponseInterceptor._internal();

  /// Check if response indicates account is deactivated
  /// Returns true if account is deactivated, false otherwise
  Future<bool> checkForDeactivation(http.Response response) async {
    try {
      // Check for 400 status with deactivation error
      if (response.statusCode == 400) {
        final body = response.body.toLowerCase();
        
        // Check for account_Deactivated in response body
        if (body.contains('account_deactivated') || 
            body.contains('account deactivated') ||
            body.contains('deactivated')) {
          AppLogger.error('[ApiInterceptor] 🚨 Account deactivation detected in API response');
          await _handleDeactivation();
          return true;
        }
      }

      // Check for 401/403 which might indicate deactivated account
      if (response.statusCode == 401 || response.statusCode == 403) {
        try {
          final jsonBody = jsonDecode(response.body);
          final error = jsonBody['error']?.toString().toLowerCase() ?? '';
          final message = jsonBody['message']?.toString().toLowerCase() ?? '';
          
          if (error.contains('deactivat') || 
              message.contains('deactivat') ||
              error.contains('account_deactivated')) {
            AppLogger.error('[ApiInterceptor] 🚨 Account deactivation detected (401/403)');
            await _handleDeactivation();
            return true;
          }
        } catch (e) {
          // JSON parsing failed, continue
        }
      }

      // Check response body for deactivation keywords
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final jsonBody = jsonDecode(response.body);
          if (jsonBody is Map<String, dynamic>) {
            final isDeactivated = jsonBody['is_deactivated'] == true ||
                                  jsonBody['account_deactivated'] == true ||
                                  jsonBody['status'] == 'deactivated';
            
            if (isDeactivated) {
              AppLogger.error('[ApiInterceptor] 🚨 Account deactivation flag in response data');
              await _handleDeactivation();
              return true;
            }
          }
        } catch (e) {
          // JSON parsing failed, continue
        }
      }

      return false;
    } catch (e) {
      AppLogger.error('[ApiInterceptor] Error checking for deactivation: $e');
      return false;
    }
  }

  /// Handle deactivation - trigger AccountStatusService
  Future<void> _handleDeactivation() async {
    if (Get.isRegistered<AccountStatusService>()) {
      await AccountStatusService.instance.handleDeactivatedApiResponse();
    } else {
      AppLogger.error('[ApiInterceptor] AccountStatusService not registered');
    }
  }

  /// Check error description for deactivation
  bool isDeactivationError(String? errorDescription) {
    if (errorDescription == null) return false;
    
    final error = errorDescription.toLowerCase();
    return error.contains('account_deactivated') ||
           error.contains('account deactivated') ||
           error.contains('deactivated');
  }
}
