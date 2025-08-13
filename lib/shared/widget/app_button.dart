import 'package:flutter/material.dart';

import '../app_colors.dart';
import '../app_dimensions.dart';

enum AppButtonType { primary, secondary, outline, text }

class AppButton extends StatelessWidget {
  const AppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.type = AppButtonType.primary,

    this.isLoading = false,
    this.icon,
    this.background,
    this.fixedSize,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final Color? background;
  final Size? fixedSize;

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButtonWidget(context);

    return buttonWidget;
  }

  Widget _buildButtonWidget(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: background,
            fixedSize: fixedSize,
          ),
          onPressed: onPressed,
          child: _buildButtonContent(context),
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: background ?? AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
            fixedSize: fixedSize,
          ),
          child: _buildButtonContent(context),
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(fixedSize: fixedSize),
          child: _buildButtonContent(context),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: onPressed,
          style: TextButton.styleFrom(fixedSize: fixedSize),
          child: _buildButtonContent(context),
        );
    }
  }

  Widget _buildLoadingButton() {
    return ElevatedButton(
      onPressed: null,
      child: SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            type == AppButtonType.outline || type == AppButtonType.text
                ? AppColors.primary
                : AppColors.surface,
          ),
        ),
      ),
    );
  }

  Widget _buildButtonContent(BuildContext context) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18),
          const SizedBox(width: AppDimensions.xs),
          Text(text),
        ],
      );
    }

    return Text(text);
  }
}
