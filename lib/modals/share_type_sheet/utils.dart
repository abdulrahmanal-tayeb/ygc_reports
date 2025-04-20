import 'package:flutter/material.dart';
import 'package:ygc_reports/core/constants/report_type.dart';

IconData getShareTypeIcon(ReportType type) {
  switch (type) {
    case ReportType.pdf:
      return Icons.picture_as_pdf;
    case ReportType.image:
      return Icons.image;
  }
}

String getShareTypeLabel(ReportType type) {
  switch (type) {
    case ReportType.pdf:
      return 'Share as PDF';
    case ReportType.image:
      return 'Share as Image';
  }
}