// lib/core/dependency_injection.dart
import 'package:assaan_rishta/app/core/services/storage_services/export.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/export.dart';
import '../../viewmodels/account_type_viewmodel.dart';
import '../../viewmodels/bottom_nav_viewmodel.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../viewmodels/login_viewmodel.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../views/profile/change_password/change_password_controller.dart';
import '../../views/profile/contact_us/contact_us_controller.dart';
import '../../views/profile/edit_profile/edit_profile_controller.dart';
import '../../views/profile/favorites/favorites_controller.dart';
import '../../views/profile/profile_details/profile_details_controller.dart';
import '../../views/profile/transaction_history/transaction_history_controller.dart';
import 'network_services/export.dart';

class DependencyInjection {
  static Future<void> init() async {
    Get.lazyPut<AccountTypeViewModel>(() => AccountTypeViewModel());

    // Initialize SharedPreferences first (required by multiple classes)
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    // 1. Register low-level dependencies
    Get.lazyPut<StorageRepo>(() => StorageRepoImpl(sharedPreferences));
    Get.lazyPut<NetworkHelper>(() => NetworkHelperImpl(sharedPreferences));
    Get.lazyPut<EndPoints>(() => EndPoints());
    Get.lazyPut<AccountTypeViewModel>(() => AccountTypeViewModel());



    // 3. Register SystemConfigRepo with all its dependencies
    Get.lazyPut<SystemConfigRepo>(() => SystemConfigRepoImpl(
      Get.find<StorageRepo>(),
      Get.find<NetworkHelper>(),
      Get.find<EndPoints>(),
      sharedPreferences,
    ));

    // 4. Register SystemConfigUseCase with the repo
    Get.lazyPut<SystemConfigUseCase>(
          () => SystemConfigUseCase(Get.find<SystemConfigRepo>()),
    );

    // 5. Register UserManagementRepoImpl with all dependencies
    Get.lazyPut<UserManagementRepo>(() => UserManagementRepoImpl(
      Get.find<StorageRepo>(),
      Get.find<NetworkHelper>(),
      Get.find<EndPoints>(),
      sharedPreferences,
    ));

    // 6. Register UserManagementUseCase
    Get.lazyPut<UserManagementUseCase>(
          () => UserManagementUseCase(Get.find<UserManagementRepo>()),
    );

    // 7. Register LoginViewModel
    Get.lazyPut<LoginViewModel>(() => LoginViewModel());
    Get.lazyPut<SignupViewModel>(() => SignupViewModel());
    // Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController());

    Get.lazyPut<BottomNavController>(() => BottomNavController());
    Get.lazyPut<HomeController>(() => HomeController());
    // Get.lazyPut<VendorController>(() => VendorController());
    // Get.lazyPut<FilterController>(() => FilterController());

    Get.lazyPut<UserDetailsController>(() => UserDetailsController());

    Get.lazyPut<ProfileController>(() => ProfileController());
    Get.lazyPut<ProfileDetailsController>(() => ProfileDetailsController());
    Get.lazyPut<EditProfileController>(() => EditProfileController());
    // Get.lazyPut<PartnerPreferenceController>(() => PartnerPreferenceController());
    Get.lazyPut<FavoritesController>(() => FavoritesController());
    // Get.lazyPut<BuyConnectsController>(() => BuyConnectsController());
    Get.lazyPut<TransactionHistoryController>(() => TransactionHistoryController());
    Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
    Get.lazyPut<ContactUsController>(() => ContactUsController());

    // Get.lazyPut<VendorListingController>(() => VendorListingController());
    // Get.lazyPut<VendorDetailController>(() => VendorDetailController());

  }
}
