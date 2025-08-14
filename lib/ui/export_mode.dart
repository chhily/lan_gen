import 'package:flutter/material.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/app_dimensions.dart';

import '../shared/app_colors.dart';
import '../shared/widget/app_button.dart';
import '../shared/widget/app_space.dart';

// ignore: must_be_immutable
class ExportModeWidget extends StatefulWidget {
  ExportMode exportMode;
  bool useCamelCase;
  void Function()? onPressedClear;
  void Function()? onPressedSave;

  ExportModeWidget({
    super.key,
    this.exportMode = ExportMode.overWrite,
    this.useCamelCase = false,
    this.onPressedClear,
    this.onPressedSave,
  });

  @override
  State<ExportModeWidget> createState() => _ExportModeWidgetState();
}

class _ExportModeWidgetState extends State<ExportModeWidget> {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("<EXPORT MODES/>"),
            AppSpace.y(y: AppDimensions.sm),
            ToggleButtons(
              selectedColor: AppColors.success,
              isSelected: [
                widget.exportMode == ExportMode.overWrite,
                widget.exportMode == ExportMode.merge,
              ],
              onPressed: (index) {
                setState(() {
                  widget.exportMode = ExportMode.values[index];
                });
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("<KEY MODES/>"),
            AppSpace.y(y: AppDimensions.sm),
            ToggleButtons(
              selectedColor: AppColors.success,

              onPressed: (index) {
                setState(() {
                  widget.useCamelCase = !widget.useCamelCase;
                });
              },
              isSelected: [widget.useCamelCase == true],
              children: [
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Text("USE CAMELCASE"),
                ),
              ],
            ),
          ],
        ),
        Spacer(),

        Expanded(
          child: AppButton(
            text: "SAVE",
            onPressed: widget.onPressedSave,
            background: AppColors.success,
          ),
        ),
        AppSpace.x(),

        Expanded(
          child: AppButton(
            text: "Clear",
            icon: Icons.delete_forever_rounded,
            onPressed: widget.onPressedClear,
            background: AppColors.error,
          ),
        ),
      ],
    );
  }
}
