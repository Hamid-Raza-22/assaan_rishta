import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'export.dart';

class BuyConnectsView extends GetView<BuyConnectsController> {
  const BuyConnectsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BuyConnectsController>(
      initState: (_) {
        Get.put(BuyConnectsController());

      },
      builder: (_) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            
            // Block back if purchase is in progress
            if (controller.isPurchaseInProgress.value) {
              Get.snackbar(
                'Transaction In Progress',
                'براہ کرم لین دین مکمل ہونے تک انتظار کریں',
                backgroundColor: Colors.orange,
                colorText: Colors.white,
                duration: const Duration(seconds: 2),
              );
              return;
            }
            
            // Allow back navigation
            Get.back();
          },
          child: Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            child: controller.isLoading.isFalse
                ? ListView(
                    children: [
                      const SizedBox(height: 16),
                      Container(
                        width: Get.width,
                        height: 200,
                        decoration: BoxDecoration(
                            color: AppColors.blackColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.transparent),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                AppColors.primaryColor,
                                AppColors.secondaryColor,
                              ],
                            )),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const AppText(
                                  text: "Your Connects",
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whiteColor,
                                ),
                                Obx(() => AppText(
                                  text: '${controller.totalConnects.value}',
                                  fontSize: 30,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.whiteColor,
                                )),
                              ],
                            ),
                            ConfettiWidget(
                              confettiController: controller.controllerCenter!,
                              blastDirectionality:
                                  BlastDirectionality.explosive,
                              // don't specify a direction, blast randomly
                              shouldLoop: true,
                              // start again as soon as the animation is finished
                              colors: const [
                                Colors.green,
                                Colors.blue,
                                Colors.pink,
                                Colors.orange,
                                Colors.purple
                              ],
                              // manually specify the colors to be used
                              createParticlePath:
                                  drawCoin, // define a custom shape/path.
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _getNoteForPayment(),
                      const SizedBox(height: 16),
                      ListView.builder(
                          shrinkWrap: true,
                          itemCount: getPackageList().length,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) =>
                              getPlanItem(context, index)),
                      const SizedBox(height: 20),
                    ],
                  )
                : connectsShimmer(context),
          ),
        ),
        );
      },
    );
  }

  _appBar() {
    return const PreferredSize(
      preferredSize: Size(double.infinity, 40),
      child: CustomAppBar(
        isBack: true,
        title: "Buy Connects",
      ),
    );
  }

  _getNoteForPayment() {
    return Container(
      padding: const EdgeInsets.all(08),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: AppColors.blackColor,
          )),
      child: const AppText(
        text:
            "For Manual Purchase - You can contact our support team for further assistance call +92-306-4727345",
        overflow: TextOverflow.visible,
        textAlign: TextAlign.center,
      ),
    );
  }

  getPlanItem(context, index) {
    PackageModel package = getPackageList()[index];
    ProductDetails? product = controller.getProductById(package.productId);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.only(
        bottom: 16,
        left: 16,
        right: 16,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFFF5F5F5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              width: 200,
              height: 10,
              decoration: BoxDecoration(
                color: Colors.brown[400],
                borderRadius: const BorderRadius.only(
                  bottomRight: Radius.circular(10),
                  bottomLeft: Radius.circular(10),
                ),
                gradient: LinearGradient(
                  colors: package.topColor,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                package.packageName,
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              Text(
                product != null ? product.price : package.packagePrice,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            "The plan includes:",
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.black,
                size: 18,
              ),
              const SizedBox(width: 8),
              Text(
                "Only ${package.profiles} Profiles are allowed to chat",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.black,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  package.description,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.black,
                size: 18,
              ),
              const SizedBox(width: 8),
              Flexible(
                fit: FlexFit.tight,
                child: Text(
                  package.tagline,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.black,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          CustomButton(
            height: 40,
            text: "Purchase Package",
            isGradient: true,
            fontColor: AppColors.whiteColor,
            onTap: () {
              showPurchaseBottomSheet(
                context: context,
                controller: controller,
                package: package,
              );
            },
          ),
        ],
      ),
    );
  }

  /// A custom Path to paint stars.
  Path drawStar(Size size) {
    // Method to convert degrees to radians
    double degToRad(double deg) => deg * (pi / 180.0);

    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }
    path.close();
    return path;
  }

  Path drawCoin(Size size) {
    final path = Path();
    final radius = size.width / 2;

    // Draw the circle (coin)
    path.addOval(
        Rect.fromCircle(center: Offset(radius, radius), radius: radius));

    // Optionally, you can add additional details like an inner circle (for design purposes)
    final innerRadius = radius * 0.8;
    path.addOval(
        Rect.fromCircle(center: Offset(radius, radius), radius: innerRadius));

    path.close();
    return path;
  }

  connectsShimmer(context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        children: [
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 16),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 05),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 05),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }

  List<PackageModel> getPackageList() {
    return [
      PackageModel(
        packageName: "Silver",
        packagePrice: "2000",
        percentPerLead: "20",
        profiles: "03",
        totalConnects: "220",
        productId: "silver_1500",
        description: AppConstants.silverDesc,
        tagline: AppConstants.silverTagline,
        topColor: [
          const Color(0xFFB0B0B0),
          const Color(0xFFF1F1F1),
          const Color(0xFFB0B0B0),
        ],
      ),
      PackageModel(
        packageName: "Gold",
        packagePrice: "3500",
        percentPerLead: "20",
        profiles: "08",
        totalConnects: "500",
        productId: "gold_2000",
        description: AppConstants.goldDesc,
        tagline: AppConstants.goldTagline,
        topColor: [
          const Color(0xFF9F702B),
          const Color(0xFFFFCC82),
          const Color(0xFF9F702B),
        ],
      ),
    ];
  }
}

class PackageModel {
  String packageName;
  String packagePrice;
  String percentPerLead;
  String profiles;
  String totalConnects;
  String productId;
  String description;
  String tagline;
  List<Color> topColor;

  PackageModel({
    required this.packageName,
    required this.packagePrice,
    required this.percentPerLead,
    required this.profiles,
    required this.totalConnects,
    required this.productId,
    required this.description,
    required this.tagline,
    required this.topColor,
  });
}
