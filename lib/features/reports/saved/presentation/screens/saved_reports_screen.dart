import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:share_plus/share_plus.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/utils/files.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/features/reports/saved/presentation/widgets/report_file_tile.dart';
import 'package:ygc_reports/modals/confirmation/confirmation.dart';
import 'package:ygc_reports/models/report_file.dart';

class SavedReportsScreen extends StatefulWidget {
  const SavedReportsScreen({super.key});

  @override
  State<SavedReportsScreen> createState() => _SavedReportsScreenState();
}

class _SavedReportsScreenState extends State<SavedReportsScreen> {
  late Future<List<ReportFile>> _reportFilesFuture;
  late List<ReportFile> _reportFiles; // Local variable to store the loaded files

  @override
  void initState() {
    super.initState();
    _reportFilesFuture = _loadReportFiles();
  }

  Future<List<ReportFile>> _loadReportFiles() async {
    final pdfDir = await getFilePath<Directory>(ReportType.pdf);
    final imageDir = await getFilePath<Directory>(ReportType.image);

    if(pdfDir == null || imageDir == null){
      return [];
    }
    
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

  // Function to delete a report and update the UI
  Future<void> _deleteReport(ReportFile file) async {
    try {
      await deleteReportFromPath(file.path);
      setState(() {
        // Remove the file from the list after deletion
        _reportFiles.remove(file);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.loc.message_reportDeleted)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error deleting report: $e")),
      );
    }
  }

  void openFile(ReportFile file){
    OpenFilex.open(file.path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.savedReportScreenTitle),
        automaticallyImplyLeading: false,
      ),
      body: FutureBuilder<List<ReportFile>>(
        future: _reportFilesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text(context.loc.message_noReports));
          } else {
            // Update local files list
            _reportFiles = snapshot.data!;

            return ListView.builder(
              itemCount: _reportFiles.length,
              itemBuilder: (context, index) {
                final file = _reportFiles[index];
                return ReportFileTile(
                  file: file, 
                  onOpen: () {openFile(file);}, 
                  onDelete: () async {
                    final confirm = await showConfirmation(
                      context,
                      context.loc.message_deleteReport,
                      context.loc.message_deleteReportText
                    );
                    if (confirm) {
                      // Delete the report and update the list
                      await _deleteReport(file);
                    }
                  }, 
                  onShare: (){
                    Share.shareXFiles(
                      [XFile(file.path)]
                    );
                  }
                );
              },
            );
          }
        },
      ),
    );
  }
}