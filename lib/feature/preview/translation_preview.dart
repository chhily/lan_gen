import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';

import '../../shared/themes/app_text_theme.dart';
import '../../shared/themes/themes.dart';
import '../../shared/widget/app_space.dart';
import 'widget/drag_drop_section.dart';

class TranslationPreview extends ConsumerStatefulWidget {
  final int? duplicates;
  final void Function()? onPressed;

  const TranslationPreview({super.key, this.duplicates, this.onPressed});

  @override
  ConsumerState<TranslationPreview> createState() => _TranslationPreviewState();
}

class _TranslationPreviewState extends ConsumerState<TranslationPreview> {
  late final ScrollController _horizontalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final providerData = ref.watch(translationProvider);
    final translations = providerData.translations;
    if (translations == null || (translations.isEmpty)) {
      return SingleChildScrollView(
        primary: false,
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.warning_rounded, color: AppColors.warning),
                AppSpace.x(),
                Text("No data to preview",
                    style: appTextTheme.bodyMedium
                        ?.copyWith(color: AppColors.warning)),
              ],
            ),
            AppSpace.y(y: 12),
            DragDropSection(),
          ],
        ),
      );
    }

    // Get notifier for missing key/lang detection
    final notifier = ref.read(translationProvider.notifier);
    final missingKeysPerLang = notifier.getMissingKeysPerLanguage();
    final missingLangsPerKey = notifier.getMissingLanguagesPerKey();

    final languages = translations.keys.toList();
    final keys = translations[languages.first]?.keys.toList();

    // UI for missing keys per language
    List<Widget> missingKeyWarnings = [];
    if (missingKeysPerLang.isNotEmpty) {
      missingKeyWarnings.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 18),
              AppSpace.x(),
              Expanded(
                child: Text(
                  "Missing keys in: ${missingKeysPerLang.entries.map((e) => "${e.key} [${e.value.length}]").join(", ")}",
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // UI for missing languages per key
    List<Widget> missingLangWarnings = [];

    if (missingLangsPerKey.isNotEmpty) {
      missingLangWarnings.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 18),
              AppSpace.x(),
              Expanded(
                child: Text(
                  "Keys missing in languages: ${missingLangsPerKey.entries.take(3).map((e) => "${e.key} → ${e.value.join(', ')}").join("; ")}${missingLangsPerKey.length > 3 ? " ..." : ""}",
                  style: TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      primary: false,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ...missingKeyWarnings,
            ...missingLangWarnings,
            AppSpace.y(),
            Scrollbar(
              controller: _horizontalController,
              thumbVisibility: true,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Tooltip(
                      message:
                          "Automatically flags duplicate keys within each language to prevent errors",
                      child: Badge(
                        isLabelVisible: widget.duplicates != null && widget.duplicates! > 0,
                        offset: const Offset(-16, -12),
                        backgroundColor: AppColors.warning,
                        label: Padding(
                          padding: const EdgeInsets.all(2.0),
                          child: Text("Duplicated ${widget.duplicates}"),
                        ),
                        child: TextButton(
                          onPressed: widget.onPressed,
                          style: widget.duplicates != null && widget.duplicates! > 0
                              ? TextButton.styleFrom(
                                  side: BorderSide(color: AppColors.border),
                                )
                              : null,
                          child: const Text("<PREVIEW TABLE/>"),
                        ),
                      ),
                    ),
                    AppSpace.y(),
                    DataTable(
                      headingRowColor:
                          const WidgetStatePropertyAll(AppColors.surface),
                      border: TableBorder.all(color: AppColors.border),
                      headingTextStyle:
                          const TextStyle(fontWeight: FontWeight.bold),
                      dataRowMinHeight: 48,
                      columnSpacing: 24,
                      columns: [
                        const DataColumn(label: Text("Key")),
                        for (final lang in languages)
                          DataColumn(label: Text(lang)),
                      ],
                      rows: [
                        for (final key in keys ?? [])
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
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    width: (translations[lang]?[key]?.isEmpty ??
                                            true)
                                        ? 40
                                        : null,
                                    color: (translations[lang]?[key]?.isEmpty ??
                                            true)
                                        ? AppColors.error.withOpacity(0.2)
                                        : null,
                                    child: Text(
                                      translations[lang]?[key] ?? "",
                                      textAlign: TextAlign.left,
                                      style: appTextTheme.bodyMedium?.copyWith(
                                        color: (translations[lang]?[key]
                                                    ?.isEmpty ??
                                                true)
                                            ? AppColors.error
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
