import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../utils/exports.dart';
import '../../../widgets/export.dart';
import 'export.dart';

class ContactUsView extends GetView<ContactUsController> {
  const ContactUsView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ContactUsController>(initState: (_) {
      Get.put(ContactUsController());
    }, builder: (_) {
      return Scaffold(
        backgroundColor: AppColors.whiteColor,
        appBar: const PreferredSize(
          preferredSize: Size(double.infinity, 40),
          child: CustomAppBar(
            title: "Contact Us",
            isBack: true,
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              children: [
                CustomFormField(
                  tec: controller.nameTEC,
                  hint: 'Your Name',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      if (text.isEmpty) return newValue;

                      // Find the first word and capitalize its first letter
                      final words = text.split(' '); // Split by spaces
                      if (words.isNotEmpty) {
                        words[0] = words[0].replaceFirstMapped(
                          RegExp(r'^\w'), // Match the first letter of the first word
                              (match) => match.group(0)!.toUpperCase(),
                        );
                      }
                      final capitalizedText = words.join(' ');

                      return newValue.copyWith(
                        text: capitalizedText,
                        selection: TextSelection.collapsed(offset: capitalizedText.length),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  tec: controller.emailTEC,
                  hint: 'Email',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                        .hasMatch(value)) {
                      return 'Please enter a valid email address';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  tec: controller.subjectTEC,
                  hint: 'Subject',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the subject';
                    }
                    return null;
                  },
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      if (text.isEmpty) return newValue;

                      // Find the first word and capitalize its first letter
                      final words = text.split(' '); // Split by spaces
                      if (words.isNotEmpty) {
                        words[0] = words[0].replaceFirstMapped(
                          RegExp(r'^\w'), // Match the first letter of the first word
                              (match) => match.group(0)!.toUpperCase(),
                        );
                      }
                      final capitalizedText = words.join(' ');

                      return newValue.copyWith(
                        text: capitalizedText,
                        selection: TextSelection.collapsed(offset: capitalizedText.length),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 10),
                CustomFormField(
                  tec: controller.messageTEC,
                  hint: 'Message',
                  lines: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your message';
                    }
                    return null;
                  },
                  inputFormatters: [
                    TextInputFormatter.withFunction((oldValue, newValue) {
                      final text = newValue.text;

                      if (text.isEmpty) return newValue;

                      // Find the first word and capitalize its first letter
                      final words = text.split(' '); // Split by spaces
                      if (words.isNotEmpty) {
                        words[0] = words[0].replaceFirstMapped(
                          RegExp(r'^\w'), // Match the first letter of the first word
                              (match) => match.group(0)!.toUpperCase(),
                        );
                      }
                      final capitalizedText = words.join(' ');

                      return newValue.copyWith(
                        text: capitalizedText,
                        selection: TextSelection.collapsed(offset: capitalizedText.length),
                      );
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                Obx(
                  () => CustomButton(
                    text: "Send",
                    isGradient: true,
                    isLoading: controller.isLoading.value,
                    fontColor: AppColors.whiteColor,
                    onTap: (){
                      controller.contactUs();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
