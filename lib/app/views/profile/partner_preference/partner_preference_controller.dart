
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:assaan_rishta/app/core/services/env_config_service.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:assaan_rishta/app/core/routes/app_routes.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class PartnerPreferenceController extends GetxController {
  final useCases = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  RxBool isLoading = false.obs;
  RxBool showSkipButton = false.obs; // Show skip button only when is_preference_updated is false

  // Admin managing another user's profile
  bool isAdminManaging = false;
  int? targetUserId;

  /// Get the effective user ID (target user if admin managing, otherwise logged-in user)
  int get effectiveUserId => isAdminManaging && targetUserId != null
      ? targetUserId!
      : useCases.getUserId() ?? 0;




  List<String> ageFromList =
  List.generate(33, (index) => (18 + index).toString());
  RxString ageFrom = "".obs;
  RxString ageTo = "".obs;
  RxString ageValidationError = "".obs; // Error message for age validation
  var selectedLanguages = "";
  var languages = <String>[].obs;

  var caste = "".obs;
  List<String> castNameList = [];

  var education = "".obs;
  List<String> degreesList = [];

  var occupation = "".obs;
  List<String> occupationList = [];
  var monthlyIncome = "".obs;
  var motherTongue = "".obs;

  String country = "";
  final stateController = SingleSelectController<AllStates>(null);

  int cityId = 0;
  final cityController = SingleSelectController<AllCities>(null);

  var religion = "".obs;
  List<String> religionList = [
    'Muslim-Suni',
    'Muslim-Brelvi',
    'Muslim-Deobandi',
    'Muslim-AhleHadees',
    'Muslim-Other',
  ];

  var height = "".obs;
  List<String> heightList = [];

  var built = "".obs;
  var complexion = "".obs;

  var maritalStatus = "".obs;
  List<String> maritalStatusList = [
    "Single",
    "Married",
    "Divorced",
    "Widow/Widower"
  ];

  var userDiWohtiKaTarufTEC = TextEditingController();

  var isDrink = "".obs;
  var isSmoke = "".obs;

  // Form validation
  RxBool isFormValid = false.obs;

  ///old
  var partnerProfile = PartnerPreferenceData().obs;
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];

  @override
  void onInit() {
    // Check if admin is managing another user's profile
    _checkAdminManagingArguments();
    _generateHeightList();
    _initDropDownAPIs();
    // Listen to text field changes
    userDiWohtiKaTarufTEC.addListener(validateForm);
    super.onInit();
    validateForm();
    // Check if user needs to fill preferences (first time) - for all users including admin
    _checkPreferenceStatus();
  }

  /// Check arguments for admin managing another user
  void _checkAdminManagingArguments() {
    final args = Get.arguments;
    if (args != null && args is Map<String, dynamic>) {
      isAdminManaging = args['isAdminManaging'] == true;
      final userIdStr = args['userId']?.toString();
      if (userIdStr != null && userIdStr.isNotEmpty) {
        targetUserId = int.tryParse(userIdStr);
      }
      debugPrint('🔐 PartnerPreferenceController - isAdminManaging: $isAdminManaging, targetUserId: $targetUserId');
    }
  }

  // Check if is_preference_updated is false to show skip button
  void _checkPreferenceStatus() async {
    try {
      // Use effectiveUserId instead of useCases.getUserId()
      final uid = effectiveUserId;
      final doc = await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(uid.toString())
          .get();

      final data = doc.data();
      final bool isPreferenceUpdated =
          data != null && (data['is_preference_updated'] == true);

      // Show skip button only if preference is not updated
      showSkipButton.value = !isPreferenceUpdated;

      debugPrint('🔍 is_preference_updated: $isPreferenceUpdated');
      debugPrint('🔘 showSkipButton: ${showSkipButton.value}');
    } catch (e) {
      debugPrint('❌ Error checking preference status: $e');
      showSkipButton.value = false;
    }
  }

  @override
  void onClose() {
    userDiWohtiKaTarufTEC.removeListener(validateForm);
    userDiWohtiKaTarufTEC.dispose();
    debugPrint("[GETX] PartnerPreferenceController onClose() called");
    super.onClose();
  }

  // @override
  // void onDelete() {
  //   debugPrint("[GETX] \"PartnerPreferenceController\" onDelete() called");
  //   super.onDelete();
  // }

  // Validate age range
  bool validateAgeRange() {
    if (ageFrom.value.isEmpty || ageTo.value.isEmpty) {
      ageValidationError.value = "";
      return true; // If fields are empty, don't block validation (other checks will handle empty fields)
    }

    final ageFromInt = int.tryParse(ageFrom.value) ?? 0;
    final ageToInt = int.tryParse(ageTo.value) ?? 0;

    if (ageFromInt >= ageToInt) {
      ageValidationError.value = "Age From must be less than Age To";
      return false;
    }

    ageValidationError.value = "";
    return true;
  }

  // Validate all required fields
  void validateForm() {
    // First validate age range
    final ageRangeValid = validateAgeRange();

    final allFieldsFilled = ageFrom.value.isNotEmpty &&
        ageTo.value.isNotEmpty &&
        languages.isNotEmpty &&
        caste.isNotEmpty &&
        education.isNotEmpty &&
        occupation.isNotEmpty &&
        monthlyIncome.value.isNotEmpty &&
        motherTongue.value.isNotEmpty &&
        country.isNotEmpty &&
        cityId > 0 &&
        religion.isNotEmpty &&
        height.isNotEmpty &&
        built.value.isNotEmpty &&
        complexion.value.isNotEmpty &&
        maritalStatus.isNotEmpty &&
        userDiWohtiKaTarufTEC.text.trim().isNotEmpty &&
        isDrink.value.isNotEmpty &&
        isSmoke.value.isNotEmpty;

    isFormValid.value = allFieldsFilled && ageRangeValid;

    debugPrint("🔍 Form Validation:");
    debugPrint("   ageFrom: ${ageFrom.value.isNotEmpty} (${ageFrom.value})");
    debugPrint("   ageTo: ${ageTo.value.isNotEmpty} (${ageTo.value})");
    debugPrint("   languages: ${languages.isNotEmpty}");
    debugPrint("   caste: ${caste.isNotEmpty} ($caste)");
    debugPrint("   education: ${education.isNotEmpty} ($education)");
    debugPrint("   occupation: ${occupation.isNotEmpty} ($occupation)");
    debugPrint("   monthlyIncome: ${monthlyIncome.value.isNotEmpty} (${monthlyIncome.value})");
    debugPrint("   motherTongue: ${motherTongue.value.isNotEmpty} (${motherTongue.value})");
    debugPrint("   country: ${country.isNotEmpty} ($country)");
    debugPrint("   cityId: ${cityId > 0} ($cityId)");
    debugPrint("   religion: ${religion.isNotEmpty} ($religion)");
    debugPrint("   height: ${height.isNotEmpty} ($height)");
    debugPrint("   built: ${built.value.isNotEmpty} (${built.value})");
    debugPrint("   complexion: ${complexion.value.isNotEmpty} (${complexion.value})");
    debugPrint("   maritalStatus: ${maritalStatus.isNotEmpty} ($maritalStatus)");
    debugPrint("   aboutPartner: ${userDiWohtiKaTarufTEC.text.trim().isNotEmpty}");
    debugPrint("   isDrink: ${isDrink.value.isNotEmpty} (${isDrink.value})");
    debugPrint("   isSmoke: ${isSmoke.value.isNotEmpty} (${isSmoke.value})");
    debugPrint("   ageRangeValid: $ageRangeValid");
    debugPrint("   ✅ Form valid: ${isFormValid.value}");
  }

  void _generateHeightList() {
    for (int feet = 4; feet <= 7; feet++) {
      for (int inch = 0; inch <= 11; inch++) {
        if (inch == 0) {
          heightList.add("${feet}ft");
        } else {
          heightList.add("${feet}ft ${inch}in");
        }
      }
    }
  }

  ///Apis calls
  _initDropDownAPIs() {
    getPartnerPreference();
    getAllCasts();
    getAllDegrees();
    getAllOccupations();
    getAllCountries();
  }

  getPartnerPreference() async {
    isLoading.value = true;

    // Use correct API based on admin managing or not
    final response = isAdminManaging && targetUserId != null
        ? await useCases.getPartnerPreferenceById(userId: targetUserId!)
        : await useCases.getPartnerPreference();

    debugPrint('📋 PartnerPreference - Fetching for: ${isAdminManaging ? "target user $targetUserId" : "logged-in user"}');

    return response.fold(
          (error) {
        isLoading.value = false;
        debugPrint('❌ PartnerPreference - Error: ${error.description}');
      },
          (success) {
        partnerProfile.value = success;
        setPersonalInfo(success);
        isLoading.value = false;
        debugPrint('✅ PartnerPreference - Data loaded successfully');
        update();
      },
    );
  }

  getAllCasts() async {
    castNameList.clear();
    final response = await systemConfigUseCases.getAllCasts();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        if (success.castNames!.isNotEmpty) {
          castNameList.addAll(success.castNames!);
          castNameList.sort((a, b) => a.compareTo(b));
          update();
        }
        return Right(success);
      },
    );
  }

  getAllDegrees() async {
    degreesList.clear();
    final response = await systemConfigUseCases.getAllDegrees();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        if (success.degreeNames!.isNotEmpty) {
          degreesList.addAll(success.degreeNames!);
          degreesList.sort((a, b) => a.compareTo(b));
          update();
        }
        return Right(success);
      },
    );
  }

  getAllOccupations() async {
    occupationList.clear();
    final response = await systemConfigUseCases.getAllOccupations();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        if (success.occupationNames!.isNotEmpty) {
          occupationList.addAll(success.occupationNames!);
          update();
        }
        return Right(success);
      },
    );
  }

  getAllCountries() async {
    countryList.clear();
    final response = await systemConfigUseCases.getAllCountries();
    return response.fold(
          (error) {
        return Left(error);
      },
          (success) {
        if (success.isNotEmpty) {
          countryList.addAll(success);
          update();
        }
        return Right(success);
      },
    );
  }

  getAllStates(context, countryId) async {
    AppUtils.onLoading(context);
    stateList.clear();
    final response = await systemConfigUseCases.getAllStates(
      countryId: countryId,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
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

  getAllCities(context, stateId) async {
    AppUtils.onLoading(context);
    cityList.clear();
    final response = await systemConfigUseCases.getAllCities(stateId: stateId);
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
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

  updatePartnerPreference(context) async {
    AppUtils.onLoading(context);

    Map<String, String> payload = {
      "userId": effectiveUserId.toString(),
      "partner_age_from": ageFrom.value,
      "partner_age_to": ageTo.value,
      "partner_languages": languages.value.join(','),
      "partner_caste": caste.value,
      "partner_education": education.value,
      "partner_occupation": occupation.value,
      "partner_monthly_income": monthlyIncome.value,
      "partner_mother_tounge": motherTongue.value,
      "partner_religion": religion.value,
      "partner_height": height.value,
      "partner_built": built.value,
      "partner_complexion": complexion.value,
      "partner_marital_status": maritalStatus.value,
      "about_partner": userDiWohtiKaTarufTEC.text,
      "partner_smoke": getBoolString(isSmoke.value).toString(),
      "partner_drink": getBoolString(isDrink.value).toString(),
      "partner_citizenship": cityId.toString(),
    };

    final response = await useCases.updatePartnerPreference(
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Partner Preference",
          message: "Partner Preference information updated.",
        );
        // Mark Firestore flag so subsequent logins skip this view
        try {
          final uid = effectiveUserId;
          FirebaseFirestore.instance
              .collection(EnvConfig.firebaseUsersCollection)
              .doc(uid.toString())
              .set({'is_preference_updated': true}, SetOptions(merge: true));
        } catch (_) {}

        getPartnerPreference();
        update();

        // Navigate to home after successful update
        Get.offAllNamed(AppRoutes.BOTTOM_NAV);
      },
    );
  }

  // Skip partner preference and navigate to home
  void skipPartnerPreference() async {
    // Mark preference as updated in Firestore so user won't be forced to fill it again
    try {
      final uid = effectiveUserId;
      await FirebaseFirestore.instance
          .collection(EnvConfig.firebaseUsersCollection)
          .doc(uid.toString())
          .set({'is_preference_updated': true}, SetOptions(merge: true));

      debugPrint('✅ Skipped partner preference, marked as updated');
    } catch (e) {
      debugPrint('❌ Error setting preference flag: $e');
    }

    // Navigate to home
    Get.offAllNamed(AppRoutes.BOTTOM_NAV);
  }

  ///set all data to controllers and variable

  setPersonalInfo(PartnerPreferenceData profile) {
    ageFrom.value = profile.partnerAgeFrom.toString();
    ageTo.value = profile.partnerAgeTo.toString();
    caste.value = (profile.partnerCaste ?? "").capitalize!;
    education.value = profile.partnerEducation ?? "";
    occupation.value = (profile.partnerOccupation ?? "").capitalize!;
    monthlyIncome.value = (profile.partnerAnnualIncome ?? "").capitalize!;
    motherTongue.value = (profile.partnerMotherTounge ?? "").capitalize!;
    country = (profile.aboutCountryName ?? "").capitalize!; // ✅ SET COUNTRY
    religion.value = profile.partnerReligion ?? "";
    height.value = (profile.partnerHeight ?? "").capitalize!;
    built.value = (profile.partnerBuilt ?? "").capitalize!;
    complexion.value = (profile.partnerComplexion ?? "").capitalize!;
    maritalStatus.value = profile.partnerMaritalStatus ?? "";
    userDiWohtiKaTarufTEC.text = (profile.aboutPartner ?? "").capitalize!;
    isDrink.value = getStringBool(profile.partnerDrinkHabbit);
    isSmoke.value = getStringBool(profile.partnerSmokeHabbit);
    cityId = profile.aboutParentCityId ?? 0; // ✅ SAFE DEFAULT
    selectedLanguages = (profile.partnerLanguages ?? "");
    languages.value = profile.partnerLanguages != null
        ? profile.partnerLanguages!
        .split(',')
        .map((e) => e.replaceAll('"', '').trim())
        .toList()
        : [];

    debugPrint("✅ Loaded partner preference data");
    debugPrint("   Country: $country");
    debugPrint("   City ID: $cityId");

    // Validate form after loading data
    validateForm();
    update();
  }

  String getStringBool(String? value) {
    if (value != null) {
      if (value == "true") {
        return "Yes";
      } else {
        return "No";
      }
    } else {
      return "No";
    }
  }

  bool getBoolString(String value) {
    if (value == "Yes") {
      return true;
    } else {
      return false;
    }
  }
}