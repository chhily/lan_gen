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
    this.width,
    this.height,
    this.background,
  });

  final String text;
  final VoidCallback? onPressed;
  final AppButtonType type;
  final bool isLoading;
  final IconData? icon;
  final double? width;
  final double? height;
  final Color? background;

  @override
  Widget build(BuildContext context) {
    final buttonWidget = _buildButtonWidget(context);

    return SizedBox(
      width: width ?? MediaQuery.of(context).size.width,
      height: height ?? AppDimensions.buttonHeight,
      child: buttonWidget,
    );
  }

  Widget _buildButtonWidget(BuildContext context) {
    if (isLoading) {
      return _buildLoadingButton();
    }

    switch (type) {
      case AppButtonType.primary:
        return ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: background),
          onPressed: onPressed,
          child: _buildButtonContent(context),
        );
      case AppButtonType.secondary:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: background ?? AppColors.secondary,
            foregroundColor: AppColors.textPrimary,
          ),
          child: _buildButtonContent(context),
        );
      case AppButtonType.outline:
        return OutlinedButton(
          onPressed: onPressed,
          child: _buildButtonContent(context),
        );
      case AppButtonType.text:
        return TextButton(
          onPressed: onPressed,
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
