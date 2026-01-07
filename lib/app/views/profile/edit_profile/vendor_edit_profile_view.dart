import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'edit_profile_view.dart';
import 'vendor_edit_profile_controller.dart';

/// Edit Profile View for Matrimonial (Vendor) users
/// Uses same UI design as existing EditProfileView
class VendorEditProfileView extends GetView<VendorEditProfileController> {
  const VendorEditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorEditProfileController>(
      initState: (_) {
        Get.put(VendorEditProfileController());
      },
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: true,
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: SafeArea(
            child: controller.isLoading.isFalse
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                      child: Column(
                        children: [
                          _getProfileInfo(context),
                        ],
                      ),
                    ),
                  )
                : _profileShimmer(context),
          ),
        );
      },
    );
  }

  PreferredSizeWidget _appBar() {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: true,
        title: "Edit Profile",
      ),
    );
  }

  /// Combined Profile Information Section with single update button
  Widget _getProfileInfo(BuildContext context) {
    return Form(
      key: controller.formKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.profileContainerColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            const AppText(
              text: "Business Information",
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            // Business Name
            Row(
              children: [
                getEditListTile(
                  title: 'Business Name',
                  subtitle: controller.vendorProfile.value?.venderBusinessName ?? '',
                  tec: controller.businessNameController,
                ),
              ],
            ),
            // Email (Read-only)
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const AppText(
                      text: 'Email (Cannot be changed)',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                    subtitle: CustomFormField(
                      tec: controller.emailController,
                      readOnly: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
              ],
            ),
            // Mobile No - IntlPhoneField (same as edit_profile.dart)
            const SizedBox(height: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppText(
                  text: 'Mobile No',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
                const SizedBox(height: 5),
                IntlPhoneField(
                  controller: controller.phoneController,
                  style: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  dropdownTextStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  dropdownIconPosition: IconPosition.trailing,
                  dropdownIcon: const Icon(
                    CupertinoIcons.chevron_down,
                    size: 16,
                    color: CupertinoColors.systemGrey,
                  ),
                  textInputAction: TextInputAction.next,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: false,
                    signed: false,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    _NoSpaceInputFormatter(),
                    LengthLimitingTextInputFormatter(
                      controller.phoneValidationRules[controller.countryCode.value]?.maxLength ?? 15,
                    ),
                  ],
                  flagsButtonMargin: const EdgeInsets.only(left: 10),
                  decoration: InputDecoration(
                    hintText: 'Mobile Number',
                    filled: true,
                    fillColor: AppColors.fillFieldColor,
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(
                        color: AppColors.borderColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.red),
                    ),
                  ),
                  cursorColor: AppColors.primaryColor,
                  initialCountryCode: controller.countryCode.value,
                  disableLengthCheck: true,
                  validator: controller.validatePhone,
                  onChanged: (phone) {
                    // Get max length for current country
                    final rule = controller.phoneValidationRules[phone.countryISOCode];
                    final maxLength = rule?.maxLength ?? 15;
                    
                    // Trim if exceeds max length
                    if (phone.number.length > maxLength) {
                      controller.phoneController.text = phone.number.substring(0, maxLength);
                      controller.phoneController.selection = TextSelection.fromPosition(
                        TextPosition(offset: maxLength),
                      );
                    }
                    
                    controller.countryCode.value = phone.countryISOCode;
                    controller.phoneNumber.value = phone.completeNumber;
                  },
                  onCountryChanged: (country) {
                    controller.countryCode.value = country.code;
                    controller.phoneController.clear();
                    controller.update();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Location Information Section
            const AppText(
              text: "Location Information",
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 18,
            ),
            const SizedBox(height: 10),
            // Country Dropdown
            Row(
              children: [
                getDropDownListTile(
                  title: 'Country',
                  child: CustomDropdown<AllCountries>.search(
                    hintText: controller.selectedCountryName.isNotEmpty 
                        ? controller.selectedCountryName 
                        : controller.vendorProfile.value?.vendorCountryName ?? 'Select Country',
                    items: controller.countryList,
                    onChanged: (value) {
                      if (value != null) {
                        controller.onCountryChanged(value, context);
                      }
                    },
                    decoration: basicInfoDecoration(
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // State Dropdown
            Row(
              children: [
                getDropDownListTile(
                  title: 'State',
                  child: CustomDropdown<AllStates>.search(
                    hintText: controller.stateController.value?.name ?? 
                        controller.vendorProfile.value?.vendorStateName ?? 'Select State',
                    items: controller.stateList,
                    controller: controller.stateController,
                    onChanged: (value) {
                      if (value != null) {
                        controller.onStateChanged(value, context);
                      }
                    },
                    decoration: basicInfoDecoration(
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // City Dropdown
            Row(
              children: [
                getDropDownListTile(
                  title: 'City',
                  child: CustomDropdown<AllCities>.search(
                    hintText: controller.cityController.value?.name ?? 
                        controller.vendorProfile.value?.vendorCityName ?? 'Select City',
                    items: controller.cityList,
                    controller: controller.cityController,
                    onChanged: (value) {
                      if (value != null) {
                        controller.onCityChanged(value);
                      }
                    },
                    decoration: basicInfoDecoration(
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Address
            Row(
              children: [
                getEditListTile(
                  title: 'Address',
                  subtitle: controller.vendorProfile.value?.venderAddress ?? '',
                  tec: controller.addressController,
                  lines: 2,
                ),
              ],
            ),
            // About Company
            Row(
              children: [
                getEditListTile(
                  title: 'About Company',
                  subtitle: controller.vendorProfile.value?.aboutCompany ?? '',
                  tec: controller.aboutCompanyController,
                  lines: 4,
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Service Charges Toggle
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'Service Charges',
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 8),
                      Obx(() => Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.fillFieldColor,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppColors.borderColor),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            AppText(
                              text: controller.serviceChargesEnabled.value ? 'Yes' : 'No',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.blackColor,
                            ),
                            CupertinoSwitch(
                              value: controller.serviceChargesEnabled.value,
                              onChanged: (value) {
                                controller.serviceChargesEnabled.value = value;
                                controller.update();
                              },
                              activeTrackColor: AppColors.primaryColor,
                            ),
                          ],
                        ),
                      )),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Single Update Button for all fields
            CustomButton(
              text: "Update Profile",
              fontColor: AppColors.whiteColor,
              isGradient: true,
              onTap: () {
                if (controller.formKey.currentState!.validate()) {
                  controller.updateAllProfile(context);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _profileShimmer(context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          BannerPlaceholder(
            width: w,
            height: h * 0.99,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}

/// Custom input formatter that removes spaces from input
/// Also handles pasted text with spaces by cleaning them
class _NoSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Remove all spaces from the input (handles both typing and pasting)
    final newText = newValue.text.replaceAll(' ', '');
    
    if (newText == newValue.text) {
      return newValue;
    }
    
    // Adjust cursor position after removing spaces
    final cursorOffset = newValue.selection.baseOffset - 
        (newValue.text.length - newText.length);
    
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, newText.length),
      ),
    );
  }
}
