import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:bdoneapp/components/logger_config.dart';

class PdfService {
  final Dio _dio = Dio();

  /// Downloads a PDF from a URL and saves it locally
  /// Returns the local file path
  Future<String> downloadPdf({
    required String url,
    required String fileName,
    Function(int, int)? onProgress,
  }) async {
    try {
      // Get the app's documents directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';

      // Check if file already exists
      final file = File(filePath);
      if (await file.exists()) {
        logger.d('PDF already exists at: $filePath');
        return filePath;
      }

      // Download the file
      await _dio.download(
        url,
        filePath,
        onReceiveProgress: onProgress,
      );

      logger.d('PDF downloaded to: $filePath');

      return filePath;
    } catch (e) {
      logger.e('Error downloading PDF: $e');
      rethrow;
    }
  }

  /// Checks if a PDF exists locally
  Future<bool> pdfExists(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      return await File(filePath).exists();
    } catch (e) {
      return false;
    }
  }

  /// Gets the local path of a PDF if it exists
  Future<String?> getLocalPdfPath(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      
      if (await file.exists()) {
        return filePath;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  /// Deletes a locally stored PDF
  Future<bool> deletePdf(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName.pdf';
      final file = File(filePath);
      
      if (await file.exists()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      logger.e('Error deleting PDF: $e');
      return false;
    }
  }

  /// Clears all cached PDFs
  Future<void> clearAllPdfs() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final files = directory.listSync();
      
      for (var file in files) {
        if (file.path.endsWith('.pdf')) {
          await file.delete();
        }
      }
    } catch (e) {
      logger.e('Error clearing PDFs: $e');
    }
  }
}
