import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:lan_gen/models/translation_data.dart';
import 'package:lan_gen/shared/themes/app_theme.dart';
import 'package:lan_gen/ui/home_page.dart';
import 'package:lan_gen/utils/exportor_manager.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Directory supportDir = kReleaseMode
      ? await getApplicationSupportDirectory()
      : await getTemporaryDirectory();
  await Hive.initFlutter(supportDir.path);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Hive.registerAdapter(TranslationDataAdapter());
  }

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
