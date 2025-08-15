import 'package:flutter/material.dart';
import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/ui/app_bar_action_button.dart';
import 'package:lan_gen/ui/duplicate_modal.dart';
import 'package:lan_gen/ui/export_mode.dart';
import 'package:lan_gen/ui/history_page.dart';
import 'package:lan_gen/ui/generate_modal_widget.dart';
import 'package:lan_gen/utils/app_manager.dart';
import 'package:lan_gen/utils/storage_manager.dart';

import 'translate_preview.dart';

ValueNotifier<List<TranslationData>?> translationHistoryNotifier =
    ValueNotifier<List<TranslationData>?>(null);

ValueNotifier<ExportMode> exportNotifier = ValueNotifier<ExportMode>(
  ExportMode.overWrite,
);

ValueNotifier<bool> useCamelCaseNotifier = ValueNotifier<bool>(false);

ValueNotifier<TranslationData> translationData = ValueNotifier<TranslationData>(
  TranslationData(
    name: '',
    excelFilePath: '',
    savedTranslateFilePath: '',
    savedLocaleKeyFilePath: '',
  ),
);

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Map<String, Map<String, String>> translations = {};

  Future<void> importFile() async {
    final result = await AppManager().pickSheetFile();
    if (result?.files.isNotEmpty ?? false) {
      final file = result!.files.single;
      translationData.value = translationData.value.copyWith(
        name: file.name,
        excelFilePath: file.path,
      );

      translations = await AppManager().getSheetData(filePath: file.path) ?? {};
      setState(() {});
    }
  }

  Future<void> loadProjectHistory() async {
    translationHistoryNotifier.value =
        await StorageManager.getSavedTranslationDate();
  }

  bool isHasFile() => translationData.value.excelFilePath.isNotEmpty;

  void clearData() {
    translationData.value = TranslationData(
      name: '',
      excelFilePath: '',
      savedTranslateFilePath: '',
      savedLocaleKeyFilePath: '',
    );
    ExcelParser.i.duplicateRecord.clear();
    translations.clear();
    onShowSnackBar("Cleared!");
  }

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> onShowSnackBar(
    String msg,
  ) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: Duration(seconds: 3)),
    );
  }

  bool validateTranslationData() {
    final data = translationData.value;
    return data.excelFilePath.isNotEmpty &&
        data.savedLocaleKeyFilePath.isNotEmpty &&
        data.savedTranslateFilePath.isNotEmpty;
  }

  void onGenerateFile(TranslationData data) {
    debugPrint(
      "path : ${data.savedTranslateFilePath.trim()} ${data.savedLocaleKeyFilePath}",
    );
    if (validateTranslationData()) {
      AppManager().exportTranslations(
        translations,
        context,
        exportMode: exportNotifier.value,
        useCamelCase: useCamelCaseNotifier.value,
        userDir: data.savedTranslateFilePath.trim(),
        userLocaleKeyDir: data.savedLocaleKeyFilePath.trim(),
      );
    } else {
      onSetCustomPath();
    }
  }

  void onSetCustomPath() {
    showDialog(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(120.0),
          child: ValueListenableBuilder(
            valueListenable: translationData,
            builder: (context, value, child) {
              return GenerateModalWidget(
                onPressed: validateTranslationData()
                    ? () {
                        if (validateTranslationData()) {
                          AppManager().exportTranslations(
                            translations,
                            context,
                            exportMode: exportNotifier.value,
                            useCamelCase: useCamelCaseNotifier.value,
                            userDir: value.savedTranslateFilePath.trim(),
                            userLocaleKeyDir: value.savedLocaleKeyFilePath
                                .trim(),
                          );
                          AppManager().saveData(
                            context,
                            name: value.name,
                            excelFilePath: value.excelFilePath.trim(),
                            savedTranslateFilePath: value.savedTranslateFilePath
                                .trim(),
                            savedLocaleKeyFilePath: value.savedLocaleKeyFilePath
                                .trim(),
                            loadProjectHistory: loadProjectHistory,
                          );
                        }
                      }
                    : null,
                onPressedImport: () => importFile(),
              );
            },
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    loadProjectHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => onGenerateFile(translationData.value),
        icon: const Icon(Icons.autorenew_rounded),
        label: const Text("GENERATE"),
      ),
      drawer: SizedBox(
        width: MediaQuery.of(context).size.width * 0.5,
        child: DuplicateModal(duplicateRecord: ExcelParser.i.duplicateRecord),
      ),
      appBar: AppBar(
        centerTitle: false,
        title: const Text("Aoi.dev"),
        leading: SizedBox(),
        leadingWidth: 0,
        actions: [
          AppBarActionButton(
            onImportFile: () => importFile(),
            onExportFile: isHasFile()
                ? () {
                    AppManager().exportTranslations(
                      translations,
                      context,
                      exportMode: exportNotifier.value,
                      useCamelCase: useCamelCaseNotifier.value,
                    );
                  }
                : null,
            onOpenHistory: () {
              showDialog(
                context: context,
                builder: (context) {
                  return const Padding(
                    padding: EdgeInsets.all(80.0),
                    child: HistoryPage(),
                  );
                },
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          ValueListenableBuilder<TranslationData>(
            valueListenable: translationData,
            builder: (context, data, _) {
              return ExportModeWidget(
                projectName: data.name,
                onPressedClear: () => setState(() {
                  clearData();
                }),
                onPressedSave: () {
                  if (validateTranslationData()) {
                    AppManager().saveData(
                      context,
                      name: data.name,
                      excelFilePath: data.excelFilePath.trim(),
                      savedTranslateFilePath: data.savedTranslateFilePath
                          .trim(),
                      savedLocaleKeyFilePath: data.savedLocaleKeyFilePath
                          .trim(),
                      loadProjectHistory: loadProjectHistory,
                    );
                    return;
                  }
                },
                onSetPath: () => onSetCustomPath(),
              );
            },
          ),
          AppSpace.y(y: 20),

          Builder(
            builder: (context) {
              return Center(
                child: TranslationPreview(
                  translations: translations,
                  duplicates: ExcelParser.i.duplicateRecord.length,
                  onPressed: () {
                    Scaffold.of(context).openDrawer();
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
