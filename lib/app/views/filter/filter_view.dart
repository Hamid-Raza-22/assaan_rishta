import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/filter_viewmodel.dart';
import 'package:flutter/services.dart';
import '../../widgets/export.dart';
import '../../core/routes/app_routes.dart';

class FilterView extends GetView<FilterController> {
  const FilterView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<FilterController>(
      initState: (_) {
        Get.put(FilterController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size(double.infinity, 40),
            child: CustomAppBar(
              isBack: false,
              title: "Filter",
              actions: [
                IconButton(
                  onPressed: () {
                    showFilterBottomSheet(context);
                  },
                  icon: const Icon(
                    Icons.filter_list_sharp,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showSearchBottomSheet(context);
                  },
                  icon: const Icon(
                    Icons.search,
                  ),
                ),
              ],
            ),
          ),
          body: controller.isLoading.isFalse
              ? controller.profileList.isNotEmpty
              ? ListView.builder(
            controller: controller.scrollController,
            itemCount: controller.profileList.length +
                (controller.isReloadMore.value ? 1 : 0),
            shrinkWrap: true,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const ScrollPhysics(),
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
                return filterItem(context, index);
              }
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
              : filterShimmer(context),
        );
      },
    );
  }

  filterItem(context, index) {
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
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AppText(
                            text: 'Cast:',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: user.cast,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AppText(
                            text: 'Status:',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: user.maritalStatus,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AppText(
                            text: 'City:',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: user.cityName,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AppText(
                            text: 'Job:',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: user.occupation,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Expanded(
                          child: AppText(
                            text: 'Age:',
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Expanded(
                          child: AppText(
                            text: user.age,
                            fontSize: 16,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
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
                      imageProvider: (user.profileImage != null && user.profileImage!.isNotEmpty)
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

  showSearchBottomSheet(BuildContext context) {
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
          padding: EdgeInsets.only( // Add this padding
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Padding( // Wrap Column with Padding for horizontal and vertical
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                const AppText(
                  text: "Search by User ID",
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.blackColor,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: controller.userIdSearchTEC,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                  ],
                  decoration: InputDecoration(
                    hintText: 'Enter User ID',
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.greyColor,
                      fontSize: 14,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.greyColor,
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.primaryColor,
                        width: 2,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(
                        color: AppColors.greyColor,
                        width: 1,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Search",
                  isGradient: true,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () {
                    if (controller.userIdSearchTEC.text
                        .trim()
                        .isNotEmpty) {
                      Navigator.pop(context);
                      Get.toNamed(AppRoutes.USER_DETAILS_VIEW,
                          arguments: controller.userIdSearchTEC.text.trim());
                      controller.clearSearch();
                    } else {
                      Get.snackbar(
                        'Please Enter a User ID',
                        'User ID cannot be empty',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: Colors.red,
                        colorText: Colors.white,
                      );
                    }
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Clear Search",
                  isGradient: false,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () {
                    controller.clearSearch();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  showFilterBottomSheet(BuildContext context) {
    List<String> ageFromList =
    List.generate(33, (index) => (18 + index).toString());

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
          padding: EdgeInsets.only( // Add this padding
            bottom: MediaQuery
                .of(context)
                .viewInsets
                .bottom,
          ),
          child: Padding( // Wrap Column with Padding for horizontal and vertical
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 30),
                CustomDropdown<String>.search(
                  hintText:
                  controller.caste.isEmpty ? 'Cast' : controller.caste.value,
                  items: controller.castNameList,
                  onChanged: (value) {
                    controller.caste.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.caste.value),
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      flex: 1,
                      child: CustomDropdown<String>(
                        hintText: controller.ageFrom.isEmpty
                            ? 'Age From'
                            : controller.ageFrom.value,
                        items: ageFromList,
                        onChanged: (value) {
                          controller.ageFrom.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: getHintStyle(controller.ageFrom.value),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 1,
                      child: CustomDropdown<String>(
                        hintText: controller.ageTo.isEmpty
                            ? 'Age To'
                            : controller.ageTo.value,
                        items: ageFromList,
                        onChanged: (value) {
                          controller.ageTo.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: getHintStyle(controller.ageTo.value),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomDropdown<String>(
                  hintText: controller.gender.isEmpty
                      ? 'Gender'
                      : controller.gender.value,
                  items: const ["Male", "Female"],
                  onChanged: (value) {
                    controller.gender.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.gender.value),
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllCountries>.search(
                  hintText:
                  controller.country.isEmpty ? 'Country' : controller.country,
                  items: controller.countryList,
                  onChanged: (value) {
                    controller.country = '${value?.name}';
                    controller.getAllStates(value?.id, context);
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.country),
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllStates>.search(
                  hintText: controller.state.value.isEmpty
                      ? 'State'
                      : controller.state.value,
                  items: controller.stateList,
                  onChanged: (value) {
                    controller.state.value = '${value?.name}';
                    controller.getAllCities(value!.id, context);
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.state.value),
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllCities>.search(
                  hintText: controller.city.value.isEmpty
                      ? 'City'
                      : controller.city.value,
                  items: controller.cityList,
                  onChanged: (value) {
                    controller.city.value = '${value?.name}';
                    controller.cityId.value = value!.id.toString();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.city.value),
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown<String>(
                  hintText: controller.maritalStatus.isEmpty
                      ? 'Marital Status'
                      : controller.maritalStatus.value,
                  items: controller.maritalStatusList,
                  onChanged: (value) {
                    controller.maritalStatus.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.maritalStatus.value),
                  ),
                ),
                const SizedBox(height: 10),
                CustomDropdown<String>(
                  hintText: controller.religion.isEmpty
                      ? 'Religion'
                      : controller.religion.value,
                  items: controller.religionList,
                  onChanged: (value) {
                    controller.religion.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: getHintStyle(controller.religion.value),
                  ),
                ),
                const SizedBox(height: 30),
                CustomButton(
                  text: "Apply Filter",
                  isGradient: true,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () {
                    controller
                        .getAllProfilesByFilter(context: context, page: 1)
                        .then((onValue) {
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
                    controller.clearAllFilters();
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
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

  filterShimmer(context) {
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
          itemBuilder: (context, index) {
            return BannerPlaceholder(
              width: w,
              height: h * 0.30,
              borderRadius: 10,
            );
          }),
    );
  }
}
