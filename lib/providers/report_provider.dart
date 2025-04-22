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
  }) async {
    // Case 1: If a model is already provided, use it directly
    if (reportModel != null) {
      model = reportModel;
      notifyListeners();
      return model.pumpsReadings ?? [];
    }

    // Case 2: Otherwise, get the raw map from input or database
    final raw = reportMap ?? await reportRepository.latestReport();
    if (raw == null) return [];

    // Decode old pump readings into List<Map<String, int>>
    final pr = raw['pumpsReadings'];
    final List<Map<String, int>> oldReadings = () {
      if (pr is List) {
        try {
          return pr.cast<Map<String, int>>();
        } catch (_) {
          return pr
              .map<Map<String, int>>((e) => Map<String, int>.from(e as Map))
              .toList();
        }
      }
      if (pr is String) {
        return _decodePumpReadings(pr) ?? <Map<String, int>>[];
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

    // Normalize the date field
    final dateField = raw['date'];
    final DateTime dateValue = dateField is String
        ? DateTime.tryParse(dateField) ?? DateTime.now()
        : dateField is DateTime
            ? dateField
            : DateTime.now();

    // Normalize begin/end times
    TimeOfDay parseTime(dynamic t) {
      if (t is String) return parseTime(t);
      if (t is Map<String, dynamic>) {
        final h = t['hour'] as int? ?? 0;
        final m = t['minute'] as int? ?? 0;
        return TimeOfDay(hour: h, minute: m);
      }
      return const TimeOfDay(hour: 0, minute: 0);
    }

    final begin = parseTime(raw['beginTime']);
    final end = parseTime(raw['endTime']);

    // Rebuild the model from raw map
    model = ReportModel(
      stationName: raw['stationName'] as String? ?? '',
      remainingLoad: raw['remainingLoad'] as int? ?? 0,
      date: dateValue,
      beginTime: begin,
      endTime: end,
      pumpsReadings: newReadings,
      inboundAmount: raw['inboundAmount'] as int? ?? 0,
      totalLoad: raw['totalLoad'] as int? ?? 0,
      overflow: raw['overflow'] as int? ?? 0,
      underflow: raw['underflow'] as int? ?? 0,
      filledForPeople: raw['filledForPeople'] as int? ?? 0,
      tanksForPeople: raw['tanksForPeople'] as int? ?? 0,
      filledForBuses: raw['filledForBuses'] as int? ?? 0,
      totalConsumed: raw['totalConsumed'] as int? ?? 0,
      notes: raw['notes'] as String? ?? '',
      workerName: raw['workerName'] as String? ?? '',
      representativeName: raw['representativeName'] as String? ?? '',
      workerSignature: raw['workerSignature'],
      representativeSignature: raw['representativeSignature'],
    );

    notifyListeners();
    return newReadings;
  }


  List<Map<String, int>>? _decodePumpReadings(String? jsonStr) {
    if (jsonStr == null) return null;
    final decoded = jsonDecode(jsonStr);
    return List<Map<String, int>>.from(decoded.map((e) => Map<String, int>.from(e)));
  }
}