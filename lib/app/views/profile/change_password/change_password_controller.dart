import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/services/storage_services/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class ChangePasswordController extends GetxController {
  final useCases = Get.find<UserManagementUseCase>();

  final formKey = GlobalKey<FormState>();
  RxString oldPassword = "".obs;
  final passwordTEC = TextEditingController();
  final newPasswordTEC = TextEditingController();
  final confirmPasswordTEC = TextEditingController();

  RxBool showOldPassword = true.obs;
  RxBool showNewPassword = true.obs;
  RxBool showConfPassword = true.obs;
  RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    oldPassword.value = useCases.getUserPassword();
    update();
  }

  updatePassword({context}) async {
    isLoading.value = true;
    final response = await useCases.updatePassword(
      password: confirmPasswordTEC.text,
    );
    return response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) async {
        isLoading.value = false;
        AppUtils.successData(
          title: "Change Password",
          message: "Your password has been updated successfully. Please log in again for security purposes if required.",
        );
        final pref = await SharedPreferences.getInstance();
        pref.setString(StorageKeys.userPassword, confirmPasswordTEC.text);
        update();
        Navigator.of(context).pop();
      },
    );
  }

  @override
  void dispose() {
    passwordTEC.dispose();
    newPasswordTEC.dispose();
    confirmPasswordTEC.dispose();
    super.dispose();
  }
}
