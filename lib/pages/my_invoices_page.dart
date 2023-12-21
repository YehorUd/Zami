import 'package:flutter/material.dart';
import 'package:zami/models/invoice.dart';
import 'package:zami/helper/pdf_api.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class MyInvoicesPage extends StatelessWidget {
  final Invoice? newInvoice;

  MyInvoicesPage({required this.newInvoice});

  Future<void> _savePdf(BuildContext context) async {
    var status = await Permission.storage.request();
    if (status.isGranted) {
      // Uprawnienia do dostępu do pamięci zewnętrznej zostały przyznane

      final pdfFile = await PdfApi.generate(newInvoice!);

      if (pdfFile != null) {
        final dir = await getExternalStorageDirectory();
        final downloadDir = Directory('${dir!.path}/Download');

        // Sprawdzamy, czy folder Download istnieje, a jeśli nie, to go tworzymy
        if (!downloadDir.existsSync()) {
          downloadDir.createSync();
        }

        final path = '${downloadDir.path}/faktura_${newInvoice!.info.number}.pdf';
        await File(path).writeAsBytes(pdfFile.readAsBytesSync());

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Plik PDF z fakturą został pomyślnie zapisany w folderze Download.')),
        );

        // Otwieramy pobrany plik PDF
        PdfApi.openFile(File(path));
      }
    } else {
      // Uprawnienia nie zostały przyznane
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nie udzielono uprawnień do zapisu plików.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Moje Faktury'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lista faktur będzie tutaj.'),
            if (newInvoice != null)
              Column(
                children: [
                  Text('Nowa faktura: ${newInvoice!.info.number}'),
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
}