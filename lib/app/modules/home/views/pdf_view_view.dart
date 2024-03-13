import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pdfpermission/app/modules/home/controllers/home_controller.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerView extends GetView<HomeController> {
  const PdfViewerView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(() => (controller.previewFile.isNotEmpty)
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: SfPdfViewer.file(
              File(controller.previewFile.value),
              pageLayoutMode: PdfPageLayoutMode.single,
            ),
          )
        : const Center(
            child: Text('no file'),
          ));
  }
}
