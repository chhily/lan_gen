import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_state.dart';

import '../../../shared/themes/app_text_theme.dart';
import '../../../shared/themes/themes.dart';
import '../../../shared/widget/app_button.dart';
import '../../../shared/widget/app_space.dart';

class GenerateModal extends ConsumerStatefulWidget {
  const GenerateModal({super.key});

  @override
  ConsumerState createState() => _GenerateModalState();
}

class _GenerateModalState extends ConsumerState<GenerateModal> {
  late TextEditingController translateTextController;
  late TextEditingController localeKeyTextController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    translateTextController = TextEditingController();
    localeKeyTextController = TextEditingController();
  }

  Future<void> _onGenerateSave(TranslationState state) async {
    if (_isSaving) return;
    final data = state.userData;
    if (data == null) return;

    setState(() => _isSaving = true);
    final notifier = ref.read(translationProvider.notifier);
    notifier.setUserData(
      data.copyWith(
        savedTranslateFilePath: translateTextController.text.trim(),
        savedLocaleKeyFilePath: localeKeyTextController.text.trim(),
      ),
    );
    await notifier.onSaveUserData();
    await notifier.onExportAndGenerate();
    if (mounted) setState(() => _isSaving = false);
  }

  @override
  void dispose() {
    translateTextController.dispose();
    localeKeyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(translationProvider);
    final notifier = ref.read(translationProvider.notifier);

    // keep controllers in sync with provider
    translateTextController.value = TextEditingValue(
      text: state.userData?.savedTranslateFilePath ?? '',
      selection: TextSelection.collapsed(
        offset: (state.userData?.savedTranslateFilePath ?? '').length,
      ),
    );

    localeKeyTextController.value = TextEditingValue(
      text: state.userData?.savedLocaleKeyFilePath ?? '',
      selection: TextSelection.collapsed(
        offset: (state.userData?.savedLocaleKeyFilePath ?? '').length,
      ),
    );

    bool isHasValidData() =>
        (state.userData?.excelFilePath.isNotEmpty ?? false) &&
        (state.userData?.savedTranslateFilePath.isNotEmpty ?? false) &&
        (state.userData?.savedLocaleKeyFilePath.isNotEmpty ?? false);

    return Scaffold(
      persistentFooterButtons: [
        AppButton(
          text: "GENERATE/SAVE",
          isLoading: _isSaving,
          onPressed: isHasValidData() && !_isSaving
              ? () => _onGenerateSave(state)
              : null,
          background: AppColors.success,
        ),
      ],
      appBar: AppBar(
        title: const Text("Custom Path"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                color: AppColors.greyDark,
              ),
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      state.userData?.excelFilePath.isEmpty ?? true
                          ? "Excel Path"
                          : state.userData!.excelFilePath,
                      style: appTextTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                      ),
                    ),
                  ),
                  IconButton.filled(
                    onPressed: notifier.onImportSheet,
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.info,
                    ),
                    icon: const Icon(Icons.file_upload_rounded),
                  ),
                ],
              ),
            ),
            AppSpace.y(),
            TextFormField(
              cursorColor: AppColors.textPrimary,
              controller: translateTextController,
              onChanged: (value) {
                final data = state.userData;
                if (data == null) return;
                notifier.setUserData(
                  data.copyWith(savedTranslateFilePath: value),
                );
              },
              decoration: const InputDecoration(labelText: "Translation path"),
            ),
            AppSpace.y(),
            TextFormField(
              cursorColor: AppColors.textPrimary,
              controller: localeKeyTextController,
              onChanged: (value) {
                final data = state.userData;
                if (data == null) return;
                notifier.setUserData(
                  data.copyWith(savedLocaleKeyFilePath: value),
                );
              },
              decoration: const InputDecoration(labelText: "Locale Keys path"),
            ),
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "Make sure your project knows where to find the generated files.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
