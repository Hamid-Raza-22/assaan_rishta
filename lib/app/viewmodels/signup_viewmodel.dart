// lib/app/viewmodels/signup_viewmodel.dart
import 'dart:convert';
import 'dart:io';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../core/export.dart';

import '../domain/export.dart';
import '../utils/exports.dart';
import '../widgets/custom_button.dart';

class SignupViewModel extends GetxController {
  // Form keys
  final formKey = GlobalKey<FormState>();
  final basicInfoFormKey = GlobalKey<FormState>();
  final otherInfoFormKey = GlobalKey<FormState>();

  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final userManagementUseCase = Get.find<UserManagementUseCase>();

  // Text controllers - initialized once and reused
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController();
  RxString countryCode = '+92'.obs;
  RxString countryISOCode = 'PK'.obs; // Store ISO code for validation

  final dobTEC = TextEditingController();
  final passwordController = TextEditingController();
  final aboutYourSelfTEC = TextEditingController();
  final aboutYourPartnerTEC = TextEditingController();

  // Other observables
  Rx<DateTime> dobController = DateTime
      .now()
      .obs;
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var selectedGender = 'Male'.obs;
  var isFormValid = false.obs;
  RxBool isTermsAgree = true.obs;
  RxBool isProfileBlur = false.obs; // Profile blur option for female users
  
  // Photo picker
  final ImagePicker _picker = ImagePicker();
  Rx<File?> profilePhoto = Rx<File?>(null);
  RxString photoError = ''.obs;

  // Lists (these stay populated)
  final maritalStatusList = ['Single', 'Married', 'Divorced', 'Widow/Widower'];
  final religionList = [
    'Muslim-Suni',
    'Muslim-Brelvi',
    'Muslim-Deobandi',
    'Muslim-AhleHadees',
    'Muslim-Other'
  ];
  List<String> casteList = [];
  List<String> educationList = [];
  List<String> occupationList = [];
  List<String> heightList = [];
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];

  // Selected values
  var selectedMaritalStatus = ''.obs;
  var selectedReligion = ''.obs;
  var selectedCaste = ''.obs;
  var selectedEducation = ''.obs;
  var selectedOccupation = ''.obs;
  var selectedHeight = ''.obs;
  var selectedCountry = ''.obs;
  var selectedState = ''.obs;
  var selectedCity = ''.obs;
  int cityId = 0;

  final stateController = SingleSelectController<AllStates>(null);
  final cityController = SingleSelectController<AllCities>(null);

  @override
  void onInit() {
    super.onInit();
    _generateHeightList();
    _initDropDownAPIs();

    // Add listeners for form validation
    for (var controller in [
      firstNameController,
      lastNameController,
      emailController,
      phoneController,
      dobTEC,
      passwordController
    ]) {
      controller.addListener(validateForm);
    }
  }

  // Photo picker methods
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (pickedFile != null) {
        profilePhoto.value = File(pickedFile.path);
        photoError.value = '';
      }
    } catch (e) {
      photoError.value = 'Failed to pick image';
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> pickImageFromCamera() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      
      if (pickedFile != null) {
        profilePhoto.value = File(pickedFile.path);
        photoError.value = '';
      }
    } catch (e) {
      photoError.value = 'Failed to capture image';
      debugPrint('Error capturing image: $e');
    }
  }

  void removePhoto() {
    profilePhoto.value = null;
    photoError.value = '';
  }

  void showPhotoOptions(BuildContext context) {
    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Add Profile Photo',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.camera_alt, color: AppColors.primaryColor),
              ),
              title: Text('Take Photo'),
              onTap: () {
                Get.back();
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.photo_library, color: AppColors.secondaryColor),
              ),
              title: Text('Choose from Gallery'),
              onTap: () {
                Get.back();
                pickImageFromGallery();
              },
            ),
            if (profilePhoto.value != null)
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.delete, color: Colors.red),
                ),
                title: Text('Remove Photo'),
                onTap: () {
                  Get.back();
                  removePhoto();
                },
              ),
            SizedBox(height: 10),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  // Call this method to clear form data for a new signup
  void clearFormData() {
    // Clear text controllers
    firstNameController.clear();
    lastNameController.clear();
    emailController.clear();
    phoneController.clear();
    dobTEC.clear();
    passwordController.clear();
    aboutYourSelfTEC.clear();
    aboutYourPartnerTEC.clear();

    // Reset selections
    selectedGender.value = 'Male';
    selectedMaritalStatus.value = '';
    selectedReligion.value = '';
    selectedCaste.value = '';
    selectedEducation.value = '';
    selectedOccupation.value = '';
    selectedHeight.value = '';
    selectedCountry.value = '';
    selectedState.value = '';
    selectedCity.value = '';
    cityId = 0;
    isTermsAgree.value = true;
    isFormValid.value = false;
    isProfileBlur.value = false;
    dobController.value = DateTime.now();
    
    // Clear photo
    profilePhoto.value = null;
    photoError.value = '';

    // Clear dependent lists
    stateList.clear();
    cityList.clear();

    // Reset dropdown controllers
    stateController.clear();
    cityController.clear();

    // Update UI
    update();
  }

  final Map<String, PhoneValidationRule> phoneValidationRules = {
    // A Countries
    'AD': PhoneValidationRule(minLength: 6, maxLength: 9, countryName: 'Andorra'),
    'AE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'United Arab Emirates'),
    'AF': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Afghanistan'),
    'AG': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Antigua and Barbuda'),
    'AI': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Anguilla'),
    'AL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Albania'),
    'AM': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Armenia'),
    'AO': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Angola'),
    'AR': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Argentina'),
    'AS': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'American Samoa'),
    'AT': PhoneValidationRule(minLength: 10, maxLength: 13, countryName: 'Austria'),
    'AU': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Australia'),
    'AW': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Aruba'),
    'AX': PhoneValidationRule(minLength: 6, maxLength: 12, countryName: 'Åland Islands'),
    'AZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Azerbaijan'),

    // B Countries
    'BA': PhoneValidationRule(minLength: 8, maxLength: 9, countryName: 'Bosnia and Herzegovina'),
    'BB': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Barbados'),
    'BD': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Bangladesh'),
    'BE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Belgium'),
    'BF': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Burkina Faso'),
    'BG': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Bulgaria'),
    'BH': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Bahrain'),
    'BI': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Burundi'),
    'BJ': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Benin'),
    'BL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Saint Barthélemy'),
    'BM': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Bermuda'),
    'BN': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Brunei'),
    'BO': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Bolivia'),
    'BQ': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Caribbean Netherlands'),
    'BR': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Brazil'),
    'BS': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Bahamas'),
    'BT': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Bhutan'),
    'BW': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Botswana'),
    'BY': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Belarus'),
    'BZ': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Belize'),

    // C Countries
    'CA': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Canada'),
    'CC': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Cocos Islands'),
    'CD': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Congo (DRC)'),
    'CF': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Central African Republic'),
    'CG': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Congo (Republic)'),
    'CH': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Switzerland'),
    'CI': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Côte d\'Ivoire'),
    'CK': PhoneValidationRule(minLength: 5, maxLength: 5, countryName: 'Cook Islands'),
    'CL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Chile'),
    'CM': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Cameroon'),
    'CN': PhoneValidationRule(minLength: 11, maxLength: 11, countryName: 'China'),
    'CO': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Colombia'),
    'CR': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Costa Rica'),
    'CU': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Cuba'),
    'CV': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Cape Verde'),
    'CW': PhoneValidationRule(minLength: 7, maxLength: 8, countryName: 'Curaçao'),
    'CX': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Christmas Island'),
    'CY': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Cyprus'),
    'CZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Czech Republic'),

    // D Countries
    'DE': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Germany'),
    'DJ': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Djibouti'),
    'DK': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Denmark'),
    'DM': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Dominica'),
    'DO': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Dominican Republic'),
    'DZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Algeria'),

    // E Countries
    'EC': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Ecuador'),
    'EE': PhoneValidationRule(minLength: 7, maxLength: 8, countryName: 'Estonia'),
    'EG': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Egypt'),
    'EH': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Western Sahara'),
    'ER': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Eritrea'),
    'ES': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Spain'),
    'ET': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Ethiopia'),

    // F Countries
    'FI': PhoneValidationRule(minLength: 9, maxLength: 11, countryName: 'Finland'),
    'FJ': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Fiji'),
    'FK': PhoneValidationRule(minLength: 5, maxLength: 5, countryName: 'Falkland Islands'),
    'FM': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Micronesia'),
    'FO': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'Faroe Islands'),
    'FR': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'France'),

    // G Countries
    'GA': PhoneValidationRule(minLength: 7, maxLength: 8, countryName: 'Gabon'),
    'GB': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'United Kingdom'),
    'GD': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Grenada'),
    'GE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Georgia'),
    'GF': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'French Guiana'),
    'GG': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Guernsey'),
    'GH': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Ghana'),
    'GI': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Gibraltar'),
    'GL': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'Greenland'),
    'GM': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Gambia'),
    'GN': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Guinea'),
    'GP': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Guadeloupe'),
    'GQ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Equatorial Guinea'),
    'GR': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Greece'),
    'GT': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Guatemala'),
    'GU': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Guam'),
    'GW': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Guinea-Bissau'),
    'GY': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Guyana'),

    // H Countries
    'HK': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Hong Kong'),
    'HN': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Honduras'),
    'HR': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Croatia'),
    'HT': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Haiti'),
    'HU': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Hungary'),

    // I Countries
    'ID': PhoneValidationRule(minLength: 10, maxLength: 12, countryName: 'Indonesia'),
    'IE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Ireland'),
    'IL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Israel'),
    'IM': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Isle of Man'),
    'IN': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'India'),
    'IO': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'British Indian Ocean Territory'),
    'IQ': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Iraq'),
    'IR': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Iran'),
    'IS': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Iceland'),
    'IT': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Italy'),

    // J Countries
    'JE': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Jersey'),
    'JM': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Jamaica'),
    'JO': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Jordan'),
    'JP': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Japan'),

    // K Countries
    'KE': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Kenya'),
    'KG': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Kyrgyzstan'),
    'KH': PhoneValidationRule(minLength: 8, maxLength: 9, countryName: 'Cambodia'),
    'KI': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Kiribati'),
    'KM': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Comoros'),
    'KN': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Saint Kitts and Nevis'),
    'KP': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'North Korea'),
    'KR': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'South Korea'),
    'KW': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Kuwait'),
    'KY': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Cayman Islands'),
    'KZ': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Kazakhstan'),

    // L Countries
    'LA': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Laos'),
    'LB': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Lebanon'),
    'LC': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Saint Lucia'),
    'LI': PhoneValidationRule(minLength: 7, maxLength: 9, countryName: 'Liechtenstein'),
    'LK': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Sri Lanka'),
    'LR': PhoneValidationRule(minLength: 8, maxLength: 9, countryName: 'Liberia'),
    'LS': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Lesotho'),
    'LT': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Lithuania'),
    'LU': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Luxembourg'),
    'LV': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Latvia'),
    'LY': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Libya'),

    // M Countries
    'MA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Morocco'),
    'MC': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Monaco'),
    'MD': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Moldova'),
    'ME': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Montenegro'),
    'MF': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Saint Martin'),
    'MG': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Madagascar'),
    'MH': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Marshall Islands'),
    'MK': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'North Macedonia'),
    'ML': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Mali'),
    'MM': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Myanmar'),
    'MN': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Mongolia'),
    'MO': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Macau'),
    'MP': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Northern Mariana Islands'),
    'MQ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Martinique'),
    'MR': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Mauritania'),
    'MS': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Montserrat'),
    'MT': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Malta'),
    'MU': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Mauritius'),
    'MV': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Maldives'),
    'MW': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Malawi'),
    'MX': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Mexico'),
    'MY': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Malaysia'),
    'MZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Mozambique'),

    // N Countries
    'NA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Namibia'),
    'NC': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'New Caledonia'),
    'NE': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Niger'),
    'NF': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'Norfolk Island'),
    'NG': PhoneValidationRule(minLength: 10, maxLength: 11, countryName: 'Nigeria'),
    'NI': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Nicaragua'),
    'NL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Netherlands'),
    'NO': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Norway'),
    'NP': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Nepal'),
    'NR': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Nauru'),
    'NU': PhoneValidationRule(minLength: 4, maxLength: 4, countryName: 'Niue'),
    'NZ': PhoneValidationRule(minLength: 8, maxLength: 10, countryName: 'New Zealand'),

    // O Countries
    'OM': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Oman'),

    // P Countries
    'PA': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Panama'),
    'PE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Peru'),
    'PF': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'French Polynesia'),
    'PG': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Papua New Guinea'),
    'PH': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Philippines'),
    'PK': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Pakistan'),
    'PL': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Poland'),
    'PM': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'Saint Pierre and Miquelon'),
    'PR': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Puerto Rico'),
    'PS': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Palestine'),
    'PT': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Portugal'),
    'PW': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Palau'),
    'PY': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Paraguay'),

    // Q Countries
    'QA': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Qatar'),

    // R Countries
    'RE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Réunion'),
    'RO': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Romania'),
    'RS': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Serbia'),
    'RU': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Russia'),
    'RW': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Rwanda'),

    // S Countries
    'SA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Saudi Arabia'),
    'SB': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Solomon Islands'),
    'SC': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Seychelles'),
    'SD': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Sudan'),
    'SE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Sweden'),
    'SG': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Singapore'),
    'SH': PhoneValidationRule(minLength: 4, maxLength: 4, countryName: 'Saint Helena'),
    'SI': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Slovenia'),
    'SJ': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Svalbard and Jan Mayen'),
    'SK': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Slovakia'),
    'SL': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Sierra Leone'),
    'SM': PhoneValidationRule(minLength: 8, maxLength: 10, countryName: 'San Marino'),
    'SN': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Senegal'),
    'SO': PhoneValidationRule(minLength: 8, maxLength: 9, countryName: 'Somalia'),
    'SR': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Suriname'),
    'SS': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'South Sudan'),
    'ST': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'São Tomé and Príncipe'),
    'SV': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'El Salvador'),
    'SX': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Sint Maarten'),
    'SY': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Syria'),
    'SZ': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Eswatini'),

    // T Countries
    'TC': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Turks and Caicos Islands'),
    'TD': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Chad'),
    'TG': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Togo'),
    'TH': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Thailand'),
    'TJ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Tajikistan'),
    'TK': PhoneValidationRule(minLength: 4, maxLength: 4, countryName: 'Tokelau'),
    'TL': PhoneValidationRule(minLength: 7, maxLength: 8, countryName: 'Timor-Leste'),
    'TM': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Turkmenistan'),
    'TN': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Tunisia'),
    'TO': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Tonga'),
    'TR': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Turkey'),
    'TT': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Trinidad and Tobago'),
    'TV': PhoneValidationRule(minLength: 6, maxLength: 7, countryName: 'Tuvalu'),
    'TW': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Taiwan'),
    'TZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Tanzania'),

    // U Countries
    'UA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Ukraine'),
    'UG': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Uganda'),
    'US': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'United States'),
    'UY': PhoneValidationRule(minLength: 8, maxLength: 8, countryName: 'Uruguay'),
    'UZ': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Uzbekistan'),

    // V Countries
    'VA': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Vatican City'),
    'VC': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Saint Vincent and the Grenadines'),
    'VE': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Venezuela'),
    'VG': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'British Virgin Islands'),
    'VI': PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'U.S. Virgin Islands'),
    'VN': PhoneValidationRule(minLength: 9, maxLength: 10, countryName: 'Vietnam'),
    'VU': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Vanuatu'),

    // W Countries
    'WF': PhoneValidationRule(minLength: 6, maxLength: 6, countryName: 'Wallis and Futuna'),
    'WS': PhoneValidationRule(minLength: 7, maxLength: 7, countryName: 'Samoa'),

    // Y Countries
    'YE': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Yemen'),
    'YT': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Mayotte'),

    // Z Countries
    'ZA': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'South Africa'),
    'ZM': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Zambia'),
    'ZW': PhoneValidationRule(minLength: 9, maxLength: 9, countryName: 'Zimbabwe'),
  };

  // Updated validatePhone method
  String? validatePhone(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'Phone number is required';
    }

    // Get validation rule for current country (using ISO code)
    final rule = phoneValidationRules[countryISOCode.value] ??
        PhoneValidationRule(minLength: 10, maxLength: 10, countryName: 'Pakistan');

    // Clean the phone number (remove spaces, dashes, etc.)
    final cleanNumber = phone.number.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.length < rule.minLength) {
      return 'Phone number must be at least ${rule.minLength} digits for ${rule.countryName}';
    }

    if (cleanNumber.length > rule.maxLength) {
      return 'Phone number must not exceed ${rule.maxLength} digits for ${rule.countryName}';
    }

    // Additional format validation for specific countries
    if (!_isValidPhoneFormat(cleanNumber, countryISOCode.value)) {
      return 'Invalid phone number format for ${rule.countryName}';
    }

    return null;
  }

  // Helper method for country-specific format validation
  bool _isValidPhoneFormat(String number, String countryISO) {
    // Remove any non-digit characters
    final digitsOnly = number.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.isEmpty) return false;

    switch (countryISO) {
      case 'PK':
      // Pakistan: Mobile numbers must start with 3
        return digitsOnly.startsWith('3') && digitsOnly.length == 10;

      case 'IN':
      // India: Mobile numbers must start with 6-9
        if (digitsOnly.length != 10) return false;
        final firstDigit = int.tryParse(digitsOnly[0]) ?? 0;
        return firstDigit >= 6 && firstDigit <= 9;

      case 'US':
      case 'CA':
      // US/Canada: Cannot start with 0 or 1
        if (digitsOnly.length != 10) return false;
        return !digitsOnly.startsWith('0') && !digitsOnly.startsWith('1');

      case 'GB':
      // UK: Mobile numbers typically start with 7
        return digitsOnly.startsWith('7') || digitsOnly.length == 11;

      case 'AE':
      case 'SA':
      // UAE/Saudi Arabia: Mobile numbers start with 5
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('5');

      case 'BD':
      // Bangladesh: Mobile numbers start with 1
        return digitsOnly.startsWith('1');

      case 'EG':
      // Egypt: Mobile numbers start with 1
        if (digitsOnly.length != 10) return false;
        return digitsOnly.startsWith('1');

      case 'NG':
      // Nigeria: Mobile numbers start with 7, 8, or 9
        final firstDigit = digitsOnly[0];
        return (firstDigit == '7' || firstDigit == '8' || firstDigit == '9');

      case 'ZA':
      // South Africa: Mobile numbers start with 6, 7, or 8
        if (digitsOnly.length != 9) return false;
        final firstDigit = digitsOnly[0];
        return (firstDigit == '6' || firstDigit == '7' || firstDigit == '8');

      case 'KE':
      // Kenya: Mobile numbers start with 7 or 1
        return digitsOnly.startsWith('7') || digitsOnly.startsWith('1');

      case 'TR':
      // Turkey: Mobile numbers start with 5
        if (digitsOnly.length != 10) return false;
        return digitsOnly.startsWith('5');

      case 'ID':
      // Indonesia: Mobile numbers start with 8
        return digitsOnly.startsWith('8');

      case 'PH':
      // Philippines: Mobile numbers start with 9
        if (digitsOnly.length != 10) return false;
        return digitsOnly.startsWith('9');

      case 'MY':
      // Malaysia: Mobile numbers start with 1
        return digitsOnly.startsWith('1');

      case 'SG':
      // Singapore: Mobile numbers start with 8 or 9
        if (digitsOnly.length != 8) return false;
        return digitsOnly.startsWith('8') || digitsOnly.startsWith('9');

      case 'TH':
      // Thailand: Mobile numbers start with 6, 8, or 9
        if (digitsOnly.length != 9) return false;
        final firstDigit = digitsOnly[0];
        return (firstDigit == '6' || firstDigit == '8' || firstDigit == '9');

      case 'VN':
      // Vietnam: Mobile numbers start with 3, 7, 8, or 9
        final firstDigit = digitsOnly[0];
        return (firstDigit == '3' || firstDigit == '7' ||
            firstDigit == '8' || firstDigit == '9');

      case 'AU':
      // Australia: Mobile numbers start with 4
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('4');

      case 'NZ':
      // New Zealand: Mobile numbers start with 2
        return digitsOnly.startsWith('2');

      case 'JP':
      // Japan: Mobile numbers start with 70, 80, or 90
        return digitsOnly.startsWith('70') ||
            digitsOnly.startsWith('80') ||
            digitsOnly.startsWith('90');

      case 'KR':
      // South Korea: Mobile numbers start with 1
        return digitsOnly.startsWith('1');

      case 'CN':
      // China: Mobile numbers start with 1
        if (digitsOnly.length != 11) return false;
        return digitsOnly.startsWith('1');

      case 'RU':
      // Russia: Mobile numbers start with 9
        if (digitsOnly.length != 10) return false;
        return digitsOnly.startsWith('9');

      case 'BR':
      // Brazil: Second digit must be 9 for mobile
        if (digitsOnly.length < 10) return false;
        return digitsOnly[1] == '9';

      case 'MX':
      // Mexico: Valid if 10 digits
        return digitsOnly.length == 10;

      case 'FR':
      // France: Mobile numbers start with 6 or 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('6') || digitsOnly.startsWith('7');

      case 'DE':
      // Germany: Mobile numbers start with 15, 16, or 17
        return digitsOnly.startsWith('15') ||
            digitsOnly.startsWith('16') ||
            digitsOnly.startsWith('17');

      case 'IT':
      // Italy: Mobile numbers start with 3
        return digitsOnly.startsWith('3');

      case 'ES':
      // Spain: Mobile numbers start with 6 or 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('6') || digitsOnly.startsWith('7');

      case 'NL':
      // Netherlands: Mobile numbers start with 6
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('6');

      case 'BE':
      // Belgium: Mobile numbers start with 4
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('4');

      case 'CH':
      // Switzerland: Mobile numbers start with 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('7');

      case 'AT':
      // Austria: Mobile numbers start with 6
        return digitsOnly.startsWith('6');

      case 'SE':
      // Sweden: Mobile numbers start with 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('7');

      case 'NO':
      // Norway: Mobile numbers start with 4 or 9
        if (digitsOnly.length != 8) return false;
        return digitsOnly.startsWith('4') || digitsOnly.startsWith('9');

      case 'DK':
      // Denmark: Mobile numbers start with 2, 3, 4, 5, or 6
        if (digitsOnly.length != 8) return false;
        final firstDigit = digitsOnly[0];
        return ['2', '3', '4', '5', '6'].contains(firstDigit);

      case 'FI':
      // Finland: Mobile numbers start with 4 or 5
        return digitsOnly.startsWith('4') || digitsOnly.startsWith('5');

      case 'PL':
      // Poland: Mobile numbers start with 4, 5, 6, 7, or 8
        if (digitsOnly.length != 9) return false;
        final firstDigit = digitsOnly[0];
        return ['4', '5', '6', '7', '8'].contains(firstDigit);

      case 'GR':
      // Greece: Mobile numbers start with 69
        if (digitsOnly.length != 10) return false;
        return digitsOnly.startsWith('69');

      case 'PT':
      // Portugal: Mobile numbers start with 9
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('9');

      case 'IE':
      // Ireland: Mobile numbers start with 8
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('8');

      case 'CZ':
      // Czech Republic: Mobile numbers start with 6 or 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('6') || digitsOnly.startsWith('7');

      case 'RO':
      // Romania: Mobile numbers start with 7
        if (digitsOnly.length != 9) return false;
        return digitsOnly.startsWith('7');

      case 'HU':
      // Hungary: Mobile numbers start with 2, 3, or 7
        if (digitsOnly.length != 9) return false;
        final firstDigit = digitsOnly[0];
        return (firstDigit == '2' || firstDigit == '3' || firstDigit == '7');

      default:
      // For other countries, just validate that number has correct length
        return true;
    }
  }

  // Updated validateForm method
  void validateForm() {
    // Get clean phone number
    final cleanPhone = phoneController.text.replaceAll(RegExp(r'\D'), '');

    // Get validation rule for current country (using ISO code)
    final rule = phoneValidationRules[countryISOCode.value];
    final isPhoneValid = rule != null
        ? (cleanPhone.length >= rule.minLength && cleanPhone.length <= rule.maxLength)
        : cleanPhone.length >= 7;

    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        isPhoneValid &&
        dobTEC.text.isNotEmpty &&
        passwordController.text.isNotEmpty &&
        isTermsAgree.value;
  }


  void togglePasswordVisibility() => isPasswordVisible.toggle();

  void selectGender(String gender) => selectedGender.value = gender;

  Future<void> selectDateOfBirth(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(Duration(days: 6570)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      dobTEC.text = '${picked.day}/${picked.month}/${picked.year}';
      dobController.value = picked;
    }
  }

  // Validation methods
  String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!GetUtils.isEmail(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  // String? validatePhone(PhoneNumber? phone) {
  //   if (phone == null || phone.number.isEmpty) {
  //     return 'Phone number is required';
  //   }
  //   if (phone.number.length < 10) {
  //     return 'Phone number is too short';
  //   }  if (phone.number.length > 10) {
  //     return 'Phone number is too long';
  //   }
  //   return null;
  // }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _generateHeightList() {
    if (heightList.isEmpty) { // Only generate if not already done
      for (int feet = 4; feet <= 7; feet++) {
        for (int inch = 0; inch <= 11; inch++) {
          heightList.add(inch == 0 ? "${feet}ft" : "${feet}ft ${inch}in");
        }
      }
    }
  }

  void _initDropDownAPIs() {
    // Only fetch if lists are empty
    if (casteList.isEmpty) getAllCasts();
    if (educationList.isEmpty) getAllDegrees();
    if (occupationList.isEmpty) getAllOccupations();
    if (countryList.isEmpty) getAllCountries();
  }

  Future<void> signUpUser(context) async {
    isLoading.value = true;

    debugPrint("=== Signup Data ===");
    debugPrint("First Name: ${firstNameController.text}");
    debugPrint("Last Name: ${lastNameController.text}");
    debugPrint("Email: ${emailController.text}");
    debugPrint("Phone: ${phoneController.text}");
    debugPrint("DOB: ${dobTEC.text}");
    debugPrint("Gender: ${selectedGender.value}");

    // Convert profile photo to base64 if available
    String? photoBase64;
    if (profilePhoto.value != null) {
      try {
        List<int> imageBytes = await profilePhoto.value!.readAsBytes();
        photoBase64 = base64Encode(imageBytes);
        debugPrint("Profile photo converted to base64");
      } catch (e) {
        debugPrint("Error converting photo to base64: $e");
        photoError.value = 'Failed to process image';
      }
    }

    final model = SignUpModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      mobileNo: "$countryCode${phoneController.text.trim()}",
      dateOfBirth: dobController.value.toString(),
      password: passwordController.text.trim(),
      gender: selectedGender.value,
      maritalStatus: selectedMaritalStatus.value,
      religion: selectedReligion.value,
      caste: selectedCaste.value,
      education: selectedEducation.value,
      occupation: selectedOccupation.value,
      height: selectedHeight.value,
      terms: isTermsAgree.value,
      city: cityId,
      catename: "",
      userKaTaruf: aboutYourSelfTEC.text,
      userDiWohtiKaTaruf: aboutYourPartnerTEC.text,
      roleId: 2,
      profileBlur: isProfileBlur.value, // Profile blur for female users
    );

    final response = await userManagementUseCase.signUp(signUpModel: model);
    isLoading.value = false;

    response.fold(
          (error) =>
          AppUtils.failedData(title: error.title, message: error.description),
          (success) {
        if (success == "1") {
          waitForAdminApproval();
        } else if (success != "0" || success.contains("exists")) {
          AppUtils.failedData(
              title: "User Already Exists",
              message: "An account with this email/phone already exists"
          );
        } else {
          AppUtils.failedData(
              title: "Oops",
              message: "Something went wrong"
          );
        }
      },
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
          const Text('Awaiting Approval',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
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
            onTap: () {
              // Clear form data for next signup
              clearFormData();
              Get.offAllNamed(AppRoutes.ACCOUNT_TYPE);
            },
          ),
        ],
      ),
    );
  }

  // Your API methods remain the same...
  Future<void> getAllCasts() async {
    if (casteList.isNotEmpty) return; // Don't fetch again if already loaded

    final response = await systemConfigUseCases.getAllCasts();
    response.fold(
          (error) => Left(error),
          (success) {
        if (success.castNames!.isNotEmpty) {
          casteList.addAll(success.castNames!
            ..sort());
          update();
        }
        return Right(success);
      },
    );
  }


  Future<void> getAllDegrees() async {
    educationList.clear();
    final response = await systemConfigUseCases.getAllDegrees();
    response.fold(
          (error) => Left(error),
          (success) {
        if (success.degreeNames!.isNotEmpty) {
          educationList.addAll(success.degreeNames!
            ..sort());
          update();
        }
        return Right(success);
      },
    );
  }

  Future<void> getAllOccupations() async {
    occupationList.clear();
    final response = await systemConfigUseCases.getAllOccupations();
    response.fold(
          (error) => Left(error),
          (success) {
        if (success.occupationNames!.isNotEmpty) {
          occupationList.addAll(success.occupationNames!);
          update();
        }
        return Right(success);
      },
    );
  }

  Future<void> getAllCountries() async {
    countryList.clear();
    final response = await systemConfigUseCases.getAllCountries();
    response.fold(
          (error) => Left(error),
          (success) {
        if (success.isNotEmpty) {
          countryList.addAll(success);
          selectedState = "".obs;
          update();
        }
        return Right(success);
      },
    );
  }

  Future<void> getAllStates(countryId, context) async {
    stateList.clear();
    AppUtils.onLoading(context);
    final response = await systemConfigUseCases.getAllStates(
        countryId: countryId);
    AppUtils.dismissLoader(context);
    response.fold(
          (error) => {},
          (success) {
        if (success.isNotEmpty) {
          stateList.addAll(success);
          update();
        }
      },
    );
  }

  Future<void> getAllCities(stateId, context) async {
    cityList.clear();
    AppUtils.onLoading(context);
    final response = await systemConfigUseCases.getAllCities(stateId: stateId);
    AppUtils.dismissLoader(context);
    response.fold(
          (error) => {},
          (success) {
        if (success.isNotEmpty) {
          cityList.addAll(success);
          update();
        }
      },
    );
  }

}

// PhoneValidationRule Model Class (add at the bottom of the file)
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