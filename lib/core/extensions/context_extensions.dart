import 'package:flutter/material.dart';
import 'package:lan_gen/shared/themes/app_text_theme.dart';

import '../../shared/app_colors.dart';

extension ContextExtension on BuildContext {
  void hideKeyboard() =>
      WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();

  // Size get mediaQuerySize => MediaQuery.sizeOf(this).width;

  double get mediaQueryWidth => MediaQuery.sizeOf(this).width;
  double get mediaQueryHeight => MediaQuery.sizeOf(this).height;

  double get smallSpacing => 4;
  double get mediumSpacing => 8;
  double get regularSpacing => 16;
  double get bigSpacing => 20;
  double get hugeSpacing => 26;

  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> get errorSnackBar =>
      ScaffoldMessenger.of(this).showSnackBar(
        const SnackBar(
          backgroundColor: Colors.red,
          content: Text("Something went wrong!"),
        ),
      );

  get successSnackBar => ScaffoldMessenger.of(this).showSnackBar(
    const SnackBar(
      backgroundColor: AppColors.primary,
      content: Text("Yay! successfully"),
    ),
  );
  get connectedSnackBar => ScaffoldMessenger.of(this).showSnackBar(
    SnackBar(
      // backgroundColor: AppColors.dark,
      content: Text(
        "Yay! Connected",
        style: appTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
  );
  get disconnectedSnackBar => ScaffoldMessenger.of(this).showSnackBar(
     SnackBar(
      backgroundColor: AppColors.secondary,
      content: Text(
        "Ops! You're disconnected",
        style: appTextTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
      ),
    ),
  );
}

extension AppPadding on BuildContext {
  EdgeInsets get smallGap =>
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4);
  EdgeInsets get mediumGap =>
      const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
  EdgeInsets get regularGap =>
      const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  EdgeInsets get bigGap =>
      const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
  EdgeInsets get hugeGap =>
      const EdgeInsets.symmetric(horizontal: 24, vertical: 20);
}

extension PaddingExtensionAll on BuildContext {
  EdgeInsets get paddingSmall => EdgeInsets.all(smallSpacing);
  EdgeInsets get paddingMedium => EdgeInsets.all(mediumSpacing);
  EdgeInsets get paddingRegular => EdgeInsets.all(regularSpacing);
  EdgeInsets get paddingBig => EdgeInsets.all(bigSpacing);
  EdgeInsets get paddingHuge => EdgeInsets.all(hugeSpacing);
}

extension WidgetExtension on Widget {
  Widget get toSliver {
    return SliverToBoxAdapter(child: this);
  }
}
