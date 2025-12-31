import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/base/export.dart';
import '../core/export.dart';
import '../domain/export.dart';
import '../utils/exports.dart';

class MatrimonialProfilesController extends BaseController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  final scrollController = ScrollController();

  List<ProfilesList> profileList = [];
  RxBool isLoading = false.obs;
  RxBool isError = false.obs;
  RxString errorMessage = ''.obs;

  int pageNo = 1;
  int totalCounts = 0;
  Rx<bool> isFirstLoad = true.obs;
  Rx<bool> isReloadMore = false.obs;

  int get adminId => userManagementUseCases.getUserId() ?? 0;

  @override
  void onInit() {
    super.onInit();
    _initApis();
  }

  void _initApis() {
    scrollController.addListener(_loadMoreData);
    getMatrimonialProfiles();
  }

  void _loadMoreData() {
    if (scrollController.position.pixels ==
        scrollController.position.maxScrollExtent) {
      if (totalCounts > profileList.length) {
        pageNo = pageNo + 1;
        isFirstLoad.value = false;
        isReloadMore.value = true;
        update();
        getMatrimonialProfiles(page: pageNo);
      }
    }
  }

  Future<void> getMatrimonialProfiles({int? page}) async {
    if (isFirstLoad.isTrue) {
      profileList = [];
      isLoading.value = true;
      isError.value = false;
      errorMessage.value = '';
    }

    final response = await userManagementUseCases.getMatrimonialProfiles(
      adminId: adminId,
      // pageNo: page ?? 1,
      // pageLimit: 12,
    );

    response.fold(
      (error) {
        isLoading.value = false;
        isError.value = true;
        errorMessage.value = error.description ?? 'Failed to load profiles';
        isReloadMore.value = false;
        update();
      },
      (success) {
        totalCounts = success.totalRecords ?? 0;
        if (success.profilesList != null && success.profilesList!.isNotEmpty) {
          final filteredProfiles = success.profilesList!.where((profile) {
            final alreadyAdded = profileList
                .any((existing) => existing.userId == profile.userId);
            return !alreadyAdded;
          }).toList();

          profileList.addAll(filteredProfiles);
          isReloadMore.value = false;
        }
        if (isFirstLoad.isTrue) {
          isLoading.value = false;
        }
        isError.value = false;
        update();
      },
    );
  }

  Future<void> refreshProfiles() async {
    profileList.clear();
    pageNo = 1;
    isFirstLoad.value = true;
    update();
    await getMatrimonialProfiles();
  }

  void scrollToTop() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  String getGenderBasedPlaceholder(String? gender) {
    if (gender == null || gender.isEmpty) {
      return AppAssets.imagePlaceholder;
    }
    
    final genderLower = gender.toLowerCase();
    if (genderLower == 'male') {
      return AppAssets.malePlaceholder;
    } else if (genderLower == 'female') {
      return AppAssets.femalePlaceholder;
    } else {
      return AppAssets.imagePlaceholder;
    }
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }
}
