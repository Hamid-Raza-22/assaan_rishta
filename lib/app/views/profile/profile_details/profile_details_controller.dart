import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';


class ProfileDetailsController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  RxBool isLoading = false.obs;

  var profileDetails = CurrentUserProfile().obs;
  var vendorProfile = Rx<VendorOwnProfile?>(null);
  
  /// Check if current user is a Matrimonial vendor (role_id == 3)
  RxBool isMatrimonialUser = false.obs;

  @override
  void onInit() {
    _checkUserRoleAndLoadProfile();
    super.onInit();
  }

  /// Check user role and load appropriate profile
  Future<void> _checkUserRoleAndLoadProfile() async {
    isLoading.value = true;
    final roleId = await userManagementUseCases.getUserRoleId();
    isMatrimonialUser.value = roleId == 3;
    debugPrint('👤 ProfileDetails - role_id: $roleId, isMatrimonial: ${isMatrimonialUser.value}');
    
    if (isMatrimonialUser.value) {
      await getVendorOwnProfile();
    } else {
      await getCurrentUserProfiles();
    }
  }

  /// Get Vendor Own Profile for Matrimonial users
  Future<void> getVendorOwnProfile() async {
    final response = await userManagementUseCases.getVendorOwnProfile();
    response.fold(
      (error) {
        debugPrint('❌ Error getting vendor profile: ${error.description}');
        isLoading.value = false;
      },
      (success) {
        vendorProfile.value = success;
        debugPrint('✅ Vendor profile loaded: ${success.venderBusinessName}');
        isLoading.value = false;
        update();
      },
    );
  }

  /// Get User Profile for Rishta users
  Future<void> getCurrentUserProfiles() async {
    final response = await userManagementUseCases.getCurrentUserProfile();
    response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        profileDetails.value = success;
        isLoading.value = false;
        update();
      },
    );
  }
}
