// In buy_connects_controller.dart
// Fixed version with proper confetti controller management

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

  RxBool isLoading = true.obs;
  RxInt totalConnects = 0.obs;
  ConfettiController? controllerCenter;

  ///in-app-purchase
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final List<ProductDetails> products = <ProductDetails>[].obs;
  // A set to keep track of purchases being processed to avoid duplicates.
  final Set<String> _processingPurchases = <String>{};
  // Track if purchase is already in progress
  RxBool isPurchaseInProgress = false.obs;
  // Track last purchase time to prevent rapid clicks
  DateTime? _lastPurchaseTime;

  ///Go Pay Fast
  final emailTEC = TextEditingController();
  final phoneTEC = TextEditingController();

  // Add stream subscription variable
  StreamSubscription<List<PurchaseDetails>>? _purchaseStreamSubscription;

  @override
  void onInit() {
    super.onInit();
    debugPrint("🔄 BuyConnectsController initialized");

    // Always fetch fresh connects count
    getConnects();

    // Initialize confetti controller if not exists or disposed
    _initializeConfettiController();

    // Clear any stuck processing purchases from previous instances
    _processingPurchases.clear();
    isPurchaseInProgress.value = false;
    debugPrint("✅ Controller ready for purchases");

    // Cancel any existing subscription first
    _purchaseStreamSubscription?.cancel();

    // Small delay to ensure clean state
    Future.delayed(const Duration(milliseconds: 100), () {
      // Create new subscription with proper handling
      _purchaseStreamSubscription = _inAppPurchase.purchaseStream.listen(
            (List<PurchaseDetails> purchases) {
          // Filter out already completed purchases
          final newPurchases = purchases.where((p) =>
          p.purchaseID == null || !_completedPurchases.contains(p.purchaseID)
          ).toList();

          if (newPurchases.isNotEmpty) {
            _handlePurchaseUpdates(newPurchases);
          }
        },
        onDone: () {
          debugPrint('Purchase stream done');
        },
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
        cancelOnError: false,
      );
    });

    fetchProducts();
    _inAppPurchase.isAvailable().then((available) {
      if (available) {
        // Don't restore on every init, only when needed
        // _inAppPurchase.restorePurchases();
      }
    });
  }

  // NEW METHOD: Initialize or reinitialize confetti controller
  void _initializeConfettiController() {
    // Check if controller exists and is not disposed
    if (controllerCenter == null) {
      controllerCenter = ConfettiController(
        duration: const Duration(seconds: 10),
      );
      debugPrint("🎊 Confetti controller initialized");
    } else {
      // If it exists, ensure it's ready for use
      try {
        // Try to stop it to check if it's still valid
        controllerCenter!.stop();
        debugPrint("🎊 Confetti controller is active and ready");
      } catch (e) {
        // If error, it was disposed, create new one
        controllerCenter = ConfettiController(
          duration: const Duration(seconds: 10),
        );
        debugPrint("🎊 Confetti controller recreated after disposal");
      }
    }
  }

  // NEW METHOD: Ensure confetti plays reliably
  void _playConfetti() {
    // Always check and reinitialize if needed before playing
    _initializeConfettiController();

    // Stop any current animation
    controllerCenter!.stop();

    // Small delay to ensure stop completes
    Future.delayed(const Duration(milliseconds: 50), () {
      controllerCenter!.play();
      debugPrint("🎊 Confetti animation started!");

      // Backup play call for reliability
      Future.delayed(const Duration(milliseconds: 200), () {
        if (controllerCenter != null) {
          controllerCenter!.play();
          debugPrint("🎊 Confetti animation reinforced!");
        }
      });
    });
  }

  @override
  void onClose() {
    _processingPurchases.clear();
    isPurchaseInProgress.value = false;

    _purchaseStreamSubscription?.cancel();
    // Don't dispose confetti controller here if you want it to persist
    // Only dispose if truly closing the entire feature
    if (controllerCenter != null) {
      controllerCenter!.stop(); // Just stop, don't dispose
    }
    emailTEC.dispose();
    phoneTEC.dispose();
    super.onClose();
  }

  getConnects() async {
    isLoading.value = true;
    debugPrint("📡 Fetching connects from backend...");

    final response = await systemConfigUseCases.getConnects();
    response.fold(
          (error) {
        isLoading.value = false;
        debugPrint("❌ Error fetching connects: ${error.title}");
      },
          (success) {
        isLoading.value = false;
        final newConnects = int.parse(success);
        final oldConnects = totalConnects.value;
        totalConnects.value = newConnects;

        // Force update to ensure UI refreshes
        update();

        if (newConnects != oldConnects) {
          debugPrint("🔄 Connects updated: $oldConnects → $newConnects");
        } else {
          debugPrint("📊 Connects unchanged: $newConnects");
        }
      },
    );
  }

  // This method is for granting connects via backend, not for initiating a purchase.
  Future<bool> _grantConnectsAndLogTransaction({
    required String productId,
    required String description,
    required String transactionId,
    required String currencyCode,
    required dynamic amount,
    required int actualAmount,
  }) async {
    final connectsToAdd = getConnectsBasedOnPurchase(productId);
    if (connectsToAdd == 0) return false;

    debugPrint("🔄 Calling buyConnects API: +$connectsToAdd connects");

    debugPrint("📝 Logging transaction: $transactionId");
    await createGoogleTransaction(
      transactionId: transactionId,
      googleConsoleId: productId,
      currencyCode: currencyCode,
      amount: amount,
      discountedAmount: 0.0,
      actualAmount: actualAmount,
      paymentSource: "Google Pay",
    );

    return true;
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

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchases) async {
    debugPrint("🔄 Purchase updates received: ${purchases.length}");

    // Process only unique purchases
    final uniquePurchases = <String, PurchaseDetails>{};
    for (var purchase in purchases) {
      if (purchase.purchaseID != null) {
        uniquePurchases[purchase.purchaseID!] = purchase;
      }
    }

    for (var purchase in uniquePurchases.values) {
      // CRITICAL: Check if already completed FIRST before any other checks
      if (purchase.purchaseID != null && _completedPurchases.contains(purchase.purchaseID)) {
        debugPrint("✅ Purchase already completed: ${purchase.purchaseID}, completing with Google Play only.");
        // Just complete it with Google Play if pending
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        continue;
      }

      // Check both local and global processing sets
      if (_processingPurchases.contains(purchase.purchaseID) ||
          _globalProcessingPurchases.contains(purchase.purchaseID)) {
        debugPrint("🔄 Already processing purchase: ${purchase.purchaseID}, skipping.");
        continue;
      }

      if (purchase.status == PurchaseStatus.purchased) {
        debugPrint("✅ Purchase successful, verifying...");

        // Add to processing sets (NOT completed yet)
        if (purchase.purchaseID != null) {
          _processingPurchases.add(purchase.purchaseID!);
          _globalProcessingPurchases.add(purchase.purchaseID!);
        }

        await _verifyAndDeliverPurchase(purchase);
        // Reset purchase in progress flag
        isPurchaseInProgress.value = false;

      } else if (purchase.status == PurchaseStatus.restored) {
        // This is a restored purchase. You might want to handle this.
        // For consumable products, you might not need to do anything, but you should still complete them.
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
          debugPrint("Restored purchase completed: ${purchase.purchaseID}");
        }
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint("❌ Purchase error: ${purchase.error}");
        Get.snackbar(
          "Purchase Failed",
          purchase.error?.message ?? "An error occurred during the purchase.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        _processingPurchases.remove(purchase.purchaseID);
        isPurchaseInProgress.value = false;
      } else if (purchase.status == PurchaseStatus.pending) {
        debugPrint("⏳ Purchase pending...");
        Get.snackbar(
          "Purchase Pending",
          "Your purchase is being processed...",
          backgroundColor: Colors.orange,
          colorText: Colors.white,
        );
      } else if (purchase.status == PurchaseStatus.canceled) {
        debugPrint("🚫 Purchase canceled by user");
        Get.snackbar(
          "Purchase Canceled",
          "Payment was canceled",
          backgroundColor: Colors.grey,
          colorText: Colors.white,
        );
        _processingPurchases.remove(purchase.purchaseID);
        isPurchaseInProgress.value = false;
      }
    }
  }

  // Track completed purchases to prevent duplicates (static to persist across instances)
  static final Set<String> _completedPurchases = {};
  static final Set<String> _globalProcessingPurchases = {};
  static final Set<String> _processedTransactions = {}; // Track backend transactions
  static final Set<String> _grantedPurchases = {}; // Track which purchases have had connects granted

  // Lock to prevent concurrent processing
  static bool _isProcessingAnyPurchase = false;

  Future<void> _verifyAndDeliverPurchase(PurchaseDetails purchase) async {
    try {

      ProductDetails? product = getProductById(purchase.productID);
      if (product == null) {
        debugPrint("Could not find product for id: ${purchase.productID}");
        isPurchaseInProgress.value = false;
        return; // Exit if product details are not found.
      }

      // CRITICAL: Check if this transaction was already processed in backend
      final transactionId = purchase.purchaseID ?? "UNKNOWN";
      if (_processedTransactions.contains(transactionId)) {
        debugPrint("⚠️ Transaction already processed in backend: $transactionId");
        // Still complete with Google Play
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        return;
      }

      // CRITICAL: Check if connects were already granted for this purchase
      if (_grantedPurchases.contains(transactionId)) {
        debugPrint("⚠️ Connects already granted for purchase: $transactionId");
        debugPrint("⚠️ Skipping grant to prevent duplicate connects");
        // Still complete with Google Play
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
        }
        return;
      }

      // Mark transaction as being processed
      _processedTransactions.add(transactionId);

      // 1. Grant connects AND log transaction in one call
      debugPrint("💰 Granting connects and logging transaction: $transactionId");
      _grantedPurchases.add(transactionId); // Mark BEFORE calling API

      final bool connectsGranted = await _grantConnectsAndLogTransaction(
        productId: purchase.productID,
        description: "Purchased via Google Play",
        transactionId: transactionId,
        currencyCode: product.currencyCode,
        amount: product.rawPrice,
        actualAmount: product.rawPrice.toInt(),
      );

      if (connectsGranted) {
        // Real-time update: Fetch latest connects count from backend IMMEDIATELY
        final oldConnects = totalConnects.value;
        debugPrint("📊 Old connects: $oldConnects");

        // Force immediate backend fetch for real-time update
        await getConnects();
        await Future.delayed(Duration(milliseconds: 100)); // Let the response settle

        final newConnects = totalConnects.value;
        debugPrint("🎉 Connects updated in real-time: $oldConnects → $newConnects");

        // UI will auto-update with Obx - just ensure value is set
        totalConnects.value = newConnects;
        totalConnects.refresh(); // Force refresh of observable

        debugPrint("🔄 Connects observable updated: ${totalConnects.value}");

        // 2. Use the new _playConfetti method for reliable animation
        _playConfetti();

        // 3. Show success snackbar with connects update
        final connectsAdded = getConnectsBasedOnPurchase(purchase.productID);
        await Future.delayed(Duration(milliseconds: 100)); // Small delay for better UX

        Get.snackbar(
          "🎉 Purchase Successful!",
          "Added $connectsAdded connects! Your total: $newConnects connects",
          backgroundColor: Colors.green,
          colorText: Colors.white,
          duration: Duration(seconds: 3),
          snackPosition: SnackPosition.TOP,
          margin: EdgeInsets.all(10),
          borderRadius: 8,
          icon: Icon(Icons.celebration, color: Colors.white, size: 28),
        );

        // 4. Show success pop-up with package details
        await subscribedPopup(
          packageName: product.title,
        );

        // 5. Mark as completed ONLY after successful verification and delivery
        if (purchase.purchaseID != null) {
          _completedPurchases.add(purchase.purchaseID!);
          debugPrint("✅ Purchase marked as completed: ${purchase.purchaseID}");
        }

        // 6. IMPORTANT: Complete the purchase with Google Play.
        if (purchase.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchase);
          debugPrint("✅ Purchase successfully completed and consumed: ${purchase.purchaseID}");
        }

        // NOTE: No final refresh needed - connects already refreshed after grant
        debugPrint("✅ Purchase flow completed successfully");

      } else {
        // If connects were not granted, show an error.
        Get.snackbar(
          "Delivery Failed",
          "Could not add connects to your account. Please contact support.",
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      debugPrint("❌ Error during verification/delivery: $e");
      // Remove from processed transactions on error so it can be retried
      _processedTransactions.remove(purchase.purchaseID);
      _grantedPurchases.remove(purchase.purchaseID); // Remove from granted as well
      // DON'T add to completed purchases on error
      debugPrint("⚠️ Purchase failed, not marked as completed: ${purchase.purchaseID}");
      Get.snackbar(
        "Purchase Failed",
        "Failed to verify purchase. Please contact support.",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      // ALWAYS remove the purchase from the processing sets (not from completed)
      _processingPurchases.remove(purchase.purchaseID);
      _globalProcessingPurchases.remove(purchase.purchaseID);
      debugPrint("🏁 Finished processing purchase: ${purchase.purchaseID}");
      debugPrint("📊 Total completed purchases: ${_completedPurchases.length}");
      debugPrint("📊 Total processed transactions: ${_processedTransactions.length}");
      debugPrint("📊 Total granted purchases: ${_grantedPurchases.length}");
    }
  }

  // In BuyConnectsController, modify the purchase method to prevent duplicate purchases:
  purchase({required PackageModel package}) async {
    // Check if purchase is already in progress
    if (isPurchaseInProgress.value) {
      debugPrint('⚠️ Purchase already in progress, ignoring duplicate request');
      Get.snackbar(
        'Please Wait',
        'A purchase is already being processed',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    // Check for rapid clicks (within 2 seconds)
    if (_lastPurchaseTime != null &&
        DateTime.now().difference(_lastPurchaseTime!).inSeconds < 2) {
      debugPrint('⚠️ Rapid purchase attempt blocked');
      return;
    }

    ProductDetails? product = getProductById(package.productId);
    if (product != null) {
      // Set purchase in progress flag
      isPurchaseInProgress.value = true;
      _lastPurchaseTime = DateTime.now();

      try {
        final purchaseParam = PurchaseParam(productDetails: product);
        await _inAppPurchase.buyConsumable(purchaseParam: purchaseParam);
      } catch (e) {
        debugPrint('❌ Error initiating purchase: $e');
        isPurchaseInProgress.value = false;
      }

      // Reset flag after a delay
      Future.delayed(const Duration(seconds: 3), () {
        isPurchaseInProgress.value = false;
      });
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
      debugPrint("🔍 Stack trace: $stackTrace");
      Get.snackbar(
        "Error",
        "Failed to open PayFast: $e",
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  ///---------Manual Payment-----------
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
                      Flexible(
                        child: Text(
                          'Send Receipt via WhatsApp \n+92 306 4727345',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                            height: 1.2,
                          ),
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
    // Clear local processing but keep global tracking
    _processingPurchases.clear();
    isPurchaseInProgress.value = false;

    _purchaseStreamSubscription?.cancel();
    // Properly dispose confetti controller on final disposal
    controllerCenter?.dispose();
    emailTEC.dispose();
    phoneTEC.dispose();
    super.dispose();
  }

  // Method to clear old completed purchases (call this periodically)
  static void clearOldCompletedPurchases() {
    if (_completedPurchases.length > 100) {
      // Keep only recent 50 purchases
      final recentPurchases = _completedPurchases.toList().sublist(
          _completedPurchases.length - 50
      );
      _completedPurchases.clear();
      _completedPurchases.addAll(recentPurchases);
    }

    if (_processedTransactions.length > 100) {
      // Keep only recent 50 transactions
      final recentTransactions = _processedTransactions.toList().sublist(
          _processedTransactions.length - 50
      );
      _processedTransactions.clear();
      _processedTransactions.addAll(recentTransactions);
    }

    if (_grantedPurchases.length > 100) {
      // Keep only recent 50 granted purchases
      final recentGranted = _grantedPurchases.toList().sublist(
          _grantedPurchases.length - 50
      );
      _grantedPurchases.clear();
      _grantedPurchases.addAll(recentGranted);
    }
  }

  // Refactored to be a simple confirmation dialog.
  subscribedPopup({
    required String packageName,
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
                "You have successfully subscribed to the $packageName plan! Your connects have been added to your account.",
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
                },
              ),
            ],
          ),
        );
      },
    );
  }

  createGoogleTransaction({
    required dynamic transactionId,
    required dynamic googleConsoleId,
    required dynamic currencyCode,
    required dynamic amount,
    required double discountedAmount,
    required int actualAmount,
    required dynamic paymentSource,

  }) async {
    debugPrint("📝 Creating transaction:");
    debugPrint("   Transaction ID: $transactionId");
    debugPrint("   Package: $googleConsoleId");
    debugPrint("   Amount: $amount");
    debugPrint("   Payment Source: $paymentSource");

    // NOTE: Duplicate check already done in _verifyAndDeliverPurchase
    // No need to check again here as transaction ID was already added to _processedTransactions

    final response = await systemConfigUseCases.createGoogleTransaction(
      transactionId: transactionId,
      googleConsoleId: googleConsoleId,
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
      return 3;
    } else if (productId == "gold_2000") {
      return 8;
    } else {
      return 0;
    }
  }
}