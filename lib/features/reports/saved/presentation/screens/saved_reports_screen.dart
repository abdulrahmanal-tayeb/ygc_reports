import 'dart:io';
import 'package:flutter/material.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/utils/files.dart';
import 'package:ygc_reports/modals/delete_confirmation/delete_confirmation.dart';
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
        const SnackBar(content: Text("Report deleted")),
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
        title: const Text('Saved Reports'),
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
            return const Center(child: Text('No saved reports found.'));
          } else {
            // Update local files list
            _reportFiles = snapshot.data!;

            return ListView.builder(
              itemCount: _reportFiles.length,
              itemBuilder: (context, index) {
                final file = _reportFiles[index];
                return ListTile(
                  leading: Icon(
                    file.type == ReportType.pdf
                        ? Icons.picture_as_pdf
                        : Icons.image,
                    color: file.type == ReportType.pdf
                        ? Colors.red
                        : Colors.blue,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min, // This ensures the Row doesn't expand
                    children: [
                      IconButton(
                        onPressed: () => openFile(file),
                        icon: const Icon(Icons.share),
                      ),
                      IconButton(
                        onPressed: () async {
                          final confirm = await showDeleteConfirmation(context);
                          if (confirm) {
                            // Delete the report and update the list
                            await _deleteReport(file);
                          }
                        },
                        icon: const Icon(Icons.delete),
                      ),
                    ],
                  ),
                  title: Text(file.name),
                  subtitle: Text(
                    'Modified: ${file.modified.toLocal().toString().split('.').first}',
                  ),
                  onTap: () {
                    openFile(file);
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