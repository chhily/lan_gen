import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../shared/provider/sheet_provider/sheet_provider.dart';
import '../../shared/provider/translate_provider/translation_provider.dart';

class SheetPreview extends ConsumerStatefulWidget {
  const SheetPreview({super.key});

  @override
  ConsumerState createState() => _SheetPreviewState();
}

class _SheetPreviewState extends ConsumerState<SheetPreview> {
  @override
  Widget build(BuildContext context) {
    final rawSheet = ref.watch(rawSheetProvider);
    final suggestions = ref.watch(suggestedTranslationProvider);

    final suggestionNotifier = ref.read(suggestedTranslationProvider.notifier);
    final trData = ref.watch(translationProvider);

    if (rawSheet.isEmpty) {
      return Center(child: Text("NO DATA"));
    }

    final headers = rawSheet.first.map((e) => e.toString()).toList();

    return SingleChildScrollView(
      child: DataTable(
        columns: [for (final h in headers) DataColumn(label: Text(h))],
        rows: [
          for (final row in rawSheet.skip(1))
            DataRow(
              cells: [
                for (int i = 0; i < row.length; i++)
                  DataCell(
                    Builder(
                      builder: (context) {
                        final key = row[0]?.toString() ?? '';
                        final lang = headers[i];
                        final rawValue = row[i]?.toString() ?? '';
                        final suggested = suggestions[lang]?[key];

                        return Stack(
                          children: [
                            Text(
                              rawValue.isEmpty && suggested != null
                                  ? suggested
                                  : rawValue,
                            ),
                            if (suggested != null && rawValue.isEmpty)
                              Positioned(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        Icons.check,
                                        color: Colors.green,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        suggestionNotifier.acceptSuggestion(
                                          lang,
                                          key,
                                          (lang, key, value) {
                                            trData.translations?[lang]?[key] =
                                                value;
                                          },
                                        );
                                      },
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        Icons.close,
                                        color: Colors.red,
                                        size: 18,
                                      ),
                                      onPressed: () {
                                        suggestionNotifier.removeSuggestion(
                                          lang,
                                          key,
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }
}
