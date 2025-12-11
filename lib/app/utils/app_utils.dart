// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'exports.dart';

class AppUtils {
  static onLoading(context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (BuildContext context) {
        return const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        );
      },
    );
  }

  static dismissLoader(context) {
    Navigator.of(context).pop();
  }

  static successData({String? title, String? message}) {
    Get.snackbar(
      title!,
      message!,
      colorText: AppColors.whiteColor,
      backgroundColor: AppColors.greenColor.withValues(alpha: 0.9),
    );
  }

  static failedData({String? title, String? message}) {
    Get.snackbar(
      title!,
      message!,
      colorText: AppColors.whiteColor,
      backgroundColor: Colors.red,
      snackPosition: SnackPosition.BOTTOM,
    );
  }



  // static String getCustomErrorMessage(FirebaseAuthException e) {
  //   switch (e.code) {
  //     case 'invalid-verification-code':
  //       return 'The SMS verification code used is invalid. Please enter valid code.';
  //     case 'session-expired':
  //       return 'The SMS code has expired. Please request a new code.';
  //     case 'quota-exceeded':
  //       return 'The SMS quota for this project has been exceeded. Please try again later.';
  //     case 'network-request-failed':
  //       return 'A network error occurred. Please check your internet connection and try again.';
  //     case 'too-many-requests':
  //       return 'Too many requests have been made to the server. Please wait and try again later.';
  //     case 'invalid-phone-number':
  //       return 'The provided phone number is not valid. Please check and try again.';
  //     case 'captcha-check-failed':
  //       return 'The reCAPTCHA verification failed. Please try again.';
  //     case 'user-disabled':
  //       return 'The user associated with this phone number has been disabled. Please contact support.';
  //     case 'operation-not-allowed':
  //       return 'Phone sign-in is not enabled for this project. Please contact support.';
  //     default:
  //       return 'An unknown error occurred. Please try again.';
  //   }
  // }

  /// Sanitize image URL - remove staging prefix from URLs stored in database
  /// Converts https://staging.thsolutionz.com/... to https://thsolutionz.com/...
  static String sanitizeImageUrl(String? url) {
    if (url == null || url.isEmpty) return '';

    // Replace staging URL with production URL
    return url.replaceFirst(
      'https://staging.thsolutionz.com',
      'https://thsolutionz.com',
    );
  }
}
