import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/features/creation/presentation/utils/report_printer.dart';
import 'package:ygc_reports/modals/saved_report_preview/saved_report_preview.dart';
import 'package:ygc_reports/models/report_model.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_render/pdf_render.dart' as pdfRender;

Future<void> generateReport({
  required BuildContext context,
  required ReportModel model,
  required ReportType shareType
}) async {
  if (await Permission.storage.request().isGranted) {

    final pdf = pw.Document();

    // Load the background image
    final imageData = await rootBundle.load('assets/docs/template.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());

    // Load Arabic font from assets
    final fontData = await rootBundle.load('assets/fonts/cairo/Cairo-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    final ReportPrinter reportPrinter = ReportPrinter(font: arabicFont, data: model);

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

    final Uint8List pdfBytes = await pdf.save();
    final Future<void> Function(BuildContext, Uint8List, String, {required ReportModel model}) handlingFunction = (shareType == ReportType.pdf)?  saveAndSharePdf : saveAndShareImage;
    reportRepository.insertReport(model);
    await handlingFunction(context, pdfBytes, "محطة ${model.stationName} - ${formatDate(model.date).replaceAll(r'/', '-')}", model: model);

  } else {
    debugPrint("Permission denied for storage.");
  }
}


Future<void> saveAndSharePdf(BuildContext context, Uint8List pdfBytes, String filename, {required ReportModel model}) async {
  // Get the internal storage directory (application documents directory)

  // Get the internal storage directory
  Directory? directory = await getExternalStorageDirectory();
  if (directory != null) {
    final reportsDir = Directory("${directory.path}/YGC Reports/reports/pdf");

    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }

    final filePath = "${reportsDir.path}/$filename.pdf";
    final file = File(filePath);

    await file.writeAsBytes(pdfBytes);

    await showReportPreview(
      context, 
      path: filePath,
      onShare: () async {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'تقرير محطة ${model.stationName} ليوم ${getDayName(model.date)} الموافق ${formatDate(model.date)} من الساعة ${formatTimeOfDay(model.beginTime)} الى الساعة ${formatTimeOfDay(model.endTime)}. مندوب الشركة اليمنية للغاز: ${model.representativeName}.',
        );
      }
    );
  }
}

Future<void> saveAndShareImage(BuildContext context, Uint8List pdfBytes, String filename, {required ReportModel model}) async {
  Directory? directory = await getExternalStorageDirectory();
  if (directory != null) {
    final reportsDir = Directory("${directory.path}/YGC Reports/reports/images");
    if (!await reportsDir.exists()) {
      await reportsDir.create(recursive: true);
    }
    final Uint8List? imageBytes = await convertPdfToImage(pdfBytes);

    if(imageBytes == null){
      saveAndSharePdf(context, pdfBytes, filename, model: model);
      return;
    }

    final filePath = "${reportsDir.path}/$filename.png";
    final file = File(filePath);
    await file.writeAsBytes(imageBytes);

    await showReportPreview(
      context, 
      data: imageBytes,
      onShare: () async {
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'تقرير محطة ${model.stationName} ليوم ${getDayName(model.date)} الموافق ${formatDate(model.date).replaceAll(r'/', "-")} من الساعة ${formatTimeOfDay(model.beginTime)} الى الساعة ${formatTimeOfDay(model.endTime)}. مندوب الشركة اليمنية للغاز: ${model.representativeName}.',
        );
      }
    );
     
  }
}

Future<Uint8List?> convertPdfToImage(Uint8List pdfBytes) async {
  // 1) Load the PDF into memory.
  final doc = await pdfRender.PdfDocument.openData(pdfBytes); 

  // 2) Grab page #1.
  final page = await doc.getPage(1); 

  // 3) Render to a PdfPageImage (defaults to PNG-like output internally).
  final pageImage = await page.render(
    width:  page.width.toInt(),
    height: page.height.toInt(),
    backgroundFill:       true,
    allowAntialiasingIOS: true,
  );

  // 4) Convert PdfPageImage → ui.Image
  final uiImage = await pageImage.createImageDetached(); 

  // 5) Encode ui.Image to PNG bytes
  final byteData = await uiImage.toByteData(format: ImageByteFormat.png);

  // 6) Clean up the raw page image buffer
  pageImage.dispose(); 

  return byteData?.buffer.asUint8List();
}