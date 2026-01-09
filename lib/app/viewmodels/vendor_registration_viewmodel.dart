import 'dart:convert';
import 'dart:io';

import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../core/export.dart';
import '../core/routes/app_routes.dart';
import '../domain/export.dart';
import '../utils/exports.dart';
import '../widgets/custom_button.dart';

/// Controller for Vendor Registration (Matrimonial Account Creation)
/// Follows same patterns as SignupViewModel for consistency
class VendorRegistrationViewModel extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Use cases
  final userManagementUseCase = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();

  // Text controllers
  final businessNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final passwordController = TextEditingController();
  final addressController = TextEditingController();
  final aboutCompanyController = TextEditingController();

  // Service charges toggle (Yes = true, No = false)
  RxBool serviceCharges = false.obs;

  // Phone
  RxString countryCode = '+92'.obs;
  RxString countryISOCode = 'PK'.obs;

  // Observables
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var isFormValid = false.obs;
  RxBool isTermsAgree = false.obs;

  // Photo picker for logo
  final ImagePicker _picker = ImagePicker();
  Rx<File?> logoFile = Rx<File?>(null);
  RxString logoError = ''.obs;

  // Location - Pakistan cities
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];

  int selectedCityId = 0;
  RxString selectedCityName = ''.obs;

  final stateController = SingleSelectController<AllStates>(null);
  final cityController = SingleSelectController<AllCities>(null);

  // Phone validation rules (same as SignupViewModel)
  final Map<String, PhoneValidationRule> phoneValidationRules = {
    'PK': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Pakistan'),
    'IN': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'India'),
    'US': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'United States'),
    'GB': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'United Kingdom'),
    'SA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Saudi Arabia'),
    'AE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'UAE'),
    'CA': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Canada'),
    'AU': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Australia'),
  };

  @override
  void onInit() {
    super.onInit();
    _initDropDownAPIs();

    // Add listeners for form validation
    for (var controller in [
      businessNameController,
      emailController,
      phoneController,
      passwordController,
      addressController,
      aboutCompanyController,
    ]) {
      controller.addListener(validateForm);
    }
  }

  @override
  void onClose() {
    businessNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    addressController.dispose();
    aboutCompanyController.dispose();
    super.onClose();
  }

  /// Initialize dropdown APIs - load countries for Pakistan cities
  void _initDropDownAPIs() {
    getAllCountries();
  }

  /// Get all countries
  Future<void> getAllCountries() async {
    final response = await systemConfigUseCases.getAllCountries();
    response.fold(
      (error) => debugPrint('❌ Error loading countries: ${error.description}'),
      (success) {
        countryList = success;
        // Auto-select Pakistan and load its states
        final pakistan = countryList.firstWhereOrNull(
          (c) => c.name?.toLowerCase() == 'pakistan',
        );
        if (pakistan != null) {
          getAllStates(pakistan.id ?? 0);
        }
        update();
      },
    );
  }

  /// Get all states for a country
  Future<void> getAllStates(int countryId) async {
    stateList.clear();
    final response = await systemConfigUseCases.getAllStates(countryId: countryId);
    response.fold(
      (error) => debugPrint('❌ Error loading states: ${error.description}'),
      (success) {
        stateList = success;
        update();
      },
    );
  }

  /// Get all cities for a state
  Future<void> getAllCities(BuildContext context, int stateId) async {
    AppUtils.onLoading(context);
    cityList.clear();
    final response = await systemConfigUseCases.getAllCities(stateId: stateId);
    AppUtils.dismissLoader(context);
    response.fold(
      (error) => debugPrint('❌ Error loading cities: ${error.description}'),
      (success) {
        cityList = success;
        update();
      },
    );
  }

  /// Handle state change
  void onStateChanged(AllStates state, BuildContext context) {
    stateController.value = state;
    cityController.clear();
    cityList.clear();
    selectedCityId = 0;
    selectedCityName.value = '';
    getAllCities(context, state.id ?? 0);
    validateForm();
    update();
  }

  /// Handle city change
  void onCityChanged(AllCities city) {
    cityController.value = city;
    selectedCityId = city.id ?? 0;
    selectedCityName.value = city.name ?? '';
    validateForm();
    update();
  }

  /// Toggle password visibility
  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Toggle terms agreement
  void toggleTermsAgreement(bool value) {
    isTermsAgree.value = value;
    validateForm();
    update();
  }

  /// Toggle service charges (Yes/No)
  void toggleServiceCharges(bool value) {
    serviceCharges.value = value;
    update();
  }

  /// Validate form
  void validateForm() {
    final isValid = businessNameController.text.trim().isNotEmpty &&
        emailController.text.trim().isNotEmpty &&
        phoneController.text.trim().isNotEmpty &&
        passwordController.text.trim().isNotEmpty &&
        addressController.text.trim().isNotEmpty &&
        selectedCityId > 0 &&
        isTermsAgree.value;

    isFormValid.value = isValid;
    update();
  }

  /// Validate required field
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validate email
  String? validateEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value.trim())) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validate password
  String? validatePassword(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  /// Validate phone number
  String? validatePhone(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'Phone number is required';
    }

    final rule = phoneValidationRules[countryISOCode.value];
    if (rule != null) {
      if (phone.number.length < rule.minLength) {
        return 'Phone must be at least ${rule.minLength} digits';
      }
      if (phone.number.length > rule.maxLength) {
        return 'Phone must be at most ${rule.maxLength} digits';
      }
    }
    return null;
  }

  /// Validate city selection
  String? validateCity() {
    if (selectedCityId <= 0) {
      return 'Please select a city';
    }
    return null;
  }

  /// Show photo picker options (reusable)
  void showLogoOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Logo',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildOptionButton(
                    context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () {
                      Navigator.pop(context);
                      pickLogo(ImageSource.camera);
                    },
                  ),
                  _buildOptionButton(
                    context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () {
                      Navigator.pop(context);
                      pickLogo(ImageSource.gallery);
                    },
                  ),
                  if (logoFile.value != null)
                    _buildOptionButton(
                      context,
                      icon: Icons.delete,
                      label: 'Remove',
                      color: Colors.red,
                      onTap: () {
                        Navigator.pop(context);
                        removeLogo();
                      },
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: (color ?? AppColors.primaryColor).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color ?? AppColors.primaryColor, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color ?? Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Pick logo image
  Future<void> pickLogo(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        logoFile.value = File(pickedFile.path);
        logoError.value = '';
        validateForm();
        update();
      }
    } catch (e) {
      logoError.value = 'Failed to pick image';
      debugPrint('❌ Error picking logo: $e');
    }
  }

  /// Remove logo
  void removeLogo() {
    logoFile.value = null;
    logoError.value = '';
    update();
  }

  /// Clear form data
  void clearFormData() {
    businessNameController.clear();
    emailController.clear();
    phoneController.clear();
    passwordController.clear();
    addressController.clear();
    aboutCompanyController.clear();

    countryCode.value = '+92';
    countryISOCode.value = 'PK';
    isTermsAgree.value = false;
    isFormValid.value = false;
    isPasswordVisible.value = false;
    serviceCharges.value = false;

    logoFile.value = null;
    logoError.value = '';

    selectedCityId = 0;
    selectedCityName.value = '';
    stateController.clear();
    cityController.clear();
    cityList.clear();

    update();
  }

  /// Register vendor (Matrimonial account)
  Future<void> registerVendor(BuildContext context) async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (selectedCityId <= 0) {
      AppUtils.failedData(
        title: "Validation Error",
        message: "Please select a city",
      );
      return;
    }

    if (!isTermsAgree.value) {
      AppUtils.failedData(
        title: "Terms Required",
        message: "Please accept the Terms & Conditions",
      );
      return;
    }

    // Logo validation - required
    if (logoFile.value == null) {
      AppUtils.failedData(
        title: "Logo Required",
        message: "Please upload your business logo",
      );
      return;
    }

    isLoading.value = true;

    // Convert logo to base64 with Data URI format (required by backend)
    // Backend expects: "data:image/jpeg;base64,<actual_base64_data>"
    String? logoBase64;
    if (logoFile.value != null) {
      try {
        List<int> imageBytes = await logoFile.value!.readAsBytes();
        String base64String = base64Encode(imageBytes);
        // Add Data URI prefix - backend splits by ";base64," and uses index [1]
        logoBase64 = 'data:image/jpeg;base64,$base64String';
        debugPrint('✅ Logo converted to base64 with Data URI format');
      } catch (e) {
        debugPrint('❌ Error converting logo to base64: $e');
        logoError.value = 'Failed to process image';
      }
    }

    // Build payload with all required fields
    final Map<String, dynamic> payload = {
      'Vender_business_name': businessNameController.text.trim(),
      'Vender_email': emailController.text.trim(),
      'Vender_phone': '${countryCode.value}${phoneController.text.trim()}',
      'Vender_password': passwordController.text.trim(),
      'Vender_city': selectedCityId,
      'Vender_address': addressController.text.trim(),
      'about_company': aboutCompanyController.text.trim(),
      'service_charges': serviceCharges.value,
      'terms': true,
      'role_id': 3,
      "Vender_cat_ID": 1,// Always 3 for Matrimonial
      'logo': logoBase64 ?? '',

    };


    debugPrint('📦 Vendor Registration Payload: $payload');

    final response = await userManagementUseCase.registerVendor(payload: payload);
    isLoading.value = false;

    response.fold(
      (error) {
        AppUtils.failedData(
          title: error.title,
          message: error.description,
        );
      },
      (success) {
        _showRegistrationSuccessDialog();
      },
    );
  }

  /// Show registration success dialog
  void _showRegistrationSuccessDialog() {
    Get.defaultDialog(
      title: '',
      barrierDismissible: false,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle_rounded, size: 48, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'Registration Successful',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text(
            'آپ کا میٹری مونیل اکاؤنٹ کامیابی سے بن گیا ہے۔\nبرائے مہربانی اپنی ای میل چیک کریں۔',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, height: 1.5),
          ),
          const SizedBox(height: 10),
          const Text(
            'Your Matrimonial account has been created successfully.\nPlease check your email for verification.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 12, height: 1.5, color: Colors.black54),
          ),
          const SizedBox(height: 24),
          CustomButton(
            text: "OK",
            isGradient: true,
            isEnable: true,
            fontColor: AppColors.whiteColor,
            onTap: () {
              clearFormData();
              Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
            },
          ),
        ],
      ),
    );
  }
}

/// Phone validation rule model (reused from SignupViewModel)
class PhoneValidationRule {
  final int minLength;
  final int maxLength;
  final String countryName;

  PhoneValidationRule({
    required this.minLength,
    required this.maxLength,
    required this.countryName,
  });
}
