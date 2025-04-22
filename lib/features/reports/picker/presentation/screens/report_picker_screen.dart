// report_picker_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/models/report_model.dart';

class ReportPickerScreen extends StatelessWidget {
  const ReportPickerScreen({Key? key}) : super(key: key);

  Future<List<ReportModel>> _loadReports() async {
    return await reportRepository.getAllReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Select a Report'),
        actions: [
          IconButton(
            onPressed: () async => await reportRepository.deleteReports(), icon: Icon(Icons.delete))
        ],
      ),
      body: FutureBuilder<List<ReportModel>>(
        future: _loadReports(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // still loading
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            // something went wrong
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            // no reports
            return const Center(child: Text('No reports available.'));
          }

          final reports = snapshot.data!;
          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (context, index) {
              final report = reports[index];
              // assume report.date is a DateTime; adjust if you store it differently
              final formattedDate = formatDate(report.date);

              return ListTile(
                title: Text(report.stationName),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Date: $formattedDate'),
                    Text('Remaining Load: ${report.remainingLoad}'),
                  ],
                ),
                onTap: () async {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    context.pop<ReportModel>(report); // delay until frame completes
                  });
                },
              );
            },
          );
        },
      ),
    );
  }
}
