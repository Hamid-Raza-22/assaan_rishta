import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import '../edit_profile/edit_profile_controller.dart';
import 'export.dart';

class PartnerPreferenceView extends GetView<PartnerPreferenceController> {
  const PartnerPreferenceView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<PartnerPreferenceController>(
      initState: (_) {
        Get.put(PartnerPreferenceController(), permanent: false);
      },
      dispose: (_) {
        Get.delete<PartnerPreferenceController>();
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: SafeArea(
            child: controller.isLoading.isFalse
                ? ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                const SizedBox(height: 10),
                getAgeFromAndAgeTo(context: context),
                const SizedBox(height: 10),
                getLanguages(context: context),
                const SizedBox(height: 10),
                getCaste(context: context),
                const SizedBox(height: 10),
                getEducation(context: context),
                const SizedBox(height: 10),
                getOccupation(context: context),
                const SizedBox(height: 10),
                getIncome(context: context),
                const SizedBox(height: 10),
                getMotherTongue(context: context),
                const SizedBox(height: 10),
                getCountryData(context: context),
                const SizedBox(height: 10),
                getPartnerReligion(context: context),
                const SizedBox(height: 10),
                getHeight(context: context),
                const SizedBox(height: 10),
                getBuilt(context: context),
                const SizedBox(height: 10),
                getPartnerComplexion(context: context),
                const SizedBox(height: 10),
                getMaritalStatus(context: context),
                const SizedBox(height: 10),
                getAboutPartner(context: context),
                const SizedBox(height: 10),
                isDrinkIsSmoke(context: context),
                const SizedBox(height: 10),
                Obx(
                      () => CustomButton(
                    text: "Update",
                    fontColor: controller.isFormValid.value
                        ? AppColors.whiteColor
                        : AppColors.greyColor,
                    isGradient: controller.isFormValid.value,
                    backgroundColor: controller.isFormValid.value
                        ? null
                        : AppColors.borderColor,
                    onTap: controller.isFormValid.value
                        ? () {
                      controller.updatePartnerPreference(context);
                    }
                        : null,
                  ),
                ),
                const SizedBox(height: 10),
                // CustomButton(
                //   text: "Skip for Now",
                //   fontColor: AppColors.primaryColor,
                //   isGradient: false,
                //   backgroundColor: AppColors.whiteColor,
                //   borderColor: AppColors.primaryColor,
                //   onTap: () {
                //     controller.skipPartnerPreference();
                //   },
                // ),
                const SizedBox(height: 50),
              ],
            )
                : profileShimmer(context),
          ),
          // ),
        );
      },
    );
  }

  _appBar() {
    return PreferredSize(
      preferredSize: const Size(double.infinity, 40),
      child: Obx(
            () => CustomAppBar2(
          isBack: true,
          title: "Partner Preference",
          actions: controller.showSkipButton.value
              ? [
            TextButton(
              onPressed: () {
                controller.skipPartnerPreference();
              },
              child: const AppText(
                text: "Skip",
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.primaryColor,
              ),
            ),
          ]
              : null,
        ),
      ),
    );
  }

  getAgeFromAndAgeTo({context}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: "Age From",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                  const SizedBox(height: 05),
                  Obx(
                        () => CustomDropdown<String>(
                      hintText: 'Age From',
                      initialItem:
                      (controller.ageFrom.value.isNotEmpty &&
                          controller.ageFromList.contains(
                            controller.ageFrom.value,
                          ))
                          ? controller.ageFrom.value
                          : null,
                      items: controller.ageFromList,
                      onChanged: (value) {
                        controller.ageFrom.value = value!;
                        controller.validateForm();
                        controller.update();
                      },
                      decoration: basicInfoDecoration(
                        hintStyle: getHintStyle(controller.ageFrom.value),
                        hasError:
                        controller.ageValidationError.value.isNotEmpty,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              flex: 1,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AppText(
                    text: "Age To",
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: AppColors.blackColor,
                  ),
                  const SizedBox(height: 05),
                  Obx(
                        () => CustomDropdown<String>(
                      hintText: 'Age To',
                      initialItem:
                      (controller.ageTo.value.isNotEmpty &&
                          controller.ageFromList.contains(
                            controller.ageTo.value,
                          ))
                          ? controller.ageTo.value
                          : null,
                      items: controller.ageFromList,
                      onChanged: (value) {
                        controller.ageTo.value = value!;
                        controller.validateForm();
                        controller.update();
                      },
                      decoration: basicInfoDecoration(
                        hintStyle: getHintStyle(controller.ageTo.value),
                        hasError:
                        controller.ageValidationError.value.isNotEmpty,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        // Error message display
        Obx(
              () => controller.ageValidationError.value.isNotEmpty
              ? Padding(
            padding: const EdgeInsets.only(top: 5),
            child: AppText(
              text: controller.ageValidationError.value,
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: Colors.red,
            ),
          )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  getHintStyle(String value) {
    if (value.isNotEmpty) {
      return GoogleFonts.poppins(color: AppColors.blackColor);
    } else {
      return null;
    }
  }

  getLanguages({context}) {
    return getDropDownListTile(
      title: 'Languages',
      child: Obx(() => CustomDropdown<String>.multiSelect(
        hintText: 'Languages',
        initialItems: controller.languages.isNotEmpty
            ? controller.languages.where((lang) => languagesList.contains(lang)).toList()
            : null,
        items: languagesList,
        onListChanged: (value) {
          controller.languages.value = value;
          controller.validateForm();
          controller.update();
        },
        decoration: multiSelectionDecoration(
          hintStyle: GoogleFonts.poppins(
            color: AppColors.blackColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      )),
    );
  }

  getCaste({context}) {
    return getDropDownListTile(
      title: 'Caste',
      child: Obx(() => CustomDropdown<String>.search(
        hintText: 'Caste',
        initialItem: (controller.caste.value.isNotEmpty &&
            controller.castNameList.contains(controller.caste.value))
            ? controller.caste.value
            : null,
        items: controller.castNameList,
        onChanged: (value) {
          controller.caste.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getEducation({context}) {
    return getDropDownListTile(
      title: 'Education',
      child: Obx(() => CustomDropdown<String>.search(
        hintText: 'Education',
        initialItem: (controller.education.value.isNotEmpty &&
            controller.degreesList.contains(controller.education.value))
            ? controller.education.value
            : null,
        items: controller.degreesList,
        onChanged: (value) {
          controller.education.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getOccupation({context}) {
    return getDropDownListTile(
      title: 'Occupation',
      child: Obx(() => CustomDropdown<String>.search(
        hintText: 'Occupation',
        initialItem: (controller.occupation.value.isNotEmpty &&
            controller.occupationList.contains(controller.occupation.value))
            ? controller.occupation.value
            : null,
        items: controller.occupationList,
        onChanged: (value) {
          controller.occupation.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getIncome({context}) {
    return getDropDownListTile(
      title: 'Monthly Income',
      child: Obx(() {
        const incomeItems = [
          'Below 10k',
          '10k-20k',
          '20k-30k',
          '30k-40k',
          '40k-50k',
          '50k-60k',
          '60k-70k',
          '70k-80k',
          '80k-90k',
          '90k-1lac',
          '1lac+',
        ];
        return CustomDropdown<String>(
          hintText: 'Monthly Income',
          initialItem:
          (controller.monthlyIncome.value.isNotEmpty &&
              incomeItems.contains(controller.monthlyIncome.value))
              ? controller.monthlyIncome.value
              : null,
          items: const [
            'Below 10k',
            '10k-20k',
            '20k-30k',
            '30k-40k',
            '40k-50k',
            '50k-60k',
            '60k-70k',
            '70k-80k',
            '80k-90k',
            '90k-1lac',
            '1lac+',
          ],
          onChanged: (value) {
            if (value != null) {
              controller.monthlyIncome.value = value;
              controller.validateForm();
              controller.update();
            }
          },
          decoration: basicInfoDecoration(
            hintStyle: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  getMotherTongue({context}) {
    return getDropDownListTile(
      title: 'Mother Tongue',
      child: Obx(
            () => CustomDropdown<String>(
          hintText: 'Mother Tongue',
          initialItem:
          (controller.motherTongue.value.isNotEmpty &&
              languagesList.contains(controller.motherTongue.value))
              ? controller.motherTongue.value
              : null,
          items: languagesList,
          onChanged: (value) {
            controller.motherTongue.value = value!;
            controller.validateForm();
            controller.update();
          },
          decoration: basicInfoDecoration(
            hintStyle: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  getCountryData({context}) {
    return Column(
      children: [
        const SizedBox(height: 10),
        getDropDownListTile(
          title: 'Country',
          child: CustomDropdown<AllCountries>.search(
            hintText: controller.partnerProfile.value.aboutCountryName ?? "",
            items: controller.countryList,
            onChanged: (value) {
              controller.country = '${value?.name}';
              controller.partnerProfile.value.aboutStateName = "State";
              controller.partnerProfile.value.aboutParentCityName = "City";
              controller.stateController.clear();
              controller.cityController.clear();
              controller.getAllStates(context, value?.id);
              controller.validateForm();
            },
            decoration: basicInfoDecoration(
              hintStyle: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        getDropDownListTile(
          title: 'State',
          child: CustomDropdown<AllStates>.search(
            hintText: controller.partnerProfile.value.aboutStateName ?? "",
            items: controller.stateList,
            controller: controller.stateController,
            onChanged: (value) {
              if (value != null) {
                controller.stateController.value = value;
                controller.partnerProfile.value.aboutParentCityName = "City";
                controller.cityController.clear();
                controller.getAllCities(context, value.id);
              }
            },
            decoration: basicInfoDecoration(
              hintStyle:
              controller.partnerProfile.value.aboutStateName == "State"
                  ? null
                  : GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        getDropDownListTile(
          title: "City",
          child: CustomDropdown<AllCities>.search(
            hintText: controller.partnerProfile.value.aboutParentCityName ?? "",
            controller: controller.cityController,
            items: controller.cityList,
            onChanged: (value) {
              if (value != null) {
                controller.cityId = value.id!;
                controller.cityController.value = value;
                controller.validateForm();
              }
            },
            decoration: basicInfoDecoration(
              hintStyle:
              controller.partnerProfile.value.aboutParentCityName == "City"
                  ? null
                  : GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  getPartnerReligion({context}) {
    return getDropDownListTile(
      title: 'Partner Religion',
      child: Obx(() => CustomDropdown<String>(
        hintText: 'Partner Religion',
        initialItem: (controller.religion.value.isNotEmpty &&
            controller.religionList.contains(controller.religion.value))
            ? controller.religion.value
            : null,
        items: controller.religionList,
        onChanged: (value) {
          controller.religion.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getHeight({context}) {
    return getDropDownListTile(
      title: "Height",
      child: Obx(() => CustomDropdown<String>(
        hintText: 'Height',
        initialItem: (controller.height.value.isNotEmpty &&
            controller.heightList.contains(controller.height.value))
            ? controller.height.value
            : null,
        items: controller.heightList,
        onChanged: (value) {
          controller.height.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getBuilt({context}) {
    return getDropDownListTile(
      title: 'Built',
      child: Obx(() {
        const builtItems = ["Average", "Athletic", "Slim", "Heavy"];
        return CustomDropdown<String>(
          hintText: 'Built',
          initialItem:
          (controller.built.value.isNotEmpty &&
              builtItems.contains(controller.built.value))
              ? controller.built.value
              : null,
          items: builtItems,
          onChanged: (value) {
            if (value != null) {
              controller.built.value = value;
              controller.validateForm();
              controller.update();
            }
          },
          decoration: basicInfoDecoration(
            hintStyle: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  getPartnerComplexion({context}) {
    return getDropDownListTile(
      title: 'Partner Complexion',
      child: Obx(() {
        const complexionItems = ["White", "wheatish", "black"];
        return CustomDropdown<String>(
          hintText: 'Partner Complexion',
          initialItem:
          (controller.complexion.value.isNotEmpty &&
              complexionItems.contains(controller.complexion.value))
              ? controller.complexion.value
              : null,
          items: complexionItems,
          onChanged: (value) {
            if (value != null) {
              controller.complexion.value = value;
              controller.validateForm();
              controller.update();
            }
          },
          decoration: basicInfoDecoration(
            hintStyle: GoogleFonts.poppins(
              color: AppColors.blackColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }),
    );
  }

  getMaritalStatus({context}) {
    return getDropDownListTile(
      title: 'Marriage Status',
      child: Obx(() => CustomDropdown<String>(
        hintText: 'Marriage Status',
        initialItem: (controller.maritalStatus.value.isNotEmpty &&
            controller.maritalStatusList.contains(controller.maritalStatus.value))
            ? controller.maritalStatus.value
            : null,
        items: controller.maritalStatusList,
        onChanged: (value) {
          controller.maritalStatus.value = value!;
          controller.validateForm();
          controller.update();
        },
        decoration: basicInfoDecoration(
          hintStyle: GoogleFonts.poppins(color: AppColors.blackColor),
        ),
      )),
    );
  }

  getAboutPartner({context}) {
    return getEditListTile(
      title: 'About Life Partner',
      subtitle: controller.partnerProfile.value.aboutPartner ?? "",
      lines: 4,
      tec: controller.userDiWohtiKaTarufTEC,
    );
  }

  isDrinkIsSmoke({context}) {
    return Column(
      children: [
        const SizedBox(height: 10),
        getDropDownListTile(
          title: 'Drink',
          child: Obx(() {
            const drinkItems = ["Yes", "No"];
            return CustomDropdown<String>(
              hintText: 'Drink',
              initialItem:
              (controller.isDrink.value.isNotEmpty &&
                  drinkItems.contains(controller.isDrink.value))
                  ? controller.isDrink.value
                  : null,
              items: drinkItems,
              onChanged: (value) {
                controller.isDrink.value = value!;
                controller.validateForm();
                controller.update();
              },
              decoration: basicInfoDecoration(
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
        getDropDownListTile(
          title: 'Smoke',
          child: Obx(() {
            const smokeItems = ["Yes", "No"];
            return CustomDropdown<String>(
              hintText: 'Smoke',
              initialItem:
              (controller.isSmoke.value.isNotEmpty &&
                  smokeItems.contains(controller.isSmoke.value))
                  ? controller.isSmoke.value
                  : null,
              items: smokeItems,
              onChanged: (value) {
                controller.isSmoke.value = value!;
                controller.validateForm();
                controller.update();
              },
              decoration: basicInfoDecoration(
                hintStyle: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  ///old code
  profileShimmer(context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
          const SizedBox(height: 05),
          BannerPlaceholder(width: w, height: h * 0.08, borderRadius: 10),
        ],
      ),
    );
  }
}

Widget getEditListTile({
  title,
  subtitle,
  TextEditingController? tec,
  int? lines,
}) {
  return ListTile(
    contentPadding: EdgeInsets.zero,
    title: AppText(
      text: title,
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: AppColors.blackColor,
    ),
    subtitle: CustomFormField(
      tec: tec ?? TextEditingController(text: "$subtitle"),
      lines: lines,
    ),
  );
}

Widget getDropDownListTile({title, required Widget child}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      AppText(
        text: title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.blackColor,
      ),
      const SizedBox(height: 05),
      child,
    ],
  );
}