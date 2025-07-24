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

  updateProfilePic({context, picData}) async {
    AppUtils.onLoading(Get.context!);
    final response = await userManagementUseCases.updateProfilePic(
      picData: picData,
    );
    return response.fold(
      (error) {
        AppUtils.dismissLoader(Get.context!);
        AppUtils.failedData(
          title: "Update Profile Image",
          message: "Update profile image is failed",
        );
      },
      (success) {
        AppUtils.dismissLoader(Get.context!);
        AppUtils.successData(
          title: "Update Profile Image",
          message: "Update profile image is changed successfully.",
        );
        getCurrentUserProfiles();
        update();
      },
    );
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

  // logout(BuildContext context) async {
  //   FirebaseService.updateActiveStatus(false);
  //   FirebaseService.insideChatStatus(false);
  //   await checkIfUserLogin();
  //   SharedPreferences prefs = await SharedPreferences.getInstance();
  //   await prefs.clear();
  //   Get.offNamed(AppRoutes.LOGIN);
  //   // Get.offAll(
  //   //   () => const LoginView(),
  //   //   binding: AppBindings(),
  //   // );
  // }
// Logout method with confirmation
  Future<void> handleLogout(BuildContext context) async {
    // Show confirmation dialog
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

    // if(is_web_online==true){
    //   is_mobile_online=false;
    // }else{
    //   is_mobile_online=false;
    //   is_online=false;
    //   last_active=update
    // }

    int? uid = userManagementUseCases.getUserId();

    final userRef = FirebaseFirestore.instance.collection('users').doc('$uid');

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
