import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../../core/base/export.dart';
import '../../core/export.dart';
import '../../domain/export.dart';
import '../../utils/exports.dart';

class VendorController extends BaseController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();

  final searchTEC = TextEditingController();
  List<VendorCategory> vendorCategoryList = [];

  @override
  void onInit() {
    vendorCategoryList = getVendorList();
    super.onInit();
  }


  @override
  void dispose() {
    searchTEC.dispose();
    super.dispose();
  }
}

getVendorList() {
  return [
    VendorCategory(
      id: 10,
      image: AppAssets.venues,
      title: 'Venues',
    ),
    VendorCategory(
      id: 6,
      image: AppAssets.photography,
      title: 'Photography',
    ),
    VendorCategory(
      id: 4,
      image: AppAssets.catering,
      title: 'Catering',
    ),
    VendorCategory(
      id: 8,
      image: AppAssets.carRental,
      title: 'Car Rental',
    ),
    VendorCategory(
      id: 5,
      image: AppAssets.decoration,
      title: 'Decoration',
    ),
    VendorCategory(
      id: 11,
      image: AppAssets.eventManagers,
      title: 'Event Managers',
    ),
    VendorCategory(
      id: 12,
      image: AppAssets.salon,
      title: 'Salon',
    ),
    VendorCategory(
      id: 3,
      image: AppAssets.cake,
      title: 'Cake',
    ),
    VendorCategory(
      id: 9,
      image: AppAssets.invitation,
      title: 'Invitation',
    ),
  ];
}
