import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/core/services/database/report_repository.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
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

  IconButton deleteButton(int? reportId, [bool isDraft = false]) {
    return IconButton(
      onPressed: reportId != null
          ? () async {
              if(
                await showDeleteConfirmation(
                  context,
                  isDraft? "Delete Draft" : "Delete Report"
                )
              ){
                await reportRepository.deleteReport(reportId);
                _refreshReports();
              }
            }
          : null,
      icon: const Icon(Icons.delete),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<ReportModel>>(
        future: _reportsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error} ${snapshot.stackTrace}'));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text('No reports available.'));
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
                    title: Text("Pick a Report"),
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
                      children: const [
                        Text(
                          'Draft Reports',
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
                  return ListTile(
                    title: Text(draft.stationName),
                    subtitle: Text(formattedDate),
                    trailing: deleteButton(draft.id, true),
                    onTap: () => context.pop<ReportModel>(draft),
                  );
                }

                // Submitted Reports divider
                final dividerIndex = draftEnd;
                if (drafts.isNotEmpty && others.isNotEmpty && index == dividerIndex) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: const [
                        Text(
                          'Submitted Reports',
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
                return ListTile(
                  title: Text(report.stationName),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Date: $formattedDate'),
                      Text('Remaining Load: ${report.remainingLoad}'),
                    ],
                  ),
                  trailing: deleteButton(report.id),
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
