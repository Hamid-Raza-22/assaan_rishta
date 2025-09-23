import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';

// Import WebViewScreen directly
import '../views/webview_screen.dart';
import '../../core/services/storage_services/export.dart';
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
    debugPrint("🔗 Getting PayFast token...");
    debugPrint("💰 Amount: $srtAmount");
    debugPrint("📦 Package ID: $packageId");

    if (!formKey.currentState!.validate()) {
      debugPrint("❌ Form validation failed");
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {

      String merchantId = "83233";
      final sharedPref = await SharedPreferences.getInstance();
      int? userId = sharedPref.getInt(StorageKeys.userId);

      debugPrint("👤 User ID: $userId");

      if (userId == null) {
        debugPrint("❌ User ID not found");
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

      debugPrint("🛒 Basket ID: $basketId");
      debugPrint("📧 Email: ${emailTEC.text}");
      debugPrint("📱 Phone: ${phoneTEC.text}");

      final token = await _apiService.getToken(basketId, amount.toString());
      debugPrint("🔑 Token received: ${token.substring(0, 20)}...");

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

      debugPrint("✅ Navigated to WebView");

    } catch (e) {
      debugPrint('💥 Error in getToken: $e');
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