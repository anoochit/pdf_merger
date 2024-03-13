// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../controllers/home_controller.dart';

class PdfConfigView extends GetView<HomeController> {
  PdfConfigView({super.key});

  TextEditingController ownerPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ownerPasswordController.text = 'ThisIsAVerySecureOwnerPassword!!!';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TextFormField(
            controller: ownerPasswordController,
            decoration: const InputDecoration(
              hintText: 'Owner password',
              prefixIcon: Icon(Icons.password),
            ),
            showCursor: true,
            obscureText: true,
          ),
        ),
        Expanded(
          child: Obx(
            () => ListView(
              physics: const ScrollPhysics(),
              children: controller.pdfPermissions.asMap().entries.map((e) {
                return CheckboxListTile(
                  value: controller.listPermissions[e.key],
                  title: Text(e.value.name),
                  onChanged: (value) {
                    controller.listPermissions[e.key] = value!;
                  },
                );
              }).toList(),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4),
          child: SizedBox(
            width: double.maxFinite,
            child: FilledButton.icon(
              onPressed: () async {
                // merge message
                MergeMessage mergeMessage = MergeMessage(
                  ownerPassword: ownerPasswordController.text,
                  filePaths: controller.listFiles
                      .map((element) => element.path!)
                      .toList(),
                  listPermissions: controller.listPermissions,
                  pdfPermissions: controller.pdfPermissions,
                );

                // show dialog
                showDialog(
                  context: context,
                  builder: (context) {
                    Future.delayed(const Duration(seconds: 2)).then(
                      (value) {
                        mergePdf(mergeMessage).then(
                          (value) => Get.back(),
                        );
                      },
                    );
                    return const AlertDialog(
                      content: Text('Processing...'),
                    );
                  },
                );
              },
              icon: const Icon(Icons.play_arrow),
              label: const Text('Merge'),
            ),
          ),
        ),
      ],
    );
  }
}

class MergeMessage {
  final String ownerPassword;
  final List<String> filePaths;
  final List<bool> listPermissions;
  final List<PdfPermissionsFlags> pdfPermissions;

  MergeMessage({
    required this.ownerPassword,
    required this.filePaths,
    required this.listPermissions,
    required this.pdfPermissions,
  });
}

Future<bool> mergePdf(MergeMessage mergeMessage) async {
  try {
    //Create docment
    PdfDocument document = PdfDocument();
    //Set margin for all the pages
    document.pageSettings.size = PdfPageSize.a4;
    document.pageSettings.margins.all = 0;

    for (var file in mergeMessage.filePaths) {
      final pdf = File(file);
      final doc = PdfDocument(
        inputBytes: pdf.readAsBytesSync(),
      );

      for (var i = 0; i < doc.pages.count; i++) {
        final section = document.sections!.add();
        final template = doc.pages[i].createTemplate();
        section.pages.add().graphics.drawPdfTemplate(
              template,
              const Offset(0, 0),
            );
      }
    }

    // get path
    final appPath = await getApplicationDocumentsDirectory();
    final path = appPath.path;

    // save the document
    document.compressionLevel = PdfCompressionLevel.best;

    PdfSecurity security = document.security;

    //Set security options
    security.algorithm = PdfEncryptionAlgorithm.aesx256BitRevision6;
    security.ownerPassword = mergeMessage.ownerPassword;

    // remove permission
    final listPermissions = mergeMessage.listPermissions;
    final permissions = mergeMessage.pdfPermissions;

    for (int pindex = 0; pindex < listPermissions.length; pindex++) {
      if (listPermissions[pindex] == false) {
        document.security.permissions.remove(permissions[pindex]);
      } else {
        document.security.permissions.add(permissions[pindex]);
      }
    }

    List<int> bytes = await document.save();

    // dispose the document
    document.dispose();

    // open file and write file
    final filename =
        '$path/export_${DateTime.now().millisecondsSinceEpoch}.pdf';

    log(filename);
    final file = File(filename);
    await file.writeAsBytes(bytes);

    return true;
  } catch (e) {
    log('$e');
    return false;
  }
}
