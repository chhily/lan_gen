import 'package:flutter/material.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

class AppBarActionButton extends StatelessWidget {
  final void Function()? onImportFile;
  final void Function()? onExportFile;
  final void Function()? onOpenHistory;
  const AppBarActionButton({
    super.key,
    this.onImportFile,
    this.onExportFile,
    this.onOpenHistory,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 140,
          child: AppButton(
            text: "IMPORT",
            background: AppColors.primary,
            icon: Icons.file_upload_rounded,
            onPressed: onImportFile,
          ),
        ),
        AppSpace.x(),
        SizedBox(
          width: 140,

          child: AppButton(
            text: "EXPORT",
            icon: Icons.file_download_rounded,
            onPressed: onExportFile,
          ),
        ),
        AppSpace.x(),
        IconButton.filled(
          icon: Icon(Icons.history_rounded),
          onPressed: onOpenHistory,
        ),
        AppSpace.x(),
      ],
    );
  }
}
