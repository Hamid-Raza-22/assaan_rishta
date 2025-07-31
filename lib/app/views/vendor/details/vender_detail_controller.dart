import 'dart:async';

import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import '../../../core/base/export.dart';
import '../../../core/export.dart';
import '../../../domain/export.dart';

class VendorDetailController extends BaseController {
  final useCases = Get.find<UserManagementUseCase>();
  int selectedIndex = 0;

  VendorsList vendorsItem = Get.arguments;

  RxBool isServiceLoading = false.obs;
  RxBool isQuestionsLoading = false.obs;
  RxBool isAlbumsLoading = false.obs;
  RxBool isVideoLoading = false.obs;
  RxBool isPackageLoading = false.obs;

  List<VendorServices> serviceList = [];
  List<VendorQuestions> questionsList = [];
  List<VendorAlbums> albumList = [];
  List<VendorVideos> videoList = [];
  List<VendorPackages> packageList = [];

  ///for view number
  Timer? _timer;
  RxBool isButtonVisible = true.obs;
  RxInt secondsRemaining = 05.obs;
  RxBool isClicked = false.obs;

  @override
  void onInit() {
    _initApis();
    super.onInit();
  }

  _initApis() {
    getVendorServices();
    getVendorQuestions();
    getVendorAlbums();
    getVendorVideo();
    getVendorPackage();
  }

  void startTimer() {
    isClicked.value=true;
    _timer?.cancel();
    isButtonVisible.value = false;
    secondsRemaining.value = 05;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsRemaining.value > 0) {
        secondsRemaining.value--;
      } else {
        timer.cancel();
        isButtonVisible.value = true;
      }
    });
  }

  ///Apis
  getVendorServices() async {
    isServiceLoading.value = true;
    final response = await useCases.getVendorServices(
      vendorId: vendorsItem.venderID,
    );
    return response.fold(
      (error) {
        isServiceLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          serviceList = success;
        }
        isServiceLoading.value = false;
        update();
      },
    );
  }

  getVendorQuestions() async {
    isQuestionsLoading.value = true;
    final response = await useCases.getVendorQuestions(
      vendorId: vendorsItem.venderID,
    );
    return response.fold(
      (error) {
        isQuestionsLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          questionsList = success;
        }
        isQuestionsLoading.value = false;
        update();
      },
    );
  }

  getVendorAlbums() async {
    isAlbumsLoading.value = true;
    final response = await useCases.getVendorAlbums(
      vendorId: vendorsItem.venderID,
    );
    return response.fold(
      (error) {
        isAlbumsLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          albumList = success;
        }
        isAlbumsLoading.value = false;
        update();
      },
    );
  }

  getVendorVideo() async {
    isVideoLoading.value = true;
    final response = await useCases.getVendorVideo(
      vendorId: vendorsItem.venderID,
    );
    return response.fold(
      (error) {
        isVideoLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          videoList = success;
        }
        print('Lenght => ${success.length}');
        isVideoLoading.value = false;
        update();
      },
    );
  }

  Future<Uint8List?> getThumbnail(String videoUrl) async {
    if (videoUrl.isEmpty) return null;
    try {
      final uint8list = await VideoThumbnail.thumbnailData(
        video: videoUrl,
        imageFormat: ImageFormat.PNG,
        maxWidth: 128,
        quality: 25,
      );
      return uint8list;
    } catch (e) {
      print('Thumbnail error: $e');
      return null;
    }
  }


  getVendorPackage() async {
    isPackageLoading.value = true;
    final response = await useCases.getVendorPackage(
      vendorId: vendorsItem.venderID,
    );
    return response.fold(
      (error) {
        isPackageLoading.value = false;
      },
      (success) {
        if (success.isNotEmpty) {
          packageList = success;
        }
        isPackageLoading.value = false;
        update();
      },
    );
  }

}
