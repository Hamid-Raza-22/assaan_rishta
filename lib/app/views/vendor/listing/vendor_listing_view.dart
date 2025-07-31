import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/export.dart';
import '../../../core/routes/app_routes.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import '../export.dart';

class VendorListingView extends GetView<VendorListingController> {
  const VendorListingView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorListingController>(
      initState: (_) {
        Get.put(VendorListingController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size(double.infinity, 40),
            child: CustomAppBar(
              isBack: true,
              title: "${controller.category.title} List",
              actions: [
                IconButton(
                  onPressed: () {
                    showFilterBottomSheet(context);
                  },
                  icon: const Icon(
                    Icons.filter_list_sharp,
                  ),
                )
              ],
            ),
          ),
          body: Column(
            children: [
              //_locationAndSearch(),
              const SizedBox(height: 10),
              _allVendorsListView(context: context),
            ],
          ),
        );
      },
    );
  }

  _locationAndSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                height: 42,
                width: 42,
                margin: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: AppColors.whiteColor,
                  border: Border.all(color: AppColors.borderColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.location_on_outlined,
                  color: AppColors.blackColor.withValues(alpha: 0.5),
                ),
              ),
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppText(
                    text: "Your Location",
                    fontWeight: FontWeight.w400,
                    fontSize: 12,
                  ),
                  AppText(
                    text: "Lahore Pakistan",
                    fontWeight: FontWeight.w400,
                    fontSize: 16,
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          SearchableTextFormField(
            labelText: "Search here..",
            controller: controller.searchTEC,
          )
        ],
      ),
    );
  }

  _allVendorsListView({context}) {
    return Expanded(
      child: controller.isLoading.isFalse
          ? controller.vendorList.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  itemCount: controller.vendorList.length,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // number of items in each row
                    mainAxisSpacing: 8.0, // spacing between rows
                    crossAxisSpacing: 8.0, // spacing between columns
                    childAspectRatio: 0.85,
                  ),
                  itemBuilder: (context, index) {
                    VendorsList item = controller.vendorList[index];
                    return GestureDetector(
                      onTap: () {
                        Get.toNamed(AppRoutes.VENDER_DETAILS_VIEW, arguments: item);
                      //   Get.to(
                      //     () => const VendorDetailView(),
                      //     binding: AppBindings(),
                      //     transition: Transition.circularReveal,
                      //     duration: const Duration(milliseconds: 500),
                      //     arguments: item,
                      //   );
                      },
                      child: Container(
                        margin: const EdgeInsets.all(08),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(10)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.5),
                              spreadRadius: 1,
                              blurRadius: 2,
                              offset: const Offset(
                                  0, 3), // changes position of shadow
                            ),
                          ],
                        ),
                        width: 185,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.only(
                                topRight: Radius.circular(10),
                                topLeft: Radius.circular(10),
                              ),
                              child: ImageHelper(
                                image: item.logo!,
                                imageType: ImageType.network,
                                height: 100,
                                width: 185,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  AppText(
                                    text: '${item.venderBusinessName}',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: AppColors.blackColor,
                                  ),
                                  const SizedBox(height: 05),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: AppColors.blackColor
                                            .withValues(alpha: 0.5),
                                        size: 16,
                                      ),
                                      Flexible(
                                        fit: FlexFit.tight,
                                        child: AppText(
                                          text: '${item.venderAddress}',
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 2,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w400,
                                          color: AppColors.blackColor
                                              .withValues(alpha: 0.5),
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
                    );
                  },
                )
              : const Center(
                  child: AppText(
                    text: "No Record Found",
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                )
          : vendorListingShimmer(context),
    );
  }

  showFilterBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.whiteColor,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppText(
                text: 'Refine your Search',
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 30),
              CustomDropdown<AllCountries>.search(
                hintText:
                    controller.country.isEmpty ? 'Country' : controller.country,
                items: controller.countryList,
                onChanged: (value) {
                  controller.country = value!.name!;
                  controller.getAllStates(context, value.id);
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: getHintStyle(controller.country),
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown<AllStates>.search(
                hintText: controller.state.isEmpty ? 'State' : controller.state,
                items: controller.stateList,
                onChanged: (value) {
                  controller.state = value!.name!;
                  controller.getAllCities(context, value.id);
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: getHintStyle(controller.state),
                ),
              ),
              const SizedBox(height: 10),
              CustomDropdown<AllCities>.search(
                hintText: controller.city.isEmpty ? 'City' : controller.city,
                items: controller.cityList,
                onChanged: (value) {
                  controller.city = value!.name!;
                  controller.cityId = value.id!;
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: getHintStyle(controller.city),
                ),
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Apply Filter",
                isGradient: true,
                fontColor: AppColors.whiteColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                onTap: () {
                  controller
                      .getAllVendors(cityId: controller.cityId)
                      .then((value) {
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  });
                },
              ),
              const SizedBox(height: 10),
              CustomButton(
                text: "Clear Filter",
                isGradient: false,
                fontColor: AppColors.whiteColor,
                fontWeight: FontWeight.w500,
                fontSize: 18,
                onTap: () {
                  controller.clearFilter();
                  Navigator.pop(context); // Close the bottom sheet
                },
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  vendorListingShimmer(context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 20,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // number of items in each row
          mainAxisSpacing: 8.0, // spacing between rows
          crossAxisSpacing: 8.0, // spacing between columns
          childAspectRatio: 0.9,
        ),
        itemBuilder: (context, index) {
          return BannerPlaceholder(
            width: w * 0.485,
            height: h * 0.45,
            borderRadius: 10,
          );
        },
      ),
    );
  }

  getHintStyle(String value) {
    if (value.isNotEmpty) {
      return GoogleFonts.poppins(
        color: AppColors.blackColor,
      );
    } else {
      return null;
    }
  }
}
