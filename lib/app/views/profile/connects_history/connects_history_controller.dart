import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';

import '../../../core/export.dart';
import '../../../core/models/res_model/connects_history.dart';
import '../../../domain/export.dart';
import '../../../utils/exports.dart';

class ConnectsHistoryController extends GetxController {
  final systemUseCase = Get.find<SystemConfigUseCase>();

  List<ConnectsHistory> connectsList = [];
  RxBool isLoading = false.obs;
  RxInt clickIndex = (-1).obs;

  String userName = Get.arguments ?? 'User';

  Future<List<ConnectsHistory>> connectsHistory() async {
    final response = await systemUseCase.connectsHistory();
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

  /// Generate PDF for Connects History
  Future<void> generateConnectsPDF(
      BuildContext context, ConnectsHistory connect) async {
    isLoading.value = true;

    final pdf = pw.Document();

    // Load logo from assets
    final Uint8List logoBytes = await rootBundle
        .load('assets/app_logo.png')
        .then((value) => value.buffer.asUint8List());
    final pw.ImageProvider logoImage = pw.MemoryImage(logoBytes);

    final dateStr =
        '${connect.date?.day}, ${connect.date?.month}, ${connect.date?.year}';

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
                  'Connects History Report',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'User: ${userName.toUpperCase()}',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.normal,
                  ),
                ),
              ),
              pw.SizedBox(height: 15),
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(3),
                  1: const pw.FlexColumnWidth(5),
                },
                border: pw.TableBorder.all(),
                children: [
                  _buildRow(
                    'Connection ID',
                    '${connect.id}',
                  ),
                  _buildRow(
                    'User ID',
                    '${connect.userId}',
                  ),
                  _buildRow(
                    'Connected With',
                    connect.userForName ?? 'N/A',
                  ),
                  _buildRow(
                    'Connected User ID',
                    '${connect.userforId}',
                  ),
                  _buildRow(
                    'Total Connects',
                    '${connect.connects}',
                  ),
                  _buildRow(
                    'Remaining Connects',
                    '${connect.remainingConnects}',
                  ),
                  _buildRow(
                    'Connection Date',
                    dateStr,
                  ),
                  if (connect.connectionDescription != null &&
                      connect.connectionDescription!.isNotEmpty)
                    _buildRow(
                      'Description',
                      connect.connectionDescription!,
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
      final file = File('${dir.path}/connects_history_${connect.id}.pdf');
      await file.writeAsBytes(await pdf.save());
      if (context.mounted) TopSnackbar.show(context, file.path);
      await OpenFile.open(file.path);
      isLoading.value = false;
    } catch (e) {
      print('Error saving or opening PDF: $e');
      isLoading.value = false;
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
    super.dispose();
  }
}