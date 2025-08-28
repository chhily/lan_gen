import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

import '../../../shared/app_colors.dart';
import '../../../shared/widget/app_button.dart';

class ActionModal extends ConsumerWidget {
  final void Function()? onOpenHistory;

  const ActionModal({super.key, this.onOpenHistory});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stateNotifier = ref.read(translationProvider.notifier);
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.min,
      children: [
        // SizedBox(
        //   width: 140,
        //   child: AppButton(
        //     text: "IMPORT",
        //     background: AppColors.primary,
        //     icon: Icons.file_upload_rounded,
        //     onPressed: () {
        //       stateNotifier.onImportSheet();
        //     },
        //   ),
        // ),
        // AppSpace.x(),

        SizedBox(
          width: 140,

          child: AppButton(
            text: "EXPORT",
            icon: Icons.file_download_rounded,
            onPressed: () {
              final notifier = ref.read(translationProvider.notifier);
              // Export file doesn't need setUser Data
              notifier.onExportAndGenerate();
            },
          ),
        ),
        AppSpace.x(),
        IconButton.filled(
          icon: Icon(Icons.history_rounded),
          onPressed: onOpenHistory,
        ),
        AppSpace.x(x: 12),
      ],
    );
  }
}
