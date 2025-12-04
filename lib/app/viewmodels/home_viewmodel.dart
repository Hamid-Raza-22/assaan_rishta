import 'package:assaan_rishta/app/widgets/app_text.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

import '../core/export.dart';
import '../domain/export.dart';
import '../utils/app_colors.dart';
import '../utils/app_utils.dart';
import '../core/routes/app_routes.dart';

class HomeController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();

  final swiperController = SwiperController();

  ///for profile listing
  List<ProfilesList> profileList = [];
  List<ProfilesList> swipedItems = [];
  RxBool isLoading = false.obs;
  
  /// Featured toggle state
  RxBool isFeaturedEnabled = false.obs;

  ///for details
  RxBool isDetailsLoading = false.obs;
  var profileDetails = ProfileDetails().obs;

  /// pagination
  int currentPage = 1;
  int featuredCurrentPage = 1;

  /// Current user's gender
  String? currentUserGender;

  @override
  void onInit() {
    // Get current user's gender
    // getCurrentUserGender();
    _loadProfiles();
    super.onInit();
  }

  /// Toggle featured profiles on/off
  void toggleFeatured() {
    isFeaturedEnabled.value = !isFeaturedEnabled.value;
    _refreshProfiles();
  }

  /// Set featured state explicitly
  void setFeaturedEnabled(bool enabled) {
    if (isFeaturedEnabled.value != enabled) {
      isFeaturedEnabled.value = enabled;
      _refreshProfiles();
    }
  }

  /// Refresh profiles based on current featured state
  void _refreshProfiles() {
    profileList.clear();
    currentPage = 1;
    featuredCurrentPage = 1;
    update();
    _loadProfiles();
  }

  /// Load profiles based on featured toggle state
  void _loadProfiles({bool addNewCards = false, int? pageNumber}) {
    if (isFeaturedEnabled.value) {
      getAllFeaturedProfiles(addNewCards: addNewCards, pageNumber: pageNumber);
    } else {
      getAllProfiles(addNewCards: addNewCards, pageNumber: pageNumber);
    }
  }

  /// Get current user's gender from repository or local storage
  // void getCurrentUserGender() {
  //   // Yahan aap apne user repository se gender fetch karein
  //   // Example:
  //   // currentUserGender = userManagementUseCases.userManagementRepo.getUserGender();
  //   // Ya agar aap local storage use kar rahe hain:
  //   // currentUserGender = GetStorage().read('userGender');
  // }

  void handleIndexChanged(int index) {
    // Check if near the end of the list (length - 3 items) to load more
    if (index >= profileList.length - 5 && !isLoading.value) {
      _loadProfiles(addNewCards: true);
    }
  }

  ///Apis
  void getAllProfiles({bool addNewCards = false, int? pageNumber}) async {
    if (addNewCards == false) {
      isLoading.value = true;
    }

    final response = await userManagementUseCases.getAllProfiles(
      pageNo: pageNumber ?? currentPage,
      pageLimit: "20",
    );

    response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        if (success.profilesList != null && success.profilesList!.isNotEmpty) {
          if (addNewCards) {
            // Filter out profiles with duplicate IDs, current user, and apply gender filter
            final currentUserId =
                userManagementUseCases.userManagementRepo.getUserId();

            final newProfiles = success.profilesList!.where((profile) {
              if (profile.userId == currentUserId) {
                return false;
              }

              bool isNotDuplicate = !profileList.any(
                (existingProfile) => existingProfile.userId == profile.userId,
              );

              bool isOppositeGender = _isOppositeGender(profile.gender);
              return isNotDuplicate && isOppositeGender;
            }).toList();

            // Add only the unique profiles with opposite gender
            profileList.addAll(newProfiles);
          } else {
            // Initial load - filter by userId and gender
            profileList = success.profilesList!.where((element) {
              bool isNotCurrentUser =
                  element.userId !=
                  userManagementUseCases.userManagementRepo.getUserId();
              bool isOppositeGender = _isOppositeGender(element.gender);
              return isNotCurrentUser && isOppositeGender;
            }).toList();
          }
          currentPage++;
        }
        update();
        isLoading.value = false;
      },
    );
  }

  /// Get all featured profiles
  void getAllFeaturedProfiles({bool addNewCards = false, int? pageNumber}) async {
    if (addNewCards == false) {
      isLoading.value = true;
    }

    final response = await userManagementUseCases.getAllFeaturedProfiles(
      pageNo: pageNumber ?? featuredCurrentPage,
      pageLimit: "20",
    );

    response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        if (success.profilesList != null && success.profilesList!.isNotEmpty) {
          if (addNewCards) {
            // Filter out profiles with duplicate IDs, current user, and apply gender filter
            final currentUserId =
                userManagementUseCases.userManagementRepo.getUserId();

            final newProfiles = success.profilesList!.where((profile) {
              if (profile.userId == currentUserId) {
                return false;
              }

              bool isNotDuplicate = !profileList.any(
                (existingProfile) => existingProfile.userId == profile.userId,
              );

              bool isOppositeGender = _isOppositeGender(profile.gender);
              return isNotDuplicate && isOppositeGender;
            }).toList();

            // Add only the unique profiles with opposite gender
            profileList.addAll(newProfiles);
          } else {
            // Initial load - filter by userId and gender
            profileList = success.profilesList!.where((element) {
              bool isNotCurrentUser =
                  element.userId !=
                  userManagementUseCases.userManagementRepo.getUserId();
              bool isOppositeGender = _isOppositeGender(element.gender);
              return isNotCurrentUser && isOppositeGender;
            }).toList();
          }
          featuredCurrentPage++;
        }
        update();
        isLoading.value = false;
      },
    );
  }

  /// Check if the profile gender is opposite to current user's gender
  bool _isOppositeGender(String? profileGender) {
    if (profileGender == null || profileGender.trim().isEmpty) {
      return false;
    }

    if (currentUserGender == null || currentUserGender!.trim().isEmpty) {
      return true; // Agar current user ka gender nahi mila to sab dikhao
    }

    String userGenderLower = currentUserGender!.toLowerCase();
    String profileGenderLower = profileGender.toLowerCase();

    // Male user ko female profiles dikhao
    if (userGenderLower == 'male') {
      return profileGenderLower == 'female';
    }
    // Female user ko male profiles dikhao
    else if (userGenderLower == 'female') {
      return profileGenderLower == 'male';
    }

    return true; // Default case
  }

  addFavorite(context, index, favUid) async {
    final bool isLoggedIn = userManagementUseCases.userManagementRepo
        .getUserLoggedInStatus();

    if (!isLoggedIn) {
      Get.dialog(
        AlertDialog.adaptive(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          title: const AppText(text: 'Login Required'),
          content: const Text('Please login to add profiles to Favorites.'),
          actions: [
            TextButton(
              onPressed: () => Get.back(),
              child: const AppText(text: 'Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Get.back();
                Get.toNamed(AppRoutes.LOGIN);
              },
              child: const AppText(text: 'Login'),
            ),
          ],
        ),
        barrierDismissible: true,
      );
      return;
    }

    AppUtils.onLoading(context);
    final response = await userManagementUseCases.addToFavorites(
      favUid: favUid,
    );
    return response.fold(
      (error) {
        AppUtils.dismissLoader(context);
      },
      (success) {
        AppUtils.dismissLoader(context);
        if (success.isNotEmpty) {
          if (profileList[index].favourite == "yes") {
            profileList[index].favourite = "no";
            AppUtils.successData(
              title: "Favorite",
              message: "Remove from favorite successfully.",
            );
          } else if (profileList[index].favourite == "no") {
            profileList[index].favourite = "yes";
            AppUtils.successData(
              title: "Favorite",
              message: "Add to favorite successfully.",
            );
          }
        }
        update();
      },
    );
  }
}
