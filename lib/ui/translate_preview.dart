import 'package:flutter/material.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

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
      child: DataTable(
        border: TableBorder.all(color: AppColors.surface),
        headingTextStyle: const TextStyle(fontWeight: FontWeight.bold),
        dataRowMinHeight: 48,
        columnSpacing: 24,
        columns: [
          const DataColumn(label: Text("Key")),
          for (final lang in languages)
            DataColumn(label: Text(lang.toUpperCase())),
        ],
        rows: [
          for (final key in keys)
            DataRow(
              cells: [
                DataCell(
                  Text(
                    key,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
                for (final lang in languages)
                  DataCell(
                    Text(
                      translations[lang]?[key] ?? "",
                      style: TextStyle(
                        color: (translations[lang]?[key]?.isEmpty ?? true)
                            ? AppColors.error
                            : null,
                      ),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
