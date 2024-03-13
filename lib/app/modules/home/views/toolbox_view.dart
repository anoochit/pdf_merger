import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class ToolboxView extends GetView<HomeController> {
  const ToolboxView({super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          ElevatedButton.icon(
            onPressed: () => addFiles(),
            icon: const Icon(Icons.add),
            label: const Text('Add files'),
          ),
          const Spacer(),
          ElevatedButton.icon(
            onPressed: () => removeFiles(),
            icon: const Icon(Icons.delete),
            label: const Text('Remove All'),
          ),
        ],
      ),
    );
  }

  // add pdf file path to list
  addFiles() async {
    final fileResult = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
      allowMultiple: true,
    );

    if (fileResult != null) {
      for (var file in fileResult.files) {
        controller.listFiles.add(file);
      }
    }
  }

  removeFiles() {
    controller.listFiles.clear();
  }
}
