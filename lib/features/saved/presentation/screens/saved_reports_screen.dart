import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/models/report_file.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  late Future<List<ReportFile>> _reportFilesFuture;

  @override
  void initState() {
    super.initState();
    _reportFilesFuture = _loadReportFiles();
  }

  Future<List<ReportFile>> _loadReportFiles() async {
    final Directory? baseDir = await getExternalStorageDirectory();
    if (baseDir == null) return [];

    final pdfDir = Directory('${baseDir.path}/YGC Reports/reports/pdf');
    final imageDir = Directory('${baseDir.path}/YGC Reports/reports/images');

    final List<ReportFile> files = [];

    if (await pdfDir.exists()) {
      final pdfFiles = pdfDir
          .listSync()
          .whereType<File>()
          .where((file) => file.path.toLowerCase().endsWith('.pdf'));
      for (var file in pdfFiles) {
        final stat = await file.stat();
        files.add(ReportFile(
          name: path.basename(file.path),
          path: file.path,
          type: ReportType.pdf,
          modified: stat.modified,
        ));
      }
    }

    if (await imageDir.exists()) {
      final imageFiles = imageDir
          .listSync()
          .whereType<File>()
          .where((file) =>
              file.path.toLowerCase().endsWith('.png') ||
              file.path.toLowerCase().endsWith('.jpg') ||
              file.path.toLowerCase().endsWith('.jpeg'));
      for (var file in imageFiles) {
        final stat = await file.stat();
        files.add(ReportFile(
          name: path.basename(file.path),
          path: file.path,
          type: ReportType.image,
          modified: stat.modified,
        ));
      }
    }

    files.sort((a, b) => b.modified.compareTo(a.modified));
    return files;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Reports'),
      ),
      body: FutureBuilder<List<ReportFile>>(
        future: _reportFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No saved reports found.'));
          } else {
            final files = snapshot.data!;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                return ListTile(
                  leading: Icon(
                    file.type == ReportType.pdf
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: file.type == ReportType.pdf
                        ? Colors.red
                        : Colors.blue,
                  ),
                  title: Text(file.name),
                  subtitle: Text(
                      'Modified: ${file.modified.toLocal().toString().split('.').first}'),
                  onTap: () {
                    // Implement file opening logic here
                  },
                );
              },
            );
          }
        },
      ),
    );
  }
}