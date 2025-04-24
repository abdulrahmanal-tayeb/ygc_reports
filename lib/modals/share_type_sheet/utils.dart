import 'package:flutter/material.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';

IconData getShareTypeIcon(ReportType type) {
  switch (type) {
    case ReportType.pdf:
      return Icons.picture_as_pdf;
    case ReportType.image:
      return Icons.image;
  }
}

String getShareTypeLabel(BuildContext context, ReportType type) {
  switch (type) {
    case ReportType.pdf:
      return context.loc.common_shareAsPDF;
    case ReportType.image:
      return context.loc.common_shareAsImage;
  }
}