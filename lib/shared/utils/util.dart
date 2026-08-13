import 'dart:async';

import 'package:flutter/material.dart';

import '../themes/app_text_theme.dart';
import '../themes/themes.dart';

class AppUtils {
  AppUtils._();

  static void showSnackBar(BuildContext context, {required String msg}) =>
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.secondary,
          content: Text(
            msg,
            style: appTextTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
}

class Debouncer {
  static Timer? _timer;
  final int milliseconds;

  Debouncer({this.milliseconds = 500});

  void run(VoidCallback action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
