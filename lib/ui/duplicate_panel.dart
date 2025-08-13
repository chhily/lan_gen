
import 'package:flutter/material.dart';
import 'package:lan_gen/models/duplicate_record.dart';

import '../shared/app_colors.dart';

class DuplicatePanel extends StatefulWidget {
  final List<DuplicateRecord> duplicates;

  const DuplicatePanel({required this.duplicates, super.key});

  @override
  // ignore: library_private_types_in_public_api
  _DuplicatePanelState createState() => _DuplicatePanelState();
}

class _DuplicatePanelState extends State<DuplicatePanel> {

  @override
  Widget build(BuildContext context) {
    if (widget.duplicates.isEmpty) return SizedBox.shrink();

    final duplicatesByLang = <String, List<DuplicateRecord>>{};
    for (var dup in widget.duplicates) {
      duplicatesByLang.putIfAbsent(dup.lang, () => []).add(dup);
    }
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        "${widget.duplicates.length} duplicated keys found",
        style: TextStyle(
          color: AppColors.warning,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      children: [
        Wrap(
          children: List.generate(duplicatesByLang.length, (index) {
            final entry = duplicatesByLang.entries.elementAt(index);
            final lang = entry.key;
            final duplicates = entry.value;
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                ...duplicates.map(
                  (record) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.start,

                    children: [
                      RichText(
                        text: TextSpan(
                          text: lang.toUpperCase(),
                          style: TextStyle(color: AppColors.warning),

                          children: [
                            TextSpan(text: ": "),
                            TextSpan(
                              text: record.key,
                              style: TextStyle(color: AppColors.info),
                            ),
                          ],
                        ),
                      ),

                      Text("Old Value: ${record.oldValue}"),
                      Text("New Value: ${record.newValue}"),
                      Divider(color: AppColors.grey, thickness: 1),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ],
    );
  }
}
