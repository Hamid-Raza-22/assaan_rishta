// forgot_password_controller.dart - FIXED VERSION
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

  RxString countryCode="+92".obs; // Selected country code from dropdown
  RxString savedPhoneNumber="".obs; // Complete saved number with country code (e.g., "+923486255887")
  RxString savedCountryCode="".obs; // Extracted country code from saved number (e.g., "+92")
  RxString savedNumberWithoutCode="".obs; // Number without country code (e.g., "3486255887")
  RxString maskedNumber = "".obs;

  ///enter password
  RxBool showPassword=true.obs;
  final newPasswordTEC = TextEditingController();
  final confirmPasswordTEC = TextEditingController();


  @override
  void onInit() {
    super.onInit();
    _loadPhoneNumber();
  }

  Future<void> _loadPhoneNumber() async {
    final prefs = await SharedPreferences.getInstance();
    // Get the full number with country code from SharedPreferences
    String fullNumber = prefs.getString('userNumber') ?? '';

    debugPrint('📱 Saved phone number from SharedPreferences: "$fullNumber"');

    if (fullNumber.isEmpty) {
      return;
    }

    // First, clean the number - remove all spaces and special chars except + and digits
    String cleanedNumber = fullNumber.replaceAll(RegExp(r'[^\d+]'), '');
    debugPrint('🧹 Cleaned number: "$cleanedNumber"');

    // Check if number starts with + sign
    if (cleanedNumber.startsWith('+')) {
      // Number has + sign: e.g., "+923131489445"
      savedPhoneNumber.value = cleanedNumber;
      debugPrint('✅ Processing number WITH + sign');

      // Extract country code and number
      if (cleanedNumber.startsWith('+92')) {
        savedCountryCode.value = '+92';
        // FIXED: Remove "+92" which is 3 characters
        savedNumberWithoutCode.value = cleanedNumber.substring(3);
        debugPrint('🇵🇰 Pakistan +92 detected');
      } else if (cleanedNumber.startsWith('+1')) {
        savedCountryCode.value = '+1';
        savedNumberWithoutCode.value = cleanedNumber.substring(2);
        debugPrint('🇺🇸 US/Canada +1 detected');
      } else if (cleanedNumber.startsWith('+91')) {
        savedCountryCode.value = '+91';
        savedNumberWithoutCode.value = cleanedNumber.substring(3);
        debugPrint('🇮🇳 India +91 detected');
      } else if (cleanedNumber.startsWith('+44')) {
        savedCountryCode.value = '+44';
        savedNumberWithoutCode.value = cleanedNumber.substring(3);
        debugPrint('🇬🇧 UK +44 detected');
      } else if (cleanedNumber.startsWith('+971')) {
        savedCountryCode.value = '+971';
        savedNumberWithoutCode.value = cleanedNumber.substring(4);
        debugPrint('🇦🇪 UAE +971 detected');
      } else if (cleanedNumber.startsWith('+966')) {
        savedCountryCode.value = '+966';
        savedNumberWithoutCode.value = cleanedNumber.substring(4);
        debugPrint('🇸🇦 Saudi Arabia +966 detected');
      } else {
        // Try to extract country code dynamically
        RegExp countryCodeRegex = RegExp(r'^\+(\d{1,4})');
        Match? match = countryCodeRegex.firstMatch(cleanedNumber);
        if (match != null) {
          savedCountryCode.value = match.group(0)!; // e.g., "+92"
          savedNumberWithoutCode.value = cleanedNumber.substring(match.group(0)!.length);
          debugPrint('⚠️ Unknown country code detected: ${savedCountryCode.value}');
        } else {
          savedCountryCode.value = '+92';
          savedNumberWithoutCode.value = cleanedNumber.substring(1);
        }
      }
    } else {
      // Number WITHOUT + sign: e.g., "923131489445"
      debugPrint('⚠️ Processing number WITHOUT + sign');

      if (cleanedNumber.startsWith('92') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+92';
        savedNumberWithoutCode.value = cleanedNumber.substring(2); // Remove "92"
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇵🇰 Pakistan 92 detected (no +)');
      } else if (cleanedNumber.startsWith('1') && cleanedNumber.length == 11) {
        savedCountryCode.value = '+1';
        savedNumberWithoutCode.value = cleanedNumber.substring(1);
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇺🇸 US/Canada 1 detected (no +)');
      } else if (cleanedNumber.startsWith('91') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+91';
        savedNumberWithoutCode.value = cleanedNumber.substring(2);
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇮🇳 India 91 detected (no +)');
      } else if (cleanedNumber.startsWith('44') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+44';
        savedNumberWithoutCode.value = cleanedNumber.substring(2);
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇬🇧 UK 44 detected (no +)');
      } else if (cleanedNumber.startsWith('971') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+971';
        savedNumberWithoutCode.value = cleanedNumber.substring(3);
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇦🇪 UAE 971 detected (no +)');
      } else if (cleanedNumber.startsWith('966') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+966';
        savedNumberWithoutCode.value = cleanedNumber.substring(3);
        savedPhoneNumber.value = '+$cleanedNumber';
        debugPrint('🇸🇦 Saudi Arabia 966 detected (no +)');
      } else {
        // Can't detect country code
        savedNumberWithoutCode.value = cleanedNumber;
        savedPhoneNumber.value = cleanedNumber;
        savedCountryCode.value = '+92'; // Default fallback
        debugPrint('❌ Could not detect country code, using defaults');
      }
    }

    countryCode.value = savedCountryCode.value; // Set initial country code in dropdown

    debugPrint('✅ === EXTRACTION RESULT ===');
    debugPrint('Country Code: "${savedCountryCode.value}"');
    debugPrint('Number Without Code: "${savedNumberWithoutCode.value}"');
    debugPrint('Full Number for OTP: "${savedPhoneNumber.value}"');
    debugPrint('========================');

    // Create masked version for display
    if (savedNumberWithoutCode.value.length > 4) {
      String lastFour = savedNumberWithoutCode.value.substring(savedNumberWithoutCode.value.length - 4);
      maskedNumber.value = savedNumberWithoutCode.value.substring(0, savedNumberWithoutCode.value.length - 4)
          .replaceAll(RegExp(r'.'), '*') + lastFour;
    } else {
      maskedNumber.value = savedNumberWithoutCode.value;
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

  // Validate if entered phone and country code match saved phone
  bool validatePhoneNumber() {
    String enteredNumber = phoneTEC.text.trim();

    // Remove any spaces or special characters from entered number
    enteredNumber = enteredNumber.replaceAll(RegExp(r'[^0-9]'), '');

    // Get selected country code from dropdown
    String selectedCountryCode = countryCode.value;

    // Compare with saved data (already cleaned in _loadPhoneNumber)
    String savedNumberClean = savedNumberWithoutCode.value.replaceAll(RegExp(r'[^0-9]'), '');
    String savedCodeClean = savedCountryCode.value;

    debugPrint('=== 🔍 VALIDATION DEBUG ===');
    debugPrint('Entered number: "$enteredNumber"');
    debugPrint('Selected country code: "$selectedCountryCode"');
    debugPrint('Saved number (without code): "$savedNumberClean"');
    debugPrint('Saved country code: "$savedCodeClean"');

    // Match both: country code AND phone number
    bool countryCodeMatches = selectedCountryCode == savedCodeClean;
    bool phoneNumberMatches = enteredNumber == savedNumberClean;

    debugPrint('Country code matches: $countryCodeMatches');
    debugPrint('Phone number matches: $phoneNumberMatches');
    debugPrint('========================');

    return countryCodeMatches && phoneNumberMatches;
  }

  void startPhoneVerification({required BuildContext context}) async {
    // Get the phone number directly from the controller
    final String phoneNumber = phoneTEC.text.trim();

    // Check if phone number is empty
    if (phoneNumber.isEmpty) {
      AppUtils.failedData(title: 'Error', message: 'Please enter a phone number');
      return;
    }

    // Validate if entered number and country code match saved data
    if (!validatePhoneNumber()) {
      AppUtils.failedData(
          title: 'Invalid Number',
          message: 'The entered phone number or country code does not match your registered number'
      );
      return;
    }

    // If validation passes, use the saved phone number from SharedPreferences for OTP
    final String fullPhone = savedPhoneNumber.value; // Use the complete saved number

    debugPrint('📤 Sending OTP to saved number: $fullPhone');

    isSendingCode.value = true;
    update();

    try {
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verification completed');
        },
        verificationFailed: (auth.FirebaseAuthException e) {
          debugPrint('❌ Verification failed: ${e.message}');

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
          debugPrint('✅ Code sent successfully. Verification ID: $verificationId');
          _verificationId = verificationId;

          otpTEC.clear();
          debugPrint('Sending OTP to: ${Get.arguments}');

          Get.toNamed(AppRoutes.OTP_VIEW, arguments: Get.arguments);
          AppUtils.successData(title: 'Success', message: 'OTP sent to ${savedCountryCode.value} ${maskedNumber.value}');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('⏰ Auto retrieval timeout');
        },
      );
    } catch (e) {
      AppUtils.failedData(title: 'Error', message: e.toString());
      debugPrint('❌ Error in phone verification: $e');
    } finally {
      isSendingCode.value = false;
      update();
    }
  }

  void resendCode() {
    otpTEC.clear();

    // Validate phone number again before resending
    if (phoneTEC.text.trim().isNotEmpty && validatePhoneNumber()) {
      startPhoneVerification(context: Get.context!);
    } else {
      AppUtils.failedData(title: 'Error', message: 'Please enter your registered phone number with correct country code');
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

      final userCredential = await auth.FirebaseAuth.instance.signInWithCredential(credential);

      debugPrint('✅ OTP verified successfully');
      debugPrint('User email: ${Get.arguments}');

      newPasswordTEC.clear();
      confirmPasswordTEC.clear();

      Get.toNamed(AppRoutes.ENTER_PASSWORD_VIEW, arguments: Get.arguments);

      await auth.FirebaseAuth.instance.signOut();

    } on auth.FirebaseAuthException catch (e) {
      debugPrint('❌ OTP verification failed: ${e.code} - ${e.message}');

      String errorMessage = 'Invalid OTP';
      if (e.code == 'invalid-verification-code') {
        errorMessage = 'Invalid OTP code. Please check and try again';
      } else if (e.code == 'session-expired') {
        errorMessage = 'OTP expired. Please request a new one';
      }

      AppUtils.failedData(title: 'Invalid Code', message: errorMessage);
    } catch (e) {
      AppUtils.failedData(title: 'Error', message: e.toString());
      debugPrint('❌ Error in OTP verification: $e');
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
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String email = prefs.getString('Email') ?? '';

      debugPrint('🔐 Updating password with email: $email');

      final response = await useCases.resetPassword(password: confirmPasswordTEC.text, email: email);

      Get.back();

      response.fold(
            (error) {
          AppUtils.failedData(title: 'Failed', message: 'Could not update password');
        },
            (success) async {
          AppUtils.successData(title: 'Success', message: 'Password updated successfully');

          final pref = await SharedPreferences.getInstance();
          await pref.setString(StorageKeys.userPassword, confirmPasswordTEC.text);

          phoneTEC.clear();
          otpTEC.clear();
          newPasswordTEC.clear();
          confirmPasswordTEC.clear();
          _verificationId = null;

          Get.toNamed(AppRoutes.LOGIN);
        },
      );
    } catch (e) {
      Get.back();
      AppUtils.failedData(title: 'Error', message: 'Failed to update password');
      debugPrint('❌ Error updating password: $e');
    }
  }
}