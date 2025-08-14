import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/ui/app_bar_action_button.dart';
import 'package:lan_gen/ui/input_path.dart';
import 'package:lan_gen/utils/app_manager.dart';
import 'package:lan_gen/utils/exportor_manager.dart';

import '../shared/app_colors.dart';
import 'duplicate_panel.dart';
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
      appBar: AppBar(
        centerTitle: false,
        title: Text("Aoi.dev"),
        actions: [AppBarActionButton()],
        toolbarHeight: kToolbarHeight + 12,
      ),
      body: ListView(
        padding: EdgeInsets.all(12),
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
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: translationNotifier,
                      builder: (context, value, child) {
                        return Column(
                          children: List.generate(value?.length ?? 0, (index) {
                            final itemValue = value?.elementAt(index);
                            return Text("${itemValue?.excelFilePath}");
                          }),
                        );
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    AppSpace.y(),

                    Text('Select your Excel file with translations'),
                    AppSpace.y(),

                    AppButton(
                      text: "CHOSE EXCEL FILE",
                      background: AppColors.primary,
                      icon: Icons.file_upload_rounded,
                      onPressed: () async {
                        final (value, value1) = await AppManager()
                            .pickSheetFile();
                        setState(() {
                          filePath = value;
                          excelFilePathController.value = value1;
                        });
                        translations =
                            await AppManager().getSheetData(
                              filePath: filePath,
                            ) ??
                            {};
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
                              Clipboard.setData(
                                ClipboardData(text: filePath ?? ""),
                              );
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
                            onPressed: () => AppManager().exportTranslations(
                              translations,
                              context,
                              exportMode: exportMode,
                            ),
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
                              AppManager().exportTranslations(
                                translations,
                                context,
                                exportMode: exportMode,
                                useCamelCase: useCamelCase,
                                userDir: translateTextController.text.trim(),
                                userLocaleKeyDir: localeKeyTextController.text
                                    .trim(),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    AppSpace.y(),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: AppButton(
                            text: "Clear",
                            icon: Icons.delete_forever_rounded,
                            onPressed: () => clearData(),
                            background: AppColors.error,
                          ),
                        ),
                        AppSpace.x(),
                        Flexible(
                          child: AppButton(
                            text: "Save",
                            icon: Icons.shopping_cart_rounded,
                            onPressed: () {
                              if (!validateFilePath()) {
                                return;
                              }

                              AppManager().saveData(
                                context,
                                name: "name",
                                excelFilePath: excelFilePathController.text
                                    .trim(),
                                savedTranslateFilePath: translateTextController
                                    .text
                                    .trim(),
                                savedLocaleKeyFilePath: localeKeyTextController
                                    .text
                                    .trim(),
                                loadProjectHistory: loadProjectHistory,
                              );
                            },
                            background: AppColors.primary,
                          ),
                        ),
                      ],
                    ),

                    AppSpace.y(y: 32),

                    DuplicatePanel(duplicates: ExcelParser.i.duplicateRecord),
                  ],
                ),
              ),
            ],
          ),

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
