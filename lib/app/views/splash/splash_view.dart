
import 'package:assaan_rishta/app/core/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/export.dart';
import '../../domain/export.dart';
import '../../utils/exports.dart';
import '../../widgets/export.dart';
import 'export.dart';
import '../../viewmodels/auth_service.dart';



class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService.instance;
    return GetBuilder<SplashController>(
      initState: (_) {
        Get.put(SplashController(
          Get.find<UserManagementUseCase>(),
        ));
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 70),
              child: ListView(
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ImageHelper(
                        image: AppAssets.appLogoPng,
                        imageType: ImageType.asset,
                        boxFit: BoxFit.contain,
                        width: double.infinity,
                        height: 250,
                      ),
                      ImageHelper(
                        image: AppAssets.splashIcon,
                        imageType: ImageType.asset,
                        boxFit: BoxFit.contain,
                      ),
                      Column(
                        children: [
                          const AppText(
                            text: "Welcome To",
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          const AppText(
                            text: "Asaan Rishta",
                            color: AppColors.secondaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          const AppText(
                            text: "Services",
                            color: AppColors.blackColor,
                            fontSize: 20,
                            fontWeight: FontWeight.w400,
                          ),
                          const SizedBox(height: 20),
                          // (controller.useCase.userManagementRepo
                          //             .getUserLoggedInStatus() ==
                          //         false)
                          (!authService.isInitialized.value == false)
                              ? CustomButton(
                                  text: "Get Started",
                                  isGradient: true,
                                  fontColor: AppColors.whiteColor,
                                  suffixIcon: const Icon(
                                    Icons.arrow_forward_sharp,
                                    color: AppColors.whiteColor,
                                  ),
                                   onTap: () =>
                                    Get.offNamed(AppRoutes.ACCOUNT_TYPE)
                                  //     () => const AccountTypeView(),
                                  //     binding: AppBindings(),
                                  //     transition: Transition.circularReveal,
                                  //     duration:
                                  //         const Duration(milliseconds: 500),
                                  //   );

                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
