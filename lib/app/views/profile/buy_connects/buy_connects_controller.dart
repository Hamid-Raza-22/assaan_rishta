// In buy_connects_controller.dart
// Remove Stacked navigation imports and use GetX navigation

import 'dart:async';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

// Import your AmountView directly
import '../../../fast_pay/views/amount_view.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/export.dart';
import '../export.dart';

class BuyConnectsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();

  // // Remove Stacked navigation service
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
    // createTransaction(
    //   connectsPackagesId: purchase.productID,
    //   transactionId: purchase.purchaseID,
    // );
    await createTransaction(
      transactionId: purchase.purchaseID ?? "UNKNOWN",
      connectsPackagesId: purchase.productID,
    );
    await createGoogleTransaction(
      transactionId: purchase.purchaseID ?? "UNKNOWN",
      connectsPackagesId: purchase.productID,
      currencyCode: product.currencyCode,
      amount: product.rawPrice,
      discountedAmount: 0, // Add discount logic if needed
      actualAmount: product.rawPrice,
      paymentSource: "Google Play",
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
  ///---------Manual Payment-----------


// Add this updated method to your BuyConnectsController class

// Compact and Professional Manual Payment Dialog

  showManualPaymentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          titlePadding: EdgeInsets.fromLTRB(20, 20, 20, 0),
          contentPadding: EdgeInsets.fromLTRB(20, 16, 20, 0),
          actionsPadding: EdgeInsets.fromLTRB(20, 0, 20, 16),
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.account_balance,
                      color: AppColors.primaryColor, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Bank Transfer',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => Get.back(),
                child: Icon(Icons.close, color: Colors.grey[600], size: 20),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Compact Bank Details Card
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Bank Name
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'MEEZAN BANK - ASAAN RISHTA',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 16, thickness: 0.5),

                    // IBAN Row
                    _buildCompactDetailRow(
                      label: 'IBAN',
                      value: 'PK46MEZN0002190112349582',
                      onCopy: () => _copyToClipboard(
                          'PK46MEZN0002190112349582',
                          'IBAN'
                      ),
                    ),
                    SizedBox(height: 8),

                    // Account Number Row
                    _buildCompactDetailRow(
                      label: 'Account',
                      value: '0112349582',
                      onCopy: () => _copyToClipboard(
                          '0112349582',
                          'Account Number'
                      ),
                    ),
                    Divider(height: 16, thickness: 0.5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'JAZZCASH - ASAAN RISHTA',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),

                    // Account Number Row
                    _buildCompactDetailRow(
                      label: 'Account',
                      value: '03064727345',
                      onCopy: () => _copyToClipboard(
                          '03064727345',
                          'Account Number'
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 12),

              // WhatsApp Button - Compact
              InkWell(
                onTap: () => _openWhatsApp('+923064727345'),
                child: Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.send, color: Colors.white, size: 16),
                      SizedBox(width: 8),
                      Text(
                        'Send Receipt via WhatsApp \n+92 306 4727345',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 8),

              // Compact Note
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.blue[700], size: 14),
                    SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Connects will be added after payment verification',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.blue[800],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: EdgeInsets.symmetric(vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  'Got it',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// Compact detail row helper
  Widget _buildCompactDetailRow({
    required String label,
    required String value,
    required VoidCallback onCopy,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          child: Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 11,
              color: Colors.grey[600],
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
        ),
        GestureDetector(
          onTap: onCopy,
          child: Container(
            padding: EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Icon(
              Icons.copy,
              size: 14,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

// Copy to clipboard function - Simplified
  void _copyToClipboard(String text, String fieldName) async {
    await Clipboard.setData(ClipboardData(text: text));
    Get.snackbar(
      "Copied!",
      "$fieldName copied",
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: Duration(seconds: 1),
      snackPosition: SnackPosition.TOP,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      borderRadius: 8,
      animationDuration: Duration(milliseconds: 300),
    );
  }

// Open WhatsApp function - Simplified
  void _openWhatsApp(String phoneNumber) async {
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    String message = Uri.encodeComponent(
        "Assalam-O-Alaikum, I have made a payment for Asaan Rishta connects. "
            "Please find the payment receipt attached."
    );

    final whatsappUrl = Uri.parse(
        "whatsapp://send?phone=$cleanNumber&text=$message"
    );

    final whatsappWebUrl = Uri.parse(
        "https://wa.me/$cleanNumber?text=$message"
    );

    try {
      if (await canLaunchUrl(whatsappUrl)) {
        await launchUrl(whatsappUrl);
      } else if (await canLaunchUrl(whatsappWebUrl)) {
        await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      } else {
        await Clipboard.setData(ClipboardData(text: phoneNumber));
        Get.snackbar(
          "WhatsApp not found",
          "Number copied: $phoneNumber",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          duration: Duration(seconds: 2),
          snackPosition: SnackPosition.TOP,
        );
      }
    } catch (e) {
      await Clipboard.setData(ClipboardData(text: phoneNumber));
      Get.snackbar(
        "Number Copied",
        phoneNumber,
        backgroundColor: Colors.blue,
        colorText: Colors.white,
        duration: Duration(seconds: 2),
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
    required String transactionId,
    required String connectsPackagesId,


  }) async {
    debugPrint("📝 Creating transaction:");
    debugPrint("   Transaction ID: $transactionId");
    debugPrint("   Package: $connectsPackagesId");


    final response = await systemConfigUseCases.createTransaction(
      transactionId: transactionId,
      connectsPackagesId: connectsPackagesId,
    );

    return response.fold(
          (error) {
        debugPrint("❌ Transaction Error: ${error.title}");
        Get.snackbar(
          "Transaction Failed",
          error.description ?? "Could not save transaction",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
          (success) {
        debugPrint("✅ Transaction Success: $success");
      },
    );
  }
  createGoogleTransaction({
    required String transactionId,
    required String connectsPackagesId,
    required String currencyCode,
    required double amount,
    required double discountedAmount,
    required double actualAmount,
    required String paymentSource,

  }) async {
    debugPrint("📝 Creating transaction:");
    debugPrint("   Transaction ID: $transactionId");
    debugPrint("   Package: $connectsPackagesId");
    debugPrint("   Amount: $amount");
    debugPrint("   Payment Source: $paymentSource");


    final response = await systemConfigUseCases.createGoogleTransaction(
      transactionId: transactionId,
      connectsPackagesId: connectsPackagesId,
      currencyCode: currencyCode,
      amount: amount,
      discountedAmount: discountedAmount,
      actualAmount: actualAmount,
      paymentSource: paymentSource,
    );

    return response.fold(
          (error) {
        debugPrint("❌ Transaction Error: ${error.title}");
        Get.snackbar(
          "Transaction Failed",
          error.description ?? "Could not save transaction",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      },
          (success) {
        debugPrint("✅ Transaction Success: $success");
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