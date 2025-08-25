// optimized_vender_detail_controller.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'dart:typed_data';
import '../../../core/base/export.dart';
import '../../../core/export.dart';
import '../../../domain/export.dart';

class VendorDetailController extends BaseController {
  final useCases = Get.find<UserManagementUseCase>();
  int selectedIndex = 0;

  // Initialize with empty vendor to prevent crashes
  VendorsList vendorsItem = VendorsList();
  bool _isInitialized = false;

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

  // For view number functionality
  Timer? _timer;
  RxBool isButtonVisible = true.obs;
  RxInt secondsRemaining = 05.obs;
  RxBool isClicked = false.obs;

  @override
  void onInit() {
    debugPrint('🎯 OptimizedVendorDetailController onInit called');
    _initializeController();
    super.onInit();
  }

  void _initializeController() {
    final arguments = Get.arguments;
    debugPrint('📋 Arguments received: ${arguments?.runtimeType}');

    if (arguments != null && arguments is VendorsList) {
      _setVendorData(arguments);
    } else {
      debugPrint('⚠️ No valid vendor data in arguments');
    }
  }

  void _setVendorData(VendorsList vendor) {
    vendorsItem = vendor;
    _isInitialized = true;

    debugPrint('✅ Vendor initialized: ${vendorsItem.venderBusinessName} (ID: ${vendorsItem.venderID})');

    // Load APIs immediately after setting data
    _initApis();
  }

  // Optimized method to update vendor data (for deep links)
  void updateVendorData(VendorsList newVendor) {
    debugPrint('🔄 Updating vendor data: ${newVendor.venderBusinessName}');

    // Clear previous data
    _clearData();

    // Set new vendor data
    _setVendorData(newVendor);

    // Update UI immediately
    update();
  }

  void _clearData() {
    serviceList.clear();
    questionsList.clear();
    albumList.clear();
    videoList.clear();
    packageList.clear();

    // Reset loading states
    isServiceLoading.value = false;
    isQuestionsLoading.value = false;
    isAlbumsLoading.value = false;
    isVideoLoading.value = false;
    isPackageLoading.value = false;

    // Reset view number state
    isClicked.value = false;
    isButtonVisible.value = true;
    secondsRemaining.value = 05;
    _timer?.cancel();
  }

  void _initApis() {
    if (vendorsItem.venderID != null && _isInitialized) {
      debugPrint('📡 Loading APIs for vendor ID: ${vendorsItem.venderID}');

      // Load all APIs in parallel for better performance
      Future.wait([
        _getVendorServices(),
        _getVendorQuestions(),
        _getVendorAlbums(),
        _getVendorVideo(),
        _getVendorPackage(),
      ]).then((_) {
        debugPrint('✅ All vendor data loaded');
      }).catchError((error) {
        debugPrint('❌ Error loading vendor data: $error');
      });
    }
  }

  bool get hasValidVendor => _isInitialized && vendorsItem.venderID != null;

  void startTimer() {
    isClicked.value = true;
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

  // Optimized API methods with better error handling
  Future<void> _getVendorServices() async {
    if (!hasValidVendor) return;

    try {
      isServiceLoading.value = true;
      final response = await useCases.getVendorServices(
        vendorId: vendorsItem.venderID,
      );

      response.fold(
            (error) {
          debugPrint('❌ Services error: $error');
        },
            (success) {
          if (success.isNotEmpty) {
            serviceList = success;
            debugPrint('✅ Loaded ${success.length} services');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in services: $e');
    } finally {
      isServiceLoading.value = false;
      update();
    }
  }

  Future<void> _getVendorQuestions() async {
    if (!hasValidVendor) return;

    try {
      isQuestionsLoading.value = true;
      final response = await useCases.getVendorQuestions(
        vendorId: vendorsItem.venderID,
      );

      response.fold(
            (error) {
          debugPrint('❌ Questions error: $error');
        },
            (success) {
          if (success.isNotEmpty) {
            questionsList = success;
            debugPrint('✅ Loaded ${success.length} questions');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in questions: $e');
    } finally {
      isQuestionsLoading.value = false;
      update();
    }
  }

  Future<void> _getVendorAlbums() async {
    if (!hasValidVendor) return;

    try {
      isAlbumsLoading.value = true;
      final response = await useCases.getVendorAlbums(
        vendorId: vendorsItem.venderID,
      );

      response.fold(
            (error) {
          debugPrint('❌ Albums error: $error');
        },
            (success) {
          if (success.isNotEmpty) {
            albumList = success;
            debugPrint('✅ Loaded ${success.length} albums');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in albums: $e');
    } finally {
      isAlbumsLoading.value = false;
      update();
    }
  }

  Future<void> _getVendorVideo() async {
    if (!hasValidVendor) return;

    try {
      isVideoLoading.value = true;
      final response = await useCases.getVendorVideo(
        vendorId: vendorsItem.venderID,
      );

      response.fold(
            (error) {
          debugPrint('❌ Videos error: $error');
        },
            (success) {
          if (success.isNotEmpty) {
            videoList = success;
            debugPrint('✅ Loaded ${success.length} videos');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in videos: $e');
    } finally {
      isVideoLoading.value = false;
      update();
    }
  }

  Future<void> _getVendorPackage() async {
    if (!hasValidVendor) return;

    try {
      isPackageLoading.value = true;
      final response = await useCases.getVendorPackage(
        vendorId: vendorsItem.venderID,
      );

      response.fold(
            (error) {
          debugPrint('❌ Packages error: $error');
        },
            (success) {
          if (success.isNotEmpty) {
            packageList = success;
            debugPrint('✅ Loaded ${success.length} packages');
          }
        },
      );
    } catch (e) {
      debugPrint('❌ Exception in packages: $e');
    } finally {
      isPackageLoading.value = false;
      update();
    }
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
      debugPrint('❌ Thumbnail error: $e');
      return null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Legacy methods for compatibility (marked deprecated)
  @Deprecated('Use _getVendorServices instead')
  getVendorServices() => _getVendorServices();

  @Deprecated('Use _getVendorQuestions instead')
  getVendorQuestions() => _getVendorQuestions();

  @Deprecated('Use _getVendorAlbums instead')
  getVendorAlbums() => _getVendorAlbums();

  @Deprecated('Use _getVendorVideo instead')
  getVendorVideo() => _getVendorVideo();

  @Deprecated('Use _getVendorPackage instead')
  getVendorPackage() => _getVendorPackage();
}