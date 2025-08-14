import 'package:flutter/material.dart';
import 'package:lan_gen/services/exportor.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

// ignore: must_be_immutable
class AppBarActionButton extends StatefulWidget {
  ExportMode exportMode;
  bool useCamelCase;
  AppBarActionButton({
    super.key,
    this.exportMode = ExportMode.overWrite,
    this.useCamelCase = false,
  });

  @override
  State<AppBarActionButton> createState() => _AppBarActionButtonState();
}

class _AppBarActionButtonState extends State<AppBarActionButton> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
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
        AppSpace.x(),
        ToggleButtons(
          selectedColor: AppColors.success,

          onPressed: (index) {
            setState(() {
              widget.useCamelCase = !widget.useCamelCase;
            });
          },
          isSelected: [widget.useCamelCase == true],
          children: [
            Padding(padding: EdgeInsets.all(8), child: Text("USE CAMELCASE")),
          ],
        ),
        AppSpace.x(),
      ],
    );
  }
}
