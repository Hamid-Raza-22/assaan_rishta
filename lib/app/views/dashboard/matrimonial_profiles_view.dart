import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/matrimonial_profiles_viewmodel.dart';
import '../../widgets/export.dart';
import '../../core/routes/app_routes.dart';

class MatrimonialProfilesView extends GetView<MatrimonialProfilesController> {
  const MatrimonialProfilesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MatrimonialProfilesController>(
      initState: (_) {
        Get.put(MatrimonialProfilesController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size(double.infinity, 56),
            child: AppBar(
              backgroundColor: AppColors.primaryColor,
              elevation: 0,
              leading: IconButton(
                onPressed: () => Get.back(),
                icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              ),
              title: Text(
                "Matrimonial Profiles",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: () => controller.refreshProfiles(),
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  tooltip: "Refresh",
                ),
              ],
            ),
          ),
          body: _buildBody(context),
        );
      },
    );
  }

  Widget _buildBody(BuildContext context) {
    if (controller.isLoading.isTrue) {
      return _filterShimmer(context);
    }

    if (controller.isError.isTrue) {
      return _buildErrorState();
    }

    if (controller.profileList.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () => controller.refreshProfiles(),
      color: AppColors.primaryColor,
      child: ListView.builder(
        controller: controller.scrollController,
        itemCount: controller.profileList.length +
            (controller.isReloadMore.value ? 1 : 0),
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          if (index == controller.profileList.length) {
            return const SizedBox(
              height: 200,
              width: double.infinity,
              child: Align(
                alignment: Alignment.center,
                child: CircularProgressIndicator(
                  color: AppColors.primaryColor,
                ),
              ),
            );
          } else {
            return _profileItem(context, index);
          }
        },
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              "Something went wrong",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.errorMessage.value,

              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.fontLightColor,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Retry",
              isGradient: true,
              fontColor: AppColors.whiteColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              onTap: () => controller.refreshProfiles(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              "No Profiles Found",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "You haven't created any matrimonial profiles yet.",
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.fontLightColor,
              ),
            ),
            const SizedBox(height: 24),
            CustomButton(
              text: "Refresh",
              isGradient: true,
              fontColor: AppColors.whiteColor,
              fontWeight: FontWeight.w500,
              fontSize: 16,
              onTap: () => controller.refreshProfiles(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileItem(BuildContext context, int index) {
    ProfilesList user = controller.profileList[index];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 60),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: AppColors.profileContainerColor,
              borderRadius: const BorderRadius.all(
                Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.5),
                  spreadRadius: 3,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 74),
                    Text(
                      '${user.name}',
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Admin Created Badge
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppColors.primaryColor.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.verified_user,
                              size: 14,
                              color: AppColors.primaryColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              "Admin Created",
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // const SizedBox(height: 16),
                    // _buildInfoRow('Cast:', user.cast),
                    const SizedBox(height: 10),
                    _buildInfoRow('Status:', user.maritalStatus),
                    const SizedBox(height: 10),
                    _buildInfoRow('City:', user.cityName),
                    // const SizedBox(height: 10),
                    // _buildInfoRow('Job:', user.occupation),
                    // const SizedBox(height: 10),
                    // _buildInfoRow('Age:', user.age),
                    const SizedBox(height: 30),
                    CustomButton(
                      text: "View Profile",
                      isGradient: true,
                      fontColor: AppColors.whiteColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 18,
                      onTap: () {
                        Get.toNamed(AppRoutes.USER_DETAILS_VIEW,
                            arguments: user.userId);
                      },
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
            child: Column(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: AppColors.whiteColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withValues(alpha: 0.5),
                        spreadRadius: 3,
                        blurRadius: 7,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: BlurredProfileImage(
                      imageProvider: (user.profileImage != null &&
                              user.profileImage!.isNotEmpty)
                          ? NetworkImage(user.profileImage!) as ImageProvider
                          : AssetImage(
                              controller.getGenderBasedPlaceholder(user.gender),
                            ) as ImageProvider,
                      shouldBlur: user.blurProfileImage ?? false,
                      isCircular: true,
                      width: 90,
                      height: 90,
                      boxFit: BoxFit.cover,
                      blurSigma: 10.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: AppText(
            text: label,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: AppText(
            text: value ?? '-',
            fontSize: 16,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }

  Widget _filterShimmer(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        itemCount: 5,
        shrinkWrap: true,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemBuilder: (context, index) {
          return BannerPlaceholder(
            width: w,
            height: h * 0.30,
            borderRadius: 10,
          );
        },
      ),
    );
  }
}
