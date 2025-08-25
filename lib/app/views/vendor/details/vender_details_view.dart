import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import 'package:share_plus/share_plus.dart'; // Add this import

import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import '../export.dart';

class VendorDetailView extends GetView<VendorDetailController> {


// Add this debug method to your VendorDetailView class (around line 10-15)

  @override
  Widget build(BuildContext context) {


    // Add debug logging
    debugPrint('🔍 VendorDetailView build called');
    debugPrint('🔍 Get.arguments type: ${Get.arguments.runtimeType}');
    debugPrint('🔍 Get.arguments value: ${Get.arguments}');


    return GetBuilder<VendorDetailController>(
      initState: (_) {
        debugPrint('🔍 VendorDetailView initState called');
        debugPrint('🔍 Arguments in initState: ${Get.arguments}');

        // Defer any controller updates to after the build
        WidgetsBinding.instance.addPostFrameCallback((_) {
          // Check if controller already exists
          if (Get.isRegistered<VendorDetailController>()) {
            debugPrint('🔍 VendorDetailController already registered');

            // Get the existing controller
            final existingController = Get.find<VendorDetailController>();
            debugPrint('🔍 Existing controller vendor ID: ${existingController.vendorsItem?.venderID}');

            // Check if we have new vendor data in arguments
            final arguments = Get.arguments;
            if (arguments != null && arguments is VendorsList) {
              debugPrint('🔄 New vendor data found in arguments, updating controller...');

              // Update the existing controller with new vendor data
              existingController.updateVendorData(arguments);
              debugPrint('✅ Controller updated with vendor: ${arguments.venderBusinessName}');
            } else {
              debugPrint('⚠️ No new vendor data in arguments');
            }
          } else {
            debugPrint('🔍 Creating new VendorDetailController');
            Get.put(VendorDetailController());
          }
        });
      },
      builder: (_) {
        debugPrint('🔍 VendorDetailView builder called');
        debugPrint('🔍 Controller vendor ID: ${controller.vendorsItem?.venderID}');
        debugPrint('🔍 Controller vendor name: ${controller.vendorsItem?.venderBusinessName}');

        // Check if vendor data is available
        if (controller.vendorsItem?.venderID == null) {
          // Show loading or error state
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: const PreferredSize(
              preferredSize: Size(double.infinity, 40),
              child: CustomAppBar2(
                isBack: true,
                title: "Loading...",
              ),
            ),
            // body: const Center(
            //   child: CircularProgressIndicator(
            //     color: AppColors.primaryColor,
            //   ),
            // ),
          );
        }

        // Rest of your existing build method...
        return Scaffold(

          backgroundColor: Colors.white,
          appBar: PreferredSize(
            preferredSize: const Size(double.infinity, 40),
            child: CustomAppBar2(
              isBack: true,
              title: controller.vendorsItem.vendorCategoryName,
              actions: [
                // Add share button in app bar
                IconButton(
                  onPressed: () => _shareVendor(),
                  icon: const Icon(
                    Icons.share,
                    color: AppColors.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  // Vendor Profile Image with Share Button Overlay
                  Stack(
                    children: [
                      Center(
                        child: ImageHelper(
                          image: controller.vendorsItem.logo ?? AppAssets.userImage,
                          imageType: ImageType.network,
                          height: 110,
                          width: 110,
                          boxFit: BoxFit.cover,
                          imageShape: ImageShape.circle,
                        ),
                      ),
                      // Share button positioned at top right of image
                      // Positioned(
                      //   right: MediaQuery.of(context).size.width / 2 - 65,
                      //   top: 0,
                      //   child: Container(
                      //     decoration: BoxDecoration(
                      //       color: AppColors.primaryColor,
                      //       shape: BoxShape.circle,
                      //       boxShadow: [
                      //         BoxShadow(
                      //           color: Colors.black.withOpacity(0.2),
                      //           blurRadius: 4,
                      //           offset: const Offset(0, 2),
                      //         ),
                      //       ],
                      //     ),
                      //     child: IconButton(
                      //       onPressed: () => _shareVendor(),
                      //       icon: const Icon(
                      //         Icons.share,
                      //         color: Colors.white,
                      //         size: 20,
                      //       ),
                      //       padding: const EdgeInsets.all(8),
                      //       constraints: const BoxConstraints(),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AppText(
                    text: controller.vendorsItem.venderBusinessName,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 5),
                  // Share button below vendor name
                  // TextButton.icon(
                  //   onPressed: () => _shareVendor(),
                  //   icon: const Icon(
                  //     Icons.share,
                  //     size: 18,
                  //     color: AppColors.primaryColor,
                  //   ),
                  //   label: const AppText(
                  //     text: "Share Vendor",
                  //     fontSize: 14,
                  //     color: AppColors.primaryColor,
                  //   ),
                  // ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        text: "Category: ",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        text: controller.vendorsItem.vendorCategoryName,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const AppText(
                        text: "Email: ",
                        fontWeight: FontWeight.w500,
                        fontSize: 16,
                      ),
                      const SizedBox(width: 4),
                      AppText(
                        text: controller.vendorsItem.venderEmail,
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Obx(
                        () => controller.isClicked.isFalse
                        ? CustomButton(
                      text: "View Number",
                      margin: const EdgeInsets.symmetric(horizontal: 40),
                      backgroundColor: AppColors.primaryColor,
                      fontColor: AppColors.whiteColor,
                      onTap: () {
                        controller.startTimer();
                      },
                    )
                        : const SizedBox.shrink(),
                  ),
                  Obx(
                        () => controller.isClicked.isTrue
                        ? getVendorInformation()
                        : const SizedBox.shrink(),
                  ),
                  const SizedBox(height: 20),
                  const AppText(
                    text: "About Company",
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                  const SizedBox(height: 13),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      controller.vendorsItem!.aboutCompany ?? '',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderColor),
                    ),
                    child: const Column(
                      children: [
                        AppText(
                          text: "Call Asaan-Rishta for the best price!",
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                        SizedBox(height: 10),
                        AppText(
                          text: "+92-307-4052552  +92-306-4727345",
                          fontWeight: FontWeight.w400,
                          fontSize: 16,
                          color: AppColors.primaryColor,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTextItem("Services", 0),
                      const SizedBox(width: 10),
                      _buildTextItem("Questions", 1),
                      const SizedBox(width: 10),
                      _buildTextItem("ALBUMS ", 2),
                      const SizedBox(width: 10),
                      _buildTextItem("VIDEOS", 3),
                      const SizedBox(width: 10),
                      _buildTextItem("PACKAGES", 4),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  if (controller.selectedIndex == 0)
                    getServiceTab()
                  else if (controller.selectedIndex == 1)
                    getQuestionTab()
                  else if (controller.selectedIndex == 2)
                      getAlbumTab()
                    else if (controller.selectedIndex == 3)
                        getVideoTab()
                      else if (controller.selectedIndex == 4)
                          getPackageTab(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Add share vendor method
// Add this method to your VendorDetailView class

  void _shareVendor() async {
    try {
      // Show loading indicator
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            color: AppColors.primaryColor,
          ),
        ),
        barrierDismissible: false,
      );

      // Generate deep links for vendor
      final vendorId = controller.vendorsItem?.venderID;
      final vendorName = controller.vendorsItem?.venderBusinessName;
      final vendorCategory = controller.vendorsItem?.vendorCategoryName;

      if (vendorId == null) {
        // Close loading dialog
        if (Get.isDialogOpen ?? false) {
          Get.back();
        }

        Get.snackbar(
          'Error',
          'Cannot share vendor at this time.',
          backgroundColor: Colors.red.withOpacity(0.1),
          colorText: Colors.red,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Create both HTTPS and custom scheme links
      final httpsLink = 'https://asaanrishta.com/vendor-details-view/$vendorId';
      final customLink = 'asaanrishta://vendor-details-view/$vendorId';

      // Create share message
      final shareMessage = '''
🏪 Check out this amazing vendor on Asaan Rishta!

Business: ${vendorName ?? 'Vendor'}
Category: ${vendorCategory ?? 'Services'}

📱 View Details: $httpsLink

Download Asaan Rishta app:
🤖 Android: https://play.google.com/store/apps/details?id=com.asan.rishta.matrimonial.asan_rishta


Find your perfect match and trusted vendors on Asaan Rishta! 💕
''';

      // Close loading dialog
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      // Share the message
      await Share.share(
        shareMessage,
        subject: 'Check out ${vendorName ?? 'this vendor'} on Asaan Rishta',
      );

      debugPrint('✅ Vendor shared successfully: $vendorId');

      // Show success message
      Get.snackbar(
        'Shared Successfully! 🎉',
        'Vendor details have been shared',
        backgroundColor: Colors.green.withOpacity(0.1),
        colorText: Colors.green,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );

    } catch (e) {
      // Close loading dialog if still open
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }

      debugPrint('❌ Error sharing vendor: $e');

      // Show error message
      Get.snackbar(
        'Error',
        'Failed to share vendor. Please try again.',
        backgroundColor: Colors.red.withOpacity(0.1),
        colorText: Colors.red,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
  getVendorInformation() {
    return Obx(
      () => controller.isButtonVisible.isTrue
          ? Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.blackColor,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 16),
                  const AppText(
                    text: "City",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  AppText(
                    text: controller.vendorsItem?.vendorCityName,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  const Divider(),
                  const AppText(
                    text: "Address: ",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  Text(
                    '${controller.vendorsItem?.venderAddress}',
                    overflow: TextOverflow.visible,
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const Divider(),
                  const AppText(
                    text: "Mobile No: ",
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  AppText(
                    text: '${controller.vendorsItem?.venderPhone}',
                    overflow: TextOverflow.visible,
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                  ),
                  const Divider(),
                  Text(
                    "When you call, don’t forget to mention that you found their profile on AsanRishta.com",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const AppText(
                  text: 'Mention AsanRishta.com for exclusive discount',
                  overflow: TextOverflow.visible,
                  textAlign: TextAlign.center,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
                AppText(
                  text: '${controller.secondsRemaining.value}',
                  overflow: TextOverflow.visible,
                  fontSize: 16,
                  fontWeight: FontWeight.w400,
                ),
              ],
            ),
    );
  }

  Widget _buildTextItem(String text, int index) {
    return Expanded(
      flex: 1,
      child: GestureDetector(
        onTap: () {
          controller.selectedIndex = index;
          print(index);
          controller.update();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AppText(
              text: text,
              color: controller.selectedIndex == index
                  ? AppColors.primaryColor
                  : Colors.black,
              fontWeight: FontWeight.w300,
              fontSize: 12,
            ),
            if (controller.selectedIndex ==
                index) // Show underline only if selected
              Container(
                height: 2,
                width: 110,
                margin: const EdgeInsets.only(top: 05),
                color: AppColors.primaryColor, // Blue underline
              ),
          ],
        ),
      ),
    );
  }

  getServiceTab() {
    return controller.isServiceLoading.isFalse
        ? GridView.builder(
            shrinkWrap: true,
            itemCount: controller.serviceList.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              childAspectRatio: 3.0,
            ),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(03),
                color: AppColors.borderColor,
                alignment: Alignment.center,
                child: AppText(
                  text: controller.serviceList[index].servicesName,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: AppColors.blackColor,
                ),
              );
            },
          )
        : vendorShimmer(childAspectRatio: 3.0);
  }

  getQuestionTab() {
    return controller.isQuestionsLoading.isFalse
        ? ListView.builder(
            shrinkWrap: true,
            itemCount: controller.questionsList.length,
            physics: const BouncingScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.all(03),
                padding: const EdgeInsets.all(08),
                decoration: BoxDecoration(
                  color: AppColors.borderColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      //text: 'Space Availability',
                      text: controller.questionsList[index].qusetion1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      maxLines: 10,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.blackColor,
                    ),
                    const SizedBox(height: 05),
                    AppText(
                      text: controller.questionsList[index].answer,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.start,
                      maxLines: 10,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blackColor,
                    ),
                  ],
                ),
              );
            },
          )
        : vendorShimmer(childAspectRatio: 2.0);
  }

  getAlbumTab() {
    return controller.isAlbumsLoading.isFalse
        ? GridView.builder(
            shrinkWrap: true,
            itemCount: controller.albumList.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  Get.to(
                    () => PhotoGalleryView(
                      imageList: controller.albumList,
                      context: context,
                      selectedIndex: index,
                    ),
                    // binding: AppBindings(),
                    transition: Transition.circularReveal,
                    duration: Duration(milliseconds: 500),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.all(03),
                  color: AppColors.whiteColor,
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                    child: ImageHelper(
                      image: controller.albumList[index].imagesName ??
                          AppAssets.appLogoPng,
                      imageType: ImageType.network,
                      height: 100,
                      width: 185,
                      boxFit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          )
        : vendorShimmer(childAspectRatio: 1.0);
  }

  getVideoTab() {
    return controller.isVideoLoading.isFalse
        ? GridView.builder(
            shrinkWrap: true,
            itemCount: controller.videoList.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              childAspectRatio: 1.0,
            ),
            itemBuilder: (context, index) {
              final item = controller.videoList[index];
              final videoUrl =
                  item.videoName ?? ''; // Assuming video URL is here
              return GestureDetector(
                onTap: () {
                  Get.to(() => VideoPlayerScreen(videoUrl: videoUrl));
                },
                child: FutureBuilder<Uint8List?>(
                  future: controller.getThumbnail(videoUrl),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasData) {
                      return Container(
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.memory(
                                snapshot.data!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                            const Positioned.fill(
                              child: Align(
                                alignment: Alignment.center,
                                child: Icon(
                                  Icons.play_circle_fill,
                                  color: Colors.white,
                                  size: 50,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return Container(
                        margin: const EdgeInsets.all(3),
                        color: AppColors.borderColor,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: ImageHelper(
                            image: AppAssets.appLogoPng,
                            imageType: ImageType.asset,
                            height: 100,
                            width: 185,
                            boxFit: BoxFit.contain,
                          ),
                        ),
                      );
                    }
                  },
                ),
              );
            },
          )
        : vendorShimmer(childAspectRatio: 1.0);
  }

  getPackageTab() {
    return controller.isPackageLoading.isFalse
        ? GridView.builder(
            shrinkWrap: true,
            itemCount: controller.packageList.length,
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // number of items in each row
              childAspectRatio: 1.5,
            ),
            itemBuilder: (context, index) {
              VendorPackages item = controller.packageList[index];
              return GestureDetector(
                onTap: () {
                  showPackageDialog(context, item);
                },
                child: Container(
                  margin: const EdgeInsets.all(03),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      AppText(
                        // text: 'PACKAGE 1',
                        text: controller.packageList[index].packageName,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                      AppText(
                        text:
                            '${item.packageMinPrice} - ${item.packageMaxPrice}/${item.packagePriceType} ',
                        //text: 'Rs 999 -Rs 999/ Per Person',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        fontSize: 12,
                        textAlign: TextAlign.center,
                        fontWeight: FontWeight.w600,
                        color: AppColors.whiteColor,
                      ),
                      AppText(
                        text: '${item.packageTaxPrice}',
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.whiteColor,
                      ),
                    ],
                  ),
                ),
              );
            },
          )
        : vendorShimmer(childAspectRatio: 1.5);
  }

  void showPackageDialog(BuildContext context, VendorPackages item) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: AppColors.whiteColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFE91E63), // Pink background
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Text(
                    '${item.packageName}',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Icon(Icons.close, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 10),
            // Pricing
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${item.packageMinPrice} ',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: ' - ',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '${item.packageMaxPrice}',
                      style: GoogleFonts.poppins(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    TextSpan(
                      text: '${item.packagePriceType}',
                      style: GoogleFonts.poppins(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'TAX EXCLUSIVE',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            // Package items
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                '${item.packageDiscription}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.left,
              ),
            ),

            const SizedBox(height: 20),

            // Close button
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  vendorShimmer({required double childAspectRatio}) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: 06,
        physics: const BouncingScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // number of items in each row
          crossAxisSpacing: 10.0, // spacing between columns
          childAspectRatio: childAspectRatio,
        ),
        itemBuilder: (context, index) {
          return const BannerPlaceholder();
        },
      ),
    );
  }
}
