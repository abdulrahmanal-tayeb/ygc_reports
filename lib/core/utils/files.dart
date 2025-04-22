import 'dart:io';

Future<void> deleteReportFromPath(String path) async {
  try {
    final file = File(path);
    if (await file.exists()) {
      await file.delete();
    } else {
      throw Exception("File not found");
    }
  } catch (e) {
    print("Error deleting file: $e");
    throw Exception("Failed to delete report file");
  }
}