import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'export.dart';
void showPurchaseBottomSheet({
  required BuildContext context,
  required BuyConnectsController controller,
  required PackageModel package,
}) {
  debugPrint("💳 Showing payment bottom sheet for: ${package.packageName}");

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    backgroundColor: AppColors.whiteColor,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            buildIconWithText(
              icon: Icons.payment,
              text: 'Google Pay',
              onTap: () {
                debugPrint("🔵 Google Pay clicked");
                Navigator.of(context).pop();
                controller.purchase(package: package);
              },
            ),
            buildIconWithText(
              icon: Icons.payment,
              text: 'Pay Fast',
              onTap: () async {
                debugPrint("🟡 PayFast clicked");
                Navigator.of(context).pop();

                try {
                  await controller.payWithGoFastPay(
                    context: context,
                    amount: package.packagePrice,
                    packageId: package.productId,
                  );
                  debugPrint("✅ PayFast navigation completed");
                } catch (e) {
                  debugPrint("❌ PayFast error: $e");
                  Get.snackbar(
                    "Error",
                    "Failed to open PayFast: $e",
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                }
              },
            ),
            buildIconWithText(
              icon: Icons.payment,
              text: 'Manual Pay',
              onTap: () async {
                debugPrint("🟡 Manual Accounts clicked");
                Navigator.of(context).pop();

                // Show GetX Dialog with account numbers
                Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white38,
                            Colors.white38
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Header
                          Row(
                            children: [
                              Icon(
                                Icons.account_balance_wallet,
                                color: Colors.blue,
                                size: 38,
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Account Numbers',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () => Get.back(),
                                icon: Icon(Icons.close, color: Colors.grey),
                              ),
                            ],
                          ),
                          SizedBox(height: 20),

                          // Account Details
                          _buildAccountItem(
                            'Easypaisa',
                            '03XX-XXXXXXX',
                            Colors.green,
                            Icons.phone_android,
                          ),
                          SizedBox(height: 12),

                          _buildAccountItem(
                            'JazzCash',
                            '03XX-XXXXXXX',
                            Colors.orange,
                            Icons.phone_android,
                          ),
                          SizedBox(height: 12),

                          _buildAccountItem(
                            'Meezan Bank',
                            'XXXX-XXXX-XXXX-XXXX',
                            Colors.blue,
                            Icons.account_balance,
                          ),

                          SizedBox(height: 24),

                          // Instructions
                          Container(
                            padding: EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info, color: Colors.blue, size: 20),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Transfer amount to any account above and send screenshot for verification',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: 20),

                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => Get.back(),
                                  style: OutlinedButton.styleFrom(
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(color: Colors.grey),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.grey.shade700),
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Get.back();
                                    // Add your confirmation logic here
                                    // Get.snackbar(
                                    //   "Success",
                                    //   "Please transfer the amount and send screenshot",
                                    //   backgroundColor: Colors.green,
                                    //   colorText: Colors.white,
                                    //   icon: Icon(Icons.check_circle, color: Colors.white),
                                    // );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(
                                    'Got it',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  barrierDismissible: true,
                );
              },
            ),

            const SizedBox(height: 20),
            CustomButton(
              text: "Close",
              isGradient: true,
              fontColor: AppColors.whiteColor,
              onTap: () {
                debugPrint("❌ Payment sheet closed");
                Get.back();
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      );
    },
  );
}
// Helper method for account items (add this to your class)
Widget _buildAccountItem(String title, String number, Color color, IconData icon) {
  return Container(
    padding: EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          blurRadius: 4,
          offset: Offset(0, 2),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 2),
              Text(
                number,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {

            copyToClipboard(number, title);

          },
          icon: Icon(Icons.copy, color: Colors.grey, size: 18),
        ),
      ],
    ),
  );
}
// Copy function
void copyToClipboard(String text, String accountName) async {
  await Clipboard.setData(ClipboardData(text: text));
  Get.snackbar(
    "Copied! ✅",
    "$accountName account number copied to clipboard",
    backgroundColor: Colors.green,
    colorText: Colors.white,
    duration: Duration(seconds: 2),
    snackPosition: SnackPosition.BOTTOM,
    margin: EdgeInsets.all(10),
  );
}
Widget buildIconWithText({
  required IconData icon,
  required String text,
  required Function() onTap,
}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.fillFieldColor,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: AppColors.greyColor.withValues(alpha: 0.10),
            offset: const Offset(0, 25),
            blurRadius: 9,
            spreadRadius: -10,
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: AppColors.primaryColor),
          const SizedBox(width: 8),
          AppText(
            text: text,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    ),
  );
}
