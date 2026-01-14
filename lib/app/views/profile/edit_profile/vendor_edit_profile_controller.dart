import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';

import '../../../core/export.dart';
import '../../../core/services/env_config_service.dart';
import '../../../domain/use_cases/user_management_use_case/user_management_use_case.dart';
import '../../../domain/use_cases/system_config_use_case/system_config_use_case.dart';
import '../../../utils/exports.dart';
import '../../../viewmodels/dashboard_viewmodel.dart';
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
  
  // Location - Pakistan only (fixed country)
  static const String PAKISTAN_COUNTRY_NAME = 'Pakistan';
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];
  
  int pakistanCountryId = 0;
  final stateController = SingleSelectController<AllStates>(null);
  final cityController = SingleSelectController<AllCities>(null);
  
  // Store selected IDs for persistence
  int selectedStateId = 0;
  int selectedCityId = 0;
  
  // Store profile's original state/city names for initial restoration
  String? _profileStateName;
  String? _profileCityName;

  @override
  void onInit() {
    super.onInit();
    _initializeData();
  }
  
  /// Initialize data - load profile and Pakistan states
  Future<void> _initializeData() async {
    await loadVendorProfile();
    await _loadPakistanStates();
    // Restore state/city from profile after states are loaded
    await _restoreLocationFromProfile();
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

  /// Load Pakistan states directly (country is fixed to Pakistan)
  Future<void> _loadPakistanStates() async {
    // First get countries to find Pakistan's ID
    final countriesResponse = await systemConfigUseCases.getAllCountries();
    countriesResponse.fold(
      (error) => debugPrint('❌ Error loading countries: ${error.description}'),
      (success) {
        countryList = success;
        // Find Pakistan
        final pakistan = countryList.firstWhereOrNull(
          (c) => c.name?.toLowerCase() == 'pakistan',
        );
        if (pakistan != null) {
          pakistanCountryId = pakistan.id ?? 0;
        }
      },
    );
    
    // Load Pakistan states
    if (pakistanCountryId > 0) {
      final statesResponse = await systemConfigUseCases.getAllStates(countryId: pakistanCountryId);
      statesResponse.fold(
        (error) => debugPrint('❌ Error loading states: ${error.description}'),
        (success) {
          stateList = success;
          update();
        },
      );
    }
  }
  
  /// Restore location (state/city) from profile data
  Future<void> _restoreLocationFromProfile() async {
    if (_profileStateName == null || _profileStateName!.isEmpty) return;
    
    // Find matching state in stateList
    final matchingState = stateList.firstWhereOrNull(
      (s) => s.name?.toLowerCase() == _profileStateName?.toLowerCase(),
    );
    
    if (matchingState != null) {
      stateController.value = matchingState;
      selectedStateId = matchingState.id ?? 0;
      
      // Load cities for this state
      if (selectedStateId > 0) {
        final citiesResponse = await systemConfigUseCases.getAllCities(stateId: selectedStateId);
        citiesResponse.fold(
          (error) => debugPrint('❌ Error loading cities: ${error.description}'),
          (success) {
            cityList = success;
            
            // Find and set matching city
            if (_profileCityName != null && _profileCityName!.isNotEmpty) {
              final matchingCity = cityList.firstWhereOrNull(
                (c) => c.name?.toLowerCase() == _profileCityName?.toLowerCase(),
              );
              if (matchingCity != null) {
                cityController.value = matchingCity;
                selectedCityId = matchingCity.id ?? 0;
              }
            }
            update();
          },
        );
      }
    }
    update();
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

  /// Handle state change - clears city and loads new cities
  void onStateChanged(AllStates state, BuildContext context) {
    stateController.value = state;
    selectedStateId = state.id ?? 0;
    // Clear city when state changes
    cityController.clear();
    cityList.clear();
    selectedCityId = 0;
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
    
    // Store profile's state/city names for restoration
    _profileStateName = profile.vendorStateName;
    _profileCityName = profile.vendorCityName;
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
    
    // Get state/city values - use controller values (which are restored from profile if not changed)
    final stateName = stateController.value?.name ?? '';
    final cityName = cityController.value?.name ?? '';
    
    // Validate location fields
    if (stateName.isEmpty || cityName.isEmpty) {
      AppUtils.failedData(
        title: "Validation Error",
        message: "Please select State and City",
      );
      return;
    }
    
    AppUtils.onLoading(context);
    
    // Use stored city ID (either from selection or restored from profile)
    final cityId = selectedCityId > 0 ? selectedCityId : null;
    
    // Combined payload with all fields - country is always Pakistan
    final payload = {
      'Vender_ID': vendorProfile.value!.venderId,
      "Vender_email": emailController.text.trim(),
      'Vender_business_name': businessNameController.text.trim(),
      'Vender_phone': phoneNumber.value.isNotEmpty ? phoneNumber.value : phoneController.text.trim(),
      'Vender_address': addressController.text.trim(),
      'about_company': aboutCompanyController.text.trim(),
      'service_charges': serviceChargesEnabled.value ? 'true' : 'false',
      'VenderCountryName': PAKISTAN_COUNTRY_NAME,
      "Vender_featured_cat_ID": 0,
      'VenderStateName': stateName,
      'VenderCityName': cityName,
      'Vender_city': cityId?.toString() ?? '',
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
      (success) async {
        AppUtils.dismissLoader(context);
        debugPrint('✅ Profile updated successfully');
        
        // Update Firebase with vendor profile data
        await _updateFirebaseVendorProfile();
        
        // Refresh dashboard to show updated name and image
        if (Get.isRegistered<DashboardController>()) {
          Get.find<DashboardController>().refreshDashboard();
        }
        
        AppUtils.successData(
          title: "Success",
          message: "Profile updated successfully",
        );
        loadVendorProfile();
      },
    );
  }
  
  /// Update vendor profile data in Firebase
  Future<void> _updateFirebaseVendorProfile() async {
    try {
      final vendorId = vendorProfile.value?.venderId?.toString();
      if (vendorId == null || vendorId.isEmpty) {
        debugPrint('❌ Cannot update Firebase: Vendor ID is null');
        return;
      }
      
      final businessName = businessNameController.text.trim();
      final aboutCompany = aboutCompanyController.text.trim();
      final stateName = stateController.value?.name ?? '';
      final cityName = cityController.value?.name ?? '';
      
      debugPrint('🔄 Updating Firebase for vendor: $vendorId');
      debugPrint('📝 Business name: $businessName');
      debugPrint('📝 Location: $cityName, $stateName');
      
      // Update in Firebase users collection
      await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(vendorId)
          .update({
        'name': businessName,
        'about': aboutCompany.isNotEmpty ? aboutCompany : "Matrimonial Service Provider",
        // 'city': cityName,
        // 'state': stateName,
        // 'country': PAKISTAN_COUNTRY_NAME,
        'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
      });
      
      debugPrint('✅ Firebase updated successfully for vendor');
      
    } catch (e) {
      debugPrint('❌ Error updating Firebase: $e');
      // Don't show error to user - Firebase sync is secondary
      // Profile was already updated successfully in backend
    }
  }
}
