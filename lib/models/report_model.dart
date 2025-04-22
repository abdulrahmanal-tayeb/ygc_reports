import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;

class ReportModel {
  String stationName;
  DateTime date;
  TimeOfDay beginTime;
  TimeOfDay endTime;

  int tankLoad;
  int inboundAmount;
  int totalLoad;

  List<Map<String, int>>? pumpsReadings;
  int totalConsumed;

  int remainingLoad;
  int overflow;
  int underflow;

  int filledForPeople;
  int tanksForPeople;
  int filledForBuses;

  String notes;

  String workerName;
  String representativeName;

  Uint8List? workerSignature;
  Uint8List? representativeSignature;
  bool isEmptying;

  ReportModel({
    this.stationName = '',
    DateTime? date,
    TimeOfDay? beginTime,
    TimeOfDay? endTime,
    this.tankLoad = 0,
    this.inboundAmount = 0,
    this.totalLoad = 0,
    this.remainingLoad = 0,
    this.overflow = 0,
    this.underflow = 0,
    this.filledForPeople = 0,
    this.notes = '',
    this.workerName = '',
    this.pumpsReadings,
    this.tanksForPeople = 0,
    this.filledForBuses = 0,
    this.totalConsumed = 0,
    this.representativeName = '',
    this.isEmptying = false,
    this.representativeSignature,
    this.workerSignature,
  })  : date = date ?? DateTime.now(),
        beginTime = beginTime ?? const TimeOfDay(hour: 20, minute: 0),
        endTime = endTime ?? const TimeOfDay(hour: 20, minute: 0);

  /// --- 1) toJson
  Map<String, dynamic> toJson() {
    return {
      'stationName': stationName,
      'date': date.toIso8601String(),
      'beginTime': {'hour': beginTime.hour, 'minute': beginTime.minute},
      'endTime': {'hour': endTime.hour, 'minute': endTime.minute},
      'pumpsReadings': pumpsReadings,
      'remainingLoad': remainingLoad,
      'isEmptying': isEmptying,
      'workerName': workerName,
    };
  }

  /// --- 2) fromJson
  factory ReportModel.fromJson(Map<String, dynamic> json) {
    Uint8List? _decode(String? b64) =>
        b64 != null ? base64Decode(b64) : null;
    TimeOfDay _time(Map<String, dynamic> t) =>
        TimeOfDay(hour: t['hour'], minute: t['minute']);

    return ReportModel(
      stationName: json['stationName'] as String? ?? '',
      date: DateTime.parse(json['date'] as String),
      beginTime: _time(json['beginTime'] as Map<String, dynamic>),
      endTime: _time(json['endTime'] as Map<String, dynamic>),
      tankLoad: json['tankLoad'] as int? ?? 0,
      inboundAmount: json['inboundAmount'] as int? ?? 0,
      totalLoad: json['totalLoad'] as int? ?? 0,
      pumpsReadings: (json['pumpsReadings'] as List<dynamic>?)
          ?.map((e) => Map<String, int>.from(e as Map))
          .toList(),
      isEmptying: (json['isEmptying'] as bool?) ?? false,
      totalConsumed: json['totalConsumed'] as int? ?? 0,
      remainingLoad: json['remainingLoad'] as int? ?? 0,
      overflow: json['overflow'] as int? ?? 0,
      underflow: json['underflow'] as int? ?? 0,
      filledForPeople: json['filledForPeople'] as int? ?? 0,
      tanksForPeople: json['tanksForPeople'] as int? ?? 0,
      filledForBuses: json['filledForBuses'] as int? ?? 0,
      notes: json['notes'] as String? ?? '',
      workerName: json['workerName'] as String? ?? '',
      representativeName: json['representativeName'] as String? ?? '',
      workerSignature: _decode(json['workerSignature'] as String?),
      representativeSignature:
          _decode(json['representativeSignature'] as String?),
    );
  }
}

/// --- 3) PDF‑friendly QR method
extension ReportModelPdfQr on ReportModel {
  /// Returns a `pw.BarcodeWidget` you can insert into your PDF.
  pw.Widget qrForPdf({double size = 200}) {
    final String payload = jsonEncode(toJson());
    return pw.BarcodeWidget(
      barcode: pw.Barcode.qrCode(),
      data: payload,
      width: size,
      height: size,
    );
  }
}
