
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../viewmodels/home_viewmodel.dart';

class FavoritesController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  RxBool isLoading = false.obs;
  List<FavoritesProfiles> favList = [];

  @override
  void onInit() {
    super.onInit();
    getAllFavorites();
  }

  getAllFavorites() async {
    isLoading.value = true;
    favList.clear();
    final response = await userManagementUseCases.getAllFavorites();
    return response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          favList = success;
        }
        isLoading.value = false;
        update();
      },
    );
  }

  removeFromLocalList(int index){
    favList.removeAt(index);
    update();
  }

  removeFavorite({required int favUid}) async {
    final response = await userManagementUseCases.addToFavorites(
      favUid: favUid,
    );
    return response.fold(
          (error) {
        debugPrint(error.title);
      },
          (success) {
        if (success.isNotEmpty) {
          Get.find<HomeController>().profileList.clear();
          Get.find<HomeController>().getAllProfiles(pageNumber: 0);
        }
        update();
      },
    );
  }

}
