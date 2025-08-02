import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:assaan_rishta/app/viewmodels/signup_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../core/export.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/constant_widgets.dart';
import '../../widgets/app_text.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_form_field.dart';


class AddressPreferencesView extends GetView<SignupViewModel> {
  const AddressPreferencesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.whiteColor,
      appBar: const PreferredSize(
        preferredSize: Size(double.infinity, 40),
        child: CustomAppBar(
          title: "Other Information",
        ),
      ),
      body: SafeArea(
        child: Obx(
          () => Form(
            key: controller.otherInfoFormKey,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              children: [
                const SizedBox(height: 30),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: "Location",
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllCountries>.search(
                  hintText: 'Country',
                  items: controller.countryList,
                  validateOnChange: true,
                  validator: (value) {
                    if (value == null) {
                      return "Please select Country";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    controller.selectedCountry.value = '${value?.name}';
                    controller.selectedState.value = '';
                    controller.selectedCity.value = '';
                    controller.getAllStates(value?.id, context);
                  },
                  decoration: basicInfoDecoration(),
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllStates>.search(
                  hintText: 'State',
                  items: controller.stateList,
                  controller: controller.stateController,
                  validateOnChange: true,
                  validator: (value) {
                    if (value == null) {
                      return "Please select State";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    if (value != null) {
                      controller.selectedState.value = '${value.name}';
                      controller.stateController.value = value;
                      controller.cityController.clear();
                      controller.getAllCities(value.id, context);
                    }
                  },                  decoration: basicInfoDecoration(),
                ),
                const SizedBox(height: 10),
                CustomDropdown<AllCities>.search(
                  hintText: 'City',
                  validateOnChange: true,
                  items: controller.cityList,

                  validator: (value) {
                    if (value == null) {
                      return "Please select City";
                    } else {
                      return null;
                    }
                  },
                  onChanged: (value) {
                    if(value !=null){
                      controller.selectedCity.value = '${value.name}';
                      controller.cityId = value.id!;
                      controller.cityController.value = value;
                    }
                  },
                  decoration: basicInfoDecoration(),
                ),
                const SizedBox(height: 10),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    AppText(
                      text: "Preferences",
                      color: AppColors.blackColor,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  tec: controller.aboutYourSelfTEC,
                  hint: 'About Yourself',
                  lines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Write some information about yourself";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  tec: controller.aboutYourPartnerTEC,
                  hint: 'About Your Partner',
                  lines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Write some information about your partner";
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: "Create Account",
                  isGradient: true,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  isLoading: controller.isLoading.value,
                  fontSize: 18,
                  onTap: () {
                    debugPrint(
                      "dhftrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${controller.selectedMaritalStatus.value}"
                          " ${controller.selectedReligion.value} "
                          "${controller.selectedCaste.value} "
                          "${controller.selectedEducation.value} "
                          "${controller.selectedOccupation.value} "
                          "${controller.selectedHeight.value}",
                    );
                    if (controller.otherInfoFormKey.currentState!.validate()) {
                      controller.signUpUser(context);
                    }
                   // waitForAdminApproval();
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "Back",
                  isGradient: false,
                  fontColor: AppColors.whiteColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 18,
                  onTap: () {
                    Get.back();
                  },
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void waitForAdminApproval() {
    Get.defaultDialog(
      title: '',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.access_time_rounded, size: 48, color: Colors.orange),
          const SizedBox(height: 16),
          const Text('Awaiting Approval', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Your profile is pending admin approval.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "OK",
            isGradient: true,
            isEnable: true,
            fontColor: AppColors.whiteColor,
            onTap: () =>  Get.offNamed("/login"),
            // onTap: () =>  Get.toNamed(AppRoutes.LOGIN),
          ),
        ],
      ),
    );
  }
}
