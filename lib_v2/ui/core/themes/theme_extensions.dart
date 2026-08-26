// shared/theme/app_text_colors.dart
import 'package:flutter/material.dart';

@immutable
class AppTextColors extends ThemeExtension<AppTextColors> {

  const AppTextColors({
    required this.primary,
    required this.secondary,
    required this.onButton,
    required this.caption,
    required this.overline,
  });
  final Color primary;
  final Color secondary;
  final Color onButton;
  final Color caption;
  final Color overline;

  @override
  AppTextColors copyWith({
    Color? primary,
    Color? secondary,
    Color? onButton,
    Color? caption,
    Color? overline,
  }) {
    return AppTextColors(
      primary: primary ?? this.primary,
      secondary: secondary ?? this.secondary,
      onButton: onButton ?? this.onButton,
      caption: caption ?? this.caption,
      overline: overline ?? this.overline,
    );
  }

  @override
  AppTextColors lerp(ThemeExtension<AppTextColors>? other, double t) {
    if (other is! AppTextColors) return this;
    return AppTextColors(
      primary: Color.lerp(primary, other.primary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onButton: Color.lerp(onButton, other.onButton, t)!,
      caption: Color.lerp(caption, other.caption, t)!,
      overline: Color.lerp(overline, other.overline, t)!,
    );
  }
}
