import 'package:dartz/dartz.dart';
import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../../core/base/export.dart';
import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class VendorListingController extends BaseController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  final systemConfigUseCases = Get.find<SystemConfigUseCase>();

  final searchTEC = TextEditingController();
  VendorCategory category = Get.arguments;

  ///vendors details
  RxBool isLoading = false.obs;
  List<VendorsList> vendorList = [];

  ///filters lists
  String country = "";
  List<AllCountries> countryList = [];

  String state = "";
  List<AllStates> stateList = [];

  String city = "";
  int cityId = 0;
  List<AllCities> cityList = [];

  @override
  void onInit() {
    _initApis();
    super.onInit();
  }

  _initApis() {
    getAllVendors();
    getAllCountries();
  }

  clearFilter() {
    country = "";
    state = "";
    city = "";
    update();
    getAllVendors();
  }

  ///Apis
  Future<void> getAllVendors({cityId}) async {
    isLoading.value = true;
    vendorList.clear();
    final response = await userManagementUseCases.getAllVendors(
      catId: category.id,
      pageNo: "1",
      cityId: cityId ?? 0,
    );
    return response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        if (success.profilesList!.isNotEmpty) {
          vendorList = success.profilesList!;
        }
        isLoading.value = false;
        update();
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

  getAllStates(context,countryId) async {
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
        if (success.isNotEmpty) {
          stateList.addAll(success);
          update();
        }
        AppUtils.dismissLoader(context);
      },
    );
  }

  getAllCities(context,stateId) async {
    AppUtils.onLoading(context);
    cityList.clear();
    final response = await systemConfigUseCases.getAllCities(stateId: stateId);
    return response.fold(
      (error) {
        AppUtils.dismissLoader(context);
      },
      (success) {
        if (success.isNotEmpty) {
          cityList.addAll(success);
          update();
        }
        AppUtils.dismissLoader(context);
      },
    );
  }

  @override
  void dispose() {
    searchTEC.dispose();
    super.dispose();
  }
}
