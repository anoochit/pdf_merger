import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

import 'package:get/get.dart';
import 'package:pdfpermission/app/modules/home/views/pdf_view_view.dart';

import '../controllers/home_controller.dart';
import 'list_files_view.dart';
import 'pdf_config_view.dart';
import 'toolbox_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Merger'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        surfaceTintColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Flex(
        direction: Axis.horizontal,
        children: [
          const Flexible(
            flex: 2,
            child: PdfViewerView(),
          ),
          const VerticalDivider(
            width: 0.0,
          ),
          Flexible(
            flex: 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Flexible(
                  flex: 0,
                  child: Column(
                    children: [
                      //
                      ToolboxView(),
                    ],
                  ),
                ),

                //
                const Divider(),
                const Flexible(
                  flex: 2,
                  child: ListFilesView(),
                ),

                //
                const Divider(
                  height: 1.0,
                ),
                Flexible(
                  flex: 4,
                  child: PdfConfigView(),
                ),

                const Gap(8),
              ],
            ),
          )
        ],
      ),
    );
  }
}
