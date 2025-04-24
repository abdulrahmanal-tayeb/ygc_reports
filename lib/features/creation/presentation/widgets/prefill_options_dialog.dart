import 'package:flutter/material.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';

class PrefillOptionsDialog extends StatelessWidget {
  const PrefillOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: Text(context.loc.choosePrefillMethod),
        content: Text(context.loc.choosePrefillMethodText),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.loc.common_prefillOnly),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(context.loc.common_prepareForNextReport),
          ),
        ],
      );
  }
}