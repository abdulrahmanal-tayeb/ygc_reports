import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

Future<void> showReportPreview(BuildContext context, {String? path, Uint8List? data,  required void Function({bool save}) onShare}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.white,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              centerTitle: true,
              title: const Text(
                'Report Preview',
                style: TextStyle(
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
                    child: 
                    (path != null)?
                      PDFView(
                        filePath: path,
                        autoSpacing: true,
                        enableSwipe: true,
                        swipeHorizontal: false,
                        pageSnap: true,
                        fitEachPage: true,
                        fitPolicy: FitPolicy.BOTH,
                        onError: (error) =>
                            debugPrint('PDFView error: $error'),
                        onPageError: (page, error) =>
                            debugPrint('Error on page $page: $error'),
                      )
                    : (data != null) ?
                      Image.memory(data)
                      : const Center(child: Text("Preview not available."))
                  ),
                  SafeArea(
                    child: Container(
                      color: Colors.white,
                      child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: double.infinity,
                        child: Row(
                          spacing: 5,
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => onShare!(save: false),
                                icon: const Icon(Icons.share, color: Colors.black),
                                label: const Text('Share Only', style: TextStyle(color: Colors.black)),
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
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: onShare,
                                icon: const Icon(Icons.save_alt_rounded, color: Colors.white,),
                                label: const Text('Save & Share', style: TextStyle(color: Colors.white),),
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  backgroundColor: Colors.black
                                ),
                              )
                            )
                            
                          ],
                        ),
                      ),
                    )
                    ),
                  ),
                ],
              )
            ),
          ),
        ),
      );
    },
  );
}
