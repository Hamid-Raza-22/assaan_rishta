// app_bindings.dart - Complete fix
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/export.dart';
import '../../viewmodels/account_type_viewmodel.dart';
import '../../viewmodels/auth_service.dart';
import '../../viewmodels/chat_list_viewmodel.dart';
import '../../viewmodels/chat_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/filter_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../views/bottom_nav/export.dart';
import '../../views/forgot_password/export.dart';
import '../../views/on_boarding_screens/controller.dart';
import '../../views/profile/connects_history/connects_history_controller.dart';
import '../../views/profile/export.dart';
import '../../views/profile/partner_preference/partner_preference_controller.dart';
import '../../views/profile/user_guide/user_guide_controller.dart';
import '../../views/splash/export.dart';
import '../../views/vendor/export.dart';
import '../services/account_status_service.dart';
import '../services/session_manager.dart';




class AppBindings extends Bindings {
  @override
  void dependencies() async {
    debugPrint('🔧 Initializing AppBindings...');

    try {
      // Register SessionManager first (required by AccountStatusService)
      Get.put<SessionManager>(SessionManager(), permanent: true);
      debugPrint('✅ SessionManager registered');

      // Register AccountStatusService (for cross-device deactivation)
      Get.put<AccountStatusService>(AccountStatusService(), permanent: true);
      debugPrint('✅ AccountStatusService registered');

      Get.lazyPut<AuthService>(() => AuthService(), fenix: true);
      debugPrint('✅ AuthService registered');

      Get.lazyPut<SplashController>(
            () => SplashController(
          Get.find<UserManagementUseCase>(),
        ),
      );
      debugPrint('✅ SplashController registered');

      Get.lazyPut(() => LoginViewModel(), fenix: true);
      debugPrint('✅ LoginViewModel registered');

      Get.lazyPut(() => AccountTypeViewModel(), fenix: true);
      debugPrint('✅ AccountTypeViewModel registered');

      Get.lazyPut(() => ChatViewModel(), fenix: true);
      debugPrint('✅ ChatViewModel registered');
      Get.put(SignupViewModel());
      // Get.lazyPut(() => SignupViewModel(), fenix: true);
      debugPrint('✅ SignupViewModel registered');

      Get.lazyPut(() => ForgotPasswordController(), fenix: true);
      debugPrint('✅ ForgotPasswordController registered');

      Get.lazyPut(() => BottomNavController(), fenix: true);
      debugPrint('✅ BottomNavController registered');

      Get.lazyPut(() => ChatListController(), fenix: true);
      debugPrint('✅ ChatListController registered');

      Get.lazyPut(() => HomeController(), fenix: true);
      debugPrint('✅ HomeController registered');

      // UserDetailsController is now managed by route-specific binding
      // Get.lazyPut(() => UserDetailsController(), fenix: true);
      // debugPrint('✅ UserDetailsController registered');

      Get.lazyPut(() => ProfileController(), fenix: true);
      debugPrint('✅ ProfileController registered');

      Get.lazyPut(() => ProfileDetailsController(), fenix: true);
      debugPrint('✅ ProfileDetailsController registered');

      Get.lazyPut(() => EditProfileController(), fenix: true);
      debugPrint('✅ EditProfileController registered');

      Get.lazyPut(() => FavoritesController(), fenix: true);
      debugPrint('✅ FavoritesController registered');

      Get.lazyPut(() => TransactionHistoryController(), fenix: true);
      debugPrint('✅ TransactionHistoryController registered');
      Get.lazyPut(() => ConnectsHistoryController(), fenix: true);
      debugPrint('✅ ConnectsHistoryController registered');


      Get.lazyPut(() => ChangePasswordController(), fenix: true);
      debugPrint('✅ ChangePasswordController registered');

      Get.lazyPut(() => ContactUsController(), fenix: true);
      debugPrint('✅ ContactUsController registered');

      Get.lazyPut(() => VendorController(), fenix: true);
      debugPrint('✅ VendorController registered');

      Get.lazyPut(() => FilterController(), fenix: true);
      debugPrint('✅ FilterController registered');

      Get.lazyPut(() => VendorListingController(), fenix: true);
      debugPrint('✅ VendorListingController registered');

      // VendorDetailController is now managed by route-specific binding
      // Get.lazyPut(() => VendorDetailController(), fenix: true);
      // debugPrint('✅ VendorDetailController registered');

      Get.lazyPut(() => PartnerPreferenceController(), fenix: true);
      debugPrint('✅ PartnerPreferenceController registered');
      Get.lazyPut(() =>BuyConnectsController(), fenix: true);
      debugPrint('✅ BuyConnectsController registered');

      Get.lazyPut(() => UserGuideController(), fenix: true);
      debugPrint('✅ UserGuideController registered');

      Get.lazyPut(() => OnboardingController(), fenix: true);
      debugPrint('✅ All dependencies registered');

      debugPrint('🎉 All dependencies registered successfully');
    } catch (e) {
      debugPrint('💥 Error in AppBindings: $e');
    }
  }
}

