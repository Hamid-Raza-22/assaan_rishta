import 'dart:convert';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../utils/exports.dart';
import '../../widgets/custom_button.dart';

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

  @override
  void initState() {
    super.initState();

    String params = "TOKEN=${widget.token}" +
        "&MERCHANT_ID=${widget.merchant}" +
        "&MERCHANT_NAME=ASAAN RISHTA" +
        "&PROCCODE=00" +
        "&TXNAMT=${widget.amount}" +
        "&CUSTOMER_MOBILE_NO=${widget.phoneNumber}" +
        "&CUSTOMER_EMAIL_ADDRESS=${widget.email}" +
        "&SIGNATURE=testsign" +
        "&VERSION=MERCHANT-CART-0.1" +
        "&TXNDESC=Silver Package_for chat" +
        "&SUCCESS_URL=${getSuccessCheckUrl()}" +
        "&FAILURE_URL=https://asaanrishta.com/failure" +
        "&BASKET_ID=${widget.basketId}" +
        "&ORDER_DATE=${getOrderDate()}" +
        "&CHECKOUT_URL=https://thsolutionz.com/api/PayFastController/CheckOut" +
        "&CURRENCY_CODE=PKR" +
        "&TRAN_TYPE=ECOMM_PURCHASE" +
        "&RECURRING_TXN=";

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final url = request.url;
            if (url.contains('asaanrishta.com/success')) {
              isSuccess = true;
            }
            if (url.contains('asaanrishta.com/failure')) {
              isSuccess = false;
            }
            Future.delayed(const Duration(seconds: 3), () {
              setState(() {});
            });
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(
            'https://ipguat.apps.net.pk/Ecommerce/api/Transaction/PostTransaction'),
        method: LoadRequestMethod.post,
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: Uint8List.fromList(utf8.encode(params)),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: AppBar(
        backgroundColor: AppColors.whiteColor,
        surfaceTintColor: AppColors.whiteColor,
        title: const Text('Payment'),
      ),
      body: WebViewWidget(controller: _controller),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: isSuccess
            ? CustomButton(
                isEnable: true,
                isGradient: true,
                fontColor: Colors.white,
                text: "Back to Profiles",
                onTap: () {
                  if (isSuccess) {
                    // Get.offAll(
                    //   () => const BottomNavView(),
                    //   binding: AppBindings(),
                    // );
                  } else {
                    Get.back();
                  }
                },
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
    return "https://asaanrishta.com/success/${widget.userId}/${widget.packageId}";
  }
}
