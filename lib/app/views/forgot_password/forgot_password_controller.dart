// forgot_password_controller.dart - WITH LAST 5 DIGITS FALLBACK
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart' as cloud;
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart'as auth;
import 'package:url_launcher/url_launcher.dart';

import '../../core/base/export.dart';
import '../../core/routes/app_routes.dart';
import '../../core/services/secure_storage_service.dart';
import '../../utils/exports.dart';
import '../../domain/export.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/services/storage_services/export.dart';
import '../../viewmodels/auth_service.dart';

class ForgotPasswordController extends BaseController{
  final useCases = Get.find<UserManagementUseCase>();
  final RxBool isPasting = false.obs;
  final formKey = GlobalKey<FormState>();
  final enterPasswordFormKey = GlobalKey<FormState>();
  final phoneTEC=TextEditingController();
  final otpTEC=TextEditingController();
  final authService = AuthService.instance;
  RxString countryCode="+92".obs;
  RxString savedPhoneNumber="".obs;
  RxString savedCountryCode="".obs;
  RxString savedNumberWithoutCode="".obs;
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

  Future<void> pasteAndVerifyOtp({required BuildContext context}) async {
    isPasting.value = true;
    update();

    try {
      ClipboardData? data = await Clipboard.getData(Clipboard.kTextPlain);

      if (data == null || data.text == null || data.text!.isEmpty) {
        AppUtils.failedData(
          title: 'Clipboard Empty',
          message: 'No OTP found in clipboard',
        );
        isPasting.value = false;
        update();
        return;
      }

      String pastedText = data.text!.replaceAll(RegExp(r'[^0-9]'), '');

      debugPrint('📋 Pasted text: ${data.text}');
      debugPrint('🔢 Extracted OTP: $pastedText');

      if (pastedText.length != 6) {
        AppUtils.failedData(
          title: 'Invalid OTP',
          message: 'Please copy a valid 6-digit OTP',
        );
        isPasting.value = false;
        update();
        return;
      }

      otpTEC.text = pastedText;

      await Future.delayed(const Duration(milliseconds: 300));

      isPasting.value = false;
      update();

      if (otpFormKey.currentState!.validate()) {
        await verifyOtpAndProceed(context: context);
      }

    } catch (e) {
      debugPrint('❌ Error pasting OTP: $e');
      AppUtils.failedData(
        title: 'Error',
        message: 'Failed to paste OTP',
      );
      isPasting.value = false;
      update();
    }
  }

  Future<void> _loadPhoneNumber() async {
    // Use SecureStorage instead of SharedPreferences
    final secureStorage = SecureStorageService();
    String fullNumber = await secureStorage.getUserPhone() ?? '';

    debugPrint('📱 Saved phone number from SecureStorage: "$fullNumber"');

    if (fullNumber.isEmpty) {
      return;
    }

    String cleanedNumber = fullNumber.replaceAll(RegExp(r'[^\d+]'), '');
    debugPrint('🧹 Cleaned number: "$cleanedNumber"');

    if (cleanedNumber.startsWith('+')) {
      savedPhoneNumber.value = cleanedNumber;
      debugPrint('✅ Processing number WITH + sign');

      if (cleanedNumber.startsWith('+92')) {
        savedCountryCode.value = '+92';
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
        RegExp countryCodeRegex = RegExp(r'^\+(\d{1,4})');
        Match? match = countryCodeRegex.firstMatch(cleanedNumber);
        if (match != null) {
          savedCountryCode.value = match.group(0)!;
          savedNumberWithoutCode.value = cleanedNumber.substring(match.group(0)!.length);
          debugPrint('⚠️ Unknown country code detected: ${savedCountryCode.value}');
        } else {
          savedCountryCode.value = '+92';
          savedNumberWithoutCode.value = cleanedNumber.substring(1);
        }
      }
    } else {
      debugPrint('⚠️ Processing number WITHOUT + sign');

      if (cleanedNumber.startsWith('92') && cleanedNumber.length >= 12) {
        savedCountryCode.value = '+92';
        savedNumberWithoutCode.value = cleanedNumber.substring(2);
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
      } else if (cleanedNumber.startsWith('0') && cleanedNumber.length == 11) {
        // ✅ Pakistani format: 03324521680 -> remove 0 and add +92
        savedCountryCode.value = '+92';
        savedNumberWithoutCode.value = cleanedNumber.substring(1); // Remove leading 0
        savedPhoneNumber.value = '+92${cleanedNumber.substring(1)}';
        debugPrint('🇵🇰 Pakistan local format detected (0XXX) - converted to international');
      } else {
        // Fallback: assume it's a local number, add +92
        savedCountryCode.value = '+92';
        if (cleanedNumber.startsWith('0')) {
          savedNumberWithoutCode.value = cleanedNumber.substring(1);
          savedPhoneNumber.value = '+92${cleanedNumber.substring(1)}';
        } else {
          savedNumberWithoutCode.value = cleanedNumber;
          savedPhoneNumber.value = '+92$cleanedNumber';
        }
        debugPrint('⚠️ Could not detect country code, assuming Pakistan +92');
      }
    }

    countryCode.value = savedCountryCode.value;

    debugPrint('✅ === EXTRACTION RESULT ===');
    debugPrint('Country Code: "${savedCountryCode.value}"');
    debugPrint('Number Without Code: "${savedNumberWithoutCode.value}"');
    debugPrint('Full Number for OTP: "${savedPhoneNumber.value}"');
    debugPrint('========================');

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

  final otpFormKey = GlobalKey<FormState>();
  final RxBool isSendingCode = false.obs;
  final RxBool isVerifyingOtp = false.obs;
  String? _verificationId;

  // ✅ UPDATED: Validate with fallback to last 5 digits
  bool validatePhoneNumber() {
    String enteredNumber = phoneTEC.text.trim();
    enteredNumber = enteredNumber.replaceAll(RegExp(r'[^0-9]'), '');

    String selectedCountryCode = countryCode.value;
    String savedNumberClean = savedNumberWithoutCode.value.replaceAll(RegExp(r'[^0-9]'), '');
    String savedCodeClean = savedCountryCode.value;

    debugPrint('=== 🔍 VALIDATION DEBUG ===');
    debugPrint('Entered number: "$enteredNumber"');
    debugPrint('Selected country code: "$selectedCountryCode"');
    debugPrint('Saved number (without code): "$savedNumberClean"');
    debugPrint('Saved country code: "$savedCodeClean"');

    // Primary validation: country code AND full phone number
    bool countryCodeMatches = selectedCountryCode == savedCodeClean;
    bool phoneNumberMatches = enteredNumber == savedNumberClean;

    debugPrint('Country code matches: $countryCodeMatches');
    debugPrint('Phone number matches: $phoneNumberMatches');

    if (countryCodeMatches && phoneNumberMatches) {
      debugPrint('✅ Full validation passed');
      debugPrint('========================');
      return true;
    }

    // ✅ FALLBACK: Check last 5 digits
    debugPrint('⚠️ Full validation failed, checking last 5 digits...');

    if (enteredNumber.length >= 5 && savedNumberClean.length >= 5) {
      String enteredLast5 = enteredNumber.substring(enteredNumber.length - 5);
      String savedLast5 = savedNumberClean.substring(savedNumberClean.length - 5);

      debugPrint('Entered last 5 digits: "$enteredLast5"');
      debugPrint('Saved last 5 digits: "$savedLast5"');

      bool last5Match = enteredLast5 == savedLast5;
      debugPrint('Last 5 digits match: $last5Match');

      if (last5Match) {
        debugPrint('✅ Fallback validation passed (last 5 digits matched)');
        debugPrint('========================');
        return true;
      }
    }

    debugPrint('❌ All validations failed');
    debugPrint('========================');
    return false;
  }

  void startPhoneVerification({required BuildContext context}) async {
    final String phoneNumber = phoneTEC.text.trim();

    if (phoneNumber.isEmpty) {
      AppUtils.failedData(title: 'Error', message: 'Please enter a phone number');
      return;
    }

    if (!validatePhoneNumber()) {
      AppUtils.failedData(
          title: 'Invalid Number',
          message: 'The entered phone number does not match your registered number'
      );
      return;
    }

    final String fullPhone = savedPhoneNumber.value;

    // ✅ YE EXACT NUMBER FIREBASE KO JAYEGA
    debugPrint('🔥🔥🔥 === FIREBASE KO JANE WALA NUMBER === 🔥🔥🔥');
    debugPrint('📤 Full Phone Number (E.164 Format): "$fullPhone"');
    debugPrint('🌍 Country Code: "${savedCountryCode.value}"');
    debugPrint('📱 Number (without country code): "${savedNumberWithoutCode.value}"');
    debugPrint('💡 User ne enter kiya: "${phoneTEC.text}"');
    debugPrint('💡 Selected country code from dropdown: "${countryCode.value}"');
    debugPrint('🔥🔥🔥 ================================== 🔥🔥🔥');

    isSendingCode.value = true;
    update();

    try {
      await auth.FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: fullPhone, // ✅ YE LINE - EXACT YE NUMBER FIREBASE KO JATA HAI
        timeout: const Duration(seconds: 60),
        verificationCompleted: (auth.PhoneAuthCredential credential) async {
          debugPrint('✅ Auto verification completed');
          isSendingCode.value = false;
          update();
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

          isSendingCode.value = false;
          update();
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('✅ Code sent successfully. Verification ID: $verificationId');
          _verificationId = verificationId;

          otpTEC.clear();

          isSendingCode.value = false;
          update();

          Get.toNamed(AppRoutes.OTP_VIEW, arguments: Get.arguments);
          AppUtils.successData(
              title: 'Success',
              message: 'OTP sent to ${savedCountryCode.value} ${maskedNumber.value}'
          );
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
          debugPrint('⏰ Auto retrieval timeout');
          isSendingCode.value = false;
          update();
        },
      );
    } catch (e) {
      AppUtils.failedData(title: 'Error', message: e.toString());
      debugPrint('❌ Error in phone verification: $e');

      isSendingCode.value = false;
      update();
    }
  }

  void resendCode() {
    otpTEC.clear();

    if (phoneTEC.text.trim().isNotEmpty && validatePhoneNumber()) {
      startPhoneVerification(context: Get.context!);
    } else {
      AppUtils.failedData(
          title: 'Error',
          message: 'Please enter your registered phone number'
      );
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
      // Use SecureStorage for email
      final secureStorage = SecureStorageService();
      String email = await secureStorage.getUserEmail() ?? '';

      debugPrint('🔐 Updating password with email: $email');

      final response = await useCases.resetPassword(password: confirmPasswordTEC.text, email: email);

      Get.back();

      response.fold(
            (error) {
          AppUtils.failedData(title: 'Failed', message: 'Could not update password');
        },
            (success) async {
          AppUtils.successData(title: 'Success', message: 'Password updated successfully');

          // Save password to secure storage
          await secureStorage.saveUserPassword(confirmPasswordTEC.text);

          // phoneTEC.clear();
          // otpTEC.clear();
          // newPasswordTEC.clear();
          // confirmPasswordTEC.clear();
          // _verificationId = null;
          await authService.logout(context);
          // Clear password reset screens but preserve Account Type in navigation stack
          // Get.offNamedUntil(
          //   AppRoutes.LOGIN,
          //   (route) => route.settings.name == AppRoutes.ACCOUNT_TYPE || route.isFirst,
          // );
        },
      );
    } catch (e) {
      Get.back();
      AppUtils.failedData(title: 'Error', message: 'Failed to update password');
      debugPrint('❌ Error updating password: $e');
    }
  }
}