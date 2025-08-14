import 'package:flutter/material.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/themes/themes.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/ui/home_page.dart';

class InputPath extends StatefulWidget {
  final void Function()? onPressed;
  final void Function()? onPressedImport;
  const InputPath({super.key, this.onPressed, this.onPressedImport});

  @override
  State<InputPath> createState() => _InputPathState();
}

class _InputPathState extends State<InputPath> {
  late TextEditingController translateTextController;
  late TextEditingController localeKeyTextController;

  @override
  void initState() {
    super.initState();

    translateTextController = TextEditingController();
    localeKeyTextController = TextEditingController();

    // Initialize with current translationData values
    final data = translationData.value;
    translateTextController.text = data.savedTranslateFilePath;
    localeKeyTextController.text = data.savedLocaleKeyFilePath;

    // Listen to translationData changes
    translationData.addListener(_updateControllers);
  }

  void _updateControllers() {
    final data = translationData.value;
    // Only update if values are different to avoid cursor jump
    if (translateTextController.text != data.savedLocaleKeyFilePath) {
      translateTextController.text = data.savedLocaleKeyFilePath;
    }
    if (localeKeyTextController.text != data.savedLocaleKeyFilePath) {
      localeKeyTextController.text = data.savedLocaleKeyFilePath;
    }
  }

  @override
  void dispose() {
    translationData.removeListener(_updateControllers);
    translateTextController.dispose();
    localeKeyTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      persistentFooterButtons: [
        AppButton(
          text: "GENERATE",
          onPressed: widget.onPressed,
          background: AppColors.success,
        ),
      ],
      appBar: AppBar(
        title: const Text("Custom Path"),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border, width: 1),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                color: AppColors.greyLight,
              ),
              padding: const EdgeInsets.all(8),
              child: ValueListenableBuilder(
                valueListenable: translationData,
                builder: (context, value, child) {
                  return Row(
                    children: [
                      Expanded(
                        child: Text(
                          value.excelFilePath.isEmpty
                              ? "Excel Path"
                              : value.excelFilePath,
                          style: appTextTheme.bodySmall?.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                      IconButton.filled(
                        onPressed: widget.onPressedImport,
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.info,
                        ),
                        icon: const Icon(Icons.file_upload_rounded),
                      ),
                    ],
                  );
                },
              ),
            ),
            AppSpace.y(),
            TextFormField(
              cursorColor: AppColors.textPrimary,
              controller: translateTextController,
              decoration: const InputDecoration(labelText: "Translation path"),
            ),
            AppSpace.y(),
            TextFormField(
              cursorColor: AppColors.textPrimary,
              controller: localeKeyTextController,
              decoration: const InputDecoration(labelText: "Locale Keys path"),
            ),
            const Padding(
              padding: EdgeInsets.all(40.0),
              child: Text(
                "Make sure your Flutter project knows where to find the generated files.",
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
