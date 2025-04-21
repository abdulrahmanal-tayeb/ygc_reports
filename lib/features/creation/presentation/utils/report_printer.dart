import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:ygc_reports/models/report_model.dart';
import "package:ygc_reports/core/utils/formatters.dart";

class ReportPrinter {
  final pw.Font font;
  final ReportModel data;
  ReportPrinter({
    required this.font,
    required this.data
  });

  List<pw.Widget> buildReport(){
    return [
      ..._upperDate(),
      ..._metaData(),
      ..._timingDetails(),
      ..._pumpLoad(),
      ..._pumpReads(),
      ..._remainingLoad(),
      ..._notes(),
      ..._employees()
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
                    text: "${data.stationName} "
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
                    text: "${formatDate(data.date)} "
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
    debugPrint("+++++++++++++++++++++++++++++++++++++++++++ ${data.totalConsumed}");
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
    final double y = 565;
    
    // Checking this only because all other fields depends on it.
    if(data.filledForPeople == 0) return [];

    return [
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

      if(data.notes.isNotEmpty)
        pw.Positioned(
          right: 40,
          top: y + 43,
          child: pw.Container(
            width: 500,
            height: 80,
            child: arabicText(
              data.notes,
              maxLines: 4
            ),
          ),
        ),
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
          child: arabicText(data.workerName),
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
          child: arabicText(data.representativeName)
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
  


}