import 'package:flutter/material.dart';
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

  void setField(String field, dynamic value) {
    switch (field) {
      case 'currentLoad':
        model.currentLoad = value;
        break;
      case 'inboundLoad':
        model.inboundLoad = value;
        break;
      case 'totalLoad':
        model.totalLoad = value;
        break;
      case 'startLiters':
        model.startLiters = value;
        break;
      case 'endLiters':
        model.endLiters = value;
        break;
      case 'totalConsumed':
        model.totalConsumed = value;
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
    }
    notifyListeners();
  }
}