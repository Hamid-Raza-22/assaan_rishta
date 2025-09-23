// profile_viewmodel.dart - Enhanced with complete Firebase cleanup

import 'dart:convert';
import 'package:assaan_rishta/app/widgets/app_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../core/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import 'auth_service.dart';

class ProfileController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  RxBool isLoading = false.obs;
  final authService = AuthService.instance;

  var profileDetails = CurrentUserProfile().obs;
  RxInt profileCompleteCount = 0.obs;

  @override
  void onInit() {
    getCurrentUserProfiles();
    getProfileCompletionCount();
    super.onInit();
  }

  getUserName() {
    return "${profileDetails.value.firstName} ${profileDetails.value.lastName}";
  }

  // ENHANCED: Complete profile deletion with Firebase cleanup
  deleteProfile(context) async {
    AppUtils.onLoading(context);

    try {
      final userId = userManagementUseCases.getUserId().toString();
      debugPrint('🗑️ Starting complete profile deletion for user: $userId');

      // Step 1: Delete from backend API first
      final response = await userManagementUseCases.deleteUserProfile();

      await response.fold(
            (error) {
          AppUtils.dismissLoader(context);
          debugPrint("❌ Error deleting profile from backend: $error");
          AppUtils.failedData(
            title: "Delete Profile Failed",
            message: "Failed to delete profile from server",
          );
          throw Exception("Backend deletion failed");
        },
            (success) async {
          debugPrint("✅ Profile deleted from backend successfully");

          // Step 2: Complete Firebase cleanup
          await _performCompleteFirebaseCleanup(userId);

          AppUtils.dismissLoader(context);

          // Step 3: Show success message
          AppUtils.successData(
            title: "Profile Deleted",
            message: "Your profile has been completely deleted",
          );

          // Step 4: Logout user after short delay
          await Future.delayed(const Duration(seconds: 2));
          handleLogout(context);
        },
      );

    } catch (e) {
      AppUtils.dismissLoader(context);
      debugPrint("❌ Complete error in profile deletion: $e");
      AppUtils.failedData(
        title: "Deletion Failed",
        message: "Failed to completely delete profile. Please try again.",
      );
    }
  }

  // ENHANCED: Complete Firebase cleanup when user deletes profile
  Future<void> _performCompleteFirebaseCleanup(String userId) async {
    try {
      debugPrint('🔥 Starting complete Firebase cleanup for user: $userId');

      final batch = FirebaseFirestore.instance.batch();

      // Step 1: Mark user as deleted (instead of immediate deletion)
      final userRef = FirebaseFirestore.instance.collection('Hamid_users').doc(userId);
      batch.update(userRef, {
        'account_deleted': true,
        'deleted_at': DateTime.now().millisecondsSinceEpoch.toString(),
        'name': 'Deleted User',
        'image': '', // Clear image
        'about': 'This account has been deleted',
        'is_online': false,
        'is_mobile_online': false,
        'is_web_online': false,
        'push_token': '', // Clear push token
      });

      // Step 2: Get all users who have this deleted user in their chat list
      final allUsersSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .get();

      for (var userDoc in allUsersSnapshot.docs) {
        if (userDoc.id == userId) continue; // Skip the deleted user

        // Check if this user has the deleted user in their my_users
        final myUsersRef = userDoc.reference.collection('my_users').doc(userId);
        final myUserDoc = await myUsersRef.get();

        if (myUserDoc.exists) {
          // Mark this chat as with deleted user
          batch.update(myUsersRef, {
            'user_deleted': true,
            'deletion_timestamp': DateTime.now().millisecondsSinceEpoch.toString(),
          });

          debugPrint('📱 Updated chat reference for user: ${userDoc.id}');
        }
      }

      // Step 3: Clean up user's own my_users collection
      final myUsersSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .collection('my_users')
          .get();

      for (var doc in myUsersSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Step 4: Clean up deleted_chats collection
      final deletedChatsSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .collection('deleted_chats')
          .get();

      for (var doc in deletedChatsSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Step 5: Update all active conversations to show deletion status
      final conversationsSnapshot = await FirebaseFirestore.instance
          .collection('Hamid_chats')
          .where('participants', arrayContains: userId)
          .get();

      for (var chatDoc in conversationsSnapshot.docs) {
        // Add a system message about user deletion
        final systemMessageRef = chatDoc.reference
            .collection('messages')
            .doc(DateTime.now().millisecondsSinceEpoch.toString());

        batch.set(systemMessageRef, {
          'fromId': 'SYSTEM',
          'toId': '',
          'msg': 'This user has deleted their account',
          'type': 'system',
          'sent': DateTime.now().millisecondsSinceEpoch.toString(),
          'read': '',
        });
      }

      // Commit all changes
      await batch.commit();

      debugPrint('✅ Complete Firebase cleanup completed successfully');

    } catch (e) {
      debugPrint('❌ Error in Firebase cleanup: $e');
      rethrow;
    }
  }

  // Enhanced chat user card detection method
  static Future<bool> isUserDeleted(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .get();

      if (!userDoc.exists) {
        return true; // User doesn't exist
      }

      final userData = userDoc.data()!;
      return userData['account_deleted'] == true;

    } catch (e) {
      debugPrint('Error checking if user is deleted: $e');
      return false;
    }
  }

  // Method to get user deletion timestamp
  static Future<String?> getUserDeletionTime(String userId) async {
    try {
      final userDoc = await FirebaseFirestore.instance
          .collection('Hamid_users')
          .doc(userId)
          .get();

      if (userDoc.exists && userDoc.data()!['account_deleted'] == true) {
        return userDoc.data()!['deleted_at'] as String?;
      }

      return null;
    } catch (e) {
      debugPrint('Error getting deletion time: $e');
      return null;
    }
  }

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
          .collection('Hamid_users')
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
          await getCurrentUserProfiles();
          String? newImageUrl = profileDetails.value.profileImage;

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

    final userRef = FirebaseFirestore.instance.collection('Hamid_users').doc('$uid');

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
}