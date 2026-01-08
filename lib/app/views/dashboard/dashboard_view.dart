import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/libraries/image_loader/image_helper.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/exports.dart';
import '../../viewmodels/dashboard_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<DashboardController>(
      initState: (_) {
        Get.put(DashboardController());
        controller.getUserProfile();
      },
      builder: (_) {
        return Scaffold(
          appBar: _appBar(context),
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(

            child: controller.isLoading.value
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primaryColor,
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () => controller.refreshDashboard(),
                    color: AppColors.primaryColor,
                    child: CustomScrollView(
                      slivers: [
                        // _buildAppBar(context),
                        SliverPadding(
                          padding: const EdgeInsets.all(16),
                          sliver: SliverList(
                            delegate: SliverChildListDelegate([
                              _buildWelcomeCard(context),
                              const SizedBox(height: 20),
                              // // _buildRegisterUserCard(context),
                              // const SizedBox(height: 20),
                              // _buildStatsSection(context),
                              const SizedBox(height: 20),
                              _buildQuickActions(context),
                              const SizedBox(height: 20),
                              _buildRecentActivity(context),
                              const SizedBox(height: 30),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
  _appBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: false,
        title: "Dashboard",
        actions: [
          // Obx(
          //   () => Padding(
          //     padding: const EdgeInsets.only(right: 15.0),
          //     child: FeaturedChip(
          //       isEnabled: controller.isFeaturedEnabled.value,
          //       onTap: () => controller.toggleFeatured(),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
  // SliverAppBar _buildAppBar(BuildContext context) {
  //   return SliverAppBar(
  //     expandedHeight: 60,
  //     floating: true,
  //     pinned: true,
  //     elevation: 0,
  //     backgroundColor: AppColors.primaryColor,
  //     automaticallyImplyLeading: false,
  //     title: Row(
  //       children: [
  //         Image.asset(
  //           AppAssets.appLogoPng,
  //           height: 40,
  //           width: 40,
  //         ),
  //         const SizedBox(width: 12),
  //         Text(
  //           "Dashboard",
  //           style: GoogleFonts.poppins(
  //             fontSize: 18,
  //             fontWeight: FontWeight.w600,
  //             color: Colors.white,
  //           ),
  //         ),
  //       ],
  //     ),
  //     actions: [
  //       IconButton(
  //         onPressed: () => controller.refreshDashboard(),
  //         icon: const Icon(Icons.refresh, color: Colors.white),
  //         tooltip: "Refresh",
  //       ),
  //       const SizedBox(width: 8),
  //     ],
  //   );
  // }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withBlue(180),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: CircleAvatar(
              radius: 32,
              backgroundColor: Colors.white,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                child: controller.userImage.isNotEmpty
                    ? ImageHelper(
                        image: controller.userImage,
                        imageType: ImageType.network,
                        height: 64,
                        width: 64,
                        boxFit: BoxFit.cover,
                      )
                    : ImageHelper(
                        image: AppAssets.imagePlaceholder,
                        imageType: ImageType.asset,
                        height: 64,
                        width: 64,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome back,",
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white.withOpacity(0.9),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  controller.userName.isNotEmpty ? controller.userName : "Admin",
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.userRole.isNotEmpty ? controller.userRole : "Administrator",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
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

  Widget _buildRegisterUserCard(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.green.shade600,
            Colors.green.shade400,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => controller.navigateToRegisterUser(),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.person_add_alt_1_rounded,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Register New User",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Create a new matrimonial profile using the app registration flow",
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "Statistics Overview",
              style: GoogleFonts.poppins(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.blackColor,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 14, color: AppColors.primaryColor),
                  const SizedBox(width: 4),
                  Text(
                    "Live",
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "Total Profiles",
                value: controller.totalProfiles.toString(),
                icon: Icons.people_alt_rounded,
                color: Colors.blue,
                bgColor: Colors.blue.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Active Users",
                value: controller.activeUsers.toString(),
                icon: Icons.verified_user_rounded,
                color: Colors.green,
                bgColor: Colors.green.shade50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: "New Registrations",
                value: controller.newRegistrations.toString(),
                icon: Icons.person_add_alt_rounded,
                color: Colors.orange,
                bgColor: Colors.orange.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: "Pending Approvals",
                value: controller.pendingApprovals.toString(),
                icon: Icons.hourglass_top_rounded,
                color: Colors.red,
                bgColor: Colors.red.shade50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.fontLightColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Quick Actions",
          style: GoogleFonts.poppins(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.blackColor,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.4,
          children: [
            _buildActionCard(
              title: "Register User",
              subtitle: "Add new profile",
              icon: Icons.person_add_alt_1_rounded,
              color: Colors.green,
              bgColor: Colors.green.shade50,
              onTap: () => controller.navigateToRegisterUser(),
            ),
            _buildActionCard(
              title: "My Profiles",
              subtitle: "View profiles",
              icon: Icons.people_alt_rounded,
              color: Colors.blue,
              bgColor: Colors.blue.shade50,
              onTap: () => Get.toNamed(AppRoutes.MATRIMONIAL_PROFILES),
            ),
            // _buildActionCard(
            //   title: "Approvals",
            //   subtitle: "Pending reviews",
            //   icon: Icons.task_alt_rounded,
            //   color: Colors.orange,
            //   bgColor: Colors.orange.shade50,
            //   onTap: () {
            //     // Navigate to approve profiles screen
            //   },
            // ),
            _buildActionCard(
              title: "My Profile",
              subtitle: "View profile",
              icon: Icons.person_rounded,
              color: Colors.purple,
              bgColor: Colors.purple.shade50,
              onTap: () => Get.toNamed(AppRoutes.PROFILE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation:10,
      shadowColor: Colors.grey,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(height: 10),
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Text(
                subtitle,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: AppColors.fontLightColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentActivity(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Recent Activity",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "View All",
                  style: GoogleFonts.poppins(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.fontLightColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildActivityItem(
            icon: Icons.person_add_alt_1_rounded,
            title: "New User Registered",
            description: "Dashboard created profile",
            time: "Just now",
            color: Colors.green,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.check_circle_rounded,
            title: "Profile Approved",
            description: "User verification completed",
            time: "2 hours ago",
            color: AppColors.primaryColor,
          ),
          const Divider(height: 24),
          _buildActivityItem(
            icon: Icons.favorite_rounded,
            title: "New Match",
            description: "Profiles matched successfully",
            time: "Yesterday",
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required String title,
    required String description,
    required String time,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppColors.fontLightColor,
                ),
              ),
            ],
          ),
        ),
        Text(
          time,
          style: GoogleFonts.poppins(
            fontSize: 11,
            fontWeight: FontWeight.w400,
            color: AppColors.fontLightColor,
          ),
        ),
      ],
    );
  }
}
