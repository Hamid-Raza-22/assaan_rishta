import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'export.dart';

void showPurchaseBottomSheet({
  required BuildContext context,
  required BuyConnectsController controller,
  required PackageModel package,
}) {
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
                Navigator.of(context).pop();
                controller.purchase(package: package);
              },
            ),
            buildIconWithText(
              icon: Icons.payment,
              text: 'Pay Fast',
              onTap: () {
                Navigator.of(context).pop();
                controller.payWithGoFastPay(
                  context: context,
                  amount: package.packagePrice,
                  packageId: package.productId,
                );
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Close",
              isGradient: true,
              fontColor: AppColors.whiteColor,
              onTap: () {
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
