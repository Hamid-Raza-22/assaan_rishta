import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/constant_widgets.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_button.dart';

class BasicInfoView extends GetView<SignupViewModel> {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
        appBar: const PreferredSize(
          preferredSize: Size(double.infinity, 40),
          child: CustomAppBar(
            title: "Basic Information",
          ),),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: SingleChildScrollView(
            child: Form(
              key: controller.basicInfoFormKey,
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  ..._buildDropdownFields(controller),
                  const SizedBox(height: 20),
                  
                  // Profile Blur Switch - Only visible for Female users
                  Obx(() => controller.selectedGender.value == 'Female' 
                    ? Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppColors.fillFieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.blur_on,
                                  color: AppColors.primaryColor,
                                  size: 22,
                                ),
                                const SizedBox(width: 12),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Profile Picture Blur',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Hide your photo from others',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            CupertinoSwitch(
                              value: controller.isProfileBlur.value,
                              onChanged: (value) {
                                controller.isProfileBlur.value = value;
                              },
                              activeColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      )
                    : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: "Next",
                    isGradient: true,
                    fontColor: AppColors.whiteColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                    onTap: () {
                      debugPrint(
                        "dhftrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr${controller.selectedMaritalStatus.value}"
                            " ${controller.selectedReligion.value} "
                            "${controller.selectedCaste.value} "
                            "${controller.selectedEducation.value} "
                            "${controller.selectedOccupation.value} "
                            "${controller.selectedHeight.value}"
                            "${controller.emailController.value}"
                            "${controller.passwordController.value}"
                            "${controller.firstNameController.value}"
                            "${controller.lastNameController.value}"

                        ,
                      );

                      if (controller.basicInfoFormKey.currentState!
                          .validate()) {
                        Get.toNamed(AppRoutes.OTHER_INFO); // Navigate to next screen
                      }
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
      ),
    );
  }

  List<Widget> _buildDropdownFields(SignupViewModel controller) {
    return [
      CustomDropdown<String>(
        hintText: 'Marital Status',
        items: controller.maritalStatusList,
        validateOnChange: true,
        validator: (value) =>
            value == null ? "Please select marital status" : null,
        onChanged: (value) => controller.selectedMaritalStatus.value = value!,
        decoration: basicInfoDecoration(),
      ),
      const SizedBox(height: 16),
      CustomDropdown<String>(
        hintText: 'Religion',
        items: controller.religionList,
        validateOnChange: true,
        validator: (value) => value == null ? "Please select religion" : null,
        onChanged: (value) => controller.selectedReligion.value = value!,
        decoration: basicInfoDecoration(),
      ),
      const SizedBox(height: 16),
      CustomDropdown<String>.search(
        hintText: 'Caste',
        items: controller.casteList,
        validateOnChange: true,
        validator: (value) => value == null ? "Please select caste" : null,
        onChanged: (value) => controller.selectedCaste.value = value!,
        decoration: basicInfoDecoration(),
      ),
      const SizedBox(height: 16),
      CustomDropdown<String>.search(
        hintText: 'Education',
        items: controller.educationList,
        validateOnChange: true,
        validator: (value) => value == null ? "Please select education" : null,
        onChanged: (value) => controller.selectedEducation.value = value!,
        decoration: basicInfoDecoration(),
      ),
      const SizedBox(height: 16),
      CustomDropdown<String>.search(
        hintText: 'Occupation',
        items: controller.occupationList,
        validateOnChange: true,
        validator: (value) => value == null ? "Please select occupation" : null,
        onChanged: (value) => controller.selectedOccupation.value = value!,
        decoration: basicInfoDecoration(),
      ),
      const SizedBox(height: 16),
      CustomDropdown<String>.search(
        hintText: 'Height',
        items: controller.heightList,
        validateOnChange: true,
        validator: (value) => value == null ? "Please select height" : null,
        onChanged: (value) => controller.selectedHeight.value = value!,
        decoration: basicInfoDecoration(),
      ),
    ];
  }
}
