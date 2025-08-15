import 'package:flutter/material.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/app_dimensions.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/ui/home_page.dart';

import '../shared/app_colors.dart';
import '../shared/widget/app_button.dart';
import '../shared/widget/app_space.dart';

class ExportModeWidget extends StatefulWidget {
  final String? projectName;
  final void Function()? onPressedClear;
  final void Function()? onPressedSave;
  final void Function()? onSetPath;

  const ExportModeWidget({
    super.key,
    this.projectName,
    this.onPressedClear,
    this.onPressedSave,
    this.onSetPath,
  });

  @override
  State<ExportModeWidget> createState() => _ExportModeWidgetState();
}

class _ExportModeWidgetState extends State<ExportModeWidget> {
  ExportMode exportMode = ExportMode.overWrite;
  bool isHasProject() => widget.projectName?.isNotEmpty ?? false;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("<EXPORT MODES/>"),
            AppSpace.y(y: AppDimensions.sm),
            ValueListenableBuilder(
              valueListenable: exportNotifier,
              builder: (context, value, child) {
                return ToggleButtons(
                  selectedColor: AppColors.success,
                  isSelected: [
                    value == ExportMode.overWrite,
                    value == ExportMode.merge,
                  ],
                  onPressed: (index) {
                    setState(() {
                      exportNotifier.value = ExportMode.values[index];
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("OVERWRITE"),
                    ),
                    Padding(padding: EdgeInsets.all(8), child: Text("MERGE")),
                  ],
                );
              },
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
            ValueListenableBuilder(
              valueListenable: useCamelCaseNotifier,
              builder: (context, value, child) {
                return ToggleButtons(
                  selectedColor: AppColors.success,

                  onPressed: (index) {
                    setState(() {
                      useCamelCaseNotifier.value = !value;
                    });
                  },
                  isSelected: [value == true],
                  children: [
                    Padding(
                      padding: EdgeInsets.all(8),
                      child: Text("USE CAMELCASE"),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
        AppSpace.x(),
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("<Custom Path/>"),
            AppSpace.y(y: AppDimensions.sm),
            InkWell(
              onTap: widget.onSetPath,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.borderDark),
                ),
                padding: EdgeInsets.symmetric(vertical: 14, horizontal: 8),
                child: Text(
                  "SET FILE PATH",
                  style: appTextTheme.bodyMedium?.copyWith(
                    color: AppColors.textPrimary,
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
              "<${widget.projectName ?? ""}/>",
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
                    onPressed: isHasProject() ? widget.onPressedSave : null,
                    background: AppColors.success,
                  ),
                ),
                AppSpace.x(),
                SizedBox(
                  width: 140,
                  child: AppButton(
                    text: "Clear",
                    fixedSize: Size.fromHeight(48),
                    onPressed: isHasProject() ? widget.onPressedClear : null,
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
