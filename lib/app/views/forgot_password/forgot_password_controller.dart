import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/base/export.dart';

class ForgotPasswordController extends BaseController{

  final formKey = GlobalKey<FormState>();
  final enterPasswordFormKey = GlobalKey<FormState>();
  final phoneTEC=TextEditingController();

  RxString countryCode="+92".obs;

  ///enter password
  RxBool showPassword=true.obs;
  final newPasswordTEC = TextEditingController();
  final confirmPasswordTEC = TextEditingController();


  @override
  void onInit() {
    // TODO: implement onInit
    super.onInit();
  }


  @override
  void dispose() {
    phoneTEC.dispose();
    super.dispose();
  }

}