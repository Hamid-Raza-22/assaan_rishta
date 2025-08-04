// profile_viewmodel.dart - FIXED: Real-time Firebase image updates

import 'dart:convert';

import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:assaan_rishta/app/viewmodels/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/export.dart';
import '../core/services/firebase_service/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';

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

  // FIXED: Update Firebase chat collection when profile image changes
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

  ///Apis
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

  // FIXED: Update both backend API and Firebase chat collection
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
          // 1. Refresh profile to get new image URL
          await getCurrentUserProfiles();

          // 2. Extract new image URL from updated profile
          String? newImageUrl = profileDetails.value.profileImage;

          debugPrint('📱 Profile updated successfully');
          debugPrint('🔗 New image URL from API: $newImageUrl');

          // 3. Update Firebase chat collection if image URL is available
          if (newImageUrl != null && newImageUrl.isNotEmpty) {
            await updateFirebaseChatImage(newImageUrl);

            AppUtils.successData(
              title: "Update Profile Image",
              message: "Profile image updated successfully in chat and profile.",
            );
          } else {
            // Fallback: try to construct image URL or use base64
            debugPrint('⚠️ No image URL received, updating Firebase with constructed URL');

            // You might need to construct the URL based on your API response
            // Or use a default approach
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

          // Still show success since API update worked
          AppUtils.successData(
            title: "Update Profile Image",
            message: "Image updated but chat sync may need app restart.",
          );
        }

        update();
      },
    );
  }

  // Helper method to construct image URL from API response
  String _constructImageUrl(dynamic apiResponse) {
    try {
      // Adjust this based on your actual API response structure
      if (apiResponse is Map<String, dynamic>) {
        // Check common response patterns
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

      // If response is just a string URL
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

  // FIXED: Alternative method if you want to update Firebase immediately with base64
  updateProfilePicWithImmediateFirebaseSync({context, picData}) async {
    AppUtils.onLoading(Get.context!);

    try {
      // 1. First update Firebase with a temporary/placeholder approach
      final userId = userManagementUseCases.getUserId().toString();
      final tempTimestamp = DateTime.now().millisecondsSinceEpoch.toString();

      // 2. Update backend API
      final response = await userManagementUseCases.updateProfilePic(
        picData: picData,
      );

      await response.fold(
            (error) {
          AppUtils.dismissLoader(Get.context!);
          debugPrint('❌ Error updating profile image: $error');
          AppUtils.failedData(
            title: "Update Profile Image",
            message: "Update profile image failed",
          );
        },
            (success) async {
          // 3. Get updated profile with new image URL
          await getCurrentUserProfiles();

          // 4. Update Firebase with actual image URL
          String? newImageUrl = profileDetails.value.profileImage;

          if (newImageUrl != null && newImageUrl.isNotEmpty) {
            await updateFirebaseChatImage(newImageUrl);
          }

          AppUtils.dismissLoader(Get.context!);
          AppUtils.successData(
            title: "Update Profile Image",
            message: "Profile image updated successfully everywhere!",
          );
        },
      );

      update();

    } catch (e) {
      AppUtils.dismissLoader(Get.context!);
      debugPrint('❌ Error in complete image update: $e');
      AppUtils.failedData(
        title: "Update Profile Image",
        message: "Failed to update profile image",
      );
    }
  }

  deleteProfile(context) async {
    AppUtils.onLoading(context);
    final response = await userManagementUseCases.deleteUserProfile();
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
        debugPrint("error getting profile count");
      },
          (success) {
        AppUtils.dismissLoader(context);
        handleLogout(context);
      },
    );
  }

  Future<String> getVersionNumber() async {
    final PackageInfo info = await PackageInfo.fromPlatform();
    return info.version;
  }

  // Logout method with confirmation
  Future<void> handleLogout(BuildContext context) async {
    try {
      // Call the AuthService logout method
      await authService.logout(context);
    } catch (e) {
      // Hide loading
      Get.back();

      // Show error
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

    // FIXED: Use correct collection name for logout status
    final userRef = FirebaseFirestore.instance.collection('Hamid_users').doc('$uid');

    final snapshot = await userRef.get();
    final data = snapshot.data() ?? {};

    // Check if required keys exist
    final hasIsWebOnline = data.containsKey('is_web_online');
    final hasIsMobileOnline = data.containsKey('is_mobile_online');

    // If any key is missing, initialize all of them
    if (!hasIsWebOnline || !hasIsMobileOnline) {
      await userRef.set({
        'is_web_online': false,
        'is_mobile_online': false,
      }, SetOptions(merge: true));
    }

    // Then read the (updated) value of is_web_online
    final updatedSnapshot = await userRef.get();
    final updatedData = updatedSnapshot.data() ?? {};
    final isWebOnline = updatedData['is_web_online'] == true;

    // Perform update based on is_web_online
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