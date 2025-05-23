import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/features/reports/picker/presentation/widgets/report_record_tile.dart';
import 'package:ygc_reports/modals/confirmation/confirmation.dart';
import 'package:ygc_reports/models/report_model.dart';

class ReportPickerScreen extends StatefulWidget {
  const ReportPickerScreen({super.key});

  @override
  State<ReportPickerScreen> createState() => _ReportPickerScreenState();
}

class _ReportPickerScreenState extends State<ReportPickerScreen> {
  late Future<List<ReportModel>> _reportsFuture;

  @override
  void initState() {
    super.initState();
    _reportsFuture = reportRepository.getAllReports();
  }

  void _refreshReports() {
    setState(() {
      _reportsFuture = reportRepository.getAllReports();
    });
  }

  void deleteReport(ReportModel report) async {
    if(
      await showConfirmation(
        context,
        report.isDraft? context.loc.message_deleteDraft : context.loc.message_deleteReport,
        context.loc.message_deleteReportText
      )
    ){
      await reportRepository.deleteReport(report.id!);
      _refreshReports();
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.loc.pickReportScreenTitle),
      ),
      body: FutureBuilder<List<ReportModel>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error} ${snapshot.stackTrace}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return Center(child: Text(context.loc.message_noReports));
          }

          // Here I am separating the drafts from the actual, sumbitted reports.
          final allReports = snapshot.data!;
          final drafts = allReports.where((r) => r.isDraft).toList();
          final others = allReports.where((r) => !r.isDraft).toList();

          return ListView.builder(
            padding: EdgeInsets.zero,
            itemCount: 
                (drafts.isNotEmpty ? 1 + drafts.length : 0) +
                (others.isNotEmpty ? 1 + others.length : 0),
            itemBuilder: (context, index) {
              int currentIndex = 0;

              // Drafts divider
              if (drafts.isNotEmpty) {
                if (index == currentIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          context.loc.draftReports,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  );
                }
                currentIndex++;

                // Drafts items
                final draftIndex = index - currentIndex;
                if (draftIndex >= 0 && draftIndex < drafts.length) {
                  final draft = drafts[draftIndex];
                  final formattedDate = formatDate(draft.date);
                  return ReportListTile(
                    report: draft,
                    formattedDate: formattedDate,
                    onDelete: () => deleteReport(draft),
                    onTap: () => context.pop<ReportModel>(draft),
                  );
                }
                currentIndex += drafts.length;
              }

              // Submitted Reports divider
              if (others.isNotEmpty) {
                if (index == currentIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          context.loc.submittedReports,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  );
                }
                currentIndex++;

                // Others items
                final reportIndex = index - currentIndex;
                if (reportIndex >= 0 && reportIndex < others.length) {
                  final report = others[reportIndex];
                  final formattedDate = formatDate(report.date);
                  return ReportListTile(
                    report: report,
                    formattedDate: formattedDate,
                    onDelete: () => deleteReport(report),
                    onTap: () => context.pop<ReportModel>(report),
                  );
                }
              }

              return const SizedBox(); // fallback
            },
          );
        },
      ),
    );
  }
}
