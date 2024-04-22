// ignore_for_file: public_member_api_docs, sort_constructors_first, use_build_context_synchronously
// ignore_for_file: must_be_immutable

import 'dart:developer';
import 'dart:io';

import 'package:audioplayers/audioplayers.dart';
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
          child: Obx(
            () => TextFormField(
              controller: ownerPasswordController,
              decoration: InputDecoration(
                hintText: 'Owner password',
                prefixIcon: const Icon(Icons.password),
                suffixIcon: IconButton(
                  onPressed: () => controller.showPassword.value =
                      !controller.showPassword.value,
                  icon: (controller.showPassword.value)
                      ? const Icon(Icons.visibility)
                      : const Icon(Icons.visibility_off),
                ),
              ),
              showCursor: true,
              obscureText: controller.showPassword.value,
            ),
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
            child: Obx(
              () => FilledButton.icon(
                onPressed: (controller.listFiles.isNotEmpty)
                    ? () => merge(context)
                    : null,
                icon: const Icon(Icons.play_arrow),
                label: const Text('Merge'),
              ),
            ),
          ),
        ),
      ],
    );
  }

  merge(BuildContext context) async {
    // FIXME: Change to isolate process
    // merge message
    // get path
    final appPath = await getApplicationDocumentsDirectory();
    final path = appPath.path;

    // open file and write file
    final filename =
        '$path/export_${DateTime.now().millisecondsSinceEpoch}.pdf';
    MergeMessage mergeMessage = MergeMessage(
      ownerPassword: ownerPasswordController.text,
      filePaths: controller.listFiles.map((element) => element.path!).toList(),
      listPermissions: controller.listPermissions,
      pdfPermissions: controller.pdfPermissions,
      exportFile: filename,
    );

    // show dialog
    showDialog(
      context: context,
      builder: (context) {
        Future.delayed(const Duration(seconds: 2)).then(
          (value) async {
            final result = await mergePdf(mergeMessage);

            final audioPlayer = AudioPlayer();
            audioPlayer.play(
              AssetSource(
                "sound.mp3",
                mimeType: "audio/mpeg",
              ),
            );

            log('merge result = $result');
            Get.back();
            if (result == true) {
              Get.snackbar(
                'Info',
                'Merge complete at $filename',
                backgroundColor: Colors.green,
                maxWidth: 640,
                margin: EdgeInsets.only(
                    top: 8, left: MediaQuery.of(context).size.width - 640 - 8),
              );
            } else {
              Get.snackbar(
                'Error',
                'Error while merging files',
                backgroundColor: Colors.red,
                maxWidth: 640,
                margin: EdgeInsets.only(
                    top: 8, left: MediaQuery.of(context).size.width - 640 - 8),
              );
            }
          },
        );
        return const AlertDialog(
          content: Text('Waiting for processing...'),
        );
      },
    );
  }
}

class MergeMessage {
  final String ownerPassword;
  final List<String> filePaths;
  final List<bool> listPermissions;
  final List<PdfPermissionsFlags> pdfPermissions;
  final String exportFile;

  MergeMessage({
    required this.ownerPassword,
    required this.filePaths,
    required this.listPermissions,
    required this.pdfPermissions,
    required this.exportFile,
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

    log(mergeMessage.exportFile);
    final file = File(mergeMessage.exportFile);
    await file.writeAsBytes(bytes);

    Get.back();

    return true;
  } catch (e) {
    log('$e');
    return false;
  }
}
