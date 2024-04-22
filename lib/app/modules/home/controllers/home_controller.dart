import 'package:file_picker/file_picker.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

class HomeController extends GetxController {
  //
  RxList<PlatformFile> listFiles = <PlatformFile>[].obs;

  RxList<bool> listPermissions = <bool>[
    false,
    false,
    false,
    false,
    false,
    false,
    false,
    false,
  ].obs;

  List<PdfPermissionsFlags> pdfPermissions = [
    PdfPermissionsFlags.accessibilityCopyContent,
    PdfPermissionsFlags.assembleDocument,
    PdfPermissionsFlags.copyContent,
    PdfPermissionsFlags.editAnnotations,
    PdfPermissionsFlags.editContent,
    PdfPermissionsFlags.fillFields,
    PdfPermissionsFlags.fullQualityPrint,
    PdfPermissionsFlags.print,
  ];

  RxString previewFile = ''.obs;

  RxBool showPassword = true.obs;
}
