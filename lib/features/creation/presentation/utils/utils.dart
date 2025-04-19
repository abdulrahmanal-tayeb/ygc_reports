import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:ygc_reports/features/creation/presentation/utils/report_printer.dart';

Future<Uint8List> generateReportPdf({
  required String stationName,
  required String startTime,
  required String endTime,
  required List<Map<String, double>> pumpRows,
  required double filledForPeople,
  required String notes,
}) async {
  final pdf = pw.Document();

  // Load the background image
  final imageData = await rootBundle.load('assets/docs/template.png');
  final image = pw.MemoryImage(imageData.buffer.asUint8List());

  // Load Arabic font from assets
  final fontData = await rootBundle.load('assets/fonts/cairo/Cairo-Regular.ttf');
  final arabicFont = pw.Font.ttf(fontData);

  final ReportPrinter reportPrinter = ReportPrinter(font: arabicFont);

  pdf.addPage(
    pw.Page(
      margin: pw.EdgeInsets.zero,
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) {
        return pw.Directionality(
          textDirection: pw.TextDirection.rtl, 
          child: pw.Stack(
            children: [
              // Image background
              pw.Positioned.fill(
                child: pw.Image(image, fit: pw.BoxFit.cover),
              ),
              ...reportPrinter.buildReport(),
              // Your custom overlay
            ],
          )
        );
      },
    ),
  );

  return pdf.save();
}
