import 'package:flutter/material.dart';

class InputPath extends StatelessWidget {
  final TextEditingController translateTextController, localeKeyTextController;
  const InputPath({
    super.key,
    required this.translateTextController,
    required this.localeKeyTextController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(controller: translateTextController),

        TextFormField(controller: translateTextController),
      ],
    );
  }
}
