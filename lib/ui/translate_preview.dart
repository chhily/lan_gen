import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/utils/app_manager.dart';

import '../shared/app_dimensions.dart';
import 'home_page.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:path/path.dart' as p;

class TranslationPreview extends StatefulWidget {
  final Map<String, Map<String, String>> translations;
  final int? duplicates;
  final void Function()? onPressed;

  const TranslationPreview({
    super.key,
    required this.translations,
    required this.duplicates,
    this.onPressed,
  });

  @override
  State<TranslationPreview> createState() => _TranslationPreviewState();
}

class _TranslationPreviewState extends State<TranslationPreview> {
  bool _dragging = false;

  Future<void> _handleFileDrop(List<dynamic> files) async {
    if (files.isEmpty) return;

    final file = File(files.first.path);
    if (file.path.endsWith(".xlsx") || file.path.endsWith(".xls")) {
      final sheetData = await AppManager().getSheetData(filePath: file.path);
      final fileName = p.basename(file.path);
      translationData.value = translationData.value.copyWith(
        excelFilePath: file.path,
        translationsSheet: sheetData,
        name: fileName,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Only Excel files (.xlsx / .xls) allowed")),
      );
    }
  }

  bool hasDuplicates() => widget.duplicates != null && widget.duplicates != 0;
  @override
  Widget build(BuildContext context) {
    if (widget.translations.isEmpty) {
      return Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning_rounded),
              AppSpace.x(),
              Text("No data to preview"),
            ],
          ),
          AppSpace.y(y: 32),
          DropTarget(
            onDragEntered: (_) => setState(() => _dragging = true),
            onDragExited: (_) => setState(() => _dragging = false),
            onDragDone: (detail) => _handleFileDrop(detail.files),
            child: Container(
              height: MediaQuery.of(context).size.height * 0.5,
              decoration: BoxDecoration(
                border: Border.all(
                  color: _dragging ? AppColors.success : AppColors.border,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                color: _dragging
                    ? AppColors.success.withValues(alpha: 0.1)
                    : AppColors.secondary,
              ),
              child: Center(child: Text("IMPORT OR DRAG FILE HERE")),
            ),
          ),
        ],
      );
    }

    final languages = widget.translations.keys.toList();
    final keys = widget.translations[languages.first]!.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Tooltip(
            message:
                "Automatically flags duplicate keys within each language to prevent errors",
            child: Badge(
              isLabelVisible: hasDuplicates(),
              offset: Offset(-16, -12),
              backgroundColor: AppColors.warning,
              label: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Text("Duplicated ${widget.duplicates}"),
              ),
              child: TextButton(
                onPressed: hasDuplicates() ? widget.onPressed : null,
                style: hasDuplicates()
                    ? TextButton.styleFrom(
                        side: BorderSide(color: AppColors.border),
                      )
                    : null,
                child: Text("<PREVIEW TABLE/>"),
              ),
            ),
          ),
          AppSpace.y(y: AppDimensions.sm),
          DataTable(
            headingRowColor: WidgetStatePropertyAll(AppColors.surface),
            border: TableBorder.all(color: AppColors.border),
            headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
            dataRowMinHeight: 48,
            columnSpacing: 24,
            columns: [
              const DataColumn(label: Text("Key")),
              for (final lang in languages) DataColumn(label: Text(lang)),
            ],
            rows: [
              for (final key in keys)
                DataRow(
                  cells: [
                    DataCell(
                      Text(
                        key,
                        style: appTextTheme.bodyMedium?.copyWith(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                    for (final lang in languages)
                      DataCell(
                        Text(
                          widget.translations[lang]?[key] ?? "",
                          style: appTextTheme.bodyMedium?.copyWith(
                            color:
                                (widget.translations[lang]?[key]?.isEmpty ??
                                    true)
                                ? AppColors.error
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }
}
