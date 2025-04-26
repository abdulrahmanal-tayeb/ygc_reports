import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ygc_reports/core/constants/types.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/models/report_model.dart';
import "package:ygc_reports/core/utils/formatters.dart";

/// This is responsible for printing the texts on the report's template.
class ReportPrinter {
  final pw.Font font;
  final ReportModel data;
  final double width = 595.3;
  final double height = 842;
  final double margin = 56.7;
  final double qrCodeSize = 70;
  final ReportType fileType;
  final bool generateQR;
  final bool addWatermark;

  ReportPrinter({
    required this.font,
    required this.data,
    required this.fileType,
    this.generateQR = true,
    this.addWatermark = true
  });

  List<pw.Widget> buildReport(BuildContext context){
    return [
      ..._upperDate(),
      ..._metaData(),
      ..._timingDetails(),
      ..._pumpLoad(),
      ..._pumpReads(),
      ..._remainingLoad(),
      ..._notes(),
      ..._statistics(),
      ..._employees(),
      ..._footer(context),
    ];
  }

  pw.Widget arabicText(String? text, {int maxLines = 1}){
    return pw.Text(
      text ?? "",
      maxLines: maxLines,
      style: pw.TextStyle(
        font: font,
        fontSize: 12
      )
    );
  }


  List<pw.Widget> _upperDate(){
    final double y = 57;

    return [
      // Day
      pw.Positioned(
        left: 120,
        top: y,
        child: pw.Container(
          width: 20,
          child: pw.Center(child: arabicText(data.date.day.toString()))
        )
      ),

      // Month
      pw.Positioned(
        left: 92,
        top: y,
        child: pw.Container(
          width: 20,
          child: pw.Center(child: arabicText(data.date.month.toString()))
        )
      ),

      // Year
      pw.Positioned(
        left: 58,
        top: y,
        child: pw.Container(
          width: 27,
          child: pw.Center(child: arabicText(data.date.year.toString()))
        )
      )
    ];
  }

  List<pw.Widget> _metaData(){
    final double y = 126;
    final pw.TextStyle style = pw.TextStyle(
      font: font
    );

    return [
      pw.Positioned(
        right: 82,
        top: y,
        child: pw.Container(
          width: 395,
          child: pw.Center(
            child: pw.RichText(
              text: pw.TextSpan(
                children: [
                  pw.TextSpan(
                    style: style,
                    text: "تقرير محطة "
                  ),
                  // User input
                  pw.TextSpan(
                    style: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    text: _convertIncompatibleLetters("${data.stationName} ")
                  ),
                  pw.TextSpan(
                    style: style,
                    text: "ليوم "
                  ),
                  pw.TextSpan(
                    style: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    text: "${getDayName(data.date)} "
                  ),
                  pw.TextSpan(
                    style: style,
                    text: "الموافق "
                  ),
                  pw.TextSpan(
                    style: pw.TextStyle(
                      font: font,
                      fontWeight: pw.FontWeight.bold,
                    ),
                    text: "${formatDate(data.date, reverseDirection: true)} م"
                  ),
                ]
              )
            )
        )
        )
      )
    ];
  }

  List<pw.Widget> _timingDetails(){
    final double y = 149;
    return [
      pw.Positioned(
        right: 140,
        top: y,
        child: pw.Container(
          width: 100,
          child: pw.Center(child: arabicText(formatTimeOfDay(data.beginTime)))
        )
      ),

      pw.Positioned(
        left: 109,
        top: y,
        child: pw.Container(
          width: 100,
          child: pw.Center(child: arabicText(formatTimeOfDay(data.endTime)))
        )
      )
    ];
  }

  List<pw.Widget> _pumpLoad(){
    final double y = 210;
    final double spacing = 23;

    return [
      pw.Positioned(
        left: 130,
        top: y,
        child: pw.Container(
          width: 127,
          child: pw.Center(child: arabicText(data.tankLoad.toString()))
        )
      ),
      pw.Positioned(
        left: 135,
        top: y + spacing,
        child: pw.Container(
          width: 125,
          child: pw.Center(child: arabicText(data.inboundAmount.toString()))
        )
      ),
      pw.Positioned(
        left: 137,
        top: y + (spacing * 2),
        child: pw.Container(
          width: 125,
          child: pw.Center(child: arabicText(data.totalLoad.toString()))
        )
      )
    ];
  }

  List<pw.Widget> _pumpReads() {
    final double y = 318;
    final double spacing = 13;
    return [
      ...data.pumpsReadings!.asMap().entries.map((entry) {
        final index = entry.key;
        final readings = entry.value;

        return pw.Stack(
          children: [
            pw.Positioned(
              right: 100,
              top: y + spacing * index,
              child: pw.Container(
                width: 123,
                height: 15,
                child: pw.Center(
                  child: arabicText((readings["start"] ?? 0).toString()), // or any function that returns pw.Text
                ),
              ),
            ),
            pw.Positioned(
              right: 222,
              top: y + spacing * index,
              child: pw.Container(
                width: 122,
                height: 15,
                child: pw.Center(
                  child: arabicText((readings["end"] ?? 0).toString()), // or any function that returns pw.Text
                ),
              ),
            ),
            pw.Positioned(
              right: 343,
              top: y + spacing * index,
              child: pw.Container(
                width: 92,
                height: 15,
                child: pw.Center(
                  child: arabicText((readings["total"] ?? ((readings["start"] ?? 0) + (readings["end"] ?? 0))).toString()), // or any function that returns pw.Text
                ),
              ),
            )
          ]
        );
      }),

      pw.Positioned(
        left: 55,
        top: 363,
        child: pw.Container(
          width: 92,
          height: 15,
          child: pw.Center(
            child: arabicText(data.totalConsumed.toString()), // or any function that returns pw.Text
          ),
        ),
      )
    ];
  }

  List<pw.Widget> _remainingLoad() {
    final double y = 450;
    final double spacing = 21;

    return [
      pw.Positioned(
        left: 140,
        top: y,
        child: pw.Container(
          width: 120,
          height: 15,
          child: pw.Center(
            child: arabicText((data.remainingLoad).toString()), // or any function that returns pw.Text
          ),
        ),
      ),

      if(data.overflow > 0)
        pw.Positioned(
          left: 140,
          top: y + spacing,
          child: pw.Container(
            width: 120,
            height: 15,
            child: pw.Center(
              child: arabicText(data.overflow.toString()), // or any function that returns pw.Text
            ),
          ),
        )
      else if(data.underflow > 0)
        pw.Positioned(
          left: 141,
          top: y + (spacing * 2),
          child: pw.Container(
            width: 120,
            height: 15,
            child: pw.Center(
              child: arabicText(data.underflow.toString()), // or any function that returns pw.Text
            ),
          ),
        )
    ];
  }

  List<pw.Widget> _notes(){
    final double y = 539;
    
    return [
      if(data.filledForPeople > 0) 
        ...[
          pw.Positioned(
            right: 237,
            top: y,
            child: pw.Container(
              width: 55,
              height: 15,
              child: pw.Center(
                child: arabicText(data.tanksForPeople.toString()), // or any function that returns pw.Text
              ),
            ),
          ),
          pw.Positioned(
            right: 343,
            top: y,
            child: pw.Container(
              width: 52,
              height: 15,
              child: pw.Center(
                child: arabicText(data.filledForPeople.toString()), // or any function that returns pw.Text
              ),
            ),
          ),

          pw.Positioned(
            right: 237,
            top: y + 22,
            child: pw.Container(
              width: 55,
              height: 15,
              child: pw.Center(
                child: arabicText(data.filledForBuses.toString()), // or any function that returns pw.Text
              ),
            ),
          ),
        ],

      if(data.notes.isNotEmpty)
        pw.Positioned(
          right: 40,
          top: y + 43,
          child: pw.Container(
            width: 500,
            height: 80,
            child: arabicText(
              _convertIncompatibleLetters(data.notes),
              maxLines: 4
            ),
          ),
        ),
    ];
  }

  List<pw.Widget> _statistics(){
    final double y = 658;

    return [
      if(data.fullTankWeight > 0)
        pw.Positioned(
          right: 165,
          top: y,
          child: pw.Container(
            width: 55,
            height: 15,
            child: pw.Center(
              child: arabicText("${data.fullTankWeight.toString()} كجم"), // or any function that returns pw.Text
            ),
          ),
        ),
        
        if((data.progress ?? 0) > 0 || (data.litersDifference ?? 0).abs() > 0)
          pw.Positioned(
            right: 220,
            top: y + 18,
            child: pw.Container(
              width: 200,
              height: 15,
              child: arabicText(
                  "${data.litersDifference! < 0 ? "نقصان بنسبة " : "زيادة بنسبة "} ( ${data.progress}% ) ( ${data.litersDifference!.abs()} لتر )"
                ),
            ),
          )
    ];
  }

  List<pw.Widget> _employees(){
    final double y = 735;
    final double spacing = 22;
    final double companyEmployeeX = 16;
    final double stationEmployeeX = 75;

    return [
      // Station Employee
      pw.Positioned(
        right: stationEmployeeX,
        top: y,
        child: pw.Container(
          width: 300,
          height: 15,
          child: arabicText(_convertIncompatibleLetters(data.workerName)),
        ),
      ),

      if(data.workerSignature != null)
        pw.Positioned(
          right: stationEmployeeX + 10,
          top: y + spacing,
          child: pw.Container(
            width: 100,
            height: 50,
            child: pw.Image(
              pw.MemoryImage(data.workerSignature!),
              fit: pw.BoxFit.contain
            ),
          ),
        ),

      // Company's Employee
      pw.Positioned(
        left: companyEmployeeX,
        top: y,
        child: pw.Container(
          width: 130,
          height: 15,
          child: arabicText(_convertIncompatibleLetters(data.representativeName))
        ),
      ),

      if(data.representativeSignature != null)
        pw.Positioned(
          left: companyEmployeeX + 17,
          top: y + spacing,
          child: pw.Container(
            width: 100,
            height: 50,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: pw.Image(
                pw.MemoryImage(data.representativeSignature!),
                fit: pw.BoxFit.contain
              ),
            ),
          ),
        )
    ];
  }

  List<pw.Widget> _footer(BuildContext context){
    return []; // Temporarily
    return [
      // On images, it will be useless because it won't have enough quality to be scanned.
      if(fileType == ReportType.pdf && generateQR)
        pw.Positioned(
          bottom: 50,
          left: (width / 2)- (qrCodeSize / 2) + 2,
          child: pw.Container(
            width: 70,
            height: 70,
            child: pw.Align(
              alignment: pw.Alignment.centerRight,
              child: data.qrForPdf(size: 70),
            ),
          ),
        ),
      
      if(addWatermark)
        pw.Positioned(
          bottom: 7,
          child: pw.Container(
            width: width,
            height: 50,
            child: pw.Center(
              child: pw.Text(context.loc.generatedByAmtCode, style: pw.TextStyle(fontSize: 10)),
            ),
          ),
        )
    ];
  }
  

  String _convertIncompatibleLetters(String? text){
    if(text == null || text.isEmpty) return '';
    return text.replaceAll('\u06CC', '\u064A');
  }

}