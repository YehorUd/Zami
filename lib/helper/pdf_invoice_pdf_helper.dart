import 'package:zami/helper/pdf_api.dart';
import 'package:zami/models/invoice.dart';

// Klasa pomocnicza do generowania i otwierania plików PDF dla faktur
class PdfInvoicePdfHelper {
  // Metoda do generowania i otwierania pliku PDF dla danej faktury
  static void generate(Invoice invoice) async {
    // Wygenerowanie pliku PDF na podstawie faktury
    final pdfFile = await PdfApi.generate(invoice);

    // Otwarcie wygenerowanego pliku PDF
    PdfApi.openFile(pdfFile);
  }
}
