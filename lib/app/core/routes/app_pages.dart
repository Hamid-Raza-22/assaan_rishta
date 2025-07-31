// lib/core/app_pages.dart

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../views/account_type/account_type_view.dart';
import '../../views/bottom_nav/bottom_nav_view.dart';
import '../../views/chat/export.dart';
import '../../views/home/home_view.dart';
import '../../views/login/login_view.dart';
import '../../views/new_chat/chat_list_screen.dart';
import '../../views/profile/export.dart';
import '../../views/signup/address_preferences_view.dart';
import '../../views/signup/basic_info_view.dart';
import '../../views/signup/signup_view.dart';
import '../../views/user_details/user_details_view.dart';
import '../bindings/app_bindings.dart';

import '../export.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.LOGIN;

  static final routes = [
    GetPage(
      name: AppRoutes.ACCOUNT_TYPE,
      page: () => const AccountTypeView(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.LOGIN,
      page: () => LoginView(),

      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupView(),

      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.BASIC_INFO,
      page: () => const BasicInfoView(),
      binding: AppBindings(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.OTHER_INFO,
      page: () => const AddressPreferencesView(),
      binding: AppBindings(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => const HomeView(),

      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.PROFILE,
      page: () => const ProfileView(),

      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.BOTTOM_NAV,
      page: () => const BottomNavView(),

      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),

    GetPage(
      name: AppRoutes.PROFILE_DETAIL_VIEW,
      page: () => const ProfileDetailsView(),

      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.USER_DETAILS_VIEW,
      page: () => const UserDetailsView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    // In your AppRoutes or wherever you define your GetPage routes
    GetPage(
      name: AppRoutes.CHATTING_VIEW,
      page: () {
        // Add null safety and type checking
        final args = Get.arguments;
        if (args is ChatUser) {
          return ChattingView(user: args);
        } else if (args is Map && args['chatUser'] is ChatUser) {
          return ChattingView(user: args['chatUser'] as ChatUser);
        }
        // Fallback to chat list if invalid arguments
        return const BottomNavView(index: 1);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
    GetPage(
      name: '/chatting_view/:userId',
      page: () {
        final userId = Get.parameters['userId'];
        final user = Get.arguments as ChatUser?;

        if (user != null && user.id == userId) {
          return ChattingView(user: user);
        }

        // Fallback if user data is missing
        debugPrint("dhfzfyiziiiiiiiiiiiiiiiiiiiii");
        return const BottomNavView(index: 1);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
