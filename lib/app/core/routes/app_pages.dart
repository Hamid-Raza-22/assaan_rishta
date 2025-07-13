// lib/core/app_pages.dart
import 'package:assaan_rishta/app/core/bindings/account_type_binding.dart';
import 'package:get/get.dart';

import '../../views/account_type/account_type_view.dart';
import '../../views/login/login_view.dart';
import '../../views/signup/signup_view.dart';
import '../bindings/login_bindings.dart';
import '../bindings/signup_bindings.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(
      name: AppRoutes.ACCOUNT_TYPE,
      page: () => const AccountTypeView(),
      binding: AccountTypeBinding(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 300),

    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () =>  LoginView(),
      binding: LoginBinding(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 400),

    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () =>  SignupView(),
      binding: SignupBinding(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 1000),


    ),
  ];
}
