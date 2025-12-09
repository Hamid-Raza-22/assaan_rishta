import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/export.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/exports.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../widgets/export.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      initState: (_) {
        Get.put(HomeController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(context),
          body: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 5),
                Obx(
                      () => Flexible(
                    child: controller.isLoading.isFalse
                        ? Swiper(
                      controller: controller.swiperController,
                      itemCount: controller.profileList.length,
                      layout: SwiperLayout.STACK,
                      itemWidth: Get.width * 0.90,
                      itemHeight: Get.height,
                      control: const SwiperControl(
                        color: AppColors.primaryColor,
                        size: 0,
                      ),
                      autoplay: false,
                      loop: false,
                      onIndexChanged: (index) {
                        controller.handleIndexChanged(index);
                      },
                      itemBuilder: (context, index) {
                        return getCartItem(context, index);
                      },
                    )
                        : homeShimmer(context),
                  ),
                ),
                const SizedBox(height: 20),
              ],
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
        title: "Home",
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

  getCartItem(context, index) {
    final ProfilesList user = controller.profileList[index];
    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.USER_DETAILS_VIEW, arguments: user.userId);
        // Get.to(
        //   () => const UserDetailsView(),
        //   binding: AppBindings(),
        //   transition: Transition.downToUp,
        //   duration: const Duration(milliseconds: 500),
        //   arguments: user.userId,
        // );
      },
      onVerticalDragEnd: (details) {
        // Check if the swipe is upwards
        if (details.primaryVelocity != null && details.primaryVelocity! < 0) {
          Get.toNamed(AppRoutes.USER_DETAILS_VIEW, arguments: user.userId);

          // Negative velocity indicates an upward swipe
          // Get.to(
          //       () => const UserDetailsView(),
          //   binding: AppBindings(),
          //   transition: Transition.downToUp,
          //   duration: const Duration(milliseconds: 500),
          //   arguments: user.userId,
          // );
        }
      },
      child:
      Container(
        clipBehavior: Clip.hardEdge,
        margin: const EdgeInsets.symmetric(horizontal: 00),
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(40)),
          color: AppColors.blackColor,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.2),
              spreadRadius: 3,
              blurRadius: 7,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(40)),
              child: BlurredProfileImage(
                imageProvider: user.profileImage != null && user.profileImage!.isNotEmpty
                    ? NetworkImage(user.profileImage!) as ImageProvider
                    : AssetImage(
                  user.gender!.toLowerCase() == "male"
                      ? AppAssets.malePlaceholder
                      : AppAssets.femalePlaceholder,
                ) as ImageProvider,
                shouldBlur: user.blurProfileImage ?? false,
                boxFit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child:
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // CustomButton(
                //   text: '5.0',
                //   width: 100,
                //   prefixIcon: const Padding(
                //     padding: EdgeInsets.only(right: 8.0),
                //     child: Icon(
                //       Icons.star,
                //       color: AppColors.whiteColor,
                //     ),
                //   ),
                //   backgroundColor: AppColors.secondaryColor,
                //   fontColor: AppColors.whiteColor,
                //   onTap: () {},
                // ),
                InkWell(
                  onTap: () {
                    controller.addFavorite(context, index, user.userId);
                  },
                  child: CircleAvatar(
                    backgroundColor: AppColors.whiteColor,
                    child: user.favourite == "no"
                        ? const Icon(Icons.favorite_border)
                        : const Icon(Icons.favorite, color: AppColors.redColor),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: user.name,
                    color: AppColors.whiteColor,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.whiteColor,
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: AppText(
                          text:
                          '${user.cityName}, ${user.stateName}, ${user.countryName}',
                          overflow: TextOverflow.visible,
                          color: AppColors.whiteColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ],
          ),
            ),
          ],
        ),
      ),
    );
  }

  String getImageProfile(profileImage) {
    if (profileImage != null) {
      return profileImage;
    } else {
      return "";
    }
  }



  Widget homeShimmer(BuildContext context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: 3,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Container(
              width: w,
              height: h * 0.80,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          );
        },
      ),
    );
  }
}