import 'package:flutter/material.dart';
import 'package:ygc_reports/core/utils/formatters.dart';
import 'package:ygc_reports/models/report_model.dart';

class ReportListTile extends StatelessWidget {
  final ReportModel report;
  final VoidCallback onDelete;
  final VoidCallback onTap;
  final String formattedDate;

  const ReportListTile({
    super.key,
    required this.report,
    required this.onDelete,
    required this.onTap,
    required this.formattedDate,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon or initial
            CircleAvatar(
              radius: 22,
              backgroundColor: Colors.blue.withOpacity(0.1),
              child: const Icon(Icons.ev_station, color: Colors.blue),
            ),
            const SizedBox(width: 14),

            // Info section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    report.stationName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[700],
                    ),
                  ),
                  Text(
                    getDayName(report.date),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 10),

            // Delete button
            IconButton(
              icon: const Icon(Icons.delete, size: 22),
              tooltip: 'Delete',
              onPressed: onDelete,
              color: Colors.red[400],
            ),
          ],
        ),
      ),
    );
  }
}