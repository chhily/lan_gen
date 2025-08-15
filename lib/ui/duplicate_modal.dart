import 'package:flutter/material.dart';

import '../models/duplicate_record.dart';
import '../shared/app_colors.dart';
import '../shared/themes/app_text_theme.dart';
import '../shared/widget/app_space.dart';

class DuplicateModal extends StatelessWidget {
  final List<DuplicateRecord> duplicateRecord;
  const DuplicateModal({super.key, required this.duplicateRecord});

  @override
  Widget build(BuildContext context) {
    final duplicatesByLang = <String, Map<String, List<int>>>{};
    for (var dup in duplicateRecord) {
      duplicatesByLang.putIfAbsent(dup.lang, () => {});
      duplicatesByLang[dup.lang]!.putIfAbsent(dup.key, () => []);
      duplicatesByLang[dup.lang]![dup.key]!.add(dup.rowNumber);
    }

    return Scaffold(
      persistentFooterButtons: [
        Center(
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Text(
              "App will automatically flag duplicate keys within each language to prevent errors.",
              style: appTextTheme.labelMedium?.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
      appBar: AppBar(
        title: Text("<DUPLICATE RECORD/>", style: appTextTheme.headlineSmall),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(12),
        itemBuilder: (context, langIndex) {
          final langEntry = duplicatesByLang.entries.elementAt(langIndex);
          final lang = langEntry.key;
          final keysMap = langEntry.value;

          final filteredKeys = keysMap.entries
              .where((e) => e.value.isNotEmpty)
              .toList();

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Duplicate Keys Found in [$lang]: ${filteredKeys.length} keys",
                style: appTextTheme.labelLarge,
              ),
              ...filteredKeys.map((e) {
                final key = e.key;
                final rows = e.value.join(", ");
                final count = e.value.length;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  child: Text(
                    "[$key] => [$count] duplicates in rows: \n($rows)",
                  ),
                );
              }),
            ],
          );
        },
        separatorBuilder: (context, index) => AppSpace.y(),
        itemCount: duplicatesByLang.length,
      ),
    );
  }
}
