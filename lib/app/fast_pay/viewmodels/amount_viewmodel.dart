import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

// Import WebViewScreen directly
import '../views/webview_screen.dart';
import '../../core/services/env_config_service.dart';
import '../../core/services/secure_storage_service.dart';
import '../../core/utils/app_logger.dart';
import '../services/api_service.dart';
// Remove Stacked imports
// import '../app/app.locator.dart';
// import '../app/app.router.dart';

class AmountViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();

  // Remove Stacked navigation service
  // final _navigationService = locator<NavigationService>();

  // Initialize ApiService directly or through GetX dependency injection
  final _apiService = ApiService(); // Or use Get.find<ApiService>() if registered with GetX

  final emailTEC = TextEditingController();
  final phoneTEC = TextEditingController();
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  AmountViewModel(){
    if(kDebugMode){
      emailTEC.text = "hafizijaz656@gmail.com";
      phoneTEC.text = "923024116232";
    }
   }

  Future<void> getToken({
    required BuildContext context,
    required String srtAmount,
    required String packageId,
  }) async {
    AppLogger.network('Getting PayFast token...');
    AppLogger.info('Amount: $srtAmount');
    AppLogger.info('Package ID: $packageId');

    if (!formKey.currentState!.validate()) {
      AppLogger.warning('Form validation failed');
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {

      // Load merchant ID from environment variables instead of hardcoding
      String merchantId = EnvConfig.payfastMerchantId;
      
      if (merchantId.isEmpty) {
        AppLogger.error('PayFast merchant ID not configured in .env');
        Get.snackbar(
          "Configuration Error",
          "Payment gateway not configured. Please contact support.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }
      
      // Use SecureStorage for user ID instead of plain SharedPreferences
      final secureStorage = SecureStorageService();
      final userIdStr = await secureStorage.getUserId();
      final userId = userIdStr != null ? int.tryParse(userIdStr) : null;

      AppLogger.info('User ID: $userId');

      if (userId == null) {
        AppLogger.warning('User ID not found');
        Get.snackbar(
          "Error",
          "User not logged in",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final amount = double.parse(srtAmount);
      final basketId = 'ITEM-${Random().nextInt(10000).toString()}';

      AppLogger.info('Basket ID: $basketId');
      AppLogger.info('Email: ${emailTEC.text}');
      AppLogger.info('Phone: ${phoneTEC.text}');

      final token = await _apiService.getToken(basketId, amount.toString());
      AppLogger.success('Token received: ${token.substring(0, 20)}...');

      // Use GetX navigation instead of Stacked
      await Get.to(
            () => WebViewScreen(
          token: token,
          amount: amount,
          basketId: basketId,
          merchant: merchantId,
          packageId: packageId,
          userId: userId,
          email: emailTEC.text,
          phoneNumber: phoneTEC.text,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );

      AppLogger.success('Navigated to WebView');

    } catch (e) {
      AppLogger.error('Error in getToken', e);
      Get.snackbar(
        "Error",
        "Failed to process payment: ${e.toString()}",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    emailTEC.dispose();
    phoneTEC.dispose();
    super.dispose();
  }
}