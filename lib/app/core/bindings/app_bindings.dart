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
import '../../viewmodels/profile_viewmodel.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../views/bottom_nav/export.dart';
import '../../views/profile/export.dart';
import '../../views/profile/profile_details/profile_details_controller.dart';
import '../services/network_services/export.dart';
import '../services/storage_services/export.dart';



class AppBindings extends Bindings {
  @override
  void dependencies() async {
    debugPrint('🔧 Initializing AppBindings...');

    try {
      // HIGHEST PRIORITY: AuthService
      Get.put<AuthService>(AuthService(), permanent: true);
      debugPrint('✅ AuthService registered');

      // Initialize SharedPreferences
      final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
      debugPrint('✅ SharedPreferences initialized');

      // PERMANENT CORE DEPENDENCIES - These should never be deleted
      Get.put<StorageRepo>(StorageRepoImpl(sharedPreferences), permanent: true);
      Get.put<NetworkHelper>(NetworkHelperImpl(sharedPreferences), permanent: true);
      Get.put<EndPoints>(EndPoints(), permanent: true);
      debugPrint('✅ Core dependencies registered');

      // PERMANENT REPOS
      Get.put<SystemConfigRepo>(
        SystemConfigRepoImpl(
          Get.find<StorageRepo>(),
          Get.find<NetworkHelper>(),
          Get.find<EndPoints>(),
          sharedPreferences,
        ),
        permanent: true,
      );

      Get.put<UserManagementRepo>(
        UserManagementRepoImpl(
          Get.find<StorageRepo>(),
          Get.find<NetworkHelper>(),
          Get.find<EndPoints>(),
          sharedPreferences,
        ),
        permanent: true,
      );
      debugPrint('✅ Repos registered');

      // PERMANENT USE CASES
      Get.put<SystemConfigUseCase>(
        SystemConfigUseCase(Get.find<SystemConfigRepo>()),
        permanent: true,
      );

      Get.put<UserManagementUseCase>(
        UserManagementUseCase(Get.find<UserManagementRepo>()),
        permanent: true,
      );
      debugPrint('✅ Use cases registered');

      // PERMANENT VIEW MODELS
      Get.put<ChatListController>( ChatListController(),permanent: true);
      Get.put<ChatViewModel>(ChatViewModel(), permanent: true);
      debugPrint('✅ ChatViewModel registered');

      // LAZY PUT FOR OTHER CONTROLLERS (these can be deleted)
      Get.lazyPut<AccountTypeViewModel>(() => AccountTypeViewModel());
      Get.lazyPut<LoginViewModel>(() => LoginViewModel());
      Get.lazyPut<SignupViewModel>(() => SignupViewModel());
      Get.lazyPut<BottomNavController>(() => BottomNavController());
      Get.lazyPut<HomeController>(() => HomeController());
      Get.lazyPut<UserDetailsController>(() => UserDetailsController());
      Get.lazyPut<ProfileController>(() => ProfileController());
      Get.lazyPut<ProfileDetailsController>(() => ProfileDetailsController());
      Get.lazyPut<EditProfileController>(() => EditProfileController());
      Get.lazyPut<FavoritesController>(() => FavoritesController());
      Get.lazyPut<TransactionHistoryController>(() => TransactionHistoryController());
      Get.lazyPut<ChangePasswordController>(() => ChangePasswordController());
      Get.lazyPut<ContactUsController>(() => ContactUsController());
      Get.lazyPut<ChatListController>(() => ChatListController());
      debugPrint('🎉 All dependencies registered successfully');
    } catch (e) {
      debugPrint('💥 Error in AppBindings: $e');
    }
  }
}