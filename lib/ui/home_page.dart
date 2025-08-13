import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/ui/input_path.dart';

import '../services/file_services.dart';
import '../shared/app_colors.dart';
import 'duplicate_panel.dart';
import 'translate_preview.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late TextEditingController translateTextController,
      localeKeyTextController,
      excelFilePathController;

  String? filePath;
  Map<String, Map<String, String>> translations = {};

  FileServices fileServices = FileServices.i;

  ExportMode exportMode = ExportMode.overWrite;

  bool useCamelCase = false;

  Future<void> pickSheetFile() async {
    try {
      final result = await fileServices.pickExcelFile();
      if (result != null && result.files.single.path != null) {
        setState(() {
          filePath = result.files.single.path;
          excelFilePathController.value = TextEditingValue(
            text: result.files.single.path ?? "N/A",
          );
        });
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> getSheetData() async {
    try {
      final result = await fileServices.readFile(path: filePath);
      if (result.isNotEmpty) {
        translations = ExcelParser.i.parseTranslation(result);
      }
    } catch (e) {
      debugPrint("$e");
    }
  }

  void exportTranslations() {
    switch (exportMode) {
      case ExportMode.overWrite:
        Exportor.i.exportTranslations(translations);
      case ExportMode.merge:
        Exportor.i.exportWithMerged(translations: translations);
    }
  }

  void generateTranslations() {
    switch (exportMode) {
      case ExportMode.overWrite:
        Exportor.i.exportTranslations(
          translations,
          userDir: translateTextController.text,
          userLocaleKeyDir: localeKeyTextController.text,
        );
      case ExportMode.merge:
        Exportor.i.exportWithMerged(
          translations: translations,
          userDir: translateTextController.text,
          userLocaleKeyDir: localeKeyTextController.text,
        );
    }
  }

  bool validateFilePath() {
    return excelFilePathController.text.isNotEmpty &&
        translateTextController.text.isNotEmpty &&
        localeKeyTextController.text.isNotEmpty;
  }

  void clearData() {
    FilePicker.platform.clearTemporaryFiles();
    excelFilePathController.clear();
    translateTextController.clear();
    localeKeyTextController.clear();
    ExcelParser.i.duplicateRecord.clear();
    translations.clear();
    filePath = null;
    setState(() {});
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> onShowSnackBar(
    String msg,
  ) {
    return ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), duration: Durations.medium1));
  }

  @override
  void initState() {
    super.initState();
    translateTextController = TextEditingController();
    localeKeyTextController = TextEditingController();
    excelFilePathController = TextEditingController();
  }

  @override
  void dispose() {
    translateTextController.dispose();
    localeKeyTextController.dispose();
    excelFilePathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: kToolbarHeight + 12,
        flexibleSpace: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              ToggleButtons(
                isSelected: [
                  exportMode == ExportMode.overWrite,
                  exportMode == ExportMode.merge,
                ],
                onPressed: (index) {
                  setState(() {
                    exportMode = ExportMode.values[index];
                  });
                },
                children: const [
                  Padding(padding: EdgeInsets.all(8), child: Text("OVERWRITE")),
                  Padding(padding: EdgeInsets.all(8), child: Text("MERGE")),
                ],
              ),
              AppSpace.x(),
              ToggleButtons(
                onPressed: (index) {
                  setState(() {
                    useCamelCase = !useCamelCase;
                  });
                },
                isSelected: [useCamelCase == true],
                children: [
                  Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("USE CAMELCASE"),
                  ),
                ],
              ),

              Spacer(),
              Text(
                "aoi.dev",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(16),

        children: [
          ExpansionTile(
            iconColor: AppColors.warning,
            initiallyExpanded: true,

            title: Text(
              "GEN FILE PATH INPUT",
              style: TextStyle(
                color: AppColors.warning,
                fontWeight: FontWeight.bold,
              ),
            ),
            tilePadding: EdgeInsets.zero,
            children: [
              AppSpace.y(),

              InputPath(
                excelFilePathController: excelFilePathController,
                translateTextController: translateTextController,
                localeKeyTextController: localeKeyTextController,
              ),
              AppSpace.y(),
            ],
          ),

          AppSpace.y(),

          Text('Select your Excel file with translations'),
          AppSpace.y(),

          AppButton(
            text: "CHOSE EXCEL FILE",
            background: AppColors.secondaryDark,
            icon: Icons.file_upload_rounded,
            onPressed: () async {
              await pickSheetFile();
              await getSheetData();
            },
          ),

          AppSpace.y(),
          if (filePath != null)
            Row(
              children: [
                Expanded(
                  child: Text(
                    'File: $filePath',

                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: filePath ?? ""));
                    onShowSnackBar("File Path copied!");
                  },
                ),
              ],
            ),

          AppSpace.y(y: 24),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  text: "EXPORT",
                  icon: Icons.file_download_rounded,
                  onPressed: () => exportTranslations(),
                ),
              ),
              AppSpace.x(),
              Expanded(
                child: AppButton(
                  text: "GENERATE",
                  icon: Icons.autorenew_rounded,
                  background: AppColors.success,
                  onPressed: () {
                    if (!validateFilePath()) {
                      onShowSnackBar("Path cannot be empty!");
                      return;
                    }
                    generateTranslations();
                  },
                ),
              ),
            ],
          ),
          AppSpace.y(),
          AppButton(
            text: "Clear",
            onPressed: () => clearData(),
            background: AppColors.error,
          ),
          AppSpace.y(y: 32),

          DuplicatePanel(duplicates: ExcelParser.i.duplicateRecord),
          AppSpace.y(y: 32),

          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Preview", style: TextStyle(fontSize: 20)),
                AppSpace.y(),
                TranslationPreview(translations: translations),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
