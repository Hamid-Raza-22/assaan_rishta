// edit_profile_controller.dart - FIXED: Real-time Firebase updates for chat system

import 'package:animated_custom_dropdown/custom_dropdown.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/phone_number.dart';
import '../../../utils/exports.dart';
import '../../../core/export.dart';
import '../../../core/services/env_config_service.dart';
import '../../../domain/export.dart';
import '../../../viewmodels/signup_viewmodel.dart'; // For PhoneValidationRule

class EditProfileController extends GetxController {
  final useCases = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  RxBool isLoading = false.obs;

  // Admin managing another user's profile
  bool isAdminManaging = false;
  int? targetUserId;

  var profileDetails = CurrentUserProfile().obs;
  List<AllCountries> countryList = [];
  List<AllStates> stateList = [];
  List<AllCities> cityList = [];
  List<String> occupationList = [];

  /// Get the effective user ID (target user if admin managing, otherwise logged-in user)
  int get effectiveUserId => isAdminManaging && targetUserId != null
      ? targetUserId!
      : useCases.getUserId() ?? 0;

  ///general information
  var firstNameTEC = TextEditingController();
  var lastNameTEC = TextEditingController();
  var gender = "Male".obs;
  var mobileTEC = TextEditingController();
  var countryCode = 'PK'.obs; // Country ISO code
  var phoneNumber = ''.obs; // Store phone number
  var dobTEC = TextEditingController();
  var selectedDateTime = DateTime.now().obs;
  var userKaTarufTEC = TextEditingController();
  var userDiWohtiKaTarufTEC = TextEditingController();

  String caste = "";
  List<String> castNameList = [];

  String maritalStatus = "";
  List<String> maritalStatusList = [
    'Single',
    'Married',
    'Divorced',
    'Widow/Widower'
  ];

  String religion = "";
  List<String> religionList = [
    'Muslim-Suni',
    'Muslim-Brelvi',
    'Muslim-Deobandi',
    'Muslim-AhleHadees',
    'Muslim-Other',
  ];

  String education = "";
  List<String> degreesList = [];

  String occupation = "";

  String height = "";
  List<String> heightList = [];

  String country = "";
  final stateController = SingleSelectController<AllStates>(null);

  int cityId = 0;
  final cityController = SingleSelectController<AllCities>(null);

  ///personal information
  var profileNameTEC = TextEditingController();
  var createdFor = "".obs;
  var likeToMarry = "".obs;
  var culture = "".obs;
  var lifeStyle = "".obs;
  var transport = "".obs;
  var selectedLanguages = "";
  var languages = <String>[].obs;

  ///about my self
  var aboutMyselfTEC = TextEditingController();

  ///contact information
  var streetAddressTEC = TextEditingController();
  var bornCountryName = "".obs;
  var bornStateName = "".obs;
  var bornInCityName = "".obs;
  var bornInCityId = 0.obs;
  var nationality = "".obs;
  var residentialType = "".obs;
  var postalCodeTEC = TextEditingController();
  var relocate = "".obs;
  var landlineTEC = TextEditingController();
  var cellPhoneProtectionStatus = "".obs;

  ///financial status
  var monthlyIncome = "".obs;
  var familyStatus = "".obs;

  ///physical appearance
  var complexion = "".obs;
  var eyeColor = "".obs;
  var hairColor = "".obs;
  var weight = "".obs;
  var built = "".obs;

  ///family details
  var liveWith = "".obs;
  var parentCountryName = "".obs;
  var parentStateName = "".obs;
  var parentCityName = "".obs;
  var parentCityId = 0.obs;
  var fatherAlive = "".obs;
  var fatherOccupation = "".obs;
  var motherAlive = "".obs;
  var motherOccupation = "".obs;
  var motherTongue = "".obs;
  var siblings = "".obs;
  var noOfBrotherTEC = TextEditingController();
  var noOfSisterTEC = TextEditingController();
  var marriedBrotherTEC = TextEditingController();
  var marriedSisterTEC = TextEditingController();

  ///habit details
  var namaz = "".obs;
  var namazTimes = "0".obs;
  var fasting = "".obs;
  var zakat = "".obs;
  var isDrink = "".obs;
  var drink = "".obs;
  var isSmoke = "".obs;
  var smoke = "".obs;
  var interest = "".obs;
  var hobbies = "".obs;
  var diet = "".obs;

  ///health information
  var bloodGroup = "".obs;
  var handicapped = "".obs;
  var disability = "".obs;
  var eyeProblem = "".obs;
  var eyeProblemDefect = "".obs;
  var healthProblem = "".obs;
  var healthDefect = "".obs;
  var takingMedicines = "".obs;
  var whichMedicines = "".obs;
  var doExercise = "".obs;
  var exercises = "".obs;
  var visitGym = "".obs;

  ///general info
  final generalInfoFormKey = GlobalKey<FormState>();

  ///origin
  final originFormKey = GlobalKey<FormState>();
  var ethnicOrigin = "".obs;
  var pakiCnicTEC = TextEditingController();
  var pakiDrivingLicense = "".obs;
  var pakiDrivingLicenseNoTEC = TextEditingController();
  var pakiPassport = "".obs;
  var pakiPassportNoTEC = TextEditingController();
  var pakiTax = "".obs;
  var pakiTaxNoTEC = TextEditingController();
  var dualNationality = "".obs;
  var socialSecurityNoTEC = TextEditingController();
  var internationalDrivingLicense = "".obs;
  var internationalDrivingLicenseNoTEC = TextEditingController();
  var internationalPassport = "".obs;
  var internationalPassportNoTEC = TextEditingController();

  // Phone validation rules (same as signup)
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

  // Map dial codes to ISO country codes
  final Map<String, String> dialCodeToISO = {
    '92': 'PK',   // Pakistan
    '91': 'IN',   // India
    '1': 'US',    // US/Canada (ambiguous, defaulting to US)
    '44': 'GB',   // United Kingdom
    '966': 'SA',  // Saudi Arabia
    '971': 'AE',  // UAE
    '61': 'AU',   // Australia
    '86': 'CN',   // China
    '81': 'JP',   // Japan
    '82': 'KR',   // South Korea
    '33': 'FR',   // France
    '49': 'DE',   // Germany
    '39': 'IT',   // Italy
    '34': 'ES',   // Spain
    '7': 'RU',    // Russia
    '55': 'BR',   // Brazil
    '52': 'MX',   // Mexico
    '90': 'TR',   // Turkey
    '62': 'ID',   // Indonesia
    '63': 'PH',   // Philippines
    '60': 'MY',   // Malaysia
    '65': 'SG',   // Singapore
    '66': 'TH',   // Thailand
    '880': 'BD',  // Bangladesh
    '20': 'EG',   // Egypt
    '234': 'NG',  // Nigeria
    '27': 'ZA',   // South Africa
    '254': 'KE',  // Kenya
  };

  @override
  void onInit() {
    // Check if admin is managing another user's profile
    _checkAdminManagingArguments();
    _generateHeightList();
    _initDropDownAPIs();
    super.onInit();
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
      debugPrint('🔐 EditProfileController - isAdminManaging: $isAdminManaging, targetUserId: $targetUserId');
    }
  }

  // Updated phone validation with country-specific rules
  String? validatePhone(PhoneNumber? phone) {
    if (phone == null || phone.number.isEmpty) {
      return 'Phone number is required';
    }

    // Get validation rule for current country
    final rule = phoneValidationRules[countryCode.value] ??
        PhoneValidationRule(minLength: 7, maxLength: 15, countryName: 'Default');

    // Clean the phone number
    final cleanNumber = phone.number.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.length < rule.minLength) {
      return 'Phone must be ${rule.minLength} digits for ${rule.countryName}';
    }

    if (cleanNumber.length > rule.maxLength) {
      return 'Phone must not exceed ${rule.maxLength} digits for ${rule.countryName}';
    }

    // Country-specific format validation
    if (!_isValidPhoneFormat(cleanNumber, countryCode.value)) {
      return 'Invalid phone format for ${rule.countryName}';
    }

    return null;
  }

  // Helper method for country-specific format validation
  bool _isValidPhoneFormat(String number, String countryISO) {
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
        final firstDigit = int.tryParse(digitsOnly[0]) ?? 0;
        return firstDigit >= 2 && firstDigit <= 9;
      case 'SA':
      // Saudi Arabia: Mobile must start with 5
        return digitsOnly.startsWith('5') && digitsOnly.length == 9;
      case 'AE':
      // UAE: Mobile must start with 5
        return digitsOnly.startsWith('5') && digitsOnly.length == 9;
      default:
        return true; // Allow any format for other countries
    }
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
    getCurrentUserProfiles();
    getAllCasts();
    getAllDegrees();
    getAllOccupations();
    getAllCountries();
  }

  getCurrentUserProfiles() async {
    isLoading.value = true;

    // Use correct API based on admin managing or not
    final response = isAdminManaging && targetUserId != null
        ? await useCases.getUserProfileById(userId: targetUserId!)
        : await useCases.getCurrentUserProfile();

    debugPrint('📋 EditProfile - Fetching profile for: ${isAdminManaging ? "target user $targetUserId" : "logged-in user"}');

    return response.fold(
          (error) {
        isLoading.value = false;
        debugPrint('❌ EditProfile - Error fetching profile: ${error.description}');
      },
          (success) {
        profileDetails.value = success;
        setGeneralInfo(success);
        setPersonalInfo(success);
        setAboutMySelf(success);
        setContactInfo(success);
        setFinancialStatus(success);
        setPhysicalAppearance(success);
        setFamilyDetails(success);
        setHabitDetails(success);
        setHealthInformation(success);
        setOriginInformation(success);
        isLoading.value = false;
        debugPrint('✅ EditProfile - Profile loaded for: ${success.firstName} ${success.lastName}');
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

  // FIXED: Update both backend API and Firebase chat collection
  updateGeneralInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      "user_id": effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      "first_name": firstNameTEC.text,
      "last_name": lastNameTEC.text,
      "gender": gender.value,
      "cast": caste,
      "date_of_birth": selectedDateTime.value.toString(),
      "religion": religion,
      "marital_status": maritalStatus,
      "education": education,
      "height": height,
      "occupation": occupation,
      "userCountryName": country,
      "userStateName": stateController.value?.name,
      "cityid": cityId,
      "userKaTaruf": userKaTarufTEC.text,
      "userDiWohtiKaTaruf": userDiWohtiKaTarufTEC.text,
      "mobile_no": mobileTEC.text,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "updateuser",
      payload: payload,
    );

    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
        debugPrint('❌ Error updating profile: $error');
      },
          (success) async {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "General Information",
          message: "General information updated.",
        );

        // FIXED: Update Firebase chat collection with correct collection name
        try {
          final userId = useCases.getUserId().toString();
          final fullName = '${firstNameTEC.text.trim()} ${lastNameTEC.text.trim()}';
          final aboutText = userKaTarufTEC.text.trim();

          debugPrint('🔄 Updating Firebase for user: $userId');
          debugPrint('📝 New name: $fullName');
          debugPrint('📝 New about: $aboutText');

          // Update in the correct Hamid_users collection
          await FirebaseFirestore.instance
              .collection(EnvConfig.firebaseUsersCollection)
              .doc(userId)
              .update({
            'name': fullName,
            'about': aboutText.isNotEmpty ? aboutText : "Hey, I am using We Chat !!",
            'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
          });

          debugPrint('✅ Firebase updated successfullyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyyy');

          // Force update in local profile
          profileDetails.value.firstName = firstNameTEC.text;
          profileDetails.value.lastName = lastNameTEC.text;
          profileDetails.value.userKaTaruf = userKaTarufTEC.text;

        } catch (e) {
          debugPrint('❌ Error updating Firebase: $e');

          // Show error to user
          AppUtils.successData(
            title: "Warning",
            message: "Profile updated but chat data sync failed. Please restart the app.",
          );
        }

        update();
      },
    );
  }

  // FIXED: Add method to update profile image in Firebase
  // Future<void> updateProfileImageInFirebase(String imageUrl) async {
  //   try {
  //     final userId = useCases.getUserId().toString();
  //
  //     debugPrint('🖼️ Updating profile image in Firebase for user: $userId');
  //     debugPrint('🔗 Image URL: $imageUrl');
  //
  //     await FirebaseFirestore.instance
  //         .collection(EnvConfig.firebaseUsersCollection)
  //         .doc(userId)
  //         .update({
  //       'image': imageUrl,
  //       'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
  //     });
  //
  //     debugPrint('✅ Profile image updated in Firebase successfully');
  //
  //   } catch (e) {
  //     debugPrint('❌ Error updating profile image in Firebase: $e');
  //
  //     // Show error to user
  //     AppUtils.successData(
  //       title: "Warning",
  //       message: "Image updated but chat sync failed. Please restart the app.",
  //     );
  //   }
  // }

  // FIXED: Method to sync complete profile data to Firebase
  // Future<void> syncProfileToFirebase() async {
  //   try {
  //     final userId = useCases.getUserId().toString();
  //     final profile = profileDetails.value;
  //
  //     debugPrint('🔄 Syncing complete profile to Firebase...');
  //
  //     final updateData = <String, dynamic>{
  //       'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
  //     };
  //
  //     // Add name if available
  //     if (profile.firstName != null && profile.lastName != null) {
  //       updateData['name'] = '${profile.firstName} ${profile.lastName}';
  //     }
  //
  //     // Add about if available
  //     if (profile.userKaTaruf != null && profile.userKaTaruf!.isNotEmpty) {
  //       updateData['about'] = profile.userKaTaruf!;
  //     }
  //
  //     // Add image if available (you might need to get this from another source)
  //     // updateData['image'] = profile.imageUrl ?? "";
  //
  //     await FirebaseFirestore.instance
  //         .collection(EnvConfig.firebaseUsersCollection)
  //         .doc(userId)
  //         .update(updateData);
  //
  //     debugPrint('✅ Profile synced to Firebase successfully');
  //
  //   } catch (e) {
  //     debugPrint('❌ Error syncing profile to Firebase: $e');
  //   }
  // }

  updatePersonalInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'profile_name': profileNameTEC.text.toLowerCase(),
      'for_whom': createdFor.value.toLowerCase(),
      'like_to_marry': likeToMarry.value.toLowerCase(),
      'life_style': lifeStyle.value.toLowerCase(),
      'culture': culture.value.toLowerCase(),
      'transport': transport.value.toLowerCase(),
      'languages': languages.value,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "updatepresnolinfo",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) async {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Personal Information",
          message: "Personal information updated.",
        );

        // FIXED: Update about in Firebase if profile name changed
        try {
          if (profileNameTEC.text.trim().isNotEmpty) {
            final userId = useCases.getUserId().toString();

            await FirebaseFirestore.instance
                .collection(EnvConfig.firebaseUsersCollection)
                .doc(userId)
                .update({
              'about': profileNameTEC.text.trim(),
              'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
            });

            debugPrint('✅ Profile name updated in Firebase');
          }
        } catch (e) {
          debugPrint('❌ Error updating profile name in Firebase: $e');
        }

        update();
      },
    );
  }

  updateAboutMySelf(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'about_myself': aboutMyselfTEC.text,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "updateAboutMyself",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) async {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "About My Self",
          message: "About my self information updated.",
        );

        // FIXED: Update about in Firebase
        try {
          final userId = useCases.getUserId().toString();

          await FirebaseFirestore.instance
              .collection(EnvConfig.firebaseUsersCollection)
              .doc(userId)
              .update({
            'about': aboutMyselfTEC.text.trim().isEmpty
                ? "Hey, I am using We Chat !!"
                : aboutMyselfTEC.text.trim(),
            'last_active': DateTime.now().millisecondsSinceEpoch.toString(),
          });

          debugPrint('✅ About myself updated in Firebase');
        } catch (e) {
          debugPrint('❌ Error updating about in Firebase: $e');
        }

        update();
      },
    );
  }

  updateContactInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'street_address': streetAddressTEC.text,
      'born_in_city_id': bornInCityId.value,
      'nationality': nationality.value,
      'residential_type': residentialType.value,
      'postal_code': postalCodeTEC.text,
      'relocate': getBoolString(relocate.value),
      'landline': landlineTEC.text,
      'cell_phone_protection_status': cellPhoneProtectionStatus.value,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "updateContactinfo",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Personal Information",
          message: "Personal information updated.",
        );
        update();
      },
    );
  }

  updateFinancialStatus(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'monthly_income': monthlyIncome.value,
      'family_status': familyStatus.value,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdateEducationCareer",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Financial Status",
          message: "Financial status updated.",
        );
        update();
      },
    );
  }

  updatePhysicalAppearance(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'complexion': complexion.value,
      'eye_color': eyeColor.value,
      'hair_color': hairColor.value,
      'weight': weight.value,
      'built': built.value,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdatePhysicalAppearance",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Physical Appearance",
          message: "Physical appearance updated.",
        );
        update();
      },
    );
  }

  updateFamilyInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'live_with': liveWith.value,
      'parent_city_id': parentCityId.value,
      'father_alive': getBoolString(fatherAlive.value),
      'father_occupation': fatherOccupation.value,
      'mother_alive': getBoolString(motherAlive.value),
      'mother_occupation': motherOccupation.value,
      'mother_tounge': motherTongue.value,
      'silings': getBoolString(siblings.value),
      'no_of_brother': noOfBrotherTEC.text,
      'no_of_sister': noOfSisterTEC.text,
      'married_brother': marriedBrotherTEC.text,
      'married_sister': marriedSisterTEC.text,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdateFamilyDetails",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Family Details",
          message: "Family details updated.",
        );
        update();
      },
    );
  }

  updateHabitInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'namaz': getBoolString(namaz.value),
      'namaz_times': namazTimes.value,
      'fasting': getBoolString(fasting.value),
      'zakat': getBoolString(zakat.value),
      'is_drink': getBoolString(isDrink.value),
      'drink': drink.value,
      'is_smoke': getBoolString(isSmoke.value),
      'smoke': smoke.value,
      'interest': interest.value,
      'hobbies': hobbies.value,
      'diet': diet.value,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdateHabbits",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Habit Details",
          message: "Habit details updated.",
        );
        update();
      },
    );
  }

  updateHealthInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'blood_group': bloodGroup.value,
      'handicapped': getBoolString(handicapped.value),
      'disability': disability.value,
      'eye_problem': getBoolString(eyeProblem.value),
      'eye_problem_defect': eyeProblemDefect.value,
      'health_problem': getBoolString(healthProblem.value),
      'health_defect': healthDefect.value,
      'taking_medicines': getBoolString(takingMedicines.value),
      'which_medicines': whichMedicines.value,
      'do_exercise': getBoolString(doExercise.value),
      'exercises': exercises.value,
      'visit_gym': getBoolString(visitGym.value),
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdateHealthInformation",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Health Information",
          message: "Health Information updated.",
        );
        update();
      },
    );
  }

  updateOriginInfo(context) async {
    AppUtils.onLoading(context);

    Map<String, dynamic> payload = {
      'user_id': effectiveUserId,
      "profile_id": profileDetails.value.profileId,
      "roll_id": 0,
      'ethnic_origin': ethnicOrigin.value,
      'paki_cnic': pakiCnicTEC.text,
      'paki_driving_license': getBoolString(pakiDrivingLicense.value),
      'paki_driving_license_no': pakiDrivingLicenseNoTEC.text,
      'paki_passport': getBoolString(pakiPassport.value),
      'paki_passport_no': pakiPassportNoTEC.text,
      'paki_tax': getBoolString(pakiTax.value),
      'paki_tax_no': pakiTaxNoTEC.text,
      'dual_nationality': getBoolString(dualNationality.value),
      'social_security_no': socialSecurityNoTEC.text,
      'international_driving_license':
      getBoolString(internationalDrivingLicense.value),
      'international_driving_license_no': internationalDrivingLicenseNoTEC.text,
      'international_passport': getBoolString(internationalPassport.value),
      'international_passport_no': internationalPassportNoTEC.text,
    };

    final response = await useCases.updateProfileInfoPic(
      endPoint: "UpdateOrigin",
      payload: payload,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        AppUtils.dismissLoader(context);
        AppUtils.successData(
          title: "Origin information",
          message: "Origin information updated.",
        );
        update();
      },
    );
  }

  ///set all data to controllers and variable
  setGeneralInfo(CurrentUserProfile profile) {
    firstNameTEC.text = '${profile.firstName}';
    lastNameTEC.text = '${profile.lastName}';
    gender.value = '${profileDetails.value.gender}';
    caste = profileDetails.value.cast ?? "";

    // Parse mobile number and extract country code
    String fullMobileNo = '${profileDetails.value.mobileNo}';
    String localNumber = '';

    if (fullMobileNo.startsWith('+')) {
      // Extract digits only
      String digitsOnly = fullMobileNo.replaceAll(RegExp(r'[^\d]'), '');

      // Try to match dial code and extract country ISO code
      String? detectedISO;
      String dialCode = '';

      // Try matching from longest to shortest dial codes (3, 2, 1 digits)
      for (int length = 3; length >= 1; length--) {
        if (digitsOnly.length > length) {
          String potentialDialCode = digitsOnly.substring(0, length);
          if (dialCodeToISO.containsKey(potentialDialCode)) {
            dialCode = potentialDialCode;
            detectedISO = dialCodeToISO[potentialDialCode];
            localNumber = digitsOnly.substring(length);
            break;
          }
        }
      }

      // Set country code if detected, otherwise default to PK
      if (detectedISO != null) {
        countryCode.value = detectedISO;
      } else {
        countryCode.value = 'PK';
        localNumber = digitsOnly;
      }

      debugPrint('📱 Mobile: $fullMobileNo');
      debugPrint('📱 Dial Code: $dialCode');
      debugPrint('📱 ISO Code: ${countryCode.value}');
      debugPrint('📱 Local Number: $localNumber');

    } else {
      // No country code prefix, assume it's just local number
      localNumber = fullMobileNo.replaceAll(RegExp(r'[^\d]'), '');
      countryCode.value = 'PK'; // Default to Pakistan
    }

    mobileTEC.text = localNumber;

    DateTime dateTime = DateTime.parse('${profileDetails.value.dateOfBirth}');
    dobTEC.text = DateFormat('dd/MM/yyyy').format(dateTime);
    selectedDateTime.value = dateTime;
    religion = '${profileDetails.value.religion}';
    maritalStatus = '${profileDetails.value.maritalStatus}';
    education = '${profileDetails.value.education}';
    height = '${profileDetails.value.height}';
    occupation = '${profileDetails.value.occupation}';
    country = '${profileDetails.value.userCountryName}';
    cityId = profileDetails.value.cityid ?? 0;
    userKaTarufTEC.text = '${profile.userKaTaruf}';
    userDiWohtiKaTarufTEC.text = '${profile.userDiWohtiKaTaruf}';
    update();
  }

  setPersonalInfo(CurrentUserProfile profile) {
    profileNameTEC.text = (profile.profileName ?? "").capitalize!;
    createdFor.value = (profile.forWhom ?? "").capitalize!;
    likeToMarry.value = (profile.likeToMarry ?? "").capitalize!;
    lifeStyle.value = (profile.lifeStyle ?? "").capitalize!;
    culture.value = (profile.culture ?? "").capitalize!;
    transport.value = (profile.transport ?? "").capitalize!;
    selectedLanguages = (profile.languages ?? "");
    languages.value = profile.languages != null
        ? profile.languages!
        .split(',')
        .map((e) => e.replaceAll('"', '').trim())
        .toList()
        : [];
    update();
  }

  setAboutMySelf(CurrentUserProfile profile) {
    aboutMyselfTEC.text = profile.aboutMyself ?? "";
    update();
  }

  setContactInfo(CurrentUserProfile profile) {
    streetAddressTEC.text = (profile.streetAddress ?? "");
    bornCountryName.value = (profile.bornCountryName ?? "");
    bornStateName.value = (profile.bornStateName ?? "");
    bornInCityName.value = (profile.bornInCityName ?? "");
    bornInCityId.value = (profile.bornInCityId ?? 0);
    nationality.value = (profile.nationality ?? "");
    residentialType.value = (profile.residentialType ?? "");
    postalCodeTEC.text = (profile.postalCode ?? 0).toString();
    relocate.value = getStringBool(profile.relocate);
    landlineTEC.text = (profile.landline ?? "");
    cellPhoneProtectionStatus.value = (profile.cellPhoneProtectionStatus ?? "");
    update();
  }

  setFinancialStatus(CurrentUserProfile profile) {
    monthlyIncome.value = profile.monthlyIncome ?? "";
    familyStatus.value = profile.familyStatus ?? "";
    update();
  }

  setPhysicalAppearance(CurrentUserProfile profile) {
    complexion.value = profile.complexion ?? "";
    eyeColor.value = profile.eyeColor ?? "";
    hairColor.value = profile.hairColor ?? "";
    weight.value = profile.weight ?? "";
    built.value = profile.built ?? "";
    update();
  }

  setFamilyDetails(CurrentUserProfile profile) {
    liveWith.value = profile.liveWith ?? "";
    parentCountryName.value = profile.parentCountryName ?? "";
    parentStateName.value = profile.parentStateName ?? "";
    parentCityName.value = profile.parentCityName ?? "";
    fatherAlive.value = getStringBool(profile.fatherAlive);
    fatherOccupation.value = profile.fatherOccupation ?? "";
    motherAlive.value = getStringBool(profile.motherAlive);
    motherOccupation.value = profile.motherOccupation ?? "";
    motherTongue.value = profile.motherTounge ?? "";
    siblings.value = getStringBool(profile.silings);
    noOfBrotherTEC.text = '${profile.noOfBrother ?? 0}';
    noOfSisterTEC.text = '${profile.noOfSister ?? 0}';
    marriedBrotherTEC.text = '${profile.marriedBrother ?? 0}';
    marriedSisterTEC.text = '${profile.marriedSister ?? 0}';
    update();
  }

  setHabitDetails(CurrentUserProfile profile) {
    namaz.value = getStringBool(profile.namaz);
    namazTimes.value = (profile.namazTimes ?? "0");
    fasting.value = getStringBool(profile.fasting);
    zakat.value = getStringBool(profile.zakat);
    isDrink.value = getStringBool(profile.isDrink);
    drink.value = profile.drink ?? "";
    isSmoke.value = getStringBool(profile.isSmoke);
    smoke.value = profile.smoke ?? "";
    interest.value = profile.interest ?? "";
    hobbies.value = profile.hobbies ?? "";
    diet.value = profile.diet ?? "";
    update();
  }

  setHealthInformation(CurrentUserProfile profile) {
    bloodGroup.value = profile.bloodGroup ?? "";
    handicapped.value = getStringBool(profile.handicapped);
    disability.value = profile.disability ?? "";
    eyeProblem.value = getStringBool(profile.eyeProblem);
    eyeProblemDefect.value = profile.eyeProblemDefect ?? "";
    healthProblem.value = getStringBool(profile.healthProblem);
    healthDefect.value = profile.healthDefect ?? "";
    takingMedicines.value = getStringBool(profile.takingMedicines);
    whichMedicines.value = profile.whichMedicines ?? "";
    doExercise.value = getStringBool(profile.doExercise);
    exercises.value = profile.exercises ?? "";
    visitGym.value = getStringBool(profile.visitGym);
    update();
  }

  setOriginInformation(CurrentUserProfile profile) {
    ethnicOrigin.value = profile.ethnicOrigin ?? "";
    pakiCnicTEC.text = profile.pakiCnic ?? "";
    pakiDrivingLicense.value = getStringBool(profile.pakiDrivingLicense);
    pakiDrivingLicenseNoTEC.text = profile.pakiDrivingLicenseNo ?? "";
    pakiPassport.value = getStringBool(profile.pakiPassport);
    pakiPassportNoTEC.text = profile.pakiPassportNo ?? "";
    pakiTax.value = getStringBool(profile.pakiTax);
    pakiTaxNoTEC.text = profile.pakiTaxNo ?? "";
    dualNationality.value = getStringBool(profile.dualNationality);
    socialSecurityNoTEC.text = profile.socialSecurityNo ?? "";
    internationalDrivingLicense.value =
        getStringBool(profile.internationalDrivingLicense);
    internationalDrivingLicenseNoTEC.text =
        profile.internationalDrivingLicenseNo ?? "";
    internationalPassport.value = getStringBool(profile.internationalPassport);
    internationalPassportNoTEC.text = profile.internationalPassportNo ?? "";
    update();
  }

  String getStringBool(bool? value) {
    if (value != null) {
      if (value) {
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

List<String> languagesList = [
  'English',
  'Albanian',
  'Arabic',
  'Balochi',
  'Chinese',
  'Czech',
  'Danish',
  'Dutch',
  'Finnish',
  'French',
  'German',
  'Greek',
  'Hindi',
  'Hungarian',
  'Indonesian',
  'Irish',
  'Italian',
  'Japanese',
  'Korean',
  'Latin',
  'Malayalam',
  'Pashto',
  'Punjabi',
  'Persian',
  'Portuguese',
  'Rajasthani',
  'Russian',
  'Sanskrit',
  'Sindhi',
  'Saraiki',
  'Serbian',
  'Spanish',
  'Swedish',
  'Tamil',
  'Telugu',
  'Thai',
  'Turkish',
  'Ukrainian',
  'Urdu',
  'Uyghur',
  'Uzbek',
  'Venetian',
  'Vietnamese',
];