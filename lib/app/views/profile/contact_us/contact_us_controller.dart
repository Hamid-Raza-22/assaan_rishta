import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../domain/export.dart';
import '../../../utils/exports.dart';
import '../../../core/services/storage_services/export.dart';

class ContactUsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final formKey = GlobalKey<FormState>();

  // TextEditingControllers to get the form data
  final nameTEC = TextEditingController();
  final emailTEC = TextEditingController();
  final subjectTEC = TextEditingController();
  final messageTEC = TextEditingController();

  RxBool isLoading=false.obs;
  // support | info selection
  // final selectedType = RxnString();
  //
  // bool get isFormEnabled => selectedType.value != null;
  //
  // void selectType(String value){
  //   selectedType.value = value;
  //   update();
  // }

  @override
  void onInit() {
    super.onInit();
    _prefillUserDetails();
  }

  Future<void> _prefillUserDetails() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedName = prefs.getString(StorageKeys.userName) ?? '';
      final savedEmail = prefs.getString(StorageKeys.userEmail) ?? '';

      if (savedName.isNotEmpty) {
        nameTEC.text = savedName;
      }
      if (savedEmail.isNotEmpty) {
        emailTEC.text = savedEmail;
      }
      update();
    } catch (_) {}
  }

  Future<void> _sendEmailViaLauncher({required String to, required String subject, required String body}) async {
    final uri = Uri(
      scheme: 'mailto',
      path: to,
      queryParameters: {
        'subject': subject,
        'body': body,
      },
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> openWhatsApp({required String phone, String? message}) async {
    String cleanNumber = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final text = Uri.encodeComponent(message ?? 'Assalam-o-Alaikum, I need assistance regarding Asaan Rishta.');
    final whatsappUrl = Uri.parse("whatsapp://send?phone=$cleanNumber&text=$text");
    final whatsappWebUrl = Uri.parse("https://wa.me/$cleanNumber?text=$text");

    if (await canLaunchUrl(whatsappUrl)) {
      await launchUrl(whatsappUrl);
      return;
    }
    if (await canLaunchUrl(whatsappWebUrl)) {
      await launchUrl(whatsappWebUrl, mode: LaunchMode.externalApplication);
      return;
    }
    await Clipboard.setData(ClipboardData(text: phone));
    Get.snackbar(
      "WhatsApp not found",
      "Number copied: $phone",
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
      snackPosition: SnackPosition.TOP,
    );
  }

  contactUsForSupport() async {
      isLoading.value=true;
      try{
        final to = 'support@asaanrishta.com' ;
        final subject = subjectTEC.text.trim();
        final body = '';

        await _sendEmailViaLauncher(to: to, subject: subject, body: body);
        isLoading.value=false;

        update();
      } catch(e){
        isLoading.value=false;
        AppUtils.failedData(title: 'Error', message: 'Unable to open mail app.');
      }
    }

  contactUsForInfo() async {

    if (formKey.currentState!.validate()) {
      isLoading.value=true;
      try{
        final to = 'info@asaanrishta.com' ;
        final subject = subjectTEC.text.trim();
        final body = '';

        await _sendEmailViaLauncher(to: to, subject: subject, body: body);
        isLoading.value=false;

        update();
      } catch(e){
        isLoading.value=false;
        AppUtils.failedData(title: 'Error', message: 'Unable to open mail app.');
      }
    }
  }

  @override
  void dispose() {
    nameTEC.dispose();
    emailTEC.dispose();
    subjectTEC.dispose();
    messageTEC.dispose();
    super.dispose();
  }
}
