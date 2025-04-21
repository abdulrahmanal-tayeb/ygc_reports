import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';

Future<void> showReportPreview(BuildContext context, String reportPath, {void Function()? onShare}) async {
  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) {
      return FractionallySizedBox(
        heightFactor: 0.95,
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          child: Scaffold(
            appBar: AppBar(
              backgroundColor: Colors.white,
              elevation: 1,
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
            body: Column(
              children: [
                Expanded(
                  child: PDFView(
                    filePath: reportPath,
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
                  ),
                ),
                SafeArea(
                  child: Container(
                    color: Colors.white,
                    child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: onShare,
                        icon: const Icon(Icons.share, color: Colors.white,),
                        label: const Text('Share', style: TextStyle(color: Colors.white),),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.black
                        ),
                      ),
                    ),
                  )
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
