
import 'package:flutter/material.dart';
import 'package:lan_gen/shared/app_colors.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';
import 'package:lan_gen/ui/home_page.dart';
import 'package:lan_gen/utils/storage_manager.dart';

import '../models/translation_data.dart';

class HistoryPage extends StatefulWidget {
  final void Function(UserTranslationData? value)? onSelectSheet;
  const HistoryPage({super.key, this.onSelectSheet});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  void onDeleteProject(UserTranslationData? itemValue) {
    if (itemValue == null) return;
    StorageManager.deleteProject(itemValue).whenComplete(() {
      setState(() {
        translationHistoryNotifier.value?.remove(itemValue);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("<HISTORY/>", style: appTextTheme.headlineSmall),
        automaticallyImplyLeading: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: translationHistoryNotifier,
        builder: (context, value, child) {
          return ListView.separated(
            padding: EdgeInsets.all(12),
            itemCount: value?.length ?? 0,
            separatorBuilder: (context, index) => AppSpace.y(),
            itemBuilder: (context, index) {
              final itemValue = value?.elementAt(index);
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                _buildText(
                                  title: "Project Name",
                                  value: itemValue?.name,
                                ),
                                _buildText(
                                  title: "Excel Path",
                                  value: itemValue?.excelFilePath,
                                ),
                                _buildText(
                                  title: "Json Path",
                                  value: itemValue?.savedTranslateFilePath,
                                ),
                                _buildText(
                                  title: "Key Path",
                                  value: itemValue?.savedLocaleKeyFilePath,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      AppSpace.y(),
                      Row(
                        children: [
                          Expanded(
                            child: AppButton(
                              text: "DELETE",
                              onPressed: () => onDeleteProject(itemValue),
                              background: AppColors.error,
                            ),
                          ),
                          AppSpace.x(),
                          Expanded(
                            child: AppButton(text: "EDIT", onPressed: () {
                              widget.onSelectSheet?.call(itemValue);
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildText({required String title, required String? value}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "$title: ",
              style: appTextTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SelectableText(
            value ?? "N/A",
            selectionColor: AppColors.info,
            style: appTextTheme.bodyMedium?.copyWith(
              decoration: TextDecoration.underline,
            ),
          ),
        ],
      ),
    );
  }
}
