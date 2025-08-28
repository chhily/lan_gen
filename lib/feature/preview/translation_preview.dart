import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';

import '../../shared/themes/app_text_theme.dart';
import '../../shared/themes/themes.dart';
import '../../shared/widget/app_space.dart';
import 'widget/drag_drop_section.dart';

class TranslationPreview extends ConsumerWidget {
  final int? duplicates;
  final void Function()? onPressed;

  const TranslationPreview({super.key, this.duplicates, this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerData = ref.watch(translationProvider);
    final translations = providerData.translations;
    if (translations == null || (translations.isEmpty)) {
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
          AppSpace.y(y: 12),
          DragDropSection(),
        ],
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

    return Column(
      children: [
        ...missingKeyWarnings,
        ...missingLangWarnings,

        AppSpace.y(),

        SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 12),
          scrollDirection: Axis.horizontal,
          child: Column(
            children: [
              Tooltip(
                message:
                    "Automatically flags duplicate keys within each language to prevent errors",
                child: Badge(
                  isLabelVisible: duplicates != null,
                  offset: Offset(-16, -12),
                  backgroundColor: AppColors.warning,
                  label: Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text("Duplicated $duplicates"),
                  ),
                  child: TextButton(
                    onPressed: onPressed,
                    style: duplicates != null
                        ? TextButton.styleFrom(
                            side: BorderSide(color: AppColors.border),
                          )
                        : null,
                    child: Text("<PREVIEW TABLE/>"),
                  ),
                ),
              ),
              AppSpace.y(),
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
                              width: (translations[lang]?[key]?.isEmpty ?? true)
                                  ? 40
                                  : null,
                              color: (translations[lang]?[key]?.isEmpty ?? true)
                                  ? AppColors.error
                                  : null,
                              child: Text(
                                translations[lang]?[key] ?? "",
                                textAlign: TextAlign.left,
                                style: appTextTheme.bodyMedium?.copyWith(
                                  color:
                                      (translations[lang]?[key]?.isEmpty ??
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
      ],
    );
  }
}
