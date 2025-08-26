import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lan_gen/shared/provider/translate_provider/translation_provider.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';
import 'package:lan_gen/shared/widget/app_button.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

import '../../shared/themes/themes.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(translationProvider);
    final userTrData = provider.userTrHistory;
    return Scaffold(
      appBar: AppBar(
        title: Text("<HISTORY/>", style: appTextTheme.headlineSmall),
        automaticallyImplyLeading: false,
      ),
      body: ListView.separated(
        padding: EdgeInsets.all(12),
        itemCount: userTrData?.length ?? 0,
        separatorBuilder: (context, index) => AppSpace.y(),
        itemBuilder: (context, index) {
          final itemValue = userTrData?.elementAt(index);
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
                          onPressed: () {},
                          background: AppColors.error,
                        ),
                      ),
                      AppSpace.x(),
                      Expanded(
                        child: AppButton(
                          text: "EDIT",
                          onPressed: () {
                            // widget.onSelectSheet?.call(itemValue);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
