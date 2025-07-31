import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../widgets/export.dart';
import 'export.dart';

class VendorView extends GetView<VendorController> {
  const VendorView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VendorController>(
      initState: (_) {
        Get.put(VendorController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: const PreferredSize(
            preferredSize: Size(double.infinity, 40),
            child: CustomAppBar(
              isBack: false,
              title: "Vendors",
            ),
          ),
          body: GridView.builder(
            shrinkWrap: true,
            itemCount: controller.vendorCategoryList.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              mainAxisSpacing: 8.0, // spacing between rows
              crossAxisSpacing: 8.0, // spacing between columns
            ),
            itemBuilder: (context, index) {
              return _categoryItem(context, index);
            },
          ),
        );
      },
    );
  }

  _categoryItem(context, index) {
    VendorCategory category = controller.vendorCategoryList[index];
    return GestureDetector(
      // onTap: () {
      //   Get.to(
      //     () => const VendorListingView(),
      //     binding: AppBindings(),
      //     transition: Transition.circularReveal,
      //     duration: const Duration(milliseconds: 500),
      //     arguments: category,
      //   );
      // },
      child: Container(
        margin: const EdgeInsets.all(08),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.all(Radius.circular(10)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withValues(alpha: 0.5),
              spreadRadius: 1,
              blurRadius: 2,
              offset: const Offset(0, 3), // changes position of shadow
            ),
          ],
        ),
        width: 185,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(10),
                topLeft: Radius.circular(10),
              ),
              child: ImageHelper(
                image: category.image,
                imageType: ImageType.asset,
                height: 125,
                width: 185,
                boxFit: BoxFit.cover,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AppText(
                  text: category.title,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackColor,
                ),
              ],
            ),
            const SizedBox(),
          ],
        ),
      ),
    );
  }
}
