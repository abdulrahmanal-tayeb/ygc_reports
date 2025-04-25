import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:ygc_reports/core/constants/report_type.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';
import 'package:ygc_reports/models/report_file.dart';
import 'package:ygc_reports/providers/locale_provider.dart';

class ReportFileTile extends StatelessWidget {
  final ReportFile file;
  final VoidCallback onOpen;
  final VoidCallback onDelete;
  final VoidCallback onShare;

  const ReportFileTile({
    super.key,
    required this.file,
    required this.onOpen,
    required this.onDelete,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final String locale = (context.watch<LocaleProvider>().locale ?? Locale("ar")).toLanguageTag();
    final isPDF = file.type == ReportType.pdf;
    final color = isPDF ? Colors.red[600] : Colors.blue[600];
    final icon = isPDF ? Icons.picture_as_pdf : Icons.image;
    final date = DateFormat('yyyy / MM / dd', locale).format(file.modified);
    final time = DateFormat('hh:mm a', locale).format(file.modified);
    final bool isRtl = context.isRtl;

    return Dismissible(
      key: Key(file.path),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.endToStart) {
          onDelete();
        } else if (direction == DismissDirection.startToEnd) {
          onShare();
        }
        return false; // prevent auto-dismiss
      },
      background: Container(
        alignment: isRtl? Alignment.centerRight : Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.blue[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.share, color: Colors.white, size: 28),
      ),
      secondaryBackground: Container(
        alignment: isRtl? Alignment.centerLeft : Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.red[400],
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white, size: 28),
      ),
      child: InkWell(
        onTap: onOpen,
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
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: color!.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: color, size: 26),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      time,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                icon: const Icon(Icons.share, size: 20),
                tooltip: context.loc.common_share,
                onPressed: onShare,
                color: Colors.grey[800],
              ),
              IconButton(
                icon: const Icon(Icons.delete, size: 20),
                tooltip: context.loc.common_delete,
                onPressed: onDelete,
                color: Colors.grey[800],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
