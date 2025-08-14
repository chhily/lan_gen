import 'package:flutter/material.dart';
import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/ui/app_bar_action_button.dart';
import 'package:lan_gen/ui/export_mode.dart';
import 'package:lan_gen/ui/history_page.dart';
import 'package:lan_gen/utils/app_manager.dart';
import 'package:lan_gen/utils/storage_manager.dart';

import 'translate_preview.dart';

ValueNotifier<List<TranslationData>?> translationNotifier =
    ValueNotifier<List<TranslationData>?>(null);

ValueNotifier<ExportMode> exportNotifier = ValueNotifier<ExportMode>(
  ExportMode.overWrite,
);

ValueNotifier<bool> useCamelCaseNotifer = ValueNotifier<bool>(false);

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
  String? fileName;
  Map<String, Map<String, String>> translations = {};

  bool validateFilePath() {
    return excelFilePathController.text.isNotEmpty &&
        translateTextController.text.isNotEmpty &&
        localeKeyTextController.text.isNotEmpty;
  }

  Future<void> loadProjectHistory() async {
    translationNotifier.value = await StorageManager.getSavedTranslationDate();
  }

  void clearData() {
    excelFilePathController.clear();
    translateTextController.clear();
    localeKeyTextController.clear();
    ExcelParser.i.duplicateRecord.clear();
    translations.clear();
    filePath = null;
    fileName = null;
    setState(() {});
    onShowSnackBar("Cleared!");
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
    loadProjectHistory();
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (!validateFilePath()) {
            onShowSnackBar("Path cannot be empty!");
            return;
          }
          AppManager().exportTranslations(
            translations,
            context,
            exportMode: exportNotifier.value,
            useCamelCase: useCamelCaseNotifer.value,
            userDir: translateTextController.text.trim(),
            userLocaleKeyDir: localeKeyTextController.text.trim(),
          );
        },
        icon: Icon(Icons.autorenew_rounded),
        label: Text("GENERATE"),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: Text("Aoi.dev"),
        actions: [
          AppBarActionButton(
            onImportFile: () async {
              final result = await AppManager().pickSheetFile();
              if (result?.files != null) {
                setState(() {
                  filePath = result?.files.single.path;
                  fileName = result?.files.single.name;
                  excelFilePathController.value = TextEditingValue(
                    text: filePath ?? "",
                  );
                });
              }

              translations =
                  await AppManager().getSheetData(filePath: filePath) ?? {};
            },
            onExportFile: () {
              AppManager().exportTranslations(
                translations,
                context,
                exportMode: exportNotifier.value,
                useCamelCase: useCamelCaseNotifer.value,
              );
            },
            onOpenHistory: () {
              showDialog(
                context: context,

                builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.all(80.0),
                    child: HistoryPage(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
        children: [
          ExportModeWidget(
            projectName: fileName,
            onPressedClear: () => clearData(),
            onPressedSave: () {
              AppManager().saveData(
                context,
                name: fileName ?? "N/A",
                excelFilePath: excelFilePathController.text.trim(),
                savedTranslateFilePath: translateTextController.text.trim(),
                savedLocaleKeyFilePath: localeKeyTextController.text.trim(),
                loadProjectHistory: loadProjectHistory,
              );
              if (!validateFilePath()) {
                return;
              }
            },
          ),

          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: TranslationPreview(translations: translations),
            ),
          ),
        ],
      ),
    );
  }
}
