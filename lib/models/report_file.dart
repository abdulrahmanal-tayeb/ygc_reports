import 'package:ygc_reports/core/constants/report_type.dart';

class ReportFile {
  final String name;
  final String path;
  final ReportType type;
  final DateTime modified;

  ReportFile({
    required this.name,
    required this.path,
    required this.type,
    required this.modified,
  });
}
