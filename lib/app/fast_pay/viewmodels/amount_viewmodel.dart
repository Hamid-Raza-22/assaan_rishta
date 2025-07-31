import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stacked/stacked.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../core/export.dart';
import '../../core/services/storage_services/export.dart';
import '../app/app.locator.dart';
import '../app/app.router.dart';
import '../services/api_service.dart';

class AmountViewModel extends BaseViewModel {
  final formKey = GlobalKey<FormState>();
  final _navigationService = locator<NavigationService>();
  final _apiService = locator<ApiService>();
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
    _isLoading = true;
    notifyListeners();
    try {
      String merchantId = "102";
      final sharedPref = await SharedPreferences.getInstance();
      int? userId = sharedPref.getInt(StorageKeys.userId);
      final amount = double.parse(srtAmount);
      final basketId = 'ITEM-${Random().nextInt(10000).toString()}';
      final token = await _apiService.getToken(basketId, amount.toString());
      await _navigationService.navigateTo(
        Routes.webViewScreen,
        arguments: WebViewScreenArguments(
          token: token,
          amount: amount,
          basketId: basketId,
          merchant: merchantId,
          packageId: packageId,
          userId: userId!,
          email: emailTEC.text,
          phoneNumber: phoneTEC.text,
        ),
      );
    } catch (e) {
      debugPrint('Error: $e');
      // Handle error appropriately
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
