import 'package:flutter/material.dart';
import 'package:lan_gen/shared/themes/app_theme.dart';
import 'package:lan_gen/ui/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LAN~GEN',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
