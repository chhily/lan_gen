import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../app_colors.dart';

class AppLoading extends StatelessWidget {
  final Color? color;
  final double? size;
  const AppLoading({super.key, this.color, this.size});

  static void show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AppLoading(),
      ),
    );
  }

  static void close(BuildContext context) {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: LoadingAnimationWidget.inkDrop(
        color: color ?? AppColors.greyLight,
        size: size ?? 24,
      ),
    );
  }
}
