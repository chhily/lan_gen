import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/core/services/exportor.dart';
import 'package:lan_gen/shared/provider/app_provider.dart';
import 'package:lan_gen/shared/provider/sheet_provider/sheet_provider.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';

import '../../../shared/themes/app_text_theme.dart';
import '../../../shared/themes/themes.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_space.dart';

class ExportModeWidget extends ConsumerWidget {
  final void Function()? onTap;
  const ExportModeWidget({super.key, this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = ref.watch(translationProvider);
    final stateNotifier = ref.read(translationProvider.notifier);
    final appProvider = ref.watch(appConfigProvider);

    bool isHasProject() => provider.userData?.name.isNotEmpty ?? false;
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("<EXPORT MODES/>"),
            AppSpace.y(y: AppDimensions.sm),
            ToggleButtons(
              selectedColor: AppColors.success,
              isSelected: [
                appProvider.exportMode == ExportMode.overWrite,
                appProvider.exportMode == ExportMode.merge,
              ],
              onPressed: (index) {
                ref
                    .read(appConfigProvider.notifier)
                    .setExportMode(ExportMode.values[index]);
              },
              children: const [
                Tooltip(
                  message: "Replace existing translation files entirely",
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("OVERWRITE"),
                  ),
                ),
                Tooltip(
                  message: "Merge new translations into existing files, keeping untouched keys",
                  child: Padding(padding: EdgeInsets.all(8), child: Text("MERGE")),
                ),
              ],
            ),
          ],
        ),
        AppSpace.x(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("<KEY MODES/>"),
            AppSpace.y(y: AppDimensions.sm),
            ToggleButtons(
              selectedColor: AppColors.success,
              onPressed: (index) {
                ref.read(appConfigProvider.notifier).toggleCamelCase();
              },
              isSelected: [appProvider.useCamelCase],
              children: [
                Tooltip(
                  message: "Generate locale keys in camelCase instead of the default format",
                  child: Padding(
                    padding: EdgeInsets.all(8),
                    child: Text("USE CAMELCASE"),
                  ),
                ),
              ],
            ),
          ],
        ),
        AppSpace.x(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("<Auto tr/>"),
            AppSpace.y(y: AppDimensions.sm),
            Row(
              children: [
                Tooltip(
                  message: "Automatically translate missing values",
                  child: InkWell(
                    onTap: onTap,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                      child: Text(
                        "AUTO FILL",
                        style: appTextTheme.bodyMedium?.copyWith(
                          color: ref.read(translationProvider.notifier).validateData()
                              ? AppColors.success
                              : AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ),
                ),
                AppSpace.x(x: 8),
                Tooltip(
                  message: "Accept all suggestions",
                  child: IconButton(
                    onPressed: () {
                      ref.read(suggestedTranslationProvider.notifier).acceptAllSuggestions(
                        (lang, key, value) {
                          ref.read(translationProvider.notifier).setTranslationValue(lang, key, value);
                        },
                      );
                    },
                    icon: const Icon(Icons.done_all, color: AppColors.success),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(),
        Column(
          children: [
            Text(
              "<${provider.userData?.name ?? ""}/>",
              style: appTextTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpace.y(y: AppDimensions.xs),
            // Progress Indicator
            if (isHasProject())
              Builder(
                builder: (context) {
                  final progress = ref.watch(translationProvider.notifier).getTranslationProgress();
                  final overall = progress.isEmpty 
                      ? 0.0 
                      : progress.values.reduce((a, b) => a + b) / progress.length;
                  
                  return Tooltip(
                    message: progress.entries
                        .map((e) => "${e.key}: ${(e.value * 100).toInt()}%")
                        .join("\n"),
                    child: SizedBox(
                      width: 200,
                      height: 4,
                      child: LinearProgressIndicator(
                        value: overall,
                        backgroundColor: AppColors.borderDark,
                        color: AppColors.success,
                      ),
                    ),
                  );
                },
              ),
            AppSpace.y(y: AppDimensions.sm),
            Row(
              children: [
                Tooltip(
                  message: "Save the current project's translation data",
                  child: SizedBox(
                    width: 140,
                    child: AppButton(
                      text: "SAVE",
                      fixedSize: Size.fromHeight(48),
                      onPressed: isHasProject()
                          ? () {
                              stateNotifier.onSaveUserData();
                            }
                          : null,
                      background: AppColors.success,
                    ),
                  ),
                ),
                AppSpace.x(),
                Tooltip(
                  message: "Clear all loaded data and reset the current session",
                  child: SizedBox(
                    width: 140,
                    child: AppButton(
                      text: "Clear",
                      fixedSize: Size.fromHeight(48),
                      onPressed: isHasProject()
                          ? () {
                              ref.invalidate(suggestedTranslationProvider);
                              ref.invalidate(rawSheetProvider);
                              ref.invalidate(duplicateProvider);
                              stateNotifier.clearStateValue();
                            }
                          : null,
                      background: AppColors.error,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
