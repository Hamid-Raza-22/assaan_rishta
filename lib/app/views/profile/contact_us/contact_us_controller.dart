import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class ContactUsController extends GetxController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final formKey = GlobalKey<FormState>();

  // TextEditingControllers to get the form data
  final nameTEC = TextEditingController();
  final emailTEC = TextEditingController();
  final subjectTEC = TextEditingController();
  final messageTEC = TextEditingController();

  RxBool isLoading=false.obs;

  contactUs() async {
    if (formKey.currentState!.validate()) {
      isLoading.value=true;

      final response = await systemConfigUseCases.contactUs(
        name: nameTEC.text,
        email: emailTEC.text,
        subject: subjectTEC.text,
        message: messageTEC.text,
      );
      return response.fold(
        (error) {
          isLoading.value=false;
          AppUtils.failedData(
            title: "Error",
            message: error.description,
          );
        },
        (success) {
          isLoading.value=false;
          AppUtils.successData(
            title: "Connect Us",
            message: success,
          );
          update();
        },
      );
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
