import 'dart:async';


import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:stacked_services/stacked_services.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../fast_pay/app/app.locator.dart';
import '../../../fast_pay/app/app.router.dart';
import '../../../utils/exports.dart';
import '../../../widgets/custom_button.dart';
import '../export.dart';

class BuyConnectsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final _navigationService = locator<NavigationService>();

  RxBool isLoading = true.obs;
  RxInt totalConnects = 0.obs;
  ConfettiController? controllerCenter;

  ///in-app-purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> products = <ProductDetails>[].obs;

  ///Go Pay Fast
  final emailTEC = TextEditingController();
  final phoneTEC = TextEditingController();

  @override
  void onInit() {
    getConnects();
    controllerCenter = ConfettiController(
      duration: const Duration(seconds: 10),
    );
    super.onInit();
    _inAppPurchase.purchaseStream.listen((List<PurchaseDetails> purchases) {
      _handlePurchaseUpdates(purchases);
    });
    fetchProducts();
  }

  getConnects() async {
    isLoading = true.obs;
    final response = await systemConfigUseCases.getConnects();
    return response.fold(
      (error) {
        isLoading = false.obs;
      },
      (success) {
        isLoading = false.obs;
        totalConnects.value = int.parse(success);
        update();
      },
    );
  }

  buyConnects(context, {int? connect, afterPayment}) async {
    if (afterPayment == false) AppUtils.onLoading(context);
    final response = await systemConfigUseCases.buyConnects(
      connect: connect ?? 0,
      connectDesc: "By using google pay",
    );
    return response.fold(
      (error) {
        if (afterPayment == false) AppUtils.dismissLoader(context);
      },
      (success) {
        if (afterPayment == false) AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Connect Purchased",
          message: "Connects added into your account.",
        );
        totalConnects.value += connect ?? 0;
        controllerCenter!.play();
        update();
      },
    );
  }

  ///Google Pay
  Future<void> fetchProducts() async {
    const Set<String> productIds = {'silver_1500', 'gold_2000'};
    final ProductDetailsResponse response =
        await _inAppPurchase.queryProductDetails(productIds);
    if (response.notFoundIDs.isEmpty) {
      products.assignAll(response.productDetails);
    }
    isLoading.value = false;
  }

  void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
    for (var purchase in purchases) {
      if (purchase.status == PurchaseStatus.purchased) {
        _verifyAndDeliverPurchase(purchase);
      } else if (purchase.status == PurchaseStatus.error) {
        Get.snackbar(
          "Purchase Failed",
          "An error occurred during the purchase.",
        );
      }
    }
  }

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    // Consume the purchase if it's consumable
    if (purchase.pendingCompletePurchase) {
      await _inAppPurchase.completePurchase(purchase);
    }
    ProductDetails? product = getProductById(purchase.productID);
    subscribedPopup(
      price: product!.price,
      packageName: product.title,
      productId: purchase.productID,
    );

    Get.snackbar(
      "Purchase Successful",
      "You have successfully purchased connects!",
    );
    createTransaction(
      connectsPackagesId: purchase.productID,
      transactionId: purchase.purchaseID,
    );
  }

  purchase({required PackageModel package}) {
    ProductDetails? product = getProductById(package.productId);
    if (product != null) {
      final purchaseParam = PurchaseParam(productDetails: product);
      _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
    }
  }

  ProductDetails? getProductById(String productId) {
    return products.firstWhereOrNull(
      (product) => product.id == productId,
    );
  }

  ///----------Google Pay End----------
  ///----------Go Pay Fast ------------
  payWithGoFastPay({
    required BuildContext context,
    required String amount,
    required String packageId,
  }) async {
    await _navigationService.navigateTo(
      Routes.amountView,
      arguments: AccountScreenArguments(
        amount: amount,
        packageId: packageId,
      ),
    )!.then((onValue){
      getConnects();
    });
  }

  @override
  void dispose() {
    controllerCenter!.dispose();
    super.dispose();
  }

  subscribedPopup({
    required String price,
    required String packageName,
    required String productId,
  }) {
    showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          titlePadding: EdgeInsets.zero,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 60,
              ),
              const SizedBox(height: 16),
              Text(
                "Subscription Successful!",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "You have successfully subscribed to your selected plan! Enjoy access to exclusive features and benefits tailored to your $packageName membership.",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              CustomButton(
                text: "Close",
                height: 45,
                isGradient: true,
                fontColor: AppColors.whiteColor,
                onTap: () {
                  Navigator.of(context).pop();
                  buyConnects(
                    context,
                    connect: getConnectsBasedOnPurchase(productId),
                    afterPayment: true,
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  createTransaction({
    required connectsPackagesId,
    required transactionId,
  }) async {
    final response = await systemConfigUseCases.createTransaction(
      connectsPackagesId: connectsPackagesId,
      transactionId: transactionId,
    );
    return response.fold(
      (error) {
        debugPrint("Error : ${error.title}");
      },
      (success) {
        debugPrint("Success : $success");
      },
    );
  }

  int getConnectsBasedOnPurchase(String productId) {
    if (productId == "silver_1500") {
      return 03;
    } else if (productId == "gold_2000") {
      return 08;
    } else {
      return 0;
    }
  }
}
