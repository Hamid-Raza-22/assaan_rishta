import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

import '../core/base/export.dart';
import '../core/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import '../widgets/app_text.dart';
import 'dashboard_viewmodel.dart';
import 'profile_viewmodel.dart';

class MatrimonialProfilesController extends BaseController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  final scrollController = ScrollController();

  List<ProfilesList> profileList = [];
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxString errorMessage = ''.obs;
  
  final ImagePicker _picker = ImagePicker();

  int pageNo = 1;
  int totalCounts = 0;
  Rx<bool> isFirstLoad = true.obs;
  Rx<bool> isReloadMore = false.obs;

  int get adminId => userManagementUseCases.getUserId() ?? 0;

  @override
  void onInit() {
    super.onInit();
    _initApis();
  }

  void _initApis() {
    scrollController.addListener(_loadMoreData);
    getMatrimonialProfiles();
  }

  void _loadMoreData() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (totalCounts > profileList.length) {
        pageNo = pageNo + 1;
        isFirstLoad.value = false;
        isReloadMore.value = true;
        update();
        getMatrimonialProfiles(page: pageNo);
      }
    }
  }

  Future<void> getMatrimonialProfiles({int? page}) async {
    if (isFirstLoad.isTrue) {
      profileList = [];
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';
    }

    final response = await userManagementUseCases.getMatrimonialProfiles(
      adminId: adminId,
      // pageNo: page ?? 1,
      // pageLimit: 12,
    );

    response.fold(
      (error) {
        isLoading.value = false;
        isError.value = true;
        errorMessage.value = error.description ?? 'Failed to load profiles';
        isReloadMore.value = false;
        update();
      },
      (success) {
        totalCounts = success.totalRecords ?? 0;
        if (success.profilesList != null && success.profilesList!.isNotEmpty) {
          final filteredProfiles = success.profilesList!.where((profile) {
            final alreadyAdded = profileList
                .any((existing) => existing.userId == profile.userId);
            return !alreadyAdded;
          }).toList();

          profileList.addAll(filteredProfiles);
          isReloadMore.value = false;
        }
        if (isFirstLoad.isTrue) {
          isLoading.value = false;
        }
        isError.value = false;
        update();
      },
    );
  }

  Future<void> refreshProfiles() async {
    profileList.clear();
    pageNo = 1;
    isFirstLoad.value = true;
    update();
    await getMatrimonialProfiles();
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String getGenderBasedPlaceholder(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppAssets.imagePlaceholder;
    }
    
    final genderLower = gender.toLowerCase();
    if (genderLower == 'male') {
      return AppAssets.malePlaceholder;
    } else if (genderLower == 'female') {
      return AppAssets.femalePlaceholder;
    } else {
      return AppAssets.imagePlaceholder;
    }
  }

  /// Show professional delete confirmation dialog
  void showDeleteConfirmationDialog(BuildContext context, ProfilesList user) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 48,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Delete Profile',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              const SizedBox(height: 12),
              
              // User Info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                      backgroundImage: (user.profileImage != null && user.profileImage!.isNotEmpty)
                          ? NetworkImage(user.profileImage!)
                          : null,
                      child: (user.profileImage == null || user.profileImage!.isEmpty)
                          ? Icon(Icons.person, color: AppColors.primaryColor)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user.name ?? 'Unknown',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            'ID: ${user.userId}',
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: AppColors.fontLightColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              
              // Warning Message
              Text(
                'Are you sure you want to delete this profile? This action cannot be undone.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: AppColors.fontLightColor,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppColors.fontLightColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        _deleteProfile(context, user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        'Delete',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  /// Delete profile API call
  Future<void> _deleteProfile(BuildContext context, ProfilesList user) async {
    AppUtils.onLoading(context);
    
    try {
      // final response = await userManagementUseCases.deleteUserProfileById(
      // final response = await userManagementUseCases.deactivateUserProfile(
      final response = await userManagementUseCases.removeMatrimonialUser(
        userId: user.userId ?? 0,
      );
      
      response.fold(
        (error) {
          AppUtils.dismissLoader(context);
          AppUtils.failedData(
            title: "Delete Failed",
            message: error.description ?? "Failed to Delete profile. Please try again.",
          );
        },
        (success) {
          AppUtils.dismissLoader(context);
          
          // Remove from local list
          profileList.removeWhere((p) => p.userId == user.userId);
          update();
          
          // Show success message
          Get.snackbar(
            'Profile Deleted',
            '${user.name ?? "Profile"} has been Deleted successfully.',
            snackPosition: SnackPosition.TOP,
            backgroundColor: AppColors.greenColor,
            colorText: Colors.white,
            duration: const Duration(seconds: 3),
            margin: const EdgeInsets.all(10),
            borderRadius: 10,
            icon: const Icon(Icons.check_circle, color: Colors.white),
          );
        },
      );
    } catch (e) {
      AppUtils.dismissLoader(context);
      AppUtils.failedData(
        title: "Error",
        message: "An unexpected error occurred. Please try again.",
      );
      debugPrint('❌ Error deleting profile: $e');
    }
  }

  /// Show cupertino action sheet for image selection
  void showImagePickerSheet(BuildContext context, ProfilesList user) {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const AppText(
          text: 'Select Profile Image',
          color: AppColors.blackColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        message: Text(
          'Choose image for ${user.name ?? "User"}',
          style: const TextStyle(fontSize: 14),
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageForUser(user, ImageSource.camera);
            },
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              Navigator.of(context).pop();
              _pickImageForUser(user, ImageSource.gallery);
            },
            child: const Text('Gallery'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const AppText(text: 'Cancel', color: AppColors.redColor),
        ),
      ),
    );
  }

  /// Pick image for a specific user and upload via API
  Future<void> _pickImageForUser(ProfilesList user, ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 50,
      );
      
      if (pickedFile != null && user.userId != null) {
        // Convert image to base64
        final File imageFile = File(pickedFile.path);
        final List<int> imageBytes = await imageFile.readAsBytes();
        final String base64String = base64Encode(imageBytes);
        
        // Show loading
        AppUtils.onLoading(Get.context!);
        
        // Upload via API
        final response = await userManagementUseCases.updateUserProfilePic(
          picData: base64String,
          userId: user.userId!,
        );
        
        response.fold(
          (error) {
            AppUtils.dismissLoader(Get.context!);
            debugPrint('❌ Error updating profile image: ${error.description}');
            AppUtils.failedData(
              title: "Update Failed",
              message: "Failed to update profile image. Please try again.",
            );
          },
          (success) {
            AppUtils.dismissLoader(Get.context!);
            debugPrint('✅ Profile image updated for user ${user.userId}');
            
            // Refresh profiles to show updated image
            refreshProfiles();
            
            // Also refresh dashboard to update welcome card image
            if (Get.isRegistered<DashboardController>()) {
              final dashboardController = Get.find<DashboardController>();
              dashboardController.getUserProfile();
            }
            
            // Also refresh profile view to update profile image
            if (Get.isRegistered<ProfileController>()) {
              final profileController = Get.find<ProfileController>();
              profileController.getVendorOwnProfile();
            }
            
            Get.snackbar(
              'Image Updated',
              'Profile image updated for ${user.name ?? "User"}',
              snackPosition: SnackPosition.TOP,
              backgroundColor: AppColors.greenColor,
              colorText: Colors.white,
              duration: const Duration(seconds: 2),
              margin: const EdgeInsets.all(10),
              borderRadius: 10,
            );
          },
        );
      }
    } catch (e) {
      AppUtils.dismissLoader(Get.context!);
      debugPrint('❌ Error picking image: $e');
      AppUtils.failedData(
        title: "Error",
        message: "Failed to pick image. Please try again.",
      );
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
