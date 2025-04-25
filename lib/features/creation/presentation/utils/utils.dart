import 'dart:io';
import 'dart:math';
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
import 'package:ygc_reports/core/utils/files.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/features/creation/presentation/utils/report_printer.dart';
import 'package:ygc_reports/modals/confirmation/confirmation.dart';
import 'package:ygc_reports/modals/saved_report_preview/saved_report_preview.dart';
import 'package:ygc_reports/models/report_model.dart';
import 'package:pdf_render/pdf_render.dart' as pdfRender;

Future<void> generateReport({
  required BuildContext context,
  required ReportModel model,
  required ReportType fileType
}) async {
  if (await Permission.storage.request().isGranted) {
    final bool reportExist = await reportRepository.reportExistsOnDate(model.date);
    if(reportExist){
      final result = await showConfirmation(
        context, 
        context.loc.reportExist, 
        context.loc.reportExistText,
        confirmText: context.loc.common_overwrite
      );
      if(!result) return; // The user don't want to overwrite the previous report.
    }

    final ReportModel? previousReport = await reportRepository.getReportByDate(model.date.subtract(const Duration(days: 1)) );

    debugPrint("BROOOOOOOOOOO IS THE FUCKING THING IS: ${previousReport}");
    // If its the report for the next day, calculate the increase the total consumed liters.
    if(previousReport != null && previousReport.stationName == model.stationName){
      model.litersDifference = model.totalConsumed - previousReport.totalConsumed;
      model.progress = calculatePercentageIncrease(previousReport.totalConsumed, model.totalConsumed);
    }
    
    final pdf = pw.Document();
    // Load the background image
    final imageData = await rootBundle.load('assets/docs/template.png');
    final image = pw.MemoryImage(imageData.buffer.asUint8List());

    // Load Arabic font from assets
    final fontData = await rootBundle.load('assets/fonts/cairo/Cairo-Regular.ttf');
    final arabicFont = pw.Font.ttf(fontData);
    if(model.isEmptying){
      emptyingReport(model);
    }

    final ReportPrinter reportPrinter = ReportPrinter(font: arabicFont, data: model, fileType: fileType);

    pdf.addPage(
      pw.Page(
        margin: pw.EdgeInsets.zero,
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context pwcontext) {
          return pw.Directionality(
            textDirection: pw.TextDirection.rtl, 
            child: pw.Stack(
              children: [
                // Image background
                pw.Positioned.fill(
                  child: pw.Image(image, fit: pw.BoxFit.cover),
                ),
                ...reportPrinter.buildReport(context),
                // Your custom overlay
              ],
            )
          );
        },
      ),
    );

    final Uint8List pdfBytes = await pdf.save();
    final Future<void> Function(BuildContext, Uint8List, String, {required ReportModel model}) handlingFunction = (fileType == ReportType.pdf)?  saveAndSharePdf : saveAndShareImage;
    await handlingFunction(context, pdfBytes, "محطة ${model.stationName} - ${formatDate(model.date).replaceAll(r'/', '-')}", model: model);

  } else {
    debugPrint("Permission denied for storage.");
  }
}

Future<void> saveAndSharePdf(BuildContext context, Uint8List pdfBytes, String filename, {required ReportModel model}) async {
  // Get the internal storage directory (application documents directory)

  // Get the internal storage directory
  String? path = await getFilePath(ReportType.pdf);
  if (path != null) {
    final filePath = "$path/$filename.pdf";
    final file = File(filePath);
    await file.writeAsBytes(pdfBytes); // Needed to open the PDF preview.
    bool shouldSave = true;

    final bool wasDismissed = await showReportPreview(
      context, 
      path: filePath,
      onShare: ({bool save = true}) async {
        if(save){
          reportRepository.insertReport(model);
        } else {
          shouldSave = false;
        }

        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'تقرير محطة ${model.stationName} ليوم ${getDayName(model.date)} الموافق ${formatDate(model.date)} من الساعة ${formatTimeOfDay(model.beginTime)} الى الساعة ${formatTimeOfDay(model.endTime)}. مندوب الشركة اليمنية للغاز: ${model.representativeName}.',
        );
      },
    );

    if(wasDismissed || !shouldSave){
      debugPrint("DELETEEEEEEEEEEEEEEEEEED");
      file.delete();
    }
  }
}

Future<void> saveAndShareImage(BuildContext context, Uint8List pdfBytes, String filename, {required ReportModel model}) async {
  String? path = await getFilePath(ReportType.image);
  if (path != null) {
    final Uint8List? imageBytes = await convertPdfToImage(pdfBytes);

    if(imageBytes == null){
      saveAndSharePdf(context, pdfBytes, filename, model: model);
      return;
    }

    final filePath = "$path/$filename.png";
    final file = File(filePath);

    await showReportPreview(
      context, 
      data: imageBytes,
      onShare: ({bool save = true}) async {
        if(save){
          reportRepository.insertReport(model);
          await file.writeAsBytes(imageBytes);
        }
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'تقرير محطة ${model.stationName} ليوم ${getDayName(model.date)} الموافق ${formatDate(model.date).replaceAll(r'/', "-")} من الساعة ${formatTimeOfDay(model.beginTime)} الى الساعة ${formatTimeOfDay(model.endTime)}. مندوب الشركة اليمنية للغاز: ${model.representativeName}.',
        );
      }
    );
     
  }
}

void emptyingReport(ReportModel model){
  if(model.remainingLoad == 0) return; // because it is already correct, and there is no overflow nor underflow.

  if(model.remainingLoad < 0) { // Meaning that the tank has load, but the report shows that it hasn't = overflow
    model.overflow = model.remainingLoad.abs();
    model.notes = "تمت تصفية الخزان، ووفقًا للتقارير فإن الكمية المتبقية فيه تبلغ ${max(0, model.remainingLoad)} لتر، في حين أن الكمية الفعلية في الخزان تختلف عن ذلك ولا يزال يحتوي على كمية من الغاز.";
  } else { // Meaning that the tank is empty, but the report shows it has load = underflow, 
    model.underflow = model.remainingLoad.abs();
    model.notes = "تمت تصفية الخزان، ووفقًا للتقارير، فإن الكمية المتبقية في الخزان تبلغ ${max(0, model.remainingLoad)} لتر، في حين أن الخزان قد نفد بالكامل فعليًا.";

  }
  model.remainingLoad = 0; // Reset the `actual` remaining load.
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