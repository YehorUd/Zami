import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zami/models/invoice.dart';

class PdfApi {
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    final bytes = await pdf.save();

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');

    await file.writeAsBytes(bytes);

    return file;
  }

  static Future openFile(File file) async {
    final url = file.path;

    await OpenFile.open(url);
  }

  static Future<File> generate(Invoice invoice) async {
    try {
      final pdf = pw.Document();

      final fontDataRegular =
      await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
      final fontDataBold =
      await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");

      final ttfFontRegular =
      pw.Font.ttf(fontDataRegular.buffer.asByteData());
      final ttfFontBold = pw.Font.ttf(fontDataBold.buffer.asByteData());

      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(
            base: ttfFontRegular,
            bold: ttfFontBold,
          ),
          build: (context) => [
            pw.Paragraph(
              text: 'FAKTURA NR: ${invoice.info.number}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Paragraph(
              text: 'Miejscowość: ${invoice.location}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text: 'Data wystawienia: ${Utils.formatDate(invoice.info.date)}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text:
              'Termin płatności: ${Utils.formatDate(invoice.info.dueDate)}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text: 'Sprzedawca: ${invoice.supplier.name}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text: 'Nabywca: ${invoice.customer.name}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.SizedBox(height: 10), // Add some space

            // Invoice items
            pw.Table.fromTextArray(
              headers: [
                'Opis',
                'Ilość',
                'Cena jedn.',
                'Wartość netto',
                'VAT (%)',
                'Wartość VAT',
                'Wartość brutto'
              ],
              data: invoice.items
                  .map((item) => [
                item.description,
                item.quantity.toString(),
                '${item.unitPrice} zł',
                '${item.netAmount} zł',
                '${(item.vat * 100).toStringAsFixed(2)}%',
                '${item.vatAmount} zł',
                '${item.grossAmount} zł',
              ])
                  .toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 10), // Add some space

            pw.Paragraph(
              text:
              'Razem: ${Utils.formatPrice(invoice.grossTotalAmount)}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 10), // Add some space

            // Payment details
            pw.Paragraph(
              text: 'Status płatności: ${invoice.paymentStatus}',
              style: pw.TextStyle(fontSize: 12),
            ),
            if (invoice.paymentStatus == 'Zapłacona')
              pw.Paragraph(
                text:
                'Termin płatności: ${Utils.formatDate(invoice.paymentDueDate)}',
                style: pw.TextStyle(fontSize: 12),
              ),
            pw.Paragraph(
              text: 'Forma płatności: ${invoice.paymentMethod}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text: 'Metoda płatności: ${invoice.paymentType}',
              style: pw.TextStyle(fontSize: 12),
            ),
          ],
        ),
      );

      return saveDocument(name: 'faktura.pdf', pdf: pdf);
    } catch (e) {
      print('Błąd generowania PDF: $e');
      throw e;
    }
  }
}

class Utils {
  static String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  static String formatPrice(double price) {
    return "${price.toStringAsFixed(2)} zł";
  }
}
