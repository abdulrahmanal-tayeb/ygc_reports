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
        model.tankLoad = int.tryParse(value) ?? 0;
        break;
      case 'fullTankWeight':
        model.fullTankWeight = double.tryParse(value) ?? 0;
        break;
      case 'inboundAmount':
        model.inboundAmount = int.tryParse(value) ?? 0;
        break;
      case 'totalLoad':
        model.totalLoad = int.tryParse(value) ?? 0;
        break;
      case 'remainingLoad':
        model.remainingLoad = int.tryParse(value) ?? 0;
        break;
      case 'overflow':
        model.overflow = int.tryParse(value) ?? 0;
        break;
      case 'underflow':
        model.underflow = int.tryParse(value) ?? 0;
        break;
      case 'filledForPeople':
        model.filledForPeople = int.tryParse(value) ?? 0;
        break;
      case 'stationName':
        model.stationName = value;
        break;
      case 'notes':
        model.notes = value;
        break;
      case 'isEmptying':
        model.isEmptying = value;
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

  /// Loads the “previous” report (either passed in, or fetched from the repo)
  /// and prepares a fresh list of pump‑readings where each new `start` is the
  /// old `end`, and both `end` and `total` are 0.
  Future<List<Map<String, int>>> loadFromReport({
    Map<String, dynamic>? reportMap,
    ReportModel? reportModel,
    bool prepareForNextReport = false,
  }) async {

    final ReportModel report = reportModel ?? await reportRepository.latestReport();
    // Case 1: If a model is already provided, use it directly
    // If it is a draft, then return it as is.
    if(report.isDraft || !prepareForNextReport){
      model = report;
      model.isDraft = false;
      notifyListeners();
      return model.pumpsReadings ?? [];
    }

    model = report;
    model.date = DateTime.now();
    model.tankLoad = model.remainingLoad;
    model.pumpsReadings = getNewReadings(model.pumpsReadings);
    model.resetDependent();
    notifyListeners();
    return model.pumpsReadings ?? [];
  }


  List<Map<String, int>> getNewReadings(dynamic readings){
    final List<Map<String, int>> oldReadings = () {
      if (readings is List) {
        try {
          return readings.cast<Map<String, int>>();
        } catch (_) {
          return readings
              .map<Map<String, int>>((e) => Map<String, int>.from(e as Map))
              .toList();
        }
      }
      if (readings is String) {
        return _decodePumpReadings(readings) ?? <Map<String, int>>[];
      }
      return <Map<String, int>>[];
    }();

    // Build the “prefilled” pumpRows
    final newReadings = oldReadings
        .map((r) => {
              'start': r['end'] ?? 0,
              'end': 0,
              'total': 0,
            })
        .toList();

    return newReadings;
  }

  List<Map<String, int>>? _decodePumpReadings(String? jsonStr) {
    if (jsonStr == null) return null;
    final decoded = jsonDecode(jsonStr);
    return List<Map<String, int>>.from(decoded.map((e) => Map<String, int>.from(e)));
  }
}