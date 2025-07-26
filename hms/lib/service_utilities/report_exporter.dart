import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:url_launcher/url_launcher.dart';

class ReportExporter {
  static Future<void> exportCsvAndUploadAndDownload({
    required List<String> headers,
    required List<List<dynamic>> rows,
    required String fileNamePrefix,
  }) async {
    if (rows.isEmpty) {
      Fluttertoast.showToast(msg: "No data to export");
      return;
    }

    try {
      final List<List<dynamic>> csvData = [headers, ...rows];
      final csvContent = const ListToCsvConverter().convert(csvData);

      final fileBytes = utf8.encode(csvContent);
      final Uint8List byteData = Uint8List.fromList(fileBytes);

      final fileName =
          'reports/${fileNamePrefix}_${DateTime.now().millisecondsSinceEpoch}.csv';

      final ref = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(contentType: 'text/csv');

      final snapshot = await ref.putData(byteData, metadata);
      final downloadUrl = await snapshot.ref.getDownloadURL();

      Fluttertoast.showToast(msg: "Download started...");

      final uri = Uri.parse(downloadUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception("Could not launch download URL");
      }
    } catch (e) {
      debugPrint("CSV Export error: $e");
      Fluttertoast.showToast(msg: "Export failed: $e");
    }
  }

  static Future<void> exportToPDF({
    required String title,
    required List<String> headers,
    required List<List<String>> dataRows,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(
            level: 0,
            child: pw.Text(title, style: pw.TextStyle(fontSize: 18)),
          ),
          pw.Table.fromTextArray(
            headers: headers,
            data: dataRows,
            cellAlignment: pw.Alignment.centerLeft,
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            border: pw.TableBorder.all(),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async {
        return pdf.save();
      },
    );
  }
}

//How To Use
// await ReportExporter.exportCsvAndUploadAndDownload(
//   headers: ['Name', 'Amount'],
//   rows: [
//     ['John', '100'],
//     ['Jane', '150'],
//   ],
//   fileNamePrefix: 'my_report',
// );
