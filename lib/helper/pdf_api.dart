import 'dart:io';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:zami/models/invoice.dart';

// Klasa obsługująca operacje związane z generowaniem i zapisem plików PDF
class PdfApi {
  // Metoda do zapisywania dokumentu PDF na urządzeniu
  static Future<File> saveDocument({
    required String name,
    required pw.Document pdf,
  }) async {
    // Zapisanie dokumentu PDF do pliku
    final bytes = await pdf.save();
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$name');
    await file.writeAsBytes(bytes);
    return file;
  }

  // Metoda do otwierania istniejącego pliku
  static Future openFile(File file) async {
    final url = file.path;
    await OpenFile.open(url);
  }

  // Metoda do generowania dokumentu PDF na podstawie faktury
  static Future<File> generate(Invoice invoice) async {
    try {
      // Inicjalizacja dokumentu PDF
      final pdf = pw.Document();

      // Ładowanie czcionek
      final fontDataRegular =
      await rootBundle.load("assets/fonts/OpenSans-Regular.ttf");
      final fontDataBold =
      await rootBundle.load("assets/fonts/OpenSans-Bold.ttf");
      final fontDataLightItalic =
      await rootBundle.load("assets/fonts/OpenSans-LightItalic.ttf");

      // Definicja czcionek
      final ttfFontRegular = pw.Font.ttf(fontDataRegular.buffer.asByteData());
      final ttfFontBold = pw.Font.ttf(fontDataBold.buffer.asByteData());
      final ttfFontLightItalic = pw.Font.ttf(fontDataLightItalic.buffer.asByteData());

      // Dodanie strony do dokumentu
      pdf.addPage(
        pw.MultiPage(
          // Konfiguracja tematu strony
          theme: pw.ThemeData.withFont(
            base: ttfFontRegular,
            bold: ttfFontBold,
          ),
          // Konfiguracja stopki strony
          footer: (pw.Context context) {
            return pw.Container(
              alignment: pw.Alignment.center,
              margin: pw.EdgeInsets.only(top: 10),
              child: pw.Text(
                'Strona ${context.pageNumber}/${context.pagesCount}',
                style: pw.TextStyle(
                  fontSize: 8,
                  color: PdfColors.black,
                ),
              ),
            );
          },
          // Budowanie treści strony
          build: (context) => [
            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.end,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Paragraph(
                      text: 'FAKTURA NR: ${invoice.info.number}',
                      style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Paragraph(
                      text:
                      'Data wystawienia: ${Utils.formatDate(invoice.info.date)}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text:
                      'Termin płatności: ${Utils.formatDate(invoice.info.dueDate)}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                  ],
                ),
              ],
            ),
            pw.SizedBox(height: 40),

            pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Seller details
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Paragraph(
                      text: 'Sprzedawca:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Paragraph(
                      text: 'Nazwa Firmy: ${invoice.supplier.name}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Adres: ${invoice.supplier.address}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Kod pocztowy: ${invoice.supplier.postalCode}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Miejscowość: ${invoice.supplier.city}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'NIP: ${invoice.supplier.nip}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                  ],
                ),

                // Spacer to push Buyer details to the right
                pw.SizedBox(width: 100),

                // Buyer details
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Paragraph(
                      text: 'Odbiorca:',
                      style: pw.TextStyle(
                        fontSize: 12,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Paragraph(
                      text: 'Imie i Nazwisko: ${invoice.customer.name}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Adres: ${invoice.customer.address}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Kod pocztowy: ${invoice.customer.postalCode}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'Miejscowość: ${invoice.customer.city}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                    pw.Paragraph(
                      text: 'NIP: ${invoice.customer.nip}',
                      style: pw.TextStyle(fontSize: 12),
                      margin: pw.EdgeInsets.only(bottom: 4),
                    ),
                  ],
                ),
              ],
            ),


            pw.SizedBox(height: 20),

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

            pw.SizedBox(height: 10),

            // Summary table
            pw.Table.fromTextArray(
              headers: [
                'Podsumowanie',
                'Wartość netto',
                'VAT %',
                'Wartość VAT',
                'Wartość brutto',
              ],
              data: [
                [
                  'Razem',
                  '${Utils.formatPrice(invoice.netTotalAmount)}',
                  '23%',
                  '${Utils.formatPrice(invoice.vatTotalAmount)}',
                  '${Utils.formatPrice(invoice.grossTotalAmount)}',
                ],
              ],
              border: pw.TableBorder.all(),
              headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
              cellAlignment: pw.Alignment.centerLeft,
            ),

            pw.SizedBox(height: 10),

            // Total amount in words
            pw.Paragraph(
              text:
              'Słownie: ${Utils.amountInWords(invoice.grossTotalAmount)}',
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
              ),
            ),

            pw.SizedBox(height: 20),

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
            pw.SizedBox(height: 20),
            pw.Paragraph(
              text: 'Dokument wystawiony automatycznie nie wymagający podpisu.',
              style: pw.TextStyle(
                fontSize: 10,
                fontStyle: pw.FontStyle.italic,
                font: ttfFontLightItalic,
                color: PdfColors.grey900,
              ),
            ),
          ],
        ),
      );
      // Zapisanie i zwrócenie pliku PDF
      return saveDocument(name: 'faktura.pdf', pdf: pdf);
    } catch (e) {
      print('Błąd generowania PDF: $e');
      throw e;
    }
  }
}

// Klasa narzędziowa zawierająca pomocnicze metody
class Utils {
  // Metoda do formatowania daty
  static String formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}";
  }

  // Metoda do formatowania ceny
  static String formatPrice(double price) {
    return "${price.toStringAsFixed(2)} zł";
  }

// Metoda zamieniająca kwotę na słowa
  static String amountInWords(double amount) {
    final wholePart = amount.floor();
    final decimalPart = ((amount - wholePart) * 100).round();

    final wholeWords = _convertToWords(wholePart);
    final decimalWords = _convertToWords(decimalPart);

    final wholeText = wholeWords.isNotEmpty ? '$wholeWords złotych' : '';
    final decimalText =
    decimalWords.isNotEmpty ? ' i $decimalWords groszy' : '';

    return '$wholeText$decimalText';
  }

// Metoda prywatna konwertująca liczbę poniżej tysiąca na słowa
  static String _convertToWords(int number) {
    final units = ['', 'jeden', 'dwa', 'trzy', 'cztery', 'pięć', 'sześć', 'siedem', 'osiem', 'dziewięć'];
    final teens = ['dziesięć', 'jedenaście', 'dwanaście', 'trzynaście', 'czternaście', 'piętnaście', 'szesnaście', 'siedemnaście', 'osiemnaście', 'dziewiętnaście'];
    final tens = ['', '', 'dwadzieścia', 'trzydzieści', 'czterdzieści', 'pięćdziesiąt', 'sześćdziesiąt', 'siedemdziesiąt', 'osiemdziesiąt', 'dziewięćdziesiąt'];
    final hundreds = ['', 'sto', 'dwieście', 'trzysta', 'czterysta', 'pięćset', 'sześćset', 'siedemset', 'osiemset', 'dziewięćset'];

    String convertBelowThousand(int num) {
      if (num == 0) {
        return '';
      } else if (num < 10) {
        return units[num];
      } else if (num < 20) {
        return teens[num - 10];
      } else if (num < 100) {
        final ten = num ~/ 10;
        final unit = num % 10;
        return '${tens[ten]} ${units[unit]}';
      } else {
        final hundred = num ~/ 100;
        final remainder = num % 100;
        return '${hundreds[hundred]} ${convertBelowThousand(remainder)}';
      }
    }

    if (number == 0) {
      return 'zero';
    } else {
      return convertBelowThousand(number);
    }
  }
}