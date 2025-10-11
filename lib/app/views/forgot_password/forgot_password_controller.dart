// forgot_password_controller.dart - IMPROVED VERSION
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'as auth;
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/export.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/exports.dart';
import '../../domain/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/storage_services/export.dart';

class ForgotPasswordController extends BaseController{
  final useCases = Get.find<UserManagementUseCase>();

  final formKey = GlobalKey<FormState>();
  final enterPasswordFormKey = GlobalKey<FormState>();
  final phoneTEC=TextEditingController();
  final otpTEC=TextEditingController();

  RxString countryCode="+92".obs;
RxString number="".obs;
  RxString maskedNumber = "".obs;
  ///enter password
  RxBool showPassword=true.obs;
  final newPasswordTEC = TextEditingController();

  final confirmPasswordTEC = TextEditingController();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    // Assuming you save the number with a specific key, e.g., 'saved_phone_number'
    String userNumber = prefs.getString('userNumber') ?? '';
    number.value = userNumber;

    if (userNumber.length > 4) {
      String lastThree = userNumber.substring(userNumber.length - 4);
      maskedNumber.value = userNumber.substring(0, userNumber.length - 4).replaceAll(RegExp(r'.'), '*') + lastThree;
    } else {
      maskedNumber.value = userNumber;
    }
  }


  @override
  void dispose() {
    phoneTEC.dispose();
    otpTEC.dispose();
    newPasswordTEC.dispose();
    confirmPasswordTEC.dispose();
    super.dispose();
  }

  // OTP
  final otpFormKey = GlobalKey<FormState>();
  final RxBool isSendingCode = false.obs;
  final RxBool isVerifyingOtp = false.obs;
  String? _verificationId;

  void startPhoneVerification({required BuildContext context}) async {
    // Get the phone number directly from the controller
    final String phoneNumber = phoneTEC.text.trim();

    // Check if phone number is empty
    if (phoneNumber.isEmpty) {
      AppUtils.failedData(title: 'Error', message: 'Please enter a phone number');
      return;
    }

    // Construct full phone number with country code
    final String fullPhone = '${countryCode.value}$phoneNumber';

    debugPrint('Sending OTP to: $fullPhone'); // Debug print

    isSendingCode.value = true;
    update();

    try {
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60), // Add timeout
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          // Auto-retrieval on Android
          debugPrint('Auto verification completed');
        },
        verificationFailed: (auth.FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');

          // Provide more specific error messages
          String errorMessage = 'Verification failed';
          if (e.code == 'invalid-phone-number') {
            errorMessage = 'Invalid phone number format';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later';
          } else if (e.message != null) {
            errorMessage = e.message!;
          }

          AppUtils.failedData(title: 'OTP Failed', message: errorMessage);
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Code sent successfully. Verification ID: $verificationId');
          _verificationId = verificationId;

          // Clear OTP field before navigating
          otpTEC.clear();
      debugPrint('Sending OTP to: ${Get.arguments}');

          Get.toNamed(AppRoutes.OTP_VIEW, arguments: Get.arguments);
          AppUtils.successData(title: 'Success', message: 'OTP sent to $fullPhone');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('Auto retrieval timeout');
        },
      );
    } catch (e) {
      AppUtils.failedData(title: 'Error', message: e.toString());
      debugPrint('Error in phone verification: $e');
    } finally {
      isSendingCode.value = false;
      update();
    }
  }

  void resendCode() {
    // Clear OTP field
    otpTEC.clear();

    // Use the existing phone number
    if (phoneTEC.text.trim().isNotEmpty) {
      startPhoneVerification(context: Get.context!);
    } else {
      AppUtils.failedData(title: 'Error', message: 'Phone number is required');
    }
  }

  Future<void> verifyOtpAndProceed({required BuildContext context}) async {
    if (_verificationId == null) {
      AppUtils.failedData(title: 'Error', message: 'No verification in progress. Please request a new OTP');
      return;
    }

    if (otpTEC.text.trim().isEmpty) {
      AppUtils.failedData(title: 'Error', message: 'Please enter the OTP');
      return;
    }

    isVerifyingOtp.value = true;
    update();

    try {
      final credential = auth.PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otpTEC.text.trim(),
      );

      // Verify the OTP
      final userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint('OTP verified successfully');
      debugPrint('User emailllllllllllllllllllll: ${Get.arguments}');

      // Clear password fields before navigating
      newPasswordTEC.clear();
      confirmPasswordTEC.clear();

      Get.toNamed(AppRoutes.ENTER_PASSWORD_VIEW, arguments: Get.arguments);

      // Sign out immediately after verification (since this is just for password reset)
      await auth.FirebaseAuth.instance.signOut();

    } on auth.FirebaseAuthException catch (e) {
      debugPrint('OTP verification failed: ${e.code} - ${e.message}');

      String errorMessage = 'Invalid OTP';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP code. Please check and try again';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP expired. Please request a new one';
      }

      AppUtils.failedData(title: 'Invalid Code', message: errorMessage);
    } catch (e) {
      AppUtils.failedData(title: 'Error', message: e.toString());
      debugPrint('Error in OTP verification: $e');
    } finally {
      isVerifyingOtp.value = false;
      update();
    }
  }

  Future<void> updatePasswordAfterOtp({required BuildContext context}) async {
    if (newPasswordTEC.text.isEmpty || confirmPasswordTEC.text.isEmpty) {
      AppUtils.failedData(title: 'Error', message: 'Please fill both password fields');
      return;
    }

    if (newPasswordTEC.text.length < 6) {
      AppUtils.failedData(title: 'Error', message: 'Password must be at least 6 characters');
      return;
    }

    if (newPasswordTEC.text != confirmPasswordTEC.text) {
      AppUtils.failedData(title: 'Mismatch', message: 'Passwords do not match');
      return;
    }

    AppUtils.onLoading(context);

    try {
      debugPrint('Updating password with emaillllllllllllllllllllllllllll: ${Get.arguments}');

      final response = await useCases.resetPassword(password: confirmPasswordTEC.text, email: Get.arguments);

      Get.back(); // Close loading

      response.fold(
            (error) {
          AppUtils.failedData(title: 'Failed', message: 'Could not update password');
        },
            (success) async {
          AppUtils.successData(title: 'Success', message: 'Password updated successfully');

          // Save password locally
          final pref = await SharedPreferences.getInstance();
          await pref.setString(StorageKeys.userPassword, confirmPasswordTEC.text);

          // Clear all fields
          phoneTEC.clear();
          otpTEC.clear();
          newPasswordTEC.clear();
          confirmPasswordTEC.clear();
          _verificationId = null;

          // Navigate to login
          Get.offAllNamed(AppRoutes.LOGIN);
        },
      );
    } catch (e) {
      Get.back(); // Close loading
      AppUtils.failedData(title: 'Error', message: 'Failed to update password');
      debugPrint('Error updating password: $e');
    }
  }
}