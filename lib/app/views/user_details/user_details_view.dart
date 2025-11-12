// Updated user_details_view.dart
import 'package:flutter/services.dart'; // For Clipboard
// Optional: import 'package:share_plus/share_plus.dart'; // If you fix the plugin
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';
import '../../core/export.dart';
import '../../core/routes/app_routes.dart';
import '../../viewmodels/auth_service.dart';
import '../../viewmodels/profile_viewmodel.dart';
import '../../data/providers/auth_provider.dart';
import '../../utils/exports.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../widgets/export.dart';

import '../profile/export.dart';

class UserDetailsView extends GetView<UserDetailsController> {
  const UserDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    debugPrint("Building UserDetailsView with arguments: ${Get.arguments}");
    
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 40),
        child: CustomAppBar2(isBack: true),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return userDetailsShimmer(context);
        }

        // Check if user details are valid
        if (controller.profileDetails.value.firstName == null || controller.profileDetails.value.lastName == null) {
          return const Center(
            child: AppText(
              text: "User not found",
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: AppColors.greyColor,
            ),
          );
        }

        return ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: [
            getProfileImage(context),
            const SizedBox(height: 10),
            getVideoInfo(),
            const SizedBox(height: 10),
            getProfileInfo(),
            const SizedBox(height: 10),
            getPartnerPreferences(),
            const SizedBox(height: 20),
          ],
        );
      }),
    );
  }

  Widget userDetailsShimmer(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: [
          // Avatar + header block
          const SizedBox(height: 60),
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            height: 245,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name line
                Align(
                  alignment: Alignment.center,
                  child: Container(width: w * 0.5, height: 20, color: Colors.white),
                ),
                const SizedBox(height: 20),
                // Buttons placeholder
                Row(
                  children: [
                    Expanded(
                      child: Container(height: 48, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30))),
                    ),
                    const SizedBox(width: 12),
                    Container(width: 40, height: 40, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          // Video block
          Container(
            height: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          const SizedBox(height: 12),
          // General information block
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: List.generate(4, (i) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: w * 0.35, height: 14, color: Colors.white),
                      Container(width: w * 0.35, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          // Partner preferences block
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: List.generate(4, (i) =>
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(width: w * 0.35, height: 14, color: Colors.white),
                      Container(width: w * 0.35, height: 14, color: Colors.white),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  getProfileImage(context) {
    // Check if user is logged in
    bool isLoggedIn = controller.useCase.userManagementRepo
        .getUserLoggedInStatus();

    return Stack(
      children: [
        Container(
          height: 245, // Increased height to accommodate login text
          margin: const EdgeInsets.only(top: 60),
          decoration: const BoxDecoration(
            color: AppColors.profileContainerColor,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 55),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text:
                        '${controller.profileDetails.value.firstName} ${controller.profileDetails.value.lastName}',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  // Two buttons in a row - Message and Share
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        // Message Button
                        Expanded(
                          flex: 2,
                          child: isLoggedIn
                              ? _buildLoggedInMessageButton(context)
                              : _buildGuestMessageButton(context),
                        ),
                        // const SizedBox(width: 10),
                        // // Share Button
                        // Expanded(
                        //   flex: 1,
                        //   child: _buildShareButton(context),
                        // ),
                      ],
                    ),
                  ),

                  // Login prompt text for guest users
                  if (!isLoggedIn) ...[
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Please signup or login to activate messaging",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              // Share button positioned at top right corner
              Positioned(
              top: 10,
              right: 10,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: PopupMenuButton<String>(

                  padding: const EdgeInsets.all(4),
                  icon: const Icon(
                    Icons.more_vert,
                    color: AppColors.primaryColor,
                    size: 22,
                  ),
                  onSelected: (value) {
                    if (value == 'share') {
                      _shareProfile(context);
                    } else if (value == 'report') {
                      _reportProfile();
                    }
                  },
                  itemBuilder: (context) => [
                    // ADDED: Popup background color
                    PopupMenuItem<String>(
                      value: 'share',
                      child: Row(
                        children: [
                          const Icon(Icons.share, size: 18,),
                          const SizedBox(width: 8),
                          Text('Share', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'report',
                      child: Row(
                        children: [
                          const Icon(Icons.flag_outlined, size: 18),
                          const SizedBox(width: 8),
                          Text('Report', style: GoogleFonts.poppins()),
                        ],
                      ),
                    ),
                  ],
                  color: AppColors.whiteColor, // ADDED: Set background color to white
                ),
              ),
            ),
              const Positioned(
                left: 0,
                right: 0,
                top: -50,
                child: CircleAvatar(backgroundColor: Colors.white, radius: 40),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: ImageHelper(
            image: controller.profileDetails.value.profileImage != null
                ? controller.profileDetails.value.profileImage!
                : AppAssets.imagePlaceholder,
            imageType: controller.profileDetails.value.profileImage != null
                ? ImageType.network
                : ImageType.asset,
            imageShape: ImageShape.circle,
            boxFit: BoxFit.contain,
            height: 90,
            width: 90,
          ),
        ),
      ],
    );
  }


  void _shareProfile(BuildContext context) async {
    final bool isLoggedIn =
        controller.useCase.userManagementRepo.getUserLoggedInStatus();

    if (!isLoggedIn) {
      Get.dialog(
        AlertDialog.adaptive(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          title: const AppText(text: 'Login Required'),
          content: const Text('Please login to Share profile.'),
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

    final profileName = '${controller.profileDetails.value.firstName}-${controller.profileDetails.value.lastName}';
    final age = controller.profileDetails.value.age ?? '--';
    final city = controller.profileDetails.value.cityName ?? '--';
    final education = controller.profileDetails.value.education ?? '--';
    final occupation = controller.profileDetails.value.occupation ?? '--';
    final profileId = controller.profileDetails.value.userId;

    // Replace spaces with hyphens for URL-friendly name
    final urlFriendlyName = profileName.replaceAll(' ', '-');

    // Show loading indicator
    Get.dialog(
      const Center(
        child: CircularProgressIndicator(
          color: AppColors.primaryColor,
        ),
      ),
      barrierDismissible: false,
    );

    String shareText = '''
🌟 Check out this profile on Assaan Rishta!

👤 Name: $profileName
📅 Age: $age
📍 Location: $city
🎓 Education: $education
💼 Occupation: $occupation
''';

    // Add deep link
    if (profileId != null) {
      // IMPORTANT: Using correct domain - asaanrishta.co
      shareText += '''

📱 Open Profile in App:
https://asaanrishta.com/rishta/$urlFriendlyName/$profileId
''';
    }

    // Add app download link
    shareText += '''

Don't have the app? Download now:
📲 Android: https://play.google.com/store/apps/details?id=com.asan.rishta.matrimonial.asan_rishta
''';

    // Close loading dialog
    Get.back();

    // Share using share_plus
    try {
      await Share.share(
        shareText,
        subject: 'Profile from Assaan Rishta - $profileName',
      );

      // Track share event (optional)
      debugPrint('Profile shared successfully: $profileId');

    } catch (e) {
      debugPrint("Error sharing profile: $e");
      Get.snackbar(
        'Error',
        'Could not share profile. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _reportProfile() {
    final bool isLoggedIn =
        controller.useCase.userManagementRepo.getUserLoggedInStatus();

    if (!isLoggedIn) {
      Get.dialog(
        AlertDialog.adaptive(
          backgroundColor: AppColors.whiteColor,
          surfaceTintColor: AppColors.whiteColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),

          title: const AppText(text: 'Login Required'),
          content: const Text('Please login to Report profiles.'),
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

    final reportedId = controller.profileDetails.value.userId?.toInt() ?? 0;
    final messageController = TextEditingController();
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    // Prefill from logged-in user profile
    try {
      final auth = AuthService.instance;
      final profileCtrl = Get.isRegistered<ProfileController>() ? Get.find<ProfileController>() : null;
      final currentName = auth.userName ?? profileCtrl?.getUserName() ?? '';
      final currentPhone = profileCtrl?.profileDetails.value.mobileNo ?? '';
      if (currentName.isNotEmpty) nameController.text = currentName;
      if (currentPhone != 'null' && currentPhone.isNotEmpty) phoneController.text = currentPhone;
    } catch (_) {}

    showDialog(
      context: Get.context!,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text('Report Profile', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: messageController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Reason/Message',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                // TextField(
                //   controller: nameController,
                //   decoration: const InputDecoration(
                //     labelText: 'Your Name',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
                // const SizedBox(height: 12),
                // TextField(
                //   controller: phoneController,
                //   keyboardType: TextInputType.phone,
                //   decoration: const InputDecoration(
                //     labelText: 'Your Phone Number',
                //     border: OutlineInputBorder(),
                //   ),
                // ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: Text('Cancel', style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (messageController.text.trim().isEmpty ||
                    nameController.text.trim().isEmpty ||
                    phoneController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Missing Info',
                    'Please fill all fields.',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                Navigator.of(ctx).pop();

                Get.dialog(
                  const Center(child: CircularProgressIndicator(color: AppColors.primaryColor)),
                  barrierDismissible: false,
                );

                try {
                  final provider = Get.put(AuthProvider());
                  final nowIso = DateTime.now().toUtc().toIso8601String();
                  final res = await provider.reportUser(
                    message: messageController.text.trim(),
                    reporterNumber: phoneController.text.trim(),
                    reporterName: nameController.text.trim(),
                    reportDateIso: nowIso,
                    reportedUserId: reportedId,
                  );

                  Get.back();

                  if (res.isOk) {
                    Get.snackbar(
                      'Report Submitted',
                      'Thanks! We have received your report.',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  } else {
                    Get.snackbar(
                      'Error',
                      'Could not submit report. Please try again.',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: AppColors.redColor,
                      colorText: AppColors.whiteColor,
                    );
                  }
                } catch (e) {
                  Get.back();
                  Get.snackbar(
                    'Error',
                    'Something went wrong. Please try again.',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.redColor,
                    colorText: AppColors.whiteColor,
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
              child: Text('Submit', style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.w600)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoggedInMessageButton(BuildContext context) {
    return CustomButton(
      text: "Message",
      isGradient: true,
      fontColor: AppColors.whiteColor,
      fontWeight: FontWeight.w500,
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ImageHelper(
          image: AppAssets.icChat,
          imageType: ImageType.asset,
          color: AppColors.whiteColor,
          height: 24,
          width: 24,
        ),
      ),
      fontSize: 18,
      onTap: () {
        if (controller.totalConnects.value > 0) {
          controller.sendMessageToOtherUser(context);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppColors.whiteColor,
                title: Text(
                  'No Connects',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                content: Text(
                  'You don\'t have any connects left. Please purchase more to continue.',
                  style: GoogleFonts.poppins(fontSize: 14),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.to(() => const BuyConnectsView());
                    },
                    child: Text(
                      'Purchase',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  Widget _buildGuestMessageButton(BuildContext context) {
    return CustomButton(
      text: "Login to Message",
      isGradient: true,
      fontColor: AppColors.whiteColor,
      fontWeight: FontWeight.w500,
      prefixIcon: const Padding(
        padding: EdgeInsets.only(right: 8.0),
        child: Icon(Icons.lock, color: AppColors.whiteColor, size: 24),
      ),
      fontSize: 18,
      onTap: () {
        controller.navigateToLogin();
      },
    );
  }
  getProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "General Information",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.info, color: AppColors.greenColor),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Name',
                subtitle:
                    '${controller.profileDetails.value.firstName} ${controller.profileDetails.value.lastName}',
              ),
              getListTile(
                title: 'Gender',
                subtitle: controller.profileDetails.value.gender ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Age',
                subtitle: '${controller.profileDetails.value.age ?? "--"}',
              ),
              getListTile(
                title: 'Caste',
                subtitle: controller.profileDetails.value.cast ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Religion',
                subtitle: controller.profileDetails.value.religion ?? "--",
              ),
              getListTile(
                title: 'Marriage Status',
                subtitle: controller.profileDetails.value.maritalStatus ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Education',
                subtitle: controller.profileDetails.value.education ?? "--",
              ),
              getListTile(
                title: 'Occupation',
                subtitle: controller.profileDetails.value.occupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Height',
                subtitle: '${controller.profileDetails.value.height}',
              ),
              getListTile(
                title: 'Country',
                subtitle: '${controller.profileDetails.value.userCountryName}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'State',
                subtitle: '${controller.profileDetails.value.userStateName}',
              ),
              getListTile(
                title: 'City',
                subtitle: '${controller.profileDetails.value.cityName}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'About Me',
                subtitle: controller.profileDetails.value.userKaTaruf ?? "--",
              ),
              getListTile(
                title: 'About Life Partner',
                subtitle:
                    controller.profileDetails.value.userDiWohtiKaTaruf ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Updated getVideoInfo method with proper video handling
  // Updated getVideoInfo method with proper video handling and thumbnail support
  getVideoInfo() {
    bool hasTiktokLink =
        controller.profileDetails.value.tiktokLink != null &&
        controller.profileDetails.value.tiktokLink!.isNotEmpty;

    debugPrint("Video URL: ${controller.profileDetails.value.tiktokLink}");

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "Video Preview",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.videocam, color: AppColors.greenColor),
            ],
          ),
          const SizedBox(height: 10),
          if (hasTiktokLink)
            Center(child: _buildVideoPreview())
          else
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: AppText(
                  text: "No video preview available.",
                  color: AppColors.greyColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Enhanced video preview widget
  Widget _buildVideoPreview() {
    String videoUrl = controller.profileDetails.value.tiktokLink!;

    return Container(
      height: 550,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: GetBuilder<UserDetailsController>(
          id: 'video_player',
          builder: (controller) {
            // Prefer pre-fetched thumbnail while player warms up
            return GetBuilder<UserDetailsController>(
              id: 'video_thumb',
              builder: (_) {
                final thumb = controller.videoThumbnailData.value;
                final isThumbLoading = controller.isVideoThumbLoading.value;

                // When controller is initialized, show the player
                if (controller.videoController?.value.isInitialized == true) {
                  return _buildVideoPlayerWidget();
                }

                // If we have a thumbnail, show it with a play overlay
                if (thumb != null && thumb.isNotEmpty) {
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.memory(thumb, fit: BoxFit.cover),
                      Container(color: Colors.black26),
                      Center(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(16),
                          child: const Icon(Icons.play_arrow, color: Colors.white, size: 40),
                        ),
                      ),
                    ],
                  );
                }

                // Show lightweight shimmer-like placeholder
                if (isThumbLoading) {
                  return _buildThumbnailLoading();
                }

                // Fallback to generic link or error
                if (_isTikTokUrl(videoUrl)) {
                  return _buildTikTokPreview(videoUrl);
                }
                if (controller.isDirectVideoUrl(videoUrl)) {
                  return _buildLoadingWidget();
                }
                return _buildGenericVideoLink(videoUrl);
              },
            );
          },
        ),
      ),
    );
  }

  // Check if URL is TikTok
  bool _isTikTokUrl(String url) {
    return url.contains('tiktok.com') || url.contains('vm.tiktok.com');
  }

  // Generic video link widget
  Widget _buildGenericVideoLink(String videoUrl) {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.video_library,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            text: "Video Link",
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AppText(
              text: _truncateUrl(videoUrl),
              fontSize: 12,
              color: AppColors.greyColor,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () => _openVideoExternally(videoUrl),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text('Open Video', style: GoogleFonts.poppins(fontSize: 14)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Video player widget with controls
  Widget _buildVideoPlayerWidget() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Video player
        SizedBox(
          width: double.infinity,
          height: 250,
          child: FittedBox(
            fit: BoxFit.cover,
            child: SizedBox(
              width: controller.videoController!.value.size.width,
              height: controller.videoController!.value.size.height,
              child: VideoPlayer(controller.videoController!),
            ),
          ),
        ),

        // Play/Pause overlay
        GestureDetector(
          onTap: () {
            controller.toggleVideoPlayback();
          },
          child: Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(16),
            child: Icon(
              controller.videoController!.value.isPlaying
                  ? Icons.pause
                  : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
          ),
        ),

        // Video progress indicator at bottom
        Positioned(
          bottom: 10,
          left: 10,
          right: 10,
          child: Container(
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2),
            ),
            child: GetBuilder<UserDetailsController>(
              id: 'video_progress',
              builder: (controller) {
                if (controller.videoController?.value.isInitialized == true) {
                  final progress =
                      controller
                          .videoController!
                          .value
                          .position
                          .inMilliseconds /
                      controller.videoController!.value.duration.inMilliseconds;
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress.clamp(0.0, 1.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ),

        // Mute/Unmute button
        Positioned(
          top: 10,
          right: 10,
          child: GestureDetector(
            onTap: () {
              controller.toggleVideoMute();
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: Icon(
                controller.videoController!.value.volume > 0
                    ? Icons.volume_up
                    : Icons.volume_off,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Loading widget
  Widget _buildLoadingWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          AppText(text: "Loading video...", color: AppColors.greyColor),
        ],
      ),
    );
  }

  // Error widget with thumbnail fallback
  Widget _buildErrorWidget(String videoUrl) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Video thumbnail placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primaryColor.withOpacity(0.3),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.video_library,
              size: 40,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            text: "Video Preview Not Available",
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.greyColor,
          ),
          const SizedBox(height: 8),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: AppText(
              text: "Tap below to open video externally",
              fontSize: 12,
              color: AppColors.greyColor,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),

          // External link button
          ElevatedButton.icon(
            onPressed: () {
              _openVideoExternally(videoUrl);
            },
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(
              _getVideoSourceLabel(videoUrl),
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTikTokPreview(String tiktokUrl) {
    return Container(
      height: 250,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FutureBuilder<Uint8List?>(
          future: controller.getVideoThumbnailData(tiktokUrl),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _buildThumbnailLoading();
            } else if (snapshot.hasData && snapshot.data != null) {
              return _buildThumbnailWithImage(snapshot.data!, tiktokUrl);
            } else {
              return _buildThumbnailFallback(tiktokUrl);
            }
          },
        ),
      ),
    );
  }
// Loading state for thumbnail
  Widget _buildThumbnailLoading() {
    return Container(
      color: Colors.grey[900],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primaryColor),
          SizedBox(height: 16),
          AppText(
            text: "Loading thumbnail...",
            color: Colors.white,
            fontSize: 14,
          ),
        ],
      ),
    );
  }

// Thumbnail with actual image
  Widget _buildThumbnailWithImage(Uint8List thumbnailData, String videoUrl) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Thumbnail image
        Container(
          width: double.infinity,
          height: 250,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: MemoryImage(thumbnailData),
              fit: BoxFit.cover,
            ),
          ),
        ),

        // Dark overlay
        Container(
          color: Colors.black.withOpacity(0.3),
        ),

        // Play button overlay
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.6),
            shape: BoxShape.circle,
          ),
          padding: const EdgeInsets.all(20),
          child: const Icon(
            Icons.play_arrow,
            color: Colors.white,
            size: 50,
          ),
        ),

        // TikTok label
        Positioned(
          top: 15,
          left: 15,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.video_library,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  'TikTok',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Open button
        // Positioned(
        //   bottom: 15,
        //   right: 15,
        //   child: ElevatedButton.icon(
        //     onPressed: () => _openTikTokVideo(videoUrl),
        //     icon: const Icon(Icons.open_in_new, size: 18),
        //     label: Text(
        //       'Open',
        //       style: GoogleFonts.poppins(fontSize: 14),
        //     ),
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: AppColors.primaryColor,
        //       foregroundColor: Colors.white,
        //       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(25),
        //       ),
        //     ),
        //   ),
        // ),

        // Tap to open gesture
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _openTikTokVideo(videoUrl),
            child: Container(color: Colors.transparent),
          ),
        ),
      ],
    );
  }

// Fallback when thumbnail loading fails
  Widget _buildThumbnailFallback(String videoUrl) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.withOpacity(0.8),
            Colors.pink.withOpacity(0.8),
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.video_library,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            "TikTok Video",
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Tap to open in TikTok app",
            style: GoogleFonts.poppins(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => _openTikTokVideo(videoUrl),
            icon: const Icon(Icons.open_in_new, size: 18),
            label: Text(
              'Open TikTok',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.purple,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
          ),
        ],
      ),
    );
  }
  String _truncateUrl(String url) {
    if (url.length > 50) {
      return '${url.substring(0, 25)}...${url.substring(url.length - 20)}';
    }
    return url;
  }

  // Helper method to get video source label
  String _getVideoSourceLabel(String url) {
    if (url.contains('tiktok.com')) {
      return 'Open TikTok';
    } else if (url.contains('youtube.com') || url.contains('youtu.be')) {
      return 'Open YouTube';
    } else if (url.contains('instagram.com')) {
      return 'Open Instagram';
    } else {
      return 'Open Video';
    }
  }

  void _openTikTokVideo(String url) {
    // Add url_launcher dependency and implement
    launchUrl(Uri.parse(url));
    debugPrint("Opening TikTok URL: $url");
  }

  // Method to open video externally
  void _openVideoExternally(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

    } catch (e) {
      debugPrint("Error opening video URL: $e");
      Get.snackbar(
        'Error',
        'Unable to open video link',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: AppColors.redColor,
        colorText: AppColors.whiteColor,
      );
    }
  }

  getFamilyInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "Family Details",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.info, color: AppColors.greenColor),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Living',
                subtitle: controller.profileDetails.value.lifeStyle ?? "--",
              ),
              getListTile(
                title: 'Parent Country',
                subtitle:
                    controller.profileDetails.value.parentCountryName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Parent State',
                subtitle:
                    controller.profileDetails.value.parentStateName ?? "--",
              ),
              getListTile(
                title: 'Parent City',
                subtitle:
                    controller.profileDetails.value.parentCityName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Father Alive',
                subtitle: getStringBool(
                  controller.profileDetails.value.fatherAlive,
                ),
              ),
              getListTile(
                title: 'Father\'s Occupation',
                subtitle:
                    controller.profileDetails.value.fatherOccupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Alive',
                subtitle: getStringBool(
                  controller.profileDetails.value.motherAlive,
                ),
              ),
              getListTile(
                title: 'Mother Occupation',
                subtitle:
                    controller.profileDetails.value.motherOccupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Tounge',
                subtitle: controller.profileDetails.value.motherTounge ?? "--",
              ),
              getListTile(
                title: 'Siblings',
                subtitle: getStringBool(
                  controller.profileDetails.value.silings,
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Number Of Brothers',
                subtitle: controller.profileDetails.value.noOfBrother
                    .toString(),
              ),
              getListTile(
                title: 'Number Of Sisters ',
                subtitle: controller.profileDetails.value.noOfSister.toString(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Married Brothers',
                subtitle: controller.profileDetails.value.marriedBrother
                    .toString(),
              ),
              getListTile(
                title: 'Married Sisters',
                subtitle: controller.profileDetails.value.marriedSister
                    .toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getPartnerPreferences() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "Partner Preference",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(Icons.info, color: AppColors.greenColor),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Age',
                subtitle:
                    '${controller.profileDetails.value.partnerAgeFrom ?? "-"} from ${controller.profileDetails.value.partnerAgeTo ?? "-"}',
              ),
              getListTile(
                title: 'Languages',
                subtitle:
                    controller.profileDetails.value.partnerLanguages ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Caste',
                subtitle: controller.profileDetails.value.partnerCaste,
              ),
              getListTile(
                title: 'Education',
                subtitle: controller.profileDetails.value.partnerEducation,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Occupation',
                subtitle: controller.profileDetails.value.partnerOccupation,
              ),
              getListTile(
                title: 'Monthly Income',
                subtitle: controller.profileDetails.value.partnerAnnualIncome,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Tongue',
                subtitle: controller.profileDetails.value.partnerMotherTounge,
              ),
              getListTile(
                title: 'Religion',
                subtitle: controller.profileDetails.value.partnerReligion,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Height',
                subtitle: controller.profileDetails.value.partnerHeight,
              ),
              getListTile(
                title: 'Built',
                subtitle: controller.profileDetails.value.partnerBuilt,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Complexion',
                subtitle: controller.profileDetails.value.partnerComplexion,
              ),
              getListTile(
                title: 'Marital Status ',
                subtitle:
                    controller.profileDetails.value.partnerMaritalStatus ??
                    "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // getListTile(
              //   title: 'Drinking',
              //   subtitle: _getYesNoFromBoolString(controller.profileDetails.value.partnerDrinkHabbit),
              // ),
              getListTile(
                title: 'Smoking',
                subtitle: _getYesNoFromBoolString(controller.profileDetails.value.partnerSmokeHabbit),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'About Partner',
                subtitle: controller.profileDetails.value.aboutPartner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStringBool(bool? value) {
    if (value != null) {
      if (value) {
        return "Yes";
      } else {
        return "No";
      }
    } else {
      return "No";
    }
  }

  String _getYesNoFromBoolString(String? value) {
    if (value == null) return "--";
    if (value.toLowerCase() == 'true') {
      return "Yes";
    } else if (value.toLowerCase() == 'false') {
      return "No";
    }
    return value; // Return original value if not 'true' or 'false'
  }

}
