// lib/app/viewmodels/signup_viewmodel.dart
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../core/export.dart';
import '../data/models/user_model.dart' hide SignUpModel;

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
    [
      firstNameController,
      lastNameController,
      emailController,
      phoneController,
      dobTEC,
      passwordController
    ]
        .forEach((controller) => controller.addListener(validateForm));
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
    dobController.value = DateTime.now();

    // Clear dependent lists
    stateList.clear();
    cityList.clear();

    // Reset dropdown controllers
    stateController.clear();
    cityController.clear();

    // Update UI
    update();
  }

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.length > 4 &&
        dobTEC.text.isNotEmpty &&
        passwordController.text.isNotEmpty;
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

  String? validatePhone(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'Phone number is required';
    }
    if (phone.number.length < 10) {
      return 'Phone number is too short';
    }  if (phone.number.length > 10) {
      return 'Phone number is too long';
    }
    return null;
  }

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