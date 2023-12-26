import 'package:zami/helper/pdf_api.dart';
import 'package:zami/models/invoice.dart';

class PdfInvoicePdfHelper {
  static void generate(Invoice invoice) async {
    final pdfFile = await PdfApi.generate(invoice);
    PdfApi.openFile(pdfFile);
  }
}