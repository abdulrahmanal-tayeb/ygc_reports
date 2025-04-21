import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import '../models/report_model.dart';

class ReportProvider extends ChangeNotifier {
  ReportModel model = ReportModel();

  void setStationName(String value) {
    model.stationName = value;
    notifyListeners();
  }

  void setDate(DateTime value) {
    model.date = value;
    notifyListeners();
  }

  void setBeginTime(TimeOfDay value) {
    model.beginTime = value;
    notifyListeners();
  }

  void setEndTime(TimeOfDay value) {
    model.endTime = value;
    notifyListeners();
  }

  void setField(String field, dynamic value, {bool notify = true}) {
    switch (field) {
      case 'tankLoad':
        model.tankLoad = value;
        break;
      case 'inboundAmount':
        model.inboundAmount = value;
        break;
      case 'totalLoad':
        model.totalLoad = value;
        break;
      case 'remainingLoad':
        model.remainingLoad = value;
        break;
      case 'overflow':
        model.overflow = value;
        break;
      case 'underflow':
        model.underflow = value;
        break;
      case 'filledForPeople':
        model.filledForPeople = value;
        break;
      case 'notes':
        model.notes = value;
        break;
      case 'workerName':
        model.workerName = value;
        break;
      case 'representativeName':
        model.representativeName = value;
        break;
      case 'representativeSignature':
        model.representativeSignature = value;
        break;
      case 'workerSignature':
        model.workerSignature = value;
        break;
    }

    if(notify){
      notifyListeners();
    }
  }

  void notify(){
    debugPrint("HELLO +++++++++++++++++++++++++++++++++++++++++++++++++++");
    notifyListeners();
  }


  void clear({bool notify = true}){
    model = ReportModel();
    if(notify){
      notifyListeners();
    }
  }

  Future<List<Map<String, int>>?> loadFromLastReport() async {
    final Map<String, dynamic>? lastReport = await reportRepository.latestReport();
    if(lastReport == null) return [];
    List<Map<String, int>>? pumpReadings;
    List<Map<String, int>>? storedReadings = _decodePumpReadings(lastReport['pumpsReadings']);
    if(storedReadings != null){
      pumpReadings = storedReadings.map((reading){
        return {"start": reading["end"] ?? 0, "end": 0, "total": 0};
      }).toList();
    }

    model = ReportModel(
      stationName: lastReport['stationName'] as String,
      // Add all other fields from lastReport appropriately, e.g.
      tankLoad: lastReport['remainingLoad'] ?? 0,
      inboundAmount: 0,
      totalLoad: lastReport["remainingLoad"] ?? 0,
      remainingLoad: 0,
      overflow: 0,
      underflow: 0,
      filledForPeople: 0,
      tanksForPeople: 0,
      filledForBuses: 0,
      totalConsumed: 0,
      notes: '',
      workerName: lastReport['workerName'] ?? '',
      representativeName: lastReport['representativeName'] ?? '',
      date: DateTime.now(),
      beginTime: _parseTime(lastReport['beginTime']),
      endTime: _parseTime(lastReport['endTime']),
      pumpsReadings: pumpReadings,
      workerSignature: lastReport['workerSignature'],
      representativeSignature: lastReport['representativeSignature'],
    );
    notifyListeners();
    return pumpReadings;
  }

  TimeOfDay _parseTime(String? timeStr) {
    if (timeStr == null) return const TimeOfDay(hour: 8, minute: 0);
    final parts = timeStr.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  List<Map<String, int>>? _decodePumpReadings(String? jsonStr) {
    if (jsonStr == null) return null;
    final decoded = jsonDecode(jsonStr);
    return List<Map<String, int>>.from(decoded.map((e) => Map<String, int>.from(e)));
  }
}