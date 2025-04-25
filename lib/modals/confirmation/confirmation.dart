import 'package:flutter/material.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';

Future<bool> showConfirmation(BuildContext context, String title, String content, {
  String? confirmText,
  Color confirmColor = Colors.red,
}) async {
  return await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(context.loc.common_cancel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(confirmText ?? context.loc.common_delete, style: TextStyle(color: confirmColor)),
        ),
      ],
    ),
  ) ??
  false;
}
