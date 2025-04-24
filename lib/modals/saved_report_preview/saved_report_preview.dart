import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:ygc_reports/core/utils/local_helpers.dart';


Future<bool> showReportPreview(
  BuildContext context, {
  String? path,
  Uint8List? data,
  required Future<void> Function({bool save}) onShare,
}) async {
  bool dismissed = true;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: Text(
                context.loc.reportPreview,
                style: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.black87),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            body: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: path != null
                        ? PDFView(
                            filePath: path,
                            autoSpacing: true,
                            enableSwipe: true,
                            swipeHorizontal: false,
                            pageSnap: true,
                            fitEachPage: true,
                            fitPolicy: FitPolicy.BOTH,
                            onError: (error) => debugPrint('PDFView error: $error'),
                            onPageError: (page, error) => debugPrint('Error on page $page: $error'),
                          )
                        : data != null
                            ? Image.memory(data)
                            : const Center(child: Text("Preview not available.")),
                  ),
                  SafeArea(
                    child: Container(
                      color: Colors.white,
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                dismissed = false;
                                await onShare(save: false);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.share, color: Colors.black),
                              label: Text(context.loc.common_share, style: const TextStyle(color: Colors.black)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  side: const BorderSide(color: Colors.black, width: 1),
                                ),
                                backgroundColor: Colors.transparent,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () async {
                                dismissed = false;
                                await onShare(save: true);
                                Navigator.pop(context);
                              },
                              icon: const Icon(Icons.save_alt_rounded, color: Colors.white),
                              label: Text(context.loc.common_saveAndShare, style: const TextStyle(color: Colors.white)),
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                backgroundColor: Colors.black,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );

  return dismissed;
}
