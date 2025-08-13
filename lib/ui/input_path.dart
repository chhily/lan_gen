import 'package:flutter/material.dart';
import 'package:lan_gen/shared/widget/app_space.dart';

class InputPath extends StatelessWidget {
  final TextEditingController translateTextController,
      localeKeyTextController,
      excelFilePathController;
  const InputPath({
    super.key,
    required this.translateTextController,
    required this.localeKeyTextController,
    required this.excelFilePathController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: excelFilePathController,
          enabled: false,
          decoration: InputDecoration(labelText: "Excel path"),
        ),
        AppSpace.y(),
        TextFormField(
          controller: translateTextController,

          decoration: InputDecoration(labelText: "Translation path"),
        ),
        AppSpace.y(),
        TextFormField(
          controller: translateTextController,
          decoration: InputDecoration(labelText: "Locale Keys path"),
        ),
      ],
    );
  }
}
