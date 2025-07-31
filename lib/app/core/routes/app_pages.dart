// lib/core/app_pages.dart

import 'package:assaan_rishta/app/views/profile/partner_preference/partner_preference_view.dart';
import 'package:assaan_rishta/app/views/splash/splash_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../views/account_type/account_type_view.dart';
import '../../views/bottom_nav/bottom_nav_view.dart';
import '../../views/chat/export.dart';
import '../../views/home/home_view.dart';
import '../../views/login/login_view.dart';
import '../../views/profile/export.dart';
import '../../views/signup/address_preferences_view.dart';
import '../../views/signup/basic_info_view.dart';
import '../../views/signup/signup_view.dart';
import '../../views/user_details/user_details_view.dart';
import '../../views/vendor/export.dart';
import '../bindings/app_bindings.dart';
import '../../widgets/export.dart';
import '../export.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 200),
    ),
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
      name: AppRoutes.PROFILE_EDIT_VIEW,
      page: () => const EditProfileView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.PARTNER_PREFERENCE_VIEW,
      page: () => const PartnerPreferenceView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.FAVORITES_VIEW,
      page: () => const FavoritesView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.BUY_CONNECTS_VIEW,
      page: () => const BuyConnectsView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.TRANSACTION_HISTORY_VIEW,
      page: () => const TransactionHistoryView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.CHANGE_PASSWORD_VIEW,
      page: () => const ChangePasswordView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.CONTACT_US_VIEW,
      page: () => const ContactUsView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.ABOUT_US_VIEW,
      page: () => const AboutUsView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.IN_APP_WEB_VIEW_SITE,
      page: () => const InAppWebViewSite(
        url: "https://asaanrishta.com/privacy",
        title: "Privacy Policy",
      ),
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
    GetPage(
      name: AppRoutes.VENDER_LISTING_VIEW,
      page: () => const VendorListingView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.VENDER_DETAILS_VIEW,
      page: () => const VendorDetailView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.VENDER_VIEW,
      page: () => const VendorView(),
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
        return const BottomNavView(index: 2);
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
        return const BottomNavView(index: 2);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 400),
    ),
  ];
}
