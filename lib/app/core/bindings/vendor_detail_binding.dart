import 'package:get/get.dart';
import '../../views/vendor/details/vender_detail_controller.dart';

class VendorDetailBinding extends Bindings {
  @override
  void dependencies() {
    // Create a fresh controller instance for each navigation
    Get.lazyPut<VendorDetailController>(
      () => VendorDetailController(),
      fenix: true,
    );
  }
}
