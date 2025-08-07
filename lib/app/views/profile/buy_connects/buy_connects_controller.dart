// In buy_connects_controller.dart
// Remove Stacked navigation imports and use GetX navigation

import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Import your AmountView directly
import '../../../fast_pay/views/amount_view.dart';
import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/custom_button.dart';
import '../export.dart';

class BuyConnectsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();

  // Remove Stacked navigation service
  // final _navigationService = locator<NavigationService>();

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
  // Future<void> fetchProducts() async {
  //   debugPrint("🔍 Fetching products...");
  //
  //   const Set<String> productIds = {'silver_1500', 'gold_2000'};
  //
  //   try {
  //     // Check if in-app purchases are available
  //     final bool isAvailable = await _inAppPurchase.isAvailable();
  //     debugPrint("📱 In-app purchases available: $isAvailable");
  //
  //     if (!isAvailable) {
  //       debugPrint("❌ In-app purchases not available on this device");
  //       Get.snackbar(
  //         "Error",
  //         "In-app purchases are not available on this device",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       isLoading.value = false;
  //       return;
  //     }
  //
  //     final ProductDetailsResponse response =
  //     await _inAppPurchase.queryProductDetails(productIds);
  //
  //     debugPrint("📦 Products found: ${response.productDetails.length}");
  //     debugPrint("❌ Products not found: ${response.notFoundIDs}");
  //
  //     if (response.notFoundIDs.isNotEmpty) {
  //       debugPrint("⚠️ Some products not found: ${response.notFoundIDs}");
  //       Get.snackbar(
  //         "Warning",
  //         "Some products are not available: ${response.notFoundIDs.join(', ')}",
  //         backgroundColor: Colors.orange,
  //         colorText: Colors.white,
  //       );
  //     }
  //
  //     if (response.productDetails.isNotEmpty) {
  //       products.assignAll(response.productDetails);
  //       debugPrint("✅ Products loaded successfully");
  //
  //       // Print product details for debugging
  //       for (var product in response.productDetails) {
  //         debugPrint("💰 Product: ${product.id} - ${product.title} - ${product.price}");
  //       }
  //     } else {
  //       debugPrint("❌ No products found");
  //       Get.snackbar(
  //         "Error",
  //         "No products available for purchase",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     }
  //   } catch (e) {
  //     debugPrint("💥 Error fetching products: $e");
  //     Get.snackbar(
  //       "Error",
  //       "Failed to load products: $e",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   } finally {
  //     isLoading.value = false;
  //   }
  // }
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
  // void _handlePurchaseUpdates(List<PurchaseDetails> purchases) {
  //   debugPrint("🔄 Purchase updates received: ${purchases.length}");
  //
  //   for (var purchase in purchases) {
  //     debugPrint("💳 Purchase status: ${purchase.status}");
  //     debugPrint("💳 Purchase ID: ${purchase.purchaseID}");
  //     debugPrint("💳 Product ID: ${purchase.productID}");
  //
  //     if (purchase.status == PurchaseStatus.purchased) {
  //       debugPrint("✅ Purchase successful, verifying...");
  //       _verifyAndDeliverPurchase(purchase);
  //     } else if (purchase.status == PurchaseStatus.error) {
  //       debugPrint("❌ Purchase error: ${purchase.error}");
  //       Get.snackbar(
  //         "Purchase Failed",
  //         purchase.error?.message ?? "An error occurred during the purchase.",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //     } else if (purchase.status == PurchaseStatus.pending) {
  //       debugPrint("⏳ Purchase pending...");
  //       Get.snackbar(
  //         "Purchase Pending",
  //         "Your purchase is being processed...",
  //         backgroundColor: Colors.orange,
  //         colorText: Colors.white,
  //       );
  //     } else if (purchase.status == PurchaseStatus.canceled) {
  //       debugPrint("🚫 Purchase canceled by user");
  //       Get.snackbar(
  //         "Purchase Canceled",
  //         "Payment was canceled",
  //         backgroundColor: Colors.grey,
  //         colorText: Colors.white,
  //       );
  //     }
  //   }
  // }

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

// In BuyConnectsController, modify the purchase method to bypass Google Play for testing:
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
  // purchase({required PackageModel package}) async {
  //   debugPrint("🛒 Attempting to purchase: ${package.packageName}");
  //
  //   try {
  //     // Check if purchases are available
  //     final bool isAvailable = await _inAppPurchase.isAvailable();
  //     if (!isAvailable) {
  //       debugPrint("❌ In-app purchases not available");
  //       Get.snackbar(
  //         "Error",
  //         "In-app purchases are not available",
  //         backgroundColor: Colors.red,
  //         colorText: Colors.white,
  //       );
  //       return;
  //     }
  //
  //     ProductDetails? product = getProductById(package.productId);
  //
  //     if (product != null) {
  //       debugPrint("💳 Starting purchase for: ${product.title}");
  //
  //       final purchaseParam = PurchaseParam(productDetails: product);
  //
  //       // Show loading indicator
  //       Get.snackbar(
  //         "Processing",
  //         "Starting purchase...",
  //         backgroundColor: Colors.blue,
  //         colorText: Colors.white,
  //         duration: Duration(seconds: 2),
  //       );
  //
  //       bool purchaseResult = await _inAppPurchase.buyConsumable(
  //           purchaseParam: purchaseParam
  //       );
  //       debugPrint("🔄 Purchase initiated: $purchaseResult");
  //
  //     } else {
  //       debugPrint("❌ Product not found: ${package.productId}");
  //
  //       // FOR TESTING ONLY - Remove this in production
  //       if (kDebugMode) {
  //         // Show dialog to simulate purchase
  //         final result = await Get.dialog<bool>(
  //           AlertDialog(
  //             title: Text("Test Purchase"),
  //             content: Text(
  //               "Product '${package.packageName}' not found in Google Play.\n\n"
  //                   "Would you like to simulate a successful purchase for testing?",
  //             ),
  //             actions: [
  //               TextButton(
  //                 onPressed: () => Get.back(result: false),
  //                 child: Text("Cancel"),
  //               ),
  //               TextButton(
  //                 onPressed: () => Get.back(result: true),
  //                 child: Text("Simulate Purchase"),
  //               ),
  //             ],
  //           ),
  //         );
  //
  //         if (result == true) {
  //           // Simulate successful purchase
  //           subscribedPopup(
  //             price: "PKR ${package.packagePrice}",
  //             packageName: package.packageName,
  //             productId: package.productId,
  //           );
  //
  //           // Create a fake transaction for testing
  //           createTransaction(
  //             connectsPackagesId: package.productId,
  //             transactionId: "TEST_${DateTime.now().millisecondsSinceEpoch}",
  //           );
  //         }
  //       } else {
  //         // Production error
  //         Get.snackbar(
  //           "Error",
  //           "Product ${package.packageName} is not available",
  //           backgroundColor: Colors.red,
  //           colorText: Colors.white,
  //         );
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint("💥 Purchase error: $e");
  //     Get.snackbar(
  //       "Error",
  //       "Failed to start purchase: $e",
  //       backgroundColor: Colors.red,
  //       colorText: Colors.white,
  //     );
  //   }
  // }
  //
  // ProductDetails? getProductById(String productId) {
  //   return products.firstWhereOrNull(
  //         (product) => product.id == productId,
  //   );
  // }

  ///----------Google Pay End----------
  ///----------Go Pay Fast ------------
  ///PayFast Methods - UPDATED TO USE GETX NAVIGATION
  Future<void> payWithGoFastPay({
    required BuildContext context,
    required String amount,
    required String packageId,
  }) async {
    debugPrint("💳 Opening PayFast for amount: $amount, package: $packageId");

    try {
      // Validate inputs
      // if (amount.isEmpty) {
      //   debugPrint("❌ Amount is empty");
      //   Get.snackbar(
      //     "Error",
      //     "Invalid amount",
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }

      // if (packageId.isEmpty) {
      //   debugPrint("❌ Package ID is empty");
      //   Get.snackbar(
      //     "Error",
      //     "Invalid package",
      //     backgroundColor: Colors.red,
      //     colorText: Colors.white,
      //   );
      //   return;
      // }

      debugPrint("🚀 Navigating to AmountView using GetX...");

      // Use GetX navigation instead of Stacked
      final result = await Get.to(
            () => AmountView(
          amount: amount,
          packageId: packageId,
        ),
        transition: Transition.rightToLeft,
        duration: const Duration(milliseconds: 300),
      );

      debugPrint("🔄 Navigation result: $result");
      debugPrint("🔄 Returned from PayFast, refreshing connects...");
      getConnects();

    } catch (e, stackTrace) {
      debugPrint("❌ Error opening PayFast: $e");
      debugPrint("📍 Stack trace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to open PayFast: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  void dispose() {
    controllerCenter!.dispose();
    emailTEC.dispose();
    phoneTEC.dispose();
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