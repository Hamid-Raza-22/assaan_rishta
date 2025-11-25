import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';

import 'export.dart';

class FavoritesView extends GetView<FavoritesController> {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FavoritesController>(
      initState: (_) {
        Get.put(FavoritesController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: SafeArea(
              child: Obx(
            () => controller.isLoading.isFalse
                ? controller.favList.isNotEmpty
                    ? ListView.builder(
                        shrinkWrap: true,
                        itemCount: controller.favList.length,
                        physics: const BouncingScrollPhysics(),
                        itemBuilder: (context, index) {
                          return getListTile(
                            context: context,
                            favItem: controller.favList[index],
                            index: index,
                          );
                        },
                      )
                    : emptyFavorite()
                : favoritesShimmer(context),
          )),
        );
      },
    );
  }

  _appBar() {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: true,
        title: "Favorite",
      ),
    );
  }

  Widget getListTile({
    required BuildContext context,
    required FavoritesProfiles favItem,
    required int index,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(
        vertical: 05,
        horizontal: 16,
      ),
      decoration: BoxDecoration(
        color: AppColors.fillFieldColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        onTap: () {
          // Get.to(
          //   () => const UserDetailsView(),
          //   binding: AppBindings(),
          //   transition: Transition.downToUp,
          //   duration: const Duration(milliseconds: 500),
          //   arguments: favItem.userId,
          // );
        },
        leading: BlurredProfileImage(
          imageProvider: (favItem.profileImage != null && favItem.profileImage!.isNotEmpty)
              ? NetworkImage(favItem.profileImage!) as ImageProvider
              : AssetImage(
                  controller.getGenderBasedPlaceholder(favItem.gender),
                ) as ImageProvider,
          shouldBlur: favItem.blurProfileImage ?? false,
          isCircular: true,
          width: 50,
          height: 50,
          boxFit: BoxFit.cover,
          blurSigma: 10.0,
        ),
        title: AppText(
          text: favItem.name,
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.blackColor,
        ),
        subtitle: AppText(
          text: "${favItem.cast}",
          fontSize: 14,
          fontWeight: FontWeight.w300,
          color: AppColors.blackColor,
        ),
        trailing: InkWell(
          onTap: () {
            controller.removeFromLocalList(index);
            controller.removeFavorite(favUid: favItem.userId!);
          },
          child: Container(
            padding: const EdgeInsets.all(05),
            decoration: const BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border,
              color: AppColors.whiteColor,
            ),
          ),
        ),
      ),
    );
  }

  emptyFavorite() {
    return Center(
      child: ImageHelper(
        image: AppAssets.emptyFavorite,
        imageType: ImageType.JsonAsset,
      ),
    );
  }

  favoritesShimmer(context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView.builder(
        itemCount: 20,
        shrinkWrap: true,
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        itemBuilder: (context, index) {
          return const BannerPlaceholder(
            width: double.infinity,
            height: 60,
            borderRadius: 10,
          );
        },
      ),
    );
  }
}
