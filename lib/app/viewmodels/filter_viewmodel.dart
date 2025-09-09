import 'package:dartz/dartz.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/base/export.dart';
import '../core/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';

class FilterController extends BaseController {
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  final searchTEC = TextEditingController();
  final userIdSearchTEC = TextEditingController(); // New controller for User ID search
  final scrollController = ScrollController();

  List<ProfilesList> profileList = [];
  RxBool isLoading = false.obs;

  ///for details
  RxBool isDetailsLoading = false.obs;
  var profileDetails = ProfileDetails().obs;

  RxString caste = "".obs;
  RxString ageFrom = "".obs;
  RxString ageTo = "".obs;
  RxString cityId = "0".obs;
  RxString gender = "".obs;
  RxString maritalStatus = "".obs;
  RxString religion = "".obs;

  List<String> maritalStatusList = [
    'Single',
    'Married',
    'Divorced',
    'Widow/Widower'
  ];

  List<String> religionList = [
    'Muslim-Suni',
    'Muslim-Brelvi',
    'Muslim-Deobandi',
    'Muslim-AhleHadees',
    'Muslim-Other',
  ];

  List<String> castNameList = [];

  ///Location and Preferences
  String country = "";
  List<AllCountries> countryList = [];

  RxString state = "".obs;
  List<AllStates> stateList = [];

  RxString city = "".obs;
  List<AllCities> cityList = [];

  int pageNo = 1;
  int totalCounts = 0;
  Rx<bool> isFirstLoad = true.obs;
  Rx<bool> isReloadMore = false.obs;

  Rx<bool> isFilterApplied = false.obs;
  Rx<bool> isSearchByUserId = false.obs; // New flag for User ID search

  @override
  void onInit() {
    _initApis();
    super.onInit();
  }

  _initApis() {
    scrollController.addListener(_loadMoreData);
    getAllProfiles();
    getAllCasts();
    getAllCountries();
  }

  _loadMoreData() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (totalCounts > profileList.length) {
        pageNo = pageNo + 1;
        isFirstLoad.value = false;
        isReloadMore.value = true;
        update();
        if (isSearchByUserId.isTrue) {
          // Don't load more data for User ID search as it returns single result
          return;
        } else if (isFilterApplied.isTrue) {
          getAllProfilesByFilter(page: pageNo);
        } else {
          getAllProfiles(page: pageNo);
        }
      }
    }
  }



  ///Clear search functionality
  clearSearch() {
    isSearchByUserId.value = false;
    userIdSearchTEC.clear();
    isFirstLoad.value = true;
    profileList.clear();
    update();
    getAllProfiles(page: 1);
  }

  ///Existing Apis
  Future<void> getAllProfilesByFilter({
    required int page,
    BuildContext? context,
  }) async {
    scrollToTop();
    if (context != null) {
      AppUtils.onLoading(context);
      profileList.clear();
    }

    isFilterApplied.value = true;
    isSearchByUserId.value = false; // Reset search flag

    ProfileFilter filter = ProfileFilter(
      userId: userManagementUseCases.getUserId(),
      pageNumber: page,
      pageSize: 12,
      caste: caste.value,
      ageFrom: ageFrom.value,
      ageTo: ageTo.value,
      city: cityId.value == "0" ? "" : cityId.value,
      gender: gender.value,
      maritalStatus: maritalStatus.value,
      religion: religion.value,
    );

    final response = await userManagementUseCases.getAllProfilesByFilter(
      profileFilter: filter,
    );
    return response.fold(
          (error) {
        AppUtils.dismissLoader(context);
      },
          (success) {
        totalCounts = success.totalRecords!;
        if (success.profilesList!.isNotEmpty) {
          profileList.addAll(success.profilesList!);
          isReloadMore.value = false;
        }
        if (context != null) {
          AppUtils.dismissLoader(context);
        }
        update();
      },
    );
  }

  getAllProfiles({page, limit}) async {
    if (isFirstLoad.isTrue) {
      profileList = [];
      isLoading.value = true;
    }

    // Reset search flags when getting all profiles
    isSearchByUserId.value = false;

    final response = await userManagementUseCases.getAllFeaturedProfiles(
      pageNo: page ?? 1,
      pageLimit: "12",
    );
    return response.fold(
          (error) {
        isLoading.value = false;
      },
          (success) {
        totalCounts = success.totalRecords!;
        if (success.profilesList!.isNotEmpty) {
          profileList.addAll(success.profilesList!);
          isReloadMore.value = false;
        }
        if (isFirstLoad.isTrue) {
          isLoading.value = false;
        }
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

  getAllStates(countryId, context) async {
    stateList.clear();
    AppUtils.onLoading(context);
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

  getAllCities(stateId, context) async {
    AppUtils.onLoading(context);
    cityList.clear();
    final response = await systemConfigUseCases.getAllCities(
      stateId: stateId,
    );
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

  clearAllFilters() {
    isFilterApplied.value = false;
    isSearchByUserId.value = false; // Reset search flag
    caste = "".obs;
    ageFrom = "".obs;
    ageTo = "".obs;
    country = "";
    state = "".obs;
    city = "".obs;
    cityId = "0".obs;
    gender = "".obs;
    maritalStatus = "".obs;
    religion = "".obs;
    userIdSearchTEC.clear(); // Clear search field
    isFirstLoad.value = true;
    update();
    getAllProfiles(page: 1);
  }

  scrollToTop() {
    scrollController.animateTo(
      scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  @override
  void onClose() {
    searchTEC.dispose();
    userIdSearchTEC.dispose();
    scrollController.dispose();
    super.onClose();
  }
}