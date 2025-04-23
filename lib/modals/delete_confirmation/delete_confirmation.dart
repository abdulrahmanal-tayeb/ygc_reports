import 'package:flutter/material.dart';

Future<bool> showDeleteConfirmation(BuildContext context, [String title = "Delete Report", String content = "Are you sure you want to delete this report?"]) async {
  return await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ) ??
      false; // Return false if dismissed
}
