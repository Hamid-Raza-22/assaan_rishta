import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/services/env_config_service.dart';
import '../../utils/exports.dart';
import '../../widgets/custom_button.dart';
// Import your BottomNavView if needed for success navigation
// import '../bottom_nav/bottom_nav_view.dart';

class WebViewScreen extends StatefulWidget {
  final String token;
  final String basketId;
  final double amount;
  final String merchant;
  final String packageId;
  final int userId;
  final String email;
  final String phoneNumber;

  const WebViewScreen({
    super.key,
    required this.token,
    required this.basketId,
    required this.amount,
    required this.merchant,
    required this.packageId,
    required this.userId,
    required this.email,
    required this.phoneNumber,
  });

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool isSuccess = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();

    String params = "TOKEN=${widget.token}" "&MERCHANT_ID=${widget.merchant}" "&MERCHANT_NAME=ASAAN RISHTA" "&PROCCODE=00" "&TXNAMT=${widget.amount}" +
        "&CUSTOMER_MOBILE_NO=${widget.phoneNumber}" +
        "&CUSTOMER_EMAIL_ADDRESS=${widget.email}" +
        "&SIGNATURE=testsign" +
        "&VERSION=MERCHANT-CART-0.1" +
        "&TXNDESC=Silver Package_for chat" +
        "&SUCCESS_URL=${getSuccessCheckUrl()}" +
        "&FAILURE_URL=${EnvConfig.payfastFailureUrl}" +
        "&BASKET_ID=${widget.basketId}" +
        "&ORDER_DATE=${getOrderDate()}" +
        "&CHECKOUT_URL=${EnvConfig.payfastCheckoutUrl}" +
        "&CURRENCY_CODE=PKR" +
        "&TRAN_TYPE=ECOMM_PURCHASE" +
        "&RECURRING_TXN=";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            debugPrint("🌐 Page started loading: $url");
            setState(() {
              isLoading = true;
            });
          },
          onPageFinished: (String url) {
            debugPrint("✅ Page finished loading: $url");
            setState(() {
              isLoading = false;
            });
          },
          onNavigationRequest: (request) {
            final url = request.url;
            debugPrint("🔍 Navigation request to: $url");

            if (url.contains('asaanrishta.com/success')) {
              debugPrint("✅ Payment successful!");
              setState(() {
                isSuccess = true;
              });
              // Optional: Auto-navigate after success
              Future.delayed(const Duration(seconds: 2), () {
                handleSuccessNavigation();
              });
            }

            if (url.contains('asaanrishta.com/failure')) {
              debugPrint("❌ Payment failed!");
              setState(() {
                isSuccess = false;
              });
              Get.snackbar(
                "Payment Failed",
                "Transaction was not successful. Please try again.",
                backgroundColor: Colors.red,
                colorText: Colors.white,
                duration: const Duration(seconds: 3),
              );
            }

            return NavigationDecision.navigate;
          },
          onWebResourceError: (error) {
            debugPrint("❌ WebView error: ${error.description}");
            Get.snackbar(
              "Error",
              "Failed to load payment page: ${error.description}",
              backgroundColor: Colors.red,
              colorText: Colors.white,
            );
          },
        ),
      )
      ..loadRequest(
        Uri.parse(EnvConfig.payfastTransactionUrl),
        method: LoadRequestMethod.post,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: Uint8List.fromList(utf8.encode(params)),
      );
  }

  void handleSuccessNavigation() {
    if (isSuccess) {
      // Navigate to home or profile screen after successful payment
      // You can either:
      // 1. Go back to the previous screens
      Get.back(); // Back to AmountView
      Get.back(); // Back to BuyConnectsView

      // 2. Or navigate to a specific screen (uncomment and modify as needed)
      // Get.offAll(() => BottomNavView());

      Get.snackbar(
        "Payment Successful",
        "Your payment has been processed successfully!",
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Handle back button press
        if (!isSuccess) {
          final shouldPop = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Cancel Payment?'),
              content: const Text(
                  'Are you sure you want to cancel the payment process?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return shouldPop ?? false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: AppBar(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          title: const Text('Payment'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              if (isSuccess) {
                handleSuccessNavigation();
              } else {
                Get.back();
              }
            },
          ),
        ),
        body: Stack(
          children: [
            WebViewWidget(controller: _controller),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
          ],
        ),
        bottomNavigationBar: isSuccess
            ? Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            isEnable: true,
            isGradient: true,
            fontColor: Colors.white,
            text: "Back to Profiles",
            onTap: handleSuccessNavigation,
          ),
        )
            : null,
      ),
    );
  }

  String getOrderDate() {
    final dateFormat = DateFormat("yyyy-MM-dd HH:mm:ss", "en_US");
    return dateFormat.format(DateTime.now());
  }

  String getSuccessCheckUrl() {
    return "${EnvConfig.payfastSuccessUrl}/${widget.userId}/${widget.packageId}";
  }
}