import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'dart:typed_data';

import 'package:ygc_reports/core/utils/local_helpers.dart';

Future<Uint8List?> showSignaturePad(BuildContext context) async {
  final SignatureController _controller = SignatureController(
    penStrokeWidth: 3,
    penColor: Colors.black,
    exportBackgroundColor: Colors.white,
  );

  Uint8List? signatureResult;

  // Use showModalBottomSheet and await its closure.
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (BuildContext ctx) {
      // Using a StatefulBuilder so that the sheet can update internally if needed.
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          top: 16,
          left: 16,
          right: 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.loc.signBelow,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[200],
              ),
              child: Signature(
                controller: _controller,
                backgroundColor: Colors.transparent,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: _controller.clear,
                  icon: const Icon(Icons.refresh),
                  label: Text(context.loc.common_clear),
                ),
                ElevatedButton.icon(
                  onPressed: () async {
                    // Ensure we haven't disposed yet
                    if (_controller.isNotEmpty) {
                      final image = await _controller.toPngBytes();
                      if (image != null) {
                        signatureResult = image;
                        // Pop the bottom sheet using GoRouter's context extension.
                        // Alternatively, you can use Navigator.of(context).pop()
                        context.pop();
                      }
                    }
                  },
                  icon: const Icon(Icons.check, color: Colors.black),
                  label: Text(context.loc.common_save),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
        ),
      );
    },
  );

  return signatureResult;
}
