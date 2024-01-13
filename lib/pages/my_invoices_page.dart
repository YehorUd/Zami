import 'package:flutter/material.dart';
import 'package:zami/models/invoice.dart';
import 'package:zami/helper/pdf_api.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MyInvoicesPage extends StatefulWidget {
  final Invoice? newInvoice;

  MyInvoicesPage({required this.newInvoice});

  @override
  _MyInvoicesPageState createState() => _MyInvoicesPageState();
}

class _MyInvoicesPageState extends State<MyInvoicesPage> {
  @override
  Widget build(BuildContext context) {
    // Warunek określający, czy pokazać listę faktur czy nową fakturę.
    bool showInvoiceList = widget.newInvoice == null;

    return Scaffold(
      appBar: AppBar(
        title: Text('Moje Faktury'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showInvoiceList)
              Text('Lista faktur będzie tutaj.'),
            if (widget.newInvoice != null)
              Column(
                children: [
                  // Wyświetlanie numeru nowej faktury.
                  Text('Faktura: ${widget.newInvoice!.info.number}'),
                  ElevatedButton(
                    onPressed: () => _savePdf(context),
                    child: Text('Pobierz fakturę'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _savePdf(BuildContext context) async {
    // Prośba o uprawnienia do zapisu plików.
    var status = await Permission.storage.request();
    if (status.isGranted) {
      final pdfFile = await PdfApi.generate(widget.newInvoice!);

      if (pdfFile != null) {
        final dir = await getExternalStorageDirectory();
        final downloadDir = Directory('${dir!.path}/Download');

        if (!downloadDir.existsSync()) {
          downloadDir.createSync();
        }

        // Tworzenie ścieżki i zapis pliku PDF.
        final path = '${downloadDir.path}/faktura_${widget.newInvoice!.info.number}.pdf';
        await File(path).writeAsBytes(pdfFile.readAsBytesSync());

        // Wyświetlanie informacji o udanym zapisie pliku.
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plik PDF z fakturą został pomyślnie zapisany w folderze Download.')),
        );

        // Otwarcie zapisanego pliku PDF.
        PdfApi.openFile(File(path));
      }
    } else {
     // Informacja o braku udzielonych uprawnień.
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udzielono uprawnień do zapisu plików.')),
      );
    }
  }
}
