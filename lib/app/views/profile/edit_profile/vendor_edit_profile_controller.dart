import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/export.dart';
import '../../../domain/use_cases/user_management_use_case/user_management_use_case.dart';
import '../../../domain/use_cases/system_config_use_case/system_config_use_case.dart';
import '../../../utils/exports.dart';
import '../../../viewmodels/signup_viewmodel.dart';

/// Controller for Vendor Edit Profile (Matrimonial users)
/// Uses same field designs as EditProfileController
class VendorEditProfileController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  
  RxBool isLoading = true.obs;
  RxBool isUpdating = false.obs;
  
  var vendorProfile = Rx<VendorOwnProfile?>(null);
  
  // Form key
  final formKey = GlobalKey<FormState>();
  final generalInfoFormKey = GlobalKey<FormState>();
  
  // Text controllers for editable fields
  final businessNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final aboutCompanyController = TextEditingController();
  
  // Service Charges toggle
  RxBool serviceChargesEnabled = false.obs;
  
  // Phone validation
  var countryCode = 'PK'.obs;
  var phoneNumber = ''.obs;
  
  // Phone validation rules (same as EditProfileController)
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
  
  /// Validate phone number with PhoneNumber object from IntlPhoneField
  String? validatePhone(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'Phone number is required';
    }
    
    final rule = phoneValidationRules[phone.countryISOCode];
    if (rule != null) {
      if (phone.number.length < rule.minLength) {
        return 'Phone number must be at least ${rule.minLength} digits for ${rule.countryName}';
      }
      if (phone.number.length > rule.maxLength) {
        return 'Phone number must be at most ${rule.maxLength} digits for ${rule.countryName}';
      }
    } else {
      // Default validation for countries not in the list
      if (phone.number.length < 7) {
        return 'Phone number is too short';
      }
      if (phone.number.length > 15) {
        return 'Phone number is too long';
      }
    }
    return null;
  }
  
  // Location - same approach as EditProfileController
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];
  
  String selectedCountryName = '';
  int selectedCountryId = 0;
  final stateController = SingleSelectController<AllStates>(null);
  final cityController = SingleSelectController<AllCities>(null);
  int selectedCityId = 0;

  @override
  void onInit() {
    super.onInit();
    loadVendorProfile();
    loadCountries();
  }

  @override
  void onClose() {
    businessNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    addressController.dispose();
    aboutCompanyController.dispose();
    super.onClose();
  }

  /// Load countries list
  Future<void> loadCountries() async {
    final response = await systemConfigUseCases.getAllCountries();
    response.fold(
      (error) => debugPrint('❌ Error loading countries: ${error.description}'),
      (success) {
        countryList = success;
        update();
      },
    );
  }

  /// Load states for selected country (by ID)
  Future<void> getAllStates(BuildContext context, int countryId) async {
    AppUtils.onLoading(context);
    stateList.clear();
    final response = await systemConfigUseCases.getAllStates(countryId: countryId);
    response.fold(
      (error) {
        AppUtils.dismissLoader(context);
        debugPrint('❌ Error loading states: ${error.description}');
      },
      (success) {
        AppUtils.dismissLoader(context);
        if (success.isNotEmpty) {
          stateList.addAll(success);
          update();
        }
      },
    );
  }

  /// Load cities for selected state (by ID)
  Future<void> getAllCities(BuildContext context, int stateId) async {
    AppUtils.onLoading(context);
    cityList.clear();
    final response = await systemConfigUseCases.getAllCities(stateId: stateId);
    response.fold(
      (error) {
        AppUtils.dismissLoader(context);
        debugPrint('❌ Error loading cities: ${error.description}');
      },
      (success) {
        AppUtils.dismissLoader(context);
        if (success.isNotEmpty) {
          cityList.addAll(success);
          update();
        }
      },
    );
  }

  /// Handle country change
  void onCountryChanged(AllCountries country, BuildContext context) {
    selectedCountryName = country.name ?? '';
    selectedCountryId = country.id ?? 0;
    stateController.clear();
    cityController.clear();
    stateList.clear();
    cityList.clear();
    getAllStates(context, selectedCountryId);
    update();
  }

  /// Handle state change
  void onStateChanged(AllStates state, BuildContext context) {
    stateController.value = state;
    cityController.clear();
    cityList.clear();
    getAllCities(context, state.id ?? 0);
    update();
  }

  /// Handle city change
  void onCityChanged(AllCities city) {
    cityController.value = city;
    selectedCityId = city.id ?? 0;
    update();
  }

  /// Load vendor profile data
  Future<void> loadVendorProfile() async {
    isLoading.value = true;
    
    final response = await userManagementUseCases.getVendorOwnProfile();
    response.fold(
      (error) {
        debugPrint('❌ Error loading vendor profile: ${error.description}');
        isLoading.value = false;
        AppUtils.failedData(
          title: "Error",
          message: "Failed to load profile data",
        );
      },
      (success) {
        vendorProfile.value = success;
        _populateFields(success);
        isLoading.value = false;
        update();
      },
    );
  }

  /// Populate text fields with vendor data
  void _populateFields(VendorOwnProfile profile) {
    businessNameController.text = profile.venderBusinessName ?? '';
    emailController.text = profile.venderEmail ?? '';
    phoneController.text = profile.venderPhone ?? '';
    addressController.text = profile.venderAddress ?? '';
    aboutCompanyController.text = profile.aboutCompany ?? '';
    
    // Service charges
    serviceChargesEnabled.value = profile.serviceCharges?.toLowerCase() == 'true' || 
                                   profile.serviceCharges == '1';
    
    // Location - pre-fill country name from profile (display only until user changes)
    selectedCountryName = profile.vendorCountryName ?? '';
  }

  /// Update vendor profile (business info)
  Future<void> updateVendorProfile(BuildContext context) async {
    if (vendorProfile.value == null) return;
    
    AppUtils.onLoading(context);
    
    final payload = {
      'Vender_ID': vendorProfile.value!.venderId,
      'Vender_business_name': businessNameController.text.trim(),
      'Vender_phone': phoneController.text.trim(),
      'Vender_address': addressController.text.trim(),
      'about_company': aboutCompanyController.text.trim(),
      'service_charges': serviceChargesEnabled.value ? 'true' : 'false',
    };

    final response = await userManagementUseCases.updateVendorProfile(payload: payload);
    
    response.fold(
      (error) {
        AppUtils.dismissLoader(context);
        debugPrint('❌ Error updating vendor profile: ${error.description}');
        AppUtils.failedData(
          title: "Update Failed",
          message: error.description.isNotEmpty ? error.description : "Failed to update profile",
        );
      },
      (success) {
        AppUtils.dismissLoader(context);
        debugPrint('✅ Vendor profile updated successfully');
        AppUtils.successData(
          title: "Success",
          message: "Profile updated successfully",
        );
        loadVendorProfile();
      },
    );
  }

  /// Update all profile info (business info + location) with single button
  Future<void> updateAllProfile(BuildContext context) async {
    if (vendorProfile.value == null) return;
    
    // Get existing values from profile if user hasn't changed them
    final countryName = selectedCountryName.isNotEmpty 
        ? selectedCountryName 
        : vendorProfile.value?.vendorCountryName ?? '';
    final stateName = stateController.value?.name ?? vendorProfile.value?.vendorStateName ?? '';
    final cityName = cityController.value?.name ?? vendorProfile.value?.vendorCityName ?? '';
    
    // Validate location fields - check both new selections and existing profile values
    if (countryName.isEmpty || stateName.isEmpty || cityName.isEmpty) {
      AppUtils.failedData(
        title: "Validation Error",
        message: "Please select Country, State and City",
      );
      return;
    }
    
    AppUtils.onLoading(context);
    
    // Combined payload with all fields - use existing values if not changed
    final payload = {
      'Vender_ID': vendorProfile.value!.venderId,
      'Vender_business_name': businessNameController.text.trim(),
      'Vender_phone': phoneNumber.value.isNotEmpty ? phoneNumber.value : phoneController.text.trim(),
      'Vender_address': addressController.text.trim(),
      'about_company': aboutCompanyController.text.trim(),
      'service_charges': serviceChargesEnabled.value ? 'true' : 'false',
      'VendorCountryName': countryName,
      'VendorStateName': stateName,
      'VendorCityName': cityName,
      'cityid': selectedCityId > 0 ? selectedCityId : null,
    };

    final response = await userManagementUseCases.updateVendorProfile(payload: payload);
    
    response.fold(
      (error) {
        AppUtils.dismissLoader(context);
        debugPrint('❌ Error updating profile: ${error.description}');
        AppUtils.failedData(
          title: "Update Failed",
          message: error.description.isNotEmpty ? error.description : "Failed to update profile",
        );
      },
      (success) {
        AppUtils.dismissLoader(context);
        debugPrint('✅ Profile updated successfully');
        AppUtils.successData(
          title: "Success",
          message: "Profile updated successfully",
        );
        loadVendorProfile();
      },
    );
  }
}
