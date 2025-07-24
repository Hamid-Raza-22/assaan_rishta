import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import '../../../core/export.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class TransactionHistoryController extends GetxController {
  final systemUseCase = Get.find<SystemConfigUseCase>();

  List<TransactionHistory> transactionList = [];
  RxBool isLoading = false.obs;
  RxInt clickIndex = (-1).obs;

  String userName = Get.arguments;

  Future<List<TransactionHistory>> transactionHistory() async {
    final response = await systemUseCase.transactionHistory();
    return response.fold(
      (error) {
        debugPrint(error.description);
        return [];
      },
      (success) {
        return success;
      },
    );
  }

  ///make pdf
  Future<void> generateTransactionPDF(
      BuildContext context, TransactionHistory tx) async {
    isLoading.value = true;

    final pdf = pw.Document();

    // ✅ Load logo from assets
    final Uint8List logoBytes = await rootBundle
        .load('assets/app_logo.png')
        .then((value) => value.buffer.asUint8List());
    final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

    final dateStr =
        '${tx.createdDate?.day}, ${tx.createdDate?.month}, ${tx.createdDate?.year}';

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            mainAxisAlignment: pw.MainAxisAlignment.start,
            children: [
              pw.SizedBox(height: 10),
              pw.Image(
                logoImage,
                height: 150,
                width: 200,
              ),
              pw.Center(
                child: pw.Text(
                  'Thank you ${userName.toUpperCase()} for your purchase',
                  style: pw.TextStyle(
                    fontSize: 16,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 10),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(5),
                },
                border: pw.TableBorder.all(),
                children: [
                  _buildRow(
                    'Transaction ID',
                    tx.transactionId!,
                  ),
                  _buildRow(
                    'Invoice Number',
                    'INV-${tx.tid}',
                  ),
                  _buildRow(
                    'Transaction Amount',
                    'Rs ${tx.amount!.toStringAsFixed(0)}',
                  ),
                  _buildRow(
                    'Discounted Amount',
                    'Rs ${tx.discountedAmount!.toStringAsFixed(0)}',
                  ),
                  _buildRow(
                    'Actual Amount',
                    'Rs ${tx.actualAmount!.toStringAsFixed(0)}',
                  ),
                  _buildRow(
                    'Package Name',
                    '${tx.connectsPackagesId}',
                  ),
                  _buildRow(
                    'Number of Profiles',
                    '${tx.numberOfConnects}',
                  ),
                  _buildRow(
                    'Transaction Date',
                    dateStr,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    try {
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/invoice_${tx.tid}.pdf');
      await file.writeAsBytes(await pdf.save());
      if (context.mounted) TopSnackbar.show(context, file.path);
      await OpenFile.open(file.path);
      isLoading.value = false;
    } catch (e) {
      print('Error saving or opening PDF: $e');
    }
  }

  pw.TableRow _buildRow(String label, String value) {
    return pw.TableRow(children: [
      pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child:
            pw.Text(label, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
      ),
      pw.Padding(
        padding: const pw.EdgeInsets.all(8.0),
        child: pw.Text(value),
      ),
    ]);
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
}
