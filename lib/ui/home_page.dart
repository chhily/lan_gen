import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/ui/app_bar_action_button.dart';
import 'package:lan_gen/ui/export_mode.dart';
import 'package:lan_gen/ui/history_page.dart';
import 'package:lan_gen/utils/app_manager.dart';
import 'package:lan_gen/utils/exportor_manager.dart';

import 'translate_preview.dart';

ValueNotifier<List<TranslationData>?> translationNotifier =
    ValueNotifier<List<TranslationData>?>(null);

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

  ExportMode exportMode = ExportMode.overWrite;

  bool useCamelCase = false;

  bool validateFilePath() {
    return excelFilePathController.text.isNotEmpty &&
        translateTextController.text.isNotEmpty &&
        localeKeyTextController.text.isNotEmpty;
  }

  Future<void> loadProjectHistory() async {
    translationNotifier.value =
        await ExportPathManager.getSavedTranslationDate();
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
            exportMode: exportMode,
            useCamelCase: useCamelCase,
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
              final (value, value1) = await AppManager().pickSheetFile();
              setState(() {
                filePath = value;
                excelFilePathController.value = value1;
              });
              translations =
                  await AppManager().getSheetData(filePath: filePath) ?? {};
            },
            onExportFile: () {
              AppManager().exportTranslations(
                translations,
                context,
                exportMode: exportMode,
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
            exportMode: exportMode,
            useCamelCase: useCamelCase,
            onPressedClear: () => clearData(),
            onPressedSave: () {
              if (!validateFilePath()) {
                return;
              }
              AppManager().saveData(
                context,
                name: "name",
                excelFilePath: excelFilePathController.text.trim(),
                savedTranslateFilePath: translateTextController.text.trim(),
                savedLocaleKeyFilePath: localeKeyTextController.text.trim(),
                loadProjectHistory: loadProjectHistory,
              );
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
