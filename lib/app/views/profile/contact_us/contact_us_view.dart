
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
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Professional Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryColor.withOpacity(0.1),
                        AppColors.primaryColor.withOpacity(0.05),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.headset_mic_rounded,
                        size: 48,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 12),
                      const AppText(
                        text: 'We\'re Here to Help',
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(height: 8),
                      const AppText(
                        text: 'Get in touch with our dedicated support team',
                        fontSize: 14,
                        color: AppColors.greyColor,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                 // Contact Information Cards
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'Contact Information',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 20),

                       // Support Email Card
                       InkWell(
                         onTap: () => controller.contactUsForSupport(),
                         borderRadius: BorderRadius.circular(12),
                         child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.fillFieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.support_agent,
                                color: AppColors.primaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                             Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  AppText(
                                    text: 'For Support & Assistance',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackColor,
                                  ),
                                  SizedBox(height: 4),
                                  AppText(
                                    text: 'support@asaanrishta.com',
                                    fontSize: 13,
                                    color: AppColors.primaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                         ),
                       ),),

                      const SizedBox(height: 12),

                       // General Info Email Card
                       InkWell(
                         onTap: () => controller.contactUsForSupport(),
                         borderRadius: BorderRadius.circular(12),
                         child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.fillFieldColor,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.borderColor.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Icon(
                                Icons.info_outline,
                                color: AppColors.secondaryColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                             Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  AppText(
                                    text: 'For General Information',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.blackColor,
                                  ),
                                  SizedBox(height: 4),
                                  AppText(
                                    text: 'info@asaanrishta.com',
                                    fontSize: 13,
                                    color: AppColors.secondaryColor,
                                  ),
                                ],
                              ),
                            ),
                          ],
                         ),
                       ),),

                       const SizedBox(height: 12),

                       // WhatsApp Card
                       InkWell(
                         onTap: () => controller.openWhatsApp(phone: '+923064727345'),
                         borderRadius: BorderRadius.circular(12),
                         child: Container(
                           padding: const EdgeInsets.all(16),
                           decoration: BoxDecoration(
                             color: AppColors.fillFieldColor,
                             borderRadius: BorderRadius.circular(12),
                             border: Border.all(
                               color: AppColors.borderColor.withOpacity(0.5),
                             ),
                           ),
                           child: Row(
                             children: [
                               Container(
                                 padding: const EdgeInsets.all(10),
                                 decoration: BoxDecoration(
                                   color: Colors.green.withOpacity(0.1),
                                   borderRadius: BorderRadius.circular(10),
                                 ),
                                 child: const Icon(
                                   Icons.phone,
                                   color: Colors.green,
                                   size: 24,
                                 ),
                               ),
                               const SizedBox(width: 16),
                               const Expanded(
                                 child: Column(
                                   crossAxisAlignment: CrossAxisAlignment.start,
                                   children: [
                                     AppText(
                                       text: 'WhatsApp (Support)',
                                       fontSize: 14,
                                       fontWeight: FontWeight.w600,
                                       color: AppColors.blackColor,
                                     ),
                                     SizedBox(height: 4),
                                     AppText(
                                       text: '+92 306 4727345',
                                       fontSize: 13,
                                       color: Colors.green,
                                     ),
                                   ],
                                 ),
                               ),
                             ],
                           ),
                         ),
                        ),
                       ],
                  ),
                ),

                const SizedBox(height: 20),

                // Office Hours Section
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.access_time_filled,
                            color: AppColors.primaryColor,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          const AppText(
                            text: 'Business Hours',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.blackColor,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const AppText(
                        text: 'Monday - Friday: 9:00 AM - 6:00 PM (PST)',
                        fontSize: 13,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(height: 4),
                      const AppText(
                        text: 'Saturday: 10:00 AM - 4:00 PM (PST)',
                        fontSize: 13,
                        color: AppColors.greyColor,
                      ),
                      const SizedBox(height: 4),
                      const AppText(
                        text: 'Sunday: Closed',
                        fontSize: 13,
                        color: AppColors.greyColor,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Response Time Note
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.primaryColor.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 20,
                        color: AppColors.primaryColor,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            AppText(
                              text: 'Response Time',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.blackColor,
                            ),
                            SizedBox(height: 4),
                            AppText(
                              text: 'We typically respond within 24-48 business hours. For urgent matters, please mark your email as "URGENT" in the subject line.',
                              fontSize: 12,
                              color: AppColors.greyColor,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Additional Notes
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const AppText(
                        text: 'Important Notes:',
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.blackColor,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppText(text: '• ', fontSize: 12, color: AppColors.greyColor),
                          Expanded(
                            child: AppText(
                              text: 'For technical support, please include your account details and a detailed description of the issue.',
                              fontSize: 12,
                              color: AppColors.greyColor,

                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppText(text: '• ', fontSize: 12, color: AppColors.greyColor),
                          Expanded(
                            child: AppText(
                              text: 'For partnership inquiries, please use the info@asaanrishta.com email address.',
                              fontSize: 12,
                              color: AppColors.greyColor,

                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppText(text: '• ', fontSize: 12, color: AppColors.greyColor),
                          Expanded(
                            child: AppText(
                              text: 'All emails are handled with complete confidentiality and privacy.',
                              fontSize: 12,
                              color: AppColors.greyColor,
                                 ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          AppText(text: '• ', fontSize: 12, color: AppColors.greyColor),
                          Expanded(
                            child: AppText(
                              text: 'Our customer support team is committed to providing you with the best possible assistance.',
                              fontSize: 12,
                              color: AppColors.greyColor,

                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    });
  }
}