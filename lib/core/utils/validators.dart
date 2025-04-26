import 'package:flutter/material.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/models/report_model.dart';


/// Makes it easy to validate fields.
class Validators {
  static String? required(BuildContext context, String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return context.loc.error_required;
    }
    return null;
  }

  static String? positiveNumber(BuildContext context, String? value, String fieldName) {
    final num? number = num.tryParse(value ?? '');
    if (number == null || number < 0) {
      return context.loc.error_positiveNumber;
    }
    return null;
  }

  static bool validate(ReportModel model, List<Map<String, int>> pumpRows) {
    if(model.pumpsReadings == null || model.pumpsReadings!.isEmpty){
      model.pumpsReadings = pumpRows;
    }

    debugPrint("${model.pumpsReadings }");
    if (
      model.stationName.trim().length <= 1
      ||
      model.workerName.trim().length <= 1
      ||
      model.representativeName.trim().length <= 1
      
    ) {
      return false;
    }
    
    return true;
  }

  static String? validateNumber(BuildContext context, String? value, {bool isRequired = false}) {
    if (isRequired && (value == null || value.isEmpty)) {
      return context.loc.error_required;
    }

    if(value == null) return null;

    final isNumeric = RegExp(r'^\d+$').hasMatch(value);
    if (!isNumeric) {
      return context.loc.error_onlyNumbers;
    }

    return null; // ✅ valid
  }
}