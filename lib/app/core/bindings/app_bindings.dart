// app_bindings.dart - Complete fix
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import '../../views/profile/export.dart';
import '../../views/profile/partner_preference/partner_preference_controller.dart';
import '../../views/splash/export.dart';
import '../../views/vendor/export.dart';
import '../services/network_services/export.dart';
import '../services/storage_services/export.dart';



class AppBindings extends Bindings {
  @override
  void dependencies() async {
    debugPrint('🔧 Initializing AppBindings...');

    try {
      Get.put<AuthService>(AuthService(), permanent: true);
      final SharedPreferences prefs = await SharedPreferences.getInstance();

      Get.put<StorageRepo>(StorageRepoImpl(prefs), permanent: true);
      Get.put<NetworkHelper>(NetworkHelperImpl(prefs), permanent: true);
      Get.put<EndPoints>(EndPoints(), permanent: true);
      Get.lazyPut<SplashController>(
            () => SplashController(
          Get.find<UserManagementUseCase>(),
        ),
      );
      Get.put<SystemConfigRepo>(
        SystemConfigRepoImpl(Get.find(), Get.find(), Get.find(), prefs),
        permanent: true,
      );
      Get.put<UserManagementRepo>(
        UserManagementRepoImpl(Get.find(), Get.find(), Get.find(), prefs),
        permanent: true,
      );

      Get.put<SystemConfigUseCase>(SystemConfigUseCase(Get.find()), permanent: true);
      Get.put<UserManagementUseCase>(UserManagementUseCase(Get.find()), permanent: true);

      Get.put<ChatViewModel>(ChatViewModel(), permanent: true);
      // Get.put<ChatListController>(ChatListController(), permanent: true);
      Get.put<AccountTypeViewModel>(AccountTypeViewModel(), permanent: true);
      // Get.put<BottomNavController>(BottomNavController(), permanent: true);

      // Lazy loaded viewmodels
      // Get.Put(() => AccountTypeViewModel());
      Get.lazyPut(() => LoginViewModel());
      Get.lazyPut(() => SignupViewModel());
      Get.lazyPut(() => ForgotPasswordController());
      Get.lazyPut(() => BottomNavController());
      Get.lazyPut(() => ChatListController());
      Get.lazyPut(() => HomeController());
      Get.lazyPut(() => UserDetailsController());
      Get.lazyPut(() => ProfileController());
      Get.lazyPut(() => ProfileDetailsController());
      Get.lazyPut(() => EditProfileController());
      Get.lazyPut(() => FavoritesController());
      Get.lazyPut(() => TransactionHistoryController());
      Get.lazyPut(() => ChangePasswordController());
      Get.lazyPut(() => ContactUsController());
      Get.lazyPut(() => VendorController());
      Get.lazyPut(() => FilterController());
      Get.lazyPut(() => VendorListingController());
      Get.lazyPut(() => VendorDetailController());
      Get.lazyPut(() => ProfileDetailsController());
      Get.lazyPut(() => EditProfileController());
      Get.lazyPut(() => PartnerPreferenceController());
      Get.lazyPut(() => FavoritesController());
      Get.lazyPut(() => BuyConnectsView());
      Get.lazyPut(() => TransactionHistoryController());
      Get.lazyPut(() => ChangePasswordController());
      Get.lazyPut(() => ContactUsController());


      debugPrint('🎉 All dependencies registered successfully');
    } catch (e) {
      debugPrint('💥 Error in AppBindings: $e');
    }
  }
}
