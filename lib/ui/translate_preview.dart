import 'package:flutter/material.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

import '../shared/app_dimensions.dart';

class TranslationPreview extends StatelessWidget {
  final Map<String, Map<String, String>> translations;

  const TranslationPreview({super.key, required this.translations});

  @override
  Widget build(BuildContext context) {
    if (translations.isEmpty) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.warning_rounded),
          AppSpace.x(),
          Text("No data to preview"),
        ],
      );
    }

    final languages = translations.keys.toList();
    final keys = translations[languages.first]!.keys.toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        children: [
          Text("<PREVIEW TABLE/>"),
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
                          translations[lang]?[key] ?? "",
                          style: appTextTheme.bodyMedium?.copyWith(
                            color: (translations[lang]?[key]?.isEmpty ?? true)
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
