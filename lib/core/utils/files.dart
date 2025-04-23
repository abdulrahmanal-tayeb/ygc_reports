import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:ygc_reports/core/constants/report_type.dart';

Future<void> deleteReportFromPath(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    } else {
      throw Exception("File not found");
    }
  } catch (e) {
    print("Error deleting file: $e");
    throw Exception("Failed to delete report file");
  }
}


Future<T?> getFilePath<T>(ReportType reportType) async {
  final baseDir = await getExternalDirectory(
    reportType == ReportType.pdf ? "documents" : "images",
  );
  if (baseDir == null) return null;

  final reportsDir = Directory(
    "${baseDir.path}/YGC Reports/${reportType == ReportType.pdf ? "pdf" : "images"}",
  );
  if (!await reportsDir.exists()) {
    await reportsDir.create(recursive: true);
  }

  if (T == Directory) {
    // caller asked explicitly for a Directory
    return reportsDir as T;
  }
  // default (any T ≠ Directory) → return the path string
  return reportsDir.path as T;
}


Future<Directory?> getExternalDirectory(String type) async {
  if (Platform.isAndroid) {
    final base = await getExternalStorageDirectory(); // e.g., /storage/emulated/0/Android/data/<package>/files

    if (base == null) return null;

    switch (type.toLowerCase()) {
      case 'images':
        return Directory('${base.parent.parent.parent.parent.path}/Pictures');
      case 'downloads':
        return Directory('${base.parent.parent.parent.parent.path}/Download');
      case 'documents':
        return Directory('${base.parent.parent.parent.parent.path}/Documents');
      default:
        return base;
    }
  } else if (Platform.isIOS) {
    final dir = await getApplicationDocumentsDirectory();

    switch (type.toLowerCase()) {
      case 'images':
      case 'downloads':
      case 'documents':
        final subdir = Directory('${dir.path}/$type');
        if (!await subdir.exists()) await subdir.create(recursive: true);
        return subdir;
      default:
        return dir;
    }
  } else {
    // Desktop or unsupported platform
    return null;
  }
}