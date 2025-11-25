import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/libraries/image_loader/image_helper.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/exports.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../widgets/export.dart';
import 'export.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      initState: (_) {
        Get.put(ProfileController());
        controller.getProfileCompletionCount();
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(context),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              children: [
                getTopUserInfo(context),
                const SizedBox(height: 10),
                _getSettingsContainer(context: context),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  _appBar(BuildContext context) {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(isBack: false, title: "Profile"),
    );
  }

  getTopUserInfo(context) {
    if (controller.isLoading.isFalse) {
      return Stack(
        children: [
          Container(
            height: 165,
            margin: const EdgeInsets.only(top: 60),
            decoration: const BoxDecoration(
              color: AppColors.profileContainerColor,
              borderRadius: BorderRadius.all(Radius.circular(20)),
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 50),
                    AppText(
                      text: controller.getUserName(),
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          text:
                              'Complete Your Profile: ${controller.profileCompleteCount} %',
                          fontSize: 10,
                          fontWeight: FontWeight.w400,
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
                const Positioned(
                  left: 0,
                  right: 0,
                  top: -50,
                  child: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 40,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            child: DisplayImage(
              imagePath: controller.profileDetails.value.profileImage != null
                  ? controller.profileDetails.value.profileImage!
                  : AppAssets.imagePlaceholder,
              shouldBlur: controller.profileDetails.value.blurProfileImage ?? false,
              onPressed: () {
                _showCupertinoSheet(context);
              },
            ),
            // child: ClipRRect(
            //   borderRadius: BorderRadius.circular(30),
            //   child: GestureDetector(
            //     onTap: () {
            //       _showCupertinoSheet(context);
            //     },
            //     child: ImageHelper(
            //       image: controller.profileDetails.value.profileImage != null
            //           ? controller.profileDetails.value.profileImage!
            //           : AppAssets.imagePlaceholder,
            //       imageType:
            //           controller.profileDetails.value.profileImage != null
            //               ? ImageType.network
            //               : ImageType.asset,
            //       imageShape: ImageShape.circle,
            //       boxFit: BoxFit.contain,
            //       height: 90,
            //       width: 90,
            //     ),
            //   ),
            // ),
          ),
        ],
      );
    } else {
      return profileShimmer(context);
    }
  }

  Future<void> _showCupertinoSheet(context) async {
    showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        title: const AppText(
          text: 'Select Image',
          color: AppColors.blackColor,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        actions: <Widget>[
          CupertinoActionSheetAction(
            onPressed: () {
              controller.pickImage(context, ImageSource.camera);
              Navigator.of(context).pop();
            },
            child: const Text('Camera'),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              controller.pickImage(context, ImageSource.gallery);
              Navigator.of(context).pop();
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

  _getSettingsContainer({context}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: const BorderRadius.all(Radius.circular(10.0)),
        border: Border.all(
          width: 1.0,
          color: const Color.fromARGB(255, 234, 234, 234),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 20.0, top: 10),
            child: AppText(
              text: 'Others',
              color: AppColors.fontLightColor,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
          ClickableListTile(
            text: 'My Profile',
            icon: Icons.person_outline,
            onTap: () {
              Get.toNamed(AppRoutes.PROFILE_DETAIL_VIEW);
              // Get.to(
              //   () => const ProfileDetailsView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),
          // Blur Profile Toggle - Only for Female Users
          if (controller.profileDetails.value.gender?.toLowerCase() == 'female')
            Obx(() => InkWell(
              onTap: () {
                // Toggle on tap of entire tile
                final currentValue = controller.profileDetails.value.blurProfileImage ?? false;
                controller.toggleBlurProfileImage(!currentValue);
              },
              child: ListTile(
                leading: const Icon(
                  Icons.blur_on,
                  color: AppColors.greyColor,
                  size: 25,
                ),
                title: Text(
                  'Blur Profile Picture',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w400,
                    fontSize: 14,
                    color: AppColors.blackColor,
                  ),
                ),
                subtitle: Text(
                  'Hide your photo from others',
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey[600],
                  ),
                ),
                trailing: CupertinoSwitch(
                  value: controller.profileDetails.value.blurProfileImage ?? false,
                  onChanged: (value) {
                    controller.toggleBlurProfileImage(value);
                  },
                  activeColor: AppColors.primaryColor,
                ),
              ),
            )),
          ClickableListTile(
            text: 'Edit Profile',
            icon: Icons.edit_outlined,
            onTap: () {
              Get.toNamed(AppRoutes.PROFILE_EDIT_VIEW)!.then((onValue) {
                controller.getCurrentUserProfiles();
              });

              // Get.to(
              //   () => const EditProfileView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // )!
              //     .then((onValue) {
              //   controller.getCurrentUserProfiles();
              // });
            },
          ),
          ClickableListTile(
            text: 'Partner Preference',
            icon: Icons.person_add_alt_1_outlined,
            onTap: () {
              Get.toNamed(AppRoutes.PARTNER_PREFERENCE_VIEW);

              // Get.to(
              //   () => const PartnerPreferenceView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),
          ClickableListTile(
            text: 'Favorites',
            iconPath: AppAssets.icFavorites,
            imageType: ImageType.svg,
            onTap: () {
              Get.toNamed(AppRoutes.FAVORITES_VIEW);

              // Get.to(
              //   () => const FavoritesView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),
          ClickableListTile(
            text: 'Buy Connects',
            iconPath: AppAssets.icReferEarn,
            imageType: ImageType.svg,
            onTap: () =>
              Get.toNamed(AppRoutes.BUY_CONNECTS_VIEW)

              // Get.to(
              //   () => const BuyConnectsView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );

          ),
          ClickableListTile(
            text: 'Transaction History',
            icon: Icons.history,
            onTap: () {
              Get.toNamed(AppRoutes.TRANSACTION_HISTORY_VIEW, arguments: controller.getUserName());

              //   Get.to(
              //     () => const TransactionHistoryView(),
              //     binding: AppBindings(),
              //     transition: Transition.circularReveal,
              //     duration: const Duration(milliseconds: 500),
              //     arguments: controller.getUserName(),
              //   );
            },
          ),        ClickableListTile(
            text: 'Connects History',
            icon: Icons.history,
            onTap: () {
              Get.toNamed(AppRoutes.CONNECTS_HISTORY_VIEW, arguments: controller.getUserName());

              //   Get.to(
              //     () => const TransactionHistoryView(),
              //     binding: AppBindings(),
              //     transition: Transition.circularReveal,
              //     duration: const Duration(milliseconds: 500),
              //     arguments: controller.getUserName(),
              //   );
            },
          ),
          ClickableListTile(
            text: 'Change Password',
            icon: Icons.lock_outline,
            onTap: () {
              Get.toNamed(AppRoutes.CHANGE_PASSWORD_VIEW);

              // Get.to(
              //   () => const ChangePasswordView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),
          ClickableListTile(
            text: 'Contact Us',
            icon: Icons.contact_emergency_outlined,
            onTap: () {
              Get.toNamed(AppRoutes.CONTACT_US_VIEW);

              // Get.to(
              //   () => const ContactUsView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),
          ClickableListTile(
            text: 'About Us',
            iconPath: AppAssets.icTermsOfServices,
            imageType: ImageType.asset,
            onTap: () {
              Get.toNamed(AppRoutes.ABOUT_US_VIEW);

              // Get.to(
              //   () => const AboutUsView(),
              //   binding: AppBindings(),
              //   transition: Transition.circularReveal,
              //   duration: const Duration(milliseconds: 500),
              // );
            },
          ),

          ClickableListTile(
            text: 'Privacy Policy',
            icon: Icons.privacy_tip_outlined,
            onTap: () {
              Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE);

            },
          ),
          ClickableListTile(
            text: 'User Guide',
            iconPath: AppAssets.icTermsOfServices,
            imageType: ImageType.asset,
            onTap: () {
              Get.toNamed(AppRoutes.USER_GUIDE_VIEW);
            },
          ),
          // ClickableListTile(
          //   text: 'Delete Profile',
          //   textColor: AppColors.redColor,
          //   icon: Icons.delete_outline,
          //   onTap: () {
          //     onDeleteProfile(context);
          //   },
          // ),
          ClickableListTile(
            text: 'Deactivate Profile',
            textColor: AppColors.redColor,
            icon: Icons.power_settings_new,
            onTap: () {
              onDeactivateProfile(context);
            },
          ),
          ClickableListTile(
            text: 'Logout',
            iconPath: AppAssets.icLogout,
            imageType: ImageType.asset,
            textColor: AppColors.redColor,
            onTap: () {
              onLogout(context);
            },
          ),
          getVersionNameWidget(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Future<void> onDeactivateProfile(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          title: Text(
            "Deactivate Profile?",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to deactivate your profile? You can reactivate it anytime by logging in again.",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      Get.back();
                      controller.deactivateProfile();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: AppColors.redColor,
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.redColor),
                          ),
                          child: Text(
                            'Deactivate',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> onDeleteProfile(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          title: Text(
            "Delete Profile?",
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            "Are you sure you want to delete profile?",
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      controller.deleteProfile(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            // border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            'Delete',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Future<void> onLogout(BuildContext context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          elevation: 0.5,
          surfaceTintColor: Colors.white,
          title: const Text(
            "Log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: const Text(
            "Are you sure you want to log out?",
            style: TextStyle(
              fontFamily: 'Sora',
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Get.back();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            // border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      // Show confirmation dialog first (optional)
                        await controller.handleLogout(context);

                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Card(
                        elevation: 0.5,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(35)),
                        ),
                        child: Container(
                          alignment: Alignment.center,
                          height: MediaQuery.of(context).size.height * 0.065,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            // border: Border.all(color: Colors.grey.withValues(alpha: 0.5)),
                            borderRadius: BorderRadius.circular(35),
                            border: Border.all(color: AppColors.primaryColor),
                          ),
                          child: Text(
                            'Log Out',
                            style: GoogleFonts.poppins(
                              color: AppColors.whiteColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  // Optional: Logout confirmation dialog

  getVersionNameWidget() {
    return FutureBuilder(
      future: controller.getVersionNumber(),
      builder: (ctx, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.hasError) {
            return const Center(
              child: AppText(
                text: 'Version: 1.0.2',
                fontSize: 12,
                color: Colors.black,
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data as String;
            return Center(
              child: AppText(
                text: 'version: $data',
                fontSize: 12,
                color: Colors.black,
              ),
            );
          }
        }
        return const SizedBox.shrink();
      },
    );
  }

  profileShimmer(context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: BannerPlaceholder(width: w, height: h * 0.25, borderRadius: 10),
    );
  }
}
