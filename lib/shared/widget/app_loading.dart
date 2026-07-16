import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../app_colors.dart';

class AppLoading extends StatelessWidget {
  final Color? color;
  final double? size;
  final VoidCallback? onCancel;
  const AppLoading({super.key, this.color, this.size, this.onCancel});

  /// [onCancel], if given, shows a Cancel button so a hung operation can be
  /// dismissed instead of leaving the user stuck behind the barrier forever.
  static void show(BuildContext context, {VoidCallback? onCancel}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PopScope(
        canPop: false,
        child: AppLoading(onCancel: onCancel),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.inkDrop(
            color: color ?? AppColors.greyLight,
            size: size ?? 24,
          ),
          if (onCancel != null) ...[
            const SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onCancel!();
              },
              child: const Text("Cancel"),
            ),
          ],
        ],
      ),
    );
  }
}
