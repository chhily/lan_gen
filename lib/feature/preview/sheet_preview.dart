import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/core/extensions/context_extensions.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

import '../../shared/app_colors.dart';
import '../../shared/provider/sheet_provider/sheet_provider.dart';
import '../../shared/provider/translate_provider/translation_provider.dart';

class SheetPreview extends ConsumerStatefulWidget {
  const SheetPreview({super.key});

  @override
  ConsumerState createState() => _SheetPreviewState();
}

class _SheetPreviewState extends ConsumerState<SheetPreview> {
  static const double _columnWidth = 220;
  static const double _rowHeight = 70;

  late final ScrollController _horizontalController;
  late final ScrollController _verticalController;

  @override
  void initState() {
    super.initState();
    _horizontalController = ScrollController();
    _verticalController = ScrollController();
  }

  @override
  void dispose() {
    _horizontalController.dispose();
    _verticalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rawSheet = ref.watch(rawSheetProvider);
    final suggestions = ref.watch(suggestedTranslationProvider);
    if (rawSheet.isEmpty) {
      return Center(
        child: Text(
          "NO DATA",
          style: appTextTheme.bodyMedium?.copyWith(color: AppColors.warning),
        ),
      );
    }

    final headers = rawSheet.first.map((e) => e.toString()).toList();
    final tableWidth = headers.length * _columnWidth;

    return Column(
      children: [
        AppSpace.y(y: 32),
        Expanded(
          child: Scrollbar(
            controller: _verticalController,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: Scrollbar(
              controller: _horizontalController,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: tableWidth,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          for (int i = 0; i < headers.length; i++)
                            _headerCell(headers[i], i),
                        ],
                      ),
                      Expanded(
                        child: ListView.builder(
                          controller: _verticalController,
                          itemCount: rawSheet.length - 1,
                          itemBuilder: (context, rowIndex) {
                            final row = rawSheet[rowIndex + 1];

                            return SizedBox(
                              height: _rowHeight,
                              child: Row(
                                children: [
                                  for (int i = 0; i < row.length; i++)
                                    Builder(
                                      builder: (_) {
                                        final key = row[0]?.toString() ?? '';
                                        final lang = headers[i];
                                        final rawValue =
                                            row[i]?.toString() ?? '';
                                        final item = suggestions
                                            .translations[lang]?[key];
                                        final suggested = item?.value;
                                        final accepted =
                                            item?.accepted ?? false;

                                        return _buildCell(
                                          lang: lang,
                                          key: key,
                                          rawValue: rawValue,
                                          suggested: suggested,
                                          accepted: accepted,
                                        );
                                      },
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCell({
    required String lang,
    required String key,
    required String rawValue,
    required String? suggested,
    required bool accepted,
  }) {
    final suggestionNotifier = ref.read(suggestedTranslationProvider.notifier);

    return Container(
      width: _columnWidth,
      height: _rowHeight,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.centerLeft,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accepted
                      ? AppColors.success
                      : suggested != null
                      ? AppColors.warning
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  rawValue.isEmpty && suggested != null ? suggested : rawValue,
                  style: appTextTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ),
          ),

          if (suggested != null && rawValue.isEmpty)
            Positioned(
              top: 0,
              right: 0,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!accepted)
                    InkWell(
                      onTap: () {
                        suggestionNotifier.acceptSuggestion(lang, key, (
                          lang,
                          key,
                          value,
                        ) {
                          ref
                              .read(translationProvider.notifier)
                              .setTranslationValue(lang, key, value);
                        });
                      },
                      child: const Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 18,
                      ),
                    ),

                  InkWell(
                    onTap: () {
                      suggestionNotifier.resetSuggestion(lang, key);
                    },
                    child: Icon(
                      accepted ? Icons.restore : Icons.cancel,
                      color: Colors.red,
                      size: 18,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _headerCell(String text, int column) {
    final isKeyColumn = column == 0;

    return InkWell(
      onTap: isKeyColumn
          ? null
          : () {
              ref
                  .read(suggestedTranslationProvider.notifier)
                  .acceptLanguageSuggestion(text, (key, value) {
                    ref
                        .read(translationProvider.notifier)
                        .setTranslationValue(text, key, value);
                  });
            },
      child: Container(
        width: _columnWidth,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Badge(
          isLabelVisible: !isKeyColumn,
          label: const Text("Accept All"),
          backgroundColor: AppColors.tertiary,
          offset: const Offset(16, -12),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
