import 'package:flutter/material.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';

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
}