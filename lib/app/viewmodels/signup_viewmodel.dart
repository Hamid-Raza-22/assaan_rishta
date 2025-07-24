// lib/app/viewmodels/signup_viewmodel.dart
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../core/export.dart';
import '../data/models/user_model.dart' hide SignUpModel;

import '../domain/export.dart';
import '../utils/exports.dart';
import '../widgets/custom_button.dart';

class SignupViewModel extends GetxController {
  // final AuthRepository _authRepository;
  //
  // SignupViewModel(this._authRepository);

  final formKey = GlobalKey<FormState>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final userManagementUseCase = Get.find<UserManagementUseCase>();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();
  final phoneController = TextEditingController(text: '+92 ');
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final aboutYourSelfTEC = TextEditingController();
  final aboutYourPartnerTEC = TextEditingController();
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;
  var selectedGender = 'Male'.obs;
  var isFormValid = false.obs;
  RxBool isTermsAgree = true.obs;

  @override
  void onInit() {
    _generateHeightList();
    _initDropDownAPIs();
    super.onInit();
    [firstNameController, lastNameController, emailController, phoneController, dobController, passwordController]
        .forEach((controller) => controller.addListener(validateForm));
  }
  // Dummy data lists
  final maritalStatusList =  ['Single', 'Married', 'Divorced', 'Widow/Widower'];
  final religionList =  ['Muslim-Suni', 'Muslim-Brelvi', 'Muslim-Deobandi', 'Muslim-AhleHadees', 'Muslim-Other'];
  List<String> casteList = [];
  List<String> educationList = [];
  List<String>occupationList = [];
  List<String> heightList = [];
  List<AllCountries> countryList = [];
  List<AllStates>stateList = [];
  List<AllCities> cityList = [];
  final basicInfoFormKey = GlobalKey<FormState>();
  final otherInfoFormKey = GlobalKey<FormState>();
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

  // Setters
  void setMaritalStatus(String? value) => selectedMaritalStatus.value = value ?? '';
  void setReligion(String? value) => selectedReligion.value = value ?? '';
  void setCaste(String? value) => selectedCaste.value = value ?? '';
  void setEducation(String? value) => selectedEducation.value = value ?? '';
  void setOccupation(String? value) => selectedOccupation.value = value ?? '';
  void setHeight(String? value) => selectedHeight.value = value ?? '';
  void setCountry(String? value) => selectedCountry.value = value ?? '';
  void setState(String? value) => selectedState.value = value ?? '';
  void setCity(String? value) => selectedCity.value = value ?? '';

  void proceedToNextStep() {
    // Handle saving or passing data to next step
    Get.snackbar("Success", "Info Saved. Moving to next step.");
    // Get.toNamed('/nextStep');
  }
  void _initDropDownAPIs() {
    getAllCasts();
    getAllDegrees();
    getAllOccupations();
    getAllCountries();
  }


  void _generateHeightList() {
    for (int feet = 4; feet <= 7; feet++) {
      for (int inch = 0; inch <= 11; inch++) {
        heightList.add(inch == 0 ? "${feet}ft" : "${feet}ft ${inch}in");
      }
    }
  }

  Future<void> getAllCasts() async {
    casteList.clear();
    final response = await systemConfigUseCases.getAllCasts();
    response.fold(
          (error) => Left(error),
          (success) {
        if (success.castNames!.isNotEmpty) {
          casteList.addAll(success.castNames!..sort());
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
          educationList.addAll(success.degreeNames!..sort());
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
    final response = await systemConfigUseCases.getAllStates(countryId: countryId);
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

  void validateForm() {
    isFormValid.value = firstNameController.text.isNotEmpty &&
        lastNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        phoneController.text.length > 4 &&
        dobController.text.isNotEmpty &&
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
      dobController.text = '${picked.day}/${picked.month}/${picked.year}';
    }
  }
// Validation Methods

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

  String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (value.length < 10) {
      return 'Please enter a valid phone number';
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
  Future<void> signUpUser(context) async {
    isLoading.value = true;
    final model = SignUpModel(
      firstName: firstNameController.text.trim(),
      lastName: lastNameController.text.trim(),
      email: emailController.text.trim(),
      mobileNo: phoneController.text.trim(),
      dateOfBirth: dobController.text.trim(),
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
          (error) => AppUtils.failedData(title: error.title, message: error.description),
          (success) => success == "1" ? waitForAdminApproval() : AppUtils.failedData(title: "Oops", message: "User exists"),
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
            onTap: () => Get.offNamed('/login'),
          ),
        ],
      ),
    );
  }


  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    dobController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
