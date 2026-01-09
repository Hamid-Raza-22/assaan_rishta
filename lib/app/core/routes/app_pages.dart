// lib/core/app_pages.dart

import 'package:assaan_rishta/app/views/profile/partner_preference/partner_preference_view.dart';
import 'package:assaan_rishta/app/views/splash/splash_view.dart';
import 'package:assaan_rishta/app/views/on_boarding_screens/onboarding_screen.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../views/account_type/account_type_view.dart';
import '../../views/bottom_nav/bottom_nav_view.dart';
import '../../views/chat/chatting_view.dart';
import '../../views/chat/export.dart';
import '../../views/dashboard/dashboard_view.dart';
import '../../views/dashboard/matrimonial_profiles_view.dart';
import '../../views/forgot_password/export.dart';
import '../../views/home/home_view.dart';
import '../../views/login/login_view.dart';
import '../../views/profile/connects_history/connects_history_view.dart';
import '../../views/profile/export.dart';
import '../../views/profile/user_guide/user_guide.dart';
import '../../views/signup/address_preferences_view.dart';
import '../../views/signup/basic_info_view.dart';
import '../../views/signup/matrimonial_signup_view.dart';
import '../../views/signup/signup_view.dart';
import '../../views/user_details/user_details_view.dart';
import '../../views/vendor/export.dart';
import '../bindings/app_bindings.dart';
import '../bindings/user_details_binding.dart';
import '../bindings/vendor_detail_binding.dart';
import '../../widgets/export.dart';
import '../export.dart';
import 'app_routes.dart';

class AppPages {
  static const INITIAL = AppRoutes.SPLASH;

  static final routes = [
    GetPage(
      name: AppRoutes.ONBOARDING,
      page: () => const OnboardingView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => const SplashView(),
      transition: Transition.leftToRight,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.ACCOUNT_TYPE,
      page: () =>  AccountTypeView(),
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
      name: AppRoutes.FORGOT_PASSWORD_VIEW,
      page: () => ForgotPasswordView(),
      transition: Transition.upToDown,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.OTP_VIEW,
      page: () => OtpView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.ENTER_PASSWORD_VIEW,
      page: () => EnterPasswordView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 300),
    ),
    GetPage(
      name: AppRoutes.SIGNUP,
      page: () => SignupView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.BASIC_INFO,
      page: () => const BasicInfoView(),
      binding: AppBindings(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.OTHER_INFO,
      page: () => const AddressPreferencesView(),
      binding: AppBindings(),
      transition: Transition.rightToLeft,
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
      name: AppRoutes.DASHBOARD,
      page: () => const DashboardView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.MATRIMONIAL_PROFILES,
      page: () => const MatrimonialProfilesView(),
      transition: Transition.rightToLeft,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.PROFILE_EDIT_VIEW,
      page: () => const EditProfileView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.VENDOR_EDIT_PROFILE_VIEW,
      page: () => const VendorEditProfileView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.MATRIMONIAL_SIGNUP,
      page: () => MatrimonialSignupView(),
      transition: Transition.rightToLeft,
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
      name: AppRoutes.CONNECTS_HISTORY_VIEW,
      page: () => const ConnectsHistoryView(),
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
      name: AppRoutes.USER_GUIDE_VIEW,
      page: () => const UserGuideScreen(),
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
      name: AppRoutes.IN_APP_WEB_VIEW_SITE_TERMS_AND_CONDITIONS,
      page: () => const InAppWebViewSite(
        url: "https://asaanrishta.com/terms",
        title: "Terms and Conditions",
      ),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),

    // GetPage(
    //   name: AppRoutes.ACCOUNT_DEACTIVATED,
    //   page: () => const AccountDeactivatedScreen(),
    //   transition: Transition.fade,
    //   transitionDuration: Duration(milliseconds: 300),
    // ),
    GetPage(
      name: AppRoutes.BOTTOM_NAV,
      page: () => const BottomNavView(),
      transition: Transition.circularReveal,
      transitionDuration: Duration(milliseconds: 200),
    ),
    GetPage(
      name: AppRoutes.BOTTOM_NAV2,
      page: () {
        // Agar argument me index diya gaya ho to use karo, warna default 0
        final index = Get.arguments is int ? Get.arguments as int : 0;
        return BottomNavView(index: index);
      },
      transition: Transition.circularReveal,
      transitionDuration: const Duration(milliseconds: 200),
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
      binding: UserDetailsBinding(),
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
      binding: VendorDetailBinding(),
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
        final args = Get.arguments;

        // Handle different argument types
        if (args is ChatUser) {
          return ChattingView(user: args);
        } else if (args is Map<String, dynamic>) {
          // Handle map arguments (from notifications or admin profile context)
          final chatUser = args['chatUser'] as ChatUser?;
          final isBlocked = args['isBlocked'] as bool?;
          final isBlockedByOther = args['isBlockedByOther'] as bool?;
          final isDeleted = args['isDeleted'] as bool?;
          // Admin profile context for inline system message
          final isAdminManagedProfile = args['isAdminManagedProfile'] as bool? ?? false;
          final originalProfileId = args['originalProfileId'] as int?;
          final originalProfileName = args['originalProfileName'] as String?;
          final originalProfileImage = args['originalProfileImage'] as String?;
          // Flag for Admin viewing their own created profile (input should be disabled)
          final isAdminViewingOwnProfile = args['isAdminViewingOwnProfile'] as bool? ?? false;

          if (chatUser != null) {
            return ChattingView(
              key: ValueKey(chatUser.id),
              user: chatUser,
              isBlocked: isBlocked,
              isBlockedByOther: isBlockedByOther,
              isDeleted: isDeleted,
              isAdminManagedProfile: isAdminManagedProfile,
              originalProfileId: originalProfileId,
              originalProfileName: originalProfileName,
              originalProfileImage: originalProfileImage,
              isAdminViewingOwnProfile: isAdminViewingOwnProfile,
            );
          }
        }

        // Fallback to chat list
        debugPrint('⚠️ Invalid chat navigation arguments');
        return const BottomNavView(index: 2);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
// Dynamic route with user ID
    GetPage(
      name: '/chatting_view/:userId',
      page: () {
        final userId = Get.parameters['userId'];
        final args = Get.arguments;

        if (args is ChatUser && args.id == userId) {
          return ChattingView(user: args);
        } else if (args is Map<String, dynamic>) {
          final chatUser = args['chatUser'] as ChatUser?;
          if (chatUser != null && chatUser.id == userId) {
            return ChattingView(
              key: ValueKey(chatUser.id),
              user: chatUser,
              isBlocked: args['isBlocked'] as bool?,
              isBlockedByOther: args['isBlockedByOther'] as bool?,
              isDeleted: args['isDeleted'] as bool?,
            );
          }
        }

        debugPrint('⚠️ User ID mismatch or missing data for chat: $userId');
        return const BottomNavView(index: 2);
      },
      transition: Transition.rightToLeft,
      transitionDuration: const Duration(milliseconds: 300),
    ),
  ];
}