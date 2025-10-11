import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_datetime_picker_bdaya/flutter_datetime_picker_bdaya.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import '../export.dart';

class EditProfileView extends GetView<EditProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<EditProfileController>(
      initState: (_) {
        Get.put(EditProfileController());
      },
      builder: (_) {
        return Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.white,
          appBar: _appBar(),
          body: SafeArea(
            child: controller.isLoading.isFalse
                ? SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10.0, 10.0, 10.0, 20.0),
                      child: Column(
                        children: [getGeneralInfo(context)],
                      ),
                    ),
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
        title: "Edit Profile",
      ),
    );
  }

  getGeneralInfo(context) {
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
            text: "General Information",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'First Name',
                subtitle: '${controller.profileDetails.value.firstName}',
                tec: controller.firstNameTEC,
              ),
              const SizedBox(width: 05),
              getEditListTile(
                title: 'Last Name',
                subtitle: '${controller.profileDetails.value.lastName}',
                tec: controller.lastNameTEC,
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: "Gender",
                child: CustomDropdown<String>(
                  hintText: '${controller.profileDetails.value.gender}',
                   
                  items: const ["Male", "Female"],
                  onChanged: (value) {
                    controller.gender.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Caste',
                child: CustomDropdown<String>.search(
                  hintText: controller.profileDetails.value.cast??"",
                   
                  items: controller.castNameList,
                  onChanged: (value) {
                    controller.caste = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDateOfBirth(context: context),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Religion',
                child: CustomDropdown<String>(
                  hintText: '${controller.profileDetails.value.religion}',
                   
                  items: controller.religionList,
                  onChanged: (value) {
                    controller.religion = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Marriage Status',
                child: CustomDropdown<String>(
                  hintText: controller.profileDetails.value.maritalStatus??"",
                   
                  items: controller.maritalStatusList,
                  onChanged: (value) {
                    controller.maritalStatus = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Education',
                child: CustomDropdown<String>.search(
                  hintText: controller.profileDetails.value.education??"",
                   
                  items: controller.degreesList,
                  onChanged: (value) {
                    controller.education = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: "Height",
                child: CustomDropdown<String>(
                  hintText: controller.profileDetails.value.height??"",
                   
                  items: controller.heightList,
                  onChanged: (value) {
                    controller.height = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              getDropDownListTile(
                title: 'Occupation',
                child: CustomDropdown<String>.search(
                  hintText: controller.profileDetails.value.occupation??"",
                   
                  items: controller.occupationList,
                  onChanged: (value) {
                    controller.occupation = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'Mobile No',
                subtitle: '${controller.profileDetails.value.mobileNo}',
                tec: controller.mobileTEC,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                  title: 'Country',
                  child: CustomDropdown<AllCountries>.search(
                    hintText: controller.profileDetails.value.userCountryName??"",
                     
                    items: controller.countryList,
                    onChanged: (value) {
                      controller.country = '${value?.name}';
                      controller.profileDetails.value.userStateName = "State";
                      controller.profileDetails.value.cityName = "City";
                      controller.stateController.clear();
                      controller.cityController.clear();
                      controller.getAllStates(context, value?.id);
                    },
                    decoration: basicInfoDecoration(
                      hintStyle: GoogleFonts.poppins(
                        color: AppColors.blackColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  )),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              getDropDownListTile(
                title: 'State',
                child: CustomDropdown<AllStates>.search(
                  hintText: controller.profileDetails.value.userStateName??"",
                   
                  items: controller.stateList,
                  controller: controller.stateController,
                  onChanged: (value) {
                    if (value != null) {
                      controller.stateController.value = value;
                      controller.profileDetails.value.cityName = "City";
                      controller.cityController.clear();
                      controller.getAllCities(context, value.id);
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle:
                        controller.profileDetails.value.userStateName == "State"
                            ? null
                            : GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              getDropDownListTile(
                title: "City",
                child: CustomDropdown<AllCities>.search(
                  hintText: controller.profileDetails.value.cityName??"",
                   
                  controller: controller.cityController,
                  items: controller.cityList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.cityId = value.id!;
                      controller.cityController.value = value;
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle:
                        controller.profileDetails.value.cityName == "City"
                            ? null
                            : GoogleFonts.poppins(
                                color: AppColors.blackColor,
                                fontWeight: FontWeight.w500,
                              ),
                  ),
                ),
              )
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'About Me',
                subtitle: controller.profileDetails.value.userKaTaruf ?? "",
                lines: 4,
                tec: controller.userKaTarufTEC,
              ),
              const SizedBox(width: 05),
              getEditListTile(
                title: 'About Life Partner',
                subtitle:
                    controller.profileDetails.value.userDiWohtiKaTaruf ?? "",
                lines: 4,
                tec: controller.userDiWohtiKaTarufTEC,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateGeneralInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getPersonalInfo(context) {
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
            text: "Personal Information",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'Profile Name',
                subtitle: controller.profileDetails.value.profileName ?? "",
                lines: 1,
                tec: controller.profileNameTEC,
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Created For',
                child: CustomDropdown<String>(
                  hintText: controller.createdFor.value,
                   
                  items: const ["Self", "Son", "Daughter", "Brother", "Sister"],
                  onChanged: (value) {
                    controller.createdFor.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Like to Marry',
                child: CustomDropdown<String>(
                  hintText: controller.likeToMarry.value,
                   
                  items: const [
                    "Soon",
                    "Within 6 months",
                    "In a year",
                    "No fixed time"
                  ],
                  onChanged: (value) {
                    controller.likeToMarry.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Life Style',
                child: CustomDropdown<String>(
                  hintText: controller.lifeStyle.value,
                   
                  items: const [
                    "Rural lifestyle",
                    "Simple living",
                    "Traditional lifestyle"
                  ],
                  onChanged: (value) {
                    controller.lifeStyle.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Culture',
                child: CustomDropdown<String>(
                  hintText: controller.culture.value,
                   
                  items: const [
                    "Punjabi",
                    "Sindhi",
                    "Pashtoon",
                    "Balochi",
                    "Kashmiri"
                  ],
                  onChanged: (value) {
                    controller.culture.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Personal Transport',
                child: CustomDropdown<String>(
                  hintText: controller.transport.value,
                   
                  items: const ["Bike", "Car", "None"],
                  onChanged: (value) {
                    controller.transport.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Languages',
                child: CustomDropdown<String>.multiSelect(
                  hintText: controller.selectedLanguages,
                   
                  items: languagesList,
                  onListChanged: (value) {
                    controller.languages = value.obs;
                    controller.update();
                  },
                  decoration: multiSelectionDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updatePersonalInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getAboutMySelf(context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "About Myself",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'About',
                subtitle: controller.profileDetails.value.aboutMyself ?? "",
                tec: controller.aboutMyselfTEC,
                lines: 5,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateAboutMySelf(context);
            },
          ),
        ],
      ),
    );
  }

  getContactInfo(context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "Contact Information",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                  title: 'Street Address',
                  subtitle: controller.profileDetails.value.streetAddress ?? "",
                  tec: controller.streetAddressTEC),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Born in Country',
                child: CustomDropdown<AllCountries>(
                  hintText: controller.bornCountryName.value,
                   
                  items: controller.countryList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.bornCountryName.value = value.name!;
                      controller.getAllStates(context, value.id);
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Born in State',
                child: CustomDropdown<AllStates>(
                  hintText: controller.bornStateName.value,
                   
                  items: controller.stateList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.bornStateName.value = value.name!;
                      controller.getAllCities(context, value.id);
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Born in City',
                child: CustomDropdown<AllCities>(
                  hintText: controller.bornInCityName.value,
                   
                  items: controller.cityList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.bornInCityId.value = value.id!;
                      controller.bornInCityName.value = value.name!;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Nationality',
                child: CustomDropdown<String>(
                  hintText: controller.nationality.value,
                   
                  items: const [
                    "Pakistan",
                    "America",
                    "India",
                    "Afghanistan",
                    "Bangladesh"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.nationality.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Residential Type',
                child: CustomDropdown<String>(
                  hintText: controller.residentialType.value,
                   
                  items: const [
                    "Citizen",
                    "Permanent Resident",
                    "Work Permit",
                    "Student Visa",
                    "Temporary Visa"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.residentialType.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'Postal Code',
                subtitle: controller.profileDetails.value.postalCode ?? "",
                tec: controller.postalCodeTEC,
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Relocate',
                child: CustomDropdown<String>(
                  hintText: controller.relocate.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    if (value != null) {
                      controller.relocate.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                  title: 'Landline Number',
                  subtitle: controller.profileDetails.value.landline ?? "",
                  tec: controller.landlineTEC),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Cell Phone Protection',
                child: CustomDropdown<String>(
                  hintText: controller.cellPhoneProtectionStatus.value,
                   
                  items: const [
                    "Visible to Everyone",
                    "Visible to Registered Users",
                    "Only Me"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.cellPhoneProtectionStatus.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateContactInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getFinancialStatus(context) {
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Monthly Income',
                child: CustomDropdown<String>(
                  hintText: controller.monthlyIncome.value,
                   
                  items: const [
                    "Below 10k",
                    "10k-20k",
                    "20k-30k",
                    "30k-40k",
                    "40k-50k",
                    "50k-60k",
                    "60k-70k",
                    "70k-80k",
                    "80k-90k",
                    "90k-1lac",
                    "1lac+"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.monthlyIncome.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Family Status',
                child: CustomDropdown<String>(
                  hintText: controller.familyStatus.value,
                   
                  items: const [
                    "Poor",
                    "Middle Class",
                    "Upper Middle Class",
                    "Rich"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.familyStatus.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateFinancialStatus(context);
            },
          ),
        ],
      ),
    );
  }

  getPhysicalAppearance(context) {
    List<String> weightList = List.generate(101, (index) => "${index + 40}kg");
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "Physical Appearance",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Complexion',
                child: CustomDropdown<String>(
                  hintText: controller.complexion.value,
                   
                  items: const [
                    "Very Fair",
                    "Fair",
                    "Wheatish",
                    "Wheatish brown",
                    "Dark"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.complexion.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Eye Color',
                child: CustomDropdown<String>(
                  hintText: controller.eyeColor.value,
                   
                  items: const [
                    "Brown",
                    "Hazel Eyes",
                    "Blue Eyes",
                    "Silver Eyes",
                    "Amber Eyes"
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      controller.eyeColor.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Hair Color',
                child: CustomDropdown<String>(
                  hintText: controller.hairColor.value,
                   
                  items: const ["Red", "Brown", "Black", "White"],
                  onChanged: (value) {
                    if (value != null) {
                      controller.hairColor.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Weight',
                child: CustomDropdown<String>(
                  hintText: '${controller.weight.value}kg',
                   
                  items: weightList,
                  onChanged: (value) {
                    if (value != null) {
                      List<String> item = value.split("k");
                      controller.weight.value = item.first;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Built',
                child: CustomDropdown<String>(
                  hintText: controller.built.value,
                   
                  items: const ["Average", "Athletic", "Slim", "Heavy"],
                  onChanged: (value) {
                    if (value != null) {
                      controller.built.value = value;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updatePhysicalAppearance(context);
            },
          ),
        ],
      ),
    );
  }

  getFamilyInfo(context) {
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Living',
                child: CustomDropdown<String>(
                  hintText: controller.liveWith.value,
                   
                  items: const ["With Family", "Without Family"],
                  onChanged: (value) {
                    controller.liveWith.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Parent\'s Country',
                child: CustomDropdown<AllCountries>(
                  hintText: controller.parentCountryName.value,
                   
                  items: controller.countryList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.parentCountryName.value = value.name!;
                      controller.getAllStates(context, value.id);
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Parent\'s State',
                child: CustomDropdown<AllStates>(
                  hintText: controller.parentStateName.value,
                   
                  items: controller.stateList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.parentStateName.value = value.name!;
                      controller.getAllCities(context, value.id);
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Parent\'s City',
                child: CustomDropdown<AllCities>(
                  hintText: controller.parentCityName.value,
                   
                  items: controller.cityList,
                  onChanged: (value) {
                    if (value != null) {
                      controller.parentCityId.value = value.id!;
                      controller.parentCityName.value = value.name!;
                      controller.update();
                    }
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Father Alive',
                child: CustomDropdown<String>(
                  hintText: controller.fatherAlive.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.fatherAlive.value = value!;
                    if (value == "No") {
                      controller.fatherOccupation.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Father\'s Occupation',
                child: CustomDropdown<String>(
                  hintText: controller.fatherOccupation.value,
                   
                  items: controller.occupationList,
                  onChanged: (value) {
                    controller.fatherOccupation.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Mother Alive',
                child: CustomDropdown<String>(
                  hintText: controller.motherAlive.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.motherAlive.value = value!;
                    if (value == "No") {
                      controller.motherOccupation.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Mother\'s Occupation',
                child: CustomDropdown<String>(
                  hintText: controller.motherOccupation.value,
                  items: controller.occupationList,
                  onChanged: (value) {
                    controller.motherOccupation.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Mother Tongue',
                child: CustomDropdown<String>(
                  hintText: controller.motherTongue.value,
                  items: languagesList,
                  onChanged: (value) {
                    controller.motherTongue.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Siblings',
                child: CustomDropdown<String>(
                  hintText: controller.siblings.value,
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.siblings.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'Number of Brother',
                subtitle: controller.profileDetails.value.noOfBrother ?? "",
                tec: controller.noOfBrotherTEC,
              ),
              const SizedBox(width: 05),
              getEditListTile(
                title: 'Number of Sisters',
                subtitle: controller.profileDetails.value.noOfSister ?? "",
                tec: controller.noOfSisterTEC,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getEditListTile(
                title: 'Married Brothers',
                subtitle: controller.profileDetails.value.marriedBrother ?? "",
                tec: controller.marriedBrotherTEC,
              ),
              const SizedBox(width: 05),
              getEditListTile(
                title: 'Married Sisters',
                subtitle: controller.profileDetails.value.marriedSister ?? "",
                tec: controller.marriedSisterTEC,
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateFamilyInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getHabitInfo(context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.profileContainerColor,
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const AppText(
            text: "Habit Details",
            color: AppColors.blackColor,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Namaz',
                child: CustomDropdown<String>(
                  hintText: controller.namaz.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.namaz.value = value!;
                    if (value == "No") {
                      controller.namazTimes.value = "0";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.namaz.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Namaz Time',
                      child: CustomDropdown<String>(
                        hintText: controller.namazTimes.value.toString(),
                         
                        items: const ["0", "1", "2", "3", "4", "5"],
                        onChanged: (value) {
                          controller.namazTimes.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Fasting',
                child: CustomDropdown<String>(
                  hintText: controller.fasting.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.fasting.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Zakat',
                child: CustomDropdown<String>(
                  hintText: controller.zakat.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.zakat.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Drink',
                child: CustomDropdown<String>(
                  hintText: controller.isDrink.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.isDrink.value = value!;
                    if (value == "No") {
                      controller.drink.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.isDrink.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Drink Routine',
                      child: CustomDropdown<String>(
                        hintText: controller.drink.value,
                         
                        items: const ["Occasional", "Regular"],
                        onChanged: (value) {
                          controller.drink.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Smoke',
                child: CustomDropdown<String>(
                  hintText: controller.isSmoke.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.isSmoke.value = value!;
                    if (value == "No") {
                      controller.smoke.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.isSmoke.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Smoke Routine',
                      child: CustomDropdown<String>(
                        hintText: controller.smoke.value,
                         
                        items: const ["Occasional", "Regular"],
                        onChanged: (value) {
                          controller.smoke.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Interests',
                child: CustomDropdown<String>(
                  hintText: controller.interest.value,
                   
                  items: const [
                    'Adventure',
                    "Sports",
                    "Book",
                    "Clubs",
                    'Computer',
                  ],
                  onChanged: (value) {
                    controller.interest.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              getDropDownListTile(
                title: 'Hobbies',
                child: CustomDropdown<String>(
                  hintText: controller.hobbies.value,
                   
                  items: const [
                    "Acting",
                    "Astronomy",
                    "Astrology",
                    "Collectibles",
                    "Cooking"
                  ],
                  onChanged: (value) {
                    controller.hobbies.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Diet',
                child: CustomDropdown<String>(
                  hintText: controller.diet.value,
                   
                  items: const [
                    "Vegetarian",
                    "Non Vegetarian",
                    "Halal Food Always",
                    "Halal Food When I Can",
                    "No Restrictions",
                  ],
                  onChanged: (value) {
                    controller.diet.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateHabitInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getHealthInfo(context) {
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
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Blood Group',
                child: CustomDropdown<String>(
                  hintText: controller.bloodGroup.value,
                   
                  items: const [
                    "O +ve",
                    "O -ve",
                    "B +ve",
                    "B -ve",
                    "A +ve",
                  ],
                  onChanged: (value) {
                    controller.bloodGroup.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Handicapped',
                child: CustomDropdown<String>(
                  hintText: controller.handicapped.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.handicapped.value = value!;
                    if (value == "No") {
                      controller.disability.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.handicapped.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Disability',
                      child: CustomDropdown<String>(
                        hintText: controller.disability.value,
                         
                        items: const [
                          "Mobility and Physical Impairments",
                          "Spinal Cord Disability",
                          "Head Injuries (TBI) - Brain Disability",
                          "Vision Disability",
                          "Hearing Disability",
                        ],
                        onChanged: (value) {
                          controller.disability.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Eye Problem',
                child: CustomDropdown<String>(
                  hintText: controller.eyeProblem.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.eyeProblem.value = value!;
                    if (value == "No") {
                      controller.eyeProblemDefect.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.eyeProblem.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Eye Defect',
                      child: CustomDropdown<String>(
                        hintText: controller.eyeProblemDefect.value,
                         
                        items: const ["Short Sightedness", "Long Sightedness"],
                        onChanged: (value) {
                          controller.eyeProblemDefect.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Health Problem',
                child: CustomDropdown<String>(
                  hintText: controller.healthProblem.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.healthProblem.value = value!;
                    if (value == "No") {
                      controller.healthDefect.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.healthProblem.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Health Defect',
                      child: CustomDropdown<String>(
                        hintText: controller.healthDefect.value,
                         
                        items: const [
                          "Asthma",
                          "Heart disease",
                          "Obesity",
                          "Diabetes",
                          "Headaches",
                          "Depression",
                        ],
                        onChanged: (value) {
                          controller.healthDefect.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Taking Medicines',
                child: CustomDropdown<String>(
                  hintText: controller.takingMedicines.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.takingMedicines.value = value!;
                    if (value == "No") {
                      controller.whichMedicines.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.takingMedicines.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Which Medicines',
                      child: CustomDropdown<String>(
                        hintText: controller.whichMedicines.value,
                         
                        items: const [
                          "Aspirin",
                          "Ibuprofen",
                          "Tramadol",
                          "Tizanidine",
                          "Thiocolchicoside",
                          "Paracetamol",
                          "Paracetamol +Codeine",
                          "Paracetamol +Orphenadrine",
                          "Paracetamol +caffeine",
                          "Ketorolac",
                          "None",
                        ],
                        onChanged: (value) {
                          controller.whichMedicines.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Do Exercise',
                child: CustomDropdown<String>(
                  hintText: controller.doExercise.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.doExercise.value = value!;
                    if (value == "No") {
                      controller.exercises.value = "";
                    }
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 05),
              controller.doExercise.value == "Yes"
                  ? getDropDownListTile(
                      title: 'Which Exercise',
                      child: CustomDropdown<String>(
                        hintText: controller.exercises.value,
                         
                        items: const ["Weight lifting", "Cardio"],
                        onChanged: (value) {
                          controller.exercises.value = value!;
                          controller.update();
                        },
                        decoration: basicInfoDecoration(
                          hintStyle: GoogleFonts.poppins(
                            color: AppColors.blackColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              getDropDownListTile(
                title: 'Visit Gym',
                child: CustomDropdown<String>(
                  hintText: controller.visitGym.value,
                   
                  items: const ["Yes", "No"],
                  onChanged: (value) {
                    controller.visitGym.value = value!;
                    controller.update();
                  },
                  decoration: basicInfoDecoration(
                    hintStyle: GoogleFonts.poppins(
                      color: AppColors.blackColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          CustomButton(
            text: "Update",
            fontColor: AppColors.whiteColor,
            isGradient: true,
            onTap: () {
              controller.updateHealthInfo(context);
            },
          ),
        ],
      ),
    );
  }

  getOriginInfo(context) {
    return Form(
      key: controller.originFormKey,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: AppColors.profileContainerColor,
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const AppText(
              text: "Origin",
              color: AppColors.blackColor,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
            const SizedBox(height: 08),
            getDropDownListTile(
              isExpanded: false,
              title: 'Ethnic Origin',
              child: CustomDropdown<String>(
                hintText: controller.ethnicOrigin.value,
                 
                items: const [
                  "Punjabi",
                  "Sindhi",
                  "Pashtoon",
                  "Baloch",
                  "Kashmiri"
                ],
                onChanged: (value) {
                  controller.ethnicOrigin.value = value!;
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 08),
            getEditListTile(
              isExpanded: false,
              title: 'Pakistani CNIC',
              subtitle: controller.profileDetails.value.pakiCnic ?? "",
              tec: controller.pakiCnicTEC,
              keyboardType: TextInputType.name,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                LengthLimitingTextInputFormatter(15),
              ],
              validator: (String? value) {
                RegExp cnicRegExp = RegExp(r'^\d{5}-\d{7}-\d$');
                if (!cnicRegExp.hasMatch(value!)) {
                  return 'Invalid CNIC format: 12345-6789012-3';
                } else {
                  return null;
                }
              },
            ),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'Pakistani Driving License',
              child: CustomDropdown<String>(
                hintText: controller.pakiDrivingLicense.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.pakiDrivingLicense.value = value!;
                  if (value == "No") {
                    controller.pakiDrivingLicenseNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            controller.pakiDrivingLicense.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'Pakistani Driving License Number',
                    subtitle:
                        controller.profileDetails.value.pakiDrivingLicenseNo ??
                            "",
                    tec: controller.pakiDrivingLicenseNoTEC,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                    ],
                    validator: (String? value) {
                      RegExp rex = RegExp(r'^\d{4}-\d{4}-\d{4}-\d{3}$');
                      if (!rex.hasMatch(value!)) {
                        return 'Invalid format.: 1234-5678-9012-345';
                      } else {
                        return null;
                      }
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'Pakistani Passport',
              child: CustomDropdown<String>(
                hintText: controller.pakiPassport.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.pakiPassport.value = value!;
                  if (value == "No") {
                    controller.pakiPassportNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 08),
            controller.pakiPassport.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'Pakistani Passport Number',
                    subtitle:
                        controller.profileDetails.value.pakiPassportNo ?? "",
                    tec: controller.pakiPassportNoTEC,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[A-Z0-9]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (String? value) {
                      RegExp rex = RegExp(r'^[A-Z]{2}\d{7}$');
                      if (!rex.hasMatch(value!)) {
                        return 'Invalid format: AB1234567';
                      } else {
                        return null;
                      }
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'Pakistani Tax',
              child: CustomDropdown<String>(
                hintText: controller.pakiTax.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.pakiTax.value = value!;
                  if (value == "No") {
                    controller.pakiTaxNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 08),
            controller.pakiTax.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'Pakistani Tax Number',
                    subtitle: controller.profileDetails.value.pakiTaxNo ?? "",
                    tec: controller.pakiTaxNoTEC,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
                      LengthLimitingTextInputFormatter(9),
                    ],
                    validator: (String? value) {
                      RegExp rex = RegExp(r'^\d{7}-\d$');
                      if (!rex.hasMatch(value!)) {
                        return 'Invalid format: 1234567-8';
                      } else {
                        return null;
                      }
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'Dual Nationality',
              child: CustomDropdown<String>(
                hintText: controller.dualNationality.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.dualNationality.value = value!;
                  if (value == "No") {
                    controller.socialSecurityNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 08),
            controller.dualNationality.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'Social Security Number',
                    subtitle:
                        controller.profileDetails.value.socialSecurityNo ?? "",
                    tec: controller.socialSecurityNoTEC,
                    keyboardType: TextInputType.name,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                    validator: (String? value) {
                      RegExp rex = RegExp(r'^\d{3}-\d{2}-\d{4}$');
                      if (!rex.hasMatch(value!)) {
                        return 'Invalid format: 123-45-6789';
                      } else {
                        return null;
                      }
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'International Driving License',
              child: CustomDropdown<String>(
                hintText: controller.internationalDrivingLicense.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.internationalDrivingLicense.value = value!;
                  if (value == "No") {
                    controller.internationalDrivingLicenseNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 08),
            controller.internationalDrivingLicense.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'International Driving License Number',
                    subtitle: controller.profileDetails.value
                            .internationalDrivingLicenseNo ??
                        "",
                    keyboardType: TextInputType.name,
                    tec: controller.internationalDrivingLicenseNoTEC,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                      LengthLimitingTextInputFormatter(16),
                    ],
                    validator: (String? value) {
                      RegExp rex = RegExp(r'^\d{3}-\d{4}-\d{4}-\d{2}$');
                      if (!rex.hasMatch(value!)) {
                        return 'Invalid format: 123-4567-8910-12';
                      } else {
                        return null;
                      }
                    },
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            getDropDownListTile(
              isExpanded: false,
              title: 'International Passport',
              child: CustomDropdown<String>(
                hintText: controller.internationalPassport.value,
                 
                items: const ["Yes", "No"],
                onChanged: (value) {
                  controller.internationalPassport.value = value!;
                  if (value == "No") {
                    controller.internationalPassportNoTEC.text = "";
                  }
                  controller.update();
                },
                decoration: basicInfoDecoration(
                  hintStyle: GoogleFonts.poppins(
                    color: AppColors.blackColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 08),
            controller.internationalPassport.value == "Yes"
                ? getEditListTile(
                    isExpanded: false,
                    title: 'International Passport Number',
                    subtitle: controller
                            .profileDetails.value.internationalPassportNo ??
                        "",
                    tec: controller.internationalPassportNoTEC,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'\d|-')),
                      LengthLimitingTextInputFormatter(11),
                    ],
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 10),
            CustomButton(
              text: "Update",
              fontColor: AppColors.whiteColor,
              isGradient: true,
              onTap: () {
                if (controller.originFormKey.currentState!.validate()) {
                  controller.updateOriginInfo(context);
                  // After image upload succeeds

                }
              },
            ),
          ],
        ),
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
        ],
      ),
    );
  }

  Widget getDateOfBirth({context}) {
    return Expanded(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: const AppText(
          text: 'Date of birth',
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.blackColor,
        ),
        subtitle: CustomFormField(
            tec: controller.dobTEC,
            readOnly: true,
            prefixIcon: Icon(
              Icons.calendar_month_sharp,
              color: AppColors.fontLightColor.withValues(alpha: 0.6),
            ),
            onFieldOnTap: () {
              DatePickerBdaya.showDatePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(1900, 3, 5),
                maxTime: DateTime(2006, 6, 7),
                onConfirm: (date) {
                  controller.selectedDateTime.value = date;
                  controller.dobTEC.text =
                      DateFormat('dd/MM/yyyy').format(date);
                  controller.update();
                },
                currentTime: DateTime.now(),
                locale: LocaleType.en,
              );
            }),
      ),
    );
  }
}

Widget getEditListTile({
  isExpanded = true,
  title,
  subtitle,
  TextEditingController? tec,
  int? lines,
  List<TextInputFormatter>? inputFormatters,
  TextInputType? keyboardType,
  String? Function(String?)? validator,
}) {
  return isExpanded
      ? Expanded(
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            title: AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
            subtitle: CustomFormField(
              tec: tec ?? TextEditingController(text: "$subtitle"),
              lines: lines,
              inputFormatters: inputFormatters,
              keyboardType: keyboardType,
              validator: validator,
            ),
          ),
        )
      : ListTile(
          contentPadding: EdgeInsets.zero,
          title: AppText(
            text: title,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.blackColor,
          ),
          subtitle: CustomFormField(
            tec: tec ?? TextEditingController(text: "$subtitle"),
            lines: lines,
            inputFormatters: inputFormatters,
            keyboardType: keyboardType,
            validator: validator,
          ),
        );
}

Widget getDropDownListTile({
  bool isExpanded = true,
  required String title,
  required Widget child,
}) {
  return isExpanded
      ? Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText(
                text: title,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.blackColor,
              ),
              const SizedBox(height: 05),
              child
            ],
          ),
        )
      : Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              text: title,
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppColors.blackColor,
            ),
            const SizedBox(height: 05),
            child
          ],
        );
}
