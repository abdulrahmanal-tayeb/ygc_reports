import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/features/reports/picker/presentation/widgets/report_record_tile.dart';
import 'package:ygc_reports/modals/delete_confirmation/delete_confirmation.dart';
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

          final allReports = snapshot.data!;
          final drafts = allReports.where((r) => r.isDraft).toList();
          final others = allReports.where((r) => !r.isDraft).toList();

          return NestedScrollView(
            headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
              return [
                if (drafts.isNotEmpty)
                  SliverAppBar(
                    backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                    expandedHeight: 50,
                    pinned: false,
                    floating: false,
                    title: Text(context.loc.pickReportScreenTitle),
                    flexibleSpace: const SizedBox.shrink(), // no content
                  ),
              ];
            },
            body: ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: 1 + drafts.length + (drafts.isNotEmpty && others.isNotEmpty ? 1 : 0) + others.length,
              itemBuilder: (context, index) {
                // Drafts divider
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          context.loc.draftReports,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  );
                }

                // Draft items
                final draftStart = 1;
                final draftEnd = draftStart + drafts.length;
                if (index >= draftStart && index < draftEnd) {
                  final draft = drafts[index - draftStart];
                  final formattedDate = formatDate(draft.date);
                  return ReportListTile(
                    report: draft,
                    formattedDate: formattedDate,
                    onDelete: () => deleteReport(draft),
                    onTap: () => context.pop<ReportModel>(draft),
                  );
                }

                // Submitted Reports divider
                final dividerIndex = draftEnd;
                if (drafts.isNotEmpty && others.isNotEmpty && index == dividerIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        Text(
                          context.loc.submittedReports,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        SizedBox(width: 8),
                        Expanded(child: Divider(thickness: 1)),
                      ],
                    ),
                  );
                }

                // Others section
                final reportIndex = index - draftEnd - (drafts.isNotEmpty && others.isNotEmpty ? 1 : 0);
                final report = others[reportIndex];
                final formattedDate = formatDate(report.date);
                return ReportListTile(
                  report: report,
                  formattedDate: formattedDate,
                  onDelete: () => deleteReport(report),
                  onTap: () => context.pop<ReportModel>(report),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
