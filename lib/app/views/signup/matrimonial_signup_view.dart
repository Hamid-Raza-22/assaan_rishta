import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

import '../../core/export.dart';
import '../../core/routes/app_routes.dart';
import '../../utils/app_colors.dart';
import '../../viewmodels/vendor_registration_viewmodel.dart';
import '../../widgets/app_text.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/custom_checkbox.dart';
import 'widgets/custom_button.dart';
import 'widgets/custom_text_field.dart';

/// Matrimonial Signup View - Reuses existing signup widgets
/// For vendor registration with role_id = 3
class MatrimonialSignupView extends StatelessWidget {
  MatrimonialSignupView({super.key});

  final VendorRegistrationViewModel controller = Get.find<VendorRegistrationViewModel>();

  PreferredSizeWidget _appBar() {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: true,
        title: "Matrimonial Sign Up",
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _appBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 10),
        child: Form(
          key: controller.formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: AppText(
                  text: 'Create Matrimonial Account',
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: AppText(
                  text: 'Register your matrimonial business\nto manage user profiles',
                  textAlign: TextAlign.center,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 25),

              // Logo Picker
              _buildLogoPicker(context),
              const SizedBox(height: 20),

              // Business Name
              CustomTextField(
                controller: controller.businessNameController,
                hintText: 'Business Name',
                prefixIcon: Icons.business_outlined,
                validator: (value) =>
                    controller.validateRequired(value, 'Business Name'),
              ),
              const SizedBox(height: 10),

              // Email
              CustomTextField(
                controller: controller.emailController,
                hintText: 'Email Address',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: controller.validateEmail,
              ),
              const SizedBox(height: 10),

              // Phone Number with IntlPhoneField
              _buildPhoneField(),
              const SizedBox(height: 10),

              // Password
              Obx(
                () => CustomTextField(
                  controller: controller.passwordController,
                  hintText: 'Password',
                  prefixIcon: Icons.lock_outline,
                  obscureText: !controller.isPasswordVisible.value,
                  suffixIcon: IconButton(
                    icon: Icon(
                      controller.isPasswordVisible.value
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: Colors.grey,
                    ),
                    onPressed: controller.togglePasswordVisibility,
                  ),
                  validator: controller.validatePassword,
                ),
              ),
              const SizedBox(height: 10),

              // Address
              CustomTextField(
                controller: controller.addressController,
                hintText: 'Business Address',
                prefixIcon: Icons.location_on_outlined,
                validator: (value) =>
                    controller.validateRequired(value, 'Address'),
              ),
              const SizedBox(height: 10),

              // About Company (below Address)
              CustomTextField(
                controller: controller.aboutCompanyController,
                hintText: 'About Company',
                prefixIcon: Icons.info_outline,
                maxLines: 3,
              ),
              const SizedBox(height: 10),

              // City Selection (Pakistan Cities)
              _buildCityDropdowns(context),
              const SizedBox(height: 15),

              // Service Charges (Yes/No Toggle)
              _buildServiceChargesToggle(),
              const SizedBox(height: 15),

              // Terms & Conditions
              _buildTermsCheckbox(),
              const SizedBox(height: 20),

              // Register Button
              Obx(
                () => CustomButton(
                  text: "Create Account",
                  isLoading: controller.isLoading.value,
                  onPressed: () {
                    if (controller.formKey.currentState!.validate()) {
                      controller.registerVendor(context);
                    }
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Already have account
              Center(
                child: RichText(
                  text: TextSpan(
                    text: 'Already have an account? ',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                    children: [
                      TextSpan(
                        text: 'Login',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppColors.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () => Get.toNamed(AppRoutes.LOGIN),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  /// Build logo picker widget (reusable pattern)
  Widget _buildLogoPicker(BuildContext context) {
    return Obx(() => Center(
          child: Column(
            children: [
              GestureDetector(
                onTap: () => controller.showLogoOptions(context),
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: controller.logoFile.value != null
                        ? null
                        : Colors.grey[100],
                    border: Border.all(
                      color: controller.logoFile.value != null
                          ? AppColors.primaryColor
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipOval(
                        child: controller.logoFile.value != null
                            ? Image.file(
                                controller.logoFile.value!,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey[50],
                                child: Icon(
                                  Icons.business_rounded,
                                  size: 40,
                                  color: Colors.grey[400],
                                ),
                              ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryColor,
                                AppColors.secondaryColor,
                              ],
                            ),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            controller.logoFile.value != null
                                ? Icons.edit
                                : Icons.add_a_photo,
                            size: 14,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              AppText(
                text: controller.logoFile.value != null
                    ? 'Tap to change logo'
                    : 'Add Business Logo',
                color: Colors.grey[600],
                fontSize: 12,
              ),
              if (controller.logoError.value.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    controller.logoError.value,
                    style: const TextStyle(fontSize: 12, color: Colors.red),
                  ),
                ),
            ],
          ),
        ));
  }

  /// Build phone field with IntlPhoneField (same as SignupView)
  Widget _buildPhoneField() {
    return IntlPhoneField(
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
          controller.phoneValidationRules[controller.countryISOCode.value]
                  ?.maxLength ??
              15,
        ),
      ],
      flagsButtonMargin: const EdgeInsets.only(left: 10),
      decoration: InputDecoration(
        hintText: 'Phone Number',
        filled: true,
        fillColor: AppColors.fillFieldColor,
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: AppColors.borderColor),
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
      initialCountryCode: 'PK',
      disableLengthCheck: true,
      validator: controller.validatePhone,
      onCountryChanged: (country) {
        controller.countryCode.value = "+${country.dialCode}";
        controller.countryISOCode.value = country.code;
        controller.phoneController.clear();
        controller.validateForm();
      },
      onChanged: (phone) {
        final rule =
            controller.phoneValidationRules[controller.countryISOCode.value];
        final maxLength = rule?.maxLength ?? 10;

        if (phone.number.length > maxLength) {
          controller.phoneController.text = phone.number.substring(0, maxLength);
          controller.phoneController.selection = TextSelection.fromPosition(
            TextPosition(offset: controller.phoneController.text.length),
          );
          HapticFeedback.lightImpact();
        }
        controller.validateForm();
      },
    );
  }

  /// Build city dropdowns (State -> City for Pakistan)
  Widget _buildCityDropdowns(BuildContext context) {
    return GetBuilder<VendorRegistrationViewModel>(
      builder: (ctrl) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // State/Province Dropdown
          CustomDropdown<AllStates>.search(
            hintText: 'Select Province/State',
            items: ctrl.stateList,
            decoration: CustomDropdownDecoration(
              closedFillColor: AppColors.fillFieldColor,
              closedBorder: Border.all(color: AppColors.borderColor),
              closedBorderRadius: BorderRadius.circular(10),
              expandedFillColor: Colors.white,
              expandedBorderRadius: BorderRadius.circular(10),
              listItemStyle: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
              ),
              headerStyle: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
              ),
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  item.name ?? '',
                  style: GoogleFonts.poppins(
                    color: isSelected ? AppColors.primaryColor : AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            },
            headerBuilder: (context, selectedItem, enabled) {
              return Text(
                selectedItem.name ?? '',
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                ),
              );
            },
            onChanged: (value) {
              if (value != null) {
                ctrl.onStateChanged(value, context);
              }
            },
          ),
          const SizedBox(height: 10),

          // City Dropdown
          CustomDropdown<AllCities>.search(
            hintText: 'Select City',
            items: ctrl.cityList,
            decoration: CustomDropdownDecoration(
              closedFillColor: AppColors.fillFieldColor,
              closedBorder: Border.all(color: AppColors.borderColor),
              closedBorderRadius: BorderRadius.circular(10),
              expandedFillColor: Colors.white,
              expandedBorderRadius: BorderRadius.circular(10),
              listItemStyle: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
              ),
              headerStyle: GoogleFonts.poppins(
                color: AppColors.blackColor,
                fontSize: 14,
              ),
              hintStyle: GoogleFonts.poppins(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            listItemBuilder: (context, item, isSelected, onItemSelect) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Text(
                  item.name ?? '',
                  style: GoogleFonts.poppins(
                    color: isSelected ? AppColors.primaryColor : AppColors.blackColor,
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              );
            },
            headerBuilder: (context, selectedItem, enabled) {
              return Text(
                selectedItem.name ?? '',
                style: GoogleFonts.poppins(
                  color: AppColors.blackColor,
                  fontSize: 14,
                ),
              );
            },
            onChanged: (value) {
              if (value != null) {
                ctrl.onCityChanged(value);
              }
            },
          ),
        ],
      ),
    );
  }

  /// Build service charges toggle (Yes/No)
  Widget _buildServiceChargesToggle() {
    return Obx(() => Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.borderColor),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.monetization_on_outlined,
                      color: Colors.grey[600], size: 22),
                  const SizedBox(width: 12),
                  Text(
                    'Service Charges',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    controller.serviceCharges.value ? 'Yes' : 'No',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: controller.serviceCharges.value
                          ? AppColors.primaryColor
                          : Colors.grey[600],
                    ),
                  ),
                  const SizedBox(width: 8),
                  CupertinoSwitch(
                    value: controller.serviceCharges.value,
                    activeTrackColor: AppColors.primaryColor,
                    onChanged: (value) => controller.toggleServiceCharges(value),
                  ),
                ],
              ),
            ],
          ),
        ));
  }

  /// Build terms and conditions checkbox
  Widget _buildTermsCheckbox() {
    return Obx(() => Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomCheckbox(
              value: controller.isTermsAgree.value,
              onChanged: (bool value) {
                controller.toggleTermsAgreement(value);
              },
            ),
            const SizedBox(width: 10),
            Expanded(
              child: RichText(
                textAlign: TextAlign.start,
                text: TextSpan(
                  text: 'I agree to the ',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w400,
                  ),
                  children: <TextSpan>[
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(
                              AppRoutes.IN_APP_WEB_VIEW_SITE_TERMS_AND_CONDITIONS);
                        },
                      text: 'Terms & Conditions',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: ' and ',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    TextSpan(
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Get.toNamed(AppRoutes.IN_APP_WEB_VIEW_SITE);
                        },
                      text: 'Privacy Policy',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: AppColors.secondaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }
}

/// Custom input formatter that removes spaces
class _NoSpaceInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text.replaceAll(' ', '');

    if (newText == newValue.text) {
      return newValue;
    }

    final cursorOffset =
        newValue.selection.baseOffset - (newValue.text.length - newText.length);

    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(
        offset: cursorOffset.clamp(0, newText.length),
      ),
    );
  }
}
