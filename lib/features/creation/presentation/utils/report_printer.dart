import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

class ReportPrinter {
  final pw.Font font;

  ReportPrinter({
    required this.font
  });

  List<pw.Widget> buildReport(){
    return [
      ..._upperDate(),
      ..._metaData(),
      ..._timingDetails(),
      ..._pumpLoad()
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
          child: pw.Center(child: arabicText("12"))
        )
      ),

      // Month
      pw.Positioned(
        left: 92,
        top: y,
        child: pw.Container(
          width: 20,
          child: pw.Center(child: arabicText("12"))
        )
      ),

      // Year
      pw.Positioned(
        left: 58,
        top: y,
        child: pw.Container(
          width: 27,
          child: pw.Center(child: arabicText("1222"))
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
                    text: "طوفان الاقصى النموذجية "
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
                    text: "الخميس "
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
                    text: "2025 / 12 / 12 "
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
          child: pw.Center(child: arabicText("8 مساء"))
        )
      ),

      pw.Positioned(
        left: 109,
        top: y,
        child: pw.Container(
          width: 100,
          child: pw.Center(child: arabicText("8 مساء"))
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
          child: pw.Center(child: arabicText("123"))
        )
      ),
      pw.Positioned(
        left: 135,
        top: y + spacing,
        child: pw.Container(
          width: 125,
          child: pw.Center(child: arabicText("111111111111111"))
        )
      ),
      pw.Positioned(
        left: 137,
        top: y + (spacing * 2),
        child: pw.Container(
          width: 125,
          child: pw.Center(child: arabicText("111111111111111"))
        )
      )
    ];
  }
}