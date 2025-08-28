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
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  Future<void> run(VoidCallback action) async {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }
}
