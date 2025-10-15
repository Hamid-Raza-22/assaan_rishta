import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/export.dart';
import '../../../core/models/res_model/connects_history.dart';
import '../../../utils/exports.dart';
import '../../../widgets/custom_button.dart';
import '../export.dart';
import 'connects_history_controller.dart';

class ConnectsHistoryView extends StatelessWidget {
  const ConnectsHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller =
    Get.put(ConnectsHistoryController());

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        title: Text(
          'Connects History',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<ConnectsHistory>>(
        future: controller.connectsHistory(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _shimmerEffect(context);
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }
          final connects = snapshot.data!;

          if (connects.isEmpty) {
            return Center(
              child: Text(
                'No connects history found.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: connects.length,
            itemBuilder: (context, index) {
              final connect = connects[index];
              return Card(
                color: AppColors.profileContainerColor,
                elevation: 2,
                margin:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _getItem(
                        title: 'Connection ID',
                        value: '${connect.id}',
                      ),
                      const SizedBox(height: 4),
                      _getItem(
                        title: 'Username',
                        value: connect.username ?? 'N/A',
                      ),
                      const SizedBox(height: 4),
                      _getItem(
                        title: 'Connected With',
                        value: connect.userForName ?? 'N/A',
                      ),
                      const SizedBox(height: 4),
                      _getItem(
                        title: 'Total Connects',
                        value: '${connect.connects}',
                      ),
                      const SizedBox(height: 4),
                      _getItem(
                        title: 'Remaining Connects',
                        value: '${connect.remainingConnects}',
                      ),
                      const SizedBox(height: 4),
                      _getItem(
                        title: 'Date',
                        value: connect.date!
                            .toLocal()
                            .toString()
                            .split(' ')[0],
                      ),
                      if (connect.connectionDescription != null &&
                          connect.connectionDescription!.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        _getItem(
                          title: 'Description',
                          value: connect.connectionDescription!,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Obx(
                            () => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CustomButton(
                              isLoading: controller.clickIndex.value == index
                                  ? controller.isLoading.value
                                  : false,
                              text: "Generate Report",
                              width: 150,
                              height: 40,
                              fontColor: AppColors.whiteColor,
                              isGradient: true,
                              suffixIcon: const Icon(
                                Icons.picture_as_pdf,
                                color: AppColors.whiteColor,
                                size: 14,
                              ),
                              suffixWidth: 08,
                              fontSize: 12,
                              onTap: () {
                                controller.clickIndex.value = index;
                                controller.generateConnectsPDF(
                                    context, connect);
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  _getItem({required String title, required String value}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            '$title: ',
            style: GoogleFonts.poppins(
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            textAlign: TextAlign.start,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  _shimmerEffect(context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 08),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 08),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
          const SizedBox(height: 08),
          BannerPlaceholder(
            width: Get.width,
            height: 200,
            borderRadius: 10,
          ),
        ],
      ),
    );
  }
}