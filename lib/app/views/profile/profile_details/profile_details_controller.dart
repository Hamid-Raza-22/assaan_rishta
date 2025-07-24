import 'package:get/get.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';


class ProfileDetailsController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();
  RxBool isLoading = false.obs;

  var profileDetails = CurrentUserProfile().obs;

  @override
  void onInit() {
    getCurrentUserProfiles();
    super.onInit();
  }

  ///Apis
  getCurrentUserProfiles() async {
    isLoading.value = true;
    final response = await userManagementUseCases.getCurrentUserProfile();
    return response.fold(
      (error) {
        isLoading.value = false;
      },
      (success) {
        profileDetails.value = success;
        isLoading.value = false;
        update();
      },
    );
  }
}
