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

      // Load the custom font
      final fontData =
      await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
      final ttfFont = pw.Font.ttf(fontData.buffer.asByteData());

      // Instead of using pw.Text to add text, use pw.Paragraph
      pdf.addPage(
        pw.MultiPage(
          theme: pw.ThemeData.withFont(
            base: ttfFont, // Use the loaded font
          ),
          build: (context) => [
            pw.Paragraph(
              text: 'FAKTURA NR: ${invoice.info.number}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text: 'Miejscowość: ${invoice.location}',
              style: pw.TextStyle(fontSize: 12),
            ),
            pw.Paragraph(
              text:
              'Data wystawienia: ${Utils.formatDate(invoice.info.date)}',
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
              headers: ['Description', 'Quantity', 'Unit Price', 'Total'],
              data: invoice.items
                  .map((item) => [
                item.description,
                item.quantity.toString(),
                '${item.unitPrice} zł',
                '${(item.unitPrice * item.quantity)} zł',
              ])
                  .toList(),
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 10), // Add some space

            pw.Paragraph(
              text: 'Razem: ${Utils.formatPrice(invoice.totalAmount)} zł',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
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

      return saveDocument(name: 'invoice.pdf', pdf: pdf);
    } catch (e) {
      print('PDF Generation Error: $e');
      throw e;
    }
  }
}

class Utils {
  static String formatDate(DateTime date) {
    return "${date.day}.${date.month}.${date.year}";
  }

  static String formatPrice(double price) {
    return "\$ ${price.toStringAsFixed(2)}";
  }
}