import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/base/export.dart';
import '../core/routes/app_routes.dart';
import '../domain/use_cases/user_management_use_case/user_management_use_case.dart';
import '../core/services/secure_storage_service.dart';
import '../core/export.dart';
import 'signup_viewmodel.dart';

class DashboardController extends BaseController {
  final UserManagementUseCase userManagementUseCases = Get.find<UserManagementUseCase>();
  final RxBool isLoading = true.obs;
  
  // User info
  String userName = "";
  RxString userImage = "".obs;
  String userRole = "";
  int userId = 0;
  
  // Vendor profile for matrimonial users
  Rx<VendorOwnProfile?> vendorProfile = Rx<VendorOwnProfile?>(null);
  
  // Dashboard stats
  int totalProfiles = 0;
  int activeUsers = 0;
  int newRegistrations = 0;
  int pendingApprovals = 0;

  @override
  void onInit() {
    super.onInit();
    getUserProfile();
  }

  Future<void> getUserProfile() async {
    isLoading.value = true;
    update();
    
    try {
      // Get user info from secure storage
      final secureStorage = SecureStorageService();
      userId = int.tryParse(await secureStorage.getUserId() ?? "0") ?? 0;
      userName = await secureStorage.getUserName() ?? "";
      userImage.value = await secureStorage.getUserPic() ?? "";
      
      // Get donor claims to verify role
      final response = await userManagementUseCases.getDonorClaims();
      
      bool isMatrimonial = false;
      response.fold(
        (error) {
          debugPrint('❌ Error getting user profile: $error');
        },
        (success) {
          if (success.roleId == 3) {
            userRole = success.roleName ?? "Administrator";
            isMatrimonial = true;
          }
        },
      );
      
      // Fetch vendor profile for matrimonial users (outside fold to properly await)
      if (isMatrimonial) {
        await _fetchVendorProfile();
        _fetchDashboardStats();
      }
    } catch (e) {
      debugPrint('❌ Error in getUserProfile: $e');
    } finally {
      isLoading.value = false;
      update();
    }
  }

  /// Fetch vendor profile for matrimonial users
  Future<void> _fetchVendorProfile() async {
    try {
      final response = await userManagementUseCases.getVendorOwnProfile();
      response.fold(
        (error) {
          debugPrint('❌ Error fetching vendor profile: ${error.description}');
        },
        (success) {
          vendorProfile.value = success;
          debugPrint('🖼️ Vendor logo from API: ${success.logo}');
          // Update user image with vendor logo
          if (success.logo != null && success.logo!.isNotEmpty) {
            userImage.value = success.logo!;
            debugPrint('🖼️ userImage updated to: ${userImage.value}');
          } else {
            debugPrint('⚠️ Vendor logo is null or empty');
          }
          debugPrint('✅ Vendor profile fetched successfully');
          update();
        },
      );
    } catch (e) {
      debugPrint('❌ Error in _fetchVendorProfile: $e');
    }
  }

  /// Refresh dashboard - call this to reload vendor profile
  Future<void> refreshDashboard() async {
    await getUserProfile();
  }

  Future<void> _fetchDashboardStats() async {
    try {
      // In a real implementation, these would be fetched from an API
      // For now, we'll use placeholder data
      totalProfiles = 1250;
      activeUsers = 875;
      newRegistrations = 42;
      pendingApprovals = 15;
      
      // You would implement actual API calls here to get real stats
      // Example:
      // final response = await apiService.getDashboardStats();
      // response.fold(
      //   (error) => debugPrint('Error fetching stats: $error'),
      //   (success) {
      //     totalProfiles = success.totalProfiles;
      //     activeUsers = success.activeUsers;
      //     newRegistrations = success.newRegistrations;
      //     pendingApprovals = success.pendingApprovals;
      //   },
      // );
      
    } catch (e) {
      debugPrint('❌ Error fetching dashboard stats: $e');
    }
  }
  
  /// Launch registration flow from dashboard
  /// Sets the isFromDashboard flag and profileCreatedBy in SignupViewModel
  void navigateToRegisterUser() {
    final signupController = Get.find<SignupViewModel>();
    
    // Clear any previous form data
    signupController.clearFormData();
    
    // Set dashboard registration tracking
    signupController.isFromDashboard.value = true;
    signupController.profileCreatedBy = userId;
    
    debugPrint('🔐 Dashboard registration initiated by user ID: $userId');
    
    // Navigate to signup screen
    Get.toNamed(AppRoutes.SIGNUP);
  }
  
  /// Refresh dashboard data
  // Future<void> refreshDashboard() async {
  //   await getUserProfile();
  // }
}
