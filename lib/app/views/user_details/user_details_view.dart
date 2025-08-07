// Updated user_details_view.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/export.dart';
import '../../utils/exports.dart';
import '../../viewmodels/user_details_viewmodel.dart';
import '../../widgets/export.dart';

import '../profile/export.dart';

class UserDetailsView extends GetView<UserDetailsController> {
  const UserDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<UserDetailsController>(
      initState: (_) {
        Get.put(UserDetailsController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: AppColors.whiteColor,
          appBar: const PreferredSize(
            preferredSize: Size(double.infinity, 40),
            child: CustomAppBar(
              isBack: true,
            ),
          ),
          body: controller.isLoading.isFalse
              ? ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            children: [
              getProfileImage(context),
              const SizedBox(height: 10),
              getProfileInfo(),
              const SizedBox(height: 10),
              getPartnerPreferences(),
              const SizedBox(height: 20),
            ],
          )
              : const Center(
            child: CircularProgressIndicator(
              color: AppColors.primaryColor,
            ),
          ),
        );
      },
    );
  }

  getProfileImage(context) {
    // Check if user is logged in
    bool isLoggedIn = controller.useCase.userManagementRepo.getUserLoggedInStatus();

    return Stack(
      children: [
        Container(
          height: 245, // Increased height to accommodate login text
          margin: const EdgeInsets.only(top: 60),
          decoration: const BoxDecoration(
            color: AppColors.profileContainerColor,
            borderRadius: BorderRadius.all(
              Radius.circular(20),
            ),
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 55),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AppText(
                        text:
                        '${controller.profileDetails.value.firstName} ${controller.profileDetails.value.lastName}',
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                  const SizedBox(height: 35),
                  // Message Button - Different based on login status
                  isLoggedIn ? _buildLoggedInMessageButton(context) : _buildGuestMessageButton(context),

                  // Login prompt text for guest users
                  if (!isLoggedIn) ...[
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Text(
                        "Please signup or login to activate messaging",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppColors.greyColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              const Positioned(
                left: 0,
                right: 0,
                top: -50,
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 40,
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          top: 0,
          child: ImageHelper(
            image: controller.profileDetails.value.profileImage != null
                ? controller.profileDetails.value.profileImage!
                : AppAssets.imagePlaceholder,
            imageType: controller.profileDetails.value.profileImage != null
                ? ImageType.network
                : ImageType.asset,
            imageShape: ImageShape.circle,
            boxFit: BoxFit.contain,
            height: 90,
            width: 90,
          ),
        ),
      ],
    );
  }

  // Message button for logged in users (original functionality)
  Widget _buildLoggedInMessageButton(BuildContext context) {
    return CustomButton(
      text: "Message",
      isGradient: true,
      fontColor: AppColors.whiteColor,
      fontWeight: FontWeight.w500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: ImageHelper(
          image: AppAssets.icChat,
          imageType: ImageType.asset,
          color: AppColors.whiteColor,
          height: 24,
          width: 24,
        ),
      ),
      fontSize: 18,
      onTap: () {
        if (controller.totalConnects.value >= 0) {
          controller.sendMessageToOtherUser(context);
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                backgroundColor: AppColors.whiteColor,
                title: Text(
                  'No Connects',
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                content: Text(
                  'You don\'t have any connects left. Please purchase more to continue.',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close the dialog
                    },
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Get.to(
                        () => const BuyConnectsView(),
                      );
                    },
                    child: Text(
                      'Purchase',
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        }
      },
    );
  }

  // Message button for guest users (locked with login navigation)
  Widget _buildGuestMessageButton(BuildContext context) {
    return CustomButton(
      text: "Login to Messages",
      isGradient: true,
      // backgroundColor: AppColors.redColor.withOpacity(0.3),
      fontColor: AppColors.whiteColor,
      fontWeight: FontWeight.w500,
      margin: const EdgeInsets.symmetric(horizontal: 20),
      prefixIcon: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Icon(
          Icons.lock,
          color: AppColors.whiteColor,
          size: 24,
        ),
      ),
      fontSize: 18,
      onTap: () {
        controller.navigateToLogin();
      },
    );
  }

  getProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "General Information",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.info,
                color: AppColors.greenColor,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Name',
                subtitle:
                '${controller.profileDetails.value.firstName} ${controller.profileDetails.value.lastName}',
              ),
              getListTile(
                title: 'Gender',
                subtitle: controller.profileDetails.value.gender ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Age',
                subtitle: '${controller.profileDetails.value.age ?? "--"}',
              ),
              getListTile(
                title: 'Caste',
                subtitle: controller.profileDetails.value.cast ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Religion',
                subtitle: controller.profileDetails.value.religion ?? "--",
              ),
              getListTile(
                title: 'Marriage Status',
                subtitle: controller.profileDetails.value.maritalStatus ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Education',
                subtitle: controller.profileDetails.value.education ?? "--",
              ),
              getListTile(
                title: 'Occupation',
                subtitle: controller.profileDetails.value.occupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Height',
                subtitle: '${controller.profileDetails.value.height}',
              ),
              getListTile(
                title: 'Country',
                subtitle: '${controller.profileDetails.value.userCountryName}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'State',
                subtitle: '${controller.profileDetails.value.userStateName}',
              ),
              getListTile(
                title: 'City',
                subtitle: '${controller.profileDetails.value.cityName}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'About Me',
                subtitle: controller.profileDetails.value.userKaTaruf ?? "--",
              ),
              getListTile(
                title: 'About Life Partner',
                subtitle: controller.profileDetails.value.userDiWohtiKaTaruf ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  getFamilyInfo() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "Family Details",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.info,
                color: AppColors.greenColor,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Living',
                subtitle: controller.profileDetails.value.lifeStyle ?? "--",
              ),
              getListTile(
                title: 'Parent Country',
                subtitle:
                controller.profileDetails.value.parentCountryName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Parent State',
                subtitle:
                controller.profileDetails.value.parentStateName ?? "--",
              ),
              getListTile(
                title: 'Parent City',
                subtitle:
                controller.profileDetails.value.parentCityName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Father Alive',
                subtitle:
                getStringBool(controller.profileDetails.value.fatherAlive),
              ),
              getListTile(
                title: 'Father\'s Occupation',
                subtitle:
                controller.profileDetails.value.fatherOccupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Alive',
                subtitle:
                getStringBool(controller.profileDetails.value.motherAlive),
              ),
              getListTile(
                title: 'Mother Occupation',
                subtitle:
                controller.profileDetails.value.motherOccupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Tounge',
                subtitle: controller.profileDetails.value.motherTounge ?? "--",
              ),
              getListTile(
                title: 'Siblings',
                subtitle:
                getStringBool(controller.profileDetails.value.silings),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Number Of Brothers',
                subtitle:
                controller.profileDetails.value.noOfBrother.toString(),
              ),
              getListTile(
                title: 'Number Of Sisters ',
                subtitle: controller.profileDetails.value.noOfSister.toString(),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Married Brothers',
                subtitle:
                controller.profileDetails.value.marriedBrother.toString(),
              ),
              getListTile(
                title: 'Married Sisters',
                subtitle:
                controller.profileDetails.value.marriedSister.toString(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  getPartnerPreferences() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: 10),
                child: AppText(
                  text: "Partner Preference",
                  color: AppColors.blackColor,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Icon(
                Icons.info,
                color: AppColors.greenColor,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Age',
                subtitle:
                '${controller.profileDetails.value.partnerAgeFrom ?? "-"} from ${controller.profileDetails.value.partnerAgeTo ?? "-"}',
              ),
              getListTile(
                title: 'Languages',
                subtitle:
                controller.profileDetails.value.partnerLanguages ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Caste',
                subtitle: controller.profileDetails.value.partnerCaste,
              ),
              getListTile(
                title: 'Education',
                subtitle: controller.profileDetails.value.partnerEducation,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Occupation',
                subtitle: controller.profileDetails.value.partnerOccupation,
              ),
              getListTile(
                title: 'Monthly Income',
                subtitle: controller.profileDetails.value.partnerAnnualIncome,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Tongue',
                subtitle: controller.profileDetails.value.partnerMotherTounge,
              ),
              getListTile(
                title: 'Religion',
                subtitle: controller.profileDetails.value.partnerReligion,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Height',
                subtitle: controller.profileDetails.value.partnerHeight,
              ),
              getListTile(
                title: 'Built',
                subtitle: controller.profileDetails.value.partnerBuilt,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Complexion',
                subtitle: controller.profileDetails.value.partnerComplexion,
              ),
              getListTile(
                title: 'Marital Status ',
                subtitle:
                controller.profileDetails.value.partnerMaritalStatus ??
                    "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Drinking',
                subtitle: controller.profileDetails.value.partnerDrinkHabbit,
              ),
              getListTile(
                title: 'Smoking',
                subtitle: controller.profileDetails.value.partnerSmokeHabbit,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'About Partner',
                subtitle: controller.profileDetails.value.aboutPartner,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String getStringBool(bool? value) {
    if (value != null) {
      if (value) {
        return "Yes";
      } else {
        return "No";
      }
    } else {
      return "No";
    }
  }
}
