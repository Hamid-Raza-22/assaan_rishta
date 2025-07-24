
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../utils/exports.dart';
import '../../widgets/custom_button.dart';

void showBlockUnblockBottomSheet({
  required BuildContext context,
  required String userId,
  required bool isBlocked, // Current block status of the user
  required Function onBlock,
  required Function onUnblock,
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
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              isBlocked ? "Unblock this user?" : "Block this user?",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: isBlocked ? "Unblock" : "Block",
              backgroundColor: isBlocked ? Colors.green : Colors.red,
              margin: const EdgeInsets.symmetric(horizontal: 30),
              fontWeight: FontWeight.w600,
              fontColor: AppColors.whiteColor,
              onTap: () {
                if (isBlocked) {
                  onUnblock(); // Call the unblock function
                  Get.back(); // Close the bottom sheet
                } else {
                  onBlock(); // Call the block function
                  Get.back(); // Close the bottom sheet
                }
              },
            ),
            const SizedBox(height: 20),
            CustomButton(
              text: "Cancel",
              isGradient: true,
              margin: const EdgeInsets.symmetric(horizontal: 30),
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
