
import 'package:get/get.dart';
import 'package:card_swiper/card_swiper.dart';

import '../core/export.dart';
import '../domain/export.dart';
import '../utils/app_utils.dart';


class HomeController extends GetxController {
  final userManagementUseCases = Get.find<UserManagementUseCase>();

  final swiperController = SwiperController();

  ///for profile listing
  List<ProfilesList> profileList = [];
  List<ProfilesList> swipedItems = [];
  RxBool isLoading = false.obs;

  ///for details
  RxBool isDetailsLoading = false.obs;
  var profileDetails = ProfileDetails().obs;

  /// pagination
  int currentPage = 1;

  @override
  void onInit() {
    getAllProfiles();
    super.onInit();
  }

  void handleIndexChanged(int index) {
    // Check if near the end of the list (length - 3 items) to load more
    if (index >= profileList.length - 5 && !isLoading.value) {
      getAllProfiles(addNewCards: true);
    }
  }

  ///Apis
  void getAllProfiles({bool addNewCards = false, int? pageNumber}) async {
    if (addNewCards == false) {
      isLoading.value = true;
    }

    final response = await userManagementUseCases.getAllProfiles(
      pageNo: pageNumber ?? currentPage,
      pageLimit: "20",
    );

    response.fold(
          (error) {
        isLoading.value = false;
      },
          (success) {
        if (success.profilesList != null && success.profilesList!.isNotEmpty) {
          if (addNewCards) {
            // Filter out profiles with duplicate IDs
            final newProfiles = success.profilesList!.where((profile) {
              return !profileList.any((existingProfile) => existingProfile.userId == profile.userId);
            }).toList();

            // Add only the unique profiles
            profileList.addAll(newProfiles);
          } else {
            profileList = success.profilesList!.where((element) {
              return element.userId != userManagementUseCases.userManagementRepo.getUserId();
            }).toList();
          }
          currentPage++;
        }
        update();
        isLoading.value = false;
      },
    );
  }

  addFavorite(context, index, favUid) async {
    AppUtils.onLoading(context);
    final response =
        await userManagementUseCases.addToFavorites(favUid: favUid);
    return response.fold(
      (error) {
        AppUtils.dismissLoader(context);
      },
      (success) {
        AppUtils.dismissLoader(context);
        if (success.isNotEmpty) {
          if (profileList[index].favourite == "yes") {
            profileList[index].favourite = "no";
            AppUtils.successData(
              title: "Favorite",
              message: "Remove from favorite successfully.",
            );
          } else if (profileList[index].favourite == "no") {
            profileList[index].favourite = "yes";
            AppUtils.successData(
              title: "Favorite",
              message: "Add to favorite successfully.",
            );
          }
        }
        update();
      },
    );
  }

}
