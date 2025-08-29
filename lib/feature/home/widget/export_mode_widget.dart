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
                Padding(padding: EdgeInsets.all(8), child: Text("OVERWRITE")),
                Padding(padding: EdgeInsets.all(8), child: Text("MERGE")),
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
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("USE CAMELCASE"),
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
            InkWell(
              onTap: onTap,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDark),
                ),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
          ],
        ),
        Spacer(),
        Column(
          children: [
            Text(
              "<${provider.userData?.name ?? ""}/>",
              style: appTextTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            AppSpace.y(y: AppDimensions.sm),
            Row(
              children: [
                SizedBox(
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
                AppSpace.x(),
                SizedBox(
                  width: 140,
                  child: AppButton(
                    text: "Clear",
                    fixedSize: Size.fromHeight(48),
                    onPressed: isHasProject()
                        ? () {
                            ref.invalidate(suggestedTranslationProvider);
                            ref.invalidate(rawSheetProvider);
                            stateNotifier.clearStateValue();
                          }
                        : null,
                    background: AppColors.error,
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
