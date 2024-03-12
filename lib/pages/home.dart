import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool isProcessing = false;
  FilePickerResult? result;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF remove permissaion'),
      ),
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                (result != null)
                    ? Text(result!.files.first.path!)
                    : Container(),
                const SizedBox(
                  height: 8,
                ),
                FilledButton(
                  onPressed: () => browsePDF(),
                  child: const Text('Browse PDF ...'),
                ),
                const SizedBox(
                  height: 8,
                ),
                FilledButton(
                  onPressed: () {
                    exportPdf();
                  },
                  child: const Text('Export PDF ...'),
                ),
              ],
            ),
          ),
          Visibility(
            visible: isProcessing,
            child: const SizedBox(
              width: 64,
              height: 80,
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  Text('Processing...'),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  exportPdf() async {
    if (result != null) {
      // get file path
      final file = File(result!.files.first.path!);

      // load to pdf
      PdfDocument document = PdfDocument(
        inputBytes: file.readAsBytesSync(),
      );

      PdfSecurity security = document.security;
      //Set security options
      security.ownerPassword = "vpjkcopypdfd^l'lkid^g5vt";

      // remove permission
      document.security.permissions.remove(PdfPermissionsFlags.print);
      document.security.permissions
          .remove(PdfPermissionsFlags.assembleDocument);
      document.security.permissions.remove(PdfPermissionsFlags.copyContent);
      document.security.permissions.remove(PdfPermissionsFlags.editContent);
      document.security.permissions
          .remove(PdfPermissionsFlags.accessibilityCopyContent);
      document.security.permissions
          .remove(PdfPermissionsFlags.fullQualityPrint);

      //Save and dispose the PDF document
      final output = '${result!.files.first.path!.split('.').first}_output.pdf';
      File(output).writeAsBytes(await document.save());
      document.dispose();

      Future.delayed(const Duration(seconds: 10));

      setState(() {
        isProcessing = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export file to $output '),
        ),
      );
    }
  }

  browsePDF() async {
    result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
  }
}
