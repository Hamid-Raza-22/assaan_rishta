import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import '../export.dart';

class ProfileDetailsView extends GetView<ProfileDetailsController> {
  const ProfileDetailsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileDetailsController>(
      initState: (_) {
        Get.put(ProfileDetailsController());
      },
      builder: (_) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: SafeArea(
            child: controller.isLoading.isFalse
                ? ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    children: [
                      const SizedBox(height: 10),
                      getProfileInfo(),
                      const SizedBox(height: 10),
                      //add height and state
                    ],
                  )
                : profileShimmer(context),
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
        title: "Profile Details",
      ),
    );
  }

  getProfileInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const AppText(
            text: "General Info",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
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
                subtitle: '${controller.profileDetails.value.gender}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Age',
                subtitle: '${controller.profileDetails.value.age}',
              ),
              getListTile(
                title: 'Caste',
                subtitle: '${controller.profileDetails.value.cast}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Religion',
                subtitle: '${controller.profileDetails.value.religion}',
              ),
              getListTile(
                title: 'Marriage Status',
                subtitle: '${controller.profileDetails.value.maritalStatus}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Education',
                subtitle: '${controller.profileDetails.value.education}',
              ),
              getListTile(
                title: 'Occupation',
                subtitle: '${controller.profileDetails.value.occupation}',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Email',
                subtitle: '${controller.profileDetails.value.email}',
              ),
              getListTile(
                title: 'Mobile No',
                subtitle: '${controller.profileDetails.value.mobileNo}',
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
                subtitle:
                    controller.profileDetails.value.userDiWohtiKaTaruf ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  getPersonalAndContactInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const AppText(
            text: "Personal & Contact Info",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Profile Name',
                subtitle: controller.profileDetails.value.profileName ?? "--",
              ),
              getListTile(
                title: 'Created For',
                subtitle: controller.profileDetails.value.forWhom ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Like to Marry',
                subtitle: controller.profileDetails.value.likeToMarry ?? "--",
              ),
              getListTile(
                title: 'Culture',
                subtitle: controller.profileDetails.value.culture ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Life Style',
                subtitle: controller.profileDetails.value.lifeStyle ?? "--",
              ),
              getListTile(
                title: 'Personal Transport',
                subtitle: controller.profileDetails.value.transport ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Languages',
                subtitle: controller.profileDetails.value.languages ?? "--",
              ),
            ],
          ),
          const Divider(),
          const AppText(
            text: "About Myself",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'About',
                subtitle: controller.profileDetails.value.aboutMyself ?? "--",
              ),
            ],
          ),
          const Divider(),
          const AppText(
            text: "Contact Info",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Street Address',
                subtitle: controller.profileDetails.value.streetAddress ?? "--",
              ),
              getListTile(
                title: 'Born in Country',
                subtitle:
                    controller.profileDetails.value.bornCountryName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Born in State',
                subtitle: controller.profileDetails.value.bornStateName ?? "--",
              ),
              getListTile(
                title: 'Born in City',
                subtitle:
                    controller.profileDetails.value.bornInCityName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Nationality',
                subtitle: controller.profileDetails.value.nationality ?? "--",
              ),
              getListTile(
                title: 'Residential Type',
                subtitle:
                    controller.profileDetails.value.residentialType ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Postal Code',
                subtitle: controller.profileDetails.value.postalCode.toString(),
              ),
              getListTile(
                title: 'Relocate',
                subtitle:
                    getStringBool(controller.profileDetails.value.relocate),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Landline Number',
                subtitle: controller.profileDetails.value.landline ?? "--",
              ),
              getListTile(
                title: 'Cell Phone Protection',
                subtitle:
                    controller.profileDetails.value.cellPhoneProtectionStatus ??
                        "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  getFinancialStatusPhysicalAppearance() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const AppText(
            text: "Financial Status",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Monthly Income',
                subtitle: controller.profileDetails.value.monthlyIncome ?? "--",
              ),
              getListTile(
                title: 'Family Status',
                subtitle: controller.profileDetails.value.familyStatus ?? "--",
              ),
            ],
          ),
          const Divider(),
          const AppText(
            text: "Physical Appearance",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Complexion',
                subtitle: controller.profileDetails.value.complexion ?? "--",
              ),
              getListTile(
                title: 'Eye Color',
                subtitle: controller.profileDetails.value.eyeColor ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Hair Color',
                subtitle: controller.profileDetails.value.hairColor ?? "--",
              ),
              getListTile(
                title: 'Weight',
                subtitle: '${controller.profileDetails.value.weight}kg',
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Built',
                subtitle: controller.profileDetails.value.built ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  getFamilyAndHabits() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const AppText(
            text: "Family Details",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Living',
                subtitle: controller.profileDetails.value.liveWith ?? "--",
              ),
              getListTile(
                title: 'Parent\'s Country',
                subtitle:
                    controller.profileDetails.value.parentCountryName ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Parent\'s State',
                subtitle:
                    controller.profileDetails.value.parentStateName ?? "--",
              ),
              getListTile(
                title: 'Parent\'s City',
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
                title: 'Mother\'s Occupation',
                subtitle:
                    controller.profileDetails.value.motherOccupation ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Mother Tongue',
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
                title: 'Number of Brother',
                subtitle: controller.profileDetails.value.noOfBrother.toString(),
              ),
              getListTile(
                title: 'Number of Sisters',
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
                subtitle: controller.profileDetails.value.marriedSister.toString(),
              ),
            ],
          ),
          const Divider(),
          const AppText(
            text: "Habits",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Namaz',
                subtitle: getStringBool(controller.profileDetails.value.namaz),
              ),
              getListTile(
                title: 'Namaz Time',
                subtitle: controller.profileDetails.value.namazTimes ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Fasting',
                subtitle:
                    getStringBool(controller.profileDetails.value.fasting),
              ),
              getListTile(
                title: 'Zakat',
                subtitle: getStringBool(controller.profileDetails.value.zakat),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Drink',
                subtitle:
                    getStringBool(controller.profileDetails.value.isDrink),
              ),
              getListTile(
                title: 'Drink Routine',
                subtitle: controller.profileDetails.value.drink ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Smoke',
                subtitle:
                    getStringBool(controller.profileDetails.value.isSmoke),
              ),
              getListTile(
                title: 'Smoke Routine',
                subtitle: controller.profileDetails.value.smoke ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Interests',
                subtitle: controller.profileDetails.value.interest ?? "--",
              ),
              getListTile(
                title: 'Hobbies',
                subtitle: controller.profileDetails.value.hobbies ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Diet',
                subtitle: controller.profileDetails.value.diet ?? "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  getHealthAndOrigin() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10),
          const AppText(
            text: "Health Information",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Blood Group',
                subtitle: controller.profileDetails.value.bloodGroup ?? "--",
              ),
              getListTile(
                title: 'Handicapped',
                subtitle:
                    getStringBool(controller.profileDetails.value.handicapped),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Disability',
                subtitle: controller.profileDetails.value.disability ?? "--",
              ),
              getListTile(
                title: 'Eye Problem',
                subtitle:
                    getStringBool(controller.profileDetails.value.eyeProblem) ??
                        "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Eye Defect',
                subtitle:
                    controller.profileDetails.value.eyeProblemDefect ?? "--",
              ),
              getListTile(
                title: 'Health Problem',
                subtitle: getStringBool(
                    controller.profileDetails.value.healthProblem),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Health Defect',
                subtitle: controller.profileDetails.value.healthDefect ?? "--",
              ),
              getListTile(
                title: 'Taking Medicines',
                subtitle: getStringBool(
                    controller.profileDetails.value.takingMedicines),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Which Medicines',
                subtitle:
                    controller.profileDetails.value.whichMedicines ?? "--",
              ),
              getListTile(
                title: 'Do Exercise',
                subtitle:
                    getStringBool(controller.profileDetails.value.doExercise),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Which Exercise',
                subtitle: controller.profileDetails.value.exercises ?? "--",
              ),
              getListTile(
                title: 'Visit Gym',
                subtitle:
                    getStringBool(controller.profileDetails.value.visitGym),
              ),
            ],
          ),
          const Divider(),
          const AppText(
            text: "Origin",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Ethnic Origin',
                subtitle: controller.profileDetails.value.ethnicOrigin ?? "--",
              ),
              getListTile(
                title: 'Pakistani CNIC',
                subtitle: controller.profileDetails.value.pakiCnic ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Pakistani Driving License',
                subtitle: getStringBool(
                    controller.profileDetails.value.pakiDrivingLicense),
              ),
              getListTile(
                title: 'Pakistani Driving License Number',
                subtitle:
                    controller.profileDetails.value.pakiDrivingLicenseNo ??
                        "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Pakistani Passport',
                subtitle:
                    getStringBool(controller.profileDetails.value.pakiPassport),
              ),
              getListTile(
                title: 'Pakistani Passport Number',
                subtitle:
                    controller.profileDetails.value.pakiPassportNo ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Pakistani Tax',
                subtitle:
                    getStringBool(controller.profileDetails.value.pakiTax),
              ),
              getListTile(
                title: 'Pakistani Tax Number',
                subtitle: controller.profileDetails.value.pakiTaxNo ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'Dual Nationality',
                subtitle: getStringBool(
                    controller.profileDetails.value.dualNationality),
              ),
              getListTile(
                title: 'Social Security Number',
                subtitle:
                    controller.profileDetails.value.socialSecurityNo ?? "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'International Driving License',
                subtitle: getStringBool(controller
                    .profileDetails.value.internationalDrivingLicense),
              ),
              getListTile(
                title: 'International Driving License Number',
                subtitle: controller
                        .profileDetails.value.internationalDrivingLicenseNo ??
                    "--",
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getListTile(
                title: 'International Passport',
                subtitle: getStringBool(
                    controller.profileDetails.value.internationalPassport),
              ),
              getListTile(
                title: 'International Passport Number',
                subtitle:
                    controller.profileDetails.value.internationalPassportNo ??
                        "--",
              ),
            ],
          ),
        ],
      ),
    );
  }

  profileShimmer(context) {
    double w = MediaQuery.sizeOf(context).width;
    double h = MediaQuery.sizeOf(context).height;
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        children: [
          BannerPlaceholder(
            width: w,
            height: h * 0.99,
            borderRadius: 10,
          ),
          const SizedBox(height: 05),
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

Widget getListTile({title, String? subtitle}) {
  return Expanded(
    child: ListTile(
      contentPadding: EdgeInsets.zero,
      title: AppText(
        text: title,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.blackColor,
      ),
      subtitle: AppText(
        text: subtitle != "null" ? subtitle ?? "--" : "--",
        fontSize: 14,
        fontWeight: FontWeight.w300,
        color: AppColors.blackColor,
      ),
    ),
  );
}
