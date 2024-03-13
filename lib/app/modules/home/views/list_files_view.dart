
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:pdfpermission/app/modules/home/controllers/home_controller.dart';

class ListFilesView extends GetView<HomeController> {
  const ListFilesView({super.key});
  @override
  Widget build(BuildContext context) {
    return Obx(
      () => ReorderableListView(
        physics: const ScrollPhysics(),
        onReorder: (int oldIndex, int newIndex) {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final PlatformFile item = controller.listFiles.removeAt(oldIndex);
          controller.listFiles.insert(newIndex, item);
        },
        children: controller.listFiles.asMap().entries.map((e) {
          return ListTile(
            key: Key('${e.key}'),
            title: Text(e.value.name),
            onTap: () => loadFile(path: e.value.path),
          );
        }).toList(),
      ),
    );
  }

  loadFile({String? path}) {
    controller.previewFile.value = path!;
  }
}
