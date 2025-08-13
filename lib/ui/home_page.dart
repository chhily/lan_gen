import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lan_gen/services/excel_parser.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

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
  String? filePath;
  Map<String, Map<String, String>> translations = {};

  FileServices fileServices = FileServices.i;

  ExportMode exportMode = ExportMode.overWrite;

  Future<void> pickSheetFile() async {
    try {
      final result = await fileServices.pickExcelFile();
      if (result != null && result.files.single.path != null) {
        setState(() {
          filePath = result.files.single.path;
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

  bool useNestedClasses = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: EdgeInsets.all(16),

        children: [
          Row(
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
                  Padding(padding: EdgeInsets.all(8), child: Text("MERGE")),
                  Padding(padding: EdgeInsets.all(8), child: Text("OVERWRITE")),
                ],
              ),
            ],
          ),

          AppSpace.y(y: 32),

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
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('File path copied')),
                    );
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
                  onPressed: () => exportTranslations(),
                ),
              ),
            ],
          ),
          AppSpace.y(y: 32),

          DuplicatePanel(duplicates: ExcelParser.i.duplicateRecord),
          AppSpace.y(y: 32),

          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(12),
              child: TranslationPreview(translations: translations),
            ),
          ),
        ],
      ),
    );
  }
}
