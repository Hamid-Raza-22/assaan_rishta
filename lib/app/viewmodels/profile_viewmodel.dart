// profile_viewmodel.dart - Enhanced with complete Firebase cleanup

import 'dart:convert';
import 'package:assaan_rishta/app/widgets/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/export.dart';
import '../core/routes/app_routes.dart';
import '../core/services/env_config_service.dart';
import '../core/services/firebase_service/notification_service.dart';
import '../core/services/secure_storage_service.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import 'auth_service.dart';
import 'dashboard_viewmodel.dart';

class ProfileController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  RxBool isLoading = false.obs;
  final authService = AuthService.instance;

  var profileDetails = CurrentUserProfile().obs;
  var vendorProfile = Rx<VendorOwnProfile?>(null);
  RxInt profileCompleteCount = 0.obs;
  
  /// Check if current user is a Matrimonial vendor (role_id == 3)
  RxBool isMatrimonialUser = false.obs;

  @override
  void onInit() {
    _checkUserRole();
    super.onInit();
  }

  /// Check user role and load appropriate profile
  Future<void> _checkUserRole() async {
    final roleId = await userManagementUseCases.getUserRoleId();
    isMatrimonialUser.value = roleId == 3;
    debugPrint('👤 User role_id: $roleId, isMatrimonial: ${isMatrimonialUser.value}');
    
    if (isMatrimonialUser.value) {
      await getVendorOwnProfile();
    } else {
      await getCurrentUserProfiles();
      await getProfileCompletionCount();
    }
  }

  /// Get Vendor Own Profile for Matrimonial users
  Future<void> getVendorOwnProfile() async {
    isLoading.value = true;
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

  getUserName() {
    return "${profileDetails.value.firstName} ${profileDetails.value.lastName}";
  }

  /// Deactivate profile - Professional implementation with proper sequencing
  /// Flow: API Call → Firebase Cleanup → FCM Removal → Local Clear → Navigate
  Future<void> deactivateProfile() async {
    final context = Get.context!;

    // Show deactivation-specific loading
    _showDeactivationLoader();

    try {
      final userId = userManagementUseCases.getUserId();
      debugPrint('🔄 [DEACTIVATE] Starting for user: $userId');

      // Step 1: Call backend API to deactivate
      final response = await userManagementUseCases.deactivateUserProfile(userId: userId!);

      final isSuccess = response.fold(
        (error) {
          debugPrint("❌ [DEACTIVATE] API Error: $error");
          return false;
        },
        (success) {
          debugPrint("✅ [DEACTIVATE] API Success");
          return true;
        },
      );

      if (!isSuccess) {
        _dismissDeactivationLoader();
        AppUtils.failedData(
          title: "Deactivation Failed",
          message: "Failed to deactivate profile. Please try again.",
        );
        return;
      }

      // Step 2: Perform all cleanup operations in parallel for speed
      debugPrint('🔄 [DEACTIVATE] Starting cleanup operations...');

      await Future.wait([
        _performFastFirebaseCleanup(userId.toString()),
        _removeFCMTokenFast(userId.toString()),
      ], eagerError: false);


      debugPrint('✅ [DEACTIVATE] All cleanup operations completed');

      // Step 3: Clear local storage and auth state
      await _clearLocalDataFast();

      // Step 4: Dismiss loader
      _dismissDeactivationLoader();

      // Step 5: Show brief success toast (non-blocking)
      Get.snackbar(
        'Profile Deactivated',
        'Your profile has been deactivated successfully',
        snackPosition: SnackPosition.TOP,
        backgroundColor: AppColors.greenColor,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(10),
        borderRadius: 10,
        icon: const Icon(Icons.check_circle, color: Colors.white),
      );

      // Step 6: Navigate immediately to login
      debugPrint('🚪 [DEACTIVATE] Navigating to login...');
      Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);

    } catch (e) {
      debugPrint("❌ [DEACTIVATE] Error: $e");
      _dismissDeactivationLoader();
      AppUtils.failedData(
        title: "Deactivation Failed",
        message: "Failed to deactivate profile. Please try again.",
      );
    }
  }

  /// Show deactivation-specific loader
  void _showDeactivationLoader() {
    Get.dialog(
      PopScope(
        canPop: false,
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: AppColors.primaryColor),
                SizedBox(height: 16),
                AppText(
                  text: 'Deactivating profile...',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                SizedBox(height: 4),
                AppText(
                  text: 'Please wait',
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  /// Dismiss deactivation loader safely
  void _dismissDeactivationLoader() {
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
  }

  /// Fast Firebase cleanup - optimized for deactivation (not deletion)
  Future<void> _performFastFirebaseCleanup(String userId) async {
    try {
      debugPrint('🔥 [CLEANUP] Fast Firebase cleanup for: $userId');

      // Only update user's own document - don't iterate all users
      await FirebaseFirestore.instance
                    .collection(EnvConfig.firebaseUsersCollection)

          .doc(userId)
          .update({
        'is_deactivated': true,
        'deactivated_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'is_online': false,
        'is_mobile_online': false,
        'is_web_online': false,
        'push_token': '', // Clear push token
      });

      debugPrint('✅ [CLEANUP] Firebase cleanup done');
    } catch (e) {
      debugPrint('⚠️ [CLEANUP] Firebase cleanup error (non-fatal): $e');
      // Don't rethrow - deactivation should still proceed
    }
  }

  /// Fast FCM token removal
  Future<void> _removeFCMTokenFast(String userId) async {
    try {
      debugPrint('🔔 [CLEANUP] Removing FCM token...');

      await Future.wait([
        FirebaseFirestore.instance
                      .collection(EnvConfig.firebaseUsersCollection)

            .doc(userId)
            .update({'push_token': FieldValue.delete()}),
        FirebaseMessaging.instance.deleteToken(),
      ], eagerError: false);

      debugPrint('✅ [CLEANUP] FCM token removed');
    } catch (e) {
      debugPrint('⚠️ [CLEANUP] FCM removal error (non-fatal): $e');
    }
  }

  /// Fast local data clearing
  Future<void> _clearLocalDataFast() async {
    try {
      debugPrint('🗑️ [CLEANUP] Clearing local data...');

      final secureStorage = SecureStorageService();

      // Save onboarding flags before clearing
      final hasSeenOnboarding = await secureStorage.hasSeenOnboarding();
      final isFirstInstall = await secureStorage.isFirstInstall();

      // Clear all data
      await secureStorage.clearAll();

      // Restore onboarding flags
      await Future.wait([
        secureStorage.setHasSeenOnboarding(hasSeenOnboarding),
        secureStorage.setFirstInstall(isFirstInstall),
      ]);

      // Clear notification session
      NotificationServices.clearSession();

      // Update auth state
      authService.isUserLoggedIn.value = false;
      authService.currentUser.value = null;

      debugPrint('✅ [CLEANUP] Local data cleared');
    } catch (e) {
      debugPrint('⚠️ [CLEANUP] Local clear error (non-fatal): $e');
    }
  }

  // Mark user as deactivated in Firebase (user not deleted, just marked)
  Future<void> _markUserAsDeactivatedInFirebase(String userId) async {
    try {
      debugPrint('🔥 Marking user as deactivated in Firebase: $userId');

      final userRef = FirebaseFirestore.instance          .collection(EnvConfig.firebaseUsersCollection)
.doc(userId);

      await userRef.set({
        'is_deactivated': true,
        'deactivated_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'is_online': false,
        'is_mobile_online': false,
        'is_web_online': false,
      }, SetOptions(merge: true));

      debugPrint('✅ User marked as deactivated in Firebase');
    } catch (e) {
      debugPrint('❌ Error marking user as deactivated in Firebase: $e');
    }
  }

  var isDeletingProfile = false.obs;

  // ENHANCED: Complete profile deletion with Firebase cleanup
  deleteProfile(context) async {
    if (isDeletingProfile.value) return;
    isDeletingProfile.value = true;

    // First, close the confirmation dialog if open
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }

    AppUtils.onLoading(context);

    try {
      final userId = userManagementUseCases.getUserId().toString();
      debugPrint('🗑️ Starting complete profile deletion for user: $userId');

      // Step 1: Delete from backend API first
      final response = await userManagementUseCases.deleteUserProfile();

      await response.fold(
        (error) {
          if (Get.isDialogOpen ?? false) {
            Get.back();
          }
          debugPrint("❌ Error deleting profile from backend: $error");
          AppUtils.failedData(
            title: "Delete Profile Failed",
            message: "Failed to delete profile from server",
          );
        },
        (success) async {
          debugPrint("✅ Profile deleted from backend successfully");

          // Step 2: Complete Firebase cleanup (ultra fast parallel processing)
          try {
            await _performCompleteFirebaseCleanup(userId);
          } catch (e) {
            debugPrint("⚠️ Firebase cleanup error: $e");
          }

          if (Get.isDialogOpen ?? false) {
            Get.back();
          }

          // Step 3: Show success message
          AppUtils.successData(
            title: "Profile Deleted",
            message: "Your profile has been completely deleted",
          );

          // Step 4: Logout user directly
          await handleLogout(context);
        },
      );
    } catch (e) {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
      debugPrint("❌ Complete error in profile deletion: $e");
      AppUtils.failedData(
        title: "Deletion Failed",
        message: "Failed to completely delete profile. Please try again.",
      );
    } finally {
      isDeletingProfile.value = false;
    }
  }

  // ENHANCED: Complete Firebase cleanup when user deletes profile (Ultra Fast)
  Future<void> _performCompleteFirebaseCleanup(String userId) async {
    try {
      debugPrint('🔥 Starting complete Firebase cleanup for user: $userId');

      final batch = FirebaseFirestore.instance.batch();

      // Step 1: Mark user as deleted
      final userRef = FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId);

      batch.set(userRef, {
        'account_deleted': true,
        'deleted_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Deleted User',
        'image': '',
        'about': 'This account has been deleted',
        'is_online': false,
        'is_mobile_online': false,
        'is_web_online': false,
        'push_token': '',
      }, SetOptions(merge: true));

      // Fetch user's my_users, deleted_chats, and active conversations in PARALLEL
      final myUsersFuture = FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .collection('my_users')
          .get();

      final deletedChatsFuture = FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(userId)
          .collection('deleted_chats')
          .get();

      final conversationsFuture = FirebaseFirestore.instance
          .collection(EnvConfig.firebaseChatsCollection)
          .where('participants', arrayContains: userId)
          .get();

      final results = await Future.wait([
        myUsersFuture,
        deletedChatsFuture,
        conversationsFuture,
      ]);

      final myUsersSnapshot = results[0] as QuerySnapshot<Map<String, dynamic>>;
      final deletedChatsSnapshot = results[1] as QuerySnapshot<Map<String, dynamic>>;
      final conversationsSnapshot = results[2] as QuerySnapshot<Map<String, dynamic>>;

      final partnerIds = <String>{};

      // Collect all partners from user's my_users and clean up user's my_users docs
      for (var doc in myUsersSnapshot.docs) {
        partnerIds.add(doc.id);
        batch.delete(doc.reference);
      }

      // Collect partners from active conversations and post system message
      final nowStr = DateTime.now().millisecondsSinceEpoch.toString();
      for (var chatDoc in conversationsSnapshot.docs) {
        final participants = List<String>.from(chatDoc.data()['participants'] ?? []);
        for (var pId in participants) {
          if (pId != userId && pId.isNotEmpty) {
            partnerIds.add(pId);
          }
        }

        final systemMessageRef = chatDoc.reference
            .collection('messages')
            .doc(nowStr);

        batch.set(systemMessageRef, {
          'fromId': 'SYSTEM',
          'toId': '',
          'msg': 'This user has deleted their account',
          'type': 'system',
          'sent': nowStr,
          'read': '',
        });
      }

      // Mark this chat as with deleted user in partner's my_users
      for (var partnerId in partnerIds) {
        final partnerMyUserRef = FirebaseFirestore.instance
            .collection(EnvConfig.firebaseUsersCollection)
            .doc(partnerId)
            .collection('my_users')
            .doc(userId);

        batch.set(partnerMyUserRef, {
          'user_deleted': true,
          'deletion_timestamp': nowStr,
        }, SetOptions(merge: true));

        debugPrint('📱 Updated chat reference for partner: $partnerId');
      }

      // Clean up deleted_chats collection
      for (var doc in deletedChatsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Commit all changes in a single batch
      await batch.commit();

      debugPrint('✅ Complete Firebase cleanup completed successfully');

    } catch (e) {
      debugPrint('❌ Error in Firebase cleanup: $e');
      rethrow;
    }
  }

  // Enhanced chat user card detection method
  // static Future<bool> isUserDeleted(String userId) async {
  //   try {
  //     final userDoc = await FirebaseFirestore.instance
  //                   .collection(EnvConfig.firebaseUsersCollection)

  //         .doc(userId)
  //         .get();
  //
  //     if (!userDoc.exists) {
  //       return true; // User doesn't exist
  //     }
  //
  //     final userData = userDoc.data()!;
  //     return userData['account_deleted'] == true;
  //
  //   } catch (e) {
  //     debugPrint('Error checking if user is deleted: $e');
  //     return false;
  //   }
  // }

  // Method to get user deletion timestamp
  // static Future<String?> getUserDeletionTime(String userId) async {
  //   try {
  //     final userDoc = await FirebaseFirestore.instance
  //                   .collection(EnvConfig.firebaseUsersCollection)

  //         .doc(userId)
  //         .get();
  //
  //     if (userDoc.exists && userDoc.data()!['account_deleted'] == true) {
  //       return userDoc.data()!['deleted_at'] as String?;
  //     }
  //
  //     return null;
  //   } catch (e) {
  //     debugPrint('Error getting deletion time: $e');
  //     return null;
  //   }
  // }

  // Rest of your existing methods remain the same...

  ///pick image and convert image
  Future<void> pickImage(context, ImageSource source) async {
    final pickedFile = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
    );
    if (pickedFile != null) {
      _convertToBase64(context, pickedFile);
    }
  }

  void _convertToBase64(context, XFile imageFile) async {
    List<int> imageBytes = await imageFile.readAsBytes();
    String base64String = base64Encode(imageBytes);
    updateProfilePic(context: context, picData: base64String);
  }

  // Update Firebase chat image method remains the same
  Future<void> updateFirebaseChatImage(String imageUrl) async {
    try {
      final userId = userManagementUseCases.getUserId().toString();

      debugPrint('🖼️ Updating profile image in Firebase chat for user: $userId');
      debugPrint('🔗 New image URL: $imageUrl');

      await FirebaseFirestore.instance
                    .collection(EnvConfig.firebaseUsersCollection)

          .doc(userId)
          .update({
        'image': imageUrl,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      });

      debugPrint('✅ Profile image updated in Firebase chat successfully');

    } catch (e) {
      debugPrint('❌ Error updating profile image in Firebase chat: $e');
    }
  }

  // Other existing methods...
  getProfileCompletionCount() async {
    final response = await userManagementUseCases.getProfileCompletionCount();
    return response.fold(
          (error) {
        debugPrint("error getting profile count");
      },
          (success) {
        String body = "$success";
        double bodyDouble = double.parse(body);
        profileCompleteCount.value =
        bodyDouble.toInt() >= 100 ? 100 : bodyDouble.toInt();
        update();
      },
    );
  }

  getCurrentUserProfiles() async {
    isLoading.value = true;
    final response = await userManagementUseCases.getCurrentUserProfile();
    return response.fold(
          (error) {
        isLoading.value = false;
      },
          (success) {
        profileDetails.value = success;
        debugPrint('📋 Profile loaded - is_blur: ${success.blurProfileImage}');
        isLoading.value = false;
        update();
      },
    );
  }

  updateProfilePic({context, picData}) async {
    AppUtils.onLoading(Get.context!);

    final response = await userManagementUseCases.updateProfilePic(
      picData: picData,
    );

    return response.fold(
          (error) {
        AppUtils.dismissLoader(Get.context!);
        debugPrint('❌ Error updating profile image: $error');
        AppUtils.failedData(
          title: "Update Profile Image",
          message: "Update profile image is failed",
        );
      },
          (success) async {
        AppUtils.dismissLoader(Get.context!);

        try {
          // Refresh appropriate profile based on user type
          if (isMatrimonialUser.value) {
            await getVendorOwnProfile();
            // Also refresh dashboard to update welcome card image
            if (Get.isRegistered<DashboardController>()) {
              Get.find<DashboardController>().refreshDashboard();
            }
          } else {
            await getCurrentUserProfiles();
          }
          
          // Get new image URL based on user type
          String? newImageUrl = isMatrimonialUser.value 
              ? vendorProfile.value?.logo 
              : profileDetails.value.profileImage;

          debugPrint('📱 Profile updated successfully');
          debugPrint('🔗 New image URL from API: $newImageUrl');

          if (newImageUrl != null && newImageUrl.isNotEmpty) {
            await updateFirebaseChatImage(newImageUrl);

            AppUtils.successData(
              title: "Update Profile Image",
              message: "Profile image updated successfully in chat and profile.",
            );
          } else {
            String fallbackUrl = _constructImageUrl(success);

            if (fallbackUrl.isNotEmpty) {
              await updateFirebaseChatImage(fallbackUrl);
            }

            AppUtils.successData(
              title: "Update Profile Image",
              message: "Profile image updated successfully.",
            );
          }

        } catch (e) {
          debugPrint('❌ Error in post-upload processing: $e');

          AppUtils.successData(
            title: "Update Profile Image",
            message: "Image updated but chat sync may need app restart.",
          );
        }

        update();
      },
    );
  }

  String _constructImageUrl(dynamic apiResponse) {
    try {
      if (apiResponse is Map<String, dynamic>) {
        if (apiResponse.containsKey('image_url')) {
          return apiResponse['image_url'] ?? '';
        }
        if (apiResponse.containsKey('data') &&
            apiResponse['data'] is Map<String, dynamic>) {
          final data = apiResponse['data'] as Map<String, dynamic>;
          if (data.containsKey('image_url')) {
            return data['image_url'] ?? '';
          }
          if (data.containsKey('profile_image')) {
            return data['profile_image'] ?? '';
          }
        }
        if (apiResponse.containsKey('profile_image')) {
          return apiResponse['profile_image'] ?? '';
        }
      }

      if (apiResponse is String && apiResponse.startsWith('http')) {
        return apiResponse;
      }

      debugPrint('🔍 API Response structure: $apiResponse');
      return '';

    } catch (e) {
      debugPrint('❌ Error constructing image URL: $e');
      return '';
    }
  }

  Future<String> getVersionNumber() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }
// Show loading dialog method
  void _showLoadingDialog() {
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false, // Prevent dismissal
        child: Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
                const SizedBox(height: 16),
                AppText(
                  text: 'Logging out...',
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),

              ],
            ),
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }
// Improved handleLogout method
  Future<void> handleLogout(BuildContext context) async {
    try {
      // Show loading dialog
      _showLoadingDialog();

      await authService.logout(context);

      // Hide loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

    } catch (e) {
      debugPrint('❌ Logout error: $e');

      // Hide loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      Get.snackbar(
        'Error',
        'Failed to logout. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }


  Future<void> checkIfUserLogin() async {
    int? uid = userManagementUseCases.getUserId();

    final userRef = FirebaseFirestore.instance          .collection(EnvConfig.firebaseUsersCollection)
.doc('$uid');

    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};

    final hasIsWebOnline = data.containsKey('is_web_online');
    final hasIsMobileOnline = data.containsKey('is_mobile_online');

    if (!hasIsWebOnline || !hasIsMobileOnline) {
      await userRef.set({
        'is_web_online': false,
        'is_mobile_online': false,
      }, SetOptions(merge: true));
    }

    final updatedSnapshot = await userRef.get();
    final updatedData = updatedSnapshot.data() ?? {};
    final isWebOnline = updatedData['is_web_online'] == true;

    if (isWebOnline) {
      await userRef.set({
        'is_mobile_online': false,
      }, SetOptions(merge: true));
    } else {
      await userRef.set({
        'is_online': false,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
        'is_mobile_online': false,
      }, SetOptions(merge: true));
    }
  }

  // Toggle blur profile image setting (optimistic update)
  Future<void> toggleBlurProfileImage(bool value) async {
    try {
      debugPrint('🔄 Toggling blur profile image to: $value');

      // Update UI immediately (optimistic update)
      profileDetails.value.blurProfileImage = value;
      update();

      // Make API call
      final response = await userManagementUseCases.updateBlurProfileImage(value);

      response.fold(
        (error) {
          debugPrint('❌ Error updating blur setting: $error');
          // Revert on error
          profileDetails.value.blurProfileImage = !value;
          update();
          AppUtils.failedData(
            title: error.title.isNotEmpty ? error.title : "Update Failed",
            message: error.description.isNotEmpty ? error.description : "Failed to update blur setting",
          );
        },
        (success) {
          debugPrint('✅ Blur setting updated successfully');
        },
      );
    } catch (e) {
      debugPrint('❌ Error in toggleBlurProfileImage: $e');
      // Revert on error
      profileDetails.value.blurProfileImage = !value;
      update();
      AppUtils.failedData(
        title: "Error",
        message: "An error occurred while updating blur setting",
      );
    }
  }
}