import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:ygc_reports/core/constants/types.dart';
import 'package:ygc_reports/modals/share_type_sheet/utils.dart';

Future<void> showShareTypeBottomSheet({
  required BuildContext context,
  required void Function(ReportType) onSelected,
}) async {
  await showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: ReportType.values.map((type) {
          return ListTile(
            leading: Icon(getShareTypeIcon(type)),
            title: Text(getShareTypeLabel(context, type)),
            onTap: () {
              context.pop();
              onSelected(type);
            },
          );
        }).toList(),
      );
    },
  );
}