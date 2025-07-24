import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../utils/constant_widgets.dart';
import '../../viewmodels/signup_viewmodel.dart';
import '../../widgets/custom_button.dart';

class BasicInfoView extends GetView<SignupViewModel> {
  const BasicInfoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: const Text('Basic Information', style: TextStyle(fontSize: 20)),
        centerTitle: true,
      ),
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
                            "${controller.selectedHeight.value}",
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
