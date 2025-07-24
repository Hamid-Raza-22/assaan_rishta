import 'package:animated_custom_dropdown/custom_dropdown.dart';

import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class PartnerPreferenceController extends GetxController {
  final useCases = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  RxBool isLoading = false.obs;

  List<String> ageFromList =
      List.generate(33, (index) => (18 + index).toString());
  RxString ageFrom = "".obs;
  RxString ageTo = "".obs;
  var selectedLanguages = "";
  var languages = <String>[].obs;

  String caste = "";
  List<String> castNameList = [];

  String education = "";
  List<String> degreesList = [];

  String occupation = "";
  List<String> occupationList = [];
  var monthlyIncome = "".obs;
  var motherTongue = "".obs;

  String country = "";
  final stateController = SingleSelectController<AllStates>(null);

  int cityId = 0;
  final cityController = SingleSelectController<AllCities>(null);

  String religion = "";
  List<String> religionList = [
    'Muslim-Suni',
    'Muslim-Brelvi',
    'Muslim-Deobandi',
    'Muslim-AhleHadees',
    'Muslim-Other',
  ];

  String height = "";
  List<String> heightList = [];

  var built = "".obs;
  var complexion = "".obs;

  String maritalStatus = "";
  List<String> maritalStatusList = [
    "single",
    "married",
    "divorced",
    "widow/widower"
  ];

  var userDiWohtiKaTarufTEC = TextEditingController();

  var isDrink = "".obs;
  var isSmoke = "".obs;

  ///old
  var partnerProfile = PartnerPreferenceData().obs;
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];

  @override
  void onInit() {
    _generateHeightList();
    _initDropDownAPIs();
    super.onInit();
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
    final response = await useCases.getPartnerPreference();
    return response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        partnerProfile.value = success;
        setPersonalInfo(success);
        isLoading.value = false;
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
      "userId": useCases.getUserId().toString(),
      "partner_age_from": ageFrom.value,
      "partner_age_to": ageTo.value,
      "partner_languages": languages.value.join(','),
      "partner_caste": caste,
      "partner_education": education,
      "partner_occupation": occupation,
      "partner_monthly_income": monthlyIncome.value,
      "partner_mother_tounge": motherTongue.value,
      "partner_religion": religion,
      "partner_height": height,
      "partner_built": built.value,
      "partner_complexion": complexion.value,
      "partner_marital_status": maritalStatus,
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
        getPartnerPreference();
        update();
      },
    );
  }

  ///set all data to controllers and variable

  setPersonalInfo(PartnerPreferenceData profile) {
    ageFrom.value = profile.partnerAgeFrom.toString();
    ageTo.value = profile.partnerAgeTo.toString();
    caste = (profile.partnerCaste ?? "").capitalize!;
    education = (profile.partnerEducation ?? "").capitalize!;
    occupation = (profile.partnerOccupation ?? "").capitalize!;
    monthlyIncome.value = (profile.partnerAnnualIncome ?? "").capitalize!;
    motherTongue.value = (profile.partnerMotherTounge ?? "").capitalize!;
    religion = (profile.partnerReligion ?? "").capitalize!;
    height = (profile.partnerHeight ?? "").capitalize!;
    built.value = (profile.partnerBuilt ?? "").capitalize!;
    complexion.value = (profile.partnerComplexion ?? "").capitalize!;
    maritalStatus = (profile.partnerMaritalStatus ?? "").capitalize!;
    userDiWohtiKaTarufTEC.text = (profile.aboutPartner ?? "").capitalize!;
    isDrink.value = getStringBool(profile.partnerDrinkHabbit);
    isSmoke.value = getStringBool(profile.partnerSmokeHabbit);
    cityId = profile.aboutParentCityId!;
    selectedLanguages = (profile.partnerLanguages ?? "");
    languages.value = profile.partnerLanguages != null
        ? profile.partnerLanguages!
            .split(',')
            .map((e) => e.replaceAll('"', '').trim())
            .toList()
        : [];
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
