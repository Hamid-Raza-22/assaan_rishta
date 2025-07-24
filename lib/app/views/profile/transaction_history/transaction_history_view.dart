import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/export.dart';
import '../../../utils/exports.dart';
import '../../../widgets/custom_button.dart';
import '../export.dart';

class TransactionHistoryView extends GetView<TransactionHistoryController> {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TransactionHistoryController>(initState: (_) {
      Get.put(TransactionHistoryController());
    }, builder: (_) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          title: Text(
            'Transaction History',
            style: GoogleFonts.poppins(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          centerTitle: true,
        ),
        body: FutureBuilder<List<TransactionHistory>>(
          future: controller.transactionHistory(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return shimmerEffect(context);
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
            final transactions = snapshot.data!;

            if (transactions.isEmpty) {
              return Center(
                  child: Text(
                'No transactions found.',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ));
            }

            return ListView.builder(
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
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
                        getItem(
                          title: 'Transaction ID',
                          value: '${tx.transactionId}',
                        ),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Package Name',
                          value: '${tx.connectsPackagesId}',
                        ),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Amount',
                          value:
                              '${tx.currencyCode} ${tx.amount?.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Actual Amount',
                          value:
                              '${tx.currencyCode} ${tx.actualAmount?.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Discounted Amount',
                          value:
                              '${tx.currencyCode} ${tx.discountedAmount?.toStringAsFixed(2)}',
                        ),
                        const SizedBox(height: 4),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Number of Profiles',
                          value: '${tx.numberOfConnects}',
                        ),
                        const SizedBox(height: 4),
                        getItem(
                          title: 'Date',
                          value: tx.createdDate!
                              .toLocal()
                              .toString()
                              .split(' ')[0],
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CustomButton(
                                isLoading: controller.clickIndex.value == index
                                    ? controller.isLoading.value
                                    : false,
                                text: "Generate Invoice",
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
                                  controller.generateTransactionPDF(
                                      context, tx);
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
    });
  }

  getItem({required String title, required String value}) {
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

  shimmerEffect(context) {
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
