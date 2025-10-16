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
    final controller = Get.put(ConnectsHistoryController());

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

          List<ConnectsHistory> connects = snapshot.data ?? [];

          if (connects.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No connects history found.',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            );
          }

          // ✅ Sort by latest date first
          connects.sort((a, b) {
            if (a.date == null) return 1;
            if (b.date == null) return -1;
            return b.date!.compareTo(a.date!);
          });

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: connects.length,
            itemBuilder: (context, index) {
              final connect = connects[index];
              return _buildConnectCard(context, connect, index, controller);
            },
          );
        },
      ),
    );
  }

  Widget _buildConnectCard(
      BuildContext context,
      ConnectsHistory connect,
      int index,
      ConnectsHistoryController controller,
      ) {
    // Format date nicely
    String formattedDate = _formatDate(connect.date);

    return Card(
      color: AppColors.profileContainerColor,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ Main message
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Container(
                //   padding: const EdgeInsets.all(8),
                //   decoration: BoxDecoration(
                //     color: AppColors.primaryColor.withOpacity(0.1),
                //     shape: BoxShape.circle,
                //   ),
                //   child: const Icon(
                //     Icons.person,
                //     color: AppColors.primaryColor,
                //     size: 20,
                //   ),
                // ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                          children: [
                            const TextSpan(text: 'You made a connection with '),
                            TextSpan(
                              text: connect.userForName ?? 'Unknown User',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryColor,
                              ),
                            ),
                            TextSpan(
                              text: ' on ',
                            ),
                            TextSpan(
                              text: formattedDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Additional info in smaller text
                      Text(
                        'Connection ID: ${connect.id}',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Show description if available
            // if (connect.connectionDescription != null &&
            //     connect.connectionDescription!.isNotEmpty) ...[
            //   const SizedBox(height: 12),
            //   Container(
            //     padding: const EdgeInsets.all(10),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade100,
            //       borderRadius: BorderRadius.circular(8),
            //     ),
            //     child: Row(
            //       children: [
            //         Icon(
            //           Icons.info_outline,
            //           size: 16,
            //           color: Colors.grey.shade700,
            //         ),
            //         const SizedBox(width: 8),
            //         Expanded(
            //           child: Text(
            //             connect.connectionDescription!,
            //             style: GoogleFonts.poppins(
            //               fontSize: 12,
            //               color: Colors.grey.shade700,
            //             ),
            //           ),
            //         ),
            //       ],
            //     ),
            //   ),
            // ],

            // const SizedBox(height: 12),
            //
            // // Connects info
            // Row(
            //   children: [
            //     _buildInfoChip(
            //       icon: Icons.group,
            //       label: 'Total',
            //       value: '${connect.connects}',
            //     ),
            //     const SizedBox(width: 8),
            //     _buildInfoChip(
            //       icon: Icons.trending_down,
            //       label: 'Remaining',
            //       value: '${connect.remainingConnects}',
            //       color: Colors.orange,
            //     ),
            //   ],
            // ),
            //
            // const SizedBox(height: 12),
            //
            // // Generate Report Button
            // Obx(
            //       () => CustomButton(
            //     isLoading: controller.clickIndex.value == index
            //         ? controller.isLoading.value
            //         : false,
            //     text: "Generate Report",
            //     width: double.infinity,
            //     height: 40,
            //     fontColor: AppColors.whiteColor,
            //     isGradient: true,
            //     suffixIcon: const Icon(
            //       Icons.picture_as_pdf,
            //       color: AppColors.whiteColor,
            //       size: 16,
            //     ),
            //     suffixWidth: 08,
            //     fontSize: 13,
            //     onTap: () {
            //       controller.clickIndex.value = index;
            //       controller.generateConnectsPDF(context, connect);
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  // Widget _buildInfoChip({
  //   required IconData icon,
  //   required String label,
  //   required String value,
  //   Color? color,
  // }) {
  //   return Expanded(
  //     child: Container(
  //       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
  //       decoration: BoxDecoration(
  //         color: (color ?? AppColors.primaryColor).withOpacity(0.1),
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Row(
  //         mainAxisSize: MainAxisSize.min,
  //         children: [
  //           Icon(
  //             icon,
  //             size: 16,
  //             color: color ?? AppColors.primaryColor,
  //           ),
  //           const SizedBox(width: 6),
  //           Column(
  //             crossAxisAlignment: CrossAxisAlignment.start,
  //             children: [
  //               Text(
  //                 label,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 9,
  //                   color: Colors.grey.shade600,
  //                 ),
  //               ),
  //               Text(
  //                 value,
  //                 style: GoogleFonts.poppins(
  //                   fontSize: 13,
  //                   fontWeight: FontWeight.w600,
  //                   color: color ?? AppColors.primaryColor,
  //                 ),
  //               ),
  //             ],
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown date';

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${date.day} ${months[date.month - 1]}, ${date.year}';
    }
  }

  Widget _shimmerEffect(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      enabled: true,
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: List.generate(
          4,
              (index) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            child: BannerPlaceholder(
              width: Get.width,
              height: 150,
              borderRadius: 12,
            ),
          ),
        ),
      ),
    );
  }
}