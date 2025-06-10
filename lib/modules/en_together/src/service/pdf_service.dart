import 'package:easy_pdf_viewer/easy_pdf_viewer.dart';

class PdfService {
  static Future<PDFDocument?> loadDocument(String url) async {
    final cached = await DefaultCacheManager().getFileFromCache(url);

    if (cached != null && cached.file.existsSync()) {
      return PDFDocument.fromFile(cached.file);
    }

    return null; // 다운로드 진행은 외부에서
  }
}
